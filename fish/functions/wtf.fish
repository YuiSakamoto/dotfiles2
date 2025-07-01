function wtf --description 'Select and go to git worktree using fzf'
    # fzfがインストールされているか確認
    if not type -q fzf
        echo "Error: fzf is not installed"
        return 1
    end
    
    # worktree一覧を取得してfzfで選択
    set -l selected (git worktree list | fzf --height=40% --reverse | awk '{print $1}')
    
    if test -n "$selected"
        cd $selected
        echo "Moved to: "(basename $selected)
        git branch --show-current
    end
end