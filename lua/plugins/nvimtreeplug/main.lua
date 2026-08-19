-- Настройки для NvimTree

-- require('plugins.nvimtreeplug.patch_build_nvim_tree')
-- empty setup using defaults

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true


local FileInfoDecorator = require('plugins.nvimtreeplug.file_info_decorator')

require("nvim-tree").setup({
  on_attach = function(bufnr)
    local api = require('nvim-tree.api')
    api.config.mappings.default_on_attach(bufnr)
    vim.keymap.set('n', '<Space>', function()
      require('plugins.nvimtreeplug.context_menu').open()
    end, { buffer = bufnr, noremap = true, silent = true, desc = 'Контекстное меню файла' })
    -- Открытие узла одиночным кликом (по умолчанию нужен двойной клик).
    -- <LeftRelease>, а не <LeftMouse>: к моменту отпускания курсор уже
    -- переместился на строку, по которой кликнули.
    vim.keymap.set('n', '<LeftRelease>', api.node.open.edit,
      { buffer = bufnr, noremap = true, silent = true, desc = 'Открыть узел одним кликом' })
  end,
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 45,
    number = false, -- Не показывать номера строк
  },
  renderer = {
    group_empty = true,
    decorators = { "Git", "Open", "Hidden", "Modified", "Bookmark", "Diagnostics", "Copied", FileInfoDecorator, "Cut" },
    indent_markers = {
      enable = true,  -- Показывать/скрывать маркеры отступов
    },
    icons = {
      show = {
        file = true,         -- Иконки файлов по расширению (nvim-web-devicons)
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },
  filters = {
    dotfiles = false,
    custom = { '__pycache__' },
  },
})
-- не могу нормально настроить цветовые отметки в дереве
-- require('plugins.nvimtreeplug.nvim_tree_colors')

require('plugins.nvimtreeplug.hotkeys')
