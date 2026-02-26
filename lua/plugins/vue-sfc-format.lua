return {
  "matiyas/vue-sfc-format.nvim",
  ft = { "vue" },
  config = function()
    require("vue-sfc-format").setup()

    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.vue",
      callback = function()
        require("vue-sfc-format").format()
      end,
    })
  end,
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
