return {
  dir = "~/Workspace/vue-goto-component.nvim",
  ft = { "vue" },
  opts = {},
  config = function()
    require("vue-goto-component").setup()

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        if vim.bo[args.buf].filetype == "vue" then
          -- Defer to run after LazyVim sets up its keymaps
          vim.defer_fn(function()
            vim.keymap.set("n", "gd", function()
              require("vue-goto-component").goto_definition()
            end, { buffer = args.buf, desc = "Go to definition (Vue)" })
          end, 100)
        end
      end,
    })
  end,
}
