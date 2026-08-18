-- Активировать vim-airline
vim.g['airline#extensions#tabline#enabled'] = 0        -- Включить табы сверху

-- Показ числа вкладок и буферов
vim.g['airline#extensions#tabline#show_tabs'] = 1      -- Показать вкладки
vim.g['airline#extensions#tabline#show_buffers'] = 1   -- Показать буферы
vim.g['airline#extensions#tabline#show_splits'] = 0    -- Не показывать сплиты
vim.g['airline#extensions#tabline#show_tab_nr'] = 1    -- Показать номер вкладки
vim.g['airline#extensions#tabline#show_close_button'] = 1 -- Показать кнопку закрытия вкладки

-- Использовать powerline шрифты
vim.g.airline_powerline_fonts = 1                      -- Включить шрифты powerline

-- Параметры отображения информации
vim.g['airline#extensions#whitespace#enabled'] = 1     -- Показать пробелы, табы и т.п.
vim.g['airline#extensions#branch#enabled'] = 1         -- Показать информацию о ветке Git
vim.g['airline#extensions#hunks#enabled'] = 1          -- Показать информацию о хлипах Git

-- Цветовая тема Airline
vim.g.airline_theme = 'sol'

-- Укорочение имени буфера - включить
vim.g['airline#extensions#tabline#fnamecollapse'] = 1

-- Не даём airline подменять секции в терминальных буферах,
-- иначе в окне Claude не видно наших секций (память, лимиты)
vim.g['airline#extensions#term#enabled'] = 0

-- vim-devicons загружается после init.vim и перезаписывает g:airline_section_y,
-- затирая наши секции (память, лимиты) — отключаем его вмешательство в statusline
vim.g.webdevicons_enable_airline_statusline = 0

-- Свои секции: память процесса nvim + лимиты Claude (в окне Claude Code)
require('plugins.vimairline.status_extras').setup()

vim.cmd([[
  function! AirlineNvimMem()
    return v:lua.require('plugins.vimairline.status_extras').mem()
  endfunction
  function! AirlineClaudeLimits()
    return v:lua.require('plugins.vimairline.status_extras').claude()
  endfunction
  call airline#parts#define_function('nvim_mem', 'AirlineNvimMem')
  call airline#parts#define_function('claude_limits', 'AirlineClaudeLimits')
  let g:airline_section_y = airline#section#create_right(['claude_limits', 'ffenc', 'nvim_mem'])
]])
