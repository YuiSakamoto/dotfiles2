# 基本オプションと履歴設定

# --- キーマップ ---
# ここで先にメインキーマップを確定させる。
# EDITOR に "vi" が含まれる (nvim も該当する) と zsh は起動時に viins を
# メインキーマップに選ぶ。その状態で fzf や fzf-tab がキーを張った後に
# bindkey -e で emacs へ張り替えると、張ったバインドが全部無効になる。
# したがってプラグイン・ツールがキーを張る前のこの位置で宣言しておく。
bindkey -e

# --- 履歴 ---
# 履歴の実体は $ZDOTDIR (= dotfiles2 repo への symlink) ではなく XDG の
# state ディレクトリに置く。ここを間違えると repo が履歴で汚れる。
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=100000
SAVEHIST=100000
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

setopt EXTENDED_HISTORY        # 実行時刻と所要時間も記録する
setopt SHARE_HISTORY           # 複数ペイン間で履歴を即座に共有する
setopt HIST_IGNORE_ALL_DUPS    # 重複コマンドは古い方を捨てる
setopt HIST_IGNORE_SPACE       # 行頭スペース付きのコマンドは残さない
setopt HIST_REDUCE_BLANKS      # 余分な空白を詰めて記録する
setopt HIST_VERIFY             # 履歴展開は実行前に一度確認させる
setopt HIST_NO_STORE           # history コマンド自体は履歴に残さない

# --- ディレクトリ移動 ---
setopt AUTO_CD                 # ディレクトリ名だけで cd する
setopt AUTO_PUSHD              # cd のたびにディレクトリスタックへ積む
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# --- 入力まわり ---
setopt INTERACTIVE_COMMENTS    # 対話行でも # 以降をコメントとして扱う
setopt EXTENDED_GLOB
setopt NO_BEEP
setopt NO_FLOW_CONTROL         # Ctrl+S / Ctrl+Q を端末に奪わせない
