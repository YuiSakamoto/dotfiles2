if status is-interactive
    set -g fish_user_paths "/usr/local/opt/bzip2/bin" $fish_user_paths

    # homebrew 用
    eval (/opt/homebrew/bin/brew shellenv)
    fish_add_path /opt/homebrew/bin

    # set -x PATH $HOME/.anyenv/bin $PATH
    # fish_add_path $HOME/.anyenv/bin
    # eval (anyenv init - | source)
    # (disabled) ssh-agent is managed by macOS launchd/Keychain
    # eval (ssh-agent -c)
    # (disabled) ssh-add is handled via AddKeysToAgent/UseKeychain
    # ssh-add ~/.ssh/id_ed25519
    # (disabled) do not auto-attach tmux on shell startup
    # tm
    starship init fish | source
    
    # asdf/mise は interactive のときだけ初期化（git hook 等の非対話シェルを軽くする）
    source /opt/homebrew/opt/asdf/libexec/asdf.fish
end

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
fish_add_path $HOME/.local/bin

# Added by Antigravity
fish_add_path /Users/yui.sakamoto/.antigravity/antigravity/bin
