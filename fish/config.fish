if status is-interactive
    # macOS (Apple Silicon) で Homebrew の環境変数を読む
    if test (uname) = Darwin; and test -x /opt/homebrew/bin/brew
        /opt/homebrew/bin/brew shellenv | source
    end

    # starship prompt
    if type -q starship
        starship init fish | source
    end

    # mise (runtime manager) — path.fish で activate 済みだが念のため
    if type -q mise; and not set -q __mise_activated
        mise activate fish | source
        set -g __mise_activated 1
    end
end

# kpp(kill path process)
function kpp
    kill -9 (lsof -t -i :$argv)
end

# pnpm
if test -d "$HOME/Library/pnpm"
    set -gx PNPM_HOME "$HOME/Library/pnpm"
else
    set -gx PNPM_HOME "$HOME/.local/share/pnpm"
end
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end

fish_add_path $HOME/.local/bin
