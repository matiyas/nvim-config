return {
  "LintaoAmons/scratch.nvim",
  event = "VeryLazy",
  config = function()
    require("scratch").setup({
      filetypes = {
        "html", "css", "scss", "js", "vue",
        "json", "yml",
        "sh", "py", "rb",
        "md", "txt",
      },
    })
  end,
}
