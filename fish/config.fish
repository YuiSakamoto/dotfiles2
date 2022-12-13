# set up alias for hub as git
eval (hub alias -s)
set -g fish_user_paths "/usr/local/opt/bzip2/bin" $fish_user_paths

eval (ssh-agent -c)
ssh-add ~/.ssh/id_rsa
ssh-add ~/.ssh/stash_rsa
tm
