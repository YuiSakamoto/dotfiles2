# キーバインド。fish の bind \cg / bind \cr 相当。
#
# メインキーマップの選択 (bindkey -e) は 00-options.zsh 側で先に済ませてある。
# fzf や fzf-tab がキーを張った後にキーマップを張り替えると、それらの
# バインドが丸ごと無効になるため。

# Ctrl+G: ghq 管理下のリポジトリを fzf で選んで移動する。
# fish の __ghq_repository_search の置き換え。
zle -N ghq-fzf
bindkey '^g' ghq-fzf

# Ctrl+R (履歴) は 30-tools.zsh の atuin が張る (fzf の履歴 widget を上書き)。
# Alt+C (cd) / Ctrl+O (ファイル挿入) は同ファイルの fzf 統合が張る。
# Ctrl+T は cmux のプレフィックス用に空けてある。

# Tab は fzf-tab に戻す。
# 30-tools.zsh の `fzf --zsh` が Tab を fzf 自身の fzf-completion
# (**<TAB> 方式) に張り替えてしまい、20-plugins.zsh で読んだ fzf-tab が
# 上書きされるため、両方を読み終えたこの位置で bindkey し直す。
if (( ${+functions[fzf-tab-complete]} )); then
  bindkey '^I' fzf-tab-complete
fi

# Ctrl+X ? : ショートカット早見表 (docs/SHORTCUTS.md) を開く。
# 入力途中の行は push-line で退避され、cheat を抜けると戻ってくる。
# Ctrl+X プレフィックスは zsh の emacs キーマップで空いており、
# cmux (Ctrl+T) とも fzf/atuin とも衝突しない。
cheat-widget() {
  zle push-line
  BUFFER='cheat'
  zle accept-line
}
zle -N cheat-widget
bindkey '^X?' cheat-widget

# 単語区切りから / を外し、Ctrl+W でパスを1階層ずつ削れるようにする
WORDCHARS="${WORDCHARS//\//}"
