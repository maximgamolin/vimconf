-- Автодополнение: nvim-cmp, сниппеты (LuaSnip), сигнатуры функций, cmp-ai

-- Сигнатура функций
require('lsp_signature').setup({
  bind = true, -- Это обязательная настройка, позволяет управлять плавающим окном
  hint_enable = false, -- Если true, включает подсказки в строке состояния
  floating_window = true, -- Использовать плавающее окно для отображения информации
  floating_window_above_cur_line = true, -- Плавающее окно над текущей строкой
  doc_lines = 10, -- Количество строк документации, отображаемой в плавающем окне
  max_height = 12, -- Максимальная высота плавающего окна
  max_width = 120, -- Максимальная ширина плавающего окна
  handler_opts = {
    border = 'rounded', -- Опции для рамки: "single", "double", "rounded", "solid", "shadow"
  },
  extra_trigger_chars = { '(', ',' }, -- Символы, вызывающие информацию о параметрах функции
})

-- Загрузка кастомных снипетов
require('luasnip.loaders.from_lua').load({ paths = '~/.config/nvim/lua/snippets/' })

local cmp = require('cmp')
local lspkind = require('lspkind') -- Красивые шрифты

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm(),
    ['<Down>'] = cmp.mapping.select_next_item(),
    ['<Up>'] = cmp.mapping.select_prev_item(),
    ['<Right>'] = cmp.mapping.scroll_docs(4),
    ['<C-a>'] = cmp.mapping(
      cmp.mapping.complete({
        config = {
          sources = cmp.config.sources({
            { name = 'cmp_ai' },
          }),
        },
      }),
      { 'i' }
    ),
  },
  sources = cmp.config.sources({
    -- { name = 'cmp_ai' },
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol', -- показывать только значок вида дополнения
      maxwidth = 50, -- не показывать в попапе больше 50 символов
      ellipsis_char = '...', -- чем заканчивать обрезанный по maxwidth текст
      show_labelDetails = true, -- показывать labelDetails в меню
      -- Вызывается до модификаций lspkind — даёт контроль над содержимым попапа
      before = function(entry, vim_item)
        -- Оборачиваем функции и классы в круглые скобки
        if vim.tbl_contains({ 'Function', 'Method' }, vim_item.kind) then
          vim_item.abbr = vim_item.abbr .. '()'
        end
        -- Это нужно будет включить, если найду небольшую нейронку:
        -- пометка источника ([LSP]/[AI]/[Buffer]) и процент уверенности от cmp_ai,
        -- см. историю init.vim
        return vim_item
      end,
    }),
  },
})

-- Автодополнения от нейронки (пока не работает)
require('cmp_ai.config'):setup({
  max_lines = 100,
  provider = 'Ollama',
  provider_options = {
    -- model = 'codegemma:latest',
    -- model = 'deepseek-coder-v2:latest',
    model = 'codellama:7b-code',
  },
  notify = true,
  notify_callback = function(msg)
    vim.notify(msg)
  end,
  run_on_every_keystroke = true,
  ignored_file_types = {
    -- по умолчанию ничего не игнорируется
    -- раскомментировать, чтобы игнорировать lua:
    -- lua = true
  },
})

-- Вывод всех загруженных сниппетов при старте
local ls = require('luasnip')
for ft, snips in pairs(ls.snippets) do
  print('Язык: ' .. ft)
  for _, snip in ipairs(snips) do
    print('  Сниппет: ' .. (snip.trigger or snip.name))
  end
end
