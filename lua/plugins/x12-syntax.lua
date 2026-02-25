return {
  "impliedchaos/VIM-X12-Syntax",
  ft = "x12",
  config = function(plugin)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "x12",
      callback = function()
        vim.cmd("source " .. plugin.dir .. "/x12.vim")
      end,
    })
    -- Source immediately if already in x12 buffer
    if vim.bo.filetype == "x12" then
      vim.cmd("source " .. plugin.dir .. "/x12.vim")
    end
  end,
}
