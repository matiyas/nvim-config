return {
  "tpope/vim-rails",
  ft = { "ruby", "eruby", "rake" },
  config = function()
    vim.g.rails_projections = {
      ["app/*/*.rb"] = {
        alternate = "spec/{}_spec.rb",
      },
      ["app/*.rb"] = {
        alternate = "spec/{}_spec.rb",
      },
    }
  end,
}
