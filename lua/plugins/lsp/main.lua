-- LSP: mason, pyright (+venv), хоткеи переходов, подсветка вхождений

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    'lua_ls',
    'pyright',
    'bashls',
    'cmake',
    'cssls',
    'dockerls',
    'docker_compose_language_service',
    'markdown_oxide',
    'nginx_language_server',
    'sqlls',
    'taplo',
    'lemminx',
    'yamlls',
  },
})

-- Корневые директории из переменной окружения для lsp-сервера
local pythonpath_dirs = {}
if vim.env.PYTHONPATH ~= nil then
  for path in string.gmatch(vim.env.PYTHONPATH, '[^:]+') do
    table.insert(pythonpath_dirs, path)
  end
end

-- Стандартные корневые файлы + пути из PYTHONPATH
local root_files = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' }
for _, path in ipairs(pythonpath_dirs) do
  table.insert(root_files, path)
end

-- Корневая директория проекта: ближайший предок с одним из root_files,
-- иначе — директория самого файла (как root_pattern + dirname из старого
-- require('lspconfig'), который удалён в пользу нативного vim.lsp.config)
local function get_root_dir(bufnr, on_dir)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  on_dir(vim.fs.root(bufnr, root_files) or vim.fs.dirname(fname))
end

local venv_path = tostring(vim.fn.getenv('VIRTUAL_ENV'))
print('Python virtual env: ' .. venv_path)

local python_settings = {}
if venv_path ~= '' and venv_path ~= 'NIL' then
  -- pythonPath должен указывать на бинарник интерпретатора, а не на папку venv
  python_settings = {
    python = {
      pythonPath = venv_path .. '/bin/python',
    },
  }
end

-- vim.lsp.config сливается с конфигом pyright из nvim-lspconfig;
-- запускает сервер mason-lspconfig (automatic_enable) при открытии буфера
vim.lsp.config('pyright', {
  root_dir = get_root_dir,
  capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
  settings = python_settings,
  on_attach = function(client, bufnr)
    local buf_map = function(mode, lhs, rhs, opts)
      opts = vim.tbl_extend('force', { noremap = true, silent = true }, opts or {})
      vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
    end

    -- Быстрая документация (аналог Ctrl+Q в PyCharm)
    buf_map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')

    -- Переход к определению: Ctrl+] и Option+Click
    buf_map('n', '<C-]>', '<cmd>lua vim.lsp.buf.definition()<CR>')
    buf_map('n', '<M-LeftMouse>', "<LeftMouse><cmd>lua require('telescope.builtin').lsp_references()<CR>")
    buf_map('n', '<C-LeftMouse>', '<LeftMouse><C-CR>')

    -- Навигация назад/вперёд по истории переходов (как Cmd+[ / Cmd+] в PyCharm)
    buf_map('n', '<M-[>', '<C-o>') -- Option+[ = назад
    buf_map('n', '<M-]>', '<C-i>') -- Option+] = вперёд

    -- Список использований функции или класса
    buf_map('n', '<C-r>', "<cmd>lua require('telescope.builtin').lsp_references()<CR>")

    -- Замена nvim-treesitter-refactor (архивирован, не работает с веткой main):
    -- grr — переименование, gnd — переход к объявлению, теперь через LSP
    buf_map('n', 'grr', '<cmd>lua vim.lsp.buf.rename()<CR>')
    buf_map('n', 'gnd', '<cmd>lua vim.lsp.buf.definition()<CR>')
  end,
})

-- Подсветка вхождений переменной под курсором
local lsp_highlight_group = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = true })
vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
  group = lsp_highlight_group,
  callback = function(args)
    -- Не все серверы (например, для markdown) поддерживают documentHighlight
    if #vim.lsp.get_clients({ bufnr = args.buf, method = 'textDocument/documentHighlight' }) > 0 then
      vim.lsp.buf.document_highlight()
    end
  end,
})
vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
  group = lsp_highlight_group,
  callback = function()
    vim.lsp.buf.clear_references()
  end,
})

-- Ctrl+Enter: перейти к объявлению, или если уже на объявлении — показать использования
vim.keymap.set('n', '<C-CR>', function()
  local params = vim.lsp.util.make_position_params()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_line = vim.fn.line('.') - 1

  vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result, ctx)
    if err or not result or (type(result) == 'table' and vim.tbl_isempty(result)) then
      require('telescope.builtin').lsp_references()
      return
    end

    local def = type(result) == 'table' and result[1] or result
    local def_uri = def.uri or def.targetUri
    local def_range = def.range or def.targetSelectionRange or def.targetRange
    local def_file = vim.uri_to_fname(def_uri)
    local def_line = def_range.start.line

    if def_file == current_file and def_line == current_line then
      require('telescope.builtin').lsp_references()
    else
      -- Используем уже полученный результат вместо второго LSP-запроса
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      local offset_encoding = client and client.offset_encoding or 'utf-8'
      vim.lsp.util.jump_to_location(def, offset_encoding)
    end
  end)
end)
