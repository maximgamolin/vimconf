-- Настройка цветов для элементов Tree-sitter
-- Тема: Solarized Light - Hard Gray (4lex4) — перенесена из PyCharm .icls
local set_highlight = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

-- Настройка для различных языковых элементов.
set_highlight("@keyword",                {fg = "#859900", bg = "NONE"})              -- Ключевые слова (DEFAULT_KEYWORD)
set_highlight("@keyword.function",       {fg = "#859900", bg = "NONE"})              -- def
set_highlight("@keyword.return",         {fg = "#4F96b3", bg = "NONE"})              -- return
set_highlight("@keyword.import",         {fg = "#859900", bg = "NONE"})              -- import
set_highlight("@function",               {fg = "#d33682", bg = "NONE"})              -- Объявления функций (DEFAULT_FUNCTION_DECLARATION)
set_highlight("@function.method",        {fg = "#d33682", bg = "NONE"})              -- Объявления методов
set_highlight("@function.method.call",   {fg = "#586e76", bg = "NONE"})              -- Вызов методов объектов
set_highlight("@function.call",          {fg = "#586e76", bg = "NONE"})              -- Вызов простых функций
set_highlight("@variable",               {fg = "#586e76", bg = "NONE"})              -- Переменные (DEFAULT_IDENTIFIER)
set_highlight("@variable.builtin",       {fg = "#9e9200", bg = "NONE"})              -- Встроенные: len, print, range... (PY.BUILTIN_NAME)
set_highlight("@variable.member",        {fg = "#6c71c4", bg = "NONE"})              -- Поля объектов self.x (DEFAULT_INSTANCE_FIELD)
set_highlight("@call.arg.parameter",     {fg = "#a85ba3", bg = "NONE"})              -- Именованные параметры при вызове (PY.KEYWORD_ARGUMENT)
set_highlight("@string",                 {fg = "#2aa198", bg = "NONE"})              -- Строки (DEFAULT_STRING / PY.STRING)
set_highlight("@string.documentation",   {fg = "#88999b", bg = "NONE", italic=true}) -- Докстроки (DEFAULT_DOC_COMMENT)
set_highlight("@comment",                {fg = "#88999b", bg = "NONE", italic = true}) -- Комментарии (DEFAULT_LINE_COMMENT)
set_highlight("@constant",               {fg = "#6c71c4", bg = "NONE", italic=true}) -- Константы (DEFAULT_CONSTANT)
set_highlight("@constant.builtin",       {fg = "#809a00", bg = "NONE"})              -- None, True, False
set_highlight("@number",                 {fg = "#cb4b16", bg = "NONE"})              -- Числа (DEFAULT_NUMBER) — оранжево-красный
set_highlight("@parameter",              {fg = "#586e76", bg = "NONE"})              -- Параметры функции — как обычные идентификаторы
set_highlight("@constructor",            {fg = "#268bd2", bg = "NONE"})              -- Конструкторы (DEFAULT_CLASS_NAME)
set_highlight("@type",                   {fg = "#268bd2", bg = "NONE"})              -- Классы и типы (DEFAULT_CLASS_NAME)
-- Отдельный цвет для self, cls и doubledash методов параметров методов в Python
set_highlight("@parameter.self",         {fg = "#6c71c4", bg = "NONE", italic = true})  -- self (PY.SELF_PARAMETER)
set_highlight("@parameter.cls",          {fg = "#6c71c4", bg = "NONE", italic = true})  -- cls (PY.SELF_PARAMETER)
set_highlight("@doubledash.method",      {fg = "#268bd2", bg = "NONE"})              -- магические методы (PY.PREDEFINED_DEFINITION)
set_highlight("@decorator.call",         {fg = "#b58900", bg = "NONE"})              -- Декораторы (PY.DECORATOR)


-- Дополнительные настройки для улучшенного восприятия
set_highlight("Normal",          {fg = "#586e76", bg = "#fdf6e3"})   -- Общий текст (TEXT)
set_highlight("LineNr",          {fg = "#a3adab", bg = "#eee8d5"})   -- Номера строк (LINE_NUMBERS_COLOR)
set_highlight("CursorLineNr",    {fg = "#677d85", bg = "#eee8d5"})   -- Текущий номер строки (LINE_NUMBER_ON_CARET_ROW_COLOR)
set_highlight("Visual",          {fg = "#fdf6e3", bg = "#839496"})   -- Цвет выделения (SELECTION_BACKGROUND/FOREGROUND)
set_highlight("CursorLine",      {fg = "NONE",    bg = "#f3eddc"})   -- Текущая строка (CARET_ROW_COLOR)
