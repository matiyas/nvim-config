return {
  'nvim-telescope/telescope.nvim',
  branch = 'master',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = function()
    local ignore = require('config.ignore')
    local actions = require('telescope.actions')
    return {
      defaults = {
        file_ignore_patterns = ignore.telescope_patterns(),
        layout_strategy = 'horizontal',
        layout_config = {
          horizontal = {
            preview_width = 0.6,
            width = 0.9,
            height = 0.9,
          },
        },
        mappings = {
          i = {
            ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
            ['<M-q>'] = actions.send_to_qflist + actions.open_qflist,
          },
          n = {
            ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
            ['<M-q>'] = actions.send_to_qflist + actions.open_qflist,
          },
        },
      },
    }
  end,
}
