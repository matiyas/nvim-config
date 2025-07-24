return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    "onsails/lspkind-nvim",
  },
  opts = function()
    return {
      formatting = {
        format = function(entry, vim_item)
          local tailwind_format = require("tailwindcss-colorizer-cmp").lspkind_format
          local lspkind_format = require("lspkind").cmp_format({})

          vim_item = tailwind_format(entry, vim_item)
          return lspkind_format(entry, vim_item)
        end,
      },
    }
  end,
}