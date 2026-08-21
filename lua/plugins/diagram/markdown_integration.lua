-- Markdown-интеграция для diagram.nvim с поддержкой алиасов языков:
-- код-блоки ```puml рендерятся так же, как ```plantuml.
-- Штатная интеграция (diagram/integrations/markdown.lua) сравнивает язык
-- блока со строками жёстко, поэтому оборачиваем её своим query_buffer_diagrams.

local base = require('diagram.integrations.markdown')

-- алиас → каноничный id рендерера diagram.nvim
local aliases = {
  puml = 'plantuml',
}

local known = { mermaid = true, plantuml = true, d2 = true, gnuplot = true }

---@type vim.treesitter.Query
local query = nil

local M = vim.tbl_extend('force', {}, base)

M.query_buffer_diagrams = function(bufnr)
  if not query then
    query = vim.treesitter.query.parse('markdown', '(fenced_code_block (info_string) @info (code_fence_content) @code)')
  end

  local buf = bufnr or vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(buf, 'markdown')
  parser:parse(true)

  local root = parser:parse()[1]:root()
  local matches = query:iter_captures(root, buf)

  local diagrams = {}
  local current_language = nil
  local current_range = nil
  for id, node in matches do
    local key = query.captures[id]
    local value = vim.treesitter.get_node_text(node, buf)
    if node:parent():parent() and node:parent():parent():type() == 'block_quote' then
      value = value:gsub('\n>', '\n'):gsub('^>', '')
    end

    if key == 'info' then
      local start_row, _, end_row, end_col = node:range()
      current_range = {
        start_row = start_row,
        start_col = 0,
        end_row = end_row,
        end_col = end_col,
      }
      current_language = aliases[value] or value
    else
      if known[current_language] then
        table.insert(diagrams, {
          bufnr = buf,
          renderer_id = current_language,
          source = value,
          range = current_range,
        })
      end
    end
  end

  return diagrams
end

return M
