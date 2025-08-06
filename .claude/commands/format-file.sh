#!/bin/bash

# ファイルパスを取得
FILE_PATH=$(echo "$CLAUDE_PARAMETERS" | jq -r '.file_path // .filePath // empty')

# ファイルが存在しない場合は終了
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# 拡張子を取得
EXT="${FILE_PATH##*.}"
FILENAME="${FILE_PATH##*/}"

# プロジェクトディレクトリに移動
cd "$CLAUDE_PROJECT_DIR" || exit 0

# ファイル拡張子に応じてフォーマッターを実行
case "$EXT" in
    js|jsx|ts|tsx|json|css|md)
        if [ -f "package.json" ] && command -v pnpm >/dev/null 2>&1; then
            pnpm prettier --write "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
    go)
        if [ -f "go.mod" ] && command -v go >/dev/null 2>&1; then
            go fmt "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
    py)
        if [ -f "pyproject.toml" ] && command -v uv >/dev/null 2>&1; then
            uv run ruff format "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
    yml|yaml)
        if command -v yamllint >/dev/null 2>&1; then
            yamllint -d relaxed "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
    sh)
        # シェルスクリプトに実行権限を付与
        chmod +x "$FILE_PATH"
        echo "✅ 実行権限を付与しました: $FILENAME"
        ;;
esac

# TypeScript/JavaScriptファイルの場合はESLintも実行
case "$EXT" in
    js|jsx|ts|tsx)
        if [ -f "package.json" ] && command -v pnpm >/dev/null 2>&1; then
            pnpm eslint --fix "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
esac

# Pythonファイルの場合はruff checkも実行
if [ "$EXT" = "py" ]; then
    if [ -f "pyproject.toml" ] && command -v uv >/dev/null 2>&1; then
        uv run ruff check --fix "$FILE_PATH" 2>/dev/null || true
    fi
fi

# Goファイルの場合はgolangci-lintも実行
if [ "$EXT" = "go" ]; then
    if [ -f "go.mod" ] && command -v golangci-lint >/dev/null 2>&1; then
        golangci-lint run "$FILE_PATH" 2>/dev/null || true
    fi
fi

# Terraformファイルの場合
if [ "$EXT" = "tf" ]; then
    if command -v terraform >/dev/null 2>&1; then
        terraform fmt "$FILE_PATH" 2>/dev/null || true
    fi
fi

# package.jsonが更新された場合
if [ "$FILENAME" = "package.json" ]; then
    echo "📦 package.jsonが更新されました。依存関係をインストールしています..."
    pnpm install --silent 2>/dev/null || true
fi

# go.modが更新された場合
if [ "$FILENAME" = "go.mod" ]; then
    echo "📦 go.modが更新されました。依存関係を整理しています..."
    go mod tidy 2>/dev/null || true
fi

exit 0