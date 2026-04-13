#!/usr/bin/env bash
# dotfiles2 setup
#
# Usage:
#   ./setup.sh              # link (default)
#   ./setup.sh link         # create symlinks only
#   ./setup.sh install      # install packages only (brew / apt)
#   ./setup.sh all          # install packages, then link
#   ./setup.sh --dry-run    # print actions without executing (combinable)
#
# macOS / Linux (Debian系・WSL含む) 両対応。
# 既存ファイルは dotfiles-backup-<timestamp>/ に退避してから symlink する。
set -euo pipefail

DRY_RUN=0
CMD="link"

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    link|install|all) CMD="$arg" ;;
    -h|--help)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "unknown arg: $arg" >&2; exit 1 ;;
  esac
done

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

log() { printf '\033[1;34m[setup]\033[0m %s\n' "$*"; }

run() {
  if [ "$DRY_RUN" = 1 ]; then
    printf '\033[1;33m[dry-run]\033[0m %s\n' "$*"
  else
    "$@"
  fi
}

# $1 target path, $2 expected link source
# returns 0 if caller should proceed with linking, 1 if already correct
backup_if_exists() {
  local target="$1" src="$2"
  if [ -L "$target" ]; then
    if [ "$(readlink "$target")" = "$src" ]; then
      log "already linked: $target"
      return 1
    fi
    log "replace stale symlink: $target"
    run rm "$target"
    return 0
  fi
  if [ -e "$target" ]; then
    mkdir -p "$BACKUP_DIR"
    log "backup: $target -> $BACKUP_DIR/"
    run mv "$target" "$BACKUP_DIR/"
  fi
  return 0
}

link() {
  local src="$1" dst="$2"
  if [ ! -e "$src" ]; then
    log "skip (missing src): $src"
    return
  fi
  if backup_if_exists "$dst" "$src"; then
    run mkdir -p "$(dirname "$dst")"
    run ln -s "$src" "$dst"
    log "linked: $dst -> $src"
  fi
}

link_home() {
  link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
  link "$DOTFILES_DIR/.gitignore" "$HOME/.gitignore"
  link "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
}

link_config() {
  local targets=(fish nvim starship.toml mise)
  if [ "$OS" = "Darwin" ]; then
    targets+=(karabiner wezterm)
  fi
  for t in "${targets[@]}"; do
    link "$DOTFILES_DIR/$t" "$HOME/.config/$t"
  done
}

link_claude() {
  # ~/.claude 以下のランタイム状態 (credentials, sessions, projects 等) を
  # 巻き込まないよう、リポジトリで管理する個別ファイル/ディレクトリだけを symlink する。
  local items=(CLAUDE.md agents commands skills scripts settings.json mcp-setup.sh .env.example)
  run mkdir -p "$HOME/.claude"
  for item in "${items[@]}"; do
    link "$DOTFILES_DIR/.claude/$item" "$HOME/.claude/$item"
  done
}

link_bin() {
  local bin_dir="$HOME/.local/bin"
  run mkdir -p "$bin_dir"
  local f
  for f in "$DOTFILES_DIR"/bin/*; do
    [ -f "$f" ] || continue
    link "$f" "$bin_dir/$(basename "$f")"
  done
}

install_packages() {
  case "$OS" in
    Darwin)
      if ! command -v brew >/dev/null 2>&1; then
        log "Homebrew が見つかりません。https://brew.sh から導入してください。"
        exit 1
      fi
      log "brew bundle"
      run brew bundle --file="$DOTFILES_DIR/install/Brewfile"
      ;;
    Linux)
      if ! command -v apt-get >/dev/null 2>&1; then
        log "apt-get が見つかりません。現状は Debian/Ubuntu のみ対応しています。"
        exit 1
      fi
      local pkgs
      pkgs=$(grep -vE '^\s*(#|$)' "$DOTFILES_DIR/install/apt-packages.txt" | tr '\n' ' ')
      run sudo apt-get update
      # shellcheck disable=SC2086
      run sudo apt-get install -y $pkgs
      ;;
    *)
      log "unsupported OS: $OS"; exit 1 ;;
  esac
  if [ -x "$DOTFILES_DIR/install/common-post.sh" ]; then
    log "running common-post.sh"
    run "$DOTFILES_DIR/install/common-post.sh"
  fi
}

log "OS=$OS DOTFILES_DIR=$DOTFILES_DIR DRY_RUN=$DRY_RUN CMD=$CMD"

case "$CMD" in
  link)    link_home; link_config; link_claude; link_bin ;;
  install) install_packages ;;
  all)     install_packages; link_home; link_config; link_claude; link_bin ;;
esac

if [ -d "$BACKUP_DIR" ]; then
  log "backups saved to: $BACKUP_DIR"
fi
log "done."
