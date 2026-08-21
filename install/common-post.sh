#!/usr/bin/env bash
# dotfiles2 共通の後処理インストーラ
#
# setup.sh install の最後に呼ばれる。
# apt / brew のパッケージリストに載らないもの (公式スクリプト導入推奨のもの等) を入れる。
set -euo pipefail

OS="$(uname -s)"
log() { printf '\033[1;34m[post]\033[0m %s\n' "$*"; }

have() { command -v "$1" >/dev/null 2>&1; }

# ---- starship ----
# apt には無いので公式スクリプトで。brew 側は Brewfile 済。
if [ "$OS" = "Linux" ] && ! have starship; then
  log "installing starship"
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
fi

# ---- zsh compinit のためのディレクトリ権限修正 (macOS/Homebrew) ----
# Homebrew は $(brew --prefix)/share を group(admin) 書き込み可で作る。
# zsh の compinit はこれを "insecure directories" と判定し、対話プロンプトを
# 出したうえで補完の初期化ごと中断してしまう (補完が丸ごと死ぬ)。
# 所有者の権限はそのままに group の書き込みだけ落とせば解消する。
# brew 自身は所有者として動くので install/upgrade には影響しない。
if [ "$OS" = "Darwin" ] && have brew; then
  brew_prefix="$(brew --prefix)"
  for d in \
    "$brew_prefix/share" \
    "$brew_prefix/share/zsh" \
    "$brew_prefix/share/zsh/site-functions" \
    "$brew_prefix/share/zsh-completions"
  do
    [ -d "$d" ] || continue
    # group 書き込み可のときだけ chmod する (毎回叩かない)
    if [ -n "$(find "$d" -maxdepth 0 -perm -g+w 2>/dev/null)" ]; then
      log "fixing group-writable dir for zsh compinit: $d"
      chmod g-w "$d"
    fi
  done
fi

# ---- sheldon (zsh プラグインマネージャ) ----
# apt には無いので公式インストーラで。brew 側は Brewfile 済。
if [ "$OS" = "Linux" ] && ! have sheldon; then
  log "installing sheldon"
  mkdir -p "$HOME/.local/bin"
  curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
    | bash -s -- --repo rossmacarthur/sheldon --to "$HOME/.local/bin"
fi

# ---- mise (asdf 互換のランタイム管理) ----
if ! have mise; then
  log "installing mise"
  curl -fsSL https://mise.run | sh
fi

# ---- peco ----
# apt の版は古いことがあるため GitHub release から。Linux のみ。
if [ "$OS" = "Linux" ] && ! have peco; then
  log "installing peco"
  tmp=$(mktemp -d)
  ver="v0.5.11"
  curl -fsSL "https://github.com/peco/peco/releases/download/${ver}/peco_linux_amd64.tar.gz" \
    -o "$tmp/peco.tgz"
  tar -xzf "$tmp/peco.tgz" -C "$tmp"
  mkdir -p "$HOME/.local/bin"
  install -m 0755 "$tmp/peco_linux_amd64/peco" "$HOME/.local/bin/peco"
  rm -rf "$tmp"
fi

# ---- fd / bat の alias 作成 (Debian/Ubuntu) ----
# apt だと fd=fdfind, bat=batcat で入るので ~/.local/bin に symlink を張る
if [ "$OS" = "Linux" ]; then
  mkdir -p "$HOME/.local/bin"
  if have fdfind && ! have fd; then
    log "linking fdfind -> fd"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
  if have batcat && ! have bat; then
    log "linking batcat -> bat"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi
fi

# ---- fisher (fish plugin manager) ----
if have fish && ! fish -c "type -q fisher" 2>/dev/null; then
  log "installing fisher"
  fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" || true
fi

log "common-post.sh done."
