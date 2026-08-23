-- «Просмотренные» файлы ревью: неизменённые файлы, открытые из ревью
-- (goto definition, :ReviewFile). Показываются отдельной секцией — окном
-- под explorer'ом codediff; <CR> снова открывает файл.
local session = require('plugins.review.session')

local M = {}

M.files = {} -- список relpath в порядке добавления
local buf, win

local function changed_files_set()
  local set = {}
  local st = session.state
  if not st then
    return set
  end
  local args = { 'git', 'diff', '--name-only', st.base_hash }
  if not st.head_is_worktree then
    args[#args + 1] = st.head_hash
  end
  local res = vim.system(args, { cwd = st.git_root, text = true }):wait()
  if res.code == 0 then
    for _, f in ipairs(vim.split(vim.trim(res.stdout or ''), '\n', { trimempty = true })) do
      set[f] = true
    end
  end
  return set
end

local function render()
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    return
  end
  local lines = { ' Просмотренные' }
  for _, f in ipairs(M.files) do
    lines[#lines + 1] = '   ' .. f
  end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_set_height(win, math.min(#M.files + 1, 8))
  end
end

local function open_file(relpath)
  local st = session.state
  local cd = session.codediff_session()
  if not st or not cd then
    return
  end
  local target = cd.modified_win
  if not (target and vim.api.nvim_win_is_valid(target)) then
    return
  end
  vim.api.nvim_set_current_win(target)
  vim.cmd('edit ' .. vim.fn.fnameescape(st.git_root .. '/' .. relpath))
end

local function ensure_window()
  if win and vim.api.nvim_win_is_valid(win) then
    return
  end
  local st = session.state
  if not st or not st.tabpage then
    return
  end
  local ok, lifecycle = pcall(require, 'codediff.ui.lifecycle')
  if not ok then
    return
  end
  local explorer = lifecycle.get_explorer(st.tabpage)
  if not (explorer and explorer.winid and vim.api.nvim_win_is_valid(explorer.winid)) then
    return
  end
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = 'hide'
    vim.bo[buf].buftype = 'nofile'
    vim.api.nvim_buf_set_name(buf, 'review://visited')
    vim.keymap.set('n', '<CR>', function()
      local lnum = vim.api.nvim_win_get_cursor(0)[1]
      local f = M.files[lnum - 1]
      if f then
        open_file(f)
      end
    end, { buffer = buf, nowait = true, desc = 'Открыть просмотренный файл' })
  end
  local prev = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(explorer.winid)
  vim.cmd('belowright split')
  win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'
  vim.wo[win].winfixheight = true
  vim.wo[win].cursorline = true
  if vim.api.nvim_win_is_valid(prev) then
    vim.api.nvim_set_current_win(prev)
  end
end

-- Добавить файл в «просмотренные» (изменённые файлы уже в дереве — пропускаем)
function M.add(relpath)
  if changed_files_set()[relpath] then
    return
  end
  for _, f in ipairs(M.files) do
    if f == relpath then
      return
    end
  end
  M.files[#M.files + 1] = relpath
  ensure_window()
  render()
end

function M.reset()
  M.files = {}
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  win = nil
end

return M
