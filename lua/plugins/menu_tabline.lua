-- Строка меню quickui, постоянно видимая в самом верху экрана (в tabline),
-- вкладки bufferline при этом переезжают строкой ниже (в winbar файловых окон).
--
-- Статичная строка повторяет вид панели quickui (те же отступы и цвета),
-- поэтому при активации (клик или Space+Space) настоящее меню quickui
-- отрисовывается ровно поверх неё — выглядит как «меню раскрылось».
local M = {}

-- Цвета quickui под Solarized Light. Перекрываем группы QuickDefault*,
-- на которые ссылаются QuickBG/QuickSel/QuickKey и т.д.
-- Важно: у всех групп задан фон — без него в tabline подставляется
-- светлый фон по умолчанию (из-за этого буквы-хоткеи выглядели пятнами).
local function apply_colors()
  local set = vim.api.nvim_set_hl
  set(0, 'QuickDefaultBackground', { fg = '#586e75', bg = '#eee8d5' }) -- полоса меню и фон списков
  set(0, 'QuickDefaultSel', { fg = '#073642', bg = '#fdf6e3', bold = true }) -- активный пункт — светлый
  set(0, 'QuickDefaultKey', { fg = '#cb4b16', bg = '#eee8d5' }) -- буква-хоткей
  set(0, 'QuickDefaultDisable', { fg = '#93a1a1', bg = '#eee8d5' }) -- недоступные пункты
  set(0, 'QuickDefaultHelp', { fg = '#839496', bg = '#eee8d5' }) -- подсказки справа
  set(0, 'QuickDefaultBorder', { fg = '#93a1a1', bg = '#eee8d5' })
  set(0, 'MenuBarSep', { fg = '#b8b09c', bg = '#eee8d5' }) -- разделители в строке меню
end

local cached_line

local function build_line()
  local names = vim.fn['quickui#menu#available']('system')
  local show_key = vim.fn.hlexists('QuickKey') == 1
  local parts = { '%#QuickBG#' }
  for i, name in ipairs(names) do
    local esc = vim.fn['quickui#core#escape'](name)
    local text, pos = esc[1], esc[5]
    local title = text
    if show_key and pos and pos >= 0 then
      -- подсвечиваем букву-хоткей, как это делает сам quickui
      title = text:sub(1, pos) .. '%#QuickKey#' .. text:sub(pos + 1, pos + 1) .. '%#QuickBG#' .. text:sub(pos + 2)
    end
    -- кликабельная зона: клик передаёт номер раздела в MenuTablineClick
    table.insert(parts, ('%%%d@v:lua.MenuTablineClick@ %s %%X'):format(i, title))
    if i < #names then
      -- разделитель занимает те же 2 колонки, что и зазор в открытом
      -- quickui-меню, поэтому заголовки не съезжают при активации
      table.insert(parts, '%#MenuBarSep#│%#QuickBG# ')
    end
  end
  return table.concat(parts)
end

function _G.MenuTablineRender()
  if not cached_line then
    local ok, line = pcall(build_line)
    if not ok then
      return ''
    end
    cached_line = line
  end
  return cached_line
end

function _G.MenuTablineClick(idx, _, button, _)
  if button ~= 'l' then
    return
  end
  -- Открываем настоящее меню quickui и переводим выделение на кликнутый
  -- раздел: PageUp — на первый, Right — вправо, Down — раскрыть список.
  -- Клавиши кладём в typeahead заранее — open() блокируется до закрытия меню.
  local keys = '<PageUp>' .. string.rep('<Right>', idx - 1) .. '<Down>'
  vim.fn.feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n')
  vim.fn['quickui#menu#open']()
end

-- Вкладки bufferline — в winbar обычных файловых окон (строкой ниже меню)
local WINBAR = '%{%v:lua.nvim_bufferline()%}'

local function update_winbar(win)
  win = win or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_config(win).relative ~= '' then
    return
  end
  local buf = vim.api.nvim_win_get_buf(win)
  -- Буфер картинки перехвачен image.nvim: тот ставит buftype=nowrite, но это
  -- обычный открытый файл — вкладки в его окне нужны, как и в остальных
  local is_image = vim.bo[buf].filetype == 'image_nvim'
  local want = (vim.bo[buf].buftype == '' or is_image) and vim.bo[buf].buflisted
  if want then
    pcall(vim.api.nvim_set_option_value, 'winbar', WINBAR, { win = win })
    if is_image then
      -- Перерисовка окна (появление winbar, смена вкладки) стирает kitty-графику
      -- в терминале, а image.nvim пропускает повторный render() при неизменной
      -- геометрии («skipping render») — картинка остаётся невидимой. Ждём, пока
      -- редроу закончится, и принудительно перепосылаем: clear(true) сбрасывает
      -- rendered_geometry, поэтому render() передаёт пиксели заново.
      vim.defer_fn(function()
        local ok, image = pcall(require, 'image')
        if not ok or not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
          return
        end
        for _, img in ipairs(image.get_images({ window = win })) do
          pcall(function()
            img:clear(true)
            img:render()
          end)
        end
      end, 120)
    end
    return
  end
  -- В не-файловых окнах убираем только СВОЙ winbar (вкладки bufferline), а
  -- чужой оставляем нетронутым — иначе затираем кнопки управления floaterm,
  -- которые тот ставит в winbar своего окна (см. plugins/vimfloaterm/hotkeys).
  local ok, cur = pcall(vim.api.nvim_get_option_value, 'winbar', { win = win })
  if ok and cur == WINBAR then
    pcall(vim.api.nvim_set_option_value, 'winbar', '', { win = win })
  end
end

function M.setup()
  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function()
      -- перекрываем tabline, который выставил bufferline.setup()
      vim.o.showtabline = 2
      vim.o.tabline = '%!v:lua.MenuTablineRender()'
      for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        update_winbar(w)
      end
      apply_colors()
      -- регистрируем здесь (после загрузки quickui), чтобы наш autocmd
      -- срабатывал ПОСЛЕ QuickThemeChange самого quickui и перекрывал его
      vim.api.nvim_create_autocmd('ColorScheme', { callback = apply_colors })
    end,
  })

  vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter', 'TermOpen' }, {
    callback = function()
      update_winbar()
    end,
  })

  -- image.nvim перехватывает png/jpg после BufWinEnter (ставит buftype=nowrite
  -- и filetype=image_nvim) — переустанавливаем winbar, когда это произошло
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'image_nvim',
    callback = function()
      update_winbar()
    end,
  })
end

return M
