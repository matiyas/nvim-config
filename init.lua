require("config.lazy")
require("lazy").setup({
  {"nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate"}
})

vim.opt.colorcolumn = "120"
vim.cmd("colorscheme tokyonight-night")
vim.opt.relativenumber = false
