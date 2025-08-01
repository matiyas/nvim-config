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

vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "Open git diff view" })
vim.keymap.set("n", "<leader>gq", ":DiffviewClose<CR>", { desc = "Close git diff view" })
