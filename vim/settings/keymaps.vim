" Общие горячие клавиши (не привязанные к конкретному плагину)

" Работа хоткеев при русской раскладке (langmap)
set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

" Ctrl+кириллица → Ctrl+латиница (langmap не покрывает модификаторы)
noremap <C-ф> <C-a>
noremap <C-и> <C-b>
noremap <C-с> <C-c>
noremap <C-в> <C-d>
noremap <C-у> <C-e>
noremap <C-а> <C-f>
noremap <C-п> <C-g>
noremap <C-р> <C-h>
noremap <C-ш> <C-i>
noremap <C-о> <C-j>
noremap <C-л> <C-k>
noremap <C-д> <C-l>
noremap <C-ь> <C-m>
noremap <C-т> <C-n>
noremap <C-щ> <C-o>
noremap <C-з> <C-p>
noremap <C-й> <C-q>
noremap <C-к> <C-r>
noremap <C-ы> <C-s>
noremap <C-е> <C-t>
noremap <C-г> <C-u>
noremap <C-м> <C-v>
noremap <C-ц> <C-w>
noremap <C-ч> <C-x>
noremap <C-н> <C-y>
noremap <C-я> <C-z>

" Command+C — копировать выделение в буфер обмена (работает в GUI/Neovide)
vnoremap <D-c> "+y
nnoremap <D-c> "+yy

" Переключение между окнами через Alt+стрелки
nnoremap <A-Left>  <C-w>h
nnoremap <A-Down>  <C-w>j
nnoremap <A-Up>    <C-w>k
nnoremap <A-Right> <C-w>l

" Открыть локальную историю изменений (undotree)
nnoremap <F5> :UndotreeToggle<CR>
" Открыть бар с функциями и классами (tagbar)
nnoremap <F8> :TagbarToggle<CR>
