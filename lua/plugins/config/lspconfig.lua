local lspconfig = require("lspconfig")

-- Configure vtsls for TypeScript/JavaScript (required by vue_ls)
lspconfig.vtsls.setup({
  filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" },
})

-- Configure vue_ls (volar) for Vue files
lspconfig.vue_ls.setup({
  filetypes = { "vue" },
  on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
})
