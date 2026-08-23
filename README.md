# Конфиг Neovim

Конфиг под Python-разработку в духе PyCharm: LSP (pyright + venv), отладка
через DAP, запуск тестов, git-инструменты, локальное код-ревью и интеграция
с Claude Code. Тема — **Solarized Light** (`maxmx03/solarized.nvim`,
termguicolors). Меню — vim-quickui, постоянно видно сверху в tabline.

## Структура

```
init.vim          — список плагинов (vim-plug) и подключение модулей
vim/settings/     — опции, общие хоткеи, цвета
vim/plugins/      — конфиги плагинов на vimscript (меню)
vim/functions/    — вспомогательные функции (git)
lua/plugins/      — конфиги плагинов на lua (по папке на плагин)
lua/style/        — цвета treesitter и отступов
lua/snippets/     — сниппеты (python)
queries/          — свои treesitter-запросы
```

## Что внутри

- **UI**: airline, bufferline (вкладки с контекстным меню), nvim-tree
  (с раскраской папок из `nvim_settings.ini`), карта кода neominimap
  (`\nm`, как minimap в Sublime), indent-blankline, радужные скобки,
  разноцветные одинаковые идентификаторы (локальный модуль markid), devicons.
- **Поиск**: telescope + fzy-native; файлы через `fd` (`\ff`), по содержимому
  через `rg` (`Ctrl+Shift+F`), скрытые папки исключены.
- **Git**: gitsigns (значки изменений, inline-blame, работа с hunks —
  `]c`/`[c`, `\hp`/`\hr`/`\hs`), fugitive, merginal (ветки), lazygit
  (Commit / Commit & Push), история через telescope.
- **Ревью**: локальное MR-ревью в стиле GitLab (`lua/plugins/review` поверх
  codediff.nvim): `:ReviewOpen` — diff ветки от merge-base с main,
  замечания к строкам (`\rc`), хранятся в `.review/` и коммитятся
  (`:ReviewPublish`), Claude Code исправляет их по `/fix-review`.
- **LSP**: mason + mason-lspconfig; pyright берёт venv из
  `nvim_settings.ini` / переменных окружения. `K` — документация,
  `Ctrl+]` / `Ctrl+Enter` / Option+Click — переходы, `grr` — переименование,
  подсветка вхождений под курсором.
- **Автодополнение**: nvim-cmp (LSP, буфер, пути, cmp-ai), LuaSnip,
  подсказка сигнатур (lsp_signature).
- **Отладка**: nvim-dap + dap-ui + dap-python, значения переменных
  виртуальным текстом; запуск/отладка pytest/unittest-тестов под курсором
  (`\tt`, меню Python).
- **AI**: claudecode.nvim — Claude Code в сплите (`\ac`), diff-принятие
  изменений (`\aa`/`\ad`).
- **Терминал и инструменты**: floaterm (вкладки в winbar, кликабельные пути),
  lazydocker (`\ld`), lazysql (`\ls`) в плавающих окнах.
- **Markdown**: рендер прямо в буфере, картинки по kitty graphics protocol,
  PlantUML/Mermaid-диаграммы картинками.
- **Прочее**: спеллчек ru/en (undercurl вместо красного), автосохранение,
  сворачивание через treesitter, хоткеи работают в русской раскладке
  (langmap + Ctrl-маппинги), `:Hlp` — шпаргалка по хоткеям.

## Установка

1. Установить [vim-plug](https://github.com/junegunn/vim-plug), затем в nvim —
   `:PlugInstall`.
2. Внешние программы (при запуске nvim `deps_check` сам напишет, чего не
   хватает):

   ```sh
   brew install universal-ctags fzf fd ripgrep lazygit lazydocker node imagemagick plantuml
   brew install jorgerojas26/lazysql/lazysql
   npm install -g @anthropic-ai/claude-code
   pip install debugpy   # в venv проекта, для отладки
   ```

3. Словари спеллчека:

   ```sh
   mkdir -p ~/.local/share/nvim/site/spell
   cd ~/.local/share/nvim/site/spell
   curl -k -O https://ftp.vim.org/pub/vim/runtime/spell/en.utf-8.spl
   curl -k -O https://ftp.vim.org/pub/vim/runtime/spell/en.utf-8.sug
   curl -k -O https://ftp.vim.org/pub/vim/runtime/spell/ru.utf-8.spl
   curl -k -O https://ftp.vim.org/pub/vim/runtime/spell/ru.utf-8.sug
   ```

4. Настройки проекта — файл `nvim_settings.ini` в корне проекта (секции
   `[env]` и `[tree_colors]`): `VIRTUAL_ENV`, `PYTHONPATH`, `TESTRUNNER`
   (unittest/pytest) и цвета папок дерева. Примеры переменных — в
   `env.example`. При старте nvim печатает гайд по окружению.

Стиль lua-кода конфига — stylua (`stylua.toml`), проверка:
`stylua --check lua/`.

## TODO

- [ ] Работа нескольких гитов в одном проекте: автообновление одной ветки у всех проектов
- [x] Гуй к гиту — lazygit, merginal, gitsigns, fugitive
- [x] Количество пробелов при нажатии Enter внутри скобок — nvim-autopairs (`check_ts`)
- [x] Работа хоткеев при русской раскладке — langmap + Ctrl-маппинги кириллицы
- [x] Разнести настройки всех модулей на отдельные файлы — `vim/` и `lua/plugins/`
- [ ] Добавить проверку flake8/ruff для python
- [ ] Проблема с количеством отступов не в python-файлах
- [ ] Автоматическое форматирование кода в редакторе (для самого конфига есть stylua)
- [x] Спеллчекер русского и английского — `spell`, словари см. «Установка»
- [x] Ошибки языка подчёркивать, а не красить в красный — SpellBad undercurl
- [x] Неиспользуемые переменные — серые (pyright, DiagnosticUnnecessary)
- [x] Красить линии в nvim-tree — раскраска папок из `nvim_settings.ini`
- [x] Разноцветные переменные — локальный модуль markid
- [x] Медленный поиск по большому проекту — telescope + fzy-native, fd/ripgrep
