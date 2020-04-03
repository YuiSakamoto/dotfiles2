set -x GOPATH $HOME
set -x GOBIN $HOME/bin
set -x PATH $PATH $GOPATH/bin

set -gx PKG_CONFIG_PATH "/usr/local/opt/krb5/lib/pkgconfig" $PKG_CONFIG_PATH
set -gx PKG_CONFIG_PATH "/usr/local/opt/openssl@1.1/lib/pkgconfig" $PKG_CONFIG_PATH
set -gx PKG_CONFIG_PATH "/usr/local/opt/zlib/lib/pkgconfig" $PKG_CONFIG_PATH

set -x PATH $HOME/.anyenv/bin $PATH
eval (anyenv init - | source)

