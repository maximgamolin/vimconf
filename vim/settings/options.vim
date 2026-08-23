" Базовые опции редактора

set mouse=a                  " Включить поддержку мыши (перетаскивание границ окон)
set mousescroll=ver:1,hor:6  " Колесо скроллит по 1 строке вместо 3 — плавнее
set mousemodel=extend        " Правый клик доходит до обработчиков (меню вкладок), а не открывает встроенный popup
set smoothscroll             " Прокрутка по экранным строкам (длинные строки не «прыгают»)
set clipboard=unnamedplus    " Синхронизировать буфер yank с системным буфером обмена

set number         " Номера строк
set laststatus=3   " Одна общая нижняя панель на всё окно вместо отдельной на каждый сплит
set noshowmode     " Не печатать «-- ВИЗУАЛЬНЫЙ РЕЖИМ --» — режим и так виден в airline
set cursorline     " Подсветка текущей строки
set showcmd        " Показ текущей команды
set wildmenu       " Включить меню авто-дополнения
set updatetime=250 " Для gitsigns и LSP document_highlight (100 давало лишние LSP-запросы при движении)
set expandtab      " Пробелы вместо табуляции

set hlsearch       " Подсветка поиска
set incsearch      " Инкрементальный поиск

syntax on          " Подсветка синтаксиса
set completeopt=menu,menuone,noselect " Отключение стандартного автодополнения для nvim-cmp

" Заголовок окна — текущая директория
set title
set titlestring=%{getcwd()}

" Сворачивание кода через treesitter (как + в PyCharm)
set foldmethod=expr
set foldexpr=v:lua.vim.treesitter.foldexpr()
set foldlevelstart=99  " По умолчанию всё раскрыто при открытии файла
set foldenable
set foldcolumn=1       " Показывать колонку со значками + слева от номеров строк

" Проверка орфографии
set spell
set spelllang=en,ru

" Автосохранение
augroup autosave
  autocmd!
  " Сохранять при выходе из режима вставки и после изменений в normal mode
  autocmd InsertLeave,TextChanged * if &modifiable && !&readonly && bufname('%') != '' | silent! write | endif
  " Сохранять при потере фокуса (переключение окна/приложения)
  autocmd FocusLost * if &modifiable && !&readonly && bufname('%') != '' | silent! write | endif
augroup end
