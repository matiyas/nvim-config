-- Vue Alias Middleware
-- Transforms alias imports (@/, ~/) to relative paths in buffer for LSP
-- Restores original imports on save so file on disk remains unchanged
--
-- Flow:
-- 1. BufReadPost: Store original imports, transform to relative paths
-- 2. TextChanged: Transform new imports to relative paths
-- 3. BufWritePre: Restore original alias imports
-- 4. BufWritePost: Transform back to relative paths

local M = {}

--- Alias prefixes to transform
M.alias_prefixes = { "@/", "~/" }

--- File extensions to try when resolving
M.extensions = { ".vue", ".js", ".ts", ".jsx", ".tsx", "/index.vue", "/index.js", "/index.ts" }

--- Buffer-local storage for original import lines
--- Key: bufnr, Value: { [line_nr] = original_line_text }
local original_imports = {}

--- Track which buffers have been transformed
local transformed_buffers = {}

--- Cache for project root detection
local project_root_cache = {}

--- Find project root by looking for common markers
local function find_project_root(start_dir)
  if project_root_cache[start_dir] then
    return project_root_cache[start_dir]
  end

  local markers = { "nuxt.config.js", "nuxt.config.ts", "package.json", ".git" }
  local dir = start_dir

  while dir ~= "/" do
    for _, marker in ipairs(markers) do
      local marker_path = dir .. "/" .. marker
      if vim.fn.filereadable(marker_path) == 1 or vim.fn.isdirectory(marker_path) == 1 then
        project_root_cache[start_dir] = dir
        return dir
      end
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end

  return nil
end

--- Check if path starts with an alias
local function has_alias(path)
  for _, alias in ipairs(M.alias_prefixes) do
    if path:sub(1, #alias) == alias then
      return true, alias
    end
  end
  return false, nil
end

--- Resolve alias path to relative path with extension
local function resolve_to_relative(import_path, current_file)
  local has, alias = has_alias(import_path)
  if not has then
    return nil
  end

  local current_dir = vim.fn.fnamemodify(current_file, ":h")
  local project_root = find_project_root(current_dir)

  if not project_root then
    return nil
  end

  local path_after_alias = import_path:sub(#alias + 1)
  local absolute_path = project_root .. "/" .. path_after_alias

  -- Try to find the actual file with extension
  local resolved_absolute = nil

  -- First try exact path
  if vim.fn.filereadable(absolute_path) == 1 then
    resolved_absolute = absolute_path
  else
    -- Try extensions
    for _, ext in ipairs(M.extensions) do
      local try_path = absolute_path .. ext
      if vim.fn.filereadable(try_path) == 1 then
        resolved_absolute = try_path
        break
      end
    end

    -- Try glob for partial matches
    if not resolved_absolute then
      local base_name = vim.fn.fnamemodify(absolute_path, ":t")
      local parent_dir = vim.fn.fnamemodify(absolute_path, ":h")

      if vim.fn.isdirectory(parent_dir) == 1 then
        local matches = vim.fn.glob(parent_dir .. "/" .. base_name .. ".*", false, true)
        for _, match in ipairs(matches) do
          if match:match("%.vue$") then
            resolved_absolute = match
            break
          end
        end
        if not resolved_absolute and #matches > 0 then
          resolved_absolute = matches[1]
        end
      end
    end
  end

  if not resolved_absolute then
    return nil
  end

  -- Convert to relative path from current file's directory
  -- Use Python-style relpath calculation
  local function make_relative(target, base)
    -- Normalize paths
    target = vim.fn.resolve(target)
    base = vim.fn.resolve(base)

    -- Split into parts
    local function split_path(p)
      local parts = {}
      for part in p:gmatch("[^/]+") do
        table.insert(parts, part)
      end
      return parts
    end

    local target_parts = split_path(target)
    local base_parts = split_path(base)

    -- Find common prefix length
    local common = 0
    for i = 1, math.min(#target_parts, #base_parts) do
      if target_parts[i] == base_parts[i] then
        common = i
      else
        break
      end
    end

    -- Build relative path
    local rel_parts = {}

    -- Add ../ for each remaining base part
    for _ = common + 1, #base_parts do
      table.insert(rel_parts, "..")
    end

    -- Add remaining target parts
    for i = common + 1, #target_parts do
      table.insert(rel_parts, target_parts[i])
    end

    if #rel_parts == 0 then
      return "."
    end

    local result = table.concat(rel_parts, "/")

    -- Ensure it starts with ./ or ../
    if not result:match("^%.") then
      result = "./" .. result
    end

    return result
  end

  return make_relative(resolved_absolute, current_dir)
end

--- Parse a line and extract import path if present
local function parse_import_line(line)
  -- Match: import X from 'path' or import X from "path"
  local path = line:match("from%s+['\"]([^'\"]+)['\"]")
  if path then
    return path
  end

  -- Match: import('path') for dynamic imports
  path = line:match("import%(['\"]([^'\"]+)['\"]%)")
  return path
end

--- Replace import path in a line
local function replace_import_path(line, old_path, new_path)
  -- Escape special pattern characters in old_path
  local escaped = old_path:gsub("([%.%-%+%[%]%(%)%$%^%%%?%*])", "%%%1")

  -- Try both quote styles
  local result = line:gsub("(['\"])" .. escaped .. "(['\"])", "%1" .. new_path .. "%2")
  return result
end

--- Notify CoC that document content has changed
local function notify_coc_change(bufnr)
  -- Force CoC to re-sync document content by triggering a change event
  -- Method 1: Make a small edit and undo to trigger CoC's change detection
  local current_buf = vim.api.nvim_get_current_buf()
  if current_buf == bufnr then
    -- Save cursor and undo state
    local cursor = vim.api.nvim_win_get_cursor(0)
    local undolevels = vim.bo[bufnr].undolevels

    -- Disable undo temporarily
    vim.bo[bufnr].undolevels = -1

    -- Make a tiny change and revert
    local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
    vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { first_line .. " " })
    vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, { first_line })

    -- Restore undo state
    vim.bo[bufnr].undolevels = undolevels

    -- Restore cursor
    pcall(vim.api.nvim_win_set_cursor, 0, cursor)
  end

  -- Method 2: Trigger TextChanged autocmd
  vim.api.nvim_exec_autocmds("TextChanged", { buffer = bufnr })

  -- Method 3: If CoC is ready, use its API
  if vim.fn.exists("*coc#rpc#ready") == 1 then
    vim.defer_fn(function()
      if vim.fn["coc#rpc#ready"]() then
        pcall(function()
          vim.fn.CocActionAsync("ensureDocument")
        end)
      end
    end, 50)
  end

  -- Mark as not modified after all changes
  vim.bo[bufnr].modified = false
end

--- Transform all alias imports in buffer to relative paths
function M.transform_to_relative(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  if filepath == "" then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local modified = false

  -- Initialize storage for this buffer
  if not original_imports[bufnr] then
    original_imports[bufnr] = {}
  end

  for i, line in ipairs(lines) do
    local import_path = parse_import_line(line)

    if import_path then
      local has_alias_flag = has_alias(import_path)

      if has_alias_flag then
        -- Store original line if not already stored
        if not original_imports[bufnr][i] then
          original_imports[bufnr][i] = line
        end

        -- Resolve to relative path
        local relative_path = resolve_to_relative(import_path, filepath)

        if relative_path then
          local new_line = replace_import_path(line, import_path, relative_path)
          if new_line ~= line then
            lines[i] = new_line
            modified = true
          end
        end
      end
    end
  end

  if modified then
    -- Temporarily disable events to avoid recursion
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    -- Notify CoC about the change (also resets modified flag)
    notify_coc_change(bufnr)
  end
end

--- Restore original alias imports in buffer
function M.restore_original(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local originals = original_imports[bufnr]
  if not originals or vim.tbl_isempty(originals) then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local modified = false

  for line_nr, original_line in pairs(originals) do
    if line_nr <= #lines then
      -- Extract the import path from current and original
      local current_path = parse_import_line(lines[line_nr])
      local original_path = parse_import_line(original_line)

      if current_path and original_path then
        -- Replace current relative path with original alias path
        local restored_line = replace_import_path(lines[line_nr], current_path, original_path)
        if restored_line ~= lines[line_nr] then
          lines[line_nr] = restored_line
          modified = true
        end
      end
    end
  end

  if modified then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  end
end

--- Clean up buffer storage
function M.cleanup(bufnr)
  original_imports[bufnr] = nil
  transformed_buffers[bufnr] = nil
end

--- Setup autocmds for the middleware
function M.setup()
  local group = vim.api.nvim_create_augroup("VueAliasMiddleware", { clear = true })

  -- Transform imports when file is read (use BufEnter for better timing with CoC)
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    pattern = "*.vue",
    callback = function(args)
      -- Only transform once per buffer
      if transformed_buffers[args.buf] then
        return
      end

      -- Delay to ensure CoC has initialized the document
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(args.buf) and not transformed_buffers[args.buf] then
          transformed_buffers[args.buf] = true
          M.transform_to_relative(args.buf)
        end
      end, 200)
    end,
  })

  -- Restore originals before write
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    pattern = "*.vue",
    callback = function(args)
      M.restore_original(args.buf)
    end,
  })

  -- Transform back after write
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*.vue",
    callback = function(args)
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          M.transform_to_relative(args.buf)
          vim.bo[args.buf].modified = false
        end
      end, 100)
    end,
  })

  -- Clean up when buffer is deleted
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    pattern = "*.vue",
    callback = function(args)
      M.cleanup(args.buf)
    end,
  })

  -- Handle new imports added while editing
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    pattern = "*.vue",
    callback = function(args)
      -- Check if current line has a new alias import
      local line = vim.api.nvim_get_current_line()
      local import_path = parse_import_line(line)

      if import_path and has_alias(import_path) then
        local line_nr = vim.fn.line(".")
        local filepath = vim.api.nvim_buf_get_name(args.buf)

        -- Store original
        if not original_imports[args.buf] then
          original_imports[args.buf] = {}
        end
        original_imports[args.buf][line_nr] = line

        -- Transform
        local relative_path = resolve_to_relative(import_path, filepath)
        if relative_path then
          local new_line = replace_import_path(line, import_path, relative_path)
          if new_line ~= line then
            vim.api.nvim_set_current_line(new_line)
          end
        end
      end
    end,
  })
end

--- Manual command to re-transform current buffer
function M.refresh()
  local bufnr = vim.api.nvim_get_current_buf()
  original_imports[bufnr] = {} -- Clear stored originals
  M.transform_to_relative(bufnr)
end

return M
