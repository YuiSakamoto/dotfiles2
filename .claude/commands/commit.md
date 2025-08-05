#!/usr/bin/env bash
# Claude Codeカスタムコマンド: /commit
# 会話のコンテキストを考慮してコミットを作成する

# 現在の変更状況を確認
echo "🔍 現在の変更を確認しています..."

# git statusを実行
GIT_STATUS=$(git status --porcelain 2>/dev/null)

if [ -z "$GIT_STATUS" ]; then
    echo "📭 コミットする変更がありません。"
    exit 0
fi

echo "📝 以下の変更が検出されました："
echo "$GIT_STATUS"
echo ""

# ステージングされていない変更がある場合
UNSTAGED_CHANGES=$(git status --porcelain | grep -E '^( M|MM|\?\?)' || true)
if [ -n "$UNSTAGED_CHANGES" ]; then
    echo "⚠️  ステージングされていない変更があります："
    echo "$UNSTAGED_CHANGES"
    echo ""
    echo "これらの変更もコミットに含めますか？ (y/N)"
    read -r INCLUDE_UNSTAGED
    
    if [ "$INCLUDE_UNSTAGED" = "y" ] || [ "$INCLUDE_UNSTAGED" = "Y" ]; then
        echo "📦 すべての変更をステージングしています..."
        git add -A
    fi
fi

# 会話のコンテキストからコミットメッセージを生成
echo ""
echo "🤖 会話のコンテキストを分析してコミットメッセージを生成します..."
echo ""
echo "以下の情報を基にコミットメッセージを作成してください："
echo "1. 今回の会話で行った変更内容"
echo "2. 変更の目的と背景"
echo "3. Conventional Commits形式に従う"
echo ""
echo "生成されたコミットメッセージ："

# ここでClaudeが会話のコンテキストを考慮してメッセージを生成
COMMIT_MESSAGE="feat: Claude Code グローバル設定の最適化

- ~/.claude/settings.json: モダンな開発環境設定を追加
  - フック機能でファイル編集時の自動フォーマット・Lint
  - pnpm優先のパッケージマネージャー制御
  - グローバル権限設定
- ~/.claude/CLAUDE.md: 開発原則とガイドラインを定義
- カスタムコマンドの基盤を構築"

echo "$COMMIT_MESSAGE"
echo ""

# コミットの実行確認
echo "このメッセージでコミットしますか？ (y/N/e[dit])"
read -r CONFIRM

case "$CONFIRM" in
    y|Y)
        git commit -m "$COMMIT_MESSAGE"
        echo "✅ コミットが完了しました！"
        ;;
    e|E)
        # エディタでメッセージを編集
        echo "$COMMIT_MESSAGE" > /tmp/commit_msg.txt
        ${EDITOR:-vim} /tmp/commit_msg.txt
        git commit -F /tmp/commit_msg.txt
        rm /tmp/commit_msg.txt
        echo "✅ コミットが完了しました！"
        ;;
    *)
        echo "❌ コミットをキャンセルしました。"
        exit 1
        ;;
esac