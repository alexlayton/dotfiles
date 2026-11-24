# ~/.config/fish/functions/container-nuke.fish

function container-nuke --description "Delete all Apple containers and remove all images"
    if not type -q container
        echo "container-nuke: 'container' CLI not found" >&2
        return 1
    end

    if not contains -- -y $argv; and not contains -- --yes $argv
        read -l -P "Delete ALL containers and images? [y/N] " answer
        string match -qi y -- $answer; or return 1
    end

    container delete --all --force
    container image prune --all
end
