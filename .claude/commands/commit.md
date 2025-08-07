#!/usr/bin/env bash
# Claude Codeカスタムコマンド: /commit
# 会話のコンテキストを考慮してコミットを作成する

# 現在のブランチを確認
CURRENT_BRANCH=$(git branch --show-current)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

echo "🔍 現在のブランチ: $CURRENT_BRANCH"

# mainブランチにいる場合は警告
if [ "$CURRENT_BRANCH" = "$DEFAULT_BRANCH" ] || [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    echo "⚠️  メインブランチ ($CURRENT_BRANCH) で作業しています！"
    echo ""
    
    # 変更内容から適切なブランチ名を提案
    echo "📝 変更内容を確認してブランチ名を提案します..."
    
    # 簡易的な変更ファイルのリストから推測
    CHANGED_FILES=$(git status --porcelain | awk '{print $2}' | head -3)
    
    # 日付ベースのデフォルトブランチ名
    DATE_PREFIX=$(date +%Y%m%d)
    
    # 変更内容に基づく提案（実際はClaudeが会話コンテキストから生成）
    if echo "$CHANGED_FILES" | grep -q "claude"; then
        SUGGESTED_BRANCH="feat/${DATE_PREFIX}-claude-commands"
    elif echo "$CHANGED_FILES" | grep -q "fish"; then
        SUGGESTED_BRANCH="feat/${DATE_PREFIX}-fish-config"
    elif echo "$CHANGED_FILES" | grep -q "nvim"; then
        SUGGESTED_BRANCH="feat/${DATE_PREFIX}-nvim-config"
    else
        SUGGESTED_BRANCH="feat/${DATE_PREFIX}-update"
    fi
    
    echo "💡 推奨ブランチ名: $SUGGESTED_BRANCH"
    echo ""
    echo "新しいブランチを作成して移動しますか？"
    echo "1) はい、推奨ブランチ名を使用 ($SUGGESTED_BRANCH)"
    echo "2) はい、カスタムブランチ名を入力"
    echo "3) いいえ、このままメインブランチで続行"
    echo "4) キャンセル"
    echo ""
    echo "選択してください (1-4): "
    read -r BRANCH_CHOICE
    
    case "$BRANCH_CHOICE" in
        1)
            git checkout -b "$SUGGESTED_BRANCH"
            echo "✅ ブランチ '$SUGGESTED_BRANCH' を作成して切り替えました。"
            echo ""
            ;;
        2)
            echo "ブランチ名を入力してください (例: feat/add-feature, fix/bug-123)："
            read -r CUSTOM_BRANCH
            git checkout -b "$CUSTOM_BRANCH"
            echo "✅ ブランチ '$CUSTOM_BRANCH' を作成して切り替えました。"
            echo ""
            ;;
        3)
            echo "⚠️  注意: メインブランチで作業を続行します。"
            echo ""
            ;;
        4)
            echo "❌ コミットをキャンセルしました。"
            exit 1
            ;;
        *)
            echo "❌ 無効な選択です。コミットをキャンセルしました。"
            exit 1
            ;;
    esac
fi

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