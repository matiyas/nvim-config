return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    -- Optional: configure style before loading
      require("tokyonight").setup({
      style = "night", -- other options: "storm", "moon", "day"
      transparent = false,
    })
    vim.cmd("colorscheme tokyonight-night")
  end,
}
