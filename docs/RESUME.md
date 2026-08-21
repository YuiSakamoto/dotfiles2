# 作業再開メモ — モダナイズブランチの取り込み

最終更新: 2026-08-21 / ブランチ: `feat/zsh-and-cmux-setup`

## いま何をしているか

未マージのまま放置されていた `origin/feat/modernize-2026-07`（19コミット）を、
zsh 移行後の現環境に取り込んでいる途中。ブランチの設計書は
`git show origin/feat/modernize-2026-07:docs/superpowers/specs/2026-07-07-dotfiles-modernization-design.md`
で読める。

ブランチは「fish をモダナイズ」する設計だったが、こちらは zsh へ移行済みなので
**シェル部分は zsh へ読み替え、それ以外はほぼそのまま取り込む**方針。

## 決定済みの方針

| 論点 | 決定 |
| --- | --- |
| GUI アプリ（cask 18個） | 全部入れる |
| atuin | 導入し、Ctrl+R を fzf から atuin に切り替える |
| tmux モダナイズ | 取り込む（SSH 先で使うため） |
| fish | 移行期間中は併存。peco も残す |

## 済んだこと

- [x] `install/Brewfile` — ブランチの内容をマージ。廃止 tap と plain terraform の
      再発を防ぎ、tflint（tap の cask 配布に変更）と kindle（cask 削除）を現行の
      入手経路に修正
- [x] `.gitconfig` — delta を pager に、zdiff3 / rerere / autoSetupRemote 等を追加
- [x] `mise install` — node/pnpm/go/rust/python/uv を導入（hook の `node not found` 解消）
- [x] `claude-code-hooks` — 入手元が `delphinus/claude-code-hooks` tap だと判明し復帰

## 残っていること

### 1. パッケージの実インストール（最初にこれ）

Brewfile の定義は済んでいるが、**cask 群のダウンロードが未完了**。
オフライン前に流し切れなかったので、まずこれを実行する。

```bash
./setup.sh install
```

### 2. Neovim を LazyVim ベースに刷新

現状は dein.vim。ブランチに完成済みの構成があるので、そのまま取り込む。

```bash
git checkout origin/feat/modernize-2026-07 -- nvim/
nvim --headless "+Lazy! sync" +qa   # 検証
```

移植済みの設定: `tabstop=2`, `clipboard=unnamedplus`, `;`↔`:` スワップ など。

### 3. tmux モダナイズ

`reattach-to-user-namespace` 依存の除去（Linux/WSL では起動失敗する）、
TrueColor、tpm 導入。prefix `^T` とペイン操作の手癖は維持される。

```bash
git checkout origin/feat/modernize-2026-07 -- .tmux.conf
```

tpm 本体の clone は `install/common-post.sh` に処理を足す必要がある（未着手）。

### 4. zsh 側へのシェル機能の取り込み（読み替えが必要）

ブランチは fish 向けなので、そのままでは使えない。移し先は `zsh/conf.d/`。

- **atuin**: `zsh/conf.d/30-tools.zsh` に `eval "$(atuin init zsh)"` を追加し、
  Ctrl+R を atuin に。いまは `source <(fzf --zsh)` が Ctrl+R を握っているので、
  読み込み順とキーバインドの調整が要る（`40-keybind.zsh` 参照）
- **fkill**: ブランチの `fish/functions/fkill.fish`（fzf 版プロセス kill）を
  `zsh/functions/fkill` として移植。既存の `kpp` と役割が近いので整理する
- **starship.toml**: ブランチ版は git status / 言語バージョン / k8s context /
  コマンド実行時間が入っている。`git diff main...origin/feat/modernize-2026-07 -- starship.toml`
- **alias**: `lg`(lazygit) など、ブランチの `fish/conf.d/alias.fish` の追加分を
  `zsh/conf.d/50-alias.zsh` にも反映

### 5. herdr / hunk

- `herdr/config.toml` — ブランチで claude integration（SessionStart フック）が
  入っている。`git diff main...origin/feat/modernize-2026-07 -- herdr/`
- `hunk` — レビュー向け diff ビューア。導入済みなので使い方を docs に書く程度

### 6. doctor・ドキュメントの統合

- `bin/dotfiles-doctor` — ブランチ版は新ツール（starship/atuin/zoxide/eza/delta/
  lazygit）検査と delta 必須検査を持つ。こちらは zsh 検査と生成物混入検査を
  追加済みなので、**両方をマージする**
- `docs/cheatsheet.md`（ブランチ、221行）と `docs/SHORTCUTS.md`（こちら）の統合。
  ブランチ側は nvim / tmux / git ツールの記載があるので、そこを取り込む
- `README.md` / `CLAUDE.md` — ツール一覧と WSL 対応表の更新

### 7. Linux/WSL 導入経路

`install/common-post.sh` に、apt に無いツールの導入を追加（eza / atuin /
git-delta / lazygit / dust / tlrc / tpm）。ブランチに実装があるので流用する。

```bash
git diff main...origin/feat/modernize-2026-07 -- install/common-post.sh install/apt-packages.txt
```

## 再開のしかた

```bash
cd ~/src/github.com/YuiSakamoto/dotfiles2
claude --continue          # 直前の会話を再開する
```

会話を選び直したい場合は `claude --resume`。
このファイルを読ませれば、どこまで進んだかは伝わる。

## 検証コマンド

```bash
./setup.sh doctor                      # symlink・構文・生成物混入・ツール
zsh -n .zshenv zsh/conf.d/*.zsh        # zsh 構文
ZSH_PROFILE=1 zsh -i -c exit           # 起動プロファイル（目標 100ms 未満）
cmux config validate && cmux reload-config
git diff                               # delta が効いているか
```
