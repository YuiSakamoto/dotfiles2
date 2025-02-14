if status is-interactive
    # set up alias for hub as git
    eval (hub alias -s)
    set -g fish_user_paths "/usr/local/opt/bzip2/bin" $fish_user_paths

    # homebrew 用
    eval (/opt/homebrew/bin/brew shellenv)
    fish_add_path /opt/homebrew/bin

    # set -x PATH $HOME/.anyenv/bin $PATH
    # fish_add_path $HOME/.anyenv/bin
    # eval (anyenv init - | source)

    eval (ssh-agent -c)
    ssh-add ~/.ssh/id_ed25519
    tm
    starship init fish | source
end

source /opt/homebrew/opt/asdf/libexec/asdf.fish

# kpp(kill path process)
function kpp
  kill -9 (lsof -t -i :$argv)
end

# pnpm
set -gx PNPM_HOME "/Users/yui.sakamoto/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
mise activate fish | source
