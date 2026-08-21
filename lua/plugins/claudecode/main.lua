-- claudecode.nvim — интеграция с Claude Code CLI
-- Документация: https://github.com/coder/claudecode.nvim
-- Зависимость: folke/snacks.nvim (устанавливается через PlugInstall)

-- snacks.nvim нужен claudecode как зависимость для терминала
require('snacks').setup({
  terminal = { enabled = true },
  -- всё остальное отключаем чтобы не конфликтовало с существующими плагинами
  bigfile = { enabled = false },
  dashboard = { enabled = false },
  explorer = { enabled = false },
  indent = { enabled = false },
  input = { enabled = false },
  picker = { enabled = false },
  notifier = { enabled = false },
  quickfile = { enabled = false },
  scope = { enabled = false },
  scroll = { enabled = false },
  statuscolumn = { enabled = false },
  words = { enabled = false },
})

require('claudecode').setup()

-- Хоткеи (по аналогии с рекомендованными в README)
local map = function(lhs, rhs, desc, mode)
  vim.keymap.set(mode or 'n', lhs, rhs, { noremap = true, silent = true, desc = desc })
end

map('<leader>ac', '<cmd>ClaudeCode<cr>', 'Toggle Claude')
map('<leader>af', '<cmd>ClaudeCodeFocus<cr>', 'Focus Claude')
map('<leader>ar', '<cmd>ClaudeCode --resume<cr>', 'Resume Claude')
map('<leader>aC', '<cmd>ClaudeCode --continue<cr>', 'Continue Claude')
map('<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', 'Add current buffer to Claude')
map('<leader>as', '<cmd>ClaudeCodeSend<cr>', 'Send selection to Claude', 'v')
map('<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', 'Accept diff')
map('<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', 'Deny diff')
