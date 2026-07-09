# dotfiles2

個人の開発環境設定ファイル集 (macOS / Linux / WSL 対応)。

## セットアップ

```bash
git clone https://github.com/YuiSakamoto/dotfiles2.git
cd dotfiles2

# 1. パッケージのインストール (macOSはbrew / Linuxはapt)
./setup.sh install

# 2. symlink を貼る
./setup.sh link

# まとめて
./setup.sh all
```

`--dry-run` を付けると実際には実行せず、何をやるかだけ出力します。

### 何が symlink されるか

共通:

- `~/.gitconfig`, `~/.gitignore`, `~/.tmux.conf`
- `~/.config/fish/`, `~/.config/nvim/`, `~/.config/mise/`, `~/.config/starship.toml`
- `~/.claude/` 以下の `CLAUDE.md`, `agents/`, `skills/`, `scripts/`, `settings.json`, `mcp-setup.sh`, `.env.example`
  - `credentials.json`, `sessions/`, `projects/` 等のランタイム状態は**触らない**
- `~/.local/bin/ssm`, `~/.local/bin/claude-project`
  - `~/.local/bin` が `PATH` に入っている必要あり (fish 側は `path.fish` で追加済み)

macOS のみ:

- `~/.config/karabiner/`

既存ファイルは `~/dotfiles-backup-<timestamp>/` に退避されます。既に正しい symlink ならスキップ (冪等)。

## パッケージ管理

- **macOS**: [`install/Brewfile`](install/Brewfile) — `brew bundle` 互換
- **Linux/WSL**: [`install/apt-packages.txt`](install/apt-packages.txt) — `apt-get install` 用リスト (コメント可)
- **共通後処理**: [`install/common-post.sh`](install/common-post.sh) — starship / mise / atuin / eza / delta / lazygit / dust / tlrc / tpm など、パッケージマネージャだけでは足りないものを導入
- 旧 [`YuiSakamoto/brewfile`](https://github.com/YuiSakamoto/brewfile) リポジトリは統合済み (2026-07)。今後は本リポジトリの `install/Brewfile` のみを更新する

## ディレクトリ構成

```
.
├── setup.sh              # OS判定 + symlink + パッケージインストール
├── install/              # パッケージ定義
│   ├── Brewfile
│   ├── apt-packages.txt
│   └── common-post.sh
├── .claude/              # Claude Code のグローバル設定
├── fish/                 # fish shell
├── nvim/                 # Neovim
├── mise/                 # mise (asdf互換)
├── karabiner/            # Karabiner-Elements (macOS)
├── bin/                  # ユーティリティスクリプト
└── starship.toml
```

## Linux / WSL 対応

`setup.sh` は macOS / Linux (Debian系・WSL含む) 両対応です。symlink を貼る `link` 処理はOS共通、パッケージインストール (`install`) は `uname` 判定で `brew` / `apt-get` を切り替えます。

Claude Code 関連 (`.claude/`, `bin/dotfiles-doctor`) の対応状況:

| 項目 | macOS | Linux/WSL |
| --- | --- | --- |
| `bin/dotfiles-doctor`（環境検証、`./setup.sh doctor`） | 対応 | 対応（karabiner 検査は自動スキップ） |
| `.claude/scripts/validate-edit.sh`（構文検証hook） | 対応 | 対応（fish/shellcheck/ruff等が未導入でも自動スキップ） |
| `.claude/scripts/notify-*.sh`（完了/入力待ち通知） | 対応 | macOS専用。`osascript` が無い環境では即終了し、hookは汚染しない |
| `karabiner/` | 対応 | 対象外（symlink・doctor検査ともにスキップ） |

WSL固有の注意:

- 通知音・デスクトップ通知は出ません（`notify-*.sh` が `osascript` 不在を検知して静かに無効化されるため）
- Homebrew は不要です。`./setup.sh install` は `install/apt-packages.txt` を使って `apt-get install` します
- apt に無いツール（starship, atuin 等）は `install/common-post.sh` で別途導入されます。`gh` は Debian 12 / Ubuntu 23.04+ の公式リポジトリにあるため `install/apt-packages.txt` から通常の `apt-get install` で入ります
- 新ツール（eza / delta / lazygit / dust / tlrc 等）は `install/common-post.sh` が GitHub releases から `x86_64` 向けバイナリを取得して `~/.local/bin` に導入します（`arm64` 等の非対応アーキテクチャでは自動スキップ）
- tpm（tmux plugin manager）は `install/common-post.sh` が `~/.tmux/plugins/tpm` に git clone します（macOS/Linux 共通）
- WSL では nvim/tmux のクリップボード連携用に win32yank も `install/common-post.sh` が導入します
- **WSL 実機での動作検証は未実施**です。コードレビューと `--dry-run` によるロジック確認のみで担保しています

## Fish Shell

- プロンプトは [starship](https://starship.rs/)（旧 bobthefish テーマは廃止）
- `Ctrl+R`: [atuin](https://atuin.sh/) によるインクリメンタル履歴検索
- `Ctrl+G`: [ghq](https://github.com/x-motemen/ghq) × fzf でリポジトリ検索・移動 (`__ghq_repository_search`)
- `z <キーワード>`: [zoxide](https://github.com/ajeetdsouza/zoxide) によるディレクトリジャンプ（旧 `z`/`zoxide` プラグインは廃止）

## ツール一覧

モダナイズで導入した CLI ツール:

| ツール | 用途 |
| --- | --- |
| [starship](https://starship.rs/) | シェルプロンプト（git status/言語バージョン/k8s/実行時間表示） |
| [atuin](https://atuin.sh/) | シェル履歴の検索・同期 (`Ctrl+R`) |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | 頻度ベースのディレクトリジャンプ (`z`) |
| [eza](https://github.com/eza-community/eza) | `ls` 代替。アイコン・git status 表示付き |
| [bat](https://github.com/sharkdp/bat) | `cat` 代替。シンタックスハイライト・git diff表示 |
| [fd](https://github.com/sharkdp/fd) | `find` 代替。高速・直感的なオプション |
| [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) | `grep` 代替。高速な再帰検索 |
| [fzf](https://github.com/junegunn/fzf) | あいまい検索(fuzzy finder)。`Ctrl+G`/`fkill` 等で利用 |
| [delta](https://github.com/dandavison/delta) | git diff/show 用のシンタックスハイライトpager |
| [lazygit](https://github.com/jesseduffield/lazygit) | git の TUI クライアント (`lg`) |
| [btop](https://github.com/aristocratos/btop) | `top` 代替のリソースモニタ |
| [dust](https://github.com/bootandy/dust) | `du` 代替。ディスク使用量の可視化 |
| [duf](https://github.com/muesli/duf) | `df` 代替。ディスク空き容量の可視化 |
| [tlrc](https://github.com/tldr-pages/tlrc) (`tldr`) | コマンドの要約サンプルを表示するtldrクライアント |

## トラブルシューティング

### fish をデフォルトシェルにしたい

```bash
# macOS (Homebrew)
which fish | sudo tee -a /etc/shells && chsh -s "$(which fish)"

# Linux/WSL (apt)
sudo chsh -s "$(which fish)" "$USER"
```

### tmux 設定が反映されない

```bash
tmux source-file ~/.tmux.conf   # または Ctrl+T → r
```
