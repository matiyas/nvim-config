return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {},
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(server)
        return not vim.tbl_contains({ "solargraph", "rubocop", "ruby_lsp" }, server)
      end, opts.ensure_installed or {})
      opts.automatic_installation = {
        exclude = { "solargraph", "rubocop", "ruby_lsp" },
      }
    end,
  },
}
