# 外部ツールのシェル統合。未導入の環境でも落ちないよう全てガードする。

# --- fzf ---
# オプションは widget を張る前に export しておく。
# 配色は ghostty/config の CUD 準拠パレットに合わせる。
# bg は -1 にして端末の背景を透かし、ポップアップが浮かずに地続きに見せる。
# マッチ箇所 (hl) を朱色にしているのは、選択行の反転と重なっても
# 「どこが引っかかったか」が明度差で分かるようにするため。
export FZF_DEFAULT_OPTS="--height=60% --layout=reverse --border --info=inline
  --color=bg:-1,bg+:#252a3d,fg:#cbd5ee,fg+:#eef3ff,gutter:-1
  --color=hl:#ff5f45,hl+:#ff8a70,border:#4d9dff
  --color=prompt:#5fe3ff,pointer:#ff5f45,marker:#00d7a3
  --color=info:#7480a5,header:#ffd75f,spinner:#00d7a3"
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi
if command -v bat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range=:200 {}'"
fi

# Ctrl+R (履歴), Ctrl+T (ファイル), Alt+C (cd) を提供する。
# fish 時代の peco_select_history + bind \cr の置き換え。
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)

  # Ctrl+T は cmux のプレフィックスキー (tmux 時代からの手癖) に明け渡す。
  # cmux が握るのでシェルまで届かないはずだが、届いた場合に fzf が
  # 反応しないよう明示的に外し、ファイル挿入は Ctrl+O へ移す。
  bindkey -r '^T'
  bindkey '^o' fzf-file-widget
fi

# --- atuin (シェル履歴) ---
# fzf の履歴 widget を置き換える。SQLite に全履歴を貯め、実行ディレクトリ・
# 終了コード・実行時間つきで検索できる。
#
# fzf 統合より **後** に読むこと。`fzf --zsh` が Ctrl+R に張った
# fzf-history-widget を、ここで atuin の widget に上書きするため。
#
# --disable-up-arrow: ↑ は素の履歴移動のまま残す。atuin に渡すと直前の
# コマンドを ↑ 1回で呼び出す手癖が壊れるため。atuin の絞り込みを ↑ でも
# 使いたくなったらこのフラグを外す。
# 既存の zsh 履歴の取り込みは初回のみ手動で `atuin import auto`。
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# --- zoxide ---
# fish の z プラグイン (conf.d/z.fish + __z*.fish、約 210 行) の置き換え。
# --cmd z で `z <部分文字列>` / `zi` (対話選択) のキー操作を維持する。
# DB は ~/.local/share/zoxide に置かれる。
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd z)"
fi

# --- mise (ランタイム管理) ---
# 非対話シェルは .zshenv の shims 経由で解決するので、ここは対話時のみでよい。
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# --- starship (プロンプト) ---
# 設定は ~/.config/starship.toml。fish 時代からそのまま流用している。
# プロンプトを最後に初期化して、他のツールの precmd より後段に置く。
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
