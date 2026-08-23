-- Хранилище замечаний ревью: .review/<путь через __>.md в корне репозитория.
-- Файл существует ⇔ по файлу есть замечания. Источник истины о пути — frontmatter.
-- Формат:
--   ---
--   file: src/app/main.py
--   base: a1b2c3d
--   head: e4f5a6b
--   ---
--
--   ## L42
--   > цитата строки кода
--   Текст замечания.
--
--   ## L57-L60
--   > for item in items:
--   >     process(item)
--   Текст замечания (до следующего ## или конца файла).
local M = {}

M.DIR = '.review'

-- src/app/main.py -> src__app__main.py.md
function M.encode_name(relpath)
  return relpath:gsub('/', '__') .. '.md'
end

function M.review_dir(git_root)
  return git_root .. '/' .. M.DIR
end

function M.file_path(git_root, relpath)
  return M.review_dir(git_root) .. '/' .. M.encode_name(relpath)
end

---@class ReviewComment
---@field line_start integer  номер строки в head-версии (1-based)
---@field line_end integer    равен line_start для однострочного замечания
---@field quote string[]      процитированные строки кода (без "> ")
---@field text string         текст замечания (может быть многострочным)

---@class ReviewFile
---@field file string  путь относительно корня репозитория
---@field base string  левая ревизия (merge-base)
---@field head string  ревизия, к которой привязаны номера строк
---@field comments ReviewComment[]

-- Сериализация ReviewFile в строки md-файла
---@param rf ReviewFile
---@return string[]
function M.serialize(rf)
  local lines = { '---', 'file: ' .. rf.file, 'base: ' .. rf.base, 'head: ' .. rf.head, '---' }
  for _, c in ipairs(rf.comments) do
    lines[#lines + 1] = ''
    if c.line_end and c.line_end ~= c.line_start then
      lines[#lines + 1] = string.format('## L%d-L%d', c.line_start, c.line_end)
    else
      lines[#lines + 1] = string.format('## L%d', c.line_start)
    end
    for _, q in ipairs(c.quote or {}) do
      lines[#lines + 1] = '> ' .. q
    end
    for t in (c.text .. '\n'):gmatch('(.-)\n') do
      lines[#lines + 1] = t
    end
    -- убрать хвостовые пустые строки текста
    while lines[#lines] == '' do
      lines[#lines] = nil
    end
  end
  return lines
end

-- Парсинг строк md-файла в ReviewFile (обратная операция к serialize)
---@param lines string[]
---@return ReviewFile|nil, string|nil  результат или nil+ошибка
function M.parse(lines)
  local rf = { file = nil, base = '', head = '', comments = {} }
  local i = 1
  if lines[1] ~= '---' then
    return nil, 'нет frontmatter'
  end
  i = 2
  while lines[i] and lines[i] ~= '---' do
    local key, val = lines[i]:match('^(%w+):%s*(.-)%s*$')
    if key then
      rf[key] = val
    end
    i = i + 1
  end
  if not lines[i] then
    return nil, 'frontmatter не закрыт'
  end
  if not rf.file or rf.file == '' then
    return nil, 'нет поля file'
  end
  i = i + 1

  local cur = nil -- текущий комментарий; text собираем списком строк
  local function flush()
    if cur then
      -- убрать хвостовые пустые строки
      while cur.text_lines[#cur.text_lines] == '' do
        cur.text_lines[#cur.text_lines] = nil
      end
      cur.text = table.concat(cur.text_lines, '\n')
      cur.text_lines = nil
      rf.comments[#rf.comments + 1] = cur
      cur = nil
    end
  end

  while i <= #lines do
    local l = lines[i]
    local s, e = l:match('^## L(%d+)%-L(%d+)%s*$')
    if not s then
      s = l:match('^## L(%d+)%s*$')
      e = s
    end
    if s then
      flush()
      cur = { line_start = tonumber(s), line_end = tonumber(e), quote = {}, text_lines = {}, in_quote = true }
    elseif cur then
      local q = l:match('^> ?(.*)$')
      if q and cur.in_quote and #cur.text_lines == 0 then
        cur.quote[#cur.quote + 1] = q
      elseif l == '' and cur.in_quote and #cur.text_lines == 0 then
        -- пустая строка между заголовком/цитатой и текстом — пропускаем
      else
        cur.in_quote = false
        cur.text_lines[#cur.text_lines + 1] = l
      end
    end
    i = i + 1
  end
  flush()
  for _, c in ipairs(rf.comments) do
    c.in_quote = nil
  end
  return rf
end

-- Прочитать замечания одного файла; nil если файла замечаний нет
---@return ReviewFile|nil
function M.load(git_root, relpath)
  local path = M.file_path(git_root, relpath)
  local f = io.open(path, 'r')
  if not f then
    return nil
  end
  local content = f:read('*a')
  f:close()
  local lines = vim.split(content, '\n', { plain = true })
  local rf, err = M.parse(lines)
  if not rf then
    vim.notify(('review: не смог разобрать %s: %s'):format(path, err), vim.log.levels.WARN)
    return nil
  end
  return rf
end

-- Сохранить замечания файла. Пустой список замечаний удаляет md-файл,
-- пустую папку .review тоже подчищаем.
---@param rf ReviewFile
function M.save(git_root, rf)
  local path = M.file_path(git_root, rf.file)
  if #rf.comments == 0 then
    os.remove(path)
    -- удалить папку, если опустела (rmdir падает на непустой — это ок)
    vim.uv.fs_rmdir(M.review_dir(git_root))
    return
  end
  vim.fn.mkdir(M.review_dir(git_root), 'p')
  local f = assert(io.open(path, 'w'))
  f:write(table.concat(M.serialize(rf), '\n') .. '\n')
  f:close()
end

-- Прочитать все файлы замечаний ревью
---@return table<string, ReviewFile>  ключ — путь файла относительно корня
function M.load_all(git_root)
  local result = {}
  local dir = M.review_dir(git_root)
  local handle = vim.uv.fs_scandir(dir)
  if not handle then
    return result
  end
  while true do
    local name, typ = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if typ == 'file' and name:match('%.md$') then
      local f = io.open(dir .. '/' .. name, 'r')
      if f then
        local content = f:read('*a')
        f:close()
        local rf = M.parse(vim.split(content, '\n', { plain = true }))
        if rf then
          result[rf.file] = rf
        end
      end
    end
  end
  return result
end

return M
