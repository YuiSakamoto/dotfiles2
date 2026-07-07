# dotfiles2 モダナイズ設計

日付: 2026-07-07
ステータス: 承認済み

## 目的

dotfiles2 を macOS / WSL 両対応のまま全面モダナイズする。旧世代ツール(bobthefish / peco / 自前z / dein.vim / reattach-to-user-namespace)を現行標準(starship / atuin / zoxide / LazyVim / tmux標準機能 + tpm)に置き換え、モダンCLIツール群を新規導入する。

## 方針

- **攻めの移行**: 旧ツールの設定は削除して置き換える。二重管理はしない
- **操作感の維持**: エイリアス、キーバインド(tmux prefix `^T`、vim風ペイン移動、`;`↔`:` スワップ等)は変えない
- **WSL対応は一級市民**: 全ての新ツールは macOS / Linux(Debian系・WSL)両方でのインストール経路を用意する

## 1. シェル体験(fish)

### 削除するもの

- bobthefish 一式: `fish/functions/fish_prompt.fish`, `fish_right_prompt.fish`, `fish_mode_prompt.fish`, `__bobthefish_*.fish`, `bobthefish_display_colors.fish`, `copy-fish_prompt.fish`、および `conf.d/config.fish` 内の `theme_*` 変数
- peco 関連: `peco_select_history.fish`, `peco_kill.fish`、`config.fish` の `bind \cr peco_select_history`、`GHQ_SELECTOR peco`
- 自前 z: `fish/functions/__z*.fish`, `fish/conf.d/z.fish`

### 導入するもの

| ツール | 役割 | 備考 |
| --- | --- | --- |
| starship | プロンプト | 既存 `starship.toml` を拡充(git branch/status、言語バージョン、k8s context、コマンド実行時間) |
| atuin | Ctrl+R 履歴検索 | ローカルのみで開始。マシン間同期(`atuin login`)はユーザーが任意で有効化 |
| zoxide | ディレクトリジャンプ | `zoxide init fish` で `z` コマンド提供。旧 z の学習データは移行しない |
| eza | ls 代替 | `ls`, `ll`, `la`, `lt`(tree) エイリアス |
| lazygit | git TUI | `lg` エイリアス |
| btop / dust / duf / tlrc | top / du / df / tldr 代替 | エイリアスは任意(btop等はコマンド名のまま) |

### 書き換えるもの

- `__ghq_repository_search.fish` / `ghq_key_bindings.fish`: peco → fzf
- `peco_kill` 相当: fzf 版 `fkill` として作り直し
- `conf.d/` に `starship.fish`, `atuin.fish`, `zoxide.fish` の初期化を追加(コマンド存在チェック付きで、未導入環境でもエラーにしない)
- fisher: `fish_plugins` を確認し、bobthefish / z / peco 系以外に管理プラグインが無ければ fisher 本体・`fisher.fish`・common-post.sh の fisher 導入処理を削除する。残すプラグインがあれば fisher は維持

## 2. Neovim(LazyVim ベース全面刷新)

### 削除するもの

- `nvim/init.vim`, `nvim/dein.toml`, `nvim/dein_lazy.toml`, `nvim/nvim/`(旧構成一式)

### 新構成

```
nvim/
├── init.lua
├── lazyvim.json
├── lua/
│   ├── config/
│   │   ├── lazy.lua        # lazy.nvim ブートストラップ + LazyVim 読み込み
│   │   ├── options.lua     # 現設定の移植(tabstop=2, clipboard, cursorline 等)
│   │   ├── keymaps.lua     # ;↔: スワップ等
│   │   └── autocmds.lua
│   └── plugins/            # 追加・上書きプラグイン設定
└── README.md
```

### 移植する現設定

- `number`, `tabstop=2`, `shiftwidth=2`, `expandtab`, `autoindent`
- `clipboard=unnamedplus`(WSL では win32yank を clipboard provider として自動検出)
- `hlsearch`, `termguicolors`, `list`+`listchars`, `whichwrap`, `cursorline`
- `nnoremap ; :` / `nnoremap : ;`

LSP / Treesitter / telescope / gitsigns / which-key は LazyVim デフォルトで有効。日本語コメントで設定意図を残す。

## 3. tmux

- `reattach-to-user-namespace` 依存を削除(tmux 2.6+ で不要。現状 Linux/WSL では `default-command` が壊れて起動に失敗するため必須修正)
- コピー(copy-mode-vi の `y`/`Enter`)は OS 判定でクリップボードコマンドを自動選択: pbcopy(macOS) / win32yank.exe or clip.exe(WSL) / wl-copy・xclip(Linux)
- `default-terminal tmux-256color` + `terminal-features ',*:RGB'` で TrueColor 対応
- **tpm** 導入: プラグインは `tmux-sensible`, `tmux-yank` の最小構成。tpm 本体は `common-post.sh` で clone
- 維持: prefix `^T`、vi copy-mode、h/j/k/l ペイン移動、H/J/K/L リサイズ、`|`/`-` 分割、`r` リロード

## 4. git 設定強化

`.gitconfig` に追加(既存エイリアス・既存設定は全維持):

- `core.pager = delta` + delta 設定(navigate 有効、side-by-side なし、行番号表示)
- `interactive.diffFilter = delta --color-only`
- `merge.conflictstyle = zdiff3`
- `rerere.enabled = true`
- `push.autoSetupRemote = true`
- `fetch.prune = true`
- `branch.sort = -committerdate` / `tag.sort = version:refname`
- `diff.algorithm = histogram` / `diff.colorMoved = default`
- `commit.verbose = true`
- `column.ui = auto`
- `help.autocorrect = prompt`

delta 未導入環境で git が壊れないよう、doctor で検査対象にする(pager が見つからない場合 git はエラーになるため、delta は必須ツール扱い)。

## 5. パッケージ管理・WSL 対応

### Brewfile 追加

`eza`, `zoxide`, `atuin`, `git-delta`, `lazygit`, `btop`, `dust`, `duf`, `tlrc`

### apt-packages.txt 追加(apt に存在するもの)

`zoxide`, `btop`, `duf`

### common-post.sh 追加(apt に無い/古いもの、Linux のみ実行)

- `eza`: gierens deb リポジトリ経由
- `atuin`: 公式インストーラ
- `git-delta`, `lazygit`, `dust`: GitHub releases から deb / バイナリ導入
- `tlrc`: GitHub releases(または cargo があれば cargo install)
- `tpm`: `git clone` to `~/.tmux/plugins/tpm`(macOS も共通)
- 既存の starship / mise / peco / fisher 導入処理のうち、peco は削除

### setup.sh doctor

新ツール(starship, atuin, zoxide, eza, delta, lazygit)の存在検査を追加。delta は git pager に設定するため未導入だと git が壊れる旨を警告。

## 6. 後始末・ドキュメント

- README.md のツール一覧・WSL 対応表を更新
- CLAUDE.md の記述(peco 等への言及)を更新
- 削除対象ファイルは git rm(履歴には残る)

## テスト・検証

- `./setup.sh doctor` が macOS で全パスすること
- `fish -n` / `bash -n` 構文検証(既存 hook で自動)
- `nvim --headless "+Lazy! sync" +qa` でプラグイン導入がエラーなく完了すること
- `tmux -f .tmux.conf new-session -d` で起動確認
- `git diff` で delta が動作すること
- WSL 側は実機がないため、install 経路は `--dry-run` とコードレビューで担保(README に検証未実施の旨を記載)

## スコープ外

- karabiner / wezterm の設定変更
- Claude Code 環境(直近モダナイズ済み)
- chezmoi 移行(install/README.md の判断基準を踏襲し、現時点では見送り)
- atuin のサーバー同期セットアップ(ユーザー任意)
