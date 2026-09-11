---
name: workflow-fix
description: 現在のブランチ/PRで失敗しているGitHub Actionsワークフローを調査し修正する。ユーザーが「CIを直して」「ワークフローのエラーを直して」と指示したとき、または /workflow-fix 実行時に使う。
---

# workflow-fix: GitHub Actionsワークフローエラーの修正

以下のステップを**順番に**実行する。

## 0. 前提確認

```bash
command -v gh >/dev/null || echo "gh未インストール"
```

`gh` が無い場合は `brew install gh` の実行を案内し、処理を中断する。

## 1. ワークフロー状態の取得

```bash
CURRENT_BRANCH=$(git branch --show-current)
PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null)
```

- `PR_NUMBER` が取得できた場合:

```bash
gh pr checks "$PR_NUMBER" --json name,status,conclusion,detailsUrl
```

- 取得できなかった場合（PRが無い場合）は最新コミットのcheck-runsを見る:

```bash
LATEST_SHA=$(git rev-parse HEAD)
gh api "repos/{owner}/{repo}/commits/$LATEST_SHA/check-runs" \
  --jq '.check_runs[] | {name: .name, status: .status, conclusion: .conclusion, detailsUrl: .details_url}'
```

## 2. 失敗ワークフローの抽出

上記出力に対して `conclusion` が `failure` または `cancelled` のものを失敗として扱う。全て成功していれば「すべてのワークフローが正常に実行されています」と報告して終了する。

## 3. 失敗ログの取得

各失敗ワークフローについて、`detailsUrl` 末尾の数字を `RUN_ID` として抽出し、失敗ジョブとログを取得する:

```bash
RUN_ID=$(echo "<detailsUrl>" | grep -oE '[0-9]+$')
gh run view "$RUN_ID" --json jobs -q '.jobs[] | select(.conclusion == "failure") | .name'
gh run view "$RUN_ID" --log-failed
```

取得したログを読み、失敗原因を特定する。典型的な原因と切り分け基準:

| 原因 | ログ上の手がかり |
|---|---|
| 依存関係のバージョン不整合 | `lockfile` 不一致、`ERESOLVE`、`go.sum` mismatch |
| 環境変数・シークレット不足 | `undefined`, `required secret`, 認証エラー |
| ファイルパス・パーミッション問題 | `no such file or directory`, `Permission denied` |
| テスト失敗 | テストランナーの `FAIL` 出力 |
| Lintエラー | lintツールのエラー出力 |

## 4. 修正方針の提示

特定した原因と修正方針をユーザーに提示し、承認を得てから修正に着手する。

## 5. ローカルでの修正・検証

原因に応じて、プロジェクトの種類ごとに対応する（該当するもののみ実行）:

```bash
# 依存関係
[ -f package.json ] && pnpm install
[ -f go.mod ] && go mod tidy
[ -f pyproject.toml ] && uv sync

# Lint
[ -f package.json ] && pnpm lint --fix
[ -f go.mod ] && go fmt ./...
[ -f pyproject.toml ] && uv run ruff check --fix

# テスト
[ -f package.json ] && pnpm test
[ -f go.mod ] && go test ./...
[ -f pyproject.toml ] && uv run pytest
```

依存関係更新・Lint・テストが該当する場合は必ずローカルで再実行し、失敗が解消したことを確認してから次に進む。

## 6. コミット

修正がある場合、`commit` スキルの手順に従ってコミットする。メッセージ例:

```
fix: GitHub Actionsワークフローエラーを修正

- <修正内容の要約>
```

## 検証

```bash
git status
git push
gh pr checks "$PR_NUMBER" --watch
```

（`PR_NUMBER` が無い場合は push 後にActions上で再実行結果を確認するようユーザーに案内する）

- push後のワークフローが成功していること
- まだ失敗が残る場合は、手順1に戻ってログを再取得し原因を再調査する
