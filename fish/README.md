# Fish Shell設定

Fish shellの設定ファイルとカスタマイズ内容です。

## ディレクトリ構造

```
fish/
├── conf.d/          # 設定ファイル（自動読み込み）
│   ├── alias.fish   # エイリアス定義
│   └── path.fish    # PATH設定
├── config.fish      # メイン設定ファイル
├── fish_variables   # fish変数
└── functions/       # カスタム関数
```

## 主な機能

### テーマ

**bobthefish** テーマを使用
- Powerlineフォント対応
- Gitステータス表示
- 実行時間表示
- エラーステータス表示

### キーバインディング

- `Ctrl+R`: peco連携の履歴検索
- `Ctrl+X`: pecoでプロセスを選択してkill

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
tpt           # tmux_pane_title（新機能）
```

#### その他
```bash
ij            # IntelliJ IDEA起動
less          # less -r（カラー対応）
du, df        # 人間可読形式
duh           # du -h ./ --max-depth=1
claude        # Claude Code（プロジェクト単位）
```

## カスタム関数

### peco_select_history
- `Ctrl+R`で起動
- インクリメンタルな履歴検索
- 選択したコマンドを実行

### peco_kill
- `Ctrl+X`で起動
- プロセス一覧から選択してkill

### tmux_pane_title（新機能）
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

## PATH設定

以下のパスが自動的に追加されます：
- `/usr/local/bin`
- `$HOME/bin`
- `$HOME/.local/bin`
- 各種開発ツールのパス（gcloud、cargo等）

## プラグイン管理

**Fisher**を使用してプラグインを管理：

```bash
# プラグインのインストール
fisher install <プラグイン名>

# インストール済みプラグイン一覧
fisher list
```

### 主要プラグイン
- oh-my-fish/theme-bobthefish
- jethrokuan/z（ディレクトリジャンプ）
- 0rax/fish-bd（親ディレクトリ移動）

## Tips

### z コマンド（ディレクトリジャンプ）
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

### Powerlineフォントが表示されない
Powerline対応フォントをインストール：
```bash
# Homebrew経由
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font
```

### 設定が反映されない
```bash
# 設定を再読み込み
source ~/.config/fish/config.fish

# または新しいシェルを起動
exec fish
```