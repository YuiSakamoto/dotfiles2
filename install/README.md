# install/

パッケージインストール関連のファイル置き場。

## ファイル

| ファイル | 用途 |
| --- | --- |
| `Brewfile` | macOS 用。`brew bundle --file=install/Brewfile` で使用。 |
| `apt-packages.txt` | Debian/Ubuntu/WSL 用。`#` コメントと空行を無視してパッケージ名を読む。 |
| `common-post.sh` | OS共通の後処理。starship / mise / peco / fisher など、パッケージマネージャにない or 古いものを公式ルートで導入する。 |

## 方針

- **macOS は brew / Linux は apt** が原則。
- **apt に載っていない or 古い**ものだけ `common-post.sh` で個別導入。ここが増えすぎたら chezmoi 等への移行を検討する。
- GUI/フォント/IDE などは各OS固有なので、共通管理は CLI に絞る。

## apt-packages.txt を編集したら

```bash
./setup.sh install   # Linux側の取り込み
```

## Brewfile を編集したら

```bash
./setup.sh install   # macOS側の取り込み
# もしくは
brew bundle --file=install/Brewfile
```

## 今後の方針: dotfiles 管理ツール移行の判断

現状は bash 製 `setup.sh` + `install/` で「OS 判定・冪等・バックアップ・`--dry-run`・`~/.claude/` 部分 symlink」を自前実装している。2026/4 時点でのリサーチ結果では、**機能要件を完全にカバーする後継候補は [chezmoi](https://www.chezmoi.io/)** (Go 製、毎月リリース、テンプレート/secrets/OS 分岐が一級市民) だが、**現時点で移行する価値は低い**と判断。

### 現状維持で十分な理由

- すでに冪等・dry-run・バックアップ・OS 分岐・部分 symlink を実装済み。chezmoi に乗り換えても `run_onchange_*.sh.tmpl` に同じことを書くだけ。
- chezmoi のファイル名規約 (`dot_`, `private_`, `executable_run_onchange_` など) に沿ってリネームする必要があり、git 履歴が一度途切れる。管理ファイル数が 10 前後の規模だと学習コストが釣り合わない。
- Stow / yadm は機能後退 (テンプレート不可 / Brewfile 連携が弱い)、home-manager は Nix 学習コストが過大、mackup は実質終了。よって現状の bash 自作より明確に優れているのは chezmoi だけ、という前提での判断。

### 移行を検討すべきトリガー (どれか1つでも発生したら)

1. **管理マシンが 3 台以上**に増える、または WSL 以外の Linux 実機が加わる
2. **`~/.claude/` 以外にも**「同階層に runtime state と管理対象が混在」する dotfile が増える (`~/.config/gh/`, `~/.aws/` 等)
3. **secrets を git 管理したくなる** (bash で age / 1Password CLI を自前で叩くと TOCTOU やエラーハンドリングで壊れやすい)
4. fish の `if test (uname) = Darwin` 分岐が設定ファイル全体に散らばって辛くなる (chezmoi ならビルド時に template で解決できる)

### 移行する場合の段階的アプローチ

1. `chezmoi init` で試験的に並行運用。まず fish 設定 1 ファイルだけを template 化して `if test (uname)` を消す体験を得る
2. Brewfile / apt-packages.txt を `run_onchange_before_install-packages-{darwin,linux}.sh.tmpl` に移す
3. `~/.claude/` の選択的 symlink を `.chezmoiexternal` もしくは個別 `symlink_` ファイルで再現
4. 並行運用で問題なければ `setup.sh` と `install/` を退役
