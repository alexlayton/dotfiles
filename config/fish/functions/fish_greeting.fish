function fish_greeting
    set -l quotes \
        "All warfare is based on deception." \
        "The supreme art of war is to subdue the enemy without fighting." \
        "In the midst of chaos, there is also opportunity." \
        "If you know the enemy and know yourself, you need not fear the result of a hundred battles." \
        "Victorious warriors win first and then go to war, while defeated warriors go to war first and then seek to win." \
        "Appear weak when you are strong, and strong when you are weak." \
        "Opportunities multiply as they are seized." \
        "The greatest victory is that which requires no battle."

    set -l idx (random 1 (count $quotes))

    echo
    echo (set_color yellow)"☀  Sun Tzu says:"(set_color normal)
    echo (set_color cyan)"   \"$quotes[$idx]\""(set_color normal)
    echo
end
