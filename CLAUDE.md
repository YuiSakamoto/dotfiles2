# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
英語で考えて日本語で返答して

## Repository Overview

個人の開発環境の設定ファイル集。`setup.sh` が OS を判定して symlink を張り、
パッケージを導入する。**`~/.config` 配下に実体ファイルは置かず、すべてこの
リポジトリへの symlink にする**のが基本方針（リポジトリを唯一の正とする）。

## Setup Commands

```bash
./setup.sh install   # パッケージ導入 (macOS: brew bundle / Linux: apt) + common-post.sh
./setup.sh link      # symlink を張る
./setup.sh all       # 上の両方
./setup.sh doctor    # bin/dotfiles-doctor で環境を検査
./setup.sh --dry-run all   # 何をするかだけ出力
```

詳細は [README.md](README.md)、キーバインドは [docs/SHORTCUTS.md](docs/SHORTCUTS.md)。

## Architecture

ツールごとにディレクトリを分け、`setup.sh` の `link_home` / `link_config` /
`link_claude` / `link_bin` が対応する場所へ symlink する。

### zsh（メインシェル）

**ZDOTDIR 方式**。`$HOME` 直下に置くのは `.zshenv` だけで、設定本体は
`~/.config/zsh/`（= `zsh/`）に集約する。`~/.zshrc` は存在してはいけない。

- `.zshenv` — 全 zsh 起動（非対話含む）で読まれる。PATH と環境変数のみ。
  `brew shellenv` は fork コストのため中身を直接展開している
- `zsh/.zshrc` — `conf.d/*.zsh` を番号順に読むだけ
- `zsh/conf.d/` — `00-options` / `10-completion` / `20-plugins` / `30-tools` /
  `40-keybind` / `50-alias`
- `zsh/functions/` — autoload 関数（1ファイル1関数、本体だけを書く）

**読み込み順の制約**（壊すと静かに機能が消える）:

1. `bindkey -e` は **すべてのプラグイン・ツールがキーを張る前**（`00-options`）。
   後から張り替えると、それまでのバインドが丸ごと無効になる
2. `sheldon source`（fzf-tab を含む）は **`compinit` の後**（`20-plugins`）
3. atuin は **fzf 統合の後**（`30-tools`）。`Ctrl+R` を fzf から奪うため
4. Tab の fzf-tab への再バインドは fzf 統合の後（`40-keybind`）

### その他

- `sheldon/plugins.toml` — zsh プラグイン。データは `~/.local/share/sheldon`
- `atuin/config.toml` — シェル履歴。DB は `~/.local/share/atuin`
- `nvim/` — LazyVim ベース。`lua/config/`（設定）と `lua/plugins/`（追加・上書き）
- `fish/` — zsh 移行期間中の併存用。積極的にメンテはしない
- `cmux/cmux.json` + `ghostty/config` — cmux（ghostty 内蔵）の外観とキーバインド
- `herdr/config.toml` — エージェント対応マルチプレクサ
- `.tmux.conf` — SSH 先用に維持。tpm 管理
- `install/` — `Brewfile`（macOS）/ `apt-packages.txt`（Linux）/ `common-post.sh`（共通後処理）
- `bin/dotfiles-doctor` — symlink 構成・秘密情報・構文・生成物混入・ツール導入の検査

## Conventions

- 設定ファイルのコメントは日本語。**「何を」ではなく「なぜ」**を書く
  （特に読み込み順やガード条件の理由は、消されると再発するので必ず残す）
- ツールの生成物（zcompdump / history / plugins.lock 等）がリポジトリに落ちないよう、
  出力先は `~/.cache` / `~/.local` 側へ逃がす。doctor が混入を検査する
- 新しいツールの設定を足すときは `setup.sh` の link 対象と
  `bin/dotfiles-doctor` の `config_targets` / `tools` にも追加する

## Important Notes from .cursorrules

- **技術スタックのバージョンは変更せず、必要があれば必ず承認を得る**
- **UI/UX デザインの変更（レイアウト、色、フォント、間隔など）は禁止**
- 重複実装の防止: 既存の類似機能や同名の関数・コンポーネントを確認する
- 明示的に指示されていない変更は行わない

## Git Workflow

`.gitconfig` に多数のエイリアスがある（`g aaa` で全一覧）。

- `g s` / `gs`: status
- `g po`: push to origin
- `g up`: pull --rebase
- `g rbm`: rebase on master
- `g dmb`: マージ済みブランチを一括削除

pager は delta。`.gitconfig` が `pager = delta` を指定しているので、
**delta が無いと git diff / log / show が壊れる**（doctor が fail で検出する）。
