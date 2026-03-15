-- Горячие клавиши для терминала
vim.api.nvim_set_keymap('n', '<C-d>', ':FloatermNew --height=0.2 --width=1.00 --wintype=split --position=bottom<CR>', { noremap = true, silent = true })

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

function _G.FloatermWinbarNext()
  vim.cmd('FloatermNext')
end

function _G.FloatermWinbarPrev()
  vim.cmd('FloatermPrev')
end

-- Кликабельный winbar над окном терминала
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'floaterm',
  callback = function()
    vim.wo.winbar = ' %@v:lua.FloatermWinbarKill@ ✕ закрыть %X'
      .. '  %@v:lua.FloatermWinbarHide@ − скрыть %X'
      .. '  %@v:lua.FloatermWinbarNew@ + новый %X'
      .. '  %@v:lua.FloatermWinbarPrev@ ◀ %X'
      .. '%@v:lua.FloatermWinbarNext@ ▶ %X'
  end,
})
