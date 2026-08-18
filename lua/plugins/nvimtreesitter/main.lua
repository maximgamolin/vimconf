-- Настройки для treesitter (ветка main — новый API без nvim-treesitter.configs)

-- Отключаем тяжёлую подсветку на больших файлах, иначе скролл дёргается
local function is_big_file(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  local ok, stats = pcall(vim.uv.fs_stat, name)
  return (ok and stats and stats.size > 256 * 1024)
    or vim.api.nvim_buf_line_count(bufnr) > 8000
end

-- Установка парсеров (аналог ensure_installed из старого API):
-- вызов асинхронный, уже установленные пропускает
require('nvim-treesitter').install({ 'python', 'markdown', 'markdown_inline' })

-- На ветке main подсветка не включается сама — включаем её на каждый буфер,
-- для которого есть парсер (vim.treesitter.start кидает ошибку, если парсера
-- нет — pcall её глушит). Легаси-синтаксис nvim отключает автоматически.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter_highlight', { clear = true }),
  callback = function(ev)
    if not is_big_file(ev.buf) then
      pcall(vim.treesitter.start, ev.buf)
    end
  end,
})

-- Кастомные captures (@parameter.self, @doubledash.method и т.д.) приходят из
-- queries/python/highlights.scm, а их цвета — из lua/style/treesitter.lua;
-- на ветке main это работает без настройки custom_captures.
