return {
  "matiyas/vue2-lsp-pathfinder.nvim",
  ft = { "vue" },
  opts = {},
  config = function()
    require("vue2-lsp-pathfinder").setup()

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        if vim.bo[args.buf].filetype == "vue" then
          -- Defer to run after LazyVim sets up its keymaps
          vim.defer_fn(function()
            vim.keymap.set("n", "gd", function()
              require("vue2-lsp-pathfinder").goto_definition()
            end, { buffer = args.buf, desc = "Go to definition (Vue)" })
          end, 100)
        end
      end,
    })
  end,
}
