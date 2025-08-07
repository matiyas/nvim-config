-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>/", function()
  require("telescope").extensions.live_grep_args.live_grep_args()
end, { desc = "Live Grep with args" })

vim.keymap.set("n", "<leader><leader>", function()
  require("telescope.builtin").find_files({
    cwd = vim.fn.getcwd(), -- this makes sure it uses `:pwd` as the root
  })
end, { desc = "[Find] Files from CWD" })

vim.keymap.set("n", "<leader>cp", function()
  vim.fn.setreg("+", vim.fn.expand("%"))
  print("Copied path: " .. vim.fn.expand("%"))
end, { desc = "Copy file relative path" })

vim.keymap.set("n", "<leader>gd", function()
  -- Check if there's already a diffview tab open
  for i, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
      local bufnr = vim.api.nvim_win_get_buf(winid)
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      -- Look for diffview buffers (they typically start with diffview://)
      if bufname:match("^diffview://") or bufname:match("DiffviewFiles") then
        vim.api.nvim_set_current_tabpage(tabpage)
        return
      end
    end
  end
  -- If no diffview found, open a new one
  vim.cmd("DiffviewOpen")
end, { desc = "Open or focus git diff view" })
vim.keymap.set("n", "<leader>gq", ":DiffviewClose<CR>", { desc = "Close git diff view" })
vim.keymap.set("n", "<M-C-n>", "<cmd>Scratch<cr>")
vim.keymap.set("n", "<M-C-o>", "<cmd>ScratchOpen<cr>")

-- Create LspFormat command
vim.api.nvim_create_user_command("LspFormat", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format current buffer with LSP" })

-- Create shortcut for LspFormat
vim.keymap.set("n", "<leader>lf", "<cmd>LspFormat<cr>", { desc = "Format buffer with LSP" })

-- Format JSON with jq
vim.keymap.set("n", "<leader>jq", function()
  local filename = vim.fn.expand("%:t")
  if vim.bo.filetype == "json" or filename:match("%.json$") then
    vim.cmd(":%!jq .")
  else
    print("Not a JSON file")
  end
end, { desc = "Format JSON with jq" })
