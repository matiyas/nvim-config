return {
  "Mofiqul/vscode.nvim",
  lazy = false, -- load it during startup
  priority = 1000, -- load before other plugins
  config = function()
    -- Optional: configure theme variant and style
    vim.o.background = "dark" -- or "light"
    require("vscode").setup({
      -- Enable italic comments
      italic_comments = true,
    })
    require("vscode").load('light')
  end,
}

