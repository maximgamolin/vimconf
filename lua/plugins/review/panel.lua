-- Панель и шапка ревью: бейдж «💬 N» у файлов с замечаниями в explorer'е
-- codediff (через официальный API formatters) и winbar с ревизиями сравнения.
local store = require('plugins.review.store')
local session = require('plugins.review.session')

local M = {}

-- Кеш: relpath -> число замечаний (обновляется по ReviewCommentsChanged)
M.counts = {}

function M.refresh_counts()
  M.counts = {}
  if not session.state then
    return
  end
  for path, rf in pairs(store.load_all(session.state.git_root)) do
    M.counts[path] = #rf.comments
  end
end

function M.total()
  local files, total = 0, 0
  for _, n in pairs(M.counts) do
    files = files + 1
    total = total + n
  end
  return files, total
end

-- Обёртка штатного file-formatter'а: справа добавляем бейдж замечаний
local function file_formatter(ctx)
  local layout = require('codediff.ui.explorer.formatters').file(ctx)
  local n = M.counts[ctx.path]
  if n and n > 0 then
    table.insert(layout.right, 1, {
      segments = { { text = '💬' .. n .. ' ', hl = 'ReviewCommentSign' } },
    })
  end
  return layout
end

function M.setup()
  local opts = {}
  -- API formatters появился после v2.52 — при откате codediff на старую
  -- версию просто обходимся без бейджей 💬 в панели
  if pcall(require, 'codediff.ui.explorer.formatters') then
    opts.explorer = { formatters = { file = file_formatter } }
  end
  if vim.o.background ~= 'dark' then
    -- По умолчанию codediff берёт DiffAdd/DiffDelete цветосхемы — у solarized
    -- они резкие (тёмно-синий/яркий красный). Задаём мягкие оттенки в тон
    -- Solarized Light (#fdf6e3): строка — едва заметный тон, изменённые
    -- символы — чуть глубже.
    opts.highlights = {
      line_insert = '#e9eecd', -- мягкий зелёный фон добавленных строк
      line_delete = '#f8ded7', -- мягкий красный фон удалённых строк
      char_insert = '#d5dfa8', -- добавленные символы
      char_delete = '#f3c9be', -- удалённые символы
    }
  end
  require('codediff').setup(opts)
end

-- Перерисовать строки панели (после изменения замечаний)
function M.redraw_explorer()
  if not session.state or not session.state.tabpage then
    return
  end
  local ok, lifecycle = pcall(require, 'codediff.ui.lifecycle')
  if not ok then
    return
  end
  local explorer = lifecycle.get_explorer(session.state.tabpage)
  if explorer then
    pcall(require('codediff.ui.explorer.refresh').rebuild_from_cache, explorer)
  end
end

-- Клики по шапке: левая — сменить базу, правая — сменить голову.
-- Выпадающий список фильтруется набором текста (telescope dropdown).
function _G.ReviewClickBase(_, _, button)
  if button == 'l' then
    require('plugins.review.session').change_base()
  end
end

function _G.ReviewClickHead(_, _, button)
  if button == 'l' then
    require('plugins.review.session').change_head()
  end
end

-- Кнопки «‹ пред / след ›» — навигация по изменениям (как ]c / [c).
-- Клик по winbar не меняет фокус: если курсор не в diff-окне (например,
-- в панели файлов), сначала переходим в правое diff-окно.
local function nav_hunk(dir)
  local cd = session.codediff_session()
  if not cd then
    return
  end
  local cur = vim.api.nvim_get_current_win()
  if cur ~= cd.original_win and cur ~= cd.modified_win then
    if cd.modified_win and vim.api.nvim_win_is_valid(cd.modified_win) then
      vim.api.nvim_set_current_win(cd.modified_win)
    else
      return
    end
  end
  local ok, navigation = pcall(require, 'codediff.ui.view.navigation')
  if ok then
    if dir > 0 then
      navigation.next_hunk()
    else
      navigation.prev_hunk()
    end
  end
end

function _G.ReviewNextHunk(_, _, button)
  if button == 'l' then
    nav_hunk(1)
  end
end

function _G.ReviewPrevHunk(_, _, button)
  if button == 'l' then
    nav_hunk(-1)
  end
end

local function esc(s)
  return (s:gsub('%%', '%%%%'))
end

-- «метка@hash», но если метка сама является префиксом хеша — только hash
local function rev_text(label, hash)
  if hash:sub(1, #label) == label then
    return hash:sub(1, 7)
  end
  return label .. '@' .. hash:sub(1, 7)
end

-- Winbar в diff-окнах: ревизии сравнения (кликабельны — открывают выбор
-- ветки/коммита) и счётчики замечаний
function M.set_winbar()
  local st = session.state
  local cd = session.codediff_session()
  if not st or not cd then
    return
  end
  local files, total = M.total()
  local stats = total > 0 and ('  ·  💬 %d в %d файл(ах)'):format(total, files) or ''
  local nav = '  %@v:lua.ReviewPrevHunk@ ‹ пред %X%@v:lua.ReviewNextHunk@ след › %X'
  local left = ('%%@v:lua.ReviewClickBase@  %s ▾ %%X'):format(esc(rev_text(st.base_label, st.base_hash))) .. nav
  local right = ('%%@v:lua.ReviewClickHead@  %s ▾ %%X%s'):format(esc(rev_text(st.head_label, st.head_hash)), esc(stats)) .. nav
  if cd.original_win and vim.api.nvim_win_is_valid(cd.original_win) then
    vim.wo[cd.original_win].winbar = left
  end
  if cd.modified_win and vim.api.nvim_win_is_valid(cd.modified_win) then
    vim.wo[cd.modified_win].winbar = right
  end
end

return M
