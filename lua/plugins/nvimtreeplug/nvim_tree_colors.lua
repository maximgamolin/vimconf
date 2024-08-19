local M = {}

M.path_colors = {}

function M.parse_project_dir_colors()
  local env_variable = os.getenv('PROJECT_DIR_COLORS')
  if not env_variable then
    print("PROJECT_DIR_COLORS is not set.")
    return
  end

  for entry in string.gmatch(env_variable, '([^;]+)') do
    local path, color = string.match(entry, '([^:]+):([^:]+)')
    if path and color then
      M.path_colors[path] = color
    end
  end
end

function M.set_colors(node)
  for path, color in pairs(M.path_colors) do
    if node.absolute_path:find(path, 1, true) then
      vim.api.nvim_buf_set_hl(0, -1, 'NvimTreeFolderIcon', { bg = color, fg = '#FFFFFF' })
      vim.api.nvim_buf_set_hl(0, -1, 'NvimTreeFolderName', { bg = color, fg = '#FFFFFF' })
      vim.api.nvim_buf_set_hl(0, -1, 'NvimTreeOpenedFolderName', { bg = color, fg = '#FFFFFF' })
      break
    end
  end
end

function M.colorize_node_tree(node)
  M.set_colors(node)

  if node.type == 'directory' and node.nodes then
    for _, child in pairs(node.nodes) do
      M.colorize_node_tree(child)
    end
  end
end

function M.colorize()
  local view = require('nvim-tree.view')
  local lib = require('nvim-tree.lib')

  -- Если дерево не открыто, ничего не делать
  if not view.win_open() then return end

  local root_node = lib.get_node_at_cursor()

  if root_node then
    M.colorize_node_tree(root_node)
  else
    print('Root node not found')
  end
end

function set_directory_colors()
  M.parse_project_dir_colors()

  -- Подписываемся на события nvim-tree
  local tree_events = require('nvim-tree.api').events

tree_events.subscribe("TreeOpen", function(event)
  M.colorize()
end)

tree_events.subscribe("FolderCreated", function(event)
  M.colorize()
end)

tree_events.subscribe("FileRemoved", function(event)
  M.colorize()
end)

tree_events.subscribe("FileRenamed", function(event)
  M.colorize()
end)
end

set_directory_colors()

return M

