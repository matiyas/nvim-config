return {
  "matiyas/vue-sfc-format.nvim",
  ft = { "vue" },
  opts = {},
  keys = {
    {
      "<leader>fv",
      function()
        require("vue-sfc-format").format()
      end,
      desc = "Format Vue SFC",
      ft = "vue",
    },
  },
}
