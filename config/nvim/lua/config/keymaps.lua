-- Custom key mappings. Most of Neovim's defaults are kept on purpose.
-- Plugin and LSP mappings live next to their setup in plugins.lua / lsp.lua.
-- Tip: <leader> is Space. Press it and wait to see a menu (which-key).
local map = vim.keymap.set

-- `jj` leaves insert mode without leaving the home row.
map('i', 'jj', '<Esc>', { desc = 'Exit insert mode' })

-- Clear search highlighting.
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Leave terminal mode (:terminal) with a double Esc instead of <C-\><C-n>.
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Diagnostics: ]d / [d (next/prev) and <C-w>d (show float) are built in.
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics to location list' })
