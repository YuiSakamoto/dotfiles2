function wtg --description 'Go to git worktree'
    if test (count $argv) -eq 0
        echo "Usage: wtg <worktree-name>"
        echo "Available worktrees:"
        git worktree list
        return 1
    end
    
    # Git リポジトリのルートを取得
    set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$git_root"
        echo "Error: Not in a git repository"
        return 1
    end
    
    # worktreeのパスを探す
    set -l worktree_name $argv[1]
    
    # git worktree listから実際のパスを取得
    set -l worktree_path (git worktree list | grep "/$worktree_name\s" | awk '{print $1}')
    
    if test -z "$worktree_path"
        # .git/worktrees/以下も確認
        set -l alt_path "$git_root/.git/worktrees/$worktree_name"
        if test -d "$alt_path"
            set worktree_path $alt_path
        else
            echo "Worktree not found: $worktree_name"
            echo "Available worktrees:"
            git worktree list
            return 1
        end
    end
    
    # 移動
    cd $worktree_path
    echo "Moved to worktree: $worktree_name"
    git branch --show-current
end