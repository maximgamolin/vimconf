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
            \ [ "Close menu", "call quickui#menu#close()", ""],
            \ [ "E&xit\tAlt+x", 'echo 6' ],
            \ [ "--", '' ],
            \ [ "Скопировать название файла",        'lua vim.fn.setreg("+", vim.fn.expand("%:t")); vim.notify("Скопировано: " .. vim.fn.expand("%:t"))' ],
            \ [ "Скопировать путь от корня проекта", 'lua vim.fn.setreg("+", vim.fn.expand("%:.")); vim.notify("Скопировано: " .. vim.fn.expand("%:."))' ],
            \ [ "Скопировать полный путь на диске",  'lua vim.fn.setreg("+", vim.fn.expand("%:p")); vim.notify("Скопировано: " .. vim.fn.expand("%:p"))' ],
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
            \ [ "Места использования", "lua require('telescope.builtin').lsp_references()", ""],
            \ [ "--", ""],
            \ ['Список закладок', "BookmarkShowAll"],
            \ ['Удалить все заклаки', "BookmarkClearAll"],
            \ ])

" script inside %{...} will be evaluated and expanded in the string
call quickui#menu#install("&Option", [
			\ ['Set &Spell %{&spell? "Off":"On"}', 'set spell!'],
			\ ['Set &Cursor Line %{&cursorline? "Off":"On"}', 'set cursorline!'],
			\ ['Set &Paste %{&paste? "Off":"On"}', 'set paste!'],
			\ ['--', ''],
			\ ['Рендер &Markdown Toggle', 'RenderMarkdown buf_toggle', 'Включить/выключить рендер markdown в текущем файле'],
			\ ])

" AI меню (вес 9000 — перед Help)
call quickui#menu#install('&AI', [
        \ ['Открыть / скрыть Claude\t(\\ac)', 'ClaudeCode', ''],
        \ ['Фокус на Claude\t(\\af)',          'ClaudeCodeFocus', ''],
        \ ['--', ''],
        \ ['Продолжить сессию\t(\\ar)',        'ClaudeCode --resume', ''],
        \ ['Продолжить задачу\t(\\aC)',        'ClaudeCode --continue', ''],
        \ ['Выбрать модель',                   'ClaudeCodeSelectModel', ''],
        \ ['--', ''],
        \ ['Добавить файл в контекст\t(\\ab)', 'ClaudeCodeAdd %', ''],
        \ ['--', ''],
        \ ['Принять изменения\t(\\aa)',        'ClaudeCodeDiffAccept', ''],
        \ ['Отклонить изменения\t(\\ad)',      'ClaudeCodeDiffDeny', ''],
        \ ], 9000)

" Tools меню (вес 9500 — после AI, перед Help)
call quickui#menu#install('&Tools', [
        \ ["&Docker\t(\\ld)", 'lua LazyDockerOpen()', 'lazydocker: контейнеры, порты, логи, ресурсы'],
        \ ["&SQL\t(\\ls)", 'lua LazySqlOpen()', 'lazysql: подключения к БД, таблицы, запросы'],
        \ ], 9500)

" Review меню (вес 9550) — локальное ревью в стиле GitLab MR (lua/plugins/review)
call quickui#menu#install('&Review', [
        \ ['&Открыть ревью (от main)', 'ReviewOpen', 'Diff текущей ветки от merge-base с main; \\rc — замечание к строке'],
        \ ['&Выбрать ветки/коммиты…', 'ReviewPick', 'Пошагово: база (ветка → коммит), голова (рабочее дерево / ветка → коммит)'],
        \ ['Закрыть ревью', 'ReviewClose', ''],
        \ ['--', ''],
        \ ['&Список замечаний', 'ReviewComments', 'Все замечания ревью в quickfix'],
        \ ['Открыть &файл в ревью', 'call feedkeys(":ReviewFile ")', 'Любой файл проекта — попадёт в «Просмотренные»'],
        \ ['--', ''],
        \ ['Опубликовать замечания (commit)', 'ReviewPublish', 'git commit папки .review/'],
        \ ['Замечания закрыты (удалить+commit)', 'ReviewDone', 'Удалить .review/ и закоммитить удаление'],
        \ ['--', ''],
        \ ['Установить /fix-review в проект', 'ReviewClaudeSetup', 'Скопировать команду для Claude Code в .claude/commands'],
        \ ], 9550)

" Python меню (вес 9600 — после Tools)
call quickui#menu#install('&Python', [
        \ ["&Тест: запуск / отладка\t(\\tt)", "lua require('plugins.pytest_runner').open_menu()", 'PyCharm-style: запустить или отладить тест-метод/класс под курсором'],
        \ ['--', ''],
        \ ['&Закрыть интерфейс дебаггера', 'lua require("dapui").close()', 'Скрыть окна dap-ui'],
        \ ], 9600)

" register HELP menu with weight 10000
call quickui#menu#install('H&elp', [
			\ ["&Cheatsheet", 'lua Hlp()', ''],
			\ ['T&ips', 'help tips', ''],
			\ ['--',''],
			\ ["&Tutorial", 'help tutor', ''],
			\ ['&Quick Reference', 'help quickref', ''],
			\ ['&Summary', 'help summary', ''],
			\ ], 10000)

call quickui#menu#install("&Window",[
        \ ['Toggle дерево файлов', 'NvimTreeToggle', ''],
        \ ["Toggle карта кода\t(\\nm)", 'Neominimap Toggle', 'Миникарта справа как в Sublime: цвета кода, ошибки, поиск'],
        \ ['--', ''],
        \ ['Разделить по вертикали', 'vsp', ''],
        \ ['Разделить по горизонтали', 'sp', ''],
        \ ['--', ''],
        \ ['Закрыть вкладку',            'bd', ''],
        \ ['Закрыть все кроме текущей',  'lua local cur = vim.api.nvim_get_current_buf(); for _, b in ipairs(vim.api.nvim_list_bufs()) do if b ~= cur and vim.bo[b].buflisted then vim.cmd("bd " .. b) end end', ''],
        \ ['Следующая вкладка',          'bnext', ''],
        \ ['Предыдущая вкладка',         'bprev', ''],
\])


call quickui#menu#install("&Run",[
        \ ['Terminal', 'FloatermNew --height=0.2 --width=1.00 --wintype=split --position=bottom', ''],
        \ ['Close Terminal', "FloatermKill"],
        \ ['--', ''],
        \ ['Toggle debug window', 'lua require("dapui").toggle()', ''],
        \ ['--', ''],
        \ ["Toggle breakpoint\t(\\db)", "lua require'dap'.toggle_breakpoint()", ''],
        \ ["Start\\Continue debug", "lua require'dap'.continue()", ''],
        \ ["Debug closest test method\t(\\dm)", "lua require('dap-python').test_method()", ''],
        \ ["Debug closest test class\t(\\dc)", "lua require('dap-python').test_class()", ''],
        \ ["Debug selection in visual mode\t(\\ds)", "lua require('dap-python').debug_selection()", ''],
\])
call quickui#menu#install("Git",[
        \ ['Commit', 'lua LazyGitOpen()', ''],
        \ ['Commit && Push', 'lua LazyGitCommitPush()', ''],
        \ ['--', ''],
        \ ['Blame', 'Git blame', ''],
        \ ['--', ''],
        \ ["Diff куска под курсором\t(\\hp)", 'Gitsigns preview_hunk', 'Показать изменения hunk во всплывающем окне'],
        \ ["Откатить кусок\t(\\hr)", 'Gitsigns reset_hunk', 'Вернуть строки hunk как в git, остальное не трогая'],
        \ ["Stage куска\t(\\hs)", 'Gitsigns stage_hunk', 'git add только этого hunk; повторно — unstage'],
        \ ['--', ''],
        \ ['Ветки', 'MerginalToggle', ''],
        \ ['История', 'Telescope git_commits', ''],
        \ ['История файла', 'call GitLogForFile()', ''],
        \ ['История выделенного', 'call GitLogForVisualRange()', ''],
\])

"Контекстное меню (как по правой кнопке)
let contextMenu = [
      \ ['Toggle bookmark',     ':BookmarkToggle'],
      \ ['--', ''],
      \ ['Set breakpoint', "lua require'dap'.toggle_breakpoint()"]
      \ ]
let opts = {'index':g:quickui#context#cursor}

" enable to display tips in the cmdline
let g:quickui_show_tip = 1

" Открыть меню
noremap <space><space> :call quickui#menu#open()<cr>
nnoremap <silent> <leader>m :call quickui#context#open(contextMenu, opts)<CR>

