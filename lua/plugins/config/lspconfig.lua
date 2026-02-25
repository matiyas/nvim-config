local lspconfig = require("lspconfig")

local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
local vtsls_path = mason_packages .. "/vtsls/node_modules/@vtsls/language-server"

-- Configure vtsls for TypeScript/JavaScript (required by vue_ls)
lspconfig.vtsls.setup({
  filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" },
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          {
            name = "@vue/typescript-plugin",
            location = mason_packages .. "/vue-language-server/node_modules/@vue/language-server",
            languages = { "vue" },
            configNamespace = "typescript",
            enableForWorkspaceTypeScriptVersions = true,
          },
        },
      },
    },
  },
})

-- Configure vue_ls (volar) for Vue files
lspconfig.vue_ls.setup({
  filetypes = { "vue" },
  init_options = {
    typescript = {
      tsdk = vtsls_path .. "/node_modules/typescript/lib",
    },
  },
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
