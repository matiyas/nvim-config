return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "vimdoc",
      "javascript",
      "typescript",
      "vue",
      "html",
      "css",
      "json",
      "yaml",
      "markdown",
      "bash",
      "c",
      "cpp",
      "ruby",
      "scss",
      "tsx",
    },
    sync_install = false,
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
    matchup = {
      enable = true,
    },
    endwise = {
      enable = true,
    },
  },
}
