---
name: reviews-fix
description: 現在のブランチに紐づくPRのレビューコメントを取得し、指摘事項に対応する。ユーザーが「レビューコメントに対応して」「PRの指摘を直して」と指示したとき、または /reviews-fix 実行時に使う。
---

# reviews-fix: PRレビューコメントへの対応

以下のステップを**順番に**実行する。

## 0. 前提確認

```bash
command -v gh >/dev/null || echo "gh未インストール"
```

`gh` が無い場合は `brew install gh` の実行を案内し、処理を中断する。

## 1. 対象PRの特定

```bash
PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null)
echo "PR_NUMBER=$PR_NUMBER"
```

`PR_NUMBER` が空の場合は「現在のブランチにPRが見つかりません。PRを作成してから実行してください」と伝えて中断する。

## 2. レビューコメントの取得

```bash
gh pr view "$PR_NUMBER" --json reviews \
  -q '.reviews[] | select(.state != "COMMENTED") | {author: .author.login, state: .state, body: .body}'

gh api "repos/{owner}/{repo}/pulls/$PR_NUMBER/comments" \
  --jq '.[] | {path: .path, line: .line, body: .body, user: .user.login}'
```

両方とも出力が空の場合は「対応が必要なレビューコメントはありません」と報告して終了する。

## 3. コメントの整理

取得した「一般的なレビューコメント」と「ファイル別（インライン）コメント」を一覧化し、ユーザーに提示する。各コメントについて以下を整理する:

- 対象ファイル・行
- 指摘内容の要約
- 対応方針（修正する / 議論が必要 / 対応不要とその理由）

対応方針をユーザーに提示し、承認を得てから次に進む。

## 4. 修正の実施

承認された各コメントについて、該当ファイルを実際に修正する。指摘の種類ごとの典型対応:

- コードスタイル・命名 → 該当箇所を修正
- エラーハンドリング不足 → 適切な例外処理・Result型での返却などを追加
- テスト不足の指摘 → テストケースを追加
- ドキュメント不足の指摘 → 該当ドキュメントを更新

## 5. テストの実行

プロジェクトの種類に応じてテストを実行する（該当するもののみ実行）:

```bash
[ -f package.json ] && pnpm test
[ -f go.mod ] && go test ./...
[ -f pyproject.toml ] && uv run pytest
```

テストが失敗した場合は、コミットに進まず修正をやり直す。

## 6. コミット

テストが通ったら `commit` スキルの手順に従ってコミットする。メッセージには対応したPR番号を含める:

```
fix: PRレビューコメントに対応

- <対応した指摘の要約>

Addresses PR review comments in #<PR_NUMBER>
```

## 検証

```bash
git status
git log --oneline -1
gh pr view "$PR_NUMBER" --json reviewDecision
```

- `git status` に意図しない変更が残っていないこと
- テストコマンドが成功していること（手順5の出力を確認）
- コミット後、`git push` してPRにコメントを追加し、再レビューを依頼するようユーザーに案内する
