local M = {}

-- Parse NVIM_IGNORE_DIRS env var (comma-separated list of directories)
-- Example: NVIM_IGNORE_DIRS="node_modules,vendor,.git"
function M.get_ignored_dirs()
  local env = vim.env.NVIM_IGNORE_DIRS or ""
  local dirs = {}
  for dir in string.gmatch(env, "[^,]+") do
    table.insert(dirs, vim.trim(dir))
  end
  return dirs
end

-- Get patterns for telescope file_ignore_patterns
function M.telescope_patterns()
  local patterns = {}
  for _, dir in ipairs(M.get_ignored_dirs()) do
    table.insert(patterns, dir .. "/")
  end
  return patterns
end

-- Get patterns for neo-tree filtered_items
function M.neotree_patterns()
  return M.get_ignored_dirs()
end

return M
