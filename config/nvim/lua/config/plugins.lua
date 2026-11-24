-- Plugins, managed by Neovim's built-in vim.pack (:help vim.pack).
--   Update:  :lua vim.pack.update()   (review, then :w to apply or :q to cancel)
--   Remove:  delete the spec below, then :lua vim.pack.del({ 'name' })
-- Exact versions are pinned in nvim-pack-lock.json. Commit that file.

local gh = function(repo) return 'https://github.com/' .. repo end

-- Rebuild treesitter parsers when nvim-treesitter updates.
-- (Must be defined before vim.pack.add so it also runs on first install.)
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind == 'update' then
      if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
      vim.cmd('TSUpdate')
    end
  end,
})

vim.pack.add({
  gh('savq/melange-nvim'), -- colour scheme
  gh('nvim-mini/mini.nvim'), -- icons, statusline, text objects, autopairs
  gh('folke/which-key.nvim'), -- shows available keys after a pause
  { src = gh('nvim-treesitter/nvim-treesitter'), version = 'main' }, -- syntax parsers
  gh('neovim/nvim-lspconfig'), -- default configs for language servers
  gh('mason-org/mason.nvim'), -- installs language servers (:Mason)
  gh('mason-org/mason-lspconfig.nvim'),
  { src = gh('saghen/blink.cmp'), version = vim.version.range('1.*') }, -- completion
  gh('stevearc/conform.nvim'), -- format on save
  gh('ibhagwan/fzf-lua'), -- fuzzy finder for files, text, symbols, ...
  { src = gh('nvim-neo-tree/neo-tree.nvim'), version = 'v3.x' }, -- file tree sidebar
  gh('nvim-lua/plenary.nvim'), -- needed by neo-tree
  gh('MunifTanjim/nui.nvim'), -- needed by neo-tree
  gh('lewis6991/gitsigns.nvim'), -- git changes in the sign column
}, { confirm = false })

local map = vim.keymap.set

-- Colour scheme ---------------------------------------------------------------
-- Melange has a dark and a light version; 'background' selects which one.
vim.o.background = 'dark'
vim.cmd.colorscheme('melange')

-- mini.nvim -------------------------------------------------------------------
require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons() -- plugins that expect nvim-web-devicons use mini.icons
require('mini.statusline').setup()
require('mini.pairs').setup() -- auto-close brackets and quotes
-- Extra text objects: e.g. `daa` delete argument, `vif` select function body,
-- `ci"` / `ci)` also work when the cursor is before the quotes/brackets.
require('mini.ai').setup()

-- which-key -------------------------------------------------------------------
local wk = require('which-key')
wk.setup({ delay = 400 })
wk.add({
  { '<leader>f', group = 'find' },
  { '<leader>g', group = 'git' },
  { '<leader>c', group = 'code' },
})

-- Treesitter: better syntax highlighting, folding and text objects -------------
-- Add a language here, or run :TSInstall <lang> once.
require('nvim-treesitter').install({
  'rust', 'python', 'toml', 'json', 'yaml', 'bash', 'fish',
  'javascript', 'typescript', 'tsx', 'html', 'css', 'regex', 'gitcommit', 'diff',
})
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    -- Start highlighting if a parser exists for this filetype; ignore otherwise.
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- Completion ------------------------------------------------------------------
-- 'super-tab' preset:
--   <Tab> accept (selects the first item if none is selected), else jump to
--         the next snippet field, else insert a normal tab
--   <S-Tab> previous snippet field   <C-n>/<C-p> or <Up>/<Down> next/prev
--   <C-e> close   <C-space> open   <C-b>/<C-f> scroll docs
require('blink.cmp').setup({
  keymap = { preset = 'super-tab' },
  completion = { documentation = { auto_show = true, auto_show_delay_ms = 300 } },
  signature = { enabled = true },
  fuzzy = { implementation = 'prefer_rust_with_warning' },
})

-- Formatting ------------------------------------------------------------------
require('conform').setup({
  formatters_by_ft = {
    rust = { 'rustfmt' },
    python = { 'ruff_organize_imports', 'ruff_format' },
  },
  -- Other filetypes fall back to the language server's formatter, if any.
  default_format_opts = { lsp_format = 'fallback' },
  format_on_save = function(buf)
    if vim.g.disable_autoformat or vim.b[buf].disable_autoformat then return end
    return { timeout_ms = 1000 }
  end,
})
map({ 'n', 'x' }, '<leader>cf', function() require('conform').format({ async = true }) end,
  { desc = 'Format buffer/selection' })
map('n', '<leader>cF', function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  vim.notify('Format on save: ' .. (vim.g.disable_autoformat and 'off' or 'on'))
end, { desc = 'Toggle format on save' })

-- Fuzzy finder ----------------------------------------------------------------
-- Inside the picker: type to filter, <C-j>/<C-k> or <C-n>/<C-p> to move,
-- <Enter> open, <C-v> vertical split, <C-s> horizontal split, <C-q> to quickfix.
local fzf = require('fzf-lua')
fzf.setup({})
fzf.register_ui_select() -- use fzf for code-action and other menus
map('n', '<leader><leader>', fzf.buffers, { desc = 'Open buffers' })
map('n', '<leader>ff', fzf.files, { desc = 'Files' })
map('n', '<leader>fg', fzf.live_grep, { desc = 'Grep text in project' })
map({ 'n', 'x' }, '<leader>fw', fzf.grep_cword, { desc = 'Grep word under cursor' })
map('n', '<leader>fr', fzf.oldfiles, { desc = 'Recent files' })
map('n', '<leader>fh', fzf.helptags, { desc = 'Help pages' })
map('n', '<leader>fk', fzf.keymaps, { desc = 'Keymaps' })
map('n', '<leader>fd', fzf.diagnostics_document, { desc = 'Diagnostics (file)' })
map('n', '<leader>fD', fzf.diagnostics_workspace, { desc = 'Diagnostics (project)' })
map('n', '<leader>fs', fzf.lsp_document_symbols, { desc = 'Symbols (file)' })
map('n', '<leader>fS', fzf.lsp_live_workspace_symbols, { desc = 'Symbols (project)' })
map('n', '<leader>f.', fzf.resume, { desc = 'Resume last search' })

-- File tree -------------------------------------------------------------------
-- <leader>e toggles a sidebar (like VS Code) and shows the current file in it.
-- In the tree: <Enter> open, <BS> up a folder, a add (end with / for a folder),
--   d delete, r rename, m move, c copy, H hidden files, / filter, ? all keys.
require('neo-tree').setup({
  close_if_last_window = true, -- quit Neovim when only the tree is left
  filesystem = {
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true, -- refresh when files change outside Neovim
    hijack_netrw_behavior = 'open_current', -- `nvim .` opens the tree
  },
})
map('n', '<leader>e', '<cmd>Neotree toggle reveal<CR>', { desc = 'File tree (toggle)' })

-- Git -------------------------------------------------------------------------
require('gitsigns').setup({
  on_attach = function(buf)
    local gs = require('gitsigns')
    local function bmap(mode, lhs, rhs, desc) map(mode, lhs, rhs, { buffer = buf, desc = desc }) end
    -- ]c / [c jump between changes (and keep their normal meaning in diff mode).
    bmap('n', ']c', function()
      if vim.wo.diff then vim.cmd.normal({ ']c', bang = true }) else gs.nav_hunk('next') end
    end, 'Next git change')
    bmap('n', '[c', function()
      if vim.wo.diff then vim.cmd.normal({ '[c', bang = true }) else gs.nav_hunk('prev') end
    end, 'Previous git change')
    bmap('n', '<leader>gp', gs.preview_hunk, 'Preview change')
    bmap('n', '<leader>gs', gs.stage_hunk, 'Stage/unstage change')
    bmap('n', '<leader>gr', gs.reset_hunk, 'Reset change')
    bmap('n', '<leader>gb', gs.blame_line, 'Blame line')
    bmap('n', '<leader>gd', gs.diffthis, 'Diff file')
  end,
})
