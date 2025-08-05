#!/bin/bash
# Claude Code MCP サーバーセットアップスクリプト

echo "🚀 Claude Code MCP サーバーをセットアップします"
echo ""

# ユーザースコープでMCPサーバーを追加
echo "📦 基本的なMCPサーバーを追加しています..."

# ファイルシステムサーバー
echo "1. ファイルシステムサーバー"
claude mcp add filesystem -s user \
  npx -y @modelcontextprotocol/server-filesystem \
  --env ALLOWED_DIRECTORIES="$HOME/src,$HOME/Documents,$HOME/Downloads"

# GitHub統合（GitHub Tokenが設定されている場合のみ）
if [ -n "$GITHUB_TOKEN" ]; then
  echo "2. GitHub統合サーバー"
  claude mcp add github -s user \
    npx -y @modelcontextprotocol/server-github \
    --env GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN"
else
  echo "⚠️  GITHUB_TOKENが設定されていません。GitHub統合をスキップします"
fi

# メモリ管理サーバー
echo "3. メモリ管理サーバー"
claude mcp add memory -s user \
  npx -y @modelcontextprotocol/server-memory

# ブラウザ自動化サーバー（オプション）
echo ""
echo "オプションのサーバー:"
echo "4. ブラウザ自動化 (Puppeteer) を追加しますか? (y/N)"
read -r ADD_PUPPETEER
if [ "$ADD_PUPPETEER" = "y" ] || [ "$ADD_PUPPETEER" = "Y" ]; then
  claude mcp add puppeteer -s user \
    npx -y @modelcontextprotocol/server-puppeteer
fi

# PostgreSQL統合（接続文字列が設定されている場合）
if [ -n "$POSTGRES_CONNECTION_STRING" ]; then
  echo "5. PostgreSQL統合サーバー"
  claude mcp add postgres -s user \
    npx -y @modelcontextprotocol/server-postgres \
    --env POSTGRES_CONNECTION_STRING="$POSTGRES_CONNECTION_STRING"
fi

echo ""
echo "✅ MCPサーバーのセットアップが完了しました！"
echo ""
echo "設定されたサーバーを確認:"
claude mcp list

echo ""
echo "📝 追加のセットアップ:"
echo "- プロジェクト固有のMCPサーバーは 'claude mcp add <name> -s project <command>' で追加"
echo "- .env ファイルに必要な環境変数を設定してください"