-- Подсветка директорий и файлов в nvim-tree цветным фоном
local M = {}
local api = require('nvim-tree.api')
local ps  = require('project_settings')

local NS = vim.api.nvim_create_namespace('nvimtree_dir_hl')

-- Пастельные цвета (фон, адаптированы под solarized light)
local COLORS = {
  { key = 'purple', label = 'Фиолетовый', hl = 'NvimTreeDirHL_purple', bg = '#e8d8f5' },
  { key = 'green',  label = 'Зелёный',    hl = 'NvimTreeDirHL_green',  bg = '#d5edd5' },
  { key = 'teal',   label = 'Бирюзовый',  hl = 'NvimTreeDirHL_teal',   bg = '#cce8e8' },
  { key = 'orange', label = 'Оранжевый',  hl = 'NvimTreeDirHL_orange', bg = '#f5e6cc' },
  { key = 'pink',   label = 'Розовый',    hl = 'NvimTreeDirHL_pink',   bg = '#f5d5e0' },
}

-- Карта color_key -> hl_group
local KEY_TO_HL = {}
for _, c in ipairs(COLORS) do
  vim.api.nvim_set_hl(0, c.hl, { bg = c.bg })
  KEY_TO_HL[c.key] = c.hl
end

-- { [absolute_path] = hl_group }
local marks = {}

local function find_tree_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'NvimTree' then
      return win, buf
    end
  end
end

local function apply(bufnr, winnr)
  if vim.tbl_isempty(marks) then
    vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)
    return
  end
  if not vim.api.nvim_buf_is_valid(bufnr) then return end

  vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)
  local n = vim.api.nvim_buf_line_count(bufnr)

  vim.api.nvim_buf_call(bufnr, function()
    local saved = vim.api.nvim_win_get_cursor(winnr)
    for ln = 1, n do
      vim.api.nvim_win_set_cursor(winnr, { ln, 0 })
      local node = api.tree.get_node_under_cursor()
      if node and node.absolute_path then
        for path, hl in pairs(marks) do
          local plen = #path
          if node.absolute_path == path
            or node.absolute_path:sub(1, plen + 1) == path .. '/' then
            vim.api.nvim_buf_set_extmark(bufnr, NS, ln - 1, 0, {
              line_hl_group = hl,
              priority = 10,
            })
            break
          end
        end
      end
    end
    vim.api.nvim_win_set_cursor(winnr, saved)
  end)
end

local function apply_current()
  local win, buf = find_tree_win()
  if win then apply(buf, win) end
end

-- Загружает метки из nvim_settings.ini
function M.load_from_settings()
  local colors = ps.load()
  marks = {}
  for abs_path, color_key in pairs(colors) do
    local hl = KEY_TO_HL[color_key]
    if hl then marks[abs_path] = hl end
  end
  apply_current()
end

-- Подписываемся на TreeRendered — срабатывает после каждой перерисовки
api.events.subscribe(api.events.Event.TreeRendered, function(data)
  vim.defer_fn(function()
    apply(data.bufnr, data.winnr)
  end, 10)
end)

-- При открытии дерева — грузим метки (дерево могло открыться до VimEnter-колбека)
api.events.subscribe(api.events.Event.TreeOpen, function()
  vim.defer_fn(M.load_from_settings, 50)
end)

function M.mark(color_key)
  local node = api.tree.get_node_under_cursor()
  if not node or not node.absolute_path then return end

  local hl = KEY_TO_HL[color_key]
  if not hl then return end

  if marks[node.absolute_path] == hl then
    -- повторный выбор того же цвета — снять
    marks[node.absolute_path] = nil
    ps.remove_color(node.absolute_path)
  else
    marks[node.absolute_path] = hl
    ps.save_color(node.absolute_path, color_key)
  end

  apply_current()
end

function M.clear_node()
  local node = api.tree.get_node_under_cursor()
  if not node or not node.absolute_path then return end
  marks[node.absolute_path] = nil
  ps.remove_color(node.absolute_path)
  apply_current()
end

function M.clear_all()
  -- Удаляем из файла каждый помеченный путь
  for abs_path in pairs(marks) do
    ps.remove_color(abs_path)
  end
  marks = {}
  local win, buf = find_tree_win()
  if buf then vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1) end
end

function M.get_colors()
  return COLORS
end

return M
