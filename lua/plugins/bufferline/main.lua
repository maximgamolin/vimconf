-- Вкладки сверху (bufferline) + контекстное меню вкладок

require('bufferline').setup({
  options = {
    -- левая кнопка — переключить вкладку в том окне, по чьим вкладкам кликнули
    left_mouse_command = function(buf)
      require('plugins.tab_context_menu').switch(buf)
    end,
    -- крестик на вкладке — закрытие без разрушения раскладки (см. M.close),
    -- вместо дефолтного «bdelete! %d», который закрывает окно
    close_command = function(buf)
      require('plugins.tab_context_menu').close(buf)
    end,
    -- правая кнопка по вкладке — контекстное меню quickui вместо bdelete по умолчанию
    right_mouse_command = function(buf)
      require('plugins.tab_context_menu').open(buf)
    end,
  },
})

-- Кнопка «≡» на вкладках, открывающая то же меню по левому клику
require('plugins.tab_context_menu').setup_button()
