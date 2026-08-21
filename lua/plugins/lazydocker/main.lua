-- lazydocker — интерактивный Docker UI в плавающем окне
-- Зависимость: brew install lazydocker

-- Открыть lazydocker через FloatermNew (по аналогии с lazygit)
function LazyDockerOpen()
  vim.cmd('FloatermNew --width=0.92 --height=0.92 --title=lazydocker --autoclose=1 lazydocker')
end

vim.keymap.set(
  'n',
  '<leader>ld',
  '<cmd>lua LazyDockerOpen()<CR>',
  { noremap = true, silent = true, desc = 'lazydocker' }
)
