# Claude Code グローバル設定

`~/.claude/` にシンボリックリンクされ、すべてのプロジェクトで適用されるClaude Code設定です。

## ディレクトリ構成

```
~/.claude/
├── CLAUDE.md                 # グローバル指示（全プロジェクトに適用）
├── settings.json             # 設定（permissions, hooks, env）
├── settings.local.json       # 個人設定（gitignore対象）
├── commands/                 # カスタムスラッシュコマンド・hookスクリプト
│   ├── commit.md             # /commit
│   ├── create-pr.md          # /create-pr
│   ├── reviews-fix.md        # /reviews-fix
│   ├── workflow-fix.md       # /workflow-fix
│   ├── cleanup-mcp.md        # /cleanup-mcp
│   ├── notify-completion.sh  # Stop hook（完了通知）
│   └── notify-waiting-input.sh # Notification hook（入力待ち通知）
└── mcp-setup.sh              # MCPサーバー初期セットアップ
```

## セットアップ

dotfiles2リポジトリの `setup.sh` を実行すると、このディレクトリが `~/.claude/` にシンボリックリンクされます。

```bash
cd ~/src/github.com/YuiSakamoto/dotfiles2
./setup.sh
```

## 設定の優先順位（高 → 低）

1. プロジェクトローカル設定 (`.claude/settings.local.json`)
2. プロジェクト設定 (`.claude/settings.json`)
3. グローバル設定 (`~/.claude/settings.json`) ← このファイル

## MCPサーバーの管理

```bash
# サーバー追加（ユーザースコープ）
claude mcp add <name> -s user -- <command>

# サーバー追加（プロジェクトスコープ）
claude mcp add <name> -s project -- <command>

# 一覧確認
claude mcp list

# 初期セットアップスクリプト
~/.claude/mcp-setup.sh
```

## プロジェクト固有の設定

各プロジェクトのルートに以下を配置できます:

```
your-project/
├── .claude/
│   ├── settings.json       # プロジェクト共有設定
│   ├── settings.local.json # 個人設定（.gitignoreに追加）
│   └── commands/            # プロジェクト固有コマンド
└── CLAUDE.md               # プロジェクト固有の指示
```
