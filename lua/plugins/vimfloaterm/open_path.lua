-- Открытие путей из вывода в floaterm-терминале (pytest, трейсбеки и т.п.).
-- Под курсором распознаёт форматы:
--   path.py:352                    → файл на строке 352
--   path.py:352:10                 → файл на строке 352 (колонка игнорируется)
--   path.py::TestClass::test_x     → файл + прыжок на `def test_x`
--   path.py::test_x[param]         → файл + прыжок на `def test_x` (параметры срезаются)
--   path.py                        → просто файл
-- Относительные пути резолвятся от корня проекта, затем от cwd.
local M = {}

local ps = require('project_settings')

-- Окно, куда открыть файл: первое обычное (не терминал, не спец-панель),
-- отличное от текущего. Если такого нет — вернёт nil (откроем новым сплитом).
local function target_win()
  local cur = vim.api.nvim_get_current_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win ~= cur then
      local buf = vim.api.nvim_win_get_buf(win)
      local bt = vim.api.nvim_get_option_value('buftype', { buf = buf })
      local ft = vim.api.nvim_get_option_value('filetype', { buf = buf })
      if bt == '' and ft ~= 'NvimTree' and ft ~= 'tagbar' and ft ~= 'undotree' then
        return win
      end
    end
  end
  return nil
end

-- Приводит путь к читаемому абсолютному: как есть → от корня проекта → от cwd.
local function resolve(path)
  if vim.fn.filereadable(path) == 1 then
    return path
  end
  local candidates = { ps.project_root() .. '/' .. path, vim.fn.getcwd() .. '/' .. path }
  for _, c in ipairs(candidates) do
    if vim.fn.filereadable(c) == 1 then
      return c
    end
  end
  return path
end

-- Открывает файл в подходящем окне и ставит курсор на строку/по поиску.
local function open(file, line, search)
  file = vim.fn.fnamemodify(resolve(file), ':p')
  if vim.fn.filereadable(file) == 0 then
    vim.notify('Файл не найден: ' .. file, vim.log.levels.WARN)
    return
  end

  local win = target_win()
  if win then
    vim.api.nvim_set_current_win(win)
    vim.cmd('edit ' .. vim.fn.fnameescape(file))
  else
    vim.cmd('topleft split ' .. vim.fn.fnameescape(file))
  end

  if line then
    line = math.min(line, vim.api.nvim_buf_line_count(0))
    vim.api.nvim_win_set_cursor(0, { line, 0 })
  elseif search then
    vim.fn.cursor(1, 1)
    vim.fn.search(search, 'cW')
  end
  vim.cmd('normal! zz')
end

-- Разбирает токен под курсором и открывает соответствующий файл.
function M.jump()
  local token = vim.fn.expand('<cWORD>')
  if not token or token == '' then
    return
  end
  -- Снять окружающую пунктуацию/кавычки/скобки.
  token = token:gsub('^["\'(%[]+', '')
  token = token:gsub('["\')%]:,]+$', '')

  -- Путь до расширения (жадный класс включает точки — корректно ловит
  -- абсолютные пути вида .../python3.14/.../routing.py).
  local s, e = token:find('[%w%._/%-]+%.%w+')
  if not s then
    vim.notify('Путь под курсором не найден', vim.log.levels.WARN)
    return
  end
  local path = token:sub(s, e)
  local rest = token:sub(e + 1)

  local line = rest:match('^:(%d+)')
  if line then
    open(path, tonumber(line), nil)
    return
  end

  local node = rest:match('^::(.+)')
  if node then
    -- Последний сегмент после '::' — имя метода/функции (или класса).
    local last = node
    for seg in node:gmatch('[^:]+') do
      last = seg
    end
    last = last:gsub('%[.*$', '') -- убрать [параметры] параметризации
    local escaped = vim.fn.escape(last, '\\/.*$^~[]')
    open(path, nil, '\\v(def|class)\\s+' .. escaped .. '>')
    return
  end

  -- Просто путь (возможно с ':' на конце уже срезанным)
  open(path, nil, nil)
end

-- Вешает буфер-локальные маппинги на текущий floaterm-буфер.
function M.attach()
  if vim.b.floaterm_open_path_attached then
    return
  end
  vim.b.floaterm_open_path_attached = true

  local opts = { buffer = true, silent = true, desc = 'Открыть путь под курсором' }
  vim.keymap.set('n', 'gf', M.jump, opts)
  vim.keymap.set('n', '<CR>', M.jump, opts)
  -- Двойной клик: первый <LeftMouse> уже поставил курсор, второй — открывает.
  vim.keymap.set('n', '<2-LeftMouse>', function()
    M.jump()
  end, opts)
end

-- Regex (vim, very-magic) для кликабельного токена в выводе:
--   путь c расширением + опционально :строка[:колонка] или ::nodeid
local MATCH_PATTERN = '\\v[[:alnum:]_./-]+\\.py(:\\d+(:\\d+)?|::[[:alnum:]_.:[\\]-]+)?'

-- Подсветка путей в текущем окне (зелёный + подчёркивание).
-- matchadd() оконно-локален: при FloatermHide/Show окно пересоздаётся, поэтому
-- вызываем на каждый вход в окно, но не дублируем match в одном окне.
function M.highlight()
  vim.api.nvim_set_hl(0, 'FloatermPath', { fg = '#859900', underline = true, default = true })
  if vim.w.floaterm_path_match then
    return
  end
  vim.w.floaterm_path_match = vim.fn.matchadd('FloatermPath', MATCH_PATTERN, 20)
end

return M
