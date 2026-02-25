local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
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
        },
        vue_ls = {
          filetypes = { "vue" },
          init_options = {
            typescript = {
              tsdk = mason_packages .. "/vtsls/node_modules/@vtsls/language-server/node_modules/typescript/lib",
            },
          },
        },
      },
    },
  },
}
