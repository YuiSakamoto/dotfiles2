# dotfiles2

個人の開発環境設定ファイル集です。

## セットアップ

### 初回セットアップ

```bash
# リポジトリをクローン
git clone https://github.com/YuiSakamoto/dotfiles2.git
cd dotfiles2

# セットアップスクリプトを実行
./setup.sh
```

これにより、以下のファイルがシンボリックリンクとして設定されます：

- `~/.gitconfig` - Gitの設定
- `~/.gitignore` - グローバルなgitignore
- `~/.tmux.conf` - tmuxの設定
- `~/.config/fish/` - fishシェルの設定
- `~/.config/nvim/` - Neovimの設定
- `~/.config/karabiner/` - Karabinerの設定（macOS）
- `~/.config/wezterm/` - WezTermの設定
- `~/.config/starship.toml` - Starshipの設定
- `/usr/local/bin/ssm` - AWS SSM用スクリプト

## 各ツールの使い方

### tmux

[tmux/README.md](tmux/README.md) を参照

主な機能：
- Prefix: `Ctrl+T`
- pane title機能（新機能）
- vim風のキーバインディング

### fish

[fish/README.md](fish/README.md) を参照

主な機能：
- 豊富なエイリアス設定
- peco連携（履歴検索など）
- bobthefishテーマ

### Neovim

[nvim/README.md](nvim/README.md) を参照

主な機能：
- dein.vimによるプラグイン管理
- LSP対応
- カスタマイズされたキーマッピング

### Karabiner

[karabiner/README.md](karabiner/README.md) を参照

macOS用のキーボードカスタマイズ設定

### WezTerm

[wezterm/README.md](wezterm/README.md) を参照

高機能なターミナルエミュレータの設定

## よく使うコマンド

```bash
# tmux
tm              # tmux起動
tma             # tmuxアタッチ
tpt "タイトル"  # pane titleを設定

# git
g s             # git status
g po            # git push origin
g up            # git pull --rebase

# その他
vi              # Neovim起動
k               # kubectl
d               # docker
```

## Claude Code連携

このリポジトリには`CLAUDE.md`が含まれており、Claude Codeでの作業時に適切なコンテキストが提供されます。

## トラブルシューティング

### fishが起動しない場合

```bash
# fishのパスを確認
which fish

# /etc/shellsに追加
echo /usr/local/bin/fish | sudo tee -a /etc/shells

# デフォルトシェルに設定
chsh -s /usr/local/bin/fish
```

### tmux設定が反映されない場合

```bash
# tmux内で
tmux source-file ~/.tmux.conf

# または Ctrl+T → r
```