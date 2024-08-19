-- Конфигурация плагина vim-bookmarks в Lua
vim.g.bookmark_sign = '⚑'
vim.g.bookmark_annotation_sign = '☰'
vim.g.bookmark_no_default_key_mappings = 1
vim.g.bookmark_save_per_working_dir = 1  -- "Сохранять закладку в зависимости от проекта в файл .vim-bookmarks"
vim.g.bookmark_auto_save = 1

require('plugins.vimbookmarks.hotkeys')
