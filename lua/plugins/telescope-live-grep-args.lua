return {
  "nvim-telescope/telescope-live-grep-args.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    local ignore = require("config.ignore")
    local glob_patterns = {}
    for _, dir in ipairs(ignore.get_ignored_dirs()) do
      table.insert(glob_patterns, "--glob=!" .. dir .. "/**")
    end
    require("telescope").setup({
      extensions = {
        live_grep_args = {
          auto_quoting = true,
          additional_args = glob_patterns,
        },
      },
    })
    require("telescope").load_extension("live_grep_args")
  end,
}
