-- Локальное ревью в стиле GitLab MR (см. PLAN.md).
-- Команды:
--   :ReviewOpen [база | база...голова | база голова] — открыть ревью
--   :ReviewClose    — закрыть сессию
--   :ReviewComments — все замечания в quickfix
--   :ReviewFile <путь> — открыть любой файл проекта внутри ревью
--   :ReviewPublish  — закоммитить .review/
--   :ReviewDone     — удалить .review/ и закоммитить удаление
local session = require('plugins.review.session')
local panel = require('plugins.review.panel')

-- codediff.setup с нашим formatter'ом панели (pcall: плагин может быть ещё не установлен)
local codediff_ok = pcall(panel.setup)
if not codediff_ok then
  vim.schedule(function()
    vim.notify('review: codediff.nvim не установлен — выполните :PlugInstall', vim.log.levels.WARN)
  end)
end

local function branch_candidates()
  local res = vim.system({ 'git', 'branch', '--all', '--format=%(refname:short)' }, { text = true }):wait()
  if res.code ~= 0 then
    return {}
  end
  return vim.split(vim.trim(res.stdout or ''), '\n', { trimempty = true })
end

local function project_files(arglead)
  local root = session.state and session.state.git_root
  if not root then
    return {}
  end
  local res = vim.system({ 'git', 'ls-files' }, { cwd = root, text = true }):wait()
  if res.code ~= 0 then
    return {}
  end
  local all = vim.split(vim.trim(res.stdout or ''), '\n', { trimempty = true })
  return vim.tbl_filter(function(f)
    return f:find(arglead, 1, true) == 1
  end, all)
end

vim.api.nvim_create_user_command('ReviewOpen', function(opts)
  session.open(opts.fargs)
end, {
  nargs = '*',
  complete = branch_candidates,
  desc = 'Открыть локальное ревью (по умолчанию: ветка от merge-base с main)',
})

vim.api.nvim_create_user_command('ReviewPick', function()
  session.pick()
end, { desc = 'Выбрать ветки/коммиты сравнения и открыть ревью' })

vim.api.nvim_create_user_command('ReviewClose', function()
  session.close()
end, { desc = 'Закрыть сессию ревью' })

vim.api.nvim_create_user_command('ReviewComments', function()
  require('plugins.review.comments').list()
end, { desc = 'Список замечаний ревью (quickfix)' })

vim.api.nvim_create_user_command('ReviewFile', function(opts)
  if not session.state then
    vim.notify('review: сессия не открыта', vim.log.levels.WARN)
    return
  end
  local st = session.state
  local cd = session.codediff_session()
  if cd and cd.modified_win and vim.api.nvim_win_is_valid(cd.modified_win) then
    vim.api.nvim_set_current_win(cd.modified_win)
  end
  vim.cmd('edit ' .. vim.fn.fnameescape(st.git_root .. '/' .. opts.args))
end, {
  nargs = 1,
  complete = project_files,
  desc = 'Открыть файл проекта внутри ревью (попадает в «Просмотренные»)',
})

-- git add .review && git commit
vim.api.nvim_create_user_command('ReviewPublish', function()
  local root = session.state and session.state.git_root or session.git_root()
  if not root then
    return
  end
  local store = require('plugins.review.store')
  local n = vim.tbl_count(store.load_all(root))
  if n == 0 then
    vim.notify('review: нет замечаний для публикации', vim.log.levels.WARN)
    return
  end
  local add = vim.system({ 'git', 'add', store.DIR }, { cwd = root, text = true }):wait()
  if add.code ~= 0 then
    vim.notify('review: git add: ' .. (add.stderr or ''), vim.log.levels.ERROR)
    return
  end
  local msg = ('review: замечания по %d файл(ам)'):format(n)
  local commit = vim.system({ 'git', 'commit', '-m', msg, '--', store.DIR }, { cwd = root, text = true }):wait()
  if commit.code ~= 0 then
    vim.notify('review: git commit: ' .. (commit.stderr or commit.stdout or ''), vim.log.levels.ERROR)
    return
  end
  vim.notify('review: опубликовано — ' .. msg)
end, { desc = 'Закоммитить замечания ревью (.review/)' })

-- Удалить .review/ и закоммитить удаление (сценарий «исправил сам»)
vim.api.nvim_create_user_command('ReviewDone', function()
  local root = session.state and session.state.git_root or session.git_root()
  if not root then
    return
  end
  local store = require('plugins.review.store')
  local rm = vim.system({ 'git', 'rm', '-r', '-q', '--ignore-unmatch', store.DIR }, { cwd = root, text = true }):wait()
  if rm.code ~= 0 then
    vim.notify('review: git rm: ' .. (rm.stderr or ''), vim.log.levels.ERROR)
    return
  end
  vim.fn.delete(store.review_dir(root), 'rf')
  local commit = vim.system({ 'git', 'commit', '-m', 'review: замечания закрыты', '--', store.DIR }, { cwd = root, text = true }):wait()
  if commit.code == 0 then
    vim.notify('review: замечания закрыты и закоммичены')
  else
    vim.notify('review: нечего коммитить (папка .review не была в git?)', vim.log.levels.WARN)
  end
end, { desc = 'Закрыть замечания: удалить .review/ и закоммитить' })

-- Установить slash-команду /fix-review в текущий проект (для Claude Code)
vim.api.nvim_create_user_command('ReviewClaudeSetup', function()
  local root = session.state and session.state.git_root or session.git_root()
  if not root then
    vim.notify('review: не git-репозиторий', vim.log.levels.ERROR)
    return
  end
  local src = vim.fn.expand('~/.config/nvim/lua/plugins/review/fix-review.md')
  local dst_dir = root .. '/.claude/commands'
  vim.fn.mkdir(dst_dir, 'p')
  vim.uv.fs_copyfile(src, dst_dir .. '/fix-review.md')
  vim.notify('review: /fix-review установлена в ' .. dst_dir)
end, { desc = 'Установить команду /fix-review для Claude Code в проект' })

-- ---------------------------------------------------------------------------
-- Отрисовка замечаний, панель, winbar и маппинги при показе файла в ревью.
-- codediff рендерит diff асинхронно, поэтому с задержкой.
local function dbg(msg)
  if vim.g.review_debug then
    print('[review] ' .. msg)
  end
end

-- ПРИМЕЧАНИЕ: codediff откатан на v2.52.4 (пин в init.vim) из-за бага
-- скролл-синка v2.53+ (#518: «призраки» и разъезжающиеся панели при
-- прокрутке; обходы через остановку TreeSitter и redraw! не помогли).
-- Когда #518 закроют — снять пин, вернуть свежую версию.

-- Глобальный smoothscroll ломает отрисовку при синхронном скролле панелей
-- codediff (его филлеры — большие блоки virt_lines, с которыми smoothscroll
-- до сих пор конфликтует: «призраки» и разъехавшиеся строки). Отключаем
-- локально в окнах вкладки ревью.
local function apply_win_tweaks()
  local st = session.state
  if not st or not st.tabpage or not vim.api.nvim_tabpage_is_valid(st.tabpage) then
    return
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(st.tabpage)) do
    if vim.wo[win].smoothscroll then
      vim.wo[win].smoothscroll = false
    end
  end
end

local function refresh()
  if not session.state then
    return
  end
  vim.defer_fn(function()
    local comments = require('plugins.review.comments')
    local cd = session.codediff_session()
    if not cd then
      dbg('refresh: нет codediff-сессии')
      return
    end
    dbg('refresh: render в bufnr=' .. cd.modified_bufnr)
    apply_win_tweaks()
    for _, bufnr in ipairs({ cd.original_bufnr, cd.modified_bufnr }) do
      if bufnr and vim.api.nvim_buf_is_valid(bufnr) and not vim.b[bufnr].review_attached then
        comments.attach(bufnr)
        vim.b[bufnr].review_attached = true
      end
    end
    comments.render(cd.modified_bufnr)
    panel.set_winbar()
  end, 200)
end

vim.api.nvim_create_autocmd('User', {
  pattern = { 'ReviewOpened', 'CodeDiffFileSelect' },
  callback = refresh,
})

-- Перезагрузка буфера (:e, auto-refresh codediff) стирает extmarks замечаний,
-- а смена буфера в окне может обогнать события codediff — перерисовываем.
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWinEnter' }, {
  callback = function()
    local st = session.state
    if not st or not st.tabpage or vim.api.nvim_get_current_tabpage() ~= st.tabpage then
      return
    end
    refresh()
  end,
})

-- Нашу шапку в winbar затирают двое: menu_tabline (ставит вкладки bufferline
-- в файловые окна) и сам codediff (принудительно очищает winbar diff-окон
-- «to prevent alignment issues» на тех же событиях, причём его обработчик
-- регистрируется позже нашего). Поэтому возвращаем шапку через vim.schedule —
-- после всех синхронных обработчиков события.
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter', 'BufEnter', 'FileType' }, {
  callback = function()
    local st = session.state
    if st and st.tabpage and vim.api.nvim_get_current_tabpage() == st.tabpage then
      vim.schedule(panel.set_winbar)
    end
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'ReviewOpened',
  callback = function()
    panel.refresh_counts()
    apply_win_tweaks()
    -- Карта кода (neominimap) во вкладке ревью только шумит поверх diff'а
    if session.state and session.state.tabpage then
      pcall(function()
        require('neominimap.api').tab.disable({ session.state.tabpage })
      end)
    end
    vim.defer_fn(function()
      panel.redraw_explorer()
      panel.set_winbar()
    end, 250)
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'ReviewCommentsChanged',
  callback = function()
    panel.refresh_counts()
    panel.redraw_explorer()
    panel.set_winbar()
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'ReviewClosed',
  callback = function()
    require('plugins.review.visited').reset()
  end,
})

-- Любой обычный файл, показанный в окнах вкладки ревью (goto definition, gf,
-- :ReviewFile), попадает в «Просмотренные», если он не изменён в ревью.
vim.api.nvim_create_autocmd('BufWinEnter', {
  callback = function(ev)
    local st = session.state
    if not st or not st.tabpage or vim.api.nvim_get_current_tabpage() ~= st.tabpage then
      return
    end
    local name = vim.api.nvim_buf_get_name(ev.buf)
    if name == '' or name:match('^codediff://') or name:match('^review://') then
      return
    end
    if vim.bo[ev.buf].buftype ~= '' then
      return
    end
    if name:sub(1, #st.git_root) ~= st.git_root then
      return
    end
    local relpath = name:sub(#st.git_root + 2)
    require('plugins.review.visited').add(relpath)
  end,
})
