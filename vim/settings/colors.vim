" Цветовая схема и переопределения подсветки

" Количество цветов для терминала (256 или 16)
set t_Co=256

" Использовать 24-битные цвета, если терминал поддерживает (iTerm2, gnome-terminal и т.д.)
if (has("termguicolors"))
  set termguicolors
endif

set background=light      " Установить светлую тему
colorscheme solarized

" Дополнительные настройки для улучшения отображения UI
hi Normal guibg=NONE ctermbg=NONE  " Убрать фон
hi LineNr guifg=#a3adab            " Цвет номеров строк (LINE_NUMBERS_COLOR)
hi CursorLineNr guifg=#677d85      " Цвет номера строки под курсором (LINE_NUMBER_ON_CARET_ROW_COLOR)
hi Comment guifg=#88999b           " Цвет комментариев (DEFAULT_LINE_COMMENT)

" Спеллчек: убрать зачёркивание у незнакомых слов, оставить только волнистое подчёркивание
augroup SpellNoStrike
  autocmd!
  autocmd ColorScheme * hi SpellBad gui=undercurl cterm=undercurl guisp=#dc322f
augroup END
hi SpellBad gui=undercurl cterm=undercurl guisp=#dc322f

" LSP: мягкая подсветка вхождений переменной под курсором.
" Лёгкий фон в тон solarized + подчёркивание, текст сохраняет свой цвет и читается.
function! s:LspRefColors() abort
  hi LspReferenceText  guibg=#eee8d5 gui=underline guisp=#93a1a1 cterm=underline
  hi LspReferenceRead  guibg=#eee8d5 gui=underline guisp=#93a1a1 cterm=underline
  hi LspReferenceWrite guibg=#eee8d5 gui=underline guisp=#b58900 cterm=underline
endfunction
augroup LspRefColors
  autocmd!
  autocmd ColorScheme * call s:LspRefColors()
augroup END
call s:LspRefColors()
