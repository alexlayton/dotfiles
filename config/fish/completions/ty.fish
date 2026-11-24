# ~/.config/fish/completions/ty.fish
# Shell completion for ty (https://docs.astral.sh/ty/installation/)
if type -q ty
    ty generate-shell-completion fish | source
end
