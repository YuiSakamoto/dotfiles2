# dotfiles2 モダナイズ実装計画

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** dotfiles2 を macOS/WSL 両対応のままモダナイズする(starship/atuin/zoxide/LazyVim/tpm 移行、旧 brewfile リポジトリ統合、モダン CLI 導入)。

**Architecture:** 既存の setup.sh + install/ の仕組みは維持し、中身(パッケージ定義・fish 設定・nvim 設定・tmux 設定・gitconfig)を置き換える。パッケージ導入 → 各設定刷新 → 検証基盤(doctor)更新 → 旧リポジトリ退役 → ドキュメント、の順で進める。

**Tech Stack:** bash(setup.sh), fish, starship, atuin, zoxide, fzf, eza, git-delta, lazygit, LazyVim(lazy.nvim + Lua), tmux + tpm, Homebrew / apt

**Spec:** `docs/superpowers/specs/2026-07-07-dotfiles-modernization-design.md`

## Global Constraints

- エイリアス・キーバインドの操作感は維持する(tmux prefix `^T`、vim風ペイン移動、`;`↔`:` スワップ、git エイリアス全維持)。例外: `ij`(IntelliJ 廃止に伴い削除)
- fish の新ツール初期化は必ず `type -q <tool>` ガード付き(未導入環境でエラーにしない)
- Linux 側インストールは x86_64 のみ対応(既存 peco 導入と同方針)。それ以外のアーキテクチャはスキップしてログを出す
- コミットは Conventional Commits 形式、コメントは日本語
- 編集後の構文検証は PostToolUse hook が自動実行する(fish -n / bash -n + shellcheck / jq)。失敗したら修正必須
- 実機は macOS。Linux/WSL 経路はコードレビューと `--dry-run` で担保し、README に検証未実施と記載する

---

### Task 1: install/Brewfile 統合改訂 + パッケージ導入

**Files:**
- Modify: `install/Brewfile`(全面書き換え)

**Interfaces:**
- Produces: 以降の全タスクが前提とする CLI ツール群(delta, atuin, zoxide, eza, lazygit, starship, fzf 等)が実機に入る

- [ ] **Step 1: Brewfile を全面書き換え**

`install/Brewfile` を以下の内容に置き換える:

```ruby
# dotfiles2 Brewfile (macOS)
#
# 実行: ./setup.sh install  (内部で brew bundle --file=install/Brewfile)
#
# 旧 YuiSakamoto/brewfile リポジトリを統合済み (2026-07)。
# brew パッケージの管理元はこのファイルに一本化する。
# CLI は install/apt-packages.txt と揃えてあり、Linux側はそちらを見る。

cask_args appdir: "/Applications"

tap "homebrew/bundle"
tap "homebrew/services"
tap "delphinus/claude-code-hooks"

# --- CLI 基本 ---
brew "bash"
brew "coreutils"
brew "findutils"
brew "gnu-sed"
brew "gnu-tar"
brew "watch"
brew "tree"
brew "curl"
brew "wget"
brew "openssl"
brew "pkg-config"
brew "jq"

# --- Git ---
brew "git"
brew "gh"
brew "ghq"
brew "tig"
brew "git-delta"   # git の pager (diff 表示)
brew "lazygit"     # git TUI

# --- シェル / エディタ / マルチプレクサ ---
brew "fish"
brew "starship"    # プロンプト
brew "neovim"
brew "tmux"
brew "herdr"       # エージェント対応マルチプレクサ

# --- モダン CLI ---
brew "fzf"
brew "ripgrep"
brew "fd"
brew "bat"
brew "eza"         # ls 代替
brew "zoxide"      # ディレクトリジャンプ (z)
brew "atuin"       # シェル履歴 (Ctrl+R)
brew "btop"        # top 代替
brew "dust"        # du 代替
brew "duf"         # df 代替
brew "tlrc"        # tldr クライアント

# --- DB ---
brew "mycli"
brew "libpq"

# --- Runtimes / Version managers ---
brew "mise"
brew "go"
brew "rust"
brew "deno"

# --- Cloud / Infra ---
brew "awscli"
brew "terraform"
brew "tflint"
brew "kubectl"
brew "minikube"
brew "docker-compose"

# --- Build / graph / doc ---
brew "graphviz"
brew "plantuml"
brew "marp-cli"

# --- 通知 / hooks ---
brew "terminal-notifier"
brew "delphinus/claude-code-hooks/claude-code-hooks"

# --- Cask: ターミナル ---
cask "ghostty"
cask "iterm2"

# --- Cask: 開発 ---
cask "visual-studio-code"
cask "docker"
cask "dbeaver-community"
cask "insomnia"
cask "ngrok"
cask "google-cloud-sdk"

# --- Cask: ユーティリティ ---
cask "raycast"            # ランチャー (clipboard/window管理も担う)
cask "karabiner-elements"
cask "bartender"
cask "1password"
cask "1password-cli"

# --- Cask: ドキュメント / 知識 ---
cask "notion"
cask "notion-calendar"
cask "obsidian"
cask "kindle"
cask "anki"
cask "zotero"

# --- Cask: コミュニケーション / 言語 ---
cask "discord"
cask "deepl"
cask "grammarly-desktop"

# --- Cask: ブラウザ ---
cask "firefox"
cask "google-chrome"

# --- Cask: フォント ---
cask "font-hackgen-nerd"      # 日本語対応 Nerd Font (starship/eza/LazyVim のアイコン表示に必要)
cask "font-noto-sans-cjk-jp"
```

- [ ] **Step 2: Brewfile の構文と解決可能性を確認**

Run: `brew bundle check --file=install/Brewfile; echo "exit=$?"`
Expected: 未導入パッケージが列挙される(構文エラーが出ないこと)。`Error:` で始まる出力があれば formula 名を修正する

- [ ] **Step 3: パッケージ導入**

Run: `brew bundle --file=install/Brewfile`
Expected: 成功。以降のタスクで使う delta/atuin/zoxide/eza/lazygit/tlrc 等が入る

Run: `for t in delta atuin zoxide eza lazygit dust duf tldr btop; do command -v $t || echo "MISSING: $t"; done`
Expected: MISSING なし

- [ ] **Step 4: Commit**

```bash
git add install/Brewfile
git commit -m "feat: Brewfileを全面改訂(旧brewfileリポジトリ統合+モダンCLI導入)"
```

---

### Task 2: apt-packages.txt / common-post.sh の Linux 経路整備

**Files:**
- Modify: `install/apt-packages.txt`
- Modify: `install/common-post.sh`(全面書き換え)

**Interfaces:**
- Produces: Linux/WSL で Task 1 と同等の CLI が入る導入経路。`~/.tmux/plugins/tpm`(Task 6 が前提とする)、WSL では `win32yank.exe`(Task 7 の clipboard が前提とする)

- [ ] **Step 1: apt-packages.txt に追記**

「CLI ユーティリティ」セクションに以下を追加:

```
zoxide
btop
duf
tig
```

- [ ] **Step 2: common-post.sh を全面書き換え**

```bash
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
    "https://github.com/eza-community/eza/releases/download/v0.21.3/eza_x86_64-unknown-linux-gnu.tar.gz" \
    "eza"
  gh_bin_install delta \
    "https://github.com/dandavison/delta/releases/download/0.18.2/delta-0.18.2-x86_64-unknown-linux-gnu.tar.gz" \
    "delta-0.18.2-x86_64-unknown-linux-gnu/delta"
  gh_bin_install lazygit \
    "https://github.com/jesseduffield/lazygit/releases/download/v0.50.0/lazygit_0.50.0_Linux_x86_64.tar.gz" \
    "lazygit"
  gh_bin_install dust \
    "https://github.com/bootandy/dust/releases/download/v1.1.2/dust-v1.1.2-x86_64-unknown-linux-gnu.tar.gz" \
    "dust-v1.1.2-x86_64-unknown-linux-gnu/dust"
  gh_bin_install tldr \
    "https://github.com/tldr-pages/tlrc/releases/download/v1.11.0/tlrc-v1.11.0-x86_64-unknown-linux-gnu.tar.gz" \
    "tldr"
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
```

注意: `gh_bin_install` の各バージョンは実装時に GitHub releases の最新安定版を確認して更新すること(上記は 2026-07 時点の想定値。tar 内パスもリリースページで実物を確認する)。

- [ ] **Step 3: 構文検証**

Run: `bash -n install/common-post.sh && shellcheck install/common-post.sh`
Expected: エラーなし(hook でも自動検証される)

- [ ] **Step 4: dry-run で install 経路の回帰がないことを確認**

Run: `./setup.sh install --dry-run`
Expected: macOS では `brew bundle` の dry-run 表示のみ。エラーなし

- [ ] **Step 5: Commit**

```bash
git add install/apt-packages.txt install/common-post.sh
git commit -m "feat: Linux/WSL向けにモダンCLIの導入経路を整備(peco/fisher導入を廃止)"
```

---

### Task 3: git 設定強化 (delta + モダンデフォルト)

**Files:**
- Modify: `.gitconfig`

**Interfaces:**
- Consumes: Task 1 で導入した `delta`
- Produces: なし(独立)

- [ ] **Step 1: .gitconfig を編集**

既存の `[core]` セクションに `pager = delta` を追加し、既存 `[merge]` に `conflictstyle = zdiff3` を追加。ファイル末尾(`[safe]` セクションの後)に以下を追加する。**既存のエイリアス・セクションは一切削除しない**:

```ini
# --- モダンデフォルト (2026-07 モダナイズで追加) ---
[interactive]
	diffFilter = delta --color-only
[delta]
	navigate = true          # n/N で diff セクション間を移動
	line-numbers = true
[push]
	autoSetupRemote = true   # 初回 push で -u 不要にする
[fetch]
	prune = true
[rerere]
	enabled = true           # 解決済みコンフリクトを記憶して再適用
[branch]
	sort = -committerdate
[tag]
	sort = version:refname
[diff]
	algorithm = histogram
	colorMoved = default
[commit]
	verbose = true           # commit メッセージ編集時に diff を表示
[column]
	ui = auto
[help]
	autocorrect = prompt
```

注意: 既存 `[push] default = tracking` と `[branch] autosetuprebase = always` はそのまま残す(git は同名セクションの複数出現を許容する)。

- [ ] **Step 2: 動作確認**

Run: `git -c include.path= config --file .gitconfig --list | grep -E 'delta|zdiff3|autosetupremote|rerere'`
Expected: 追加した設定が列挙される

Run: `GIT_CONFIG_GLOBAL=.gitconfig git diff HEAD~1 -- install/Brewfile | head -20`
Expected: delta による行番号付きの色付き diff が表示される

- [ ] **Step 3: Commit**

```bash
git add .gitconfig
git commit -m "feat: gitにdelta pagerとモダンデフォルト(zdiff3/rerere等)を追加"
```

---

### Task 4: fish 刷新 (bobthefish/peco/z 削除 → starship/atuin/zoxide/fzf)

**Files:**
- Delete: `fish/functions/fish_prompt.fish`, `fish_right_prompt.fish`, `fish_mode_prompt.fish`, `copy-fish_prompt.fish`, `bobthefish_display_colors.fish`, `__bobthefish_colors.fish`, `__bobthefish_display_colors.fish`, `__bobthefish_glyphs.fish`
- Delete: `fish/functions/peco_select_history.fish`, `peco_kill.fish`
- Delete: `fish/functions/__z.fish`, `__z_add.fish`, `__z_clean.fish`, `__z_complete.fish`, `fish/conf.d/z.fish`
- Delete: `fish/functions/fisher.fish`, `fish/fish_plugins`
- Create: `fish/conf.d/tools.fish`
- Create: `fish/functions/fkill.fish`
- Modify: `fish/conf.d/config.fish`(全面書き換え)
- Modify: `fish/conf.d/alias.fish`

**Interfaces:**
- Consumes: Task 1/2 で導入した starship, atuin, zoxide, fzf, eza, lazygit
- Produces: `fkill` 関数、`lg`/`ls`系エイリアス

- [ ] **Step 1: 旧ファイル削除**

```bash
git rm fish/functions/fish_prompt.fish fish/functions/fish_right_prompt.fish \
  fish/functions/fish_mode_prompt.fish fish/functions/copy-fish_prompt.fish \
  fish/functions/bobthefish_display_colors.fish fish/functions/__bobthefish_colors.fish \
  fish/functions/__bobthefish_display_colors.fish fish/functions/__bobthefish_glyphs.fish \
  fish/functions/peco_select_history.fish fish/functions/peco_kill.fish \
  fish/functions/__z.fish fish/functions/__z_add.fish fish/functions/__z_clean.fish \
  fish/functions/__z_complete.fish fish/conf.d/z.fish \
  fish/functions/fisher.fish fish/fish_plugins
```

注意: `fish/functions/` の実ファイル名は `ls fish/functions/` で確認してから実行する(bobthefish 系のファイル構成が上記と異なる場合はあるものだけ削除)。

- [ ] **Step 2: config.fish を全面書き換え**

```fish
# fish 全体設定
# プロンプト(starship)・履歴(atuin)・ジャンプ(zoxide)の初期化は tools.fish 参照

# ghq リポジトリ選択 (Ctrl+G) のセレクタ
set -gx GHQ_SELECTOR fzf

# secrets は ~/.config/fish/conf.d/secrets.fish に置く (git 追跡外)

# Claude Code Hooks: Obsidian保存先
set -gx CLAUDE_OBSIDIAN_VAULT "$HOME/src/github.com/YuiSakamoto/obsidian/private/Claude Code"
```

- [ ] **Step 3: tools.fish を新規作成**

```fish
# モダンCLIツールの初期化
# いずれも未導入環境ではスキップされる (エラーにしない)

# starship: プロンプト
if type -q starship
    starship init fish | source
end

# atuin: Ctrl+R 履歴検索 (上矢印の挙動は変えない)
if type -q atuin
    atuin init fish --disable-up-arrow | source
end

# zoxide: ディレクトリジャンプ (z コマンド)
if type -q zoxide
    zoxide init fish | source
end
```

- [ ] **Step 4: fkill.fish を新規作成**

```fish
function fkill -d "fzf でプロセスを選んで kill する"
    if not type -q fzf
        echo "fkill: fzf が見つかりません" >&2
        return 1
    end
    set -l pids (ps -ef | sed 1d | fzf -m --header='[kill process]' | awk '{print $2}')
    if test -n "$pids"
        echo $pids | xargs kill -9
    end
end
```

- [ ] **Step 5: alias.fish を編集**

`alias ij='open -b com.jetbrains.intellij'` の行を削除し、ファイル末尾に追加:

```fish
# モダンCLI (未導入なら素の ls 等のまま)
if type -q eza
    alias ls='eza --icons'
    alias ll='eza -l --icons --git'
    alias la='eza -la --icons --git'
    alias lt='eza --tree --icons --level=2'
end
if type -q lazygit
    alias lg='lazygit'
end
```

- [ ] **Step 6: 構文・動作検証**

Run: `for f in fish/conf.d/*.fish fish/functions/*.fish; fish -n $f || echo "FAIL: $f"; end`(fish で実行)
Expected: FAIL なし

Run: `fish -l -c 'type -q starship; and echo prompt-ok; functions -q fkill; and echo fkill-ok; z --help >/dev/null 2>&1; or type -q __zoxide_z; and echo z-ok'`
Expected: `prompt-ok`, `fkill-ok`, `z-ok`(symlink 済みの実環境で。未リンクならスキップし Task 10 の最終検証で確認)

- [ ] **Step 7: Commit**

```bash
git add -A fish/
git commit -m "feat: fishをモダナイズ(bobthefish/peco/z廃止、starship/atuin/zoxide/eza導入)"
```

---

### Task 5: starship.toml 拡充

**Files:**
- Modify: `starship.toml`(全面書き換え)

**Interfaces:**
- Consumes: Task 4 の `starship init fish`、Task 1 の font-hackgen-nerd(アイコン表示)
- Produces: なし

- [ ] **Step 1: starship.toml を全面書き換え**

既存の見た目(❯ シンボル、username 🌱、AWS region 別名 jp)は維持しつつ、git status・言語バージョン・実行時間・k8s を有効化する:

```toml
# starship プロンプト設定
# Nerd Font (HackGen Nerd) 前提

command_timeout = 2000
scan_timeout = 50

[character]
error_symbol = "[❯](bold red)"
success_symbol = "[❯](bold green)"

[username]
style_user = "white bold"
style_root = "black bold"
format = "[$user🌱]($style) "
disabled = false
show_always = true

[directory]
truncation_length = 100
truncate_to_repo = false
truncation_symbol = "…/"

[git_branch]
symbol = " "

# モダナイズで有効化: 変更あり/ahead-behind をプロンプトに表示
[git_status]
disabled = false

[git_state]
disabled = false

[cmd_duration]
min_time = 2000
format = "took [$duration](bold yellow) "

# --- 言語バージョン (プロジェクト内でのみ表示される) ---
[nodejs]
format = "via [ $version](bold green) "

[golang]
format = "via [ $version](bold cyan) "

[python]
format = "via [ $version](bold blue) "

[rust]
format = "via [ $version](bold red) "

# --- インフラ文脈 ---
[kubernetes]
disabled = false
format = 'on [⎈ $context(\($namespace\))](bold blue) '
detect_files = ["k8s", "Chart.yaml", "skaffold.yaml"]

[aws]
format = 'on [$symbol($profile )(\($region\) )]($style)'
style = "bold blue"

[aws.region_aliases]
ap-northeast-1 = "jp"

[docker_context]
format = "via [🐋 $context](blue bold)"

[custom.arch]
command = "uname -m"
when = """ test $(uname -m) = "x86_64" """
style = "bold yellow"
format = "[$output]($style)"
```

- [ ] **Step 2: 検証**

Run: `starship print-config --config starship.toml >/dev/null && echo config-ok`
Expected: `config-ok`(パースエラーがないこと)

- [ ] **Step 3: Commit**

```bash
git add starship.toml
git commit -m "feat: starshipにgit status/言語バージョン/k8s/実行時間表示を追加"
```

---

### Task 6: tmux モダナイズ

**Files:**
- Modify: `.tmux.conf`(全面書き換え)

**Interfaces:**
- Consumes: Task 2 の tpm(`~/.tmux/plugins/tpm`。未導入でも .tmux.conf 内で自動 clone する)
- Produces: なし

- [ ] **Step 1: .tmux.conf を全面書き換え**

キーバインド(prefix ^T、vi風移動/リサイズ、`|`/`-` 分割、`r` リロード、ペインタイトル)と見た目は維持。変更点: reattach-to-user-namespace 削除、TrueColor 化、コピーは tmux-yank に委譲、status-right の壊れた `#(wifi) #(battery --tmux)` を削除:

```tmux
# prefix を ^T に
unbind C-b
set -g prefix ^T
bind t send-prefix

# TrueColor 対応
set -g default-terminal "tmux-256color"
set -ga terminal-features ',*:RGB'

# r で設定リロード
bind r source-file ~/.tmux.conf \; display "Reloaded!"

# copy-mode (vi 風)。クリップボード連携は tmux-yank プラグインが
# pbcopy / win32yank / wl-copy / xclip を自動検出して行う
setw -g mode-keys vi
set -s set-clipboard on
unbind ^"["
bind -r ^"[" copy-mode
unbind ^]
bind -r ^] paste-buffer
bind-key -T copy-mode-vi v send-keys -X begin-selection

# ペイン移動 (vim 風)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# ペインリサイズ (vim 風)
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# | で縦分割、- で横分割 (カレントディレクトリ維持)
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# マウス操作
set-option -g mouse on
bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'copy-mode -e'"

# ステータスバー
set-option -g status-justify centre
set-option -g status-left '#H:[#P]'
set-option -g status-right '[%Y-%m-%d(%a) %H:%M:%S]'
set-option -g status-left-length 90
set-option -g status-right-length 90
set-option -g status-interval 1
set-option -g status-bg "colour238"
set-option -g status-fg "colour255"

# ペイン枠の色
set-option -g pane-border-style fg="colour232",bg="colour45"
set-option -g pane-active-border-style fg="colour164",bg="colour47"

# ペインタイトル
set -g pane-border-status top
set -g pane-border-format "#{pane_index} #{?pane_title,: #{pane_title},}"
bind T command-prompt -p "Pane title:" 'select-pane -T "%%"'
bind C-T select-pane -T ""

# --- tpm (plugin manager) ---
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-yank'

# tpm 未導入なら自動 clone (初回のみ)
if "test ! -d ~/.tmux/plugins/tpm" \
   "run 'git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

# tpm 初期化 (この行は .tmux.conf の最後に置く)
run '~/.tmux/plugins/tpm/tpm'
```

- [ ] **Step 2: 起動検証**

Run: `tmux -f .tmux.conf new-session -d -s modernize-test && tmux list-sessions && tmux kill-session -t modernize-test`
Expected: セッションが作成・表示・削除できる。エラー出力なし

- [ ] **Step 3: Commit**

```bash
git add .tmux.conf
git commit -m "feat: tmuxをモダナイズ(reattach-to-user-namespace除去、TrueColor、tpm導入)"
```

---

### Task 7: Neovim を LazyVim ベースに全面刷新

**Files:**
- Delete: `nvim/init.vim`, `nvim/dein.toml`, `nvim/dein_lazy.toml`, `nvim/nvim/`(ディレクトリごと)
- Create: `nvim/init.lua`
- Create: `nvim/lua/config/lazy.lua`
- Create: `nvim/lua/config/options.lua`
- Create: `nvim/lua/config/keymaps.lua`
- Create: `nvim/lua/config/autocmds.lua`
- Create: `nvim/lua/plugins/core.lua`
- Modify: `nvim/README.md`

**Interfaces:**
- Consumes: Task 2 の win32yank(WSL の clipboard。nvim が PATH から自動検出)
- Produces: なし

- [ ] **Step 1: 旧構成を削除**

```bash
git rm nvim/init.vim nvim/dein.toml nvim/dein_lazy.toml
git rm -r nvim/nvim
```

- [ ] **Step 2: init.lua を作成**

```lua
-- LazyVim ベースの Neovim 設定
-- 実体は lua/config/ 以下を参照
require("config.lazy")
```

- [ ] **Step 3: lua/config/lazy.lua を作成**

```lua
-- lazy.nvim のブートストラップと LazyVim の読み込み
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "lazy.nvim の clone に失敗しました:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- LazyVim 本体とそのデフォルトプラグイン群 (LSP/Treesitter/telescope 等)
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- 自分の追加・上書き設定
    { import = "plugins" },
  },
  defaults = { lazy = false, version = false },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true, notify = false }, -- 更新チェックは静かに
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
})
```

- [ ] **Step 4: lua/config/options.lua を作成**

```lua
-- 旧 init.vim からの移植 + LazyVim デフォルトの上書き
-- LazyVim デフォルトで既に有効なもの: number, cursorline, expandtab,
-- shiftwidth=2, tabstop=2, termguicolors, clipboard=unnamedplus, hlsearch

local opt = vim.opt

-- 旧設定では相対行番号を使っていなかったので無効化 (LazyVim は有効がデフォルト)
opt.relativenumber = false

-- 不可視文字の可視化 (タブを「▸-」で表示)
opt.list = true
opt.listchars = { tab = "▸-" }

-- カーソルの左右移動で行を跨げるようにする
opt.whichwrap = "b,s,h,l,<,>,[,],~"
```

- [ ] **Step 5: lua/config/keymaps.lua を作成**

```lua
-- 旧 init.vim からの移植: ノーマルモードで ; と : を入れ替え
vim.keymap.set("n", ";", ":", { desc = "コマンドライン (: の入れ替え)" })
vim.keymap.set("n", ":", ";", { desc = "f/t の繰り返し (; の入れ替え)" })
```

- [ ] **Step 6: lua/config/autocmds.lua を作成**

```lua
-- 追加の autocmd はここに書く (LazyVim のデフォルト autocmd は自動で読み込まれる)
```

- [ ] **Step 7: lua/plugins/core.lua を作成**

```lua
-- LazyVim デフォルトへの追加・上書き
return {
  -- Treesitter: 普段使う言語を最初から入れておく
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash", "fish", "lua", "vim",
        "typescript", "tsx", "javascript", "json",
        "go", "python", "rust",
        "yaml", "toml", "markdown", "markdown_inline",
        "dockerfile", "terraform", "hcl",
      },
    },
  },
}
```

- [ ] **Step 8: nvim/README.md を更新**

```markdown
# nvim

LazyVim ベースの Neovim 設定 (2026-07 に dein.vim + init.vim から移行)。

- プラグイン管理: lazy.nvim (初回起動時に自動ブートストラップ)
- ベース: [LazyVim](https://www.lazyvim.org/) — LSP / Treesitter / telescope / gitsigns / which-key 同梱
- 旧設定からの移植: tabstop=2, `;`↔`:` スワップ, listchars, whichwrap (lua/config/ 参照)
- WSL: クリップボード連携には win32yank.exe が必要 (install/common-post.sh が導入)

## 初回セットアップ

nvim を起動するだけ。lazy.nvim が自動導入され、プラグインが同期される。
`:LazyHealth` で状態確認。
```

- [ ] **Step 9: ヘッドレスでプラグイン同期し起動検証**

Run: `nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5`
Expected: エラーなく終了(初回は数分かかる)

Run: `nvim --headless "+lua print(vim.opt.tabstop:get())" +qa 2>&1`
Expected: `2`

注意: `~/.config/nvim` が本リポジトリへの symlink 済みであること(`ls -la ~/.config/nvim`)。旧 dein のキャッシュ `~/.cache/dein` は動作確認後に手動削除してよい。

- [ ] **Step 10: lazy-lock.json をコミット対象にする**

Run: `ls nvim/lazy-lock.json`
Expected: 同期後に生成されている(プラグインバージョンの再現性のため追跡する)

- [ ] **Step 11: Commit**

```bash
git add -A nvim/
git commit -m "feat: NeovimをLazyVimベースに全面刷新(dein.vim廃止)"
```

---

### Task 8: setup.sh / dotfiles-doctor 更新 (wezterm 除去・新ツール検査)

**Files:**
- Modify: `setup.sh`(link_config の targets)
- Modify: `bin/dotfiles-doctor`(config_targets、tools 配列、delta 検査追加)

**Interfaces:**
- Consumes: Task 1-7 の成果物すべて(検査対象)
- Produces: `./setup.sh doctor` が新環境の期待状態を定義する

- [ ] **Step 1: setup.sh から wezterm を除去**

`link_config()` 内:

```bash
link_config() {
  local targets=(fish nvim starship.toml mise herdr)
  if [ "$OS" = "Darwin" ]; then
    targets+=(karabiner)
  fi
  for t in "${targets[@]}"; do
    link "$DOTFILES_DIR/$t" "$HOME/.config/$t"
  done
}
```

- [ ] **Step 2: dotfiles-doctor を更新**

(a) `config_targets` から wezterm を除去:

```bash
config_targets=(fish nvim starship.toml mise herdr)
if [ "$OS" = "Darwin" ]; then
  config_targets+=(karabiner)
fi
```

(b) ツール検査の配列を更新:

```bash
tools=(brew mise fish nvim starship jq shellcheck gh fzf tmux atuin zoxide eza delta lazygit)
```

(c) ツール検査セクションの直後に delta 必須検査を追加:

```bash
# .gitconfig が pager=delta を要求するため、delta 欠如は warn でなく fail とする
if git config --file "$REPO_DIR/.gitconfig" core.pager 2>/dev/null | grep -q delta; then
  if command -v delta >/dev/null 2>&1; then
    ok "git pager (delta) が利用可能です"
  else
    fail "gitconfig が pager=delta を指定していますが delta が見つかりません (git diff が壊れます)"
  fi
fi
```

(d) 古い wezterm symlink の残骸検査を「symlink 検査」セクション末尾に追加:

```bash
# 廃止済み設定の残骸検査
if [ -L "$HOME/.config/wezterm" ]; then
  warn "廃止済みの wezterm symlink が残っています: rm ~/.config/wezterm を推奨"
fi
if [ -e "$HOME/.Brewfile" ]; then
  warn "旧 brewfile リポジトリ由来の ~/.Brewfile が残っています: 削除を推奨 (管理は install/Brewfile に一本化済み)"
fi
```

- [ ] **Step 3: 検証**

Run: `bash -n setup.sh && shellcheck setup.sh && bash -n bin/dotfiles-doctor && shellcheck bin/dotfiles-doctor`
Expected: エラーなし

Run: `./setup.sh link && ./setup.sh doctor; echo "exit=$?"`
Expected: fail 0 件、exit=0(wezterm 関連の warn が出る場合は `rm ~/.config/wezterm` 後に再実行)

- [ ] **Step 4: Commit**

```bash
git add setup.sh bin/dotfiles-doctor
git commit -m "feat: doctorに新ツール検査とdelta必須検査を追加、wezterm管理を廃止"
```

---

### Task 9: 旧 brewfile リポジトリの退役

**Files:**
- Modify(別リポジトリ `~/src/github.com/YuiSakamoto/brewfile`): `README.md` 以外を削除

- [ ] **Step 1: 旧リポジトリを退役状態にする**

```bash
cd ~/src/github.com/YuiSakamoto/brewfile
git rm Brewfile Brewfile.lock.json init.sh
git rm -r '$HOME'
cat > README.md <<'EOF'
# brewfile (archived)

このリポジトリは役目を終えました。

brew パッケージの管理は [dotfiles2](https://github.com/YuiSakamoto/dotfiles2) の
`install/Brewfile` に統合されています (2026-07)。

```bash
cd ~/src/github.com/YuiSakamoto/dotfiles2
./setup.sh install
```
EOF
git add README.md
git commit -m "chore: dotfiles2/install/Brewfileに統合したため退役"
```

- [ ] **Step 2: push(リモートがある場合)**

Run: `git -C ~/src/github.com/YuiSakamoto/brewfile push origin HEAD`
Expected: 成功(ユーザーが GitHub 側で archive するのは任意・手動)

---

### Task 10: ドキュメント更新 + 最終検証

**Files:**
- Modify: `README.md`
- Modify: `CLAUDE.md`
- Modify: `install/README.md`

- [ ] **Step 1: README.md を更新**

以下を反映する:
- symlink 一覧から wezterm を削除
- 「パッケージ管理」に「旧 YuiSakamoto/brewfile リポジトリは統合済み(2026-07)」を追記
- ディレクトリ構成から `wezterm/` を削除
- Linux/WSL 対応表に追記: 新ツール(eza/delta/lazygit/atuin 等)は common-post.sh が GitHub releases から x86_64 バイナリを導入する。**WSL 実機での動作検証は未実施**(コードレビューと dry-run で担保)
- fish の説明を更新: テーマ bobthefish → プロンプト starship、Ctrl+R は atuin、Ctrl+G は ghq×fzf、z は zoxide
- ツール一覧表(新規セクション): starship / atuin / zoxide / eza / bat / fd / ripgrep / fzf / delta / lazygit / btop / dust / duf / tlrc の一行説明

- [ ] **Step 2: CLAUDE.md を更新**

- 「Fish Shell」セクション: `Theme: bobthefish with powerline fonts` → `Prompt: starship (HackGen Nerd Font)`、`Ctrl+R for history search with peco` → `Ctrl+R: atuin / Ctrl+G: ghq repo search (fzf)`
- 「Architecture」セクション: `Neovim uses dein.vim for plugin management with configurations in TOML files` → `Neovim is LazyVim-based (lazy.nvim + Lua, see nvim/lua/)`、`WezTerm configuration for terminal emulator` を削除

- [ ] **Step 3: install/README.md を更新**

- common-post.sh の説明から peco / fisher を外し、atuin / eza / delta / lazygit / dust / tlrc / tpm / win32yank を追記
- 「今後の方針: chezmoi 移行判断」セクションはそのまま維持

- [ ] **Step 4: 最終検証**

Run: `./setup.sh doctor; echo "exit=$?"`
Expected: fail 0 件、exit=0

Run: `fish -l -c 'echo $SHELL ok; type -q z; and echo z-ok; atuin --version; starship --version' 2>&1 | head -5`
Expected: エラーなし

Run: `git status --short`
Expected: 未コミットの変更なし(herdr/config.toml, .claude/settings.json の既存ローカル変更を除く)

- [ ] **Step 5: Commit**

```bash
git add README.md CLAUDE.md install/README.md
git commit -m "docs: モダナイズ後のツール構成にREADME/CLAUDE.mdを更新"
```

---

## 実施後のユーザー手動作業(計画外・案内のみ)

- ターミナル(Ghostty/iTerm2)のフォントを HackGen Nerd に変更
- `atuin import auto` で既存 fish 履歴の取り込み、マシン間同期したければ `atuin register`/`atuin login`
- 動作が安定したら `brew bundle cleanup --file=install/Brewfile` で不要パッケージ(peco, asdf, goenv, tfenv, hub, aicommits, wezterm 等)を実機から掃除
- 旧 dein キャッシュ削除: `rm -rf ~/.cache/dein`
- GitHub 上で YuiSakamoto/brewfile を Archive
