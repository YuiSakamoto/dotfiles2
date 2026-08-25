---
name: dotfiles-doctor
description: dotfiles の設定ファイル（zsh / nvim / cmux / herdr / .claude 等）を変更した後に環境を検査する。ユーザーが「環境チェックして」「doctorして」と言ったとき、または /dotfiles-doctor 実行時に使う。
---

# dotfiles-doctor

設定変更の検証ループを閉じるためのスキル。「変更したら必ず機械検査する」を徹底する。

## 手順

1. dotfiles リポジトリのルートで検査を実行する:

   ```bash
   cd ~/src/github.com/YuiSakamoto/dotfiles2 && ./setup.sh doctor
   ```

2. **fail が1件でもあれば必ず修正してから再実行する**。よくある fail と対処:
   - `symlink 不正` → `./setup.sh link` で張り直す（実体ファイルが先にある場合は退避が必要）
   - `秘密情報が git 追跡されている` → 即座に `git rm --cached` し、`.gitignore` を確認
   - `構文エラー` → 該当ファイルを修正（zsh -n / bash -n / jq 等で個別確認できる）
   - `生成物の混入` → 出力先を `~/.cache` / `~/.local` 側へ逃がす設定に直す
   - `ツール未導入` → `./setup.sh install`（Brewfile / apt-packages.txt に追加してから）

3. すべて pass したら結果を報告する。**pass を確認する前に「完了した」と言わないこと**。

## 補足

- 新しいツールの設定を足した場合は、`setup.sh` の link 対象と `bin/dotfiles-doctor` の `config_targets` / `tools` への追加も検査対象（CLAUDE.md の規約）
- cmux の設定を触った場合は `cmux config validate && cmux reload-config` も併せて実行する
- herdr の設定を触った場合は `herdr server reload-config` でライブ反映できる
