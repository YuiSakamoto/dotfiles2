# Claude Code グローバル設定

このディレクトリには、Claude Codeのグローバル設定ファイルが含まれています。

## ファイル構成

```
~/.claude/
├── settings.json      # グローバル設定
├── CLAUDE.md         # グローバル指示書
├── commands/         # カスタムコマンド
│   ├── commit.md     # /commit コマンド
│   ├── reviews-fix.md # /reviews-fix コマンド
│   └── workflow-fix.md # /workflow-fix コマンド
├── mcp-setup.sh      # MCPサーバーセットアップスクリプト
├── .env.example      # 環境変数の例
└── README.md         # このファイル
```

## 初期設定

1. **API キーの設定**
   ```bash
   cp ~/.claude/.env.example ~/.claude/.env
   # .env ファイルを編集してAPIキーを設定
   ```

2. **環境変数の読み込み**
   ```bash
   source ~/.claude/.env
   ```

3. **MCPサーバーのセットアップ**
   ```bash
   ~/.claude/mcp-setup.sh
   ```

## カスタムコマンド

- `/commit` - 会話のコンテキストを考慮して適切なコミットメッセージを生成
- `/reviews-fix` - PRレビューコメントを分析して修正を実施
- `/workflow-fix` - GitHub Actionsのエラーを診断して修正

## MCP (Model Context Protocol)

MCPサーバーは新しいコマンドで管理されます：

```bash
# ユーザースコープでサーバーを追加
claude mcp add <name> -s user <command>

# プロジェクトスコープでサーバーを追加
claude mcp add <name> -s project <command>

# サーバー一覧を確認
claude mcp list

# サーバーを削除
claude mcp remove <name>
```

## 設定のカスタマイズ

### プロジェクト固有の設定

各プロジェクトのルートに `.claude/` ディレクトリを作成して、プロジェクト固有の設定を追加できます：

```bash
your-project/
└── .claude/
    ├── settings.json    # プロジェクト設定（チームで共有）
    ├── settings.local.json # 個人設定（gitignoreに追加）
    ├── CLAUDE.md       # プロジェクト固有の指示
    └── .mcp.json       # プロジェクト固有のMCPサーバー
```

### 設定の優先順位

1. エンタープライズ管理設定（最優先）
2. プロジェクトローカル設定 (`.claude/settings.local.json`)
3. プロジェクト設定 (`.claude/settings.json`)
4. グローバル設定 (`~/.claude/settings.json`)

## トラブルシューティング

- `claude config list` - 現在の設定を確認
- `claude config get <key>` - 特定の設定値を確認
- `claude config set <key> <value>` - 設定を変更

## 更新履歴

- 2025-08-05: 初期設定作成
  - モダンな開発環境に対応した設定
  - カスタムコマンド追加
  - 自動フォーマット・Lint機能
  - MCP設定を別ファイルに分離（新仕様対応）