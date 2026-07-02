#!/bin/bash

# macOS専用の通知スクリプト。osascript が存在しない環境 (Linux/WSL) では
# 何もせず正常終了し、hookを汚染しない。
command -v osascript >/dev/null 2>&1 || exit 0

# macOSのシステムサウンドを再生
# 利用可能なサウンド: Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink
SOUND_FILE="/System/Library/Sounds/Glass.aiff"

# サウンドファイルが存在する場合のみ再生
if [ -f "$SOUND_FILE" ]; then
    afplay "$SOUND_FILE" &
fi

# デスクトップ通知を表示（macOS）
if command -v osascript >/dev/null 2>&1; then
    # タスクの内容を取得（可能な場合）
    MESSAGE="タスクが完了しました 🎉"
    
    # 最後のコマンドや編集したファイルの情報があれば追加
    if [ -n "$CLAUDE_LAST_FILE" ]; then
        MESSAGE="$CLAUDE_LAST_FILE の編集が完了しました 📝"
    elif [ -n "$CLAUDE_LAST_COMMAND" ]; then
        MESSAGE="コマンドの実行が完了しました ✅"
    fi
    
    # 通知を表示
    osascript -e "display notification \"$MESSAGE\" with title \"Claude Code\" sound name \"Glass\"" 2>/dev/null || true
fi

# ターミナルにも完了メッセージを表示
echo "✨ Claude Codeがタスクを完了しました！"

# 長時間のタスクの場合は追加の通知音
# （前回の実行時刻と比較して3分以上経過している場合）
TIMESTAMP_FILE="/tmp/.claude_last_completion"
CURRENT_TIME=$(date +%s)

if [ -f "$TIMESTAMP_FILE" ]; then
    LAST_TIME=$(cat "$TIMESTAMP_FILE")
    TIME_DIFF=$((CURRENT_TIME - LAST_TIME))
    
    # 3分（180秒）以上経過している場合は追加の通知音
    if [ "$TIME_DIFF" -gt 180 ]; then
        sleep 0.5
        afplay "/System/Library/Sounds/Hero.aiff" &
        
        # 重要なタスク完了の通知
        osascript -e 'display notification "長時間のタスクが完了しました！" with title "⏰ Claude Code" sound name "Hero"' 2>/dev/null || true
    fi
fi

# 現在の時刻を記録
echo "$CURRENT_TIME" > "$TIMESTAMP_FILE"

exit 0