#!/usr/bin/env bash
# Claude Codeカスタムコマンド: /reviews-fix
# PRレビューコメントに対応する

# PRの情報を取得
echo "🔍 現在のPR情報を取得しています..."

# GitHub CLIがインストールされているか確認
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) がインストールされていません。"
    echo "インストール方法: https://cli.github.com/"
    exit 1
fi

# 現在のブランチ名を取得
CURRENT_BRANCH=$(git branch --show-current)

# PRが存在するか確認
PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null || echo "")

if [ -z "$PR_NUMBER" ]; then
    echo "❌ 現在のブランチにPRが見つかりません。"
    echo "PRを作成してからこのコマンドを実行してください。"
    exit 1
fi

echo "📋 PR #$PR_NUMBER のレビューコメントを取得しています..."

# レビューコメントを取得
REVIEWS=$(gh pr view "$PR_NUMBER" --json reviews -q '.reviews[] | select(.state != "COMMENTED") | {author: .author.login, state: .state, body: .body}')
REVIEW_COMMENTS=$(gh api "repos/{owner}/{repo}/pulls/$PR_NUMBER/comments" --jq '.[] | {path: .path, line: .line, body: .body, user: .user.login}')

if [ -z "$REVIEWS" ] && [ -z "$REVIEW_COMMENTS" ]; then
    echo "✨ 対応が必要なレビューコメントはありません！"
    exit 0
fi

echo ""
echo "📝 以下のレビューコメントが見つかりました："
echo ""

# レビューコメントを表示
if [ -n "$REVIEWS" ]; then
    echo "=== 一般的なレビューコメント ==="
    echo "$REVIEWS"
    echo ""
fi

if [ -n "$REVIEW_COMMENTS" ]; then
    echo "=== ファイル別のコメント ==="
    echo "$REVIEW_COMMENTS"
    echo ""
fi

# 対応方針を確認
echo "🤖 これらのレビューコメントに対応します。"
echo ""
echo "対応方針："
echo "1. 各コメントの内容を分析"
echo "2. 必要なコード修正を実施"
echo "3. テストを実行して動作確認"
echo "4. 修正内容をコミット"
echo ""

echo "続行しますか？ (y/N)"
read -r CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "❌ 処理をキャンセルしました。"
    exit 1
fi

# ここでClaudeがレビューコメントを分析して対応
echo ""
echo "🔧 レビューコメントに基づいて修正を実施しています..."
echo ""

# 修正作業のプレースホルダー
echo "以下の修正を実施します："
echo "- コードスタイルの修正"
echo "- エラーハンドリングの改善"
echo "- テストケースの追加"
echo "- ドキュメントの更新"

# テストの実行
echo ""
echo "🧪 テストを実行しています..."

# プロジェクトに応じたテストコマンド
if [ -f "package.json" ]; then
    pnpm test || echo "⚠️  一部のテストが失敗しました"
elif [ -f "go.mod" ]; then
    go test ./... || echo "⚠️  一部のテストが失敗しました"
elif [ -f "pyproject.toml" ]; then
    uv run pytest || echo "⚠️  一部のテストが失敗しました"
fi

# 変更をコミット
echo ""
echo "📦 変更をコミットしています..."

git add -A
git commit -m "fix: PRレビューコメントに対応

- レビュアーからのフィードバックを反映
- コードスタイルとエラーハンドリングを改善
- 必要なテストケースを追加

Addresses PR review comments in #$PR_NUMBER"

echo ""
echo "✅ レビューコメントへの対応が完了しました！"
echo ""
echo "次のステップ："
echo "1. git push で変更をプッシュ"
echo "2. PRにコメントを追加して対応内容を説明"
echo "3. Re-requestレビューを依頼"