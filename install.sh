#!/usr/bin/env bash
set -euo pipefail

# install.sh
# Platform-agnostic dotfile installer. Symlinks repo files into your home
# directory so edits here are reflected immediately and can be committed.

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Items at the repo root that should NOT be symlinked into $HOME.
SKIP=(
  ".git"
  ".gitignore"
  ".DS_Store"
  "README.md"
  "bootstrap.sh"
  "install.sh"
  "Brewfile"
)

should_skip() {
  local name="$1"
  for s in "${SKIP[@]}"; do
    if [[ "$name" == "$s" ]]; then
      return 0
    fi
  done
  return 1
}

backup_and_link() {
  local src="$1"
  local dest="$2"

  # Already correctly symlinked — nothing to do
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "OK $dest"
    return
  fi

  # Existing file/dir/symlink pointing elsewhere — back it up first
  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    echo "BACK $dest -> $BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/"
  fi

  echo "LINK $dest -> $src"
  ln -s "$src" "$dest"
}

echo "==> Symlinking dotfiles from $REPO_DIR"

for item in "$REPO_DIR"/*; do
  [[ -e "$item" ]] || continue
  name=$(basename "$item")
  should_skip "$name" && continue

  if [[ "$name" == "config" ]]; then
    # config/ mirrors ~/.config on a per-directory basis
    mkdir -p "$HOME/.config"
    for sub in "$item"/*; do
      [[ -e "$sub" ]] || continue
      subname=$(basename "$sub")
      backup_and_link "$sub" "$HOME/.config/$subname"
    done
  else
    backup_and_link "$item" "$HOME/.$name"
  fi
done

echo "==> Done"
