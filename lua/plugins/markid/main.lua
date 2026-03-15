require'nvim-treesitter.configs'.setup {
  markid = {
    enable = true,
    -- Тёмные цвета под Solarized Light.
    -- Не используются в синтаксисе: #859900(kw) #d33682(fn) #2aa198(str)
    -- #b58900(param) #6c71c4(self) #268bd2(dunder) #657b83(var)
    colors = {
      '#8b2a50', -- тёмная малина
      '#1a6b5a', -- тёмный изумруд
      '#7a5000', -- тёмный янтарь
      '#4a2a8a', -- тёмный индиго
      '#3a6b10', -- тёмный оливковый
      '#1a4a8a', -- тёмный кобальт
      '#8c3800', -- тёмная бронза
    },
    queries = {
      default = '(identifier) @markid (#not-eq? @markid "self") (#not-eq? @markid "cls")',
    },
  },
}
