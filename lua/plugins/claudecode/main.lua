-- claudecode.nvim — интеграция с Claude Code CLI
-- Провайдер 'none': плагин запускает только WebSocket сервер (для синхронизации
-- выделений, файлов и диагностики), терминалы управляются через floaterm.

require('claudecode').setup({
  auto_start = true,
  log_level = 'info',
  track_selection = true,
  terminal = {
    provider = 'none',
  },
})

-- ─── Менеджер вкладок Claude ─────────────────────────────────────────────────

local sessions = {}   -- { name = 'claude_N', title = 'Claude N' }
local current_idx = 0 -- индекс активной сессии (0 = нет)
local counter = 0

local function exists(name)
  return vim.fn['floaterm#terminal#get_bufnr'](name) ~= -1
end

local function cleanup_dead()
  local alive = {}
  for _, s in ipairs(sessions) do
    if exists(s.name) then
      table.insert(alive, s)
    end
  end
  -- Корректируем current_idx
  if current_idx > #alive then current_idx = #alive end
  sessions = alive
end

local function show(idx)
  if idx < 1 or idx > #sessions then return end
  local s = sessions[idx]
  if not exists(s.name) then cleanup_dead(); return end
  current_idx = idx
  vim.cmd('FloatermShow ' .. s.name)
end

local function hide_current()
  if current_idx > 0 and sessions[current_idx] then
    local s = sessions[current_idx]
    if exists(s.name) then
      vim.cmd('FloatermHide ' .. s.name)
    end
  end
end

function ClaudeNewTab()
  counter = counter + 1
  local name  = 'claude_' .. counter
  local title = 'Claude\\ ' .. counter
  hide_current()
  vim.cmd(string.format(
    'FloatermNew --width=0.90 --height=0.90 --title=%s --name=%s claude',
    title, name
  ))
  table.insert(sessions, { name = name })
  current_idx = #sessions
end

function ClaudeToggle()
  cleanup_dead()
  if #sessions == 0 then
    ClaudeNewTab()
    return
  end
  local s = sessions[current_idx > 0 and current_idx or 1]
  vim.cmd('FloatermToggle ' .. s.name)
  current_idx = current_idx > 0 and current_idx or 1
end

function ClaudeNextTab()
  cleanup_dead()
  if #sessions == 0 then ClaudeNewTab(); return end
  hide_current()
  local next_idx = (current_idx % #sessions) + 1
  show(next_idx)
end

function ClaudePrevTab()
  cleanup_dead()
  if #sessions == 0 then ClaudeNewTab(); return end
  hide_current()
  local prev_idx = ((current_idx - 2 + #sessions) % #sessions) + 1
  show(prev_idx)
end

function ClaudeCloseTab()
  cleanup_dead()
  if #sessions == 0 then return end
  local idx = current_idx > 0 and current_idx or 1
  local s = sessions[idx]
  vim.cmd('FloatermKill ' .. s.name)
  table.remove(sessions, idx)
  if #sessions == 0 then
    current_idx = 0
    return
  end
  -- Показываем соседнюю вкладку
  current_idx = math.min(idx, #sessions)
  show(current_idx)
end

-- Хоткей: Alt+` — открыть/скрыть текущую вкладку Claude
vim.keymap.set('n', '<M-`>', '<cmd>lua ClaudeToggle()<CR>',
  { noremap = true, silent = true, desc = 'Claude Code toggle' })
