return {
  "mhartington/formatter.nvim",
  config = function()
    local formatter = require("formatter")
    local util = require("formatter.util")

    formatter.setup({
      logging = true,
      log_level = vim.log.levels.WARN,

      filetype = {
        lua = {
          require("formatter.filetypes.lua").stylua,
        },

        html = {
          require("formatter.filetypes.html").prettier,
        },
        css = {
          require("formatter.filetypes.css").prettier,
        },
        markdown = {
          require("formatter.filetypes.markdown").prettier,
        },

        -- Vue: custom formatter (js-beautify for template + prettier for script/style)
        vue = {
          function()
            return {
              exe = "vue-format",
              stdin = true,
            }
          end,
        },

        c = {
          require("formatter.filetypes.c").clangformat,
        },
        cpp = {
          require("formatter.filetypes.cpp").clangformat,
        },

        ruby = {
          function()
            return {
              exe = "rubocop",
              args = {
                "-A",
                "--stdin",
                util.escape_path(util.get_current_buffer_file_name()),
                "--format",
                "files",
              },
              stdin = true,
              ignore_exitcode = true,
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

    -- Format on save
    vim.api.nvim_create_augroup("FormatAutogroup", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = "FormatAutogroup",
      pattern = { "*.lua", "*.html", "*.css", "*.md", "*.c", "*.cpp", "*.rb", "*.vue" },
      command = "FormatWrite",
    })
  end,
}
