function wt --description 'Git worktree management'
    if test (count $argv) -eq 0
        echo "Usage: wt <command> [args]"
        echo "Commands:"
        echo "  goto, g <name>    - Move to worktree"
        echo "  add, a <name>     - Create new worktree" 
        echo "  list, l           - List worktrees"
        echo "  remove, rm <name> - Remove worktree"
        echo "  root, r           - Go to repository root"
        echo "  fzf, f            - Select worktree with fzf"
        return 1
    end
    
    switch $argv[1]
        case "goto" "g"
            if test (count $argv) -lt 2
                echo "Usage: wt goto <worktree-name>"
                return 1
            end
            wtg $argv[2..-1]
            
        case "add" "a"
            if test (count $argv) -lt 2
                echo "Usage: wt add <branch-name> [path]"
                return 1
            end
            set -l branch_name $argv[2]
            set -l git_root (git rev-parse --show-toplevel)
            
            if test (count $argv) -ge 3
                git worktree add $argv[3] -b $branch_name
            else
                git worktree add "$git_root/.git/worktrees/$branch_name" -b $branch_name
            end
            
        case "list" "l"
            git worktree list
            
        case "remove" "rm"
            if test (count $argv) -lt 2
                echo "Usage: wt remove <worktree-name>"
                return 1
            end
            set -l worktree_name $argv[2]
            set -l worktree_path (git worktree list | grep "/$worktree_name\s" | awk '{print $1}')
            
            if test -n "$worktree_path"
                git worktree remove $worktree_path
            else
                echo "Worktree not found: $worktree_name"
                return 1
            end
            
        case "root" "r"
            wtr
            
        case "fzf" "f"
            wtf
            
        case "*"
            echo "Unknown command: $argv[1]"
            return 1
    end
end