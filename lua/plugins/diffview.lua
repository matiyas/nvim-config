return {
  "sindrets/diffview.nvim",
  dependencies = "nvim-lua/plenary.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  config = function()
    local lib = require("diffview.lib")
    local utils = require("diffview.utils")
    local RevType = require("diffview.vcs.rev").RevType
    local Diff2Hor = require("diffview.scene.layouts.diff_2_hor").Diff2Hor
    local FileEntry = require("diffview.scene.file_entry").FileEntry

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
      local was_working = item.kind == "working"

      if was_working then
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

      local files = view.files
      local source_list = was_working and files.working or files.staged
      local target_list = was_working and files.staged or files.working

      -- Find and remove from source list
      local idx
      for i, f in ipairs(source_list) do
        if f.path == item.path then
          idx = i
          break
        end
      end
      if not idx then
        return
      end

      -- Destroy old layout (disposes buffers with old revs)
      item:destroy()
      table.remove(source_list, idx)

      -- Create new file entry with correct revs for target list
      local new_revs, new_kind
      if was_working then
        -- Moving to staged: revs = { a: HEAD, b: STAGE }
        new_kind = "staged"
        local head_rev = adapter:head_rev() or adapter.Rev.new_null_tree()
        new_revs = {
          a = head_rev,
          b = adapter.Rev(RevType.STAGE, 0),
        }
      else
        -- Moving to working: revs = { a: STAGE, b: LOCAL }
        new_kind = "working"
        new_revs = {
          a = view.left,
          b = view.right,
        }
      end

      local new_entry = FileEntry.with_layout(Diff2Hor, {
        adapter = adapter,
        path = item.path,
        oldpath = item.oldpath,
        status = item.status,
        stats = item.stats,
        kind = new_kind,
        revs = new_revs,
      })

      table.insert(target_list, new_entry)

      -- Rebuild trees and redraw (no git calls)
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
