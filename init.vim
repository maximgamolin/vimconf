" Установить ctags, fzf, fd, ripgrep
" Для python установить debugpy
call plug#begin()
"Цветовая схема
Plug 'maxmx03/solarized.nvim'
"Полоска снизу
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Скроллбар
Plug 'Xuyuanp/scrollbar.nvim'
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
" Вкладки сверху
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
" Дерево файлов
Plug 'nvim-tree/nvim-tree.lua'
" Закладки в коде
Plug 'MattesGroeger/vim-bookmarks'
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
colorscheme solarized

" Дополнительные настройки для улучшения отображения UI
hi Normal guibg=NONE ctermbg=NONE  " Убрать фон
hi LineNr guifg=#d3b58d            " Цвет номеров строк
hi CursorLineNr guifg=#fabd2f      " Цвет номера строки под курсором
hi Comment guifg=#7c6f64           " Цвет комментариев

" Стили которые должны идти до
lua require('style.main')
" Подключение конфига плагинов

lua require('h') 
lua require('plugins.nvimtreeplug.main')
lua require('plugins.vimbookmarks.main')
lua require('plugins.vimairline.main')
lua require('plugins.blamer.main')
lua require('plugins.vimfloaterm.main')
lua require('plugins.ibl.main')
lua require('plugins.nvimtreesitter.main')
source ~/.config/nvim/vim/functions/git/main.vim
" Подключение меню должно быть последним/предпоследним
source ~/.config/nvim/vim/plugins/menu/main.vim

" Стили которые должны идти последними
lua require('style.treesitter')

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
-- Загрузка кастомных снипетов
  require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/snippets/" })

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
      ['<CR>'] = cmp.mapping.confirm(),
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
  local venv_path = tostring(vim.fn.getenv('VIRTUAL_ENV'))
print('Python virtual env: ' .. venv_path)
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
-- dap.listeners.before.event_terminated.dapui_config = function()
--   dapui.close()
-- end
-- dap.listeners.before.event_exited.dapui_config = function()
--   dapui.close()
-- end

-- UI для дебага
require("dapui").setup()

-- Вкладки сверху
require("bufferline").setup{}

-- Функция для вывода всех загруженных сниппетов
local function print_snippets()
  local ls = require("luasnip")
  local snippets = ls.snippets
  for ft, snips in pairs(snippets) do
    print("Язык: " .. ft)
    for _, snip in ipairs(snips) do
      print("  Сниппет: " .. (snip.trigger or snip.name))
    end
  end
end

-- Вызов функции для вывода сниппетов
print_snippets()

-- Автоматически закрывать скобки
local npairs = require("nvim-autopairs")
npairs.setup({check_ts = true,})

EOF

"Настройка telescope + fzf
lua require('telescope').load_extension('fzy_native')

" Настройка сроллбара
augroup ScrollbarInit
  autocmd!
  autocmd WinScrolled,VimResized,QuitPre * silent! lua require('scrollbar').show()
  autocmd WinEnter,FocusGained           * silent! lua require('scrollbar').show()
  autocmd WinLeave,BufLeave,BufWinLeave,FocusLost            * silent! lua require('scrollbar').clear()
augroup end


