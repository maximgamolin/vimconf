-- Telescope: поиск файлов и по содержимому проекта

require('telescope').setup({
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
    },
    file_ignore_patterns = { '%.pyc$', '__pycache__', 'venv', '^%.', '/%.' },
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
    path_display = { 'truncate' },
  },
})

-- fzy-нативный сортировщик (нужен и для поиска по коммитам)
require('telescope').load_extension('fzy_native')

-- Горячие клавиши
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>')
vim.keymap.set('n', '<M-F>', '<cmd>Telescope live_grep<cr>')

-- Поиск по содержимому с фильтром по расширению файлов
vim.keymap.set('n', '<C-S-f>', function()
  vim.ui.input({ prompt = 'Расширение файлов (*.py, *.lua, пусто = все): ' }, function(pattern)
    if pattern == nil then
      return
    end
    local opts = {}
    if pattern ~= '' then
      opts.glob_pattern = pattern
    end
    require('telescope.builtin').live_grep(opts)
  end)
end)
