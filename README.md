# dotfiles

Personal dotfiles for macOS and Linux, using symlinks so changes in this repo
are reflected live.

## macOS setup

1. Clone the repo to `~/.dotfiles`:

   ```bash
   git clone https://github.com/alexlayton/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Run the macOS bootstrap script. This installs Homebrew, the formulae and
casks declared in `Brewfile`, and switches your login shell to fish:

   ```bash
   ./bootstrap.sh
   ```

3. Symlink the configs into place. This also installs bun and harness with
their official installers (skipped if already installed):

   ```bash
   ./install.sh
   ```

4. Restart your terminal.

## Linux setup

On Linux the bootstrap script is skipped; install fish via your package manager,
then symlink the configs (this also installs bun and harness):

```bash
git clone https://github.com/alexlayton/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## Adding or changing dotfiles

Because everything is symlinked, editing a file in this repo updates the live
config, and `git status` shows the change immediately.

- **Top-level files** (like `gitconfig`) are symlinked to `~/.<name>`.
- **Top-level `config/`** is handled specially: each subdirectory inside it is
symlinked to `~/.config/<subdir>`. So `config/fish/` becomes `~/.config/fish/`.

Run `./install.sh` again after adding new files or directories.

If a real file already exists at the destination, it is backed up to
`~/.dotfiles-backup/<timestamp>/` before the symlink is created.

## Neovim

The config lives in `config/nvim/` and uses Neovim's built-in plugin manager
(`vim.pack`). On first start it installs plugins, treesitter parsers and the
Ruff and Lua language servers (via Mason). Plugin versions are pinned in
`config/nvim/nvim-pack-lock.json`; update them with `:lua vim.pack.update()`.

Rust uses the rustup `rust-analyzer`:

```bash
rustup component add rust-analyzer rustfmt clippy
```

Python types/completion use Astral's `ty`, installed with uv:

```bash
uv tool install ty   # update later with: uv tool upgrade ty
```

## Local secrets

Fish loads `~/.config/fish/secrets.fish` when it starts, if the file exists.
After `./install.sh`, `~/.config/fish` links to this repo's `config/fish/`.
Create your local secrets file from the example:

```bash
cp ~/.config/fish/secrets.fish.example ~/.config/fish/secrets.fish
chmod 600 ~/.config/fish/secrets.fish
```

Edit `~/.config/fish/secrets.fish` and replace the placeholder key with your
own values. Start a new fish shell to load them. The real `secrets.fish` is
ignored by Git; do not put real secrets in the tracked example or other
tracked files.

## What's installed on macOS

From `Brewfile`:

- **Formulae:** `fish`, `tmux`, `rustup-init`, `uv`, `gh`, `rtk`, `neovim`,
  `tree-sitter-cli`, `ripgrep`, `fd`, `fzf`
- **Casks:** `firefox`, `ghostty`, `visual-studio-code`, `zed`

## Python tooling

`install.sh` installs `ty` (the Python type checker and language server Neovim
uses) with `uv tool install ty@latest`. Update it with `uv tool upgrade ty`.
Fish completions for it live in `config/fish/completions/ty.fish`.

## Zed

`config/zed/settings.json` and `config/zed/keymap.json` mirror the Neovim setup
where Zed allows it: the Melange theme (installed automatically), vim mode with
relative line numbers, `jj` for Esc, the same `<Space>` leader maps (find, code,
git, `<Space>e` for the file tree), ty + ruff for Python, and clippy for Rust.
The project panel is docked on the left, overriding Zed's newer right-side
default. Other files Zed creates in `~/.config/zed` are ignored by Git.
