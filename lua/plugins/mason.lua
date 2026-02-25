return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "vue-language-server",
        "vtsls",
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      automatic_installation = {
        exclude = { "solargraph", "rubocop", "ruby_lsp" },
      },
    },
  },
}
