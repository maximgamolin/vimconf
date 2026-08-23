-- gitsigns.nvim — значки git-изменений у номеров строк (замена vim-signify),
-- inline-blame текущей строки (замена blamer.nvim) и работа с кусками (hunks).
-- Ещё это источник git-подсветки для карты кода (neominimap).

require('gitsigns').setup({
  -- Inline-blame как раньше у blamer: сразу, с префиксом ' > '
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 0,
    virt_text_pos = 'eol',
  },
  current_line_blame_formatter = ' > <author>, <author_time:%d.%m.%Y> • <summary>',

  on_attach = function(bufnr)
    local gs = require('gitsigns')
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- Переходы между изменениями (с fallback на diff-режим vim)
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({ ']c', bang = true })
      else
        gs.nav_hunk('next')
      end
    end, 'Git: следующее изменение')
    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({ '[c', bang = true })
      else
        gs.nav_hunk('prev')
      end
    end, 'Git: предыдущее изменение')

    -- Работа с куском (hunk) под курсором
    map('n', '<leader>hp', gs.preview_hunk, 'Git: показать diff куска')
    map('n', '<leader>hr', gs.reset_hunk, 'Git: откатить кусок (как в git)')
    map('n', '<leader>hs', gs.stage_hunk, 'Git: stage куска (повторно — unstage)')
    map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, 'Git: полный blame строки')
  end,
})

-- Цвет inline-blame — как был у blamer
vim.api.nvim_set_hl(0, 'GitSignsCurrentLineBlame', { fg = '#928374' })
