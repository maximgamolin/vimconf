-- Минимальный init для тестов: plenary + lua-модули конфига, без всего остального
vim.opt.rtp:append(vim.fn.expand('~/.local/share/nvim/plugged/plenary.nvim'))
local config = vim.fn.expand('~/.config/nvim')
package.path = config .. '/lua/?.lua;' .. config .. '/lua/?/init.lua;' .. package.path
