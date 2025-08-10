require("config.lazy")

vim.opt.colorcolumn = "120"
vim.cmd("colorscheme tokyonight-day")
vim.opt.relativenumber = false
vim.opt.guicursor = "n-v-c:block-Cursor,i:ver25-Cursor"
vim.opt.ignorecase = true -- Ignore case in searches
vim.opt.smartcase = false -- But make it case-sensitive if uppercase letters are used

-- vim.lsp.set_log_level("debug")

function _G.compare_to_clipboard(opts)
  local ftype = vim.api.nvim_eval("&filetype")

  -- Get visual selection if range provided, otherwise use entire buffer
  local content
  if opts.range == 2 then -- Visual selection
    local start_line = opts.line1 - 1
    local end_line = opts.line2
    content = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  else
    content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  end

  -- Create new tab and buffer with selection
  vim.cmd("tabnew")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
  vim.cmd("diffthis")

  -- Create clipboard buffer
  vim.cmd("vnew")
  vim.cmd("normal! P")
  vim.cmd("setlocal buftype=nowrite")
  vim.cmd("set filetype=" .. ftype)
  vim.cmd("diffthis")
end

vim.api.nvim_create_user_command("DiffWithClipboard", _G.compare_to_clipboard, { range = true })
vim.opt.termguicolors = true
require("bufferline").setup({})
