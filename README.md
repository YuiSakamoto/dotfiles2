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
- `~/.claude/` 以下の `CLAUDE.md`, `agents/`, `commands/`, `skills/`, `scripts/`, `settings.json`, `mcp-setup.sh`, `.env.example`
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
