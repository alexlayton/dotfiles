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

3. Symlink the configs into place:

   ```bash
   ./install.sh
   ```

4. Restart your terminal.

## Linux setup

On Linux the bootstrap script is skipped; install fish via your package manager,
then symlink the configs:

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

## What's installed on macOS

From `Brewfile`:

- **Formulae:** `fish`, `rustup-init`, `uv`
- **Casks:** `firefox`, `visual-studio-code`, `zed`
