# Claude Code グローバル設定

`~/.claude/` にシンボリックリンクされ、すべてのプロジェクトで適用されるClaude Code設定です。設定ファイル本体は dotfiles リポジトリ（このディレクトリ）で管理し、`setup.sh` によって `~/.claude/` 配下へ個別にシンボリックリンクされます（`~/.claude` 自体は丸ごとリンクせず、リポジトリで管理するファイル/ディレクトリだけを個別リンクすることで、`credentials.json` や `sessions/` などのランタイム状態を巻き込まないようにしています）。

## ディレクトリ構成

```
~/.claude/
├── CLAUDE.md                 # グローバル指示（全プロジェクトに適用）
├── settings.json             # 設定（permissions, hooks, env）
├── settings.local.json       # 個人設定（gitignore対象、symlinkしない）
├── agents/                   # カスタムサブエージェント定義
├── skills/                   # カスタムスキル（旧カスタムスラッシュコマンド）
│   ├── commit/SKILL.md
│   ├── create-pr/SKILL.md
│   ├── reviews-fix/SKILL.md
│   ├── workflow-fix/SKILL.md
│   ├── cleanup-mcp/SKILL.md
│   │   └── cleanup-mcp.sh    # cleanup-mcpスキルが呼び出す補助スクリプト
│   ├── dotfiles-doctor/SKILL.md
│   └── humanizer/SKILL.md
├── scripts/                  # hookから呼ばれる補助スクリプト
│   ├── validate-edit.sh        # PostToolUse hook（編集後の構文検証）
│   ├── notify-completion.sh    # Stop hook（完了通知）
│   ├── notify-waiting-input.sh # Notification hook（入力待ち通知）
│   └── dd-otel-headers.sh      # OTelヘッダー生成（個人用）
└── .env.example               # hook用環境変数のテンプレート
```

## スキル一覧

| スキル | 呼び出し方 | 説明 |
|---|---|---|
| `commit` | 「コミットして」等の発話 / `/commit` | 会話コンテキストを考慮してコミットメッセージを生成・実行 |
| `create-pr` | 「PRを作成して」等の発話 / `/create-pr` | 会話コンテキストからドラフトPRを作成 |
| `reviews-fix` | 「レビューコメントに対応して」等の発話 / `/reviews-fix` | PRレビューコメントを分析して修正を実施 |
| `workflow-fix` | 「CIを直して」等の発話 / `/workflow-fix` | GitHub Actionsのエラーを診断して修正 |
| `cleanup-mcp` | 「MCPをクリーンアップして」等の発話 / `/cleanup-mcp` | MCPゾンビプロセスをクリーンアップ |
| `humanizer` | 「AIくささを取って」等の発話 / `/humanizer` | AI文章のリライト（人間が書いたような文体に） |
| `dotfiles-doctor` | 「環境チェックして」等の発話 / `/dotfiles-doctor` | `./setup.sh doctor` を実行し、fail を修正して再検査するまでの検証ループ |

各スキルの詳細な実行手順・検証コマンドは `skills/<name>/SKILL.md` を参照。

## hook スクリプト（`scripts/`）

| スクリプト | hook | 説明 |
|---|---|---|
| `notify-completion.sh` | Stop | タスク完了時に音（Glass.aiff）とデスクトップ通知を表示 |
| `notify-waiting-input.sh` | Notification | ユーザー入力待ち時に通知 |
| `validate-edit.sh` | PostToolUse (Edit\|Write) | 編集ファイルの構文チェック（fish/bash/json/py等）。失敗時は exit 2 でモデルに修正を強制 |
| `dd-otel-headers.sh` | `otelHeadersHelper`（settings.json） | Datadog OTel送信用ヘッダーを生成（個人用） |

外部バイナリの hook（brew tap `delphinus/claude-code-hooks`）:

| コマンド | hook | 説明 |
|---|---|---|
| `claude-code-hooks save` | UserPromptSubmit / Stop / SessionEnd | 会話を Obsidian に保存（全ツール毎の保存はプロセス起動が嵩むため節目のみ） |
| `claude-code-hooks gh-guard` | PreToolUse (Bash) | `gh` がガード対象ホストへ書き込む前に確認を挟む |
| `claude-code-hooks notify` | PermissionRequest / SessionEnd | デスクトップ通知 |

## 環境の検証

```bash
./setup.sh doctor   # = bin/dotfiles-doctor
```

symlink 構成・秘密情報が git 追跡されていないこと・設定ファイルの構文・必須ツールの存在を機械検査する。fail があれば exit 1。

### 通知サウンドの変更

`notify-completion.sh` 内の `SOUND_FILE` 変数を変更:

```
/System/Library/Sounds/ 配下:
Basso, Blow, Bottle, Frog, Funk, Glass(デフォルト),
Hero(長時間タスク用), Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink
```

## セットアップ

dotfiles2リポジトリの `setup.sh` を実行すると、このディレクトリ配下のファイル/ディレクトリが個別に `~/.claude/` にシンボリックリンクされます。

```bash
cd ~/src/github.com/YuiSakamoto/dotfiles2
./setup.sh link
```

## 設定の優先順位（高 → 低）

1. プロジェクトローカル設定 (`.claude/settings.local.json`)
2. プロジェクト設定 (`.claude/settings.json`)
3. グローバル設定 (`~/.claude/settings.json`) ← このファイル

※ dotfiles2 リポジトリ自体で作業するときは、この `settings.json` が 2 と 3 の両方として読まれる（plugins が user / project 両スコープに登録されて見えるのはこのため。実害はない）。

## MCPサーバーの管理

```bash
# サーバー追加（ユーザースコープ）
claude mcp add <name> -s user -- <command>

# サーバー追加（プロジェクトスコープ）
claude mcp add <name> -s project -- <command>

# 一覧確認
claude mcp list
```

現在ローカル定義の MCP サーバーは使っておらず、claude.ai 側のマネージドコネクタ（Google Drive / Gmail / Slack / Notion / Figma / Linear 等）を利用している。

## 注意事項

- 通知機能はmacOS専用（`osascript`, `afplay` を使用）
- `skills/<name>/SKILL.md` はClaudeが読んで実行するMarkdown手順書。frontmatterに `name`（ディレクトリ名と一致）と `description`（呼び出しトリガーを含む説明）を持つ

## プロジェクト固有の設定

各プロジェクトのルートに以下を配置できる:

```
your-project/
├── .claude/
│   ├── settings.json       # プロジェクト共有設定
│   ├── settings.local.json # 個人設定（.gitignoreに追加）
│   └── skills/               # プロジェクト固有スキル
└── CLAUDE.md               # プロジェクト固有の指示
```
