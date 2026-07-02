---
name: cleanup-mcp
description: MCPサーバーのゾンビプロセスをクリーンアップする。ユーザーが「MCPプロセスをクリーンアップして」「MCPが重い/残ってる」と言ったとき、または /cleanup-mcp 実行時に使う。
---

# cleanup-mcp: MCPゾンビプロセスのクリーンアップ

このスキルに同梱されている `cleanup-mcp.sh` を実行する。

```bash
$HOME/.claude/skills/cleanup-mcp/cleanup-mcp.sh
```

スクリプトの内容:

- 以下のプロセスパターンに一致する常駐プロセスを `pgrep -f` で検出する
  - `mcp-server-playwright`, `figma-developer-mcp`, `mcp-server-slack`, `notion-mcp-server`, `mcp-server-github`, `@anthropic/mcp`, `container-use`, `context7`
- 検出したプロセスを `pkill -f` で終了する
- 終了後、現在起動中のMCP関連プロセス一覧を表示する

## 検証

```bash
ps aux | grep -E "(mcp|playwright|figma|notion|slack)" | grep -v grep
```

- 上記コマンドの出力が想定通り（不要なプロセスが残っていない、または起動していてほしいプロセスのみ残っている）であることを確認する
- 新たに検出対象のプロセスが増えた場合は `cleanup-mcp.sh` 内の `MCP_PATTERNS` 配列にパターンを追加する
