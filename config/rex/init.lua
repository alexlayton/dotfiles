-- Rex counterpart to ../herdr/config.toml.
-- Ctrl+Space is the prefix. Press it, release, then press the next key.
-- Herdr workspaces map to Rex sessions.

local P = "ctrl+space>"

-- Press the prefix twice to send Ctrl+Space to the terminal.
rex.bind(P .. "ctrl+space", "pane.send_key", { key = "ctrl+space" })

-- Workspaces (sessions)
rex.bind(P .. "n", "session.new")
rex.bind(P .. "shift+n", "session.new")

-- Tabs
rex.bind(P .. "c", "client.tab.new")
rex.bind(P .. "t", "client.tab.new")
rex.bind(P .. "right", "client.tab.next")
rex.bind(P .. "left", "client.tab.previous")

-- h splits side by side; v stacks panes.
rex.bind(P .. "h", "pane.split", { direction = "right" })
rex.bind(P .. "v", "pane.split", { direction = "down" })

-- Home-row pane movement.
rex.bind(P .. "e", "pane.focus", { direction = "up" })
rex.bind(P .. "s", "pane.focus", { direction = "left" })
rex.bind(P .. "d", "pane.focus", { direction = "down" })
rex.bind(P .. "f", "pane.focus", { direction = "right" })

-- Reload, settings
rex.bind(P .. "r", "client.config.reload")
rex.bind(P .. "shift+s", "client.settings")

-- Resize mode: prefix+shift+r, then e/s/d/f or arrows. Enter leaves.
rex.mode("resize", { exclusive = true })
rex.bind(P .. "shift+r", "client.mode.enter", { name = "resize" })
for key, dir in pairs({
  e = "up", s = "left", d = "down", f = "right",
  up = "up", left = "left", down = "down", right = "right",
}) do
  rex.bind("resize/" .. key, "pane.resize", { direction = dir })
  rex.bind("resize/shift+" .. key, "pane.resize", { direction = dir, amount = 15 })
end
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")
