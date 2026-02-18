return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      rubocop = false,
      ruby_lsp = false,
      solargraph = false,
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ruby",
      callback = function()
        local root_dir = vim.fs.root(0, { "Gemfile", ".git", "Rakefile" }) or vim.fn.getcwd()
        local bundle_check = vim.fn.system("cd " .. root_dir .. " && bundle show solargraph 2>/dev/null")

        if vim.v.shell_error ~= 0 or bundle_check == "" then
          return
        end

        vim.lsp.start({
          name = "solargraph",
          cmd = { "bundle", "exec", "solargraph", "stdio" },
          root_dir = root_dir,
          capabilities = vim.lsp.protocol.make_client_capabilities(),
          settings = {
            solargraph = {
              diagnostics = true,
              completion = true,
              definitions = true,
              references = true,
              hover = true,
              useBundler = true,
            },
          },
        })
      end,
    })
  end,
}
