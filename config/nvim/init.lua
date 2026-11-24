-- ~/.config/nvim/init.lua
-- Entry point. Each module in lua/config/ handles one concern.
--   options  - editor settings (:help option-list)
--   keymaps  - the few custom key mappings
--   autocmds - small automatic behaviours
--   plugins  - plugins, installed with the built-in vim.pack
--   lsp      - language servers (Rust, Python, Lua, ...)

-- Leader must be set before any mapping that uses it.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.plugins')
require('config.lsp')
