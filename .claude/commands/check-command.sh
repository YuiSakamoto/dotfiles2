#!/bin/bash

# コマンドを取得
COMMAND=$(echo "$CLAUDE_PARAMETERS" | jq -r '.command // empty')

# コマンドが空の場合は終了
if [ -z "$COMMAND" ]; then
    exit 0
fi

# npmやnpxの使用をブロック
if echo "$COMMAND" | grep -qE '^(npm|npx)\s'; then
    echo "⚠️  pnpmを使用してください (pnpm / pnpx)"
    exit 1
fi

# yarnの使用をブロック
if echo "$COMMAND" | grep -qE '^yarn\s'; then
    echo "⚠️  pnpmを使用してください"
    exit 1
fi

# ルートディレクトリからの削除をブロック
if echo "$COMMAND" | grep -qE '^rm\s+-rf\s+/'; then
    echo "🚨 危険: ルートディレクトリからの削除は禁止されています"
    exit 1
fi

# 再帰的な削除の警告
if echo "$COMMAND" | grep -qE '^(sudo\s+)?rm\s+-rf\s+\*'; then
    echo "⚠️  警告: 再帰的な削除を実行しようとしています"
    echo "本当に実行しますか？ (yes/no): "
    read -r confirm
    if [ "$confirm" != "yes" ]; then
        exit 1
    fi
fi

# force pushの警告
if echo "$COMMAND" | grep -qE '^git\s+push\s+.*--force'; then
    echo "⚠️  force pushを実行しようとしています"
    echo "本当に実行しますか？ (yes/no): "
    read -r confirm
    if [ "$confirm" != "yes" ]; then
        exit 1
    fi
fi

# git commitのヒント
if echo "$COMMAND" | grep -qE '^git\s+commit'; then
    echo "💡 ヒント: テストを実行しましたか？"
    echo "続行するにはEnterを押してください..."
    read -r
fi

# テスト実行後のメッセージ
if echo "$COMMAND" | grep -qE '^(pnpm|npm|yarn)\s+test'; then
    # コマンド実行後の終了コードをチェック
    echo "🧪 テストを実行中..."
fi

# ビルド実行後のメッセージ
if echo "$COMMAND" | grep -qE '^(pnpm|npm|yarn)\s+build'; then
    echo "🔨 ビルドを実行中..."
fi

exit 0