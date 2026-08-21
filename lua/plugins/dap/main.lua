-- Отладка: nvim-dap + dap-python + dap-ui, хоткеи, запуск тестов

-- Python для адаптера debugpy: активный venv, иначе системный python3/python.
-- (в системе может не быть команды `python` — тогда адаптер не стартует)
local dap_py = vim.env.VIRTUAL_ENV_PYTHON
if not dap_py or dap_py == '' then
  dap_py = vim.fn.exepath('python3')
  if dap_py == '' then
    dap_py = vim.fn.exepath('python')
  end
end

local dap_python = require('dap-python')
dap_python.setup(dap_py)
dap_python.test_runner = vim.env.PYTESTRUNNER or 'pytest'

-- Автоматически открывать окно UI при запуске дебаггера
local dap, dapui = require('dap'), require('dapui')
dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
-- dap.listeners.before.event_terminated.dapui_config = function()
--   dapui.close()
-- end
-- dap.listeners.before.event_exited.dapui_config = function()
--   dapui.close()
-- end

dapui.setup()

-- Горячие клавиши
local map = function(mode, lhs, rhs)
  vim.keymap.set(mode, lhs, rhs, { silent = true })
end
map('n', '<leader>db', function()
  dap.toggle_breakpoint()
end)
map('n', '<leader>dd', function()
  dap.continue()
end)
map('n', '<leader>dn', function()
  dap_python.test_method()
end)
map('n', '<leader>df', function()
  dap_python.test_class()
end)
map('v', '<leader>ds', function()
  dap_python.debug_selection()
end)

-- Меню запуск/отладка теста под курсором (аналог стрелки в гуттере PyCharm)
map('n', '<leader>tt', function()
  require('plugins.pytest_runner').open_menu()
end)
