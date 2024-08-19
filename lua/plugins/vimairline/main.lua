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
