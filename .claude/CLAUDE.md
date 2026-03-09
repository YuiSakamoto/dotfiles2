# Claude Code グローバル設定

このファイルはすべてのプロジェクトで適用される設定です。

## 基本的な対話設定

- 日本語で応答してください
- コードコメントは基本的に日本語で書いてください（プロジェクトの規約がある場合はそれに従う）
- 技術的な用語は必要に応じて英語のまま使用してください

## 開発環境

- **Shell**: Fish shell (`/opt/homebrew/bin/fish`)
- **Editor**: Neovim（`vi`, `v` でエイリアス）
- **Version Manager**: mise (asdf互換)
- **OS**: macOS (Apple Silicon)

## パッケージマネージャー

- **JavaScript/TypeScript**: pnpm を使用（npm/yarn/bunは絶対に使わない）
- **Python**: uv を使用
- **Go**: go mod を使用
- **Ruby**: bundler を使用

## コミットスタイル

Conventional Commits形式を使用:
- `feat:` 新機能
- `fix:` バグ修正
- `docs:` ドキュメントのみの変更
- `style:` コードの動作に影響しない変更（フォーマット等）
- `refactor:` バグ修正や機能追加を伴わないコード変更
- `test:` テストの追加・修正
- `chore:` ビルドプロセスやツールの変更

## コードスタイル

- **TypeScript**: `let` は極力使わない。エラーは `throw` せず Result型でreturnする
- **全般**: 読みやすいコード優先。コメントは本当に必要な箇所のみ

## フォーマッター・リンター

- **JS/TS**: Prettier, ESLint
- **Go**: gofmt, golangci-lint
- **Python**: ruff
- **Git hooks**: lefthook

## よく使うコマンド

- `/commit` - AIが会話のコンテキストを考慮してコミットする
- `/reviews-fix` - PRレビューコメントに対応する
- `/workflow-fix` - GitHub Actionsのワークフローを修正する

## シェルエイリアス（参考）

`g`=git, `k`=kubectl, `d`=docker, `dc`=docker-compose, `tf`=terraform, `v`=nvim

## 制約事項

- 技術スタックのバージョンは変更せず、必要があれば必ず承認を得る
- UI/UX デザインの変更（レイアウト、色、フォント、間隔など）は承認なしに行わない
- 明示的に指示されていない変更は行わない

## 検証基準

変更後は必ず以下で検証:
- **fish 設定**: `fish -n <file>` で構文チェック
- **シェルスクリプト**: `shellcheck <file>` で静的解析
- **git 操作**: 変更後 `git status` で確認

## セッション管理

- 同じ問題で2回以上修正を要求されたら、アプローチを再考する
- 大きなタスクは小さなステップに分割して完了確認を挟む
- コンテキストが汚染されたと感じたら `/clear` で再開を提案する

## その他

- ファイルパスは必ず絶対パスで指定する
- 大量のファイル操作を行う場合は、事前に確認を求める
- 破壊的な操作（削除、上書き等）を行う前は特に注意する
