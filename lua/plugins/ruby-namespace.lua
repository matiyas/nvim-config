return {
  "nvim-treesitter/nvim-treesitter",
  keys = {
    {
      "<leader>yn",
      function()
        require("ruby-namespace").copy_ruby_namespace()
      end,
      desc = "Yank Ruby namespace",
      ft = "ruby",
    },
  },
}
