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

-- Парсит .env файл → { key = value }
-- Поддерживает: KEY=val, KEY="val", KEY='val', export KEY=val, # комментарии
local function parse_dotenv(path)
  local vars = {}
  local f = io.open(path, 'r')
  if not f then return vars end
  for line in f:lines() do
    line = line:match('^%s*(.-)%s*$')
    if line ~= '' and not line:match('^#') then
      -- снять `export ` в начале
      line = line:gsub('^export%s+', '')
      local k, v = line:match('^([%w_]+)=(.*)$')
      if k and v then
        -- снять кавычки
        v = v:match('^"(.*)"$') or v:match("^'(.*)'$") or v
        vars[k] = v
      end
    end
  end
  f:close()
  return vars
end

-- Собирает все env-переменные из nvim_settings.ini [env] и .env файла
-- Возвращает { key = value }
function M.collect_env()
  local result = {}

  -- .env файл (меньший приоритет)
  local dotenv_path = M.project_root() .. '/.env'
  for k, v in pairs(parse_dotenv(dotenv_path)) do
    result[k] = v
  end

  -- nvim_settings.ini [env] (перезаписывает .env)
  local ini_env = parse(M.settings_path())['env'] or {}
  for k, v in pairs(ini_env) do
    result[k] = v
  end

  return result
end

-- Применяет env-переменные в текущий процесс nvim (наследуются новыми терминалами)
local function apply_env(vars)
  for k, v in pairs(vars) do
    vim.fn.setenv(k, v)
  end
  -- VIRTUAL_ENV_PYTHON — удобный алиас
  if vars.VIRTUAL_ENV then
    vim.fn.setenv('VIRTUAL_ENV_PYTHON', vars.VIRTUAL_ENV .. '/bin/python')
    vim.notify('[project_settings] VIRTUAL_ENV: ' .. vars.VIRTUAL_ENV)
  end
end

-- Загружает настройки: применяет env, возвращает { abs_path -> color_key }
function M.load()
  local vars = M.collect_env()
  apply_env(vars)

  -- Возвращаем цвета дерева { absolute_path -> color_key }
  local colors = {}
  local data = parse(M.settings_path())
  for rel, color_key in pairs(data['tree_colors'] or {}) do
    colors[to_abs(rel)] = color_key
  end
  return colors
end

-- При открытии нового floaterm — экспортируем переменные в его оболочку
vim.api.nvim_create_autocmd('User', {
  pattern = 'FloatermOpen',
  callback = function()
    local vars = M.collect_env()
    if vim.tbl_isempty(vars) then return end
    -- Собираем одну строку с несколькими export и отправляем в терминал
    local exports = {}
    for k, v in pairs(vars) do
      -- Экранируем одинарные кавычки в значении
      local safe_v = v:gsub("'", "'\\''")
      table.insert(exports, string.format("export %s='%s'", k, safe_v))
    end
    vim.cmd('FloatermSend ' .. table.concat(exports, ' && '))
  end,
})

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
