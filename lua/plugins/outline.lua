return {
  "hedyhli/outline.nvim",
  lazy = true,
  cmd = { "Outline", "OutlineOpen" },
  keys = {
    { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
  },
  opts = {
    symbols = {
      filter = {
        default = { "Function", "Method", "Class", "Module", "Constructor", "Interface", "Struct" },
        vue = { "Function", "Method", "Class", "Component", "Property", "Variable" },
        javascript = { "Function", "Method", "Class", "Constructor", "Property", "Variable" },
        json = { "Object", "Array", "Key", "Property", "Module" },
        ruby = { "Class", "Module", "Method", "Function", "Constant" },
        yaml = { "Key", "Object", "Array", "Property", "Module" },
        html = { "Class", "Method", "Property", "Field" },
        css = { "Class", "Property", "Method" },
        scss = { "Class", "Property", "Method", "Variable" },
        markdown = { "String" },
        xml = { "Class", "Method", "Property", "Field" },
        sh = { "Function", "Variable" },
      },
    },
    providers = {
      markdown = {
        filetypes = { "markdown" },
      },
    },
  },
}
