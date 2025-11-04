return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    local nvim_surround = require("nvim-surround")

    nvim_surround.setup({
      keymaps = {
        insert = "<C-g>s",
        insert_line = "<C-g>S",
        normal = "ys",
        normal_cur = "yss",
        normal_line = "yS",
        normal_cur_line = "ySS",
        visual = "S",
        visual_line = "gS",
        delete = "ds",
        change = "cs",
        change_line = "cS",
      },
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ruby",
      callback = function()
        nvim_surround.buffer_setup({
          surrounds = {
            ["b"] = { add = { "begin\n", "\nend" } },
            ["D"] = { add = { "do\n", "\nend" } },
            ["n"] = { add = { "def ", "\nend" } },
            ["C"] = { add = { "class ", "\nend" } },
            ["M"] = { add = { "module ", "\nend" } },
          },
        })
      end,
    })
  end,
}
