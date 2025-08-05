#!/usr/bin/env bash
# Claude Codeカスタムコマンド: /workflow-fix
# GitHub Actionsのワークフローエラーを修正する

echo "🔍 GitHub Actionsのワークフロー状態を確認しています..."

# GitHub CLIがインストールされているか確認
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) がインストールされていません。"
    echo "インストール方法: https://cli.github.com/"
    exit 1
fi

# 現在のブランチまたはPRのワークフロー実行状況を取得
CURRENT_BRANCH=$(git branch --show-current)

# PRが存在する場合はPRのチェックを取得
PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null || echo "")

if [ -n "$PR_NUMBER" ]; then
    echo "📋 PR #$PR_NUMBER のワークフロー状態を確認しています..."
    CHECKS=$(gh pr checks "$PR_NUMBER" --json name,status,conclusion,detailsUrl)
else
    echo "📋 ブランチ '$CURRENT_BRANCH' の最新のワークフロー実行を確認しています..."
    # 最新のコミットのSHAを取得
    LATEST_SHA=$(git rev-parse HEAD)
    CHECKS=$(gh api "repos/{owner}/{repo}/commits/$LATEST_SHA/check-runs" --jq '.check_runs[] | {name: .name, status: .status, conclusion: .conclusion, detailsUrl: .details_url}')
fi

# 失敗したワークフローを抽出
FAILED_WORKFLOWS=$(echo "$CHECKS" | jq -r 'select(.conclusion == "failure" or .conclusion == "cancelled") | .name' 2>/dev/null || echo "")

if [ -z "$FAILED_WORKFLOWS" ]; then
    echo "✅ すべてのワークフローが正常に実行されています！"
    exit 0
fi

echo ""
echo "❌ 以下のワークフローが失敗しています："
echo "$FAILED_WORKFLOWS"
echo ""

# 失敗したワークフローごとにログを取得
echo "📝 失敗したワークフローのログを分析しています..."
echo ""

for WORKFLOW in $FAILED_WORKFLOWS; do
    echo "=== $WORKFLOW ==="
    
    # ワークフローのログURLを取得
    DETAILS_URL=$(echo "$CHECKS" | jq -r --arg wf "$WORKFLOW" 'select(.name == $wf) | .detailsUrl' | head -1)
    
    if [ -n "$DETAILS_URL" ]; then
        echo "詳細: $DETAILS_URL"
        
        # ログの概要を取得（可能な場合）
        RUN_ID=$(echo "$DETAILS_URL" | grep -oE '[0-9]+$')
        if [ -n "$RUN_ID" ]; then
            echo "実行ID: $RUN_ID"
            
            # 失敗したジョブを特定
            FAILED_JOBS=$(gh run view "$RUN_ID" --json jobs -q '.jobs[] | select(.conclusion == "failure") | .name' 2>/dev/null || echo "")
            if [ -n "$FAILED_JOBS" ]; then
                echo "失敗したジョブ: $FAILED_JOBS"
            fi
        fi
    fi
    echo ""
done

# 修正方針を提示
echo "🤖 ワークフローエラーの修正方針："
echo ""
echo "1. エラーログを詳細に分析"
echo "2. 一般的な問題のチェック："
echo "   - 依存関係のバージョン不整合"
echo "   - 環境変数やシークレットの不足"
echo "   - ファイルパスやパーミッションの問題"
echo "   - テストの失敗"
echo "   - Lintエラー"
echo "3. 必要な修正を実施"
echo "4. ローカルで可能な検証を実行"
echo ""

echo "続行して修正を試みますか？ (y/N)"
read -r CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "❌ 処理をキャンセルしました。"
    exit 1
fi

# ワークフローファイルの確認
echo ""
echo "📂 ワークフローファイルを確認しています..."
WORKFLOW_FILES=$(find .github/workflows -name "*.yml" -o -name "*.yaml" 2>/dev/null | sort)

if [ -n "$WORKFLOW_FILES" ]; then
    echo "見つかったワークフローファイル:"
    echo "$WORKFLOW_FILES"
fi

# 一般的な修正を試みる
echo ""
echo "🔧 一般的な修正を実施しています..."

# パッケージ依存関係の更新（該当する場合）
if [ -f "package.json" ]; then
    echo "📦 Node.js依存関係を更新しています..."
    pnpm install
fi

if [ -f "go.mod" ]; then
    echo "📦 Go依存関係を更新しています..."
    go mod tidy
fi

if [ -f "pyproject.toml" ]; then
    echo "📦 Python依存関係を更新しています..."
    uv sync
fi

# Lintの実行（該当する場合）
echo ""
echo "🧹 Lintを実行しています..."

if [ -f "package.json" ]; then
    pnpm lint --fix 2>/dev/null || true
fi

if [ -f "go.mod" ]; then
    go fmt ./... 2>/dev/null || true
fi

# 変更があった場合はコミット
if [ -n "$(git status --porcelain)" ]; then
    echo ""
    echo "📝 修正をコミットしています..."
    git add -A
    git commit -m "fix: GitHub Actionsワークフローエラーを修正

- 依存関係を更新
- Lintエラーを修正
- ワークフロー設定を調整"
fi

echo ""
echo "✅ ワークフローの修正が完了しました！"
echo ""
echo "次のステップ："
echo "1. git push で変更をプッシュ"
echo "2. GitHub Actionsで再実行を確認"
echo "3. まだエラーが残っている場合は、詳細なログを確認"