-- Контекстное меню вкладки буфера (bufferline): открывается по правой
-- кнопке мыши на вкладке, действия применяются к кликнутому буферу.
local M = {}

-- Сохраняем буфер и окно до открытия quickui, чтобы action() мог их использовать
local _buf = nil
local _win = nil

-- Окно «с вкладками» — обычное файловое окно, в чьём winbar рисуется bufferline
-- (тот же критерий, что и в menu_tabline.update_winbar).
local function is_tab_window(win)
  if vim.api.nvim_win_get_config(win).relative ~= '' then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  return vim.bo[buf].buftype == '' and vim.bo[buf].buflisted
end

-- Закрытие последней вкладки в единственном окне с вкладками оставило бы пустой
-- буфер и ломало раскладку. Блокируем такой случай. При наличии сплитов защита
-- не действует — там есть куда «переехать» оставшемуся буферу.
local function is_last_tab()
  local tab_windows = 0
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_tab_window(w) then
      tab_windows = tab_windows + 1
      if tab_windows > 1 then
        return false
      end
    end
  end
  local listed = 0
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buflisted then
      listed = listed + 1
      if listed > 1 then
        return false
      end
    end
  end
  return true
end

-- Соседняя вкладка, на которую переключимся вместо закрываемой: следующий
-- buflisted-буфер (как переключение вкладки вперёд), иначе предыдущий.
local function pick_replacement(bufnr)
  local listed = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buflisted then
      table.insert(listed, b)
    end
  end
  local idx
  for i, b in ipairs(listed) do
    if b == bufnr then
      idx = i
      break
    end
  end
  if not idx then
    return listed[1] ~= bufnr and listed[1] or nil
  end
  return listed[idx + 1] or listed[idx - 1]
end

-- Закрытие вкладки. Используется и крестиком на вкладке (close_command в
-- bufferline.setup), и пунктом меню «Закрыть».
--
-- Нельзя просто `bdelete`: если буфер показан в окне, а рядом есть другое окно
-- (например, сплит-терминал), Neovim закрывает само окно — раскладка ломается,
-- терминал разворачивается на весь экран. Поэтому сначала переключаем все окна
-- с этим буфером на соседнюю вкладку и только потом удаляем буфер — окна и
-- сплиты остаются на месте.
function M.close(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  if is_last_tab() then
    vim.notify('Нельзя закрыть последнюю вкладку', vim.log.levels.WARN)
    return
  end
  local repl = pick_replacement(bufnr)
  if repl then
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_buf(w) == bufnr then
        vim.api.nvim_win_set_buf(w, repl)
      end
    end
  end
  pcall(vim.cmd, 'bdelete ' .. bufnr)
end

function M.open(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local mp = vim.fn.getmousepos()
  _buf = bufnr
  -- окно, по чьей winbar кликнули — в нём будем открывать буфер
  _win = mp.winid ~= 0 and mp.winid or vim.api.nvim_get_current_win()

  local items = {
    { 'Перейти', "lua require('plugins.tab_context_menu').action('goto')" },
    {
      'Разделить по горизонтали',
      "lua require('plugins.tab_context_menu').action('split_h')",
    },
    {
      'Разделить по вертикали',
      "lua require('plugins.tab_context_menu').action('split_v')",
    },
    { '--', '' },
    { 'Закрыть', "lua require('plugins.tab_context_menu').action('close')" },
    {
      'Закрыть остальные',
      "lua require('plugins.tab_context_menu').action('close_others')",
    },
    { '--', '' },
    {
      'Скопировать название файла',
      "lua require('plugins.tab_context_menu').action('copy_name')",
    },
    {
      'Скопировать путь от корня проекта',
      "lua require('plugins.tab_context_menu').action('copy_rel')",
    },
    {
      'Скопировать полный путь на диске',
      "lua require('plugins.tab_context_menu').action('copy_abs')",
    },
  }

  -- открываем меню под кликнутой вкладкой, а не у текстового курсора
  vim.fn['quickui#context#open'](items, { line = mp.screenrow + 1, col = mp.screencol })
end

-- Если вкладка была открыта в исходном окне — показать там другой буфер,
-- чтобы при разделении она именно «переехала» в новый сплит, а не задублировалась
local function detach_from(win, buf)
  if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
    return
  end
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if b ~= buf and vim.bo[b].buflisted then
      vim.api.nvim_win_set_buf(win, b)
      return
    end
  end
end

function M.action(act)
  local buf, win = _buf, _win
  _buf, _win = nil, nil
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  if not (win and vim.api.nvim_win_is_valid(win)) then
    win = vim.api.nvim_get_current_win()
  end

  local full_path = vim.api.nvim_buf_get_name(buf)
  local filename = vim.fn.fnamemodify(full_path, ':t')
  local relative_path = vim.fn.fnamemodify(full_path, ':.')

  if act == 'goto' then
    vim.api.nvim_set_current_win(win)
    vim.api.nvim_win_set_buf(win, buf)
  elseif act == 'split_h' then
    -- новый сплит снизу, вкладка переносится в него
    vim.api.nvim_set_current_win(win)
    vim.cmd('belowright split')
    vim.api.nvim_win_set_buf(0, buf)
    detach_from(win, buf)
  elseif act == 'split_v' then
    -- новый сплит справа, вкладка переносится в него
    vim.api.nvim_set_current_win(win)
    vim.cmd('belowright vsplit')
    vim.api.nvim_win_set_buf(0, buf)
    detach_from(win, buf)
  elseif act == 'close' then
    M.close(buf)
  elseif act == 'close_others' then
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if b ~= buf and vim.bo[b].buflisted then
        M.close(b)
      end
    end
  elseif act == 'copy_name' then
    vim.fn.setreg('+', filename)
    vim.notify('Скопировано: ' .. filename)
  elseif act == 'copy_rel' then
    vim.fn.setreg('+', relative_path)
    vim.notify('Скопировано: ' .. relative_path)
  elseif act == 'copy_abs' then
    vim.fn.setreg('+', full_path)
    vim.notify('Скопировано: ' .. full_path)
  end
end

-- Переключение вкладки по левому клику. Вкладки отрисованы в winbar каждого
-- окна, но стандартный обработчик bufferline делает «:buffer N» в текущем
-- окне — клик по вкладкам соседнего окна менял буфер не там, где кликнули.
-- Поэтому переключаем буфер в окне под курсором мыши (и фокусируем его).
function M.switch(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  local win = vim.fn.getmousepos().winid
  if win == 0 or not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_config(win).relative ~= '' then
    win = vim.api.nvim_get_current_win()
  end
  vim.api.nvim_set_current_win(win)
  vim.api.nvim_win_set_buf(win, bufnr)
end

-- Кнопка «≡» на каждой вкладке рядом с крестиком: по клику открывает то же
-- контекстное меню. Штатного API для своих кнопок у bufferline нет, поэтому
-- оборачиваем сборку вкладки (ui.element) и вставляем кликабельный сегмент.
function M.setup_button()
  _G.TabMenuButtonClick = function(id, _, button)
    if button == 'l' then
      M.open(id)
    end
  end

  local ui = require('bufferline.ui')
  local orig_element = ui.element
  ui.element = function(state, element)
    element = orig_element(state, element)
    local render = element.component
    element.component = function(next_item)
      local segments = render(next_item)
      local btn = {
        text = '≡',
        attr = {
          prefix = ('%%%d@v:lua.TabMenuButtonClick@'):format(element.id),
          suffix = '%X',
        },
      }
      -- ставим слева от крестика (его сегмент кликает handle_close);
      -- если крестика нет (буфер изменён — вместо него ●), то в конец вкладки
      local pos = #segments
      for i, s in ipairs(segments) do
        local prefix = s.attr and s.attr.prefix
        if prefix and prefix:find('handle_close', 1, true) then
          pos = i
          btn.highlight = s.highlight
          break
        end
      end
      table.insert(segments, pos, { text = ' ', highlight = btn.highlight })
      table.insert(segments, pos, btn)
      return segments
    end
    element.length = element.length + 2 -- «≡» и пробел после него
    return element
  end
end

return M
