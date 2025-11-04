return {
  "rickhowe/diffchar.vim",
  event = { "BufRead", "BufNewFile" },
  config = function()
    vim.g.DiffColors = 100
    vim.g.DiffUnit = "Word1"
  end,
}