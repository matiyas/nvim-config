-- Vue Go-To Component
-- Resolves Vue 2 component definitions from template tags
-- Uses alias path resolution as helper, then:
--   - Template tags: opens file directly (Vetur can't link these)
--   - Other code: delegates to CoC/Vetur

local M = {}

--- Find project root
local function find_project_root(start_dir)
  local dir = start_dir
  while dir ~= "/" do
    if vim.fn.filereadable(dir .. "/nuxt.config.js") == 1 or
       vim.fn.filereadable(dir .. "/package.json") == 1 then
      return dir
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil
end

--- Resolve @/ or ~/ path to absolute file path
local function resolve_alias(import_path, current_file)
  local current_dir = vim.fn.fnamemodify(current_file, ":h")

  local abs_path
  if import_path:match("^[@~]/") then
    local project_root = find_project_root(current_dir)
    if not project_root then
      return nil
    end
    abs_path = project_root .. "/" .. import_path:gsub("^[@~]/", "")
  elseif import_path:match("^%.") then
    abs_path = vim.fn.simplify(current_dir .. "/" .. import_path)
  else
    return nil
  end

  -- Find actual file with extension
  local extensions = { "", ".vue", ".js", ".ts", ".jsx", ".tsx" }
  for _, ext in ipairs(extensions) do
    local try_path = abs_path .. ext
    if vim.fn.filereadable(try_path) == 1 then
      return try_path
    end
  end

  return nil
end

--- Convert kebab-case to PascalCase
local function kebab_to_pascal(str)
  return str:gsub("^%l", string.upper):gsub("%-(%l)", function(c)
    return c:upper()
  end)
end

--- HTML tags to ignore
local html_tags = {
  a=1, abbr=1, address=1, area=1, article=1, aside=1, audio=1, b=1, base=1,
  bdi=1, bdo=1, blockquote=1, body=1, br=1, button=1, canvas=1, caption=1,
  cite=1, code=1, col=1, colgroup=1, data=1, datalist=1, dd=1, del=1,
  details=1, dfn=1, dialog=1, div=1, dl=1, dt=1, em=1, embed=1, fieldset=1,
  figcaption=1, figure=1, footer=1, form=1, h1=1, h2=1, h3=1, h4=1, h5=1,
  h6=1, head=1, header=1, hr=1, html=1, i=1, iframe=1, img=1, input=1,
  ins=1, kbd=1, label=1, legend=1, li=1, link=1, main=1, map=1, mark=1,
  meta=1, meter=1, nav=1, noscript=1, object=1, ol=1, optgroup=1, option=1,
  output=1, p=1, param=1, picture=1, pre=1, progress=1, q=1, rp=1, rt=1,
  ruby=1, s=1, samp=1, script=1, section=1, select=1, small=1, source=1,
  span=1, strong=1, style=1, sub=1, summary=1, sup=1, table=1, tbody=1,
  td=1, template=1, textarea=1, tfoot=1, th=1, thead=1, time=1, title=1,
  tr=1, track=1, u=1, ul=1, var=1, video=1, wbr=1,
}

--- Get tag name under cursor
local function get_tag_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".")
  local before = line:sub(1, col)

  -- Find last unclosed <
  local last_open = 0
  for i = 1, #before do
    local c = before:sub(i, i)
    if c == "<" then
      last_open = i
    elseif c == ">" then
      last_open = 0
    end
  end

  if last_open == 0 then
    return nil
  end

  local tag = line:sub(last_open + 1):match("^/?([%w%-]+)")
  if not tag or html_tags[tag:lower()] then
    return nil
  end

  return tag
end

--- Check if cursor is in template section
local function is_in_template()
  local cursor_line = vim.fn.line(".")
  local lines = vim.api.nvim_buf_get_lines(0, 0, cursor_line, false)

  local in_template = false
  for _, line in ipairs(lines) do
    if line:match("^<template") then
      in_template = true
    elseif line:match("^</template>") then
      in_template = false
    end
  end

  return in_template
end

--- Find import for component name
local function find_component_import(component_name)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for _, line in ipairs(lines) do
    -- Static: import ComponentName from 'path'
    local name, path = line:match("import%s+(" .. component_name .. ")%s+from%s+[\"']([^\"']+)[\"']")
    if name then
      return path
    end

    -- Dynamic: ComponentName: () => import('path')
    name, path = line:match("(" .. component_name .. ")%s*:%s*%(%s*%)%s*=>%s*import%s*%([\"']([^\"']+)[\"']%)")
    if name then
      return path
    end
  end

  return nil
end

--- Find script section boundaries
local function get_script_range()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local start_line, end_line = nil, nil

  for i, line in ipairs(lines) do
    if line:match("^%s*<script") then
      start_line = i
    elseif line:match("^%s*</script>") and start_line then
      end_line = i
      break
    end
  end

  return start_line, end_line
end

--- Parse Vue component options to find section boundaries
--- Returns: { data = {start, end}, computed = {start, end}, methods = {start, end}, ... }
local function parse_component_sections()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local script_start, script_end = get_script_range()

  if not script_start or not script_end then
    return {}
  end

  local sections = {}
  local section_patterns = {
    "data", "computed", "methods", "props", "watch",
    "created", "mounted", "updated", "destroyed",
    "beforeCreate", "beforeMount", "beforeUpdate", "beforeDestroy"
  }

  -- Find export default and track brace depth
  local in_export = false
  local export_depth = 0

  for i = script_start, script_end do
    local line = lines[i]

    -- Detect export default {
    if line:match("export%s+default%s*{") or line:match("export%s+default%s*$") then
      in_export = true
    end

    if in_export then
      -- Track depth by counting braces
      local open_count = select(2, line:gsub("{", ""))
      local close_count = select(2, line:gsub("}", ""))
      export_depth = export_depth + open_count - close_count

      -- At depth 1, we're directly inside export default { }
      -- Look for section definitions
      for _, section in ipairs(section_patterns) do
        -- Match: sectionName() { or sectionName: { or sectionName: [
        local pattern1 = "^%s*" .. section .. "%s*%(%s*%)%s*{"
        local pattern2 = "^%s*" .. section .. "%s*:%s*{"
        local pattern3 = "^%s*" .. section .. "%s*:%s*%["
        local pattern4 = "^%s*" .. section .. "%s*:%s*function"
        local pattern5 = "^%s*async%s+" .. section .. "%s*%("

        if line:match(pattern1) or line:match(pattern2) or
           line:match(pattern3) or line:match(pattern4) or
           line:match(pattern5) then
          -- Found section start, now find its end by tracking depth
          local section_depth = 0
          local section_start = i

          for j = i, script_end do
            local sline = lines[j]
            local sopen = select(2, sline:gsub("{", "")) + select(2, sline:gsub("%[", ""))
            local sclose = select(2, sline:gsub("}", "")) + select(2, sline:gsub("%]", ""))
            section_depth = section_depth + sopen - sclose

            if section_depth == 0 and j > i then
              sections[section] = { start = section_start, finish = j }
              break
            end
          end
        end
      end

      if export_depth == 0 then
        break
      end
    end
  end

  return sections
end

--- Find property definition within a specific section
--- target_depth: 1 for computed/methods, 2 for data() return object
local function find_in_section(name, section, target_depth)
  if not section then
    return nil
  end

  target_depth = target_depth or 1
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local escaped_name = name:gsub("([%.%-%+%[%]%(%)%$%^%%%?%*])", "%%%1")

  -- Track depth to find definitions at the right level
  local depth = 0

  for i = section.start, section.finish do
    local line = lines[i]

    -- Count braces on this line
    local open_count = select(2, line:gsub("{", "")) + select(2, line:gsub("%[", ""))
    local close_count = select(2, line:gsub("}", "")) + select(2, line:gsub("%]", ""))

    -- Check for definitions BEFORE updating depth
    if i == section.start then
      depth = open_count - close_count
    else
      -- Check at target depth (before this line's braces)
      if depth == target_depth then
        -- Method definition: name() { or async name()
        if line:match("^%s*" .. escaped_name .. "%s*%(") or
           line:match("^%s*async%s+" .. escaped_name .. "%s*%(") then
          return i
        end

        -- Spread operator: ...mapGetters etc - skip
        if not line:match("^%s*%.%.%.") then
          -- Property definition: name: (but not name: this. which is a reference)
          if line:match("^%s*" .. escaped_name .. "%s*:") then
            local after_colon = line:match("^%s*" .. escaped_name .. "%s*:%s*(.+)")
            if not after_colon or not after_colon:match("^this%.") then
              return i
            end
          end

          -- Shorthand: name, or name (at end)
          if line:match("^%s*" .. escaped_name .. "%s*,$") or
             line:match("^%s*" .. escaped_name .. "%s*$") then
            return i
          end
        end
      end

      -- Update depth after checking
      depth = depth + open_count - close_count
    end
  end

  return nil
end

--- Find mixin imports and their file paths
local function find_mixins()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local mixins = {}

  for _, line in ipairs(lines) do
    -- import MixinName from 'path'
    local name, path = line:match("import%s+([%w_]+)%s+from%s+[\"']([^\"']+)[\"']")
    if name then
      mixins[name] = path
    end
  end

  -- Find mixins array in component
  local script_start, script_end = get_script_range()
  if not script_start then
    return {}
  end

  local used_mixins = {}
  local in_mixins = false
  local depth = 0

  for i = script_start, script_end do
    local line = lines[i]

    if line:match("^%s*mixins%s*:%s*%[") then
      in_mixins = true
    end

    if in_mixins then
      depth = depth + select(2, line:gsub("%[", "")) - select(2, line:gsub("%]", ""))

      -- Extract mixin names
      for mixin_name in line:gmatch("([%w_]+)") do
        if mixins[mixin_name] then
          table.insert(used_mixins, { name = mixin_name, path = mixins[mixin_name] })
        end
      end

      if depth == 0 then
        break
      end
    end
  end

  return used_mixins
end

--- Search for property in mixin files
local function find_in_mixins(name)
  local mixins = find_mixins()
  local filepath = vim.api.nvim_buf_get_name(0)

  for _, mixin in ipairs(mixins) do
    local resolved = resolve_alias(mixin.path, filepath)
    if resolved and vim.fn.filereadable(resolved) == 1 then
      -- Read mixin file and search for property
      local mixin_lines = vim.fn.readfile(resolved)
      local escaped_name = name:gsub("([%.%-%+%[%]%(%)%$%^%%%?%*])", "%%%1")

      for i, line in ipairs(mixin_lines) do
        -- Method: name() { or async name()
        if line:match("^%s*" .. escaped_name .. "%s*%(") or
           line:match("^%s*async%s+" .. escaped_name .. "%s*%(") then
          return resolved, i
        end
        -- Property: name:
        if line:match("^%s*" .. escaped_name .. "%s*:") then
          return resolved, i
        end
      end
    end
  end

  return nil, nil
end

--- Find property/method definition
local function find_property_definition(name, current_line)
  local sections = parse_component_sections()

  -- Search order with target depths:
  -- data() returns object, so properties are at depth 2
  -- computed/methods/props/watch are objects, properties at depth 1
  local search_order = {
    { name = "computed", depth = 1 },
    { name = "methods", depth = 1 },
    { name = "data", depth = 2 },
    { name = "props", depth = 1 },
    { name = "watch", depth = 1 },
  }

  for _, search in ipairs(search_order) do
    local section = sections[search.name]
    if section then
      local def_line = find_in_section(name, section, search.depth)
      if def_line and def_line ~= current_line then
        return def_line, nil -- line in current file
      end
    end
  end

  -- Search in mixins
  local mixin_file, mixin_line = find_in_mixins(name)
  if mixin_file then
    return mixin_line, mixin_file
  end

  return nil, nil
end

--- Get word under cursor
local function get_word_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".")

  local start_col = col
  local end_col = col

  while start_col > 1 do
    local c = line:sub(start_col - 1, start_col - 1)
    if c:match("[%w_]") then
      start_col = start_col - 1
    else
      break
    end
  end

  while end_col <= #line do
    local c = line:sub(end_col, end_col)
    if c:match("[%w_]") then
      end_col = end_col + 1
    else
      break
    end
  end

  if start_col >= end_col then
    return nil
  end

  return line:sub(start_col, end_col - 1)
end

--- Keywords to skip
local keywords = {
  ["true"] = 1, ["false"] = 1, ["null"] = 1, ["undefined"] = 1,
  ["if"] = 1, ["else"] = 1, ["for"] = 1, ["while"] = 1, ["do"] = 1,
  ["return"] = 1, ["function"] = 1, ["const"] = 1, ["let"] = 1, ["var"] = 1,
  ["this"] = 1, ["new"] = 1, ["typeof"] = 1, ["instanceof"] = 1,
  ["import"] = 1, ["export"] = 1, ["default"] = 1, ["from"] = 1,
  ["async"] = 1, ["await"] = 1, ["class"] = 1, ["extends"] = 1,
  ["in"] = 1, ["of"] = 1, ["switch"] = 1, ["case"] = 1, ["break"] = 1,
  ["try"] = 1, ["catch"] = 1, ["finally"] = 1, ["throw"] = 1,
}

--- Check if current line is an import and get the path
local function get_import_path_on_line()
  local line = vim.api.nvim_get_current_line()

  -- Static import: import X from 'path'
  local path = line:match("import%s+[%w_]+%s+from%s+[\"']([^\"']+)[\"']")
  if path then
    return path
  end

  -- Dynamic import: () => import('path')
  path = line:match("import%s*%([\"']([^\"']+)[\"']%)")
  if path then
    return path
  end

  return nil
end

--- Go to definition
function M.goto_definition()
  if vim.bo.filetype ~= "vue" then
    vim.fn.CocAction("jumpDefinition")
    return
  end

  local word = get_word_under_cursor()
  local filepath = vim.api.nvim_buf_get_name(0)

  -- Check if on import line - go to imported file
  local import_path = get_import_path_on_line()
  if import_path then
    local resolved = resolve_alias(import_path, filepath)
    if resolved then
      vim.cmd("edit " .. vim.fn.fnameescape(resolved))
      return
    end
  end

  -- Check if on template tag (component)
  if is_in_template() then
    local tag = get_tag_under_cursor()
    if tag then
      local component_name = kebab_to_pascal(tag)
      local component_import = find_component_import(component_name)

      if component_import then
        local resolved = resolve_alias(component_import, filepath)

        if resolved then
          vim.cmd("edit " .. vim.fn.fnameescape(resolved))
          return
        end
      end
    end
  end

  -- Try to find property/method definition
  if word and not keywords[word] then
    local current_line = vim.fn.line(".")
    local def_line, def_file = find_property_definition(word, current_line)

    if def_file then
      -- Definition is in another file (mixin)
      vim.cmd("edit " .. vim.fn.fnameescape(def_file))
      vim.api.nvim_win_set_cursor(0, { def_line, 0 })
      vim.cmd("normal! ^")
      local line = vim.api.nvim_get_current_line()
      local pos = line:find(word, 1, true)
      if pos then
        vim.api.nvim_win_set_cursor(0, { def_line, pos - 1 })
      end
      return
    elseif def_line then
      -- Definition is in current file
      vim.api.nvim_win_set_cursor(0, { def_line, 0 })
      vim.cmd("normal! ^")
      local line = vim.api.nvim_get_current_line()
      local pos = line:find(word, 1, true)
      if pos then
        vim.api.nvim_win_set_cursor(0, { def_line, pos - 1 })
      end
      return
    end
  end

  -- Fallback to CoC for everything else
  vim.fn.CocAction("jumpDefinition")
end

return M
