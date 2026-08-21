local open_path = require('plugins.vimfloaterm.open_path')

-- Горячие клавиши для терминала
vim.api.nvim_set_keymap(
  'n',
  '<C-d>',
  ':FloatermNew --height=0.2 --width=1.00 --wintype=split --position=bottom<CR>',
  { noremap = true, silent = true }
)

-- Функции для кнопок в winbar терминала
function _G.FloatermWinbarKill()
  vim.cmd('FloatermKill')
end

function _G.FloatermWinbarHide()
  vim.cmd('FloatermHide')
end

function _G.FloatermWinbarNew()
  vim.cmd('FloatermNew --height=0.2 --width=1.00 --wintype=split --position=bottom')
end

-- Клик по вкладке терминала — переключиться на него (тот же механизм,
-- что и у FloatermNext/Prev: старое окно прячется, буфер показывается заново).
function _G.FloatermTabClick(bufnr, _, button)
  if button == 'l' and vim.api.nvim_buf_is_valid(bufnr) then
    pcall(vim.fn['floaterm#terminal#open_existing'], bufnr)
  end
end

-- Название вкладки терминала: заданное имя (--name=...), иначе команда/шелл.
local function term_label(bufnr, idx)
  local name = vim.fn['floaterm#config#get'](bufnr, 'name', '')
  if type(name) ~= 'string' or name == '' then
    -- bufname вида term://<cwd>//<pid>:<cmd ...> — берём команду после
    -- последнего двоеточия, её первый токен и хвост пути (/bin/zsh → zsh)
    local bn = vim.api.nvim_buf_get_name(bufnr)
    local cmd = bn:match(':([^:]+)$') or bn
    cmd = cmd:match('^%S+') or cmd
    name = vim.fn.fnamemodify(cmd, ':t')
    if name == '' then
      name = 'term'
    end
  end
  return (' %d·%s '):format(idx, name)
end

-- Динамическое содержимое winbar: кнопки управления + вкладки открытых
-- терминалов. Возвращается формат statusline (кликабельные %@...@, группы
-- %#...#) — winbar-выражение %{%...%} переинтерпретирует его при каждом
-- redraw, поэтому список и подсветка текущей вкладки обновляются сами.
function _G.FloatermWinbar()
  local ok, parts = pcall(function()
    local out = {
      ' %@v:lua.FloatermWinbarKill@ ✕ закрыть %X',
      ' %@v:lua.FloatermWinbarHide@ − скрыть %X',
      ' %@v:lua.FloatermWinbarNew@ + новый %X',
      '  ',
    }
    local list = vim.fn['floaterm#buflist#gather']()
    if type(list) == 'table' then
      local cur = vim.fn.bufnr('%')
      for i, b in ipairs(list) do
        local hl = (b == cur) and '%#FloatermTabSel#' or '%#FloatermTab#'
        out[#out + 1] = ('%s%%%d@v:lua.FloatermTabClick@%s%%X%%#FloatermTab#'):format(hl, b, term_label(b, i))
      end
    end
    return table.concat(out)
  end)
  return ok and parts or ''
end

-- Цвета вкладок терминала (Solarized Light, как у остальной панели)
local function apply_colors()
  vim.api.nvim_set_hl(0, 'FloatermTab', { fg = '#93a1a1' })
  vim.api.nvim_set_hl(0, 'FloatermTabSel', { fg = '#268bd2', bold = true, underline = true })
end

local function set_floaterm_winbar()
  vim.wo.winbar = '%{%v:lua.FloatermWinbar()%}'
end

-- winbar нужно ставить на КАЖДЫЙ заход в окно терминала, а не только при
-- первичном определении filetype: при FloatermHide/Show окно пересоздаётся,
-- а при FloatermNext/Prev в окне подменяется буфер — в обоих случаях
-- событие FileType повторно не срабатывает, и кнопки пропадают.
vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter', 'BufEnter', 'WinEnter' }, {
  pattern = '*',
  callback = function()
    if vim.bo.filetype == 'floaterm' then
      set_floaterm_winbar()
      -- Кликабельные пути в выводе (pytest, трейсбеки): gf / <CR> / двойной клик
      open_path.attach()
      -- Подсветка путей зелёным + подчёркивание
      open_path.highlight()
    end
  end,
})

apply_colors()
vim.api.nvim_create_autocmd('ColorScheme', { callback = apply_colors })
