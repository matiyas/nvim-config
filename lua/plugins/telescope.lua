return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    defaults = {
      mappings = {
        i = {
          ["<C-q>"] = require("telescope.actions").send_selected_to_qflist + require("telescope.actions").open_qflist,
          ["<M-q>"] = require("telescope.actions").send_to_qflist + require("telescope.actions").open_qflist,
        },
        n = {
          ["<C-q>"] = require("telescope.actions").send_selected_to_qflist + require("telescope.actions").open_qflist,
          ["<M-q>"] = require("telescope.actions").send_to_qflist + require("telescope.actions").open_qflist,
        },
      },
    },
  },
}
