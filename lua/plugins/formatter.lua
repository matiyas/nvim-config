return {
  "mhartington/formatter.nvim",
  config = function()
    local formatter = require("formatter")
    local util = require("formatter.util")

    formatter.setup({
      -- Enable logging to help with debugging
      logging = true,
      log_level = vim.log.levels.WARN,

      filetype = {
        -- Lua
        lua = {
          require("formatter.filetypes.lua").stylua,
        },

        -- TypeScript/JavaScript
        typescript = {
          require("formatter.filetypes.typescript").prettier,
        },
        javascript = {
          require("formatter.filetypes.javascript").prettier,
        },

        -- Web
        html = {
          require("formatter.filetypes.html").prettier,
        },
        css = {
          require("formatter.filetypes.css").prettier,
        },
        markdown = {
          require("formatter.filetypes.markdown").prettier,
        },

        -- C/C++
        c = {
          require("formatter.filetypes.c").clangformat,
        },
        cpp = {
          require("formatter.filetypes.cpp").clangformat,
        },

        vue = {},

        -- Ruby with auto-correction
        ruby = {
          function()
            return {
              exe = "rubocop",
              args = {
                "-A", -- Use -A for full auto-correction
                "--stdin",
                util.escape_path(util.get_current_buffer_file_name()),
                "--format",
                "files",
              },
              stdin = true,
              ignore_exitcode = true, -- Don't treat rubocop warnings as errors
              transform = function(text)
                table.remove(text, 1)
                table.remove(text, 1)
                return text
              end,
            }
          end,
        },
      },
    })

    -- Format on save for all configured filetypes
    vim.api.nvim_create_augroup("FormatAutogroup", {})
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = "FormatAutogroup",
      command = "FormatWrite",
    })
  end,
}
