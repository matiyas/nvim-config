local M = {}

-- Get the namespace path for the current cursor position
function M.get_ruby_namespace()
  local ts_utils = require("nvim-treesitter.ts_utils")
  local parsers = require("nvim-treesitter.parsers")

  -- Check if we're in a Ruby file
  if vim.bo.filetype ~= "ruby" then
    return nil
  end

  -- Check if parser is available
  if not parsers.has_parser("ruby") then
    vim.notify("Ruby parser not available", vim.log.levels.ERROR)
    return nil
  end

  local current_node = ts_utils.get_node_at_cursor()
  if not current_node then
    return nil
  end

  local namespace_parts = {}

  -- Traverse up the tree to find all module and class nodes
  local node = current_node
  while node do
    local node_type = node:type()

    if node_type == "class" or node_type == "module" then
      -- Find the constant/name node
      local name_node = nil
      for child in node:iter_children() do
        if child:type() == "constant" or child:type() == "scope_resolution" then
          name_node = child
          break
        end
      end

      if name_node then
        local name = vim.treesitter.get_node_text(name_node, 0)
        -- If it's a scope_resolution (e.g., A::B), extract just the constant name
        if name_node:type() == "scope_resolution" then
          -- Get the last constant from scope resolution
          for child in name_node:iter_children() do
            if child:type() == "constant" then
              name = vim.treesitter.get_node_text(child, 0)
            end
          end
        end
        table.insert(namespace_parts, 1, name)
      end
    end

    node = node:parent()
  end

  if #namespace_parts == 0 then
    return nil
  end

  return table.concat(namespace_parts, "::")
end

-- Copy the Ruby namespace to clipboard
function M.copy_ruby_namespace()
  local namespace = M.get_ruby_namespace()

  if namespace then
    vim.fn.setreg("+", namespace)
    vim.notify("Copied: " .. namespace, vim.log.levels.INFO)
  else
    vim.notify("No Ruby class or module found at cursor", vim.log.levels.WARN)
  end
end

return M
