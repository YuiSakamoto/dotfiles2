# set up alias for hub as git
eval (hub alias -s)
set -g fish_user_paths "/usr/local/opt/bzip2/bin" $fish_user_paths

# homebrew 用
fish_add_path /opt/homebrew/bin

# set -x PATH $HOME/.anyenv/bin $PATH
fish_add_path $HOME/.anyenv/bin
eval (anyenv init - | source)

eval (ssh-agent -c)
ssh-add ~/.ssh/id_ed25519
tm
starship init fish | source

source /opt/homebrew/opt/asdf/asdf.fish
