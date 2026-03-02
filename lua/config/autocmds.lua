-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Enable BlameLine on startup
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  command = "EnableBlameLine",
})

-- Sync bat theme with nvim colorscheme
local bat_themes = {
  ["tokyonight"] = "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme",
  ["tokyonight-night"] = "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme",
  ["tokyonight-storm"] = "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_storm.tmTheme",
  ["tokyonight-day"] = "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_day.tmTheme",
  ["tokyonight-moon"] = "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_moon.tmTheme",
  ["catppuccin"] = "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme",
  ["catppuccin-mocha"] = "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme",
  ["catppuccin-macchiato"] = "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Macchiato.tmTheme",
  ["catppuccin-frappe"] = "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Frappe.tmTheme",
  ["catppuccin-latte"] = "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Latte.tmTheme",
  ["gruvbox"] = "gruvbox-dark",
  ["onedark"] = "OneHalfDark",
}

local function sync_bat_theme()
  local colorscheme = vim.g.colors_name or "default"
  local theme = bat_themes[colorscheme]
  if not theme then
    return
  end

  local theme_name = colorscheme:gsub("-", "_")
  if theme:match("^https://") then
    local theme_dir = vim.fn.expand("~/.config/bat/themes")
    local theme_file = theme_dir .. "/" .. theme_name .. ".tmTheme"
    if vim.fn.filereadable(theme_file) == 0 then
      vim.fn.mkdir(theme_dir, "p")
      vim.fn.system({ "curl", "-sL", theme, "-o", theme_file })
      vim.fn.system({ "bat", "cache", "--build" })
    end
    vim.env.BAT_THEME = theme_name
  else
    vim.env.BAT_THEME = theme
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = sync_bat_theme,
})

-- Sync on load (autocmds.lua loads after colorscheme is set)
sync_bat_theme()
