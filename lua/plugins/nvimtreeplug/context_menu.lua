local M = {}

-- Сохраняем узел до открытия quickui, чтобы action() мог его использовать
local _node = nil

function M.open()
  local api = require('nvim-tree.api')
  local node = api.tree.get_node_under_cursor()
  if not node or not node.absolute_path or node.type == 'directory' then
    return
  end

  _node = node

  local items = {
    { 'Открыть',                           "lua require('plugins.nvimtreeplug.context_menu').action('open')" },
    { 'Открыть в новой вкладке',           "lua require('plugins.nvimtreeplug.context_menu').action('tab')" },
    { 'Разделить экран и открыть',         "lua require('plugins.nvimtreeplug.context_menu').action('split')" },
    { '--', '' },
    { 'Скопировать название файла',        "lua require('plugins.nvimtreeplug.context_menu').action('copy_name')" },
    { 'Скопировать путь от корня проекта', "lua require('plugins.nvimtreeplug.context_menu').action('copy_rel')" },
    { 'Скопировать полный путь на диске',  "lua require('plugins.nvimtreeplug.context_menu').action('copy_abs')" },
    { '--', '' },
    { 'Добавить в гит',                    "lua require('plugins.nvimtreeplug.context_menu').action('git_add')" },
  }

  vim.fn['quickui#context#open'](items, vim.empty_dict())
end

function M.action(act)
  if not _node then return end
  local full_path = _node.absolute_path
  local filename = vim.fn.fnamemodify(full_path, ':t')
  local relative_path = vim.fn.fnamemodify(full_path, ':.')
  _node = nil

  local escaped = vim.fn.fnameescape(full_path)

  if act == 'open' then
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
  end
end

return M
