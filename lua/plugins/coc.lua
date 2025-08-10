return {
  "neoclide/coc.nvim",
  branch = "release",
  config = function()
    -- CoC keymaps to match LazyVim LSP defaults
    local opts = { silent = true, noremap = true, expr = true }

    -- Use tab for trigger completion with characters ahead and navigate
    vim.keymap.set("i", "<TAB>", [[coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"]], opts)
    vim.keymap.set("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"]], opts)

    -- Use <c-space> to trigger completion
    vim.keymap.set("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })

    -- Use <cr> to confirm completion
    vim.keymap.set("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<CR>"]], opts)

    -- Navigation keymaps matching LazyVim LSP defaults
    vim.keymap.set("n", "gd", "<Plug>(coc-definition)", { silent = true, desc = "Go to definition" })
    vim.keymap.set("n", "gr", "<Plug>(coc-references)", { silent = true, desc = "Show references" })
    vim.keymap.set("n", "gI", "<Plug>(coc-implementation)", { silent = true, desc = "Go to implementation" })
    vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)", { silent = true, desc = "Go to type definition" })
    vim.keymap.set("n", "gD", "<Plug>(coc-declaration)", { silent = true, desc = "Go to declaration" })

    -- Hover and help
    vim.keymap.set("n", "K", function()
      local cw = vim.fn.expand("<cword>")
      if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
        vim.api.nvim_command("h " .. cw)
      elseif vim.api.nvim_eval("coc#rpc#ready()") then
        vim.fn.CocActionAsync("doHover")
      else
        vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
      end
    end, { silent = true, desc = "Hover documentation" })

    -- Code actions and refactoring
    vim.keymap.set("n", "<leader>ca", "<Plug>(coc-codeaction-cursor)", { silent = true, desc = "Code actions" })
    vim.keymap.set("x", "<leader>ca", "<Plug>(coc-codeaction-selected)", { silent = true, desc = "Code actions" })
    vim.keymap.set("n", "<leader>cr", "<Plug>(coc-rename)", { silent = true, desc = "Rename symbol" })

    -- Diagnostics navigation
    vim.keymap.set("n", "[d", "<Plug>(coc-diagnostic-prev)", { silent = true, desc = "Previous diagnostic" })
    vim.keymap.set("n", "]d", "<Plug>(coc-diagnostic-next)", { silent = true, desc = "Next diagnostic" })

    -- Format code
    vim.keymap.set("n", "<leader>cf", "<Plug>(coc-format)", { silent = true, desc = "Format code" })
    vim.keymap.set("x", "<leader>cf", "<Plug>(coc-format-selected)", { silent = true, desc = "Format selected" })

    -- Show all diagnostics
    vim.keymap.set("n", "<leader>cd", ":<C-u>CocList diagnostics<cr>", { silent = true, desc = "Show diagnostics" })

    -- Manage extensions
    vim.keymap.set("n", "<leader>ce", ":<C-u>CocList extensions<cr>", { silent = true, desc = "Manage extensions" })

    -- Show commands
    vim.keymap.set("n", "<leader>cc", ":<C-u>CocList commands<cr>", { silent = true, desc = "Show commands" })

    -- Search workspace symbols
    vim.keymap.set("n", "<leader>cs", ":<C-u>CocList -I symbols<cr>", { silent = true, desc = "Search symbols" })

    -- Outline
    vim.keymap.set("n", "<leader>co", ":<C-u>CocList outline<cr>", { silent = true, desc = "Document outline" })
  end,
}
