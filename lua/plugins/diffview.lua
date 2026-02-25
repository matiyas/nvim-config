return {
  "sindrets/diffview.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  config = function()
    local lib = require("diffview.lib")
    local utils = require("diffview.utils")

    local function fast_toggle_stage()
      local view = lib.get_current_view()
      if not view then return end

      local item = view:infer_cur_file(true)
      if not item or type(item.collapsed) == "boolean" then
        -- Directory or no item - fall back to default
        require("diffview.actions").toggle_stage_entry()
        return
      end

      local adapter = view.adapter
      local success

      -- Run git add/reset
      if item.kind == "working" then
        success = adapter:add_files({ item.path })
      elseif item.kind == "staged" then
        success = adapter:reset_files({ item.path })
      else
        -- Conflicting files - use default behavior
        require("diffview.actions").toggle_stage_entry()
        return
      end

      if not success then
        utils.err(("Failed to stage/unstage file: '%s'"):format(item.path))
        return
      end

      -- Move file between lists without git queries
      local files = view.files
      local source_list, target_list, new_kind

      if item.kind == "working" then
        source_list = files.working
        target_list = files.staged
        new_kind = "staged"
      else
        source_list = files.staged
        target_list = files.working
        new_kind = "working"
      end

      -- Find and remove from source list
      local idx
      for i, f in ipairs(source_list) do
        if f.path == item.path then
          idx = i
          break
        end
      end

      if idx then
        table.remove(source_list, idx)
      end

      -- Update file entry properties
      item.kind = new_kind

      -- Dispose layout buffers so they reload with correct revs
      for _, f in ipairs(item.layout:files()) do
        if f.dispose_buffer then
          f:dispose_buffer()
        end
      end

      -- Add to target list
      table.insert(target_list, item)

      -- Move cursor to next file
      view.panel:set_cur_file(item)
      view:next_file()

      -- Rebuild trees and redraw panel (fast, no git calls)
      files:update_file_trees()
      view.panel:update_components()
      view.panel:render()
      view.panel:redraw()
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
