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

fish_add_path ~/.local/bin
if type -q brew
    set -l rustup_prefix (brew --prefix rustup 2>/dev/null)
    if test -n "$rustup_prefix"; and test -d "$rustup_prefix/bin"
        fish_add_path "$rustup_prefix/bin"
    end
end

# Source all files in conf.d automatically ( Fish does this by default, but
# keeping the comment as a reminder that conf.d/ is the place for extras.)
