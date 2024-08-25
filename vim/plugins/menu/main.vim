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

call quickui#menu#install("&Window",[
        \ ['Разделить по вертикали', 'vsp', ''],
        \ ['Разделить по горизонтали', 'sp', ''],
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
        \ ['Blame', 'Git blame', ''],
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

" Открыть менб
noremap <space><space> :call quickui#menu#open()<cr>
nnoremap <silent> <leader>m :call quickui#context#open(contextMenu, opts)<CR>


