-- Language servers (:help lsp). Built-in LSP keys, active when a server attaches:
--   K           hover docs           grn  rename          gra  code action
--   grr         references           gri  implementation  grt  type definition
--   gO          symbols in file      <C-s> (insert) signature help
--   ]d / [d     next/prev diagnostic <C-w>d diagnostic under cursor
-- Commands: :checkhealth vim.lsp   :Mason (install more servers)   :LspInstall

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { spacing = 2, source = 'if_many' },
  float = { source = 'if_many' },
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('config.lsp', { clear = true }),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
    end

    -- Neovim's default `gd` is a text search; make it use the language server.
    map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
    map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')

    -- Inline type hints (like Zed/VS Code). On by default; <leader>ch toggles.
    if client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
      map('n', '<leader>ch', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
      end, 'Toggle inlay hints')
    end

    -- Ruff handles linting/formatting; leave hover docs to ty.
    if client.name == 'ruff' then client.server_capabilities.hoverProvider = false end
  end,
})

-- Rust: rust-analyzer comes from rustup (`rustup component add rust-analyzer`),
-- so it always matches your toolchain. Clippy runs on save.
vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      check = { command = 'clippy' },
    },
  },
})
vim.lsp.enable('rust_analyzer')

-- Python: Astral's tools. ty for types/completion/inlay hints, ruff for lint
-- and format. ty finds the project's .venv (as created by `uv`) by itself.
-- ty comes from uv, not Mason: `uv tool install ty`, update: `uv tool upgrade ty`.
vim.lsp.enable('ty')

-- Lua: for editing this config. Knows about the `vim` global.
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
    },
  },
})

-- Mason installs these servers on first start and enables everything it has
-- installed. For another language, open a file and run :LspInstall.
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'ruff', 'lua_ls' },
})
