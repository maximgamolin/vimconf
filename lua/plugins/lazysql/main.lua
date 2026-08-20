-- lazysql — интерактивный SQL-клиент в плавающем окне
-- Зависимость: brew install jorgerojas26/lazysql/lazysql

-- Открыть lazysql через FloatermNew (по аналогии с lazydocker)
function LazySqlOpen()
  vim.cmd('FloatermNew --width=0.92 --height=0.92 --title=lazysql --autoclose=1 lazysql')
end

vim.keymap.set('n', '<leader>ls', '<cmd>lua LazySqlOpen()<CR>', { noremap = true, silent = true, desc = 'lazysql' })
