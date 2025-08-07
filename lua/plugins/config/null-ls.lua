local null_ls = require("null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local b = null_ls.builtins

local sources = {

  -- webdev stuff
  b.formatting.prettier.with({
    command = "node_modules/.bin/prettier",
    filetypes = { "html", "markdown", "css", "typescript" },
  }),

  -- Lua
  b.formatting.stylua,

  -- cpp
  b.formatting.clang_format,

  -- Ruby
  b.formatting.rubocop.with({
    condition = function(utils)
      return utils.root_has_file({ ".rubocop.yml", ".rubocop.yaml" })
    end,
  }),
}

null_ls.setup({
  debug = true,
  sources = sources,
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({
        group = augroup,
        buffer = bufnr,
      })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({
            bufnr = bufnr,
            timeout_ms = 10000, -- 10 second timeout
            async = false,
          })
        end,
      })
    end
  end,
})
