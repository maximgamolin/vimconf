-- Выпадающие списки для выбора веток и коммитов: telescope dropdown
-- (набор текста фильтрует список, стрелки/C-j/C-k — прокрутка);
-- без telescope — fallback на vim.ui.select.
local M = {}

-- Общий выпадающий список. cb(выбранная_строка, её_индекс_в_items)
function M.select(title, items, cb)
  local ok = pcall(require, 'telescope.pickers')
  if not ok then
    vim.ui.select(items, { prompt = title }, function(choice, idx)
      if choice then
        cb(choice, idx)
      end
    end)
    return
  end
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local themes = require('telescope.themes')
  pickers
    .new(themes.get_dropdown({ previewer = false }), {
      prompt_title = title,
      finder = finders.new_table({ results = items }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(bufnr)
          if entry then
            cb(entry[1], entry.index)
          end
        end)
        return true
      end,
    })
    :find()
end

-- Список веток репозитория (без origin/HEAD)
function M.branches(root)
  local res = vim.system({ 'git', 'branch', '--all', '--format=%(refname:short)' }, { cwd = root, text = true }):wait()
  local out = {}
  if res.code == 0 then
    for _, b in ipairs(vim.split(vim.trim(res.stdout or ''), '\n', { trimempty = true })) do
      if b ~= '' and not b:match('^origin/HEAD') then
        out[#out + 1] = b
      end
    end
  end
  return out
end

-- Выбрать коммит ветки: первый пункт — вершина, дальше последние 100 коммитов.
-- cb(rev) — имя ветки (вершина) или короткий hash
function M.commit(root, branch, title, cb)
  local res = vim.system({ 'git', 'log', '--format=%h %s (%cr)', '-100', branch }, { cwd = root, text = true }):wait()
  local items = { '⌥ вершина ветки ' .. branch }
  if res.code == 0 then
    vim.list_extend(items, vim.split(vim.trim(res.stdout or ''), '\n', { trimempty = true }))
  end
  M.select(title, items, function(choice, idx)
    if idx == 1 then
      cb(branch)
    else
      cb(choice:match('^(%S+)'))
    end
  end)
end

return M
