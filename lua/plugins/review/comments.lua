-- Замечания в diff-буферах: отображение (signs + virtual lines под строкой,
-- стиль GitLab) и редактирование во float-окне. Каждое изменение сразу
-- пишется в .review/ (см. store.lua).
--
-- Ограничение v1: замечания привязаны к строкам НОВОЙ версии (head), поэтому
-- комментировать можно только правую сторону diff'а. На удалённые строки
-- (есть только слева) — комментарий к соседней строке новой версии.
local store = require('plugins.review.store')
local session = require('plugins.review.session')

local M = {}

local ns = vim.api.nvim_create_namespace('review-comments')

vim.fn.sign_define('ReviewComment', { text = '┃▸', texthl = 'ReviewCommentSign' })

local function setup_highlights()
  vim.api.nvim_set_hl(0, 'ReviewCommentSign', { default = true, link = 'WarningMsg' })
  vim.api.nvim_set_hl(0, 'ReviewCommentText', { default = true, link = 'DiagnosticVirtualTextWarn' })
  vim.api.nvim_set_hl(0, 'ReviewCommentBorder', { default = true, link = 'NonText' })
end
setup_highlights()
vim.api.nvim_create_autocmd('ColorScheme', { callback = setup_highlights })

-- След замечания в буфере: extmark id -> индекс замечания (для edit/delete)
-- b:review_marks = { [extmark_id] = comment_index }

-- Отрисовать замечания файла в буфере (правая сторона diff'а)
function M.render(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  local loc = session.locate(bufnr)
  if not loc or loc.side ~= 'modified' then
    return
  end
  local rf = store.load(session.state.git_root, loc.relpath)
  if not rf then
    vim.b[bufnr].review_marks = nil
    return
  end
  local last = vim.api.nvim_buf_line_count(bufnr)
  local marks = {}
  for idx, c in ipairs(rf.comments) do
    local lnum = math.min(c.line_end, last)
    -- дрейф: цитата больше не совпадает с кодом на этих строках
    local drift = false
    if c.quote and #c.quote > 0 then
      local cur = vim.api.nvim_buf_get_lines(bufnr, c.line_start - 1, c.line_start - 1 + #c.quote, false)
      for i, q in ipairs(c.quote) do
        if cur[i] ~= q then
          drift = true
          break
        end
      end
    end
    local virt = {}
    virt[#virt + 1] = {
      {
        '┌─ 💬 замечание (L' .. c.line_start .. (c.line_end ~= c.line_start and '-' .. c.line_end or '') .. ')'
          .. (drift and '  ⚠ код изменился после ревью' or ''),
        drift and 'ReviewCommentSign' or 'ReviewCommentBorder',
      },
    }
    for line in (c.text .. '\n'):gmatch('(.-)\n') do
      virt[#virt + 1] = { { '│ ', 'ReviewCommentBorder' }, { line, 'ReviewCommentText' } }
    end
    virt[#virt + 1] = { { '└─', 'ReviewCommentBorder' } }
    local id = vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, 0, {
      virt_lines = virt,
      sign_text = '┃▸',
      sign_hl_group = 'ReviewCommentSign',
    })
    marks[id] = idx
  end
  vim.b[bufnr].review_marks = marks
end

function M.render_current()
  local cd = session.codediff_session()
  if cd then
    M.render(cd.modified_bufnr)
  end
end

-- Найти замечание под курсором: индекс в rf.comments или nil
local function comment_at_cursor(bufnr, lnum)
  local marks = vim.b[bufnr].review_marks
  if not marks then
    return nil
  end
  local ems = vim.api.nvim_buf_get_extmarks(bufnr, ns, { lnum - 1, 0 }, { lnum - 1, -1 }, {})
  for _, em in ipairs(ems) do
    if marks[em[1]] then
      return marks[em[1]]
    end
  end
  return nil
end

-- Float-окно ввода текста замечания. callback(text|nil)
local function input_float(title, initial, callback)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = 'markdown'
  vim.bo[buf].bufhidden = 'wipe'
  if initial and initial ~= '' then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(initial, '\n', { plain = true }))
  end
  local width = math.min(80, math.max(50, vim.o.columns - 20))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    row = 1,
    col = 0,
    width = width,
    height = 8,
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. title .. '  [Ctrl+S / ZZ — сохранить, q / Esc — отмена] ',
    title_pos = 'left',
  })
  vim.wo[win].wrap = true
  local done = false
  local function finish(text)
    if done then
      return
    end
    done = true
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    callback(text)
  end
  local function save()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local text = table.concat(lines, '\n'):gsub('%s+$', '')
    if text == '' then
      finish(nil)
    else
      finish(text)
    end
  end
  local o = { buffer = buf, nowait = true }
  vim.keymap.set({ 'n', 'i' }, '<C-s>', function()
    vim.cmd.stopinsert()
    save()
  end, o)
  vim.keymap.set('n', 'ZZ', save, o)
  vim.keymap.set('n', 'q', function()
    finish(nil)
  end, o)
  vim.keymap.set('n', '<Esc>', function()
    finish(nil)
  end, o)
  vim.cmd.startinsert()
end

-- Добавить замечание к строке/диапазону текущего буфера
function M.add(line_start, line_end)
  local bufnr = vim.api.nvim_get_current_buf()
  local loc = session.locate(bufnr)
  if not loc then
    vim.notify('review: это не буфер ревью', vim.log.levels.WARN)
    return
  end
  if loc.side ~= 'modified' then
    vim.notify('review: замечания пишутся к новой версии — правая сторона', vim.log.levels.WARN)
    return
  end
  local st = session.state
  input_float(('%s:%d'):format(loc.relpath, line_start), nil, function(text)
    if not text then
      return
    end
    local rf = store.load(st.git_root, loc.relpath)
      or { file = loc.relpath, base = st.base_hash:sub(1, 12), head = st.head_hash:sub(1, 12), comments = {} }
    local quote = vim.api.nvim_buf_get_lines(bufnr, line_start - 1, line_end, false)
    rf.comments[#rf.comments + 1] = {
      line_start = line_start,
      line_end = line_end,
      quote = quote,
      text = text,
    }
    table.sort(rf.comments, function(a, b)
      return a.line_start < b.line_start
    end)
    store.save(st.git_root, rf)
    M.render(bufnr)
    vim.api.nvim_exec_autocmds('User', { pattern = 'ReviewCommentsChanged' })
  end)
end

-- Редактировать замечание под курсором
function M.edit()
  local bufnr = vim.api.nvim_get_current_buf()
  local loc = session.locate(bufnr)
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local idx = loc and comment_at_cursor(bufnr, lnum)
  if not idx then
    vim.notify('review: под курсором нет замечания', vim.log.levels.WARN)
    return
  end
  local st = session.state
  local rf = store.load(st.git_root, loc.relpath)
  if not rf or not rf.comments[idx] then
    return
  end
  input_float(('%s:%d (правка)'):format(loc.relpath, rf.comments[idx].line_start), rf.comments[idx].text, function(text)
    if not text then
      return
    end
    rf.comments[idx].text = text
    store.save(st.git_root, rf)
    M.render(bufnr)
    vim.api.nvim_exec_autocmds('User', { pattern = 'ReviewCommentsChanged' })
  end)
end

-- Удалить замечание под курсором
function M.delete()
  local bufnr = vim.api.nvim_get_current_buf()
  local loc = session.locate(bufnr)
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local idx = loc and comment_at_cursor(bufnr, lnum)
  if not idx then
    vim.notify('review: под курсором нет замечания', vim.log.levels.WARN)
    return
  end
  local st = session.state
  local rf = store.load(st.git_root, loc.relpath)
  if not rf then
    return
  end
  table.remove(rf.comments, idx)
  store.save(st.git_root, rf)
  M.render(bufnr)
  vim.api.nvim_exec_autocmds('User', { pattern = 'ReviewCommentsChanged' })
end

-- Все замечания ревью в quickfix
function M.list()
  if not session.state then
    vim.notify('review: сессия не открыта', vim.log.levels.WARN)
    return
  end
  local root = session.state.git_root
  local items = {}
  for _, rf in pairs(store.load_all(root)) do
    for _, c in ipairs(rf.comments) do
      items[#items + 1] = {
        filename = root .. '/' .. rf.file,
        lnum = c.line_start,
        text = c.text:gsub('\n', ' '),
      }
    end
  end
  table.sort(items, function(a, b)
    if a.filename ~= b.filename then
      return a.filename < b.filename
    end
    return a.lnum < b.lnum
  end)
  vim.fn.setqflist({}, ' ', { title = 'Замечания ревью', items = items })
  vim.cmd('copen')
end

-- Buffer-local маппинги в diff-буферах ревью
function M.attach(bufnr)
  local o = { buffer = bufnr, nowait = true }
  vim.keymap.set('n', '<leader>rc', function()
    local l = vim.api.nvim_win_get_cursor(0)[1]
    M.add(l, l)
  end, vim.tbl_extend('force', o, { desc = 'Ревью: замечание к строке' }))
  vim.keymap.set('x', '<leader>rc', function()
    local s = vim.fn.line('v')
    local e = vim.fn.line('.')
    if s > e then
      s, e = e, s
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
    M.add(s, e)
  end, vim.tbl_extend('force', o, { desc = 'Ревью: замечание к диапазону' }))
  vim.keymap.set('n', '<leader>re', M.edit, vim.tbl_extend('force', o, { desc = 'Ревью: править замечание' }))
  vim.keymap.set('n', '<leader>rd', M.delete, vim.tbl_extend('force', o, { desc = 'Ревью: удалить замечание' }))
  vim.keymap.set('n', '<leader>rl', M.list, vim.tbl_extend('force', o, { desc = 'Ревью: список замечаний' }))
  vim.keymap.set('n', ']r', function()
    M.jump(1)
  end, vim.tbl_extend('force', o, { desc = 'Ревью: следующее замечание' }))
  vim.keymap.set('n', '[r', function()
    M.jump(-1)
  end, vim.tbl_extend('force', o, { desc = 'Ревью: предыдущее замечание' }))
end

-- Перейти к следующему (dir=1) / предыдущему (dir=-1) замечанию в буфере
function M.jump(dir)
  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local ems = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
  if #ems == 0 then
    vim.notify('review: в этом файле нет замечаний', vim.log.levels.INFO)
    return
  end
  local lines = {}
  for _, em in ipairs(ems) do
    lines[#lines + 1] = em[2] + 1
  end
  table.sort(lines)
  if dir > 0 then
    for _, l in ipairs(lines) do
      if l > lnum then
        vim.api.nvim_win_set_cursor(0, { l, 0 })
        return
      end
    end
    vim.api.nvim_win_set_cursor(0, { lines[1], 0 }) -- по кругу
  else
    for i = #lines, 1, -1 do
      if lines[i] < lnum then
        vim.api.nvim_win_set_cursor(0, { lines[i], 0 })
        return
      end
    end
    vim.api.nvim_win_set_cursor(0, { lines[#lines], 0 })
  end
end

return M
