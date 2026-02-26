return {
  "matiyas/ruby-namespace-copy.nvim",
  ft = { "ruby" },
  opts = {},
  keys = {
    {
      "<leader>yn",
      function()
        require("ruby-namespace-copy").copy_namespace()
      end,
      desc = "Yank Ruby namespace",
      ft = "ruby",
    },
  },
}
