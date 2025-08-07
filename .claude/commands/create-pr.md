#!/usr/bin/env bash
# Claude Codeカスタムコマンド: /create-pr
# 会話のコンテキストを考慮してプルリクエストを作成する（ドラフトPR）

# 現在のブランチを確認
CURRENT_BRANCH=$(git branch --show-current)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

echo "🔍 現在のブランチ: $CURRENT_BRANCH"
echo "📌 デフォルトブランチ: $DEFAULT_BRANCH"
echo ""

# デフォルトブランチにいる場合は警告
if [ "$CURRENT_BRANCH" = "$DEFAULT_BRANCH" ]; then
    echo "⚠️  デフォルトブランチ ($DEFAULT_BRANCH) から直接PRを作成しようとしています。"
    echo "新しいブランチを作成しますか？ (y/N)"
    read -r CREATE_BRANCH
    
    if [ "$CREATE_BRANCH" = "y" ] || [ "$CREATE_BRANCH" = "Y" ]; then
        echo "ブランチ名を入力してください："
        read -r NEW_BRANCH
        git checkout -b "$NEW_BRANCH"
        CURRENT_BRANCH="$NEW_BRANCH"
    else
        echo "❌ PR作成をキャンセルしました。"
        exit 1
    fi
fi

# 未コミットの変更を確認
GIT_STATUS=$(git status --porcelain 2>/dev/null)
if [ -n "$GIT_STATUS" ]; then
    echo "⚠️  未コミットの変更があります："
    echo "$GIT_STATUS"
    echo ""
    echo "これらの変更をコミットしてからPRを作成しますか？ (y/N)"
    read -r COMMIT_FIRST
    
    if [ "$COMMIT_FIRST" = "y" ] || [ "$COMMIT_FIRST" = "Y" ]; then
        echo "コミットメッセージを入力してください："
        read -r COMMIT_MSG
        git add -A
        git commit -m "$COMMIT_MSG"
    fi
fi

# リモートにプッシュ
echo ""
echo "📤 ブランチをリモートにプッシュしています..."
git push -u origin "$CURRENT_BRANCH"

# 最近のコミットを取得して表示
echo ""
echo "📝 最近のコミット："
git log --oneline -5 "$DEFAULT_BRANCH".."$CURRENT_BRANCH"

# 会話のコンテキストからPRの内容を生成
echo ""
echo "🤖 会話のコンテキストを分析してPRの内容を生成します..."
echo ""

# PRタイトルとボディの生成（Claudeが会話のコンテキストから生成）
PR_TITLE="feat: 実装した機能の簡潔な説明"
PR_BODY="## 概要
この変更で実装した内容の概要

## 変更内容
- 具体的な変更点1
- 具体的な変更点2
- 具体的な変更点3

## テスト方法
1. テスト手順1
2. テスト手順2

## チェックリスト
- [ ] コードレビューの準備ができている
- [ ] テストを実行して動作を確認した
- [ ] ドキュメントを更新した（必要に応じて）

## 関連Issue
- #issue番号（該当する場合）

## スクリーンショット
（UI変更がある場合）
"

echo "タイトル: $PR_TITLE"
echo ""
echo "本文:"
echo "$PR_BODY"
echo ""

# PR作成の確認
echo "このタイトルと本文でドラフトPRを作成しますか？ (y/N/e[dit])"
read -r CONFIRM

case "$CONFIRM" in
    y|Y)
        # GitHub CLIでドラフトPRを作成
        if command -v gh &> /dev/null; then
            gh pr create --draft --title "$PR_TITLE" --body "$PR_BODY" --base "$DEFAULT_BRANCH"
            echo "✅ ドラフトPRが作成されました！"
        else
            echo "❌ GitHub CLI (gh) がインストールされていません。"
            echo "以下のコマンドでインストールしてください："
            echo "  brew install gh"
            exit 1
        fi
        ;;
    e|E)
        # エディタで内容を編集
        echo "$PR_TITLE" > /tmp/pr_title.txt
        echo "$PR_BODY" > /tmp/pr_body.txt
        ${EDITOR:-vim} /tmp/pr_title.txt
        ${EDITOR:-vim} /tmp/pr_body.txt
        PR_TITLE=$(cat /tmp/pr_title.txt)
        PR_BODY=$(cat /tmp/pr_body.txt)
        
        if command -v gh &> /dev/null; then
            gh pr create --draft --title "$PR_TITLE" --body "$PR_BODY" --base "$DEFAULT_BRANCH"
            echo "✅ ドラフトPRが作成されました！"
        else
            echo "❌ GitHub CLI (gh) がインストールされていません。"
            exit 1
        fi
        
        rm /tmp/pr_title.txt /tmp/pr_body.txt
        ;;
    *)
        echo "❌ PR作成をキャンセルしました。"
        exit 1
        ;;
esac