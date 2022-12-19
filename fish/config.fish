# set up alias for hub as git
eval (hub alias -s)
set -g fish_user_paths "/usr/local/opt/bzip2/bin" $fish_user_paths

eval (/opt/homebrew/bin/brew shellenv)

set -x PATH $HOME/.anyenv/bin $PATH
eval (anyenv init - | source)

eval (ssh-agent -c)
ssh-add ~/.ssh/id_ed25519
tm
