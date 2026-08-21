-- PyCharm-style запуск/отладка тестов.
-- Определяет тест-метод и тест-класс под курсором через treesitter и
-- предлагает через quickui-меню 4 действия: запустить/отладить метод или класс.
--   Запуск   — обычный прогон pytest в нижнем floaterm-сплите.
--   Отладка  — nvim-dap-python (test_method / test_class) с UI dap-ui.
local M = {}

-- Имя из поля `name` узла (function_definition / class_definition)
local function node_name(node)
  local name_node = node:field('name')[1]
  if name_node then
    return vim.treesitter.get_node_text(name_node, 0)
  end
end

-- Идём вверх по дереву от курсора: ближайший тест-метод и охватывающий класс
local function find_context()
  local ok, node = pcall(vim.treesitter.get_node)
  if not ok or not node then
    return {}
  end
  local method, class
  while node do
    local t = node:type()
    if t == 'function_definition' and not method then
      local name = node_name(node)
      if name and name:match('^test') then
        method = name
      end
    elseif t == 'class_definition' and not class then
      class = node_name(node)
    end
    node = node:parent()
  end
  return { class = class, method = method }
end

-- Команда pytest под активный venv (VIRTUAL_ENV_PYTHON ставится project_settings)
local function pytest_cmd(nodeid)
  local py = vim.env.VIRTUAL_ENV_PYTHON
  if py and py ~= '' then
    return string.format('%s -m pytest -v %s', py, nodeid)
  end
  return string.format('pytest -v %s', nodeid)
end

-- Прогон в нижнем сплите (как пункт Terminal в меню Run), результат остаётся на экране
local function run_in_term(cmd)
  vim.cmd('FloatermNew --height=0.3 --width=1.00 --wintype=split --position=bottom --autoclose=0 ' .. cmd)
end

-- pytest-nodeid текущего файла (путь от корня проекта)
local function file_id()
  return vim.fn.expand('%:.')
end

-- === Запуск (без отладки) =================================================

function M.run_method()
  local ctx = find_context()
  if not ctx.method then
    vim.notify('Не найден тест-метод под курсором', vim.log.levels.WARN)
    return
  end
  local nodeid = ctx.class and (file_id() .. '::' .. ctx.class .. '::' .. ctx.method)
    or (file_id() .. '::' .. ctx.method)
  run_in_term(pytest_cmd(nodeid))
end

function M.run_class()
  local ctx = find_context()
  if not ctx.class then
    vim.notify('Не найден тест-класс под курсором', vim.log.levels.WARN)
    return
  end
  run_in_term(pytest_cmd(file_id() .. '::' .. ctx.class))
end

-- === Отладка (nvim-dap-python) ============================================

function M.debug_method()
  require('dap-python').test_method()
end

function M.debug_class()
  require('dap-python').test_class()
end

-- === Меню (аналог стрелки в гуттере PyCharm) ==============================

function M.open_menu()
  local ctx = find_context()
  local method_label = ctx.method or '—'
  local class_label = ctx.class or '—'

  local items = {
    { 'Запустить метод:  ' .. method_label, "lua require('plugins.pytest_runner').run_method()" },
    { 'Отладить  метод:  ' .. method_label, "lua require('plugins.pytest_runner').debug_method()" },
    { '--', '' },
    { 'Запустить класс:  ' .. class_label, "lua require('plugins.pytest_runner').run_class()" },
    { 'Отладить  класс:  ' .. class_label, "lua require('plugins.pytest_runner').debug_class()" },
  }

  vim.fn['quickui#context#open'](items, { index = vim.g['quickui#context#cursor'] })
end

return M
