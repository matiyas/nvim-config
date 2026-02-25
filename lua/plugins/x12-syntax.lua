return {
  "impliedchaos/VIM-X12-Syntax",
  ft = "x12",
  config = function(plugin)
    vim.opt.rtp:append(plugin.dir)
    vim.cmd("source " .. plugin.dir .. "/x12.vim")
  end,
}
