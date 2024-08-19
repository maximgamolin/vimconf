-- Первым делом убедитесь, что nvim-tree уже загружен
require'nvim-tree'

-- Получить текущую реализацию build_folder
local original_build_folder = require'nvim-tree.view'.Builder.build_folder

-- Определите свою собственную версию build_folder
local function custom_build_folder(self, node)
  -- Ваша собственная логика здесь
  print("Custom build_folder called for node: " .. node.name)

  -- Вызываем оригинальную функцию, если хотите включить ее логику
  original_build_folder(self, node)

  -- Или заменяем ее полностью своей реализацией
  -- <ваша логика построения папки>
end

-- Переопределяем функцию
require'nvim-tree.view'.Builder.build_folder = custom_build_folder
