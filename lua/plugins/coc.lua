return {
  "neoclide/coc.nvim",
  branch = "release",
  ft = { "vue" },
  init = function()
    vim.g.coc_node_path = "/home/linuxbrew/.linuxbrew/opt/node@18/bin/node"
  end,
  config = function()
    local coc_filetypes = { vue = true }

    local function setup_coc_keymaps()
      local opts = { silent = true, noremap = true, expr = true, buffer = true }

      vim.keymap.set("i", "<TAB>", [[coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"]], opts)
      vim.keymap.set("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"]], opts)
      vim.keymap.set("i", "<c-space>", "coc#refresh()", { silent = true, expr = true, buffer = true })
      vim.keymap.set("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<CR>"]], opts)

      local nopts = { silent = true, buffer = true }
      vim.keymap.set("n", "gd", "<Plug>(coc-definition)", nopts)
      vim.keymap.set("n", "gr", "<Plug>(coc-references)", nopts)
      vim.keymap.set("n", "gI", "<Plug>(coc-implementation)", nopts)
      vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)", nopts)
      vim.keymap.set("n", "gD", "<Plug>(coc-declaration)", nopts)
      vim.keymap.set("n", "K", function()
        if vim.api.nvim_eval("coc#rpc#ready()") then
          vim.fn.CocActionAsync("doHover")
        end
      end, nopts)
      vim.keymap.set("n", "<leader>ca", "<Plug>(coc-codeaction-cursor)", nopts)
      vim.keymap.set("x", "<leader>ca", "<Plug>(coc-codeaction-selected)", nopts)
      vim.keymap.set("n", "<leader>cr", "<Plug>(coc-rename)", nopts)
      vim.keymap.set("n", "[d", "<Plug>(coc-diagnostic-prev)", nopts)
      vim.keymap.set("n", "]d", "<Plug>(coc-diagnostic-next)", nopts)
      vim.keymap.set("n", "<leader>cf", "<Plug>(coc-format)", nopts)
      vim.keymap.set("x", "<leader>cf", "<Plug>(coc-format-selected)", nopts)
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = vim.tbl_keys(coc_filetypes),
      callback = setup_coc_keymaps,
    })
  end,
}
