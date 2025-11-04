return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "moon", -- Default to moon theme
        transparent = false,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
        },
        on_colors = function(colors) end,
        on_highlights = function(highlights, colors) end,
      })

      -- Set up dark-notify integration for automatic theme switching
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
        vim.cmd("colorscheme tokyonight-moon")
      end
    end,
  },
}
