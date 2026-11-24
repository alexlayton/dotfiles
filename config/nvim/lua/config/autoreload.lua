-- Reload buffers when their files change on disk (for example, when a coding
-- agent edits them in another pane). No polling: one libuv fs_event watcher
-- per directory that has a loaded file buffer. Directory watchers still fire
-- after atomic writes (write temp file, rename over target), which a watcher
-- on the file itself would miss.
--
-- Buffers with unsaved changes are never reloaded; you get one warning per
-- conflict instead. `:checktime` + 'autoread' does the actual reload, so the
-- cursor and undo history are kept (`u` goes back to the pre-reload text).

local uv = vim.uv
local DEBOUNCE_MS = 50

vim.o.autoread = true

local dirs = {} -- dir -> { handle = uv_fs_event, files = { [basename] = { [buf] = true } } }
local watched = {} -- buf -> { dir = string, base = string }
local pending = {} -- buf -> true while a debounced check is queued
local warned = {} -- buf -> true after a conflict warning (cleared on write/reload)

local function check(buf)
  pending[buf] = nil
  if not vim.api.nvim_buf_is_loaded(buf) then return end
  if vim.fn.mode() == 'c' then -- do not interrupt the command line
    pending[buf] = true
    vim.defer_fn(function() check(buf) end, DEBOUNCE_MS)
    return
  end
  if vim.bo[buf].modified then
    if not warned[buf] then
      warned[buf] = true
      vim.notify(
        ('%s changed on disk, but the buffer has unsaved changes'):format(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':~:.')),
        vim.log.levels.WARN
      )
    end
    return
  end
  vim.cmd.checktime(buf)
end

-- Runs in libuv's fast context: only touch Lua tables, then defer to the main loop.
local function queue(buf)
  if pending[buf] then return end
  pending[buf] = true
  vim.defer_fn(function() check(buf) end, DEBOUNCE_MS)
end

local function on_event(dir, err, filename)
  local entry = dirs[dir]
  if not entry then return end
  if err then return vim.schedule(function() entry.handle:stop() end) end
  -- Some backends omit the filename: check every buffer in the directory.
  local targets = filename and { entry.files[vim.fs.basename(filename)] } or vim.tbl_values(entry.files)
  for _, bufs in ipairs(targets) do
    for buf in pairs(bufs) do queue(buf) end
  end
end

local function unwatch(buf)
  local w = watched[buf]
  if not w then return end
  watched[buf], pending[buf], warned[buf] = nil, nil, nil
  local entry = dirs[w.dir]
  local bufs = entry.files[w.base]
  bufs[buf] = nil
  if next(bufs) == nil then entry.files[w.base] = nil end
  if next(entry.files) == nil then
    entry.handle:close()
    dirs[w.dir] = nil
  end
end

local function watch(buf)
  if vim.bo[buf].buftype ~= '' then return end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then return end
  local path = uv.fs_realpath(name) or vim.fs.normalize(name) -- follow symlinks
  local dir, base = vim.fs.dirname(path), vim.fs.basename(path)

  local w = watched[buf]
  if w and w.dir == dir and w.base == base then return end
  unwatch(buf)

  local entry = dirs[dir]
  if not entry then
    local handle = uv.new_fs_event()
    if not handle then return end
    local ok = handle:start(dir, {}, function(err, filename) on_event(dir, err, filename) end)
    if not ok then -- directory may not exist yet (new file); BufWritePost retries
      handle:close()
      return
    end
    entry = { handle = handle, files = {} }
    dirs[dir] = entry
  end
  entry.files[base] = entry.files[base] or {}
  entry.files[base][buf] = true
  watched[buf] = { dir = dir, base = base }
end

local group = vim.api.nvim_create_augroup('config.autoreload', { clear = true })

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile', 'BufFilePost', 'BufWritePost' }, {
  group = group,
  callback = function(args) watch(args.buf) end,
})

vim.api.nvim_create_autocmd({ 'BufUnload', 'BufDelete', 'BufWipeout' }, {
  group = group,
  callback = function(args) unwatch(args.buf) end,
})

vim.api.nvim_create_autocmd({ 'BufWritePost', 'FileChangedShellPost' }, {
  group = group,
  callback = function(args) warned[args.buf] = nil end,
})

-- Catch changes made while Neovim was not watching (e.g. buffer was hidden/unloaded).
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  group = group,
  callback = function(args)
    if watched[args.buf] then queue(args.buf) end
  end,
})

for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_loaded(buf) then watch(buf) end
end
