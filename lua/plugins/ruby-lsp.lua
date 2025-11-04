return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Disable rubocop LSP to avoid duplicate with solargraph
      rubocop = false,
      solargraph = {
        cmd = { "solargraph", "stdio" },
        filetypes = { "ruby" },
        root_dir = require("lspconfig.util").root_pattern("Gemfile", ".git", "Rakefile"),
        settings = {
          solargraph = {
            diagnostics = true,
            completion = true,
            hover = true,
            formatting = true,
            symbols = true,
            definitions = true,
            rename = true,
            references = true,
            folding = true,
          },
        },
        on_attach = function(client, bufnr)
          -- Increase timeout for Ruby files
          vim.lsp.buf_request_sync(bufnr, "initialize", {}, 10000)
        end,
      },
    },
  },
}
