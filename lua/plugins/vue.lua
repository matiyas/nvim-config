return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "vue" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- lspconfig.eslint.setup({
      --   on_attach = function(_, bufnr)
      --     vim.api.nvim_create_autocmd("BufWritePre", {
      --       buffer = bufnr,
      --       command = "EslintFixAll",
      --     })
      --   end,
      --   on_new_config = function(config, new_root_dir)
      --     config.settings.workspaceFolder = {
      --       uri = vim.uri_from_fname(new_root_dir),
      --       name = vim.fn.fnamemodify(new_root_dir, ":t"),
      --     }
      --   end,
      -- })

      -- lspconfig.lua_ls.setup({
      --   capabilities = capabilities,
      -- })

      -- Setup Volar (Vue Language Server)
      lspconfig.volar.setup({
        capabilities = capabilities,
        filetypes = { "vue" },
        init_options = {
          vue = {
            hybridMode = false,
          },
        },
      })

      -- Setup TypeScript server for .ts/.js files (exclude .vue files)
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
      })

      lspconfig.html.setup({
        filetypes = { "html", "ejs" },
        capabilities = capabilities,
      })

      lspconfig.cssls.setup({
        capabilities = capabilities,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)

          vim.keymap.set(
            "n",
            "gd",
            vim.lsp.buf.definition,
            { desc = "Go to definition", buffer = ev.buf }
          )

          vim.keymap.set(
            "n",
            "gD",
            vim.lsp.buf.declaration,
            { desc = "Go to declaration", buffer = ev.buf }
          )

          vim.keymap.set(
            "n",
            "gi",
            vim.lsp.buf.implementation,
            { desc = "Go to implementation", buffer = ev.buf }
          )

          vim.keymap.set(
            "n",
            "gr",
            vim.lsp.buf.references,
            { desc = "Go to references", buffer = ev.buf }
          )

          vim.keymap.set(
            "n",
            "<leader>ca",
            vim.lsp.buf.code_action,
            { desc = "Code actions", buffer = ev.buf }
          )

          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename", buffer = ev.buf })
          vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Display errors" })
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Display symbol info", buffer = ev.buf })
        end,
      })
    end,
  },
}