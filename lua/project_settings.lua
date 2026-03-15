-- Настройки проекта в nvim_settings.ini в корне проекта
-- Формат INI: секции [env] и [tree_colors]

local M = {}

local FILENAME = 'nvim_settings.ini'

-- Корень проекта: ищем .git вверх от cwd, иначе cwd
function M.project_root()
  local git = vim.fn.finddir('.git', '.;')
  if git ~= '' then
    return vim.fn.fnamemodify(git, ':p:h:h')
  end
  return vim.fn.getcwd()
end

function M.settings_path()
  return M.project_root() .. '/' .. FILENAME
end

-- Парсит INI → { [section] = { [key] = value } }
local function parse(path)
  local data = {}
  local section = nil
  local f = io.open(path, 'r')
  if not f then return data end
  for line in f:lines() do
    line = line:match('^%s*(.-)%s*$')
    if line:match('^%[.+%]$') then
      section = line:match('^%[(.+)%]$')
      data[section] = data[section] or {}
    elseif section and line ~= '' and not line:match('^[;#]') then
      local k, v = line:match('^([^=]+)=(.*)$')
      if k and v then
        data[section][k:match('^%s*(.-)%s*$')] = v:match('^%s*(.-)%s*$')
      end
    end
  end
  f:close()
  return data
end

-- Сериализует обратно в INI (секции в фиксированном порядке)
local function serialize(data)
  local lines = {}
  local section_order = { 'env', 'tree_colors' }
  local written = {}
  for _, s in ipairs(section_order) do
    if data[s] then
      table.insert(lines, '[' .. s .. ']')
      for k, v in pairs(data[s]) do
        table.insert(lines, k .. '=' .. v)
      end
      table.insert(lines, '')
      written[s] = true
    end
  end
  -- остальные секции
  for s, kv in pairs(data) do
    if not written[s] then
      table.insert(lines, '[' .. s .. ']')
      for k, v in pairs(kv) do
        table.insert(lines, k .. '=' .. v)
      end
      table.insert(lines, '')
    end
  end
  return table.concat(lines, '\n')
end

local function write(path, data)
  local f = io.open(path, 'w')
  if f then
    f:write(serialize(data))
    f:close()
  end
end

-- Приводит абсолютный путь к относительному от корня проекта
local function to_rel(abs_path)
  local root = M.project_root()
  if abs_path:sub(1, #root + 1) == root .. '/' then
    return abs_path:sub(#root + 2)
  end
  return abs_path
end

-- Восстанавливает абсолютный путь из относительного
local function to_abs(rel_path)
  if rel_path:sub(1, 1) == '/' then return rel_path end
  return M.project_root() .. '/' .. rel_path
end

-- Загружает настройки: применяет VIRTUAL_ENV, возвращает { abs_path -> color_key }
function M.load()
  local path = M.settings_path()
  local data = parse(path)

  -- Применяем переменные окружения
  local env = data['env'] or {}
  if env.VIRTUAL_ENV and env.VIRTUAL_ENV ~= '' then
    vim.fn.setenv('VIRTUAL_ENV', env.VIRTUAL_ENV)
    vim.fn.setenv('VIRTUAL_ENV_PYTHON', env.VIRTUAL_ENV .. '/bin/python')
    vim.notify('[project_settings] VIRTUAL_ENV: ' .. env.VIRTUAL_ENV)
  end

  -- Возвращаем цвета дерева { absolute_path -> color_key }
  local colors = {}
  for rel, color_key in pairs(data['tree_colors'] or {}) do
    colors[to_abs(rel)] = color_key
  end
  return colors
end

-- Сохраняет цвет директории
function M.save_color(abs_path, color_key)
  local path = M.settings_path()
  local data = parse(path)
  data['tree_colors'] = data['tree_colors'] or {}
  data['tree_colors'][to_rel(abs_path)] = color_key
  write(path, data)
end

-- Удаляет цвет директории
function M.remove_color(abs_path)
  local path = M.settings_path()
  local data = parse(path)
  if not data['tree_colors'] then return end
  data['tree_colors'][to_rel(abs_path)] = nil
  data['tree_colors'][abs_path] = nil  -- на случай абсолютного пути в файле
  write(path, data)
end

-- Перезагружает при смене рабочей директории
vim.api.nvim_create_autocmd('DirChanged', {
  callback = function()
    M.load()
  end,
})

return M
