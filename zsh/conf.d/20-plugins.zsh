# sheldon によるプラグイン読み込み
#
# プラグインの定義は ~/.config/sheldon/plugins.toml (dotfiles2/sheldon)。
# プラグインの実体と lock ファイルは ~/.local/share/sheldon 配下に置かれるので
# repo は汚れない。
#
# compinit (10-completion.zsh) の後でなければ fzf-tab が機能しないため、
# このファイルを 10 より前に動かさないこと。

if command -v sheldon >/dev/null 2>&1; then
  eval "$(sheldon source)"
fi

# --- fzf-tab ---
# タブ補完を fzf のポップアップにする。fzf 本体のキーバインド (Ctrl+R 等) は
# 30-tools.zsh 側が担当する。
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'eza -1 --icons --color=always $realpath 2>/dev/null || ls -1 $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview \
  'eza -1 --icons --color=always $realpath 2>/dev/null || ls -1 $realpath'

# --- zsh-autosuggestions ---
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# widget を都度再バインドしない。起動と貼り付けの両方が速くなる。
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
