set -gx GOPATH $HOME
set -gx GOBIN $HOME/bin

# dotfiles2 の bin/ は ~/.local/bin に symlink される
fish_add_path $HOME/.local/bin
fish_add_path $HOME/bin
fish_add_path $HOME/go/bin

# mise (asdf 互換のランタイム管理)
if type -q mise
    mise activate fish | source
end

# --- macOS (Apple Silicon) 固有 ---
if test (uname) = Darwin
    fish_add_path /opt/homebrew/bin /opt/homebrew/sbin
    for p in /opt/homebrew/opt/krb5/lib/pkgconfig /opt/homebrew/opt/openssl@3/lib/pkgconfig /opt/homebrew/opt/zlib/lib/pkgconfig
        if test -d $p
            set -gx PKG_CONFIG_PATH $p $PKG_CONFIG_PATH
        end
    end
    if test -d /opt/homebrew/opt/libpq/bin
        fish_add_path /opt/homebrew/opt/libpq/bin
    end
end
