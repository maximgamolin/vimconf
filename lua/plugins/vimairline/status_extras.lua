-- Дополнительные секции для нижней панели (airline):
-- 1) память основного процесса nvim
-- 2) остатки лимитов Claude (сессия/неделя), когда активно окно Claude Code
local M = {}

-- ===== Память процесса nvim =====

local mem_str = ''

local function poll_mem()
  vim.system({ 'ps', '-o', 'rss=', '-p', tostring(vim.fn.getpid()) }, { text = true }, function(res)
    local rss_kb = tonumber((res.stdout or ''):match('%d+'))
    if rss_kb then
      local new_str
      if rss_kb >= 1024 * 1024 then
        new_str = string.format('%.1fG', rss_kb / 1024 / 1024)
      else
        new_str = string.format('%dM', math.floor(rss_kb / 1024 + 0.5))
      end
      -- перерисовываем панель только при изменении значения — лишние
      -- redrawstatus во время потокового вывода терминала оставляют артефакты
      if new_str ~= mem_str then
        mem_str = new_str
        vim.schedule(function()
          vim.cmd('redrawstatus')
        end)
      end
    end
  end)
end

function M.mem()
  return mem_str
end

-- ===== Лимиты Claude =====

local claude_str = ''

-- Активное окно — терминал Claude Code (snacks-терминал из claudecode.nvim)?
local function in_claude_window()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype ~= 'terminal' then
    return false
  end
  local name = vim.api.nvim_buf_get_name(buf):lower()
  return name:find('claude', 1, true) ~= nil
end

function M.claude()
  if claude_str == '' or not in_claude_window() then
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

-- Обновить лимиты, если данные старее минуты (вызывается при входе в окно Claude)
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

  -- при входе в окно Claude — обновить сразу (не чаще раза в минуту)
  vim.api.nvim_create_autocmd({ 'BufEnter', 'TermEnter' }, {
    callback = function()
      if in_claude_window() then
        poll_claude_throttled()
      end
    end,
  })
end

return M
