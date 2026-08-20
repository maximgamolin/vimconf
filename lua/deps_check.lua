-- Проверка внешних программ, которые нужны конфигу
-- (список — из шапки init.vim и комментариев к плагинам)

local M = {}

-- бинарник → как установить (подсказка выводится, если не найден)
local required = {
  { bin = 'ctags',      hint = 'brew install universal-ctags' },                -- tagbar
  { bin = 'fzf',        hint = 'brew install fzf' },
  { bin = 'fd',         hint = 'brew install fd' },                             -- telescope find_files
  { bin = 'rg',         hint = 'brew install ripgrep' },                        -- telescope live_grep
  { bin = 'lazygit',    hint = 'brew install lazygit' },
  { bin = 'lazydocker', hint = 'brew install lazydocker' },
  { bin = 'lazysql',    hint = 'brew install jorgerojas26/lazysql/lazysql' },
  { bin = 'node',       hint = 'brew install node' },                           -- mason/pyright
  { bin = 'claude',     hint = 'npm install -g @anthropic-ai/claude-code' },    -- claudecode.nvim
}

function M.check()
  for _, tool in ipairs(required) do
    if vim.fn.executable(tool.bin) == 1 then
      print(tool.bin .. ': OK')
    else
      print(tool.bin .. ': NOT FOUND (' .. tool.hint .. ')')
    end
  end

  -- debugpy — python-библиотека (нужна для DAP), проверяем в активном venv.
  -- Асинхронно, чтобы не задерживать запуск nvim.
  local venv = tostring(vim.fn.getenv('VIRTUAL_ENV'))
  if venv ~= '' and venv ~= 'NIL' then
    local python = venv .. '/bin/python'
    if vim.fn.executable(python) == 1 then
      vim.system({ python, '-c', 'import debugpy' }, {}, function(res)
        vim.schedule(function()
          if res.code == 0 then
            print('debugpy: OK')
          else
            print('debugpy: NOT FOUND (pip install debugpy)')
          end
        end)
      end)
    end
  end
end

return M
