;; extends
;; Аргументы в вызове функции
((call
  (argument_list
    (keyword_argument
        (identifier) @call.arg.parameter))))
;; Подсветка магических методов класса
(class_definition
  body: (block
          (function_definition
            name: (identifier) @doubledash.method (#match? @doubledash.method "^__.*__$"))))

;; Подсветка декораторов
(decorated_definition
  (decorator
    (call
      function: (identifier) @decorator.call)))

((identifier) @parameter.self 
(#eq? @parameter.self "self"))

((identifier) @parameter.cls 
(#eq? @parameter.cls "cls"))

