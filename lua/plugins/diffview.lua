return {
  "sindrets/diffview.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  config = function()
    local lib = require("diffview.lib")
    local utils = require("diffview.utils")

    local pending_refresh = nil

    local function fast_toggle_stage()
      local view = lib.get_current_view()
      if not view then
        return
      end

      local item = view:infer_cur_file(true)
      if not item or type(item.collapsed) == "boolean" then
        require("diffview.actions").toggle_stage_entry()
        return
      end

      local adapter = view.adapter
      local success

      if item.kind == "working" then
        success = adapter:add_files({ item.path })
      elseif item.kind == "staged" then
        success = adapter:reset_files({ item.path })
      else
        require("diffview.actions").toggle_stage_entry()
        return
      end

      if not success then
        utils.err(("Failed to stage/unstage file: '%s'"):format(item.path))
        return
      end

      -- Remove from source list immediately (fast UI feedback)
      local files = view.files
      local source_list = item.kind == "working" and files.working or files.staged

      for i, f in ipairs(source_list) do
        if f.path == item.path then
          -- Destroy entry (disposes buffers)
          f:destroy()
          table.remove(source_list, i)
          break
        end
      end
      -- Quick redraw to show file removed
      files:update_file_trees()
      view.panel:update_components()
      view.panel:render()
      view.panel:redraw()

      -- Schedule async refresh to add file to target list with correct revs
      if pending_refresh then
        pending_refresh:stop()
      end
      pending_refresh = vim.defer_fn(function()
        pending_refresh = nil
        if view and view.panel then
          view:update_files()
        end
      end, 100)
    end

    require("diffview").setup({
      diff_binaries = false,
      enhanced_diff_hl = false,
      git_cmd = { "git" },
      use_icons = true,
      watch_index = false,
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
            fast_toggle_stage,
            { desc = "Stage/unstage entry (optimized)" },
          },
        },
      },
    })
  end,
}
