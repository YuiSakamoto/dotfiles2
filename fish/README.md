# Fish Shell設定

Fish shellの設定ファイルとカスタマイズ内容です。

## ディレクトリ構造

```
fish/
├── conf.d/                    # 設定ファイル（自動読み込み）
│   ├── alias.fish             # エイリアス定義
│   ├── config.fish            # GHQ_SELECTOR等の環境変数
│   ├── ghq_key_bindings.fish  # Ctrl+G キーバインド (ghq×fzf)
│   ├── mise.fish              # mise (asdf互換のランタイム管理)
│   ├── path.fish               # PATH設定
│   ├── secrets.fish            # シークレット系の環境変数 (git 追跡外)
│   └── tools.fish              # starship/atuin/zoxide の初期化
├── config.fish                # メイン設定ファイル (brew shellenv/starship/mise)
├── fish_variables              # fish変数
└── functions/                   # カスタム関数
```

## 主な機能

### プロンプト

**[starship](https://starship.rs/)** を使用（旧 bobthefish テーマは廃止）
- Nerd Font 対応（HackGen Nerd Font 推奨）
- Gitステータス・言語バージョン・k8sコンテキスト・実行時間を表示
- 設定は リポジトリルートの `starship.toml`（`~/.config/starship.toml` に symlink）

### キーバインディング

- `Ctrl+R`: [atuin](https://atuin.sh/) によるインクリメンタルな履歴検索（上矢印キーの挙動は変更しない）
- `Ctrl+G`: [ghq](https://github.com/x-motemen/ghq) × fzf でリポジトリを検索して移動 (`__ghq_repository_search`)

### エイリアス

#### 開発ツール
```bash
vi, v         # Neovim
d             # docker
dc            # docker-compose
k             # kubectl
kg            # kubectl get
kd            # kubectl describe
kcx           # kubectx
tf            # terraform
gcl           # gcloud
```

#### モダンCLI（未導入環境では元のコマンドのまま動作）
```bash
ls, ll, la, lt  # eza（アイコン・git status表示）
lg              # lazygit
```

#### Git関連
```bash
g             # git
gs, gst       # git status -s -b
gc            # git commit
gci           # git commit -a
gd            # git diff
```

#### tmux関連
```bash
tm            # tmux
tma           # tmux attach
tma0-2        # tmux attach -t 0-2
tml           # tmux list-sessions
tpt           # tmux_pane_title
```

#### その他
```bash
less          # less -r（カラー対応）
du, df        # 人間可読形式（du -h / df -h）
duh           # du -h ./ --max-depth=1
cl            # Claude Code
```

## カスタム関数

### fkill
- fzf でプロセス一覧から選択して kill する

### tmux_pane_title (`tpt`)
tmuxのペインにタイトルを設定
```bash
# タイトル設定
tpt "Server Monitor"

# タイトルクリア
tpt
```

### bd (back directory)
親ディレクトリへの高速移動
```bash
# /Users/name/projects/myapp/src/components にいる場合
bd proj  # /Users/name/projects へ移動
bd my    # /Users/name/projects/myapp へ移動
```

### __ghq_repository_search
`Ctrl+G` にバインドされた ghq × fzf のリポジトリ検索。選択したリポジトリのローカルパスへ `cd` する。

## PATH設定

`conf.d/path.fish` で以下を自動的に追加します：
- `$HOME/.local/bin`, `$HOME/bin`, `$HOME/go/bin`
- mise でアクティベートされたランタイムの PATH
- macOS (Apple Silicon) では `/opt/homebrew/bin` 等

## プラグイン管理

Fisher は廃止しました。モダンCLIツールの初期化は `conf.d/tools.fish` で行い、未導入の環境でも `type -q` によるガードでエラーになりません（starship / atuin / zoxide）。

## Tips

### z コマンド（ディレクトリジャンプ）

[zoxide](https://github.com/ajeetdsouza/zoxide) を使用（旧 `jethrokuan/z` プラグインは廃止）:

```bash
# 過去に訪れたディレクトリに素早く移動
z proj      # projectsディレクトリへ
z dot       # dotfilesディレクトリへ
```

### 補完機能
Fishは強力な補完機能を持っています：
- コマンドオプションの補完
- ファイルパスの補完
- Git補完
- Man page解析による自動補完

### 文法チェック
入力中のコマンドをリアルタイムで文法チェック：
- 有効なコマンド：青色
- 無効なコマンド：赤色
- 有効なパス：下線付き

## トラブルシューティング

### fishがデフォルトシェルにならない
```bash
# fishのパスを確認
which fish

# /etc/shellsに追加
echo /usr/local/bin/fish | sudo tee -a /etc/shells

# デフォルトシェルに設定
chsh -s /usr/local/bin/fish
```

### プロンプトのアイコンが表示されない (starship)
Nerd Font 対応フォントをインストールし、ターミナルのフォント設定を変更してください：
```bash
# Homebrew経由
brew install --cask font-hackgen-nerd
```

### 設定が反映されない
```bash
# 設定を再読み込み
source ~/.config/fish/config.fish

# または新しいシェルを起動
exec fish
```
