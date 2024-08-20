-- Настройка цветов для элементов Tree-sitter
local set_highlight = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

-- Настройка для различных языковых элементов.
set_highlight("@keyword", {fg = "#859900", bg = "NONE"})  -- Ключевые слова
set_highlight("@keyword.function", {fg = "#859900", bg = "NONE"})  -- def
set_highlight("@keyword.return", {fg = "#4F96b3", bg = "NONE"})  -- return
set_highlight("@keyword.import", {fg = "#859900", bg = "NONE"})  -- import
set_highlight("@function", {fg = "#d33682", bg = "NONE"})  -- Функции
set_highlight("@function.method", {fg = "#d33682", bg = "NONE"})  -- Методы
set_highlight("@function.method.call", {fg = "#657b83", bg = "NONE"})  -- Вызщов функций объектов
set_highlight("@function.call", {fg = "#657b83", bg = "NONE"})  -- Вызов простых функций
set_highlight("@variable", {fg = "#657b83", bg = "NONE"})  -- Переменные
set_highlight("@variable.builtin", {fg = "#657b83", bg = "NONE"})  -- Встроенные переменные
set_highlight("@variable.member", {fg = "#657b83", bg = "NONE"})  -- Члены переменных (например, поля объектов)
set_highlight("@call.arg.parameter", {fg = "#a85ba3", bg = "NONE"})  -- Именованные параметры при вызове функции
set_highlight("@string", {fg = "#2aa198", bg = "NONE"})  -- Строки
set_highlight("@string.documentation", {fg = "#93a1a1", bg = "NONE"})  -- Многостраничная документация
set_highlight("@comment", {fg = "#93a1a1", bg = "NONE", italic = true})  -- Комментарии
set_highlight("@constant", {fg = "#657b83", bg = "NONE"})  -- Константы
set_highlight("@number", {fg = "#d33682", bg = "NONE"})  -- Числа
set_highlight("@parameter", {fg = "#b58900", bg = "NONE"})  -- Параметры функции
set_highlight("@constructor", {fg = "#657b83", bg = "NONE"})  -- Конструкторы, и __init__ и инициализация класа
set_highlight("@type", {fg = "#657b83", bg = "NONE"})  -- Типы данных в том числе определения классов
-- Отдельный цвет для self, cls и doubledash методов параметров методов в Python
set_highlight("@parameter.self", {fg = "#6c71c4", bg = "NONE", italic = true})  -- self (фиолетовый)
set_highlight("@parameter.cls", {fg = "#d33682", bg = "NONE", italic = true})  -- cls (розовый италик)
set_highlight("@doubledash.method", {fg = "#268bd2", bg = "NONE"})  -- машические методы
set_highlight("@decorator.call", {fg = "#b58900", bg = "NONE"})  -- Вызов декоратора


-- Дополнительные настройки для улучшенного восприятия
set_highlight("Normal", {fg = "#586e75", bg = "#fdf6e3"})  -- Общий текст
set_highlight("LineNr", {fg = "#93a1a1", bg = "#eee8d5"})  -- Номера строк
set_highlight("CursorLineNr", {fg = "#586e75", bg = "#eee8d5"})  -- Текущий номер строки
set_highlight("Visual", {fg="#fdf6e5", bg = "#869496"})  -- Цвет выделения

