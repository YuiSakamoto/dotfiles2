if status is-interactive
    # set up alias for hub as git
    eval (hub alias -s)
    set -g fish_user_paths "/usr/local/opt/bzip2/bin" $fish_user_paths

    # homebrew 用
    eval (/opt/homebrew/bin/brew shellenv)
    fish_add_path /opt/homebrew/bin

    eval (ssh-agent -c)
    ssh-add ~/.ssh/id_ed25519
    tm
    starship init fish | source
end

source /opt/homebrew/opt/asdf/libexec/asdf.fish
