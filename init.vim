" Установить ctags, fzf, fd, ripgrep
" Для python установить debugpy
call plug#begin()
"Дерево слева
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin' " Гит плагин для дерева слева
"Цветовая схема
Plug 'morhetz/gruvbox'
"Полоска снизу
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Цветные отступы
Plug 'lukas-reineke/indent-blankline.nvim'
"Терминал
Plug 'voldikss/vim-floaterm'
"Меню
Plug 'skywind3000/vim-quickui'
"Подствека синтаксиса
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
"Смотреть в коде какой элемент за что отвечает, чтобы настроить потом
"подстветку
Plug 'nvim-treesitter/playground'
Plug 'nvim-treesitter/nvim-treesitter-refactor' " Подсветка переменных в области видимости
"Телескоп для поиска
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
Plug 'nvim-telescope/telescope-fzy-native.nvim' " Тоже для телескопа, но чтобы работал поиск по коммитам
"Локальная история изменения файлов
Plug 'mbbill/undotree'
"Бар сбоку с классами и функциями
Plug 'preservim/tagbar'
" vim-fugitive для работы с Git
Plug 'tpope/vim-fugitive'
" vim-signify для показа символов изменений рядом с номерами строк
Plug 'mhinz/vim-signify'
" vim-merginal для работы с деревом Git
Plug 'idanarye/vim-merginal'
" Git lens
Plug 'APZelos/blamer.nvim'
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
Plug 'rafamadriz/friendly-snippets' " Коллекция snippets
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

call plug#end()



set number "Номера строк
set cursorline     " Подсветка текущей строки
set showcmd        " Показ текущей команды
set wildmenu       " Включить меню авто-дополнения
set updatetime=100 " Настройка для signifity
set expandtab "Пробелы вместо табуляци

set hlsearch "Подсветка поиска
set incsearch "Инкрементальный поиск

syntax on "Подсветка синтаксиса
set completeopt=menu,menuone,noselect " Отключение стандартного автодополнения для nvim-cmp
" Настройка заголовка окна
set title 
set titlestring=%{getcwd()}
"Настройка цветовой схемы

" Количество цветов для терминала (256 или 16)
set t_Co=256

" Использовать 24-битные цвета, если ваш терминал поддерживает это (например, iTerm2, gnome-terminal и т.д.)
if (has("termguicolors"))
  set termguicolors
endif

set background=light      " Установить светлую тему
colorscheme gruvbox        " Активировать Gruvbox
let g:gruvbox_contrast_light='soft'  " Установить контраст для светлой темы (может быть 'hard', 'soft' или 'medium')
let g:gruvbox_invert_selection='0'   " Не инвертировать цвет выделения
let g:gruvbox_sign_column='bg0'      " Установить цвет столбца знаков
let g:airline_theme='gruvbox'        " Настройка Airline для работы с Gruvbox (если используете vim-airline)

" Дополнительные настройки для улучшения отображения UI
hi Normal guibg=NONE ctermbg=NONE  " Убрать фон
hi LineNr guifg=#d3b58d            " Цвет номеров строк
hi CursorLineNr guifg=#fabd2f      " Цвет номера строки под курсором
hi Comment guifg=#7c6f64           " Цвет комментариев

" DAP горячие клавиши

nnoremap <silent> <leader>db :lua require('dap').toggle_breakpoint()<CR>
nnoremap <silent> <leader>dd :lua require('dap').continue()<CR>
nnoremap <silent> <leader>dn :lua require('dap-python').test_method()<CR>
nnoremap <silent> <leader>df :lua require('dap-python').test_class()<CR>
vnoremap <silent> <leader>ds <ESC>:lua require('dap-python').debug_selection()<CR>


"Telescope горячие клавиши
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
" Открыть локальную историю
nnoremap <F5> :UndotreeToggle<CR>
" Открыть бар с функциями и классами
nnoremap <F8> :TagbarToggle<CR>

" Использовать Nerd-fonts для git плагина для nerdtree
let g:NERDTreeGitStatusUseNerdFonts = 1
" Показывать инорируемые файлы для nerdtree-git-plugin
let g:NERDTreeGitStatusShowIgnored = 1
" Учитывать гит репозитории в поддиректорияз
let g:NERDTreeGitStatusConceal = 0

" Настройки горячих клавиш для NERDTree

" Открыть NERDTree
nnoremap <silent> <C-n> :NERDTreeToggle<CR>

" Переключение между NERDTree и открытым файлом
nnoremap <silent> <C-t> :NERDTreeFind<CR>

" Горячие клавиши внутри NERDTree

" Открыть файл или директорию
let NERDTreeMapOpen= 'o'          " Открыть, но остаться в дереве
let NERDTreeMapOpenSplit= 'i'     " Открыть в горизонтальном сплите
let NERDTreeMapOpenVSplit= 's'    " Открыть в вертикальном сплите
let NERDTreeMapOpenInTab= 't'     " Открыть в новой вкладке

" Перемещение по дереву
let NERDTreeMapOpenInNewTab= 'T'  " Открыть в новой вкладке и перейти в нее
let NERDTreeMapToggleFile= 'x'    " Закрыть/открыть директорию в дереве
let NERDTreeMapPreview= 'P'       " Предварительный просмотр файла

" Навигация
let NERDTreeMapChangeRoot= 'C'    " Сделать текущую директорию корневой
let NERDTreeMapUpDir= 'u'         " Перейти на директорию выше
let NERDTreeMapToggleMenu= 'm'    " Вызвать меню действий (создать файл/директорию и т.д.)

" Работа с узлами
let NERDTreeMapAddFile= 'a'       " Добавить новый файл/директорию
let NERDTreeMapDeleteNode= 'D'    " Удалить файл/директорию
let NERDTreeMapRenameNode= 'r'    " Переименовать файл/директорию
let NERDTreeMapRefreshRoot= 'R'   " Обновить дерево

" Другие полезные команды
let NERDTreeMapHelp= '?'          " Показать справку по NERDTree
let NERDTreeMapCWD= 'cd'          " Изменить текущую директорию на выбранную в NERDTree

" Добавление дерева буферов
let NERDTreeShowBookmarks=1       " Показывать закладки

" Автоматическое закрытие в случае, если это единственное окно
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | q | endif

" Опции NERDTree
let NERDTreeMinimalUI=1           " Минимальный интерфейс
let NERDTreeDirArrows=1           " Отображение стрелок для директории

" Настройки blamer.nvim 
let g:blamer_enabled = 1
let g:blamer_delay = 0
let g:blamer_prefix = ' > '
highlight Blamer guifg=#928374

" Настройки vim-airline

" Активировать vim-airline
let g:airline#extensions#tabline#enabled = 1         " Включить табы сверху

" Показ числа вкладок и буферов
let g:airline#extensions#tabline#show_tabs = 1       " Показать вкладки
let g:airline#extensions#tabline#show_buffers = 1    " Показать буферы
let g:airline#extensions#tabline#show_splits = 0     " Не показывать сплиты
let g:airline#extensions#tabline#show_tab_nr = 1     " Показать номер вкладки
let g:airline#extensions#tabline#show_close_button = 1 " Показать кнопку закрытия вкладки

" Использовать powerline шрифты
let g:airline_powerline_fonts = 1                    " Включить шрифты powerline

" Параметры отображения информации
let g:airline#extensions#whitespace#enabled = 1      " Показать пробелы, табы и т.п.
let g:airline#extensions#branch#enabled = 1          " Показать информацию о ветке Git
let g:airline#extensions#hunks#enabled = 1           " Показать информацию о хлипах Git
let g:airline#extensions#ale#enabled = 1             " Интеграция с ALE для проверок синтаксиса
let g:airline#extensions#coc#enabled = 1             " Интеграция с CoC

" Цветовая тема Airline
let g:airline_theme='sol'

" Укорочение имени буфера - включить
let g:airline#extensions#tabline#fnamecollapse = 1

" Горячие клавиши для работы с vim-airline

" Переключение между буферами
nnoremap <silent> <C-Left> :bp<CR>     " Перейти на предыдущий буфер
nnoremap <silent> <C-Rigt> :bn<CR>    " Перейти на следующий буфер

" Открытие файлов во вкладках
nnoremap <silent> <C-t> :tabnew<CR>    " Открыть новый таб

" Переключение между вкладками
nmap <silent> <C-h> :tabprevious<CR>  " Перейти на предыдущую вкладку
nmap <silent> <C-l> :tabnext<CR>      " Перейти на следующую вкладку

" Закрытие вкладок
nnoremap <silent> <C-w> :tabclose<CR>  " Закрыть текущую вкладку

" Перемещение вкладок
nnoremap <silent> <C-Shift-Left> :tabmove -1<CR>   " Переместить текущую вкладку влево
nnoremap <silent> <C-Shift-Right> :tabmove +1<CR>  " Переместить текущую вкладку вправо
"Моя шпаргалка
lua require('h')

"Цвета для пробелов при цветных отступах

highlight RainbowRedSpace guibg=#FCE3D6
highlight RainbowYellowSpace guibg=#F8F4DE
highlight RainbowBlueSpace guibg=#F2EEE4
highlight RainbowOrangeSpace guibg=#FCF0DC
highlight RainbowGreenSpace guibg=#EEF3DF
highlight RainbowVioletSpace guibg=#FCE3D6
highlight RainbowCyanSpace guibg=#EEF3DF

highlight link PySyntaxKwargs Green


"Горячие клавиши для терминала
nmap <silent> <C-d> :FloatermNew --height=0.2 --width=1.00 --wintype=split --position=bottom<CR> 
" clear all the menus
call quickui#menu#reset()

" install a 'File' menu, use [text, command] to represent an item.
call quickui#menu#install('&File', [
            \ [ "&New File\tCtrl+n", 'echo 0' ],
            \ [ "&Open File\t(F3)", 'echo 1' ],
            \ [ "&Close", 'echo 2' ],
            \ [ "--", '' ],
            \ [ "&Save\tCtrl+s", 'echo 3'],
            \ [ "Save &As", 'echo 4' ],
            \ [ "Save All", 'echo 5' ],
            \ [ "--", '' ],
            \ [ "E&xit\tAlt+x", 'echo 6' ],
            \ ])

" items containing tips, tips will display in the cmdline
call quickui#menu#install('&Edit', [
            \ [ '&Copy', 'echo 1', 'help 1' ],
            \ [ '&Paste', 'echo 2', 'help 2' ],
            \ [ '&Find', 'echo 3', 'help 3' ],
            \ [ "--", ''],
            \ [ "Глобальный поиск по cодержимому", 'Telescope live_grep', ''],
            \ [ "Поиск файла по названию", 'Telescope find_files', ''],
            \ [ "Поиск буфера", "Telescope buffers"],
            \ [ "--", ''],
            \ [ "Структура\t(F8)", "TagbarToggle", ""],
            \ [ "--", ""],
            \ [ "Локальная история\t(F5)", "UndotreeToggle", ""],
            \ [ "--", ""],
            \ [ "Места использования", "lua require('telescope.builtin').lsp_references()", ""]
            \ ])

" script inside %{...} will be evaluated and expanded in the string
call quickui#menu#install("&Option", [
			\ ['Set &Spell %{&spell? "Off":"On"}', 'set spell!'],
			\ ['Set &Cursor Line %{&cursorline? "Off":"On"}', 'set cursorline!'],
			\ ['Set &Paste %{&paste? "Off":"On"}', 'set paste!'],
			\ ])

" register HELP menu with weight 10000
call quickui#menu#install('H&elp', [
			\ ["&Cheatsheet", 'lua Hlp()', ''],
			\ ['T&ips', 'help tips', ''],
			\ ['--',''],
			\ ["&Tutorial", 'help tutor', ''],
			\ ['&Quick Reference', 'help quickref', ''],
			\ ['&Summary', 'help summary', ''],
			\ ], 10000)

call quickui#menu#install("&Run",[
        \ ['Terminal', 'FloatermNew --height=0.2 --width=1.00 --wintype=split --position=bottom', ''],
        \ ['Close Terminal', "FloatermKill"],
        \ ['--', ''],
        \ ['Toggle debug window', 'lua require("dapui").toggle()', ''],
        \ ['--', ''],
        \ ['Toggle breakpoint\t(\\db)', "lua require'dap'.toggle_breakpoint()", ''],
        \ ['Start\Continue debug', "lua require'dap'.continue()", ''],
        \ ['Debug closest test method\t(\\dm)', "lua require('dap-python').test_method()", ''], 
        \ ['Debug closest test class\t(\\dc)', "lua require('dap-python').test_class()", ''],
        \ ['Debug selection in visual mode\t(\\ds)', "lua require('dap-python').debug_selection()", ''],
\])
call quickui#menu#install("Git",[
        \ ['Blame', 'Git blame', ''],
        \ ['Ветки', 'MerginalToggle', ''],
        \ ['История', 'Telescope git_commits', ''],
        \ ['История файла', 'Telescope git_bcommits', ''],
        \ ['История выделенного', 'call GitLogForVisualRange()', ''],
\])
" enable to display tips in the cmdline
let g:quickui_show_tip = 1

" Открыть менб
noremap <space><space> :call quickui#menu#open()<cr>

function! FindGitRelativePath(file)
  " Поиск ближайший папки гит от файла
  let l:current_dir = fnamemodify(a:file, ':h')
  let l:git_dir = ''

  while l:current_dir != '/' && l:git_dir == ''
    if isdirectory(l:current_dir . '/.git')
      let l:git_dir = l:current_dir
    else
      let l:current_dir = fnamemodify(l:current_dir, ':h')
    endif
  endwhile

  if l:git_dir == ''
    echo "Error: .git directory not found"
    return ''
  endif

  return substitute(a:file, l:git_dir . '/', '', '')
endfunction

function! GitLogForVisualRange()
  " Функция для показа куска истории через гит лог
  let l:start = line("'<")
  let l:end = line("'>")
  let l:file = expand('%:p')
  let l:file = expand('%:p')
  let l:relative_path = FindGitRelativePath(l:file)

  " Create the command string with --graph option
  let l:cmd = 'Git log -L ' . l:start . ',' . l:end . ':' . l:relative_path . ' --graph'

  " Execute the command
  execute l:cmd
endfunction

lua <<EOF
-- функция для считывания файла с переменными окружения
local function load_env_vars(filepath)
    local file = io.open(filepath, "r")
    if not file then
        vim.api.nvim_err_writeln("Could not open file: " .. filepath)
        return
    end
    
    for line in file:lines() do
        for key, value in string.gmatch(line, "([%w_]+)=([%w%p]+)") do
            vim.fn.setenv(key, value)
        end
    end
    
    file:close()
end
load_env_vars(vim.fn.getcwd() .. "/env")



-- Настройка цветных отступов
local highlight = {
    "RainbowRed",
    "RainbowYellow",
    "RainbowBlue",
    "RainbowOrange",
    "RainbowGreen",
    "RainbowViolet",
    "RainbowCyan",
}

local hooks = require("ibl.hooks")
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
    vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
    vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
    vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
    vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
    vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
    vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
end)

require("ibl").setup({indent = {highlight = highlight},whitespace = {highlight = {"RainbowRedSpace", "RainbowYellowSpace", "RainbowBlueSpace", "RainbowGreenSpace", "RainbowVioletSpace", "RainbowCyanSpace"}}})

-- Настройки для treesitter
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  --ensure_installed = { "python", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  -- auto_install = true,

  refactor = {
    highlight_definitions = {
      enable = true,            -- Включение выделения объявления
      clear_on_cursor_move = true, -- Очистка выделения при движении курсора
    },
    highlight_current_scope = {
      enable = false             -- Выделение текущей области (опционально)
    },
    smart_rename = {
      enable = true,
      -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
      keymaps = {
        smart_rename = "grr",
      },
    },
    navigation = {
      enable = true,
      -- Assign keymaps to false to disable them, e.g. `goto_definition = false`.
      keymaps = {
        goto_definition = "gnd",
        list_definitions = "gnD",
        list_definitions_toc = "gO",
        goto_next_usage = "<a-*>",
        goto_previous_usage = "<a-#>",
      },
    },
  },
  ensure_installed = {"python",},
  highlight = {
    enable = true,
    playground = {
      enable = true,
      disable = {},
      updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
      persist_queries = false, -- Whether the query persists across vim sessions
      keybindings = {
        toggle_query_editor = 'o',
        toggle_hl_groups = 'i',
        toggle_injected_languages = 't',
        toggle_anonymous_nodes = 'a',
        toggle_language_display = 'I',
        focus_language = 'f',
        unfocus_language = 'F',
        update = 'R',
        goto_node = '<cr>',
        show_help = '?',
      },
    }
  }
}
-- Кастомные цвета для ключевых слов
vim.api.nvim_set_hl(0, "@variable.parameter", { fg = "#8f3f71" })

vim.api.nvim_set_hl(0, "@keyword.return", { fg = "#689d6a", bold = true })
vim.api.nvim_set_hl(0, "@keyword", { bold = true })

-- LSP
require("mason").setup()
require("mason-lspconfig").setup {
    ensure_installed = { "lua_ls", "pyright", "bashls", "cmake", "cssls", "dockerls", "docker_compose_language_service", "autotools_ls", "markdown_oxide", "nginx_language_server", "pyright", "sqlls", "taplo", "lemminx", "yamlls" }
}

-- LSP автодополнения
-- корневые диретории из переменной окрудения для lsp сервера
local pythonpath = vim.env.PYTHONPATH
local pythonpath_dirs = {}
if pythonpath ~= nil then
    for path in string.gmatch(pythonpath, "[^:]+") do
        table.insert(pythonpath_dirs, path)
    end
end

-- Указываем стандартные корневые файлы и добавляем пути из PYTHONPATH
local root_files = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    '.git'
}

-- Добавляем пути из PYTHONPATH в список корневых файлов
for _, path in ipairs(pythonpath_dirs) do
    table.insert(root_files, path)
end


-- Поиск места использования проекта
require('telescope').setup{
  defaults = {
    vimgrep_arguments = {
      'rg', 
      '--color=never', 
      '--no-heading', 
      '--with-filename', 
      '--line-number', 
      '--column', 
      '--smart-case',
      '--hidden',
    },
    file_ignore_patterns = {"*.pyc", "__pycache__", "venv*"},
    layout_config = {
      horizontal = {
        preview_width = 0.4,
      },
      vertical = {
        preview_height = 0.5,
      },
      width = 0.9,
      height = 0.9,
    },
    path_display = {"truncate"}

  }
}
-- Сигнатура функций
require'lsp_signature'.setup({
    bind = true, -- Это обязательная настройка, позволяет управлять плавающим окном
    hint_enable = false, -- Если true, включает подсказки в строке состояния
    floating_window = true, -- Использовать плавающее окно для отображения информации
    floating_window_above_cur_line = true, -- Плавающее окно над текущей строкой
    doc_lines = 10, -- Количество строк документации, отображаемой в плавающем окне
    max_height = 12, -- Максимальная высота плавающего окна
    max_width = 120, -- Максимальная ширина плавающего окна
    handler_opts = {
      border = "rounded" -- Опции для рамки плавающего окна: "single", "double", "rounded", "solid", "shadow"
    },
    extra_trigger_chars = {"(", ","} -- Символы, которые будут вызывать отображение информации о параметрах функции
  })


-- Require necessary modules
local cmp = require('cmp')
local lspconfig = require('lspconfig')
  
-- Функция для определения корневой директории
local function get_root_dir(fname)
    return lspconfig.util.root_pattern(unpack(root_files))(fname) or
           lspconfig.util.path.dirname(fname)
end
  lspconfig.pyright.setup({
  on_attach = function(client, bufnr)
    local buf_map = function(bufnr, mode, lhs, rhs, opts)
      opts = vim.tbl_extend("force", {noremap=true, silent=true}, opts or {})
      vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
    end

    -- Переход к определению (Ctrl+])
    buf_map(bufnr, "n", "<C-]>", "<cmd>lua vim.lsp.buf.definition()<CR>")

    -- Возвращение обратно (Ctrl+o)
    buf_map(bufnr, "n", "<C-o>", "<C-o>")

    -- Список использований функции или класса (Ctrl+])
    buf_map(bufnr, "n", "<C-r>", "<cmd>lua require('telescope.builtin').lsp_references()<CR>")
  end,
})

  -- nvim-cmp setup
  local source_mapping = {
  buffer = '[Buffer]',
  nvim_lsp = '[LSP]',
  nvim_lua = '[Lua]',
  cmp_ai = '[AI]',
  path = '[Path]',
}  -- маппинг для нейросети, пока не работает
  local lspkind = require('lspkind') -- Красивые шрифты
  cmp.setup({
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    mapping = {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Down>'] = cmp.mapping.select_next_item(),
      ['<Up>'] = cmp.mapping.select_prev_item(),
      ['<Right>'] = cmp.mapping.scroll_docs(4),
      ['<C-a>'] = cmp.mapping(cmp.mapping.complete({
        config = {
          sources = cmp.config.sources({
              { name = 'cmp_ai' },
            }),
          },
        }),
        { 'i' }
      ),
    },
    sources = cmp.config.sources({
      -- { name = 'cmp_ai' },
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    }, {
      { name = 'buffer' },
      { name = 'path' },
    }),
    formatting = {
      format = lspkind.cmp_format({
        mode = 'symbol', -- show only symbol annotations
        maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                     -- can also be a function to dynamically calculate max width such as 
                     -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
        ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
        show_labelDetails = true, -- show labelDetails in menu. Disabled by default

      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
        before = function(entry, vim_item)
        -- Оборачиваем функции и классы в круглые скобки
          if vim.tbl_contains({'Function', 'Method'}, vim_item.kind) then
            vim_item.abbr = vim_item.abbr .. '()'
          end
          -- Это нужно будет включить, если найду небольшую нейронку
          -- vim_item.kind = lspkind.symbolic(vim_item.kind, { mode = 'symbol' })
          -- vim_item.menu = source_mapping[entry.source.name]
          -- if entry.source.name == 'cmp_ai' then
          --   local detail = (entry.completion_item.labelDetails or {}).detail
          --   vim_item.kind = ''
          --   if detail and detail:find('.*%%.*') then
          --     vim_item.kind = vim_item.kind .. ' ' .. detail
          --   end

          --  if (entry.completion_item.data or {}).multiline then
          --    vim_item.kind = vim_item.kind .. ' ' .. '[ML]'
          --  end
          --end
          --local maxwidth = 80
          --vim_item.abbr = string.sub(vim_item.abbr, 1, maxwidth)
          return vim_item
      end

      })
    }

  })

  -- LSP setup for Python
  local servers = { 'pyright' } -- Add other servers if needed
  local venv_path = tostring(vim.fn.getenv('VIRTUAL_ENV_PYTHON'))

  for _, lsp in ipairs(servers) do
    local settings = {}
    if lsp == 'pyright' and venv_path ~= '' then
      settings = {
        python = {
          pythonPath = venv_path
        }
      }
    end
    lspconfig[lsp].setup({
      root_dir = get_root_dir,
      capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
      settings = settings,
    })
  end

  -- Настройка посветки определений функции и класса 
  vim.cmd [[
    augroup lsp_document_highlight
      autocmd!
      autocmd CursorHold,CursorHoldI * lua vim.lsp.buf.document_highlight()
      autocmd CursorMoved,CursorMovedI * lua vim.lsp.buf.clear_references()
    augroup END
]]
-- Автодополнения от нейронки (пока не работает)
local cmp_ai = require('cmp_ai.config')

cmp_ai:setup({
  max_lines = 100,
  provider = 'Ollama',
  provider_options = {
    -- model = 'codegemma:latest',
    -- model = 'deepseek-coder-v2:latest',
    model = 'codellama:7b-code',
  },
  notify = true,
  notify_callback = function(msg)
    vim.notify(msg)
  end,
  run_on_every_keystroke = true,
  ignored_file_types = {
    -- default is not to ignore
    -- uncomment to ignore in lua:
    -- lua = true
  },
})

-- DAP для python
local dap_python = require("dap-python")
dap_python.setup(vim.env.VIRTUAL_ENV_PYTHON)
dap_python.test_runner = vim.env.PYTESTRUNNER or 'pytest'

-- Автоматичеси открывать и закрывать окно при запуске дебаггера
local dap, dapui = require("dap"), require("dapui")
dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

require("dapui").setup()
EOF

"Настройка telescope + fzf
lua require('telescope').load_extension('fzy_native')


