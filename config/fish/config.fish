# ~/.config/fish/config.fish

set -l config_dir (dirname (status --current-filename))
set -l secrets "$config_dir/secrets.fish"
if test -f "$secrets"
    source "$secrets"
end

# Default editor — change this to 'zed --wait' if you prefer Zed
set -gx EDITOR "code --wait"

# Homebrew shellenv support for macOS (Apple Silicon + Intel) and Linuxbrew
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
else if test -x /usr/local/bin/brew
    /usr/local/bin/brew shellenv | source
else if test -x /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
end

# Ensure ~/.local/bin is on PATH if it exists
fish_add_path ~/.local/bin

# Source all files in conf.d automatically ( Fish does this by default, but
# keeping the comment as a reminder that conf.d/ is the place for extras.)
