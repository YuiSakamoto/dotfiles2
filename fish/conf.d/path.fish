set -x GOPATH $HOME
set -x GOBIN $HOME/bin
set -x PATH $PATH $GOPATH/bin

set -gx PKG_CONFIG_PATH "/usr/local/opt/krb5/lib/pkgconfig" $PKG_CONFIG_PATH
set -gx PKG_CONFIG_PATH "/usr/local/opt/openssl@1.1/lib/pkgconfig" $PKG_CONFIG_PATH
set -gx PKG_CONFIG_PATH "/usr/local/opt/zlib/lib/pkgconfig" $PKG_CONFIG_PATH

set -x PATH $HOME/.anyenv/bin $PATH
eval (anyenv init - | source)

# set -x GOENV_ROOT $HOME/.goenv
# set -x PATH $GOENV_ROOT/bin:$PATH
# set -x PATH $HOME/.goenv/bin:$PATH
# eval (goenv init -)

set -x PATH $PATH:/usr/local/bin:$HOME/.composer/vendor/bin
set -x PATH $PATH:/usr/local/bin/terraform
