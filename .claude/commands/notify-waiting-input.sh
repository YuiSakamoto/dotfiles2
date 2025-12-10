#!/bin/bash

# macOSのシステムサウンドを再生（入力待ちは控えめな音）
SOUND_FILE="/System/Library/Sounds/Tink.aiff"

# サウンドファイルが存在する場合のみ再生
if [ -f "$SOUND_FILE" ]; then
    afplay "$SOUND_FILE" &
fi

# デスクトップ通知を表示（macOS）
if command -v osascript >/dev/null 2>&1; then
    MESSAGE="ユーザー入力を待っています 🤔"

    # 通知を表示
    osascript -e "display notification \"$MESSAGE\" with title \"Claude Code\" sound name \"Tink\"" 2>/dev/null || true
fi

# ターミナルにも入力待ちメッセージを表示
echo "⏳ Claude Codeがユーザーの入力を待っています"

exit 0
