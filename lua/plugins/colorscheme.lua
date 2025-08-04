return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = false,
        styles = {
          comments = { italic = true },
        },
      })

      -- Set up dark-notify integration
      if vim.fn.has("mac") == 1 then
        require("dark_notify").run({
          onchange = function(mode)
            if mode == "dark" then
              vim.cmd("colorscheme tokyonight-night")
            else
              vim.cmd("colorscheme tokyonight-day")
            end
          end,
        })
      else
        vim.cmd("colorscheme tokyonight-night")
      end
    end,
  },
}
