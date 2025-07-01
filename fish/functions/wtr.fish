function wtr --description 'Go to git repository root'
    set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$git_root"
        echo "Error: Not in a git repository"
        return 1
    end
    
    cd $git_root
    echo "Moved to repository root: "(basename $git_root)
end