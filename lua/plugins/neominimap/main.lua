-- Карта кода (Isrothy/neominimap.nvim) — как minimap в Sublime Text:
-- справа уменьшенная копия файла из braille-символов, строки раскрашены
-- через treesitter, диагностика LSP подсвечивает строки с ошибками/варнингами,
-- совпадения поиска тоже видны на карте.

-- Конфиг читается плагином при загрузке, поэтому vim.g должен быть выставлен
-- до его plugin/-скриптов (init.vim выполняется раньше — порядок соблюдён)
vim.g.neominimap = {
  auto_enable = true,
  layout = 'float',
  float = {
    minimap_width = 16,
    margin = { right = 0, top = 0, bottom = 0 },
    window_border = 'none',
  },
  exclude_filetypes = { 'help', 'bigfile', 'NvimTree', 'tagbar', 'undotree', 'floaterm' },
  exclude_buftypes = { 'nofile', 'nowrite', 'quickfix', 'terminal', 'prompt' },
  click = { enabled = true }, -- клик по карте переносит курсор в это место
  search = { enabled = true }, -- подсвечивать совпадения поиска
  diagnostic = { enabled = true, mode = 'line' }, -- красить всю строку с ошибкой/варнингом
  git = { enabled = true }, -- заработает, если появится gitsigns.nvim (signify карта не видит)
}

vim.keymap.set('n', '<leader>nm', '<cmd>Neominimap Toggle<CR>', { desc = 'Карта кода: показать/скрыть' })
vim.keymap.set('n', '<leader>nf', '<cmd>Neominimap ToggleFocus<CR>', { desc = 'Карта кода: фокус на карту и обратно' })
