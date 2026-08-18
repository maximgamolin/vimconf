-- Рендер markdown прямо в буфере (заголовки, таблицы, чекбоксы, код-блоки)
require('render-markdown').setup({
  -- Рендерить в normal-режиме, в insert показывать исходный текст строки
  render_modes = { 'n', 'c', 't' },
  heading = {
    -- Иконки заголовков (требуют nerd font, уже используется для devicons)
    sign = false, -- не дублировать значок в колонке знаков
  },
  code = {
    sign = false,
    width = 'block', -- фон код-блока по ширине содержимого
  },
})
