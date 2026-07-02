---
name: create-pr
description: 現在のブランチの変更内容からドラフトPRを作成する。ユーザーが「PRを作成して」「プルリクを出して」と指示したとき、または /create-pr 実行時に使う。
---

# create-pr: 会話コンテキストを考慮したドラフトPR作成

以下のステップを**順番に**実行する。判断が必要な箇所はユーザーに確認してから進める。

## 0. 前提確認

```bash
command -v gh >/dev/null || echo "gh未インストール"
```

`gh` が無い場合は `brew install gh` の実行を案内し、処理を中断する。

## 1. ブランチ確認

```bash
CURRENT_BRANCH=$(git branch --show-current)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
DEFAULT_BRANCH=${DEFAULT_BRANCH:-main}
echo "current=$CURRENT_BRANCH default=$DEFAULT_BRANCH"
```

- `CURRENT_BRANCH` が `DEFAULT_BRANCH` と同じ場合:
  1. デフォルトブランチから直接PRを作成しようとしている旨をユーザーに伝える
  2. ブランチを新規作成するかユーザーに確認する
  3. 承認された場合はブランチ名を提案し、`git checkout -b <branch>` を実行する
  4. 拒否された場合は処理を中断する

## 2. 未コミット変更の確認

```bash
git status --porcelain
```

- 出力がある場合、コミットしてから進めるかユーザーに確認する
- コミットする場合は `commit` スキルの手順（ブランチ確認は済んでいるためステップ2以降）に従う
- コミットしない場合はユーザーの指示に従う（未コミット変更を残したままpushしない）

## 3. リモートへのプッシュ

```bash
git push -u origin "$CURRENT_BRANCH"
```

## 4. 直近のコミット確認

```bash
git log --oneline -5 "$DEFAULT_BRANCH".."$CURRENT_BRANCH"
```

この出力と会話の文脈から、PRタイトル・本文の材料を集める。

## 5. PRタイトル・本文の生成

会話のコンテキストと上記のコミットログから、**プレースホルダーではなく実際の変更内容を反映した**タイトル・本文を作成する。本文は以下のテンプレートに従う:

```markdown
## 概要
この変更で実装した内容の概要

## 変更内容
- 具体的な変更点1
- 具体的な変更点2

## テスト方法
1. テスト手順1
2. テスト手順2

## チェックリスト
- [ ] コードレビューの準備ができている
- [ ] テストを実行して動作を確認した
- [ ] ドキュメントを更新した（必要に応じて）

## 関連Issue
- #issue番号（該当する場合）
```

作成したタイトル・本文をユーザーに提示し、承認（またはユーザーによる修正指示）を得る。

## 6. ドラフトPR作成

承認が得られたら、本文をファイルに書き出してから `gh pr create` を実行する（シェルのクォート崩れを避けるため）:

```bash
cat <<'EOF' > /tmp/pr_body.txt
<本文>
EOF

gh pr create --draft --title "<タイトル>" --body-file /tmp/pr_body.txt --base "$DEFAULT_BRANCH"

rm -f /tmp/pr_body.txt
```

## 検証

```bash
gh pr view --json url,title,isDraft,baseRefName
git status
```

- `isDraft` が `true` であること
- `baseRefName` が `DEFAULT_BRANCH` と一致すること
- `git status` に想定外の未コミット変更が残っていないこと
