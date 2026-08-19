-- Декоратор nvim-tree: дата изменения и размер файла серым цветом после имени (как в PyCharm)

local enabled = true

local FileInfoDecorator = require('nvim-tree.api').Decorator:extend()

function FileInfoDecorator:new()
  self.enabled = true
  self.highlight_range = 'none'
  self.icon_placement = 'after'
end

-- Размер в человекочитаемом виде: 804 Б, 31,45 кБ, 2,33 МБ
local function fmt_size(size)
  if size < 1024 then
    return size .. ' Б'
  end
  local units = { 'кБ', 'МБ', 'ГБ', 'ТБ' }
  local s = size / 1024
  local i = 1
  while s >= 1024 and i < #units do
    s = s / 1024
    i = i + 1
  end
  local str = string.format('%.2f', s):gsub('%.', ',')
  return str .. ' ' .. units[i]
end

---@param node nvim_tree.api.Node
---@return nvim_tree.api.highlighted_string[]?
function FileInfoDecorator:icons(node)
  if not enabled then
    return nil
  end
  local stat = node.fs_stat
  if not stat or node.type == 'directory' then
    return nil
  end
  local text = '· ' .. os.date('%d.%m.%Y %H:%M', stat.mtime.sec) .. ', ' .. fmt_size(stat.size)
  return { { str = text, hl = { 'NvimTreeFileInfo' } } }
end

-- Переключить показ даты и размера
function FileInfoDecorator.toggle()
  enabled = not enabled
  require('nvim-tree.api').tree.reload()
end

-- Бледно-серый, заметно тусклее Comment; переживает смену колорсхемы
local function set_hl()
  local fg = vim.o.background == 'light' and '#c0bbae' or '#4a4f52'
  vim.api.nvim_set_hl(0, 'NvimTreeFileInfo', { fg = fg })
end
set_hl()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_hl })
vim.api.nvim_create_autocmd('OptionSet', { pattern = 'background', callback = set_hl })

return FileInfoDecorator
