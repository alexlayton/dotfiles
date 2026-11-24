-- Editor options. See `:help '<name>'` for any of these, e.g. :help 'scrolloff'
local o = vim.opt

-- Line numbers: absolute on the cursor line, relative elsewhere (makes 5j / 3k easy).
o.number = true
o.relativenumber = true
-- Show both numbers on each line: absolute (for `:42` / `42G`), then the
-- distance from the cursor in a dimmer colour (for `5j`, `d3k`).
-- Layout: signs | absolute | relative. Wrapped parts of a line show no number.
o.statuscolumn = '%s%=%{v:virtnum==0&&&nu?v:lnum:""}'
  .. '%#NonText#%{v:virtnum==0&&&rnu?printf(" %2s",v:relnum?v:relnum:""):""} '
o.cursorline = true
o.signcolumn = 'yes' -- always show, so text doesn't jump when diagnostics appear
o.scrolloff = 8 -- keep 8 lines visible above/below the cursor
o.sidescrolloff = 8
o.wrap = false

-- Indentation: 4 spaces by default. Filetype plugins (Rust, Python) adjust this.
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.smartindent = true

-- Search: case-insensitive unless you type a capital letter.
o.ignorecase = true
o.smartcase = true
o.inccommand = 'split' -- live preview of :s/foo/bar substitutions

-- Behaviour
o.mouse = 'a'
o.clipboard = 'unnamedplus' -- yank/paste use the macOS clipboard
o.undofile = true -- undo history survives closing the file
o.confirm = true -- ask instead of failing on :q with unsaved changes
o.splitright = true
o.splitbelow = true
o.updatetime = 250 -- faster CursorHold (diagnostics, git signs)
o.timeoutlen = 300 -- time to finish a mapping such as `jj` or <leader>ff

-- Appearance
o.termguicolors = true
o.winborder = 'rounded' -- borders on floating windows (hover, diagnostics)
o.showmode = false -- the statusline already shows the mode
o.list = true
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Folding with treesitter. Everything starts unfolded; use zc / zo / za / zR / zM.
o.foldmethod = 'expr'
o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
o.foldlevelstart = 99
