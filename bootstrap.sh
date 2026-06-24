#!/usr/bin/env bash
set -euo pipefail

# bootstrap.sh
# macOS-only setup: installs Homebrew, formulae, casks, and switches to fish.

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "bootstrap.sh is only for macOS. Skipping."
  exit 0
fi

echo "==> Bootstrapping macOS environment"

# Install Homebrew if it isn't already
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "==> Homebrew already installed"
fi

# Make brew available in this script regardless of architecture
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Install everything declared in the Brewfile
echo "==> Installing Homebrew packages..."
brew bundle

# Detect fish path
FISH_PATH=""
if [[ -x /opt/homebrew/bin/fish ]]; then
  FISH_PATH="/opt/homebrew/bin/fish"
elif [[ -x /usr/local/bin/fish ]]; then
  FISH_PATH="/usr/local/bin/fish"
elif command -v fish >/dev/null 2>&1; then
  FISH_PATH="$(command -v fish)"
fi

if [[ -z "$FISH_PATH" ]]; then
  echo "ERROR: Could not find fish after installation." >&2
  exit 1
fi

echo "==> Found fish at $FISH_PATH"

# Add fish to the list of allowed login shells
if ! grep -q "^${FISH_PATH}$" /etc/shells; then
  echo "==> Adding $FISH_PATH to /etc/shells (may prompt for sudo)..."
  echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

# Switch default shell to fish unless already set
CURRENT_SHELL="$(dscl . -read "$HOME" UserShell 2>/dev/null | sed 's/^UserShell: //' || true)"
if [[ "$CURRENT_SHELL" != "$FISH_PATH" ]]; then
  echo "==> Changing default shell to fish..."
  chsh -s "$FISH_PATH"
else
  echo "==> Default shell is already fish"
fi

echo "==> Bootstrap complete. Run ./install.sh to symlink your dotfiles."
echo "==> Restart your terminal after that."
