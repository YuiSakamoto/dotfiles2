set -x GOPATH $HOME
set -x GOBIN $HOME/bin
set -x PATH $PATH $GOPATH/bin

set -x PATH $HOME/.anyenv/bin $PATH
eval (anyenv init - | source)

