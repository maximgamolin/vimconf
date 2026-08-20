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

-- Как collect_env, но дополнительно возвращает источник каждой переменной.
-- Возвращает { vars = { key = value }, source = { key = 'env'|'ini' } }
function M.collect_env_sources()
  local vars, source = {}, {}

  local dotenv_path = M.project_root() .. '/.env'
  for k, v in pairs(parse_dotenv(dotenv_path)) do
    vars[k] = v
    source[k] = 'env'
  end

  local ini_env = parse(M.settings_path())['env'] or {}
  for k, v in pairs(ini_env) do
    vars[k] = v
    source[k] = 'ini'
  end

  return { vars = vars, source = source }
end

-- venv/bin, добавленный в PATH прошлым вызовом apply_env. Нужен, чтобы при
-- повторных вызовах убрать свой прежний префикс и не плодить дубли — при этом
-- НЕ трогая остальной PATH (например, каталог mason с pyright-langserver,
-- который mason.setup() добавляет в начало PATH уже после старта модуля).
local last_venv_bin = nil

-- Убирает ВСЕ вхождения каталога `dir` из PATH (в любой позиции). Нужно,
-- потому что mason добавляет свой bin в начало PATH уже после нашего префикса,
-- и venv/bin перестаёт быть ведущим элементом.
local function strip_path_entry(path, dir)
  if not dir or dir == '' then return path end
  local kept = {}
  for entry in (path .. ':'):gmatch('([^:]*):') do
    if entry ~= '' and entry ~= dir then
      kept[#kept + 1] = entry
    end
  end
  return table.concat(kept, ':')
end

-- Применяет env-переменные в текущий процесс nvim.
-- Новые терминалы (floaterm использует termopen) наследуют это окружение
-- автоматически — ничего печатать в шелл не нужно.
local function apply_env(vars)
  for k, v in pairs(vars) do
    vim.fn.setenv(k, v)
  end

  -- Берём ЖИВОЙ PATH (со всеми правками плагинов, напр. mason) и убираем из
  -- него только тот venv/bin, что добавили сами в прошлый раз.
  local path = vim.fn.getenv('PATH')
  if path == vim.NIL then path = '' end
  path = strip_path_entry(path, last_venv_bin)

  -- Эмуляция `source venv/bin/activate` через окружение, без запуска в шелле:
  --   VIRTUAL_ENV + venv/bin в начало PATH + снять PYTHONHOME
  if vars.VIRTUAL_ENV then
    local bin = vars.VIRTUAL_ENV .. '/bin'
    vim.fn.setenv('PATH', bin .. ':' .. path)
    last_venv_bin = bin
    vim.fn.setenv('PYTHONHOME', vim.NIL)
    vim.fn.setenv('VIRTUAL_ENV_PYTHON', bin .. '/python')
    -- Префикс venv в приглашении (starship/p10k/powerline читают эту переменную)
    vim.fn.setenv('VIRTUAL_ENV_PROMPT', '(' .. vim.fn.fnamemodify(vars.VIRTUAL_ENV, ':t') .. ') ')
    vim.notify('[project_settings] VIRTUAL_ENV: ' .. vars.VIRTUAL_ENV)
  else
    -- venv в проекте нет — оставляем PATH как есть (без нашего префикса)
    vim.fn.setenv('PATH', path)
    last_venv_bin = nil
    vim.fn.setenv('VIRTUAL_ENV_PROMPT', vim.NIL)
  end
end

M.apply_env = function() apply_env(M.collect_env()) end

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

-- Гарантируем, что окружение проекта выставлено в процессе nvim ещё до
-- открытия первого терминала (floaterm наследует его через termopen).
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    apply_env(M.collect_env())
  end,
})
apply_env(M.collect_env())

-- Печатает краткий гайд по окружению проекта в :messages при старте nvim
-- (по аналогии с deps_check — проверкой установленных программ).
function M.print_guide()
  local info = M.collect_env_sources()

  print('═══ Окружение проекта ═══')

  -- venv
  local venv = info.vars.VIRTUAL_ENV
  if venv and vim.fn.isdirectory(venv) == 1 then
    print('venv: ' .. venv .. '  OK')
    print('  python: ' .. venv .. '/bin/python')
    print('  пакеты: pip list   ·   pip freeze')
  else
    print('venv: NOT FOUND')
    print('  создать : python3 -m venv .venv')
    print('  включить: VIRTUAL_ENV=<путь>/.venv в .env или в [env] nvim_settings.ini')
  end

  -- переменные окружения
  local keys = {}
  for k in pairs(info.vars) do keys[#keys + 1] = k end
  table.sort(keys)
  if #keys == 0 then
    print('переменные: нет (добавь в .env или в [env] nvim_settings.ini)')
  else
    print('переменные окружения (' .. #keys .. '):')
    for _, k in ipairs(keys) do
      local v = info.vars[k]
      if #v > 60 then v = v:sub(1, 57) .. '...' end
      local tag = info.source[k] == 'env' and '[.env]' or '[ini]'
      print(string.format('  %-6s %s = %s', tag, k, v))
    end
  end
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
