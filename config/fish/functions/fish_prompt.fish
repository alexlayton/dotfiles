function fish_prompt
    set -l last_status $status
    set -l pwd_color $fish_color_cwd

    # Show directory on its own line
    echo

    # Error indicator
    if test $last_status -ne 0
        echo -n (set_color red)"✘ $last_status "(set_color normal)
    end

    # Working directory
    echo -n (set_color $pwd_color)(prompt_pwd)(set_color normal)

    # Git status if available
    if type -q git
        set -l git_branch (git branch --show-current 2>/dev/null)
        if test -n "$git_branch"
            echo -n " "(set_color magenta)"($git_branch)"(set_color normal)
        end
    end

    echo

    # Tengu mask prompt prefix
    echo -n (set_color red)"👺 "(set_color normal)
end
