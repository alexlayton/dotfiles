# ~/.config/fish/config.fish
# Keep startup fast: avoid spawning external processes (brew, dirname, ...).

set -l secrets "$__fish_config_dir/secrets.fish"
if test -f "$secrets"
    source "$secrets"
end

# Default editor
set -gx EDITOR nvim

# Homebrew (Apple Silicon, Intel macOS, Linuxbrew).
# Static equivalent of `brew shellenv`, which costs ~15 ms per shell.
if not set -q HOMEBREW_PREFIX
    for prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew
        if test -x $prefix/bin/brew
            set -gx HOMEBREW_PREFIX $prefix
            set -gx HOMEBREW_CELLAR $prefix/Cellar
            if test $prefix = /opt/homebrew
                set -gx HOMEBREW_REPOSITORY $prefix
            else
                set -gx HOMEBREW_REPOSITORY $prefix/Homebrew
            end
            break
        end
    end
end
if set -q HOMEBREW_PREFIX
    fish_add_path --global --move --path $HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin
    if test -n "$MANPATH"
        set -gx MANPATH (string replace --regex '^:*(.*?):*$' ':$1' -- "$MANPATH")
    end
    contains -- $HOMEBREW_PREFIX/share/info $INFOPATH
    or set -gx INFOPATH $HOMEBREW_PREFIX/share/info $INFOPATH

    # rustup is keg-only; use the stable opt/ symlink instead of `brew --prefix`.
    if test -d $HOMEBREW_PREFIX/opt/rustup/bin
        fish_add_path --global $HOMEBREW_PREFIX/opt/rustup/bin
    end
end

fish_add_path --global ~/.local/bin

# bun
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path --global $BUN_INSTALL/bin
