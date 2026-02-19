return {
  {
    "ojroques/nvim-osc52",
    config = function()
      vim.opt.clipboard = "unnamedplus"

      local function copy(lines, _)
        require("osc52").copy(table.concat(lines, "\n"))
      end

      local function paste()
        local content = vim.fn.system("pbpaste")
        return { vim.fn.split(content, "\n"), "c" }
      end

      vim.g.clipboard = {
        name = "osc52",
        copy = { ["+"] = copy, ["*"] = copy },
        paste = { ["+"] = paste, ["*"] = paste },
      }
    end,
  },
}
