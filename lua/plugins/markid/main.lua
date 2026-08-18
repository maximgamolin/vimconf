-- Подсветка одинаковых идентификаторов одним цветом.
-- Локальная замена плагина David-Kunz/markid: он зависел от старого
-- фреймворка nvim-treesitter (nvim-treesitter.configs), которого нет на
-- ветке main. Логика портирована, работает на чистом vim.treesitter.

local ns = vim.api.nvim_create_namespace('markid')

-- Тёмные цвета под Solarized Light.
-- Не используются в синтаксисе: #859900(kw) #d33682(fn) #2aa198(str)
-- #b58900(param) #6c71c4(self) #268bd2(dunder) #657b83(var)
local colors = {
  '#8b2a50', -- тёмная малина
  '#1a6b5a', -- тёмный изумруд
  '#7a5000', -- тёмный янтарь
  '#4a2a8a', -- тёмный индиго
  '#3a6b10', -- тёмный оливковый
  '#1a4a8a', -- тёмный кобальт
  '#8c3800', -- тёмная бронза
}

local query_text = '((identifier) @markid (#not-eq? @markid "self") (#not-eq? @markid "cls"))'

-- markid ставит extmark на каждый идентификатор — на больших файлах тормозит скролл
local function is_big_file(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  local ok, stats = pcall(vim.uv.fs_stat, name)
  return (ok and stats and stats.size > 256 * 1024)
    or vim.api.nvim_buf_line_count(bufnr) > 8000
end

for i, color in ipairs(colors) do
  vim.api.nvim_set_hl(0, 'markid' .. i, { default = true, fg = color })
end

-- Один и тот же идентификатор всегда получает один и тот же цвет:
-- группа выбирается по сумме байтов имени (как в оригинальном markid)
local hl_group_of = {}
local function group_for(text)
  if not hl_group_of[text] then
    local sum = 0
    for i = 1, #text do
      sum = sum + text:byte(i)
    end
    hl_group_of[text] = 'markid' .. (sum % #colors + 1)
  end
  return hl_group_of[text]
end

local attached = {}

local function highlight_buf(bufnr, query, tree)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
    if query.captures[id] == 'markid' then
      local text = vim.treesitter.get_node_text(node, bufnr)
      if text and text ~= '' then
        local sr, sc, er, ec = node:range()
        vim.hl.range(bufnr, ns, group_for(text), { sr, sc }, { er, ec })
      end
    end
  end
end

local function attach(bufnr)
  if attached[bufnr] or is_big_file(bufnr) then
    return
  end
  local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok_parser or not parser then
    return
  end
  local ok_query, query = pcall(vim.treesitter.query.parse, parser:lang(), query_text)
  if not ok_query then
    return -- в языке нет узла (identifier)
  end
  attached[bufnr] = true

  local trees = parser:parse()
  if trees and trees[1] then
    highlight_buf(bufnr, query, trees[1])
  end
  parser:register_cbs({
    on_changedtree = function(_, tree)
      highlight_buf(bufnr, query, tree)
    end,
  })
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('markid', { clear = true }),
  callback = function(ev)
    attach(ev.buf)
  end,
})

vim.api.nvim_create_autocmd('BufUnload', {
  group = 'markid',
  callback = function(ev)
    attached[ev.buf] = nil
  end,
})
