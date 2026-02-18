return {
  "RRethy/nvim-treesitter-endwise",
  event = "InsertEnter",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("nvim-treesitter-endwise").setup({})
  end,
}
