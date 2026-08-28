# ショートカット早見表

この環境（dotfiles2）の**実設定**に合わせた早見表。upstream の既定ではなく、
ここのエイリアス・キーバインド前提で書く。**育てるドキュメント**なので、
調べたことは末尾の「追記メモ」に足して、整理できたら各節へ昇格させる。

設定の実体は [`zsh/`](../zsh) / [`cmux/cmux.json`](../cmux/cmux.json) /
[`herdr/config.toml`](../herdr/config.toml) / [`atuin/config.toml`](../atuin/config.toml) /
[`.gitconfig`](../.gitconfig) / [`.tmux.conf`](../.tmux.conf) / [`nvim/`](../nvim)。

---

## cmux — ガワ操作（Cmd 系）

`Ctrl+T` の2ストロークプレフィックスは **herdr に譲って廃止**した（バインドは
`cmux/cmux.json` にコメントアウトで温存してあり、戻せる）。対話 zsh は cmux 内でも
herdr に常駐するため、`Ctrl+T` はペイン内の herdr が受ける。分割・ペイン移動・
コピーモードは herdr（次節）の手癖をそのまま使う。

cmux 本体の操作は既定の Cmd 系に戻った:
`Cmd+D`（右分割）/ `Cmd+Shift+D`（下分割）/ `Cmd+Opt+矢印`（ペイン移動）/
`Cmd+Shift+Return`（ズーム）/ `Cmd+T`（新規タブ）/ `Cmd+W` / `Cmd+R` が復活。
その他は「既定のまま残っているもの」の表が正。

### コピーモード内のキー（vi 風・ハードコード）

普段のコピーモードは herdr 側（`prefix` `[`）を使う。cmux のコピーモードは
prefix 廃止で「入る専用キー」が無くなった（使うならコマンドパレット
`Cmd+Shift+P` から、または cmux.json の shortcuts を復活させる）。
入ったあとのキーは cmux 本体にハードコードされていて変更できない。
**tmux copy-mode-vi の既定だった `Space`（選択開始）と `Enter`（コピー）は
効かない**ので、選択開始は `v`、コピーは `y`。

| キー | 動作 |
| --- | --- |
| `h` `j` `k` `l` / 矢印 | カーソル移動（選択中は選択範囲を伸縮） |
| `v` / `V` | 選択開始・解除 / 行選択 |
| `y` | 選択をコピーして終了 |
| `yy` / `Y` | 選択なしのとき現在行をコピーして終了 |
| `gg` / `G` | 最上部 / 最下部へ |
| `0` `^` / `$` | 行頭 / 行末 |
| `Ctrl+U` / `Ctrl+D` | 半ページスクロール |
| `Ctrl+B` / `Ctrl+F` | 1ページスクロール |
| `Ctrl+Y` / `Ctrl+E` | 1行スクロール |
| `{` / `}` | 前 / 次のプロンプトへジャンプ |
| `/` → `n` / `N` | 検索 → 次 / 前の一致へ |
| `3j` など数字プレフィックス | 回数指定 |
| `q` / `Esc` | コピーモード終了 |

出典: cmux 実装の
`CmuxTerminalCore/Sources/CmuxTerminalCore/CopyMode/TerminalKeyboardCopyModeKeyResolution.swift`
（設定項目がスキーマに無いことも確認済み。挙動が変わったらまずここを読み直す）。

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

### 配色（常時ダーク固定 / CUD 準拠）

macOS のライト/ダーク追従はやめ、**常時ダークに固定**してある。
そのうえで、赤緑の識別が落ちても読めるよう ANSI パレットを置き換えている。

```
赤 → 朱色 #ff5f45（橙寄り）      緑 → 青緑 #00d7a3（teal）
```

ターミナルは git diff の追加/削除、テストの成功/失敗と「赤 vs 緑」に意味を
載せる場面が多い。朱と青緑なら、赤緑の識別が落ちても保たれる**青-黄軸**で
分かれる。明度も離してあるので、色相が完全に潰れても明暗で区別できる。

| 何 | どこで決まるか |
| --- | --- |
| ターミナルの16色 | `ghostty/config` の `palette = N=#hex` |
| アプリUI・ペイン枠 | `cmux/cmux.json`（`app.appearance = "dark"`） |
| Neovim | `nvim/lua/plugins/core.lua`（tokyonight の `on_colors`） |
| git diff の ± | `.gitconfig` の `[delta]` |
| fzf のポップアップ | `zsh/conf.d/30-tools.zsh` の `FZF_DEFAULT_OPTS` |

**5箇所すべてを揃えること。** 1つでも外すと OS 追従やツール独自パレットに
戻り、置き換えが効かなくなる。特に `cmux.json` の `terminal.adaptiveDefaultTheme`
は **false** のままにする（true だと ghostty の指定を無視して cmux 独自パレットが入る）。

色だけに頼らない冗長化も入れてある。git diff は行番号と `+`/`-` を常時表示し、
cmux のペインは「枠が出る/出ない」という形の差でフォーカスを示す。

### cmux — 既定のまま残っているもの

| キー | 動作 |
| --- | --- |
| `Cmd+Shift+P` | コマンドパレット |
| `Cmd+P` | ワークスペースへ移動 |
| `Cmd+B` | サイドバーの開閉 |
| `Cmd+N` | 新規ウィンドウ内タブ |
| `Cmd+F` / `Cmd+Opt+F` | 検索 / 全体検索 |
| `Cmd+Opt+B` | ファイルエクスプローラの開閉 |
| `Cmd+Shift+[` / `Cmd+Shift+]` | 前 / 次のサーフェス |
| `Cmd+1`…`Cmd+9` | ワークスペースを番号で選択 |
| `Ctrl+1`…`Ctrl+9` | サーフェスを番号で選択 |
| `Cmd+,` / `Cmd+Shift+,` | 設定 / 設定の再読み込み |

見た目やキーバインドを変更したら反映が必要。ターミナルから `cmux reload-config` を
実行するのが一番早い（アプリ再起動は不要）。`Cmd+Shift+,` でも同じ。
`cmux config validate` で構文チェック、`cmux shortcuts` で設定画面を開ける。

---

## herdr — エージェント対応マルチプレクサ

概念: **Session** → **Workspace**（プロジェクト単位）→ **Tab** → **Pane** →
**Agent**（ペイン内の AI プロセスを自動検出）。エージェント状態（working / blocked /
done / idle）はサイドバーに集約される。prefix は tmux・cmux と同じ **Ctrl+T**。

**常駐方式**: 対話 zsh は起動時に herdr へ自動アタッチする
（`zsh/conf.d/05-herdr-attach.zsh`）。**cmux でも Ghostty 単体でも、開けばそのまま
herdr の中**（cmux の Ctrl+T バインドは廃止済みなので prefix は herdr に届く）。
tmux 内・SSH 先・TTY なし起動だけは従来どおり素の zsh。素の zsh が欲しいときは
`HERDR_AUTO=0 zsh`。`prefix q`（デタッチ）すると素の zsh に戻ってくる
（セッションはサーバー側で生き続け、次にシェルを開けば復帰）。herdr の起動に
失敗した場合も素の zsh にフォールバックするので端末が開けなくなることはない。
複数ウィンドウから同時に開くと同一セッションのミラー表示になる（tmux と同じ。
増殖はしない）。

### ペイン・タブ（tmux 移植分、体が覚えてる系）

| キー | 動作 |
| --- | --- |
| `prefix h/j/k/l` | ペイン移動（`shift+` で入れ替え） |
| `prefix \|` / `prefix -` | 縦 / 横分割 |
| `prefix z` | ズーム |
| `prefix c` / `prefix 1..9` / `prefix p/n` | 新規タブ / 直接切替 / 前後 |
| `prefix x` / `prefix ;` | ペインを閉じる / 直前のペインへ |
| `prefix [` | コピーモード（`v` 選択 → `y` コピー、`q` 終了） |
| `prefix r` | リサイズモード |
| `prefix q` | デタッチ（エージェントは走り続ける。`herdr` で再アタッチ） |

### herdr ならでは（ここを使い込む）

| キー | 動作 |
| --- | --- |
| `prefix o` | **通知元のペインへジャンプ**（blocked になったエージェントに即飛ぶ） |
| `prefix e` | **スクロールバックを $EDITOR (nvim) で開く** — 検索はこれで `/`（コピーモードに検索は無い） |
| `prefix f` | セッションナビゲータ（goto。既定の `prefix g` は lazygit に譲って移設） |
| `prefix w` | ワークスペースピッカー（navigate モード中は `ctrl+k/j` で上下） |
| `prefix ↑` / `prefix ↓` | 前 / 次のワークスペースへ直接切替 |
| `prefix ,` / `prefix .` | 前 / 次のエージェントへ |
| `prefix alt+1..9` | エージェント直接フォーカス |
| `prefix shift+g` / `prefix shift+o` / `prefix alt+d` | worktree ワークスペース 作成 / 開く / 削除 |
| `prefix g` | lazygit をペインで起動（カスタムコマンド） |
| `prefix b` | サイドバー表示切替 |
| `prefix s` / `prefix ?` | 設定 UI / ヘルプ |

### CLI（スクリプト・エージェント連携）

```bash
herdr server reload-config                 # config.toml をライブ反映
herdr agent start reviewer --split right -- claude   # 隣にエージェント起動
herdr agent send <target> "続けて"          # エージェントへテキスト送信
herdr agent read <target> --lines 120      # ペイン出力を読む
herdr wait agent-status w1:p1 --status done --timeout 600000  # 完了を待つ
herdr wait output w1:p1 --match "tests passed" --regex        # 出力を待つ
herdr notification show "build done" --sound request          # macOS 通知
herdr worktree create --branch feat/x --base main --focus     # worktree WS 生成
herdr --session <name> / herdr session list                   # 名前付きセッション
herdr --remote <ssh-host>                  # リモートの herdr へ接続
```

- マウス: ドラッグで自動コピー、ダブルクリックでトークン抽出、Ctrl+クリックで URL を開く
- ペイン内には `HERDR_PANE_ID` / `HERDR_ENV` / `HERDR_SOCKET_PATH` 等の環境変数が入る
  （自ペインを対象に API を叩ける。zsh の常駐ガードもこれで判定している）
- **claude integration はマシンごとに `herdr integration install claude` が必要**
  （repo の設定ファイルには入らない）。SessionStart フックで登録されるので
  **Claude Code のセッションを開き直してから**有効になる。
  更新確認は `herdr integration status --outdated-only`

---

## zsh — キーバインド

| キー | 動作 | 由来 |
| --- | --- | --- |
| `Ctrl+R` | コマンド履歴を検索 | **atuin**（旧 peco → fzf から移行） |
| `Ctrl+O` | ファイルを fzf で選んで挿入 | fzf（既定の `Ctrl+T` から退避） |
| `Alt+C` | ディレクトリを fzf で選んで `cd` | fzf |
| `Ctrl+G` | ghq 管理下のリポジトリへ移動 | 自作 widget |
| `Tab` | 補完候補を fzf のポップアップで選択 | fzf-tab |
| `↑` | 素の履歴移動（atuin には渡していない） | zsh |
| `Ctrl+T` | **herdr のプレフィックス**（シェルには届かない） | herdr |
| `Ctrl+X` `?` | この早見表を開く | 自作 widget（`cheat`） |
| `Ctrl+W` | パスを1階層ずつ削る | `WORDCHARS` 調整 |
| `→` / `Ctrl+F` | 履歴からのグレー候補を確定 | zsh-autosuggestions |

キーマップは emacs 固定（`bindkey -e`）。`EDITOR` に `vi` が含まれていても viins にならない。

## atuin — 履歴検索（Ctrl+R）

`enter_accept = false` にしてあるので **Enter では実行されず、コマンドラインに入るだけ**。
目視してからもう一度 Enter で実行する（peco / fzf 時代と同じ手順）。
`--disable-up-arrow` で初期化しているので `↑` は素の履歴移動のまま。

| キー / コマンド | 動作 |
| --- | --- |
| `Ctrl+R` | 検索 TUI を開く |
| `Ctrl+R`（TUI 内） | フィルタ切替: global → host → session → **directory** |
| `Ctrl+S`（TUI 内） | 検索モード切替: fuzzy / prefix / full-text |
| `Alt+1`…`Alt+9` | 番号で直接選択 |
| `Ctrl+O`（TUI 内） | インスペクタ（実行回数・時刻） |
| `atuin search --cwd . -i` | このディレクトリの履歴だけ（`-e 0` で成功したものだけ） |
| `atuin stats` | よく使うコマンドの統計 |

fuzzy 構文は fzf 風: `'exact` `^prefix` `suffix$` `!not`、スペース = AND、`|` = OR。

> 初回だけ既存の zsh 履歴を取り込む: `atuin import auto`

## この早見表自体を引く

| キー / コマンド | 動作 |
| --- | --- |
| `Ctrl+X` `?` | 節を fzf で選んで表示（入力途中の行は退避され、抜けると戻る） |
| `cheat` | 同上 |
| `cheat <キーワード>` | 該当行を節名つきで抽出（`cheat worktree` / `cheat Ctrl+T`） |
| `cheat -a` | 全文をページャで |

実体はこのファイル。書き換えたら即反映される（`cheat` が毎回読みに行くため）。

## fzf — 入口はこの3つ

| キー / コマンド | 動作 |
| --- | --- |
| `Ctrl+G` | ghq リポジトリを選んで `cd`（入力中の文字列が初期クエリ） |
| `fkill` | プロセスを選んで kill（`Tab` で複数選択） |
| `wtf` | git worktree を選んで移動 |

絞り込み構文は atuin の fuzzy と共通。

## zsh — 関数・コマンド

| コマンド | 動作 |
| --- | --- |
| `z <部分文字列>` | よく行くディレクトリへジャンプ（zoxide。旧 z プラグイン） |
| `zi` | 履歴から対話的に選んでジャンプ |
| `z -` | 直前のディレクトリへ |
| `zoxide query -l foo` / `zoxide remove <path>` | 移動せず候補一覧 / 学習データから削除 |
| `bd <名前>` | 親ディレクトリを名前で遡る（`bd -s` 前方一致 / `bd -i` 大小無視） |
| `wt` | git worktree 操作のまとめ（`wt list` / `wt add` / `wt remove`） |
| `wtg <名前>` / `wtf` / `wtr` | worktree へ移動 / fzf で選んで移動 / リポジトリのルートへ |
| `kpp <ポート>` | そのポートを掴んでいるプロセスを kill |
| `fkill` | fzf でプロセスを選んで kill（名前が曖昧なとき） |
| `tmux_pane_title <文字列>` | tmux のペインタイトルを設定（`tpt`） |
| `cheat` | この早見表を引く（`Ctrl+X` `?`） |

## シェル alias

| alias | 実体 |
| --- | --- |
| `ls` / `ll` / `la` / `lt` | `eza`（アイコン + git 状態。`lt` はツリー表示） |
| `vi` / `v` | `nvim` |
| `lg` | `lazygit` |
| `g` / `gi` | `git` |
| `gs` / `gst` | `git status -s -b` |
| `gc` / `gci` / `gd` | `git commit` / `git commit -a` / `git diff` |
| `d` / `dc` | `docker` / `docker compose` |
| `k` / `kg` / `kd` / `kcx` | `kubectl` / `get` / `describe` / `kubectx` |
| `tf` / `gcl` / `cl` | `terraform` / `gcloud` / `claude` |
| `tm` / `tma` / `tml` | `tmux` / `tmux attach` / `tmux list-sessions` |
| `du` / `df` / `duh` | `du -h` / `df -h` / `du -h -d 1 ./` |
| `ij` | IntelliJ IDEA を開く |

eza に素で足すなら: `-T -L 3`（深いツリー）`--sort=modified` `--git-ignore` `-d`（dir 自体）。

---

## git — delta + モダンデフォルト

- pager 内 `n` / `N` で次 / 前のファイルへジャンプ
- side-by-side が欲しい時だけ: `DELTA_FEATURES=+side-by-side git diff`

もう入っている設定:

| 設定 | 効果 |
| --- | --- |
| `push.autoSetupRemote` | 初回 push の `-u` 不要 |
| `rerere.enabled` | 解決済みコンフリクトを自動再適用 |
| `merge.conflictstyle=zdiff3` | コンフリクトに共通祖先も表示 |
| `branch.sort=-committerdate` | `git branch` が最近順 |
| `commit.verbose` | コミット編集画面に diff |
| `diff.algorithm=histogram` / `diff.colorMoved` | 見やすい差分 / 移動行を色分け |
| `fetch.prune` | 消えたリモートブランチを自動整理 |
| `help.autocorrect` | typo 時に確認して実行 |

### git alias（よく使うもの）

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
| `g r1`…`g r5` / `g rsh1`… / `g rhh1`… | `reset HEAD~`… / `--soft` / `--hard` |
| `g d1`…`g d5` | `diff HEAD~`… |
| `g lg` / `g ll` / `g la` | グラフ表示 / 1行ログ / ざっくりログ |
| `g dmb` | マージ済みブランチを一括削除 |
| `g wta` / `g wtl` / `g wtr` | worktree の追加 / 一覧 / 削除 |

## lazygit（`lg` / herdr `prefix g` / nvim `Space gg`）

| キー | 動作 |
| --- | --- |
| `Space` | ステージ切替 / ブランチ checkout / stash apply（パネル依存） |
| `a` / `c` / `A` | 全ステージ / コミット / amend |
| `P` / `p` | push / pull |
| `n` | 新規ブランチ |
| `i`（Commits） | 対話的 rebase（`s` squash `f` fixup `r` reword `d` drop、`Ctrl+J/K` 並べ替え） |
| `C` → `V` | cherry-pick（コピー → 貼り付け） |
| `z` / `Z` | **undo / redo**（reflog ベース） |
| `/` / `[` `]` | フィルタ / タブ移動 |
| `:` | 任意の git コマンド |

## hunk — レビュー用 diff TUI

| コマンド | 動作 |
| --- | --- |
| `hunk diff` | 作業ツリーの変更（`--staged` でステージ済み） |
| `hunk diff main` | ブランチ比較（`-- path` で絞り込み） |
| `hunk diff --watch` | **自動リロード（エージェント作業の横目監視）** |
| `hunk show [ref]` | コミットをレビュー |

TUI 内: `,`/`.` ファイル移動、`[`/`]` ハンク移動、`/` ファイルフィルタ、
`1`/`2`/`0` レイアウト、`z` コンテキスト行トグル、`e` エディタで開く、
`c` レビューノート、`q` 終了。

## ghq — リポジトリ管理（root: `~/src`）

| コマンド | 動作 |
| --- | --- |
| `ghq get <owner/repo>` | clone（`-p` で SSH、`-u` で既存を pull） |
| `ghq list --full-path` | 一覧 |
| `Ctrl+G` | fzf で選んで `cd` |

## mise — ランタイム + タスク

| コマンド | 動作 |
| --- | --- |
| `mise use node@22` | プロジェクトに固定（`.mise.toml`、`cd` で自動切替） |
| `mise use -g <tool>@<ver>` | グローバル変更 |
| `mise install` | 定義済みを一括導入 |
| `mise x node@20 -- node app.js` | 切替なしで一発実行 |
| `mise run update` / `doctor` / `clean` | 定義済みタスク |

---

## Neovim（LazyVim）

ノーマルモードは `;` ⇔ `:` 入れ替え済み。相対行番号は無効。リーダーは `Space`。

| キー | 動作 |
| --- | --- |
| `Space Space` | ファイル検索 |
| `Space /` | live grep |
| `Space ,` | バッファ切替 |
| `Space e` | エクスプローラ |
| `gd` / `gr` / `K` | 定義 / 参照 / ドキュメント |
| `Space ca` / `cr` / `cf` | コードアクション / リネーム / フォーマット |
| `]d` / `[d` | 次 / 前の diagnostic |
| `H` / `L` | 前 / 次のバッファ |
| `Space gg` | lazygit |
| `Space sk` | キーマップ検索（忘れたらこれ） |

プラグインの追加は `nvim/lua/plugins/` にファイルを足す。`:Lazy` で管理画面。

## tmux（SSH 先用に維持）

普段は cmux / herdr を使うが、SSH 先などのために `.tmux.conf` は残してある。
プレフィックスは `Ctrl+T` のまま（ローカルの herdr と同じ手癖。SSH 先には herdr が
いないので tmux が受ける。ローカルでは herdr が握るため tmux まで届かない）。
プラグインは tpm 管理（`tmux-sensible` / `tmux-yank`）で、初回起動時に自動 clone される。

| キー | 動作 |
| --- | --- |
| `Ctrl+T` `\|` / `-` | 横 / 縦に分割 |
| `Ctrl+T` `h` `j` `k` `l` | ペイン移動 |
| `Ctrl+T` `H` `J` `K` `L` | ペインをリサイズ |
| `Ctrl+T` `[` | コピーモード（`v` 選択 → `y` でクリップボードへ） |
| `Ctrl+T` `r` | 設定を再読み込み |
| `Ctrl+T` `T` | ペインタイトルを設定 |
| `Ctrl+T` `I` | tpm でプラグインを導入 |

## 小物クイックリファレンス

- **btop**: `f` フィルタ、`e` ツリー、`t`/`k` terminate/kill、`q` 終了
- **dust**: `dust -d 2`（深さ）、`-X .git`（除外）
- **duf**: `duf -only local`
- **tldr**: `tldr tar`、`tldr -u`（キャッシュ更新）
- **bat**: `bat -p`（パイプ向けプレーン）、`-A`（不可視文字）
- **fd**: `fd -e ts`（拡張子）、`-H`（隠し込み）、`-x cmd {}`（一括実行）
- **rg**: `-t go`（言語）、`-g '*.zsh'`（glob）、`-l`（ファイル名のみ）、`-C 3`（前後行）、`-F`（固定文字列）

---

## 追記メモ

（新しく調べたものはここへ。整理できたら上の各節に昇格させる）
