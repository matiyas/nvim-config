require("config.lazy")

vim.opt.colorcolumn = "120"
vim.cmd("colorscheme tokyonight-night")
vim.opt.relativenumber = false
vim.opt.guicursor = "n-v-c:block-Cursor,i:ver25-Cursor"

-- Disable ALL diagnostics (red/yellow underlines)
vim.diagnostic.disable()

-- OR: Only show errors (hide warnings/info)
vim.diagnostic.config({
  virtual_text = false, -- Remove inline underlines
  signs = false, -- Hide gutter icons (⚠️/💡)
  underline = false, -- Disable wavy lines
  update_in_insert = false, -- Don't update while typing
})

vim.opt.ignorecase = true -- Ignore case in searches
vim.opt.smartcase = false -- But make it case-sensitive if uppercase letters are used
