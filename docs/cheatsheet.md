# チートシート

この環境(dotfiles2)の実設定に合わせた使い方メモ。**育てるドキュメント**: 調べたことはここに追記していく。upstream のデフォルトではなく、ここのエイリアス・キーバインド前提で書く。

- 各ツール「覚える価値のあるものだけ」最大10個程度に絞る
- 出典を確認してから書く(バージョン依存のキーは要注意)

---

## herdr — ターミナルワークスペース (v0.7.1)

概念: **Session** → **Workspace**(プロジェクト単位) → **Tab** → **Pane** → **Agent**(ペイン内のAIプロセスを自動検出)。エージェント状態(working/blocked/done/idle)はサイドバーに集約される。prefix は tmux と同じ **Ctrl+T**。

### ペイン・タブ(tmux 移植分、体が覚えてる系)

| キー | 動作 |
|---|---|
| `prefix h/j/k/l` | ペイン移動(`shift+` で入れ替え) |
| `prefix \|` / `prefix -` | 縦 / 横分割 |
| `prefix z` | ズーム |
| `prefix c` / `prefix 1..9` / `prefix p/n` | 新規タブ / 直接切替 / 前後 |
| `prefix x` / `prefix ;` | ペインを閉じる / 直前のペインへ |
| `prefix [` | コピーモード(`v` 選択 → `y` コピー、`q` 終了) |
| `prefix r` | リサイズモード |
| `prefix q` | デタッチ(エージェントは走り続ける。`herdr` で再アタッチ) |

### herdr ならでは(ここを使い込む)

| キー | 動作 |
|---|---|
| `prefix o` | **通知元のペインへジャンプ**(blocked になったエージェントに即飛ぶ) |
| `prefix e` | **スクロールバックを $EDITOR(nvim)で開く** — 検索はこれで `/`(copyモードに検索は無い) |
| `prefix f` | セッションナビゲータ(goto) |
| `prefix w` | ワークスペースピッカー(navigate モード中は `ctrl+k/j` で上下) |
| `prefix ↑/↓` | 前後のワークスペースへ直接切替 |
| `prefix ,` / `prefix .` | 前 / 次のエージェントへ |
| `prefix alt+1..9` | エージェント直接フォーカス |
| `prefix shift+g` / `prefix shift+o` / `prefix alt+d` | worktree ワークスペース作成 / 開く / 削除 |
| `prefix g` | lazygit をペインで起動(カスタムコマンド) |
| `prefix b` | サイドバー表示切替 |
| `prefix s` / `prefix ?` | 設定UI / ヘルプ |

### CLI(スクリプト・エージェント連携)

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

- マウス: ドラッグで自動コピー、ダブルクリックでトークン抽出、Ctrl+クリックでURL開く
- ペイン内には `HERDR_ACTIVE_PANE_ID` 等の環境変数が入る(自ペインを対象に API を叩ける)
- 導入済み: claude integration(v7)。状態検出はフック連携(SessionStart 登録なので**セッション再起動後から有効**)、herdr 再起動後は会話を自動レジューム。更新は `herdr integration status --outdated-only` で確認、`install claude` で上書き

---

## atuin — 履歴検索 (Ctrl+R)

`--disable-up-arrow` 初期化なので↑キーは素のまま。`enter_accept = true`(Enter で即実行)。

| キー / コマンド | 動作 |
|---|---|
| `Ctrl+R` | 検索TUI |
| `Tab` | 実行せずコマンドラインに挿入(編集したい時) |
| `Ctrl+R`(TUI内) | フィルタ切替: global → host → session → **directory** |
| `Ctrl+S`(TUI内) | 検索モード切替: fuzzy / prefix / full-text |
| `Alt+1..9` | 番号で直接選択 |
| `Ctrl+O` | インスペクタ(実行回数・時刻) |
| `Ctrl+A` → `d` | エントリ削除(`D` で同一コマンド全削除) |
| `atuin search --cwd . -i` | このディレクトリの履歴だけ(`-e 0` で成功したものだけ) |
| `atuin stats` | よく使うコマンド統計 |

fuzzy 構文は fzf 風: `'exact` `^prefix` `suffix$` `!not`

## fzf — 入口はこの3つ

| キー / コマンド | 動作 |
|---|---|
| `Ctrl+G` | ghq リポジトリを選んで cd(入力中の文字列が初期クエリ) |
| `fkill` | プロセスを選んで kill(`Tab` で複数選択) |
| `wtf` | git worktree を選んで移動 |

絞り込み構文(atuin fuzzy と共通): `'word`(完全一致) `^src`(先頭) `.fish$`(末尾) `!test`(除外)、スペース=AND、`|`=OR

## zoxide — 賢い cd

| コマンド | 動作 |
|---|---|
| `z foo` | 学習済みディレクトリへジャンプ |
| `z foo bar` | 複数キーワードで絞り込み |
| `z -` | 直前のディレクトリへ |
| `zi foo` | fzf で候補を選ぶ |
| `zoxide query -l foo` | 移動せず候補一覧 |
| `zoxide remove <path>` | 学習データから削除 |

## eza — ls (alias 済み)

| エイリアス | 実体 |
|---|---|
| `ls` | `eza --icons` |
| `ll` | `eza -l --icons --git` |
| `la` | `eza -la --icons --git` |
| `lt` | `eza --tree --icons --level=2` |

素で足すなら: `-T -L 3`(深いツリー) `--sort=modified` `--git-ignore` `-d`(dir自体)。※ `cl` は claude のエイリアスであって eza ではない

## lazygit (`lg`, `prefix+g`, nvim の `Space gg`)

| キー | 動作 |
|---|---|
| `Space` | ステージ切替 / ブランチcheckout / stash apply(パネル依存) |
| `a` / `c` / `A` | 全ステージ / コミット / amend |
| `P` / `p` | push / pull |
| `n` | 新規ブランチ |
| `i`(Commits) | 対話的 rebase(`s` squash `f` fixup `r` reword `d` drop、`Ctrl+J/K` 並べ替え) |
| `C` → `V` | cherry-pick(コピー → 貼り付け) |
| `z` / `Z` | **undo / redo**(reflogベース) |
| `/` / `[` `]` | フィルタ / タブ移動 |
| `:` | 任意 git コマンド |

## git — delta + モダンデフォルト

- pager 内 `n` / `N` で次/前のファイルへジャンプ
- side-by-side が欲しい時だけ: `DELTA_FEATURES=+side-by-side git diff`

覚えておく設定(もう入ってる):

| 設定 | 効果 |
|---|---|
| `push.autoSetupRemote` | 初回 push の `-u` 不要 |
| `rerere` | 解決済みコンフリクトを自動再適用 |
| `zdiff3` | コンフリクトに共通祖先も表示 |
| `branch.sort=-committerdate` | branch が最近順 |
| `commit.verbose` | コミット編集画面に diff |
| `help.autocorrect=prompt` | typo 時に確認して実行 |

### git エイリアス厳選(`g aa` で全一覧)

| エイリアス | 用途 |
|---|---|
| `g s` / `g ss` | status / short |
| `g up` | pull --rebase |
| `g po` | push origin |
| `g please` | 安全な force push(--force-with-lease) |
| `g rbm` / `g rbc` / `g rba` | master へ rebase / continue / abort |
| `g rbi2` | rebase -i HEAD^^(1〜5あり) |
| `g cam` | commit -a --amend |
| `g cb` | checkout -b |
| `g dmb` | マージ済みブランチ一括削除 |
| `g lg` | log --graph --oneline |
| `g rhh` | reset --hard HEAD(1〜5、soft は rsh) |
| `g wta/wtl/wtr` | worktree 追加/一覧/削除 |

## hunk — レビュー用 diff TUI (v0.16)

| コマンド | 動作 |
|---|---|
| `hunk diff` | 作業ツリーの変更(`--staged` でステージ済み) |
| `hunk diff main` | ブランチ比較(`-- path` で絞り込み) |
| `hunk diff --watch` | **自動リロード(エージェント作業の横目監視)** |
| `hunk show [ref]` | コミットをレビュー |

TUI内: `,`/`.` ファイル移動、`[`/`]` ハンク移動、`/` ファイルフィルタ、`1`/`2`/`0` レイアウト、`z` コンテキスト行トグル、`e` エディタで開く、`c` レビューノート、`q` 終了

## ghq — リポジトリ管理 (root: `~/src`)

| コマンド | 動作 |
|---|---|
| `ghq get <owner/repo>` | clone(`-p` で SSH、`-u` で既存を pull) |
| `ghq list` | 一覧(`--full-path`) |
| `Ctrl+G` | fzf で選んで cd |

## mise — ランタイム + タスク

| コマンド | 動作 |
|---|---|
| `mise use node@22` | プロジェクトに固定(.mise.toml、cd で自動切替) |
| `mise use -g <tool>@<ver>` | グローバル変更 |
| `mise install` | 定義済みを一括導入 |
| `mise x node@20 -- node app.js` | 切替なしで一発実行 |
| `mise run update` / `doctor` / `clean` | 定義済みタスク |

## LazyVim — 最重要キー

ノーマルモードは `;` ⇔ `:` 入れ替え済み。

| キー | 動作 |
|---|---|
| `Space Space` | ファイル検索 |
| `Space /` | live grep |
| `Space ,` | バッファ切替 |
| `Space e` | エクスプローラ |
| `gd` / `gr` / `K` | 定義 / 参照 / ドキュメント |
| `Space ca` / `cr` / `cf` | コードアクション / リネーム / フォーマット |
| `]d` / `[d` | 次 / 前の diagnostic |
| `H` / `L` | 前 / 次のバッファ |
| `Space gg` | lazygit |
| `Space sk` | キーマップ検索(忘れたらこれ) |

## 小物クイックリファレンス

- **btop**: `f` フィルタ、`e` ツリー、`t`/`k` terminate/kill、`q` 終了
- **dust**: `dust -d 2`(深さ)、`-X .git`(除外)
- **duf**: `duf -only local`
- **tldr**: `tldr tar`、`tldr -u`(キャッシュ更新)
- **bat**: `bat -p`(パイプ向けプレーン)、`-A`(不可視文字)
- **fd**: `fd -e fish`(拡張子)、`-H`(隠し込み)、`-x cmd {}`(一括実行)
- **rg**: `-t go`(言語)、`-g '*.fish'`(glob)、`-l`(ファイル名のみ)、`-C 3`(前後行)、`-F`(固定文字列)

---

## 追記メモ

(新しく調べたものはここへ。整理できたら上の各セクションに昇格させる)
