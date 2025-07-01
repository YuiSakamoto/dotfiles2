function tmux_pane_title --description 'Set tmux pane title'
    if test -z "$TMUX"
        echo "Not in tmux session"
        return 1
    end
    
    if test (count $argv) -eq 0
        # Clear title if no arguments
        tmux select-pane -T ""
        echo "Pane title cleared"
    else
        # Set title to arguments
        set -l title (string join " " $argv)
        tmux select-pane -T "$title"
        echo "Pane title set to: $title"
    end
end