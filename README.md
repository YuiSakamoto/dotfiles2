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

- `~/.config/karabiner/`, `~/.config/wezterm/`

既存ファイルは `~/dotfiles-backup-<timestamp>/` に退避されます。既に正しい symlink ならスキップ (冪等)。

## パッケージ管理

- **macOS**: [`install/Brewfile`](install/Brewfile) — `brew bundle` 互換
- **Linux/WSL**: [`install/apt-packages.txt`](install/apt-packages.txt) — `apt-get install` 用リスト (コメント可)
- **共通後処理**: [`install/common-post.sh`](install/common-post.sh) — starship / mise / peco / fisher など、パッケージマネージャだけでは足りないものを導入

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
├── wezterm/              # WezTerm (macOS)
├── bin/                  # ユーティリティスクリプト
└── starship.toml
```

## Linux / WSL 対応

`setup.sh` は macOS / Linux (Debian系・WSL含む) 両対応です。symlink を貼る `link` 処理はOS共通、パッケージインストール (`install`) は `uname` 判定で `brew` / `apt-get` を切り替えます。

Claude Code 関連 (`.claude/`, `bin/dotfiles-doctor`) の対応状況:

| 項目 | macOS | Linux/WSL |
| --- | --- | --- |
| `bin/dotfiles-doctor`（環境検証、`./setup.sh doctor`） | 対応 | 対応（karabiner/wezterm 検査は自動スキップ） |
| `.claude/scripts/validate-edit.sh`（構文検証hook） | 対応 | 対応（fish/shellcheck/ruff等が未導入でも自動スキップ） |
| `.claude/scripts/notify-*.sh`（完了/入力待ち通知） | 対応 | macOS専用。`osascript` が無い環境では即終了し、hookは汚染しない |
| `karabiner/`, `wezterm/` | 対応 | 対象外（symlink・doctor検査ともにスキップ） |

WSL固有の注意:

- 通知音・デスクトップ通知は出ません（`notify-*.sh` が `osascript` 不在を検知して静かに無効化されるため）
- Homebrew は不要です。`./setup.sh install` は `install/apt-packages.txt` を使って `apt-get install` します
- apt に無いツール（peco, starship, fisher, gh 等）は `install/common-post.sh` で別途導入されます

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
