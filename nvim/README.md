# Neovim設定

Neovimの設定ファイルとプラグイン構成です。

## ディレクトリ構造

```
nvim/
├── init.vim         # メイン設定ファイル
├── dein.toml        # 通常起動時に読み込むプラグイン
├── dein_lazy.toml   # 遅延読み込みプラグイン
├── coc-settings.json # CoC.nvim設定
└── lua/             # Lua設定ファイル
```

## プラグイン管理

**dein.vim**を使用してプラグインを管理しています。

### 主要プラグイン

#### エディタ拡張
- **lightline.vim**: ステータスライン
- **vim-gitgutter**: Git差分表示
- **nerdtree**: ファイルツリー
- **fzf.vim**: ファジーファインダー
- **vim-fugitive**: Git統合

#### 言語サポート
- **coc.nvim**: Language Server Protocol対応
- **vim-polyglot**: 多言語シンタックスハイライト
- **emmet-vim**: HTML/CSS高速コーディング

#### 見た目
- **gruvbox**: カラースキーム
- **vim-devicons**: ファイルアイコン

## キーマッピング

### 基本操作
```vim
<Space>      # Leaderキー
jj           # ESC（Insertモード）
```

### ファイル操作
```vim
<Leader>e    # NERDTree表示/非表示
<Leader>f    # ファイル検索（fzf）
<Leader>g    # grep検索（fzf）
<Leader>b    # バッファ一覧（fzf）
```

### ウィンドウ操作
```vim
<C-h>        # 左のウィンドウへ
<C-j>        # 下のウィンドウへ
<C-k>        # 上のウィンドウへ
<C-l>        # 右のウィンドウへ
```

### CoC.nvim（補完・LSP）
```vim
<Tab>        # 補完候補選択（次）
<S-Tab>      # 補完候補選択（前）
<CR>         # 補完確定
gd           # 定義へジャンプ
gy           # 型定義へジャンプ
gi           # 実装へジャンプ
gr           # 参照一覧
K            # ホバー表示
<Leader>rn   # リネーム
<Leader>ca   # コードアクション
```

### Git操作（vim-fugitive）
```vim
<Leader>gs   # Git status
<Leader>gc   # Git commit
<Leader>gp   # Git push
<Leader>gl   # Git log
```

## 基本設定

### 表示設定
- 行番号表示（相対行番号）
- 256色対応
- シンタックスハイライト
- インデントガイド
- 80文字ルーラー

### 編集設定
- スペース2文字インデント
- 自動インデント
- タブをスペースに展開
- 末尾空白の可視化

### 検索設定
- インクリメンタルサーチ
- 大文字小文字を区別しない
- ハイライト表示

## Language Server設定

CoC.nvimで以下の言語サーバーが利用可能：

```bash
# TypeScript/JavaScript
:CocInstall coc-tsserver

# Python
:CocInstall coc-pyright

# Go
:CocInstall coc-go

# Rust
:CocInstall coc-rust-analyzer

# その他の言語サーバー
:CocList extensions
```

## カスタマイズ

### プラグイン追加

`dein.toml`または`dein_lazy.toml`に追加：

```toml
[[plugins]]
repo = 'プラグイン名'
hook_add = '''
  " 設定
'''
```

### キーマッピング追加

`init.vim`に追加：

```vim
" 例：保存
nnoremap <Leader>w :w<CR>
```

## トラブルシューティング

### プラグインが読み込まれない
```vim
" deinのキャッシュクリア
:call dein#clear_state()
:call dein#update()
```

### CoC.nvimが動作しない
```vim
" Node.jsが必要
:checkhealth

" 拡張機能の再インストール
:CocInstall <拡張機能名>
```

### カラースキームが適用されない
```vim
" init.vimで明示的に設定
colorscheme gruvbox
set background=dark
```

## Tips

### 高速起動
遅延読み込み（`dein_lazy.toml`）を活用して起動時間を短縮

### プロジェクト固有の設定
`.nvimrc`または`.vim/`ディレクトリを作成してプロジェクト固有の設定を追加

### デバッグ
```vim
" 起動時間の計測
nvim --startuptime startup.log

" プラグインの読み込み状況確認
:scriptnames
```