-- Подсветка директорий и файлов в nvim-tree цветным фоном
local M = {}
local api = require('nvim-tree.api')

local NS = vim.api.nvim_create_namespace('nvimtree_dir_hl')

-- Пастельные цвета (фон, адаптированы под solarized dark)
local COLORS = {
  { key = 'purple', label = 'Фиолетовый', hl = 'NvimTreeDirHL_purple', bg = '#3d2b4e' },
  { key = 'green',  label = 'Зелёный',    hl = 'NvimTreeDirHL_green',  bg = '#1e3b20' },
  { key = 'teal',   label = 'Бирюзовый',  hl = 'NvimTreeDirHL_teal',   bg = '#1a3535' },
  { key = 'orange', label = 'Оранжевый',  hl = 'NvimTreeDirHL_orange', bg = '#3b2a14' },
  { key = 'pink',   label = 'Розовый',    hl = 'NvimTreeDirHL_pink',   bg = '#3b1e28' },
}

for _, c in ipairs(COLORS) do
  vim.api.nvim_set_hl(0, c.hl, { bg = c.bg })
end

-- { [absolute_path] = hl_group }
local marks = {}

local function apply(bufnr, winnr)
  if vim.tbl_isempty(marks) then return end
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

-- Подписываемся на TreeRendered — срабатывает после каждой перерисовки дерева
api.events.subscribe(api.events.Event.TreeRendered, function(data)
  if not vim.tbl_isempty(marks) then
    vim.defer_fn(function()
      apply(data.bufnr, data.winnr)
    end, 10)
  end
end)

function M.mark(color_key)
  local node = api.tree.get_node_under_cursor()
  if not node or not node.absolute_path then return end

  local hl_group
  for _, c in ipairs(COLORS) do
    if c.key == color_key then
      hl_group = c.hl
      break
    end
  end
  if not hl_group then return end

  -- Повторное нажатие того же цвета — снимает выделение
  if marks[node.absolute_path] == hl_group then
    marks[node.absolute_path] = nil
  else
    marks[node.absolute_path] = hl_group
  end

  -- Найти текущий буфер/окно дерева и сразу применить
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'NvimTree' then
      apply(buf, win)
      return
    end
  end
end

function M.clear_node()
  local node = api.tree.get_node_under_cursor()
  if not node or not node.absolute_path then return end
  marks[node.absolute_path] = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'NvimTree' then
      apply(buf, win)
      return
    end
  end
end

function M.clear_all()
  marks = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'NvimTree' then
      vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1)
      return
    end
  end
end

function M.get_colors()
  return COLORS
end

return M
