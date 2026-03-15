local rainbow_delimiters = require('rainbow-delimiters')

vim.g.rainbow_delimiters = {
  strategy = {
    [''] = rainbow_delimiters.strategy['global'],
  },
  query = {
    [''] = 'rainbow-delimiters',
    lua = 'rainbow-blocks',
  },
  highlight = {
    'RainbowDelimiterRed',
    'RainbowDelimiterYellow',
    'RainbowDelimiterBlue',
    'RainbowDelimiterOrange',
    'RainbowDelimiterGreen',
    'RainbowDelimiterViolet',
    'RainbowDelimiterCyan',
  },
}

-- Тёмные цвета под Solarized Light, не пересекаются с синтаксисом и ibl-отступами
-- #859900 green(kw), #d33682 magenta(fn), #2aa198 cyan(str), #b58900 yellow(param),
-- #6c71c4 violet(self), #268bd2 blue(dunder), #657b83 gray(var) — всё занято выше
vim.api.nvim_set_hl(0, 'RainbowDelimiterRed',    { fg = '#9e2a2b' }) -- тёмный кармин
vim.api.nvim_set_hl(0, 'RainbowDelimiterYellow',  { fg = '#7a5000' }) -- тёмная охра
vim.api.nvim_set_hl(0, 'RainbowDelimiterBlue',    { fg = '#1a4a9a' }) -- тёмный кобальт
vim.api.nvim_set_hl(0, 'RainbowDelimiterOrange',  { fg = '#8c3800' }) -- тёмная ржавчина
vim.api.nvim_set_hl(0, 'RainbowDelimiterGreen',   { fg = '#3a6b10' }) -- тёмный лес
vim.api.nvim_set_hl(0, 'RainbowDelimiterViolet',  { fg = '#4a2a8a' }) -- тёмный индиго
vim.api.nvim_set_hl(0, 'RainbowDelimiterCyan',    { fg = '#1a6b5a' }) -- тёмный изумруд
