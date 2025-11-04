return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  keys = function()
    return {
      -- no 'o' here, so 'ds' / 'dS' are free for nvim-surround
      {
        "s",
        mode = { "n", "x" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },

      -- keep these if you want them; they don't clash with ds/dS
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    }
  end,
  config = function(_, opts)
    require("flash").setup(opts)
    -- defensive: remove any operator-pending s/S mappings
    pcall(vim.keymap.del, "o", "s")
    pcall(vim.keymap.del, "o", "S")
  end,
}
