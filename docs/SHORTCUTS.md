# ショートカット早見表

fish → zsh 移行と cmux 導入で変わったキーバインド・エイリアスの一覧。
設定の実体は [`zsh/`](../zsh), [`cmux/cmux.json`](../cmux/cmux.json), [`.gitconfig`](../.gitconfig)。

## cmux — Ctrl+T プレフィックス

tmux の手癖をそのまま持ち込むため、`Ctrl+T` を **2ストロークのプレフィックス**にしてある
（`Ctrl+T` を押してから次のキー）。cmux 側が `Ctrl+T` を握るので、シェルには届かない。

| キー | 動作 | アクション名 |
| --- | --- | --- |
| `Ctrl+T` `Shift+\` | 右に分割（`\|` を打つ手つきのまま） | `splitRight` |
| `Ctrl+T` `-` | 下に分割 | `splitDown` |
| `Ctrl+T` `h` | 左のペインへ | `focusLeft` |
| `Ctrl+T` `j` | 下のペインへ | `focusDown` |
| `Ctrl+T` `k` | 上のペインへ | `focusUp` |
| `Ctrl+T` `l` | 右のペインへ | `focusRight` |
| `Ctrl+T` `z` | ペインをズーム／戻す | `toggleSplitZoom` |
| `Ctrl+T` `=` | ペインサイズを均等化 | `equalizeSplits` |
| `Ctrl+T` `c` | 新規タブ | `newSurface` |
| `Ctrl+T` `x` | 閉じる | `closeTab` |
| `Ctrl+T` `r` | タブ名を変更 | `renameTab` |

> これらに割り当てたことで、既定の `Cmd+D` / `Cmd+Shift+D` / `Cmd+Opt+矢印` /
> `Cmd+Shift+Return` / `Cmd+T` / `Cmd+W` / `Cmd+R` は**使えなくなっている**。
> 1つのアクションに割り当てられるキーは1つだけのため。

### 割り当てを書き換えるときの注意

cmux が2打目に受け付けるのは**キー**であって文字ではない。使えるのは次の範囲だけ。

```
英数字 [A-Za-z0-9]
記号   , . / \ ; ' ` = [ ] -
その他 space / tab / return / 矢印 / F1-F20 / メディアキー
```

`|` `!` `@` のような**シフトを伴う文字は書けない**。`|` は US 配列では物理的に
`Shift+\` なので、そう書く必要がある（`splitRight` がこの形になっているのはこのため）。
`"|"` と書いても `cmux config validate` は JSONC の構文しか見ないので通ってしまい、
**エラーも出ないまま無反応になる**ので注意。

## cmux — 既定のまま残っているもの

| キー | 動作 |
| --- | --- |
| `Cmd+Shift+P` | コマンドパレット |
| `Cmd+P` | ワークスペースへ移動 |
| `Cmd+B` | サイドバーの開閉 |
| `Cmd+N` | 新規ウィンドウ内タブ |
| `Cmd+F` | 検索 |
| `Cmd+Opt+F` | 全体検索 |
| `Cmd+Opt+B` | ファイルエクスプローラの開閉 |
| `Cmd+Shift+[` / `Cmd+Shift+]` | 前 / 次のサーフェス |
| `Cmd+1`…`Cmd+9` | ワークスペースを番号で選択 |
| `Ctrl+1`…`Ctrl+9` | サーフェスを番号で選択 |
| `Cmd+,` | 設定 |
| `Cmd+Shift+,` | 設定の再読み込み（`reload_config`） |

見た目やキーバインドを変更したら反映が必要。ターミナルから `cmux reload-config` を
実行するのが一番早い (アプリ再起動は不要)。`Cmd+Shift+,` でも同じ。
`cmux config validate` で構文チェック、`cmux shortcuts` で設定画面を開ける。

## zsh — キーバインド

| キー | 動作 | 由来 |
| --- | --- | --- |
| `Ctrl+R` | コマンド履歴を fzf で検索 | fzf（旧 peco） |
| `Ctrl+O` | ファイルを fzf で選んで挿入 | fzf（既定の `Ctrl+T` から退避） |
| `Alt+C` | ディレクトリを fzf で選んで `cd` | fzf |
| `Ctrl+G` | ghq 管理下のリポジトリへ移動 | 自作 widget |
| `Tab` | 補完候補を fzf のポップアップで選択 | fzf-tab |
| `Ctrl+T` | **使わない**（cmux のプレフィックス） | — |
| `Ctrl+W` | パスを1階層ずつ削る | `WORDCHARS` 調整 |
| `→` / `Ctrl+F` | 履歴からのグレー候補を確定 | zsh-autosuggestions |

キーマップは emacs 固定（`bindkey -e`）。`EDITOR` に `vi` が含まれていても viins にならない。

## zsh — 関数・コマンド

| コマンド | 動作 |
| --- | --- |
| `z <部分文字列>` | よく行くディレクトリへジャンプ（zoxide。旧 z プラグイン） |
| `zi` | 履歴から対話的に選んでジャンプ |
| `bd <名前>` | 親ディレクトリを名前で遡る（`bd -s` 前方一致 / `bd -i` 大小無視） |
| `wt` | git worktree 操作のまとめ（`wt list` / `wt add` / `wt remove`） |
| `wtg <名前>` | worktree へ移動 |
| `wtf` | fzf で worktree を選んで移動 |
| `wtr` | リポジトリのルートへ移動 |
| `kpp <ポート>` | そのポートを掴んでいるプロセスを kill |
| `tmux_pane_title <文字列>` | tmux のペインタイトルを設定（`tpt`） |

## シェル alias

| alias | 実体 |
| --- | --- |
| `ls` / `ll` / `la` / `lt` | `eza`（アイコン + git 状態。`lt` はツリー表示） |
| `vi` / `v` | `nvim` |
| `g` / `gi` | `git` |
| `gs` / `gst` | `git status -s -b` |
| `gc` / `gci` / `gd` | `git commit` / `git commit -a` / `git diff` |
| `d` / `dc` | `docker` / `docker compose` |
| `k` / `kg` / `kd` / `kcx` | `kubectl` / `get` / `describe` / `kubectx` |
| `tf` | `terraform` |
| `gcl` | `gcloud` |
| `cl` | `claude` |
| `tm` / `tma` / `tml` | `tmux` / `tmux attach` / `tmux list-sessions` |
| `du` / `df` / `duh` | `du -h` / `df -h` / `du -h -d 1 ./` |
| `ij` | IntelliJ IDEA を開く |

## git alias（よく使うもの）

全一覧は `g aaa` で色付き表示できる（`g a` / `g aa` でも可）。

| alias | 実体 |
| --- | --- |
| `g s` / `g ss` | `status` / `status -s` |
| `g ad` / `g c` / `g ci` | `add` / `commit` / `commit -a` |
| `g cam` | `commit -a --amend`（直前のコミットを修正） |
| `g co` / `g cb` / `g ct` | `checkout` / `checkout -b` / `checkout --track` |
| `g br` / `g ba` / `g bm` | `branch` / `branch -a` / `branch --merged` |
| `g up` | `pull --rebase` |
| `g po` / `g pu` | `push origin` / `push -u origin` |
| `g please` | `push --force-with-lease --force-if-includes`（安全な force push） |
| `g rbm` / `g rbd` | `rebase --merge master` / `develop` |
| `g rbi1`…`g rbi5` | `rebase -i HEAD^`…`HEAD^^^^^` |
| `g rbc` / `g rba` | `rebase --continue` / `--abort` |
| `g r1`…`g r5` | `reset HEAD~`…`HEAD~~~~~` |
| `g rsh1`…`g rsh5` | `reset --soft HEAD~`… |
| `g d1`…`g d5` | `diff HEAD~`… |
| `g lg` / `g ll` / `g la` | グラフ表示 / 1行ログ / ざっくりログ |
| `g dmb` | マージ済みブランチを一括削除 |
| `g wta` / `g wtl` / `g wtr` | worktree の追加 / 一覧 / 削除 |

## tmux（現状維持）

cmux に移行したので普段は使わないが、SSH 先などのために `.tmux.conf` は残してある。
プレフィックスは `Ctrl+T` のまま（cmux の中では cmux 側が奪うため届かない）。

| キー | 動作 |
| --- | --- |
| `Ctrl+T` `\|` / `-` | 横 / 縦に分割 |
| `Ctrl+T` `h` `j` `k` `l` | ペイン移動 |
| `Ctrl+T` `H` `J` `K` `L` | ペインをリサイズ |
| `Ctrl+T` `r` | 設定を再読み込み |
| `Ctrl+T` `T` | ペインタイトルを設定 |
