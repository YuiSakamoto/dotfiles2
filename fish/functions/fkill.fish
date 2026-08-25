function fkill -d "fzf でプロセスを選んで kill する"
    if not type -q fzf
        echo "fkill: fzf が見つかりません" >&2
        return 1
    end
    set -l pids (ps -ef | sed 1d | fzf -m --header='[kill process]' | awk '{print $2}')
    if test -n "$pids"
        echo $pids | xargs kill -9
    end
end
