local M = {}

-- Сохраняем узел до открытия quickui, чтобы action() мог его использовать
local _node = nil

function M.open()
  local api = require('nvim-tree.api')
  local node = api.tree.get_node_under_cursor()
  if not node or not node.absolute_path then
    return
  end

  _node = node

  local hl = require('plugins.nvimtreeplug.dir_highlight')
  local color_items = { { '--', '' } }
  for _, c in ipairs(hl.get_colors()) do
    table.insert(color_items, {
      'Выделить: ' .. c.label,
      "lua require('plugins.nvimtreeplug.dir_highlight').mark('" .. c.key .. "')",
    })
  end
  table.insert(color_items, { 'Снять выделение',      "lua require('plugins.nvimtreeplug.dir_highlight').clear_node()" })
  table.insert(color_items, { 'Снять все выделения',  "lua require('plugins.nvimtreeplug.dir_highlight').clear_all()" })

  local create_items = {
    { '--', '' },
    { 'Создать файл',  "lua require('plugins.nvimtreeplug.context_menu').action('create_file')" },
    { 'Создать папку', "lua require('plugins.nvimtreeplug.context_menu').action('create_dir')" },
  }

  local items
  if node.type == 'directory' then
    items = {}
    for _, v in ipairs(color_items) do table.insert(items, v) end
    for _, v in ipairs(create_items) do table.insert(items, v) end
  else
    items = {
      { 'Открыть',                           "lua require('plugins.nvimtreeplug.context_menu').action('open')" },
      { 'Открыть в новой вкладке',           "lua require('plugins.nvimtreeplug.context_menu').action('tab')" },
      { 'Разделить экран и открыть',         "lua require('plugins.nvimtreeplug.context_menu').action('split')" },
      { '--', '' },
      { 'Скопировать название файла',        "lua require('plugins.nvimtreeplug.context_menu').action('copy_name')" },
      { 'Скопировать путь от корня проекта', "lua require('plugins.nvimtreeplug.context_menu').action('copy_rel')" },
      { 'Скопировать полный путь на диске',  "lua require('plugins.nvimtreeplug.context_menu').action('copy_abs')" },
      { '--', '' },
      { 'Добавить в гит',                    "lua require('plugins.nvimtreeplug.context_menu').action('git_add')" },
      { 'Частично добавить в гит',           "lua require('plugins.nvimtreeplug.context_menu').action('git_add_patch')" },
    }
    for _, v in ipairs(color_items) do table.insert(items, v) end
    for _, v in ipairs(create_items) do table.insert(items, v) end
  end

  vim.fn['quickui#context#open'](items, vim.empty_dict())
end

function M.action(act)
  if not _node then return end
  local full_path = _node.absolute_path
  local node_type = _node.type
  local filename = vim.fn.fnamemodify(full_path, ':t')
  local relative_path = vim.fn.fnamemodify(full_path, ':.')
  _node = nil

  local escaped = vim.fn.fnameescape(full_path)

  -- Базовая директория: для папки — сама папка, для файла — её родитель
  local base_dir = node_type == 'directory' and full_path or vim.fn.fnamemodify(full_path, ':h')

  if act == 'create_file' then
    local name = vim.fn.input('Имя файла: ', '', 'file')
    if name == '' then return end
    local target = base_dir .. '/' .. name
    local parent = vim.fn.fnamemodify(target, ':h')
    vim.fn.mkdir(parent, 'p')
    -- Создаём файл если не существует
    if vim.fn.filereadable(target) == 0 then
      local f = io.open(target, 'w')
      if f then f:close() end
    end
    require('nvim-tree.api').tree.reload()
    vim.notify('Создан файл: ' .. target)
    return
  elseif act == 'create_dir' then
    local name = vim.fn.input('Имя папки: ', '', 'file')
    if name == '' then return end
    local target = base_dir .. '/' .. name
    vim.fn.mkdir(target, 'p')
    require('nvim-tree.api').tree.reload()
    vim.notify('Создана папка: ' .. target)
    return
  elseif act == 'open' then
    vim.cmd('wincmd l')
    vim.cmd('edit ' .. escaped)
  elseif act == 'tab' then
    vim.cmd('tabedit ' .. escaped)
  elseif act == 'split' then
    vim.cmd('wincmd l')
    vim.cmd('vsplit ' .. escaped)
  elseif act == 'copy_name' then
    vim.fn.setreg('+', filename)
    vim.notify('Скопировано: ' .. filename)
  elseif act == 'copy_rel' then
    vim.fn.setreg('+', relative_path)
    vim.notify('Скопировано: ' .. relative_path)
  elseif act == 'copy_abs' then
    vim.fn.setreg('+', full_path)
    vim.notify('Скопировано: ' .. full_path)
  elseif act == 'git_add' then
    local result = vim.fn.system('git add ' .. vim.fn.shellescape(full_path))
    if vim.v.shell_error == 0 then
      vim.notify('git add: ' .. filename)
    else
      vim.notify('Ошибка: ' .. result, vim.log.levels.ERROR)
    end
  elseif act == 'git_add_patch' then
    -- Открываем git add -p в плавающем терминале, после закрытия — reload дерева
    vim.cmd(
      'FloatermNew --width=0.85 --height=0.85 --title=git\\ add\\ -p --autoclose=1 ' ..
      'git -c color.ui=always add -p ' .. vim.fn.shellescape(full_path)
    )
    -- Обновляем дерево когда floaterm закроется
    vim.api.nvim_create_autocmd('User', {
      pattern = 'FloatermClose',
      once = true,
      callback = function()
        require('nvim-tree.api').tree.reload()
      end,
    })
  end
end

return M
