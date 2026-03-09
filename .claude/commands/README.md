# Claude Code Commands

カスタムスラッシュコマンドとhookスクリプトを格納するディレクトリです。

## スラッシュコマンド

| コマンド | ファイル | 説明 |
|---------|---------|------|
| `/commit` | `commit.md` | 会話コンテキストを考慮してコミットメッセージを生成・実行 |
| `/create-pr` | `create-pr.md` | PRを作成 |
| `/reviews-fix` | `reviews-fix.md` | PRレビューコメントを分析して修正を実施 |
| `/workflow-fix` | `workflow-fix.md` | GitHub Actionsのエラーを診断して修正 |
| `/cleanup-mcp` | `cleanup-mcp.md` | MCPゾンビプロセスをクリーンアップ |

## Hook スクリプト

| スクリプト | hook | 説明 |
|-----------|------|------|
| `notify-completion.sh` | Stop | タスク完了時に音（Glass.aiff）とデスクトップ通知を表示 |
| `notify-waiting-input.sh` | Notification | ユーザー入力待ち時に通知 |

## 通知サウンドの変更

`notify-completion.sh` 内の `SOUND_FILE` 変数を変更:

```
/System/Library/Sounds/ 配下:
Basso, Blow, Bottle, Frog, Funk, Glass(デフォルト),
Hero(長時間タスク用), Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink
```

## 注意事項

- 通知機能はmacOS専用（`osascript`, `afplay` を使用）
- スラッシュコマンド（`.md`ファイル）はClaudeが読んで実行するMarkdownプロンプト
