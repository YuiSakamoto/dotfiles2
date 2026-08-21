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
- `~/.zshenv` — zsh は ZDOTDIR 方式。`$HOME` 直下に置くのはこれ1つだけで、
  設定本体は `~/.config/zsh/` に集約している
- `~/.config/zsh/`, `~/.config/sheldon/`, `~/.config/fish/`, `~/.config/nvim/`,
  `~/.config/mise/`, `~/.config/starship.toml`
- `~/.claude/` 以下の `CLAUDE.md`, `agents/`, `skills/`, `scripts/`, `settings.json`, `mcp-setup.sh`, `.env.example`
  - `credentials.json`, `sessions/`, `projects/` 等のランタイム状態は**触らない**
- `~/.local/bin/` 以下のユーティリティ
  - `~/.local/bin` が `PATH` に入っている必要あり (zsh は `.zshenv`、fish は `path.fish` で追加済み)

macOS のみ:

- `~/.config/karabiner/`
- `~/.config/ghostty/`, `~/.config/cmux/` — cmux (ghostty 内蔵ターミナル) の見た目とキーバインド

`~/.config` 配下はすべてこのリポジトリへの symlink で、実体ファイルは置かない方針。
逆にツールの生成物 (補完キャッシュ・履歴・plugins.lock) がリポジトリに落ちないよう、
出力先は `~/.cache` / `~/.local` 側へ逃がしてある (`./setup.sh doctor` が検査する)。

既存ファイルは `~/dotfiles-backup-<timestamp>/` に退避されます。既に正しい symlink ならスキップ (冪等)。

## パッケージ管理

- **macOS**: [`install/Brewfile`](install/Brewfile) — `brew bundle` 互換
- **Linux/WSL**: [`install/apt-packages.txt`](install/apt-packages.txt) — `apt-get install` 用リスト (コメント可)
- **共通後処理**: [`install/common-post.sh`](install/common-post.sh) — starship / mise / sheldon / peco / fisher など、パッケージマネージャだけでは足りないものの導入と、zsh の `compinit` が止まらないようにする権限修正

## ディレクトリ構成

```
.
├── setup.sh              # OS判定 + symlink + パッケージインストール
├── install/              # パッケージ定義
│   ├── Brewfile
│   ├── apt-packages.txt
│   └── common-post.sh
├── .claude/              # Claude Code のグローバル設定
├── .zshenv               # zsh: 全シェル共通 (ZDOTDIR / PATH / 環境変数)
├── zsh/                  # zsh: 対話シェル設定 (~/.config/zsh)
│   ├── .zshrc            #   conf.d/*.zsh を番号順に読むだけ
│   ├── conf.d/           #   00 options / 10 completion / 20 plugins / 30 tools / 40 keybind / 50 alias
│   └── functions/        #   autoload 関数 (1ファイル1関数)
├── sheldon/              # zsh プラグイン定義 (plugins.toml)
├── fish/                 # fish shell (移行期間中の併存用)
├── nvim/                 # Neovim
├── mise/                 # mise (asdf互換)
├── karabiner/            # Karabiner-Elements (macOS)
├── ghostty/              # ターミナルの配色・フォント (cmux が内蔵する ghostty)
├── cmux/                 # cmux 本体の外観とキーバインド (macOS)
├── docs/                 # ショートカット早見表など
├── bin/                  # ユーティリティスクリプト
└── starship.toml
```

## Linux / WSL 対応

`setup.sh` は macOS / Linux (Debian系・WSL含む) 両対応です。symlink を貼る `link` 処理はOS共通、パッケージインストール (`install`) は `uname` 判定で `brew` / `apt-get` を切り替えます。

Claude Code 関連 (`.claude/`, `bin/dotfiles-doctor`) の対応状況:

| 項目 | macOS | Linux/WSL |
| --- | --- | --- |
| `bin/dotfiles-doctor`（環境検証、`./setup.sh doctor`） | 対応 | 対応（karabiner/ghostty/cmux 検査は自動スキップ） |
| `.claude/scripts/validate-edit.sh`（構文検証hook） | 対応 | 対応（fish/shellcheck/ruff等が未導入でも自動スキップ） |
| `.claude/scripts/notify-*.sh`（完了/入力待ち通知） | 対応 | macOS専用。`osascript` が無い環境では即終了し、hookは汚染しない |
| `karabiner/`, `ghostty/`, `cmux/` | 対応 | 対象外（symlink・doctor検査ともにスキップ） |
| `zsh/`, `sheldon/` | 対応 | 対応（sheldon は apt に無いため `common-post.sh` が導入） |

WSL固有の注意:

- 通知音・デスクトップ通知は出ません（`notify-*.sh` が `osascript` 不在を検知して静かに無効化されるため）
- Homebrew は不要です。`./setup.sh install` は `install/apt-packages.txt` を使って `apt-get install` します
- apt に無いツール（sheldon, peco, starship, fisher, gh 等）は `install/common-post.sh` で別途導入されます

## トラブルシューティング

### シェルについて

メインは **zsh**。macOS 標準の `/bin/zsh` (5.9 = 最新リリース) をそのまま使うので
`chsh` も Homebrew の zsh も不要です。fish は移行期間中の併存用に残してあります。

fish に戻したい場合:

```bash
# macOS (Homebrew)
which fish | sudo tee -a /etc/shells && chsh -s "$(which fish)"

# Linux/WSL (apt)
sudo chsh -s "$(which fish)" "$USER"
```

### zsh の起動が遅い

```bash
ZSH_PROFILE=1 zsh -i -c exit   # zprof のプロファイルを出力する
```

`$(...)` を伴う init は fork の分だけ遅くなります。実測では `brew shellenv` だけが
20-30ms かかっていたため、`.zshenv` では同じ内容を fork せずに直接展開しています。

### 補完が効かない / `insecure directories` と言われる

Homebrew が `$(brew --prefix)/share` を group 書き込み可で作るため、zsh の `compinit`
がそれを危険と判断して補完の初期化ごと中断することがあります。

```bash
./setup.sh install   # common-post.sh が group 書き込み権限を落とします
```

### tmux 設定が反映されない

```bash
tmux source-file ~/.tmux.conf   # または Ctrl+T → r
```

### Ctrl+G が Chrome の Gemini に奪われる

Chrome は「Gemini in Chrome」(内部名 glic) のランチャーを有効にすると、**OS レベルの
グローバルホットキーとして macOS では Ctrl+G を勝手に登録する**。zsh の ghq 移動
(`Ctrl+G`) が効かなくなるのはこれが原因。

`chrome://settings/ai/gemini` を開き、**「Show Gemini in system tray and turn on
keyboard shortcut」をオフ**にする。Chrome 内の Gemini はそのまま使える。
横の鉛筆アイコンから別のキーに変えるだけでもよい。設定後は Chrome を完全終了して再起動する。

実体は Chrome の `Local State` にある `glic.launcher_enabled`。
現在の状態は次で確認できる。

```bash
python3 -c "import json;print(json.load(open('$HOME/Library/Application Support/Google/Chrome/Local State')).get('glic'))"
```

### cmux の見た目やキーバインドが反映されない

ターミナルから次を実行するのが一番早い。アプリの再起動は不要で、
`ghostty/config` (配色・フォント) と `cmux/cmux.json` (UI・ショートカット) が
同時に読み直される。

```bash
cmux config validate   # 先に構文と読み込みパスを確認する
cmux reload-config     # ghostty と cmux.json の両方を反映
cmux shortcuts         # 設定画面のキーボードショートカットを開いて確認
```

`Cmd+Shift+,` (reloadConfiguration) や、コマンドパレット `Cmd+Shift+P` から
`Reload Configuration` を選んでも同じ。

なお `cmux.json` のショートカットに書けるのは**キー名**であって文字ではない
(`|` のようなシフト付きの文字は不可。US 配列なら `shift+\` と書く)。
`cmux config validate` は JSONC の構文しか見ないため、間違えるとエラーも出ずに
無反応になる。詳細は [`docs/SHORTCUTS.md`](docs/SHORTCUTS.md)。

## ショートカット早見表

zsh / cmux / git のキーバインドとエイリアスの一覧は
[`docs/SHORTCUTS.md`](docs/SHORTCUTS.md) にまとめてあります。
