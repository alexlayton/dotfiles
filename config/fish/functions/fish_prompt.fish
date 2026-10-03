# Purple shades (truecolor hex):
#   d7afff  light lavender  -> cwd
#   af87ff  medium purple   -> git branch
#   af5fd7  deep orchid     -> $
function fish_prompt
    set -l last_status $status

    # Show directory on its own line
    echo

    # Error indicator
    if test $last_status -ne 0
        echo -n (set_color red)"✘ $last_status "(set_color normal)
    end

    # Working directory
    echo -n (set_color d7afff)(prompt_pwd)(set_color normal)

    # Git status if available
    if type -q git
        set -l git_branch (git branch --show-current 2>/dev/null)
        if test -n "$git_branch"
            echo -n " "(set_color af87ff)"($git_branch)"(set_color normal)
        end
    end

    echo

    # Prompt prefix; set bright white after '$ ' so typed text stays white
    echo -n (set_color af5fd7)'$ '(set_color brwhite)
end
