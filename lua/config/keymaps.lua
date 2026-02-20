-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--- Returns search directories including sibling dirs specified in NVIM_SIBLING_SEARCH_DIRS.
--- Example: NVIM_SIBLING_SEARCH_DIRS=shared will include ../shared in searches.
local function get_search_dirs()
  local cwd = vim.fn.getcwd()
  local sibling_dirs = vim.env.NVIM_SIBLING_SEARCH_DIRS

  if not sibling_dirs or sibling_dirs == '' then return { cwd } end

  local parent = vim.fn.fnamemodify(cwd, ':h')
  local dirs = { cwd }

  for name in sibling_dirs:gmatch('[^,]+') do
    local path = parent .. '/' .. name:match('^%s*(.-)%s*$')
    if vim.fn.isdirectory(path) == 1 then table.insert(dirs, path) end
  end

  return dirs
end

--- Converts absolute path to relative path from cwd, showing ../sibling for sibling dirs.
local function make_relative_path(absolute_path)
  local cwd = vim.fn.getcwd()
  local parent = vim.fn.fnamemodify(cwd, ':h')

  if absolute_path:sub(1, #cwd) == cwd then
    local rel = absolute_path:sub(#cwd + 2)
    return rel ~= '' and rel or '.'
  end

  if absolute_path:sub(1, #parent) == parent then
    return '..' .. absolute_path:sub(#parent + 1)
  end

  return absolute_path
end

--- Custom path display for telescope showing relative paths.
local function relative_path_display(_, path)
  return make_relative_path(path)
end

vim.keymap.set('n', '<leader>/', function()
  require('telescope').extensions.live_grep_args.live_grep_args({
    search_dirs = get_search_dirs(),
    path_display = relative_path_display,
  })
end, { desc = 'Live Grep with args' })

vim.keymap.set('n', '<leader><leader>', function()
  require('telescope.builtin').find_files({
    search_dirs = get_search_dirs(),
    path_display = relative_path_display,
  })
end, { desc = '[Find] Files from CWD' })

vim.keymap.set('n', '<leader>cp', function()
  local relative_path = vim.fn.expand('%:.')
  vim.fn.setreg('+', relative_path)
  local ok, osc52 = pcall(require, 'osc52')
  if ok then osc52.copy(relative_path) end
  print('Copied path: ' .. relative_path)
end, { desc = 'Copy file relative path' })

--- Finds and focuses an existing diffview tab.
local function focus_diffview_tab()
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
      local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(winid))
      if bufname:match('^diffview://') or bufname:match('DiffviewFiles') then
        vim.api.nvim_set_current_tabpage(tabpage)
        return true
      end
    end
  end
  return false
end

vim.keymap.set('n', '<leader>gd', function()
  if not focus_diffview_tab() then vim.cmd('DiffviewOpen') end
end, { desc = 'Open or focus git diff view' })

vim.keymap.set('n', '<leader>gq', ':DiffviewClose<CR>', { desc = 'Close git diff view' })
vim.keymap.set('n', '<M-C-n>', '<cmd>Scratch<cr>')
vim.keymap.set('n', '<M-C-o>', '<cmd>ScratchOpen<cr>')

vim.api.nvim_create_user_command('LspFormat', function()
  vim.lsp.buf.format({ async = true })
end, { desc = 'Format current buffer with LSP' })

vim.keymap.set('n', '<leader>lf', '<cmd>LspFormat<cr>', { desc = 'Format buffer with LSP' })

vim.keymap.set('n', '<leader>jq', function()
  local filename = vim.fn.expand('%:t')
  if vim.bo.filetype ~= 'json' and not filename:match('%.json$') then
    print('Not a JSON file')
    return
  end
  vim.cmd(':%!jq .')
end, { desc = 'Format JSON with jq' })
