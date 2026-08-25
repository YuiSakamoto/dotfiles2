#!/usr/bin/env bash
# dotfiles2 setup
#
# Usage:
#   ./setup.sh              # link (default)
#   ./setup.sh link         # create symlinks only
#   ./setup.sh install      # install packages only (brew / apt)
#   ./setup.sh all          # install packages, then link
#   ./setup.sh doctor       # verify environment state (symlinks, secrets, syntax)
#   ./setup.sh --dry-run    # print actions without executing (combinable)
#
# macOS / Linux (Debian系・WSL含む) 両対応。
# 既存ファイルは dotfiles-backup-<timestamp>/ に退避してから symlink する。
set -euo pipefail

DRY_RUN=0
CMD="link"
INSTALL_FAILED=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    link|install|all|doctor) CMD="$arg" ;;
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
    # --dry-run 時に実際のディレクトリを作らないよう run を通す
    run mkdir -p "$BACKUP_DIR"
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

# 管理対象から外したファイルを $HOME から退去させる。
# 実体が残っていると「消したはずの設定がまだ効いている」状態になるため、
# link はせずバックアップへ退避だけする。
retire() {
  local target="$1" reason="$2"
  if [ -e "$target" ] || [ -L "$target" ]; then
    run mkdir -p "$BACKUP_DIR"
    log "retire ($reason): $target -> $BACKUP_DIR/"
    run mv "$target" "$BACKUP_DIR/"
  fi
}

link_home() {
  link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
  link "$DOTFILES_DIR/.gitignore" "$HOME/.gitignore"
  link "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

  # zsh は ZDOTDIR 方式。$HOME に置くのは .zshenv だけで、残りは
  # ~/.config/zsh に集約する。
  link "$DOTFILES_DIR/.zshenv" "$HOME/.zshenv"
  # ZDOTDIR を設定すると ~/.zshrc は読まれなくなるので、実体が残っていたら退避する
  if [ ! -L "$HOME/.zshrc" ]; then
    retire "$HOME/.zshrc" "ZDOTDIR 方式では読まれないため"
  fi
}

link_config() {
  # zsh 一式・sheldon・ghostty・cmux もすべてディレクトリごと symlink する。
  # ~/.config 配下に実体ファイルを置かず、repo を唯一の正とするため。
  local targets=(zsh sheldon atuin fish nvim starship.toml mise herdr)
  if [ "$OS" = "Darwin" ]; then
    # ghostty は cmux (内蔵ターミナル) の見た目設定を兼ねる
    targets+=(karabiner ghostty cmux)
  fi
  for t in "${targets[@]}"; do
    link "$DOTFILES_DIR/$t" "$HOME/.config/$t"
  done
}

link_claude() {
  # ~/.claude 以下のランタイム状態 (credentials, sessions, projects 等) を
  # 巻き込まないよう、リポジトリで管理する個別ファイル/ディレクトリだけを symlink する。
  local items=(CLAUDE.md agents skills scripts settings.json mcp-setup.sh .env.example)
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
      # hashicorp/tap は非公式 tap なので、trust しないと formula の読み込みが拒否される
      if brew trust --help >/dev/null 2>&1; then
        run brew trust --tap hashicorp/tap
      fi
      log "brew bundle"
      if ! run brew bundle --file="$DOTFILES_DIR/install/Brewfile"; then
        log "brew bundle に失敗しました（後続の処理は続行します）"
        INSTALL_FAILED=1
      fi
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
      if ! run sudo apt-get install -y $pkgs; then
        log "apt-get install に失敗しました（後続の処理は続行します）"
        INSTALL_FAILED=1
      fi
      ;;
    *)
      log "unsupported OS: $OS"; exit 1 ;;
  esac
  if [ -x "$DOTFILES_DIR/install/common-post.sh" ]; then
    log "running common-post.sh"
    if ! run "$DOTFILES_DIR/install/common-post.sh"; then
      log "common-post.sh に失敗しました（後続の処理は続行します）"
      INSTALL_FAILED=1
    fi
  fi
}

log "OS=$OS DOTFILES_DIR=$DOTFILES_DIR DRY_RUN=$DRY_RUN CMD=$CMD"

case "$CMD" in
  link)    link_home; link_config; link_claude; link_bin ;;
  install) install_packages ;;
  all)     install_packages; link_home; link_config; link_claude; link_bin ;;
  doctor)  exec "$DOTFILES_DIR/bin/dotfiles-doctor" ;;
esac

if [ -d "$BACKUP_DIR" ]; then
  log "backups saved to: $BACKUP_DIR"
fi

# パッケージ導入に失敗していても symlink 配置は完了させ、終了コードで失敗を伝える
if [ "$INSTALL_FAILED" = 1 ]; then
  log "done (パッケージ導入に失敗したものがあります)。"
  exit 1
fi
log "done."
