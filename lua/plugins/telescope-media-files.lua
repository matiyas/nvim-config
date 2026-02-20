return {
  'nvim-telescope/telescope-media-files.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
  },
  config = function()
    require('telescope').setup({
      extensions = {
        media_files = {
          filetypes = { 'png', 'jpg', 'jpeg', 'gif', 'webp', 'svg', 'ico' },
          find_cmd = 'fd',
        },
      },
    })
    require('telescope').load_extension('media_files')
  end,
}
