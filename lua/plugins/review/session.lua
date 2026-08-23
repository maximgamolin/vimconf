-- Сессия локального ревью: выбор ревизий, запуск codediff, состояние.
-- Замечания привязываются к head-ревизии (номера строк новой версии).
local M = {}

-- Текущая сессия или nil
-- { git_root, base_arg, base_hash, base_label, head_hash, head_label,
--   head_is_worktree, tabpage }
M.state = nil

local function git(args, cwd)
  local res = vim.system(vim.list_extend({ 'git' }, args), { cwd = cwd, text = true }):wait()
  if res.code ~= 0 then
    return nil, (res.stderr or ''):gsub('%s+$', '')
  end
  return vim.trim(res.stdout or '')
end

function M.git_root()
  return git({ 'rev-parse', '--show-toplevel' }, vim.fn.getcwd())
end

-- Определить основную ветку: origin/HEAD → main → master
local function detect_main(root)
  local sym = git({ 'symbolic-ref', '--short', 'refs/remotes/origin/HEAD' }, root)
  if sym and sym ~= '' then
    return sym:gsub('^origin/', '')
  end
  for _, name in ipairs({ 'main', 'master' }) do
    if git({ 'rev-parse', '--verify', '--quiet', name }, root) then
      return name
    end
  end
  return nil
end

local function short(hash)
  return hash and hash:sub(1, 7) or '?'
end

-- Разобрать аргументы :ReviewOpen в описание сравнения.
-- ''        → main...        (merge-base основной ветки vs рабочее дерево)
-- 'A'       → A...           (merge-base A vs рабочее дерево)
-- 'A...B'   → как есть       (merge-base A/B vs B)
-- 'A B'     → прямая пара A vs B
---@return table|nil, string|nil  {spec, base_arg, head_arg|nil(worktree), merge_base}, err
local function parse_args(fargs, root)
  if #fargs == 0 then
    local main = detect_main(root)
    if not main then
      return nil, 'не нашёл основную ветку (main/master) — укажите базу явно: :ReviewOpen <ветка>'
    end
    return { spec = main .. '...', base_arg = main, head_arg = nil, merge_base = true }
  end
  if #fargs == 1 then
    local a, b = fargs[1]:match('^(.-)%.%.%.(.*)$')
    if a then
      if b == '' then
        return { spec = fargs[1], base_arg = a, head_arg = nil, merge_base = true }
      end
      return { spec = fargs[1], base_arg = a, head_arg = b, merge_base = true }
    end
    return { spec = fargs[1] .. '...', base_arg = fargs[1], head_arg = nil, merge_base = true }
  end
  return { spec = fargs[1] .. ' ' .. fargs[2], base_arg = fargs[1], head_arg = fargs[2], merge_base = false }
end

-- Открыть ревью. fargs — аргументы :ReviewOpen.
function M.open(fargs)
  local root, err = M.git_root()
  if not root then
    vim.notify('review: не git-репозиторий: ' .. (err or ''), vim.log.levels.ERROR)
    return
  end
  local cmp, perr = parse_args(fargs, root)
  if not cmp then
    vim.notify('review: ' .. perr, vim.log.levels.ERROR)
    return
  end
  M.open_cmp(root, cmp)
end

-- Открыть ревью по готовому описанию сравнения (см. parse_args)
function M.open_cmp(root, cmp)
  if M.state then
    vim.notify('review: сессия уже открыта, закройте её (:ReviewClose)', vim.log.levels.WARN)
    return
  end

  local head_arg = cmp.head_arg -- nil = рабочее дерево
  local head_is_worktree = head_arg == nil
  local head_hash = git({ 'rev-parse', head_arg or 'HEAD' }, root)
  if not head_hash then
    vim.notify('review: неизвестная ревизия: ' .. tostring(head_arg), vim.log.levels.ERROR)
    return
  end
  local base_hash
  if cmp.merge_base then
    base_hash = git({ 'merge-base', cmp.base_arg, head_arg or 'HEAD' }, root)
  else
    base_hash = git({ 'rev-parse', cmp.base_arg }, root)
  end
  if not base_hash then
    vim.notify('review: неизвестная ревизия: ' .. cmp.base_arg, vim.log.levels.ERROR)
    return
  end

  local head_label
  if head_is_worktree then
    local branch = git({ 'branch', '--show-current' }, root)
    head_label = (branch ~= '' and branch or short(head_hash)) .. '+wt'
  else
    head_label = cmp.head_label or cmp.head_arg
  end

  M.state = {
    git_root = root,
    base_arg = cmp.base_arg,
    base_hash = base_hash,
    base_label = cmp.base_label or (cmp.base_arg .. (cmp.merge_base and ' (merge-base)' or '')),
    head_hash = head_hash,
    head_label = head_label,
    head_is_worktree = head_is_worktree,
    merge_base = cmp.merge_base,
    tabpage = nil,
  }

  -- Поймать вкладку codediff, когда она откроется
  vim.api.nvim_create_autocmd('User', {
    pattern = 'CodeDiffOpen',
    once = true,
    callback = function(ev)
      if M.state then
        M.state.tabpage = ev.data and ev.data.tabpage or vim.api.nvim_get_current_tabpage()
        vim.api.nvim_exec_autocmds('User', { pattern = 'ReviewOpened' })
      end
    end,
  })
  -- Закрытие вкладки codediff завершает сессию
  vim.api.nvim_create_autocmd('User', {
    pattern = 'CodeDiffClose',
    once = true,
    callback = function()
      M.state = nil
      vim.api.nvim_exec_autocmds('User', { pattern = 'ReviewClosed' })
    end,
  })

  -- Новый codediff (есть argparse): --repo + прячем .review/ из дерева.
  -- Старый (v2.52.x): только spec — репозиторий берётся из cwd.
  if pcall(require, 'codediff.core.argparse') then
    vim.cmd('CodeDiff --repo ' .. vim.fn.fnameescape(root) .. ' ' .. cmp.spec .. ' -- . :^.review')
  else
    vim.cmd('CodeDiff ' .. cmp.spec)
  end
end

function M.close()
  if not M.state then
    return
  end
  local tab = M.state.tabpage
  if tab and vim.api.nvim_tabpage_is_valid(tab) then
    -- codediff сам приберётся по закрытию вкладки (CodeDiffClose)
    local cur = vim.api.nvim_get_current_tabpage()
    if cur == tab and #vim.api.nvim_list_tabpages() == 1 then
      vim.notify('review: последняя вкладка — закройте буферы вручную', vim.log.levels.WARN)
      return
    end
    vim.api.nvim_set_current_tabpage(tab)
    vim.cmd('tabclose')
  else
    M.state = nil
  end
end

-- Данные codediff-сессии текущей вкладки (или nil)
function M.codediff_session()
  if not M.state or not M.state.tabpage then
    return nil
  end
  local ok, cd = pcall(require, 'codediff.ui.lifecycle.session')
  if not ok then
    return nil
  end
  return cd.get_active_diffs()[M.state.tabpage]
end

-- ---------------------------------------------------------------------------
-- Выбор ревизий (:ReviewPick и клики по шапке): выпадающие списки с
-- фильтрацией набором текста (см. pickers.lua). База — ветка → коммит,
-- голова — рабочее дерево / ветка → коммит.

local function pickers()
  return require('plugins.review.pickers')
end

-- Собрать spec для CodeDiff из выбранных точек
local function build_spec(base_arg, head_arg, merge_base)
  if merge_base then
    return base_arg .. '...' .. (head_arg or '')
  end
  return head_arg and (base_arg .. ' ' .. head_arg) or base_arg
end

-- Выбрать голову: рабочее дерево или ветка → коммит. cb(rev|nil), nil = worktree
local function pick_head(root, cb)
  local items = { '⌥ рабочее дерево (текущее состояние файлов)' }
  vim.list_extend(items, pickers().branches(root))
  pickers().select('Голова (что стало):', items, function(choice, idx)
    if idx == 1 then
      cb(nil)
    else
      pickers().commit(root, choice, 'Коммит головы (' .. choice .. '):', cb)
    end
  end)
end

-- Выбрать базу: первый пункт — MR-режим (merge-base с основной веткой),
-- дальше ветка → коммит. cb(base_arg, merge_base)
local function pick_base(root, title, cb)
  local main = detect_main(root)
  local items = {}
  if main then
    items[1] = ('⌥ MR-режим: изменения от merge-base с %s'):format(main)
  end
  vim.list_extend(items, pickers().branches(root))
  pickers().select(title, items, function(choice, idx)
    if main and idx == 1 then
      cb(main, true)
    else
      pickers().commit(root, choice, 'Коммит базы (' .. choice .. '):', function(rev)
        cb(rev, false)
      end)
    end
  end)
end

-- Закрыть текущую сессию (если есть) и открыть новую. Событие CodeDiffClose,
-- обнуляющее state, приходит не мгновенно — ждём его с небольшими повторами.
local function reopen(root, cmp)
  local function try(attempt)
    if M.state then
      if attempt > 20 then
        vim.notify('review: не удалось закрыть предыдущую сессию', vim.log.levels.ERROR)
        return
      end
      vim.defer_fn(function()
        try(attempt + 1)
      end, 50)
      return
    end
    M.open_cmp(root, cmp)
  end
  if M.state then
    M.close()
  end
  vim.schedule(function()
    try(1)
  end)
end

-- Интерактивный выбор сравнения с нуля
function M.pick()
  local root, err = M.git_root()
  if not root then
    vim.notify('review: не git-репозиторий: ' .. (err or ''), vim.log.levels.ERROR)
    return
  end
  pick_base(root, 'База (что было):', function(base_arg, merge)
    pick_head(root, function(head_rev)
      reopen(root, {
        spec = build_spec(base_arg, head_rev, merge),
        base_arg = base_arg,
        head_arg = head_rev,
        merge_base = merge,
      })
    end)
  end)
end

-- Сменить базу открытого ревью (клик по левой шапке), голова сохраняется
function M.change_base()
  local st = M.state
  if not st then
    return
  end
  local root = st.git_root
  local keep_head, keep_head_label -- nil = рабочее дерево
  if not st.head_is_worktree then
    keep_head = st.head_hash:sub(1, 12)
    keep_head_label = st.head_label
  end
  pick_base(root, 'Новая база (что было):', function(base_arg, merge)
    reopen(root, {
      spec = build_spec(base_arg, keep_head, merge),
      base_arg = base_arg,
      head_arg = keep_head,
      head_label = keep_head_label,
      merge_base = merge,
    })
  end)
end

-- Сменить голову открытого ревью (клик по правой шапке), база сохраняется
function M.change_head()
  local st = M.state
  if not st then
    return
  end
  local root = st.git_root
  -- в MR-режиме база — имя ветки (merge-base пересчитается под новую голову),
  -- иначе — зафиксированный коммит
  local keep_base = st.merge_base and st.base_arg or st.base_hash:sub(1, 12)
  local keep_base_label -- в MR-режиме метка строится заново (merge-base пересчитывается)
  if not st.merge_base then
    keep_base_label = st.base_label
  end
  pick_head(root, function(head_rev)
    reopen(root, {
      spec = build_spec(keep_base, head_rev, st.merge_base),
      base_arg = keep_base,
      head_arg = head_rev,
      base_label = keep_base_label,
      merge_base = st.merge_base,
    })
  end)
end

-- По буферу определить место в ревью: путь файла (отн. корня), сторона, реальный ли буфер.
---@return {relpath: string, side: '"original"'|'"modified"', is_real: boolean}|nil
function M.locate(bufnr)
  local cd = M.codediff_session()
  if not cd then
    return nil
  end
  local side
  if bufnr == cd.original_bufnr then
    side = 'original'
  elseif bufnr == cd.modified_bufnr then
    side = 'modified'
  else
    return nil
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  local relpath
  if name:match('^codediff://') then
    local ok, vf = pcall(require, 'codediff.core.virtual_file')
    if ok then
      local _, _, p = vf.parse_url(name)
      relpath = p
    end
  else
    relpath = name
  end
  if not relpath then
    return nil
  end
  -- нормализовать в путь относительно корня репозитория
  local root = M.state.git_root
  if relpath:sub(1, #root) == root then
    relpath = relpath:sub(#root + 2)
  end
  local rev = side == 'original' and cd.original_revision or cd.modified_revision
  return { relpath = relpath, side = side, is_real = rev == nil or rev == 'WORKING' }
end

return M
