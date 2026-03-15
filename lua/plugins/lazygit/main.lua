-- lazygit — интерактивный git UI в плавающем окне
-- Зависимость: brew install lazygit

require('lazygit').setup({
  config_file_path = {},
  floating_window_winblend = 0,
  floating_window_scaling_factor = 0.9,
  floating_window_corner_chars = { '╭', '╮', '╰', '╯' },
  floating_window_use_plenary = 0,
  use_neovim_remote = 1,
})

-- Открыть lazygit
vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<CR>', { noremap = true, silent = true, desc = 'lazygit' })

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
