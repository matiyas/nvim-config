local lspconfig = require("lspconfig")

-- Configure volar for vue files
lspconfig.volar.setup({
  filetypes = { "vue", "typescript", "javascript", "typescriptreact", "javascriptreact" },

  -- optionally, override settings here
  -- settings = { ... },

  -- enable formatting
  on_attach = function(client, bufnr)
    -- Enable formatting capability only for volar server
    if client.server_capabilities.documentFormattingProvider then
      -- Format on save example:
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
})
