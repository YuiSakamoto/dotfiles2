#!/bin/bash

# MCPゾンビプロセスをクリーンアップするスクリプト
# 使用方法: /cleanup-mcp

echo "🔍 MCPプロセスを検索中..."

# 対象のMCPプロセスパターン
MCP_PATTERNS=(
    "mcp-server-playwright"
    "figma-developer-mcp"
    "mcp-server-slack"
    "notion-mcp-server"
    "mcp-server-github"
    "@anthropic/mcp"
    "container-use"
    "context7"
)

KILLED_COUNT=0

for pattern in "${MCP_PATTERNS[@]}"; do
    # プロセス数をカウント
    COUNT=$(pgrep -f "$pattern" 2>/dev/null | wc -l | tr -d ' ')

    if [ "$COUNT" -gt 0 ]; then
        echo "  - $pattern: $COUNT プロセス発見"
        pkill -f "$pattern" 2>/dev/null && KILLED_COUNT=$((KILLED_COUNT + COUNT))
    fi
done

if [ "$KILLED_COUNT" -gt 0 ]; then
    echo ""
    echo "✅ $KILLED_COUNT 個のMCPプロセスをクリーンアップしました"
else
    echo "✅ クリーンアップが必要なMCPプロセスはありませんでした"
fi

# 現在実行中のMCPプロセスを表示
echo ""
echo "📊 現在のMCPプロセス状況:"
ps aux | grep -E "(mcp|playwright|figma|notion|slack)" | grep -v grep | awk '{print "  " $11}' | sort | uniq -c || echo "  なし"

exit 0
