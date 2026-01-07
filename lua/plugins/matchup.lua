return {
  "andymass/vim-matchup",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    -- Enable matchup integration with Tree-sitter
    vim.g.matchup_matchparen_offscreen = { method = "popup" }
  end,
  init = function()
    -- Enable matchup for Tree-sitter
    vim.g.matchup_matchparen_enabled = 1
    vim.g.matchup_motion_enabled = 1
    vim.g.matchup_text_obj_enabled = 1
  end,
}
