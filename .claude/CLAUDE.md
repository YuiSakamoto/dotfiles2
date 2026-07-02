# Claude Code グローバル設定

全プロジェクト共通の設定。仕組みで強制済みの挙動はここに書かず、判断が必要なルールだけを残す。

## 仕組みで強制されていること（参照のみ）

- 応答言語（日本語）は settings.json の `"language": "japanese"` で強制
- 編集後の構文検証（fish -n / bash -n + shellcheck / jq / ruff 等）は PostToolUse hook `~/.claude/scripts/validate-edit.sh` が自動実行し、失敗時は修正必須
- npm / npx / yarn / bun は settings.json の permissions.deny でブロック
- 環境の検査は `./setup.sh doctor`（symlink 構成・秘密情報の非追跡・構文）

## 開発環境

- **Shell**: Fish shell (`/opt/homebrew/bin/fish`)
- **Editor**: Neovim（`vi`, `v` でエイリアス）
- **Version Manager**: mise (asdf互換)
- **OS**: macOS (Apple Silicon)

## パッケージマネージャー

- **JS/TS**: pnpm を使う
- **Python**: uv を使う
- **Go**: go mod を使う
- **Ruby**: bundler を使う

## コードスタイル

- コードコメントは日本語で書く（プロジェクト規約があればそれに従う）
- 技術用語は必要なら英語のまま使う
- TypeScript: `let` を避け、エラーは `throw` せず Result型で return する
- コメントは本当に必要な箇所だけ書く

## フォーマッター・リンター

- **JS/TS**: Prettier, ESLint
- **Go**: gofmt, golangci-lint
- **Python**: ruff
- **Git hooks**: lefthook

## コミット

Conventional Commits形式を使う: `feat:` / `fix:` / `docs:` / `style:` / `refactor:` / `test:` / `chore:`

## スラッシュコマンド（`~/.claude/skills/` の Skill）

- `/commit` - 会話の文脈からコミットを作る
- `/create-pr` - 現在のブランチからドラフトPRを作る
- `/reviews-fix` - PRのレビューコメントに対応する
- `/workflow-fix` - 失敗した GitHub Actions を調査・修正する
- `/cleanup-mcp` - MCPサーバーのゾンビプロセスを掃除する

## シェルエイリアス（参考）

`g`=git, `k`=kubectl, `d`=docker, `dc`=docker-compose, `tf`=terraform, `v`=nvim

## 制約事項

- 技術スタックのバージョンは変更しない。必要なら承認を得る
- UI/UX デザイン（レイアウト・色・フォント・間隔）は承認なしに変更しない
- 明示的に指示されていない変更はしない
- ファイルパスは絶対パスで指定する
