-- lazygit — интерактивный git UI в плавающем окне
-- Зависимость: brew install lazygit

-- Открыть lazygit через FloatermNew (надёжнее, чем :LazyGit при вызове из меню)
function LazyGitOpen()
  vim.cmd('FloatermNew --width=0.92 --height=0.92 --title=lazygit --autoclose=1 lazygit')
end

-- Commit & Push: запрашивает сообщение, делает git add -A + commit + push
function LazyGitCommitPush()
  local msg = vim.fn.input('Commit message: ')
  if msg == '' then
    vim.notify('Отменено: сообщение не введено', vim.log.levels.WARN)
    return
  end
  local cmd = string.format(
    'FloatermNew --width=0.7 --height=0.5 --autoclose=0 --title=commit\\ \\&\\ push '
    .. "bash -c 'git add -A && git commit -m %s && git push; echo; read -p \"Готово. Enter для закрытия...\"'",
    vim.fn.shellescape(msg)
  )
  vim.cmd(cmd)
end

vim.keymap.set('n', '<leader>lg', '<cmd>lua LazyGitOpen()<CR>', { noremap = true, silent = true, desc = 'lazygit' })
