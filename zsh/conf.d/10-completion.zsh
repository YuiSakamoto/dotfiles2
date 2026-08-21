# 補完 (compinit) の初期化
#
# fzf-tab をはじめとする補完系プラグインは compinit の後に読む必要があるため、
# このファイルは必ず 20-plugins.zsh より前に置くこと。

# 追加の補完定義を fpath へ足す。compinit より前でなければ効かない。
fpath=(
  "${ZDOTDIR:-$HOME/.config/zsh}/functions"
  ${HOMEBREW_PREFIX:+"$HOMEBREW_PREFIX/share/zsh-completions"}
  ${HOMEBREW_PREFIX:+"$HOMEBREW_PREFIX/share/zsh/site-functions"}
  $fpath
)

# zsh/functions/ 配下は 1ファイル 1関数の autoload 関数として登録する
# (fish の functions/ と同じ構成)
autoload -Uz "${ZDOTDIR:-$HOME/.config/zsh}"/functions/*(N:t)

# 補完キャッシュは repo を汚さないよう ~/.cache 配下へ置く
typeset -g _zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
[[ -d "${_zcompdump:h}" ]] || mkdir -p "${_zcompdump:h}"

zmodload -F zsh/stat b:zstat
zmodload zsh/datetime

autoload -Uz compinit
# ダンプが 24 時間以内なら安全性チェックを省略して起動を速くする (-C)。
# 24 時間を超えていたら通常の compinit でダンプを作り直す。
typeset -a _zcompdump_stat
if zstat -A _zcompdump_stat +mtime "$_zcompdump" 2>/dev/null \
  && (( EPOCHSECONDS - _zcompdump_stat[1] < 86400 )); then
  compinit -C -d "$_zcompdump"
else
  compinit -d "$_zcompdump"
fi
unset _zcompdump _zcompdump_stat

# --- 補完の見た目と挙動 ---
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"

# 大文字小文字を無視し、. _ - 区切りの途中一致も許す
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'

# cd の候補にカレントディレクトリを出さない
zstyle ':completion:*:cd:*' ignore-parents parent pwd
