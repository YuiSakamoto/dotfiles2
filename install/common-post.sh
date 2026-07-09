#!/usr/bin/env bash
# dotfiles2 共通の後処理インストーラ
#
# setup.sh install の最後に呼ばれる。
# apt / brew のパッケージリストに載らないもの (公式スクリプト導入推奨のもの、
# apt に無い/古いもの) を入れる。冪等 (導入済みならスキップ)。
set -euo pipefail

OS="$(uname -s)"
ARCH="$(uname -m)"
log() { printf '\033[1;34m[post]\033[0m %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

# GitHub release の tar.gz からバイナリ1つを ~/.local/bin に入れるヘルパー
# $1: コマンド名, $2: ダウンロードURL, $3: tar 内のバイナリパス
gh_bin_install() {
  local name="$1" url="$2" path_in_tar="$3" tmp
  have "$name" && return 0
  if [ "$ARCH" != "x86_64" ]; then
    log "skip $name (unsupported arch: $ARCH)"
    return 0
  fi
  log "installing $name"
  tmp=$(mktemp -d)
  curl -fsSL "$url" -o "$tmp/pkg.tgz"
  tar -xzf "$tmp/pkg.tgz" -C "$tmp"
  install -m 0755 "$tmp/$path_in_tar" "$BIN_DIR/$name"
  rm -rf "$tmp"
}

# GitHub release の zip からバイナリ1つを ~/.local/bin に入れるヘルパー
# $1: コマンド名, $2: ダウンロードURL, $3: zip 内のバイナリパス
gh_bin_install_zip() {
  local name="$1" url="$2" path_in_zip="$3" tmp
  have "$name" && return 0
  if [ "$ARCH" != "x86_64" ]; then
    log "skip $name (unsupported arch: $ARCH)"
    return 0
  fi
  log "installing $name"
  tmp=$(mktemp -d)
  curl -fsSL "$url" -o "$tmp/pkg.zip"
  unzip -q "$tmp/pkg.zip" -d "$tmp"
  install -m 0755 "$tmp/$path_in_zip" "$BIN_DIR/$name"
  rm -rf "$tmp"
}

# ---- starship (プロンプト) ----
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

# ---- atuin (シェル履歴) ----
# apt に無いので公式インストーラで。brew 側は Brewfile 済。
if [ "$OS" = "Linux" ] && ! have atuin; then
  log "installing atuin"
  curl --proto '=https' --tlsv1.2 -fsSL https://setup.atuin.sh | sh
fi

# ---- GitHub release 由来のバイナリ (Linux のみ、apt に無い/古いもの) ----
if [ "$OS" = "Linux" ]; then
  gh_bin_install eza \
    "https://github.com/eza-community/eza/releases/download/v0.23.4/eza_x86_64-unknown-linux-gnu.tar.gz" \
    "eza"
  gh_bin_install delta \
    "https://github.com/dandavison/delta/releases/download/0.19.2/delta-0.19.2-x86_64-unknown-linux-gnu.tar.gz" \
    "delta-0.19.2-x86_64-unknown-linux-gnu/delta"
  gh_bin_install lazygit \
    "https://github.com/jesseduffield/lazygit/releases/download/v0.63.0/lazygit_0.63.0_linux_x86_64.tar.gz" \
    "lazygit"
  gh_bin_install dust \
    "https://github.com/bootandy/dust/releases/download/v1.2.4/dust-v1.2.4-x86_64-unknown-linux-gnu.tar.gz" \
    "dust-v1.2.4-x86_64-unknown-linux-gnu/dust"
  gh_bin_install tldr \
    "https://github.com/tldr-pages/tlrc/releases/download/v1.13.1/tlrc-v1.13.1-x86_64-unknown-linux-gnu.tar.gz" \
    "tldr"
  gh_bin_install_zip ghq \
    "https://github.com/x-motemen/ghq/releases/download/v1.10.1/ghq_linux_amd64.zip" \
    "ghq_linux_amd64/ghq"
  gh_bin_install hunk \
    "https://github.com/modem-dev/hunk/releases/download/v0.17.0/hunkdiff-linux-x64.tar.gz" \
    "hunkdiff-linux-x64/hunk"
fi

# ---- fd / bat の alias 作成 (Debian/Ubuntu) ----
# apt だと fd=fdfind, bat=batcat で入るので ~/.local/bin に symlink を張る
if [ "$OS" = "Linux" ]; then
  if have fdfind && ! have fd; then
    log "linking fdfind -> fd"
    ln -sf "$(command -v fdfind)" "$BIN_DIR/fd"
  fi
  if have batcat && ! have bat; then
    log "linking batcat -> bat"
    ln -sf "$(command -v batcat)" "$BIN_DIR/bat"
  fi
fi

# ---- tpm (tmux plugin manager, 両OS共通) ----
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  log "installing tpm"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# ---- win32yank (WSL のみ: nvim/tmux のクリップボード連携) ----
if [ "$OS" = "Linux" ] && grep -qi microsoft /proc/version 2>/dev/null && ! have win32yank.exe; then
  log "installing win32yank"
  tmp=$(mktemp -d)
  curl -fsSL "https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip" -o "$tmp/win32yank.zip"
  unzip -q "$tmp/win32yank.zip" -d "$tmp"
  install -m 0755 "$tmp/win32yank.exe" "$BIN_DIR/win32yank.exe"
  rm -rf "$tmp"
fi

log "common-post.sh done."
