-- Настройки для NvimTree

-- require('plugins.nvimtreeplug.patch_build_nvim_tree')
-- empty setup using defaults

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true


require("nvim-tree").setup({
  on_attach = function(bufnr)
    local api = require('nvim-tree.api')
    api.config.mappings.default_on_attach(bufnr)
    vim.keymap.set('n', '<Space>', function()
      require('plugins.nvimtreeplug.context_menu').open()
    end, { buffer = bufnr, noremap = true, silent = true, desc = 'Контекстное меню файла' })
  end,
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
    number = true, -- Включить номера строк
  },
  renderer = {
    group_empty = true,
    indent_markers = {
      enable = true,  -- Показывать/скрывать маркеры отступов
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
