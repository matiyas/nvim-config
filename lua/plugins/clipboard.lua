return {
  {
    "ojroques/nvim-osc52",
    config = function()
      vim.opt.clipboard = "unnamedplus"

      local function copy(lines, _)
        require("osc52").copy(table.concat(lines, "\n"))
      end

      local clipboard_file = vim.env.CLIPBOARD_FILE or "/tmp/shared_clipboard.txt"

      local function get_paste_cmd()
        if vim.fn.executable("pbpaste") == 1 then
          return "pbpaste"
        elseif vim.fn.filereadable(clipboard_file) == 1 then
          return "cat " .. clipboard_file
        elseif vim.env.TMUX and vim.fn.executable("tmux") == 1 then
          return "tmux save-buffer -"
        elseif vim.fn.executable("xclip") == 1 then
          return "xclip -selection clipboard -o"
        elseif vim.fn.executable("xsel") == 1 then
          return "xsel --clipboard --output"
        elseif vim.fn.executable("wl-paste") == 1 then
          return "wl-paste --no-newline"
        end
        return nil
      end

      local paste_cmd = get_paste_cmd()

      local function paste()
        if paste_cmd then
          local content = vim.fn.system(paste_cmd)
          return { vim.fn.split(content, "\n"), "c" }
        end
        return { vim.fn.split(vim.fn.getreg("+"), "\n"), vim.fn.getregtype("+") }
      end

      vim.g.clipboard = {
        name = "osc52",
        copy = { ["+"] = copy, ["*"] = copy },
        paste = { ["+"] = paste, ["*"] = paste },
      }
    end,
  },
}
