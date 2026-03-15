;; extends

;; Именованные аргументы при вызове — ТОЛЬКО имя ключа (name:), не значение
((call
  (argument_list
    (keyword_argument
        name: (identifier) @call.arg.parameter)))
 (#set! @call.arg.parameter "priority" 210))

;; Подсветка магических методов класса
(class_definition
  body: (block
          (function_definition
            name: (identifier) @doubledash.method (#match? @doubledash.method "^__.*__$")))
  (#set! @doubledash.method "priority" 210))

;; Подсветка декораторов
(decorated_definition
  (decorator
    (call
      function: (identifier) @decorator.call))
 (#set! @decorator.call "priority" 210))

;; Подсветка self
((identifier) @parameter.self
 (#eq? @parameter.self "self")
 (#set! @parameter.self "priority" 210))

;; Подсветка cls
((identifier) @parameter.cls
 (#eq? @parameter.cls "cls")
 (#set! @parameter.cls "priority" 210))

;; Имена функций в объявлениях
(function_definition
  name: (identifier) @function
  (#set! @function "priority" 210))

;; Имена классов в объявлениях
(class_definition
  name: (identifier) @type
  (#set! @type "priority" 210))

;; Поля объектов (self.x, obj.name) — фиолетовый
(attribute
  attribute: (identifier) @variable.member
  (#set! @variable.member "priority" 210))

;; Вызовы методов (obj.method()) — серый, приоритет 220 перекрывает @variable.member (210)
(call
  function: (attribute
    attribute: (identifier) @function.method.call)
  (#set! @function.method.call "priority" 220))

;; None, True, False
([
  (true)
  (false)
  (none)
] @constant.builtin
(#set! @constant.builtin "priority" 210))
