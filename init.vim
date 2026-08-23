" Установить ctags, fzf, fd, ripgrep
" Для python установить debugpy
" Структура конфига:
"   vim/settings/   — опции, общие хоткеи, цвета
"   vim/plugins/    — конфиги плагинов на vimscript (меню)
"   vim/functions/  — вспомогательные функции (git)
"   lua/plugins/    — конфиги плагинов на lua (по папке на плагин)
"   lua/style/      — цвета treesitter и отступов
call plug#begin()
"Цветовая схема
Plug 'maxmx03/solarized.nvim'
"Полоска снизу
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Карта кода справа (как minimap в Sublime Text): раскраска treesitter, ошибки LSP, поиск
Plug 'Isrothy/neominimap.nvim'
"Цветные отступы
Plug 'lukas-reineke/indent-blankline.nvim'
"Терминал
Plug 'voldikss/vim-floaterm'
"Меню
Plug 'skywind3000/vim-quickui'
"Подствека синтаксиса
Plug 'nvim-treesitter/nvim-treesitter', {'branch': 'main', 'do': ':TSUpdate'}
"Смотреть в коде какой элемент за что отвечает — встроенные :InspectTree и :Inspect
"(плагин playground архивирован, refactor заменён LSP-командами grr/gnd)
"Телескоп для поиска
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'branch': 'master' } " master: previewer использует нативный vim.treesitter, совместим с nvim-treesitter веткой main
Plug 'nvim-telescope/telescope-fzy-native.nvim' " Тоже для телескопа, но чтобы работал поиск по коммитам
"Локальная история изменения файлов
Plug 'mbbill/undotree'
"Бар сбоку с классами и функциями
Plug 'preservim/tagbar'
" vim-fugitive для работы с Git
Plug 'tpope/vim-fugitive'
" gitsigns: значки изменений у номеров строк, inline-blame, работа с кусками (hunks),
" плюс источник git-подсветки для карты кода (neominimap)
Plug 'lewis6991/gitsigns.nvim'
" vim-merginal для работы с деревом Git
Plug 'idanarye/vim-merginal'
" lazygit — интерактивный UI для git (требует: brew install lazygit)
Plug 'kdheepak/lazygit.nvim'
" Claude Code интеграция (требует: claude CLI)
Plug 'folke/snacks.nvim'
Plug 'coder/claudecode.nvim'
" LSP, DAP, Linters protocol manager
Plug 'williamboman/mason.nvim'
" LSP
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
" Автодополнение
Plug 'hrsh7th/nvim-cmp'         " Основной плагин для автодополнения
Plug 'hrsh7th/cmp-nvim-lsp'     " Источник LSP для nvim-cmp
Plug 'hrsh7th/cmp-buffer'       " Источник буфера для nvim-cmp
Plug 'hrsh7th/cmp-path'         " Источник путей для nvim-cmp
Plug 'tzachar/cmp-ai'           " Дополнений от нейронки
Plug 'saadparwaiz1/cmp_luasnip' " Источник для snippets
Plug 'L3MON4D3/LuaSnip'         " Плагин для snippets
Plug 'ray-x/lsp_signature.nvim' " Автодополнение сигнатуры методов
" DAP
Plug 'mfussenegger/nvim-dap'
Plug 'nvim-neotest/nvim-nio'
Plug 'rcarriga/nvim-dap-ui'
Plug 'mfussenegger/nvim-dap-python'
" Шрифты
Plug 'onsails/lspkind.nvim'
Plug 'ryanoasis/vim-devicons' " Дев иконки везде
" Комментировать участки кода
Plug 'preservim/nerdcommenter'
" Закрывать парные скобки
Plug 'windwp/nvim-autopairs'
" Радужные скобки
Plug 'HiPhish/rainbow-delimiters.nvim'
" Подсветка одинаковых переменных одним цветом — теперь локальный модуль
" lua/plugins/markid (плагин David-Kunz/markid зависел от старого фреймворка
" nvim-treesitter и с веткой main не работает)
" Вкладки сверху
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
" Дерево файлов
Plug 'nvim-tree/nvim-web-devicons' " Иконки файлов по расширению для nvim-tree
Plug 'nvim-tree/nvim-tree.lua'
" Закладки в коде
Plug 'MattesGroeger/vim-bookmarks'
" Рендер markdown прямо в буфере
Plug 'MeanderingProgrammer/render-markdown.nvim'
" Картинки в терминале по kitty graphics protocol (требует: brew install imagemagick)
Plug '3rd/image.nvim'
" PlantUML/Mermaid диаграммы картинками в markdown (требует: brew install plantuml)
Plug '3rd/diagram.nvim'
call plug#end()

" Опции, общие хоткеи, цветовая схема
source ~/.config/nvim/vim/settings/keymaps.vim
source ~/.config/nvim/vim/settings/options.vim
source ~/.config/nvim/vim/settings/colors.vim

" Стили которые должны идти до
lua require('style.main')
" Шпаргалка по хоткеям (:Hlp)
lua require('h')
" Загружаем настройки проекта (VIRTUAL_ENV, цвета дерева) из nvim_settings.ini
lua require('project_settings').load()

" Конфиги плагинов
lua require('plugins.nvimtreeplug.main')
lua require('plugins.vimbookmarks.main')
lua require('plugins.vimairline.main')
lua require('plugins.gitsigns.main')
lua require('plugins.vimfloaterm.main')
lua require('plugins.ibl.main')
lua require('plugins.nvimtreesitter.main')
lua require('plugins.rainbow.main')
lua require('plugins.markid.main')
lua require('plugins.lazygit.main')
lua require('plugins.lazydocker.main')
lua require('plugins.lazysql.main')
lua require('plugins.claudecode.main')
lua require('plugins.rendermarkdown.main')
lua require('plugins.diagram.main')
" После полной загрузки — подгружаем цвета дерева из nvim_settings.ini
lua vim.api.nvim_create_autocmd('VimEnter', { once = true, callback = function() require('plugins.nvimtreeplug.dir_highlight').load_from_settings() end })

source ~/.config/nvim/vim/functions/git/main.vim
" Подключение меню должно быть последним/предпоследним
source ~/.config/nvim/vim/plugins/menu/main.vim
" Строка меню постоянно видна сверху (в tabline), вкладки — строкой ниже
lua require('plugins.menu_tabline').setup()

" Стили которые должны идти последними
lua require('style.treesitter')

" LSP (mason, pyright, хоткеи переходов, подсветка вхождений)
lua require('plugins.lsp.main')
" Проверка внешних программ (lazygit, lazydocker, ctags и т.д.)
lua require('deps_check').check()
" Гайд по окружению проекта (venv, переменные из .env / nvim_settings.ini)
lua require('project_settings').print_guide()
" Автодополнение (nvim-cmp, сниппеты, сигнатуры, cmp-ai)
lua require('plugins.cmp.main')
" Отладка (nvim-dap + dap-python + dap-ui, запуск тестов)
lua require('plugins.dap.main')
" Поиск (telescope + fzy)
lua require('plugins.telescope.main')
" Вкладки сверху
lua require('plugins.bufferline.main')
" Автозакрытие парных скобок
lua require('plugins.autopairs.main')

" Карта кода (миникарта)
lua require('plugins.neominimap.main')
