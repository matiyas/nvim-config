-- Find solargraph executable
local function get_solargraph_cmd()
  -- Try user gem directory first
  local handle = io.popen('ruby -e "puts Gem.user_dir"')
  if handle then
    local gem_dir = handle:read("*a"):gsub("%s+", "")
    handle:close()

    local solargraph_path = gem_dir .. "/bin/solargraph"
    if vim.fn.executable(solargraph_path) == 1 then
      return { solargraph_path, "stdio" }
    end
  end
  -- Fallback to system solargraph
  return { "solargraph", "stdio" }
end

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Disable rubocop LSP to avoid duplicate with solargraph
      rubocop = false,
      solargraph = {
        cmd = get_solargraph_cmd(),
        filetypes = { "ruby" },
        root_dir = require("lspconfig.util").root_pattern("Gemfile", ".git", "Rakefile"),
        flags = {
          debounce_text_changes = 150,
        },
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
