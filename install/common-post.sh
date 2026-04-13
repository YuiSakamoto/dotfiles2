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
