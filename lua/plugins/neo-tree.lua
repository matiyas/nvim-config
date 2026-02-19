return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    opts = function()
      local ignore = require("config.ignore")
      return {
        filesystem = {
          filtered_items = {
            hide_by_name = ignore.neotree_patterns(),
          },
        },
      }
    end,
  },
}
