-- Дополнительные секции для нижней панели (airline):
-- 1) память nvim и его дочерних процессов (LSP-серверы, терминалы и т.п.)
-- 2) остатки лимитов Claude (сессия/неделя), когда окно Claude Code видно во вкладке
local M = {}

-- ===== Память процесса nvim =====

local mem_str = ''

local function fmt_kb(kb)
  if kb >= 1024 * 1024 then
    return string.format('%.1fG', kb / 1024 / 1024)
  end
  return string.format('%dM', math.floor(kb / 1024 + 0.5))
end

local function poll_mem()
  local self_pid = vim.fn.getpid()
  -- одна выборка всей таблицы процессов: из неё берём RSS самого nvim
  -- и сумму по всему поддереву его потомков (LSP, терминалы и их процессы)
  vim.system({ 'ps', '-Ao', 'pid=,ppid=,rss=' }, { text = true }, function(res)
    local rss = {} -- pid -> rss в КБ
    local children = {} -- ppid -> список pid
    for line in (res.stdout or ''):gmatch('[^\n]+') do
      local pid, ppid, kb = line:match('(%d+)%s+(%d+)%s+(%d+)')
      if pid then
        pid, ppid = tonumber(pid), tonumber(ppid)
        rss[pid] = tonumber(kb)
        children[ppid] = children[ppid] or {}
        table.insert(children[ppid], pid)
      end
    end
    if not rss[self_pid] then
      return
    end
    local kids_kb = 0
    local stack = { self_pid }
    while #stack > 0 do
      local pid = table.remove(stack)
      for _, child in ipairs(children[pid] or {}) do
        kids_kb = kids_kb + (rss[child] or 0)
        table.insert(stack, child)
      end
    end
    local new_str = fmt_kb(rss[self_pid]) .. '/' .. fmt_kb(kids_kb)
    -- перерисовываем панель только при изменении значения — лишние
    -- redrawstatus во время потокового вывода терминала оставляют артефакты
    if new_str ~= mem_str then
      mem_str = new_str
      vim.schedule(function()
        vim.cmd('redrawstatus')
      end)
    end
  end)
end

function M.mem()
  return mem_str
end

-- ===== Лимиты Claude =====

local claude_str = ''

-- Буфер — терминал Claude Code (snacks-терминал из claudecode.nvim)?
local function is_claude_buf(buf)
  if vim.bo[buf].buftype ~= 'terminal' then
    return false
  end
  local name = vim.api.nvim_buf_get_name(buf):lower()
  return name:find('claude', 1, true) ~= nil
end

-- Терминал Claude виден в текущей вкладке (в любом окне, не обязательно активном)?
local function claude_visible()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_claude_buf(vim.api.nvim_win_get_buf(win)) then
      return true
    end
  end
  return false
end

function M.claude()
  if claude_str == '' or not claude_visible() then
    return ''
  end
  return claude_str
end

-- Лимиты берём из самого Claude Code: `echo "/usage" | claude -p --output-format json`
-- (официального API для Pro/Max-лимитов нет, /usage — единственный источник).
-- Ответ содержит строки вида "Current session: 72% used · resets ...".
-- Месячного лимита не существует — только 5-часовая сессия и два недельных.
local poll_running = false
local last_poll = 0

function M.poll_claude()
  if poll_running or vim.fn.executable('claude') == 0 then
    return
  end
  poll_running = true
  last_poll = vim.uv.now()
  vim.system(
    { 'claude', '-p', '--output-format', 'json' },
    { stdin = '/usage', text = true, timeout = 30000 },
    vim.schedule_wrap(function(res)
      poll_running = false
      local ok, decoded = pcall(vim.json.decode, res.stdout or '')
      local text = ok and type(decoded) == 'table' and decoded.result or nil
      if type(text) ~= 'string' then
        return
      end
      local session = tonumber(text:match('Current session: (%d+)%% used'))
      local week = tonumber(text:match('Current week %(all models%): (%d+)%% used'))
      local model, model_pct = text:match('Current week %((%w[%w%s.]-)%): (%d+)%% used')
      if model == 'all models' then
        -- первое совпадение — "all models", ищем модельный лимит дальше
        model, model_pct = text:match('Current week %(all models%).-Current week %((%w[%w%s.]-)%): (%d+)%% used')
      end
      local parts = {}
      if session then table.insert(parts, ('сессия %d%%'):format(100 - session)) end
      if week then table.insert(parts, ('неделя %d%%'):format(100 - week)) end
      if model and model_pct then
        table.insert(parts, ('%s %d%%'):format(model, 100 - tonumber(model_pct)))
      end
      if #parts > 0 then
        claude_str = 'осталось: ' .. table.concat(parts, ' · ')
        vim.cmd('redrawstatus')
      end
    end)
  )
end

-- Обновить лимиты, если данные старее минуты (вызывается при появлении окна Claude)
local function poll_claude_throttled()
  if vim.uv.now() - last_poll > 60000 then
    M.poll_claude()
  end
end

-- ===== Таймеры =====

function M.setup()
  poll_mem()
  local t = vim.uv.new_timer()
  -- память обновляем раз в 5 секунд
  t:start(5000, 5000, vim.schedule_wrap(poll_mem))

  M.poll_claude()
  local t2 = vim.uv.new_timer()
  -- лимиты — раз в 5 минут (каждый опрос запускает claude CLI на ~4 сек)
  t2:start(300000, 300000, vim.schedule_wrap(function()
    M.poll_claude()
  end))

  -- когда терминал Claude виден во вкладке — обновить сразу (не чаще раза в минуту)
  vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufEnter', 'TermEnter', 'TabEnter' }, {
    callback = function()
      if claude_visible() then
        poll_claude_throttled()
      end
    end,
  })
end

return M
