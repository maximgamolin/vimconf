-- Настройки для NvimTree

-- require('plugins.nvimtreeplug.patch_build_nvim_tree')
-- empty setup using defaults

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true


require("nvim-tree").setup({
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
    dotfiles = true,
  },
})
-- не могу нормально настроить цветовые отметки в дереве
-- require('plugins.nvimtreeplug.nvim_tree_colors')

require('plugins.nvimtreeplug.hotkeys')
