return {
  "johmsalas/text-case.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("textcase").setup({})
    require("telescope").load_extension("textcase")
  end,
  keys = {
    { "ga", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "v" }, desc = "Telescope Text Case" },
    { "gak", "<cmd>lua require('textcase').current_word('to_kebab_case')<CR>", mode = "n", desc = "To kebab-case" },
    { "gas", "<cmd>lua require('textcase').current_word('to_snake_case')<CR>", mode = "n", desc = "To snake_case" },
    { "gap", "<cmd>lua require('textcase').current_word('to_pascal_case')<CR>", mode = "n", desc = "To PascalCase" },
    { "gac", "<cmd>lua require('textcase').current_word('to_camel_case')<CR>", mode = "n", desc = "To camelCase" },
    { "gau", "<cmd>lua require('textcase').current_word('to_upper_case')<CR>", mode = "n", desc = "To UPPER_CASE" },
    { "gal", "<cmd>lua require('textcase').current_word('to_lower_case')<CR>", mode = "n", desc = "To lower case" },
    { "gat", "<cmd>lua require('textcase').current_word('to_title_case')<CR>", mode = "n", desc = "To Title Case" },
    {
      "gaf",
      "<cmd>lua require('textcase').current_word('to_constant_case')<CR>",
      mode = "n",
      desc = "To CONSTANT_CASE",
    },
    { "gad", "<cmd>lua require('textcase').current_word('to_dot_case')<CR>", mode = "n", desc = "To dot.case" },
    { "gah", "<cmd>lua require('textcase').current_word('to_phrase_case')<CR>", mode = "n", desc = "To phrase case" },
    { "gar", "<cmd>lua require('textcase').current_word('to_path_case')<CR>", mode = "n", desc = "To path/case" },

    { "gak", "<cmd>lua require('textcase').operator('to_kebab_case')<CR>", mode = "v", desc = "To kebab-case" },
    { "gas", "<cmd>lua require('textcase').operator('to_snake_case')<CR>", mode = "v", desc = "To snake_case" },
    { "gap", "<cmd>lua require('textcase').operator('to_pascal_case')<CR>", mode = "v", desc = "To PascalCase" },
    { "gac", "<cmd>lua require('textcase').operator('to_camel_case')<CR>", mode = "v", desc = "To camelCase" },
    { "gau", "<cmd>lua require('textcase').operator('to_upper_case')<CR>", mode = "v", desc = "To UPPER_CASE" },
    { "gal", "<cmd>lua require('textcase').operator('to_lower_case')<CR>", mode = "v", desc = "To lower case" },
    { "gat", "<cmd>lua require('textcase').operator('to_title_case')<CR>", mode = "v", desc = "To Title Case" },
    { "gaf", "<cmd>lua require('textcase').operator('to_constant_case')<CR>", mode = "v", desc = "To CONSTANT_CASE" },
    { "gad", "<cmd>lua require('textcase').operator('to_dot_case')<CR>", mode = "v", desc = "To dot.case" },
    { "gah", "<cmd>lua require('textcase').operator('to_phrase_case')<CR>", mode = "v", desc = "To phrase case" },
    { "gar", "<cmd>lua require('textcase').operator('to_path_case')<CR>", mode = "v", desc = "To path/case" },
  },
}
