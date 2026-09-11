# dotfiles2 .zshenv
#
# 全ての zsh (対話・非対話・スクリプト) で最初に読まれるファイル。
# ここには「非対話シェルでも必要なもの」だけを置く。
# git hook や Claude Code hook から起動されるシェルもここだけを読むため、
# PATH と環境変数はここで完結させる。
# 対話シェル専用の設定 (プラグイン・プロンプト・キーバインド) は
# $ZDOTDIR/.zshrc 側に書くこと。

# zsh の設定一式は ~/.config/zsh (dotfiles2/zsh への symlink) に置く。
# $HOME 直下に散らかさないための ZDOTDIR 方式。
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# macOS の Apple Terminal はセッション復元ファイルを $ZDOTDIR/.zsh_sessions へ
# 書き出す。ZDOTDIR が repo への symlink なので、そのままだと生成物が repo に
# 落ちる。出力先は /etc/zshrc_Apple_Terminal 側で無条件に代入されていて
# 上書きできないため、機能ごと止める（ghostty / cmux では元々使われない）。
export SHELL_SESSIONS_DISABLE=1

# PATH の重複を自動で除去する。ネストしたシェルで PATH が伸び続けるのを防ぐ。
typeset -U path PATH fpath

# --- Homebrew ---
# 非対話シェルでも brew 由来のコマンドを引けるようにする。
#
# 判定に HOMEBREW_PREFIX の有無を使ってはいけない。cmux や Claude Code から
# 起動されたシェルには HOMEBREW_PREFIX だけが継承されて PATH は引き継がれない
# ケースがあり、変数で見ると brew shellenv がスキップされて starship / mise /
# fzf などが軒並み無効になる (エラーも出ないので気付きにくい)。
# 実際に PATH が通っているかで判定すれば、その環境も二重実行の回避も両立できる。
#
# 中身は `brew shellenv zsh` と同じものを fork せずに直接書いている。
# brew shellenv は内部で path_helper まで呼ぶため 1 回あたり 20-30ms かかり、
# 全 zsh の起動が体感できるほど遅くなる (他の init は実測 0ms なので、
# ここだけが突出していた)。brew 側の出力が変わったら
# `brew shellenv zsh` と突き合わせて更新すること。
if [[ -x /opt/homebrew/bin/brew && ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
  export HOMEBREW_REPOSITORY="/opt/homebrew"
  path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
  export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
  export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
fi

# --- Go ---
export GOPATH="$HOME"
export GOBIN="$HOME/bin"

# --- pnpm ---
if [[ -d "$HOME/Library/pnpm" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
fi

# --- PATH ---
# mise の shims は非対話シェル用の経路。対話シェルでは .zshrc の
# `mise activate` がこれより優先される PATH を張るので競合しない。
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/go/bin"
  "$PNPM_HOME"
  "${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims"
  $path
)

# --- macOS (Apple Silicon) 固有 ---
if [[ "$OSTYPE" == darwin* ]]; then
  for _pc in \
    /opt/homebrew/opt/krb5/lib/pkgconfig \
    /opt/homebrew/opt/openssl@3/lib/pkgconfig \
    /opt/homebrew/opt/zlib/lib/pkgconfig
  do
    if [[ -d "$_pc" ]]; then
      export PKG_CONFIG_PATH="$_pc${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
    fi
  done
  unset _pc

  if [[ -d /opt/homebrew/opt/libpq/bin ]]; then
    path=(/opt/homebrew/opt/libpq/bin $path)
  fi
fi

# --- Claude Code hooks ---
# hook スクリプトが Obsidian の保存先を引くために使う。
export CLAUDE_OBSIDIAN_VAULT="$HOME/src/github.com/YuiSakamoto/obsidian/private/Claude Code"

# Unity CLI（インストーラの追記を移植性のある形に整えた。未導入マシンでは読み飛ばす）
[ -f "$HOME/.unity/env" ] && . "$HOME/.unity/env"
