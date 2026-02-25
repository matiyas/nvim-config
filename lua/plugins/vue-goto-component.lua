return {
  dir = vim.fn.stdpath("config"),
  ft = { "vue" },
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "vue",
      callback = function()
        vim.keymap.set("n", "gd", function()
          require("vue-goto-component").goto_definition()
        end, { buffer = true, desc = "Go to definition (Vue)" })
      end,
    })
  end,
}
