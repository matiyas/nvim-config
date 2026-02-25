return {
  "sindrets/diffview.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  config = function()
    local debounce_timer = nil
    local debounce_delay = 200 -- milliseconds

    local function debounced_stage(callback)
      if debounce_timer then
        debounce_timer:stop()
      end
      debounce_timer = vim.defer_fn(function()
        debounce_timer = nil
        callback()
      end, debounce_delay)
    end

    local actions = require("diffview.actions")

    require("diffview").setup({
      diff_binaries = false,
      enhanced_diff_hl = true,
      git_cmd = { "git" },
      use_icons = true,
      view = {
        merge_tool = {
          layout = "diff3_mixed",
        },
      },
      keymaps = {
        file_panel = {
          {
            "n",
            "s",
            function()
              debounced_stage(actions.toggle_stage_entry)
            end,
            { desc = "Stage/unstage the selected entry (debounced)" },
          },
        },
      },
    })
  end,
}
