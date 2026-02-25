return {
  dir = "~/Workspace/vue-goto-component.nvim",
  ft = { "vue" },
  keys = {
    {
      "gd",
      function()
        require("vue-goto-component").goto_definition()
      end,
      ft = "vue",
      desc = "Go to definition (Vue)",
    },
  },
  opts = {},
}
