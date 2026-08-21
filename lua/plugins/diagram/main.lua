-- Диаграммы PlantUML/Mermaid картинками прямо в markdown-буфере.
-- Связка: image.nvim выводит картинки по kitty graphics protocol,
-- diagram.nvim находит код-блоки ```plantuml / ```mermaid и рендерит их.
-- Требует: brew install imagemagick plantuml
-- и enable_kitty_graphics = true в конфиге WezTerm.

require('image').setup({
  backend = 'kitty', -- WezTerm понимает kitty graphics protocol
  processor = 'magick_cli', -- CLI ImageMagick, без luarocks-модуля magick
  -- по умолчанию картинка ограничена половиной высоты окна — разрешаем всю
  max_height_window_percentage = 100,
})

require('diagram').setup({
  integrations = {
    -- своя обёртка над штатной markdown-интеграцией: понимает ```puml как ```plantuml
    require('plugins.diagram.markdown_integration'),
  },
  renderers = {
    plantuml = {
      charset = 'utf-8', -- кириллица в диаграммах
    },
  },
})
