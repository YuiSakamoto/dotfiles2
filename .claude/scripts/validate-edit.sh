#!/usr/bin/env bash
# PostToolUse hook 用スクリプト（matcher: Edit|Write）
#
# Claude Code から stdin 経由で渡される JSON の `.tool_input.file_path` を
# 対象に、拡張子に応じた構文チェックを行う。
# 「モデル性能に依存しない再現性」を機械的に担保するためのゲートなので、
# ここでのチェック失敗はモデルに差し戻す（exit 2）。
# チェックツールが未インストールの環境では誤爆を避けるため静かにスキップする。
#
# 手動テスト例:
#   echo '{"tool_input":{"file_path":"/tmp/ok.json"}}' | .claude/scripts/validate-edit.sh
#
# 個別チェックの失敗で set -e により即死しないよう、あえて -e は付けない。
set -uo pipefail

# jq が無いと tool_input を取り出せないため何もせず終了する
if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

input="$(cat)"
file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"

# file_path が無い、あるいは対象ファイルが存在しない場合は何もしない
if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
  exit 0
fi

# チェック失敗時: stderr にエラー内容と修正指示を出力してブロッキングフィードバックを返す
fail() {
  local detail="$1"
  {
    echo "[validate-edit] 構文チェックに失敗しました: $file_path"
    echo "$detail"
    echo "上記のエラーを修正してから再度編集してください。"
  } >&2
  exit 2
}

case "$file_path" in
  *.fish)
    if command -v fish >/dev/null 2>&1; then
      out="$(fish -n "$file_path" 2>&1)" || fail "$out"
    fi
    ;;
  *.zsh | *.zshrc | *.zshenv | *.zprofile | */zsh/functions/*)
    # zsh/functions/ 配下の autoload 関数は拡張子を持たないためパスで拾う
    if command -v zsh >/dev/null 2>&1; then
      out="$(zsh -n "$file_path" 2>&1)" || fail "$out"
    fi
    ;;
  *.sh | *.bash)
    if command -v bash >/dev/null 2>&1; then
      out="$(bash -n "$file_path" 2>&1)" || fail "$out"
    fi
    if command -v shellcheck >/dev/null 2>&1; then
      out="$(shellcheck "$file_path" 2>&1)" || fail "$out"
    fi
    ;;
  */cmux/cmux.json)
    # cmux.json は JSONC（コメント可）なので jq では検証できない。
    # cmux CLI の validate（対象は primary = ~/.config/cmux/cmux.json だが、
    # この repo では symlink で同一実体）に委ねる。cmux が無い環境ではスキップ
    if command -v cmux >/dev/null 2>&1; then
      out="$(cmux config validate 2>&1)" || fail "$out"
    fi
    ;;
  *.json)
    if command -v jq >/dev/null 2>&1; then
      out="$(jq empty "$file_path" 2>&1)" || fail "$out"
    elif command -v python3 >/dev/null 2>&1; then
      out="$(python3 -m json.tool "$file_path" 2>&1 >/dev/null)" || fail "$out"
    fi
    ;;
  *.lua)
    if command -v luac >/dev/null 2>&1; then
      out="$(luac -p "$file_path" 2>&1)" || fail "$out"
    fi
    ;;
  *.toml)
    if command -v taplo >/dev/null 2>&1; then
      out="$(taplo check "$file_path" 2>&1)" || fail "$out"
    fi
    ;;
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      out="$(ruff check "$file_path" 2>&1)" || fail "$out"
    elif command -v python3 >/dev/null 2>&1; then
      out="$(python3 -m py_compile "$file_path" 2>&1)" || fail "$out"
    fi
    ;;
  *)
    # 対象外の拡張子は何もしない
    exit 0
    ;;
esac

exit 0
