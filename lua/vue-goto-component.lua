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

--- Go to definition
function M.goto_definition()
  if vim.bo.filetype ~= "vue" then
    vim.fn.CocAction("jumpDefinition")
    return
  end

  -- Check if on template tag
  if is_in_template() then
    local tag = get_tag_under_cursor()
    if tag then
      local component_name = kebab_to_pascal(tag)
      local import_path = find_component_import(component_name)

      if import_path then
        local filepath = vim.api.nvim_buf_get_name(0)
        local resolved = resolve_alias(import_path, filepath)

        if resolved then
          vim.cmd("edit " .. vim.fn.fnameescape(resolved))
          return
        end
      end
    end
  end

  -- Fallback to CoC for everything else
  vim.fn.CocAction("jumpDefinition")
end

return M
