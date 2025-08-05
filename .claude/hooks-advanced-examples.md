# Claude Code 高度なHooks活用例

## 開発効率を劇的に向上させるHooks設定

### 1. 自動ドキュメント生成

```json
{
  "hooks": {
    "write.post": [
      {
        // 新しいコンポーネント作成時に自動でStorybook用ファイルを生成
        "glob": "src/components/**/*.tsx",
        "command": "test ! -f {file%.tsx}.stories.tsx && echo 'import type { Meta, StoryObj } from \"@storybook/react\";\nimport { {basename} } from \"./{basename}\";\n\nconst meta: Meta<typeof {basename}> = {\n  component: {basename},\n};\n\nexport default meta;\ntype Story = StoryObj<typeof {basename}>;\n\nexport const Default: Story = {};' > {file%.tsx}.stories.tsx"
      },
      {
        // 新しいAPIエンドポイント作成時にOpenAPIドキュメントを生成
        "glob": "src/api/**/*.ts",
        "command": "echo '📚 APIドキュメントを更新してください: pnpm run generate:api-docs'"
      }
    ]
  }
}
```

### 2. 自動テスト実行とカバレッジチェック

```json
{
  "hooks": {
    "edit.post": [
      {
        // ソースコード編集時に関連テストを自動実行
        "glob": "src/**/*.{ts,tsx}",
        "command": "test -f {file%.ts}.test.ts && pnpm test {file%.ts}.test.ts --coverage || true"
      }
    ],
    "bash.pre": [
      {
        // PR作成前にカバレッジチェック
        "pattern": "^gh pr create",
        "command": "pnpm test --coverage && echo '✅ テストカバレッジ: ' && cat coverage/coverage-summary.json | jq '.total.lines.pct'"
      }
    ]
  }
}
```

### 3. 依存関係の自動更新と脆弱性チェック

```json
{
  "hooks": {
    "edit.post": [
      {
        // package.json編集後に脆弱性チェック
        "glob": "package.json",
        "command": "pnpm audit && echo '🔍 依存関係の脆弱性をチェックしました'"
      },
      {
        // lockファイル更新時に未使用パッケージを警告
        "glob": "pnpm-lock.yaml",
        "command": "npx depcheck --json | jq -r '.dependencies[]' | while read dep; do echo \"⚠️  未使用の依存関係: $dep\"; done"
      }
    ]
  }
}
```

### 4. Git操作の自動化と最適化

```json
{
  "hooks": {
    "bash.post": [
      {
        // ブランチ作成時に自動でupstreamを設定
        "pattern": "^git checkout -b",
        "command": "branch=$(git branch --show-current) && git push -u origin $branch && echo '✅ upstream設定完了: origin/$branch'"
      },
      {
        // マージ後に自動でローカルブランチをクリーンアップ
        "pattern": "^git merge",
        "command": "git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d 2>/dev/null && echo '🧹 マージ済みブランチをクリーンアップしました'"
      }
    ]
  }
}
```

### 5. デバッグ支援

```json
{
  "hooks": {
    "edit.pre": [
      {
        // console.logの自動削除（本番コード）
        "glob": "src/**/*.{ts,tsx,js,jsx}",
        "command": "grep -n 'console\\.' {file} && echo '⚠️  console文が含まれています。削除しますか？' || true"
      }
    ],
    "write.post": [
      {
        // デバッグ用ログファイルの自動生成
        "glob": "**/*.debug.ts",
        "command": "echo '// Debug file created at $(date)\\n// Remember to remove before commit\\n' > {file}.log"
      }
    ]
  }
}
```

### 6. CI/CD連携

```json
{
  "hooks": {
    "bash.pre": [
      {
        // デプロイ前の自動チェックリスト
        "pattern": "^(pnpm|npm|yarn) run deploy",
        "command": "echo '🚀 デプロイ前チェックリスト:' && echo '[ ] テストは全て通過？' && echo '[ ] 環境変数は設定済み？' && echo '[ ] マイグレーションは必要？' && read -p '全て完了していますか？ (y/n): ' confirm && [ \"$confirm\" = \"y\" ]"
      }
    ]
  }
}
```

### 7. パフォーマンス監視

```json
{
  "hooks": {
    "edit.post": [
      {
        // バンドルサイズの自動チェック
        "glob": "src/**/*.{ts,tsx,js,jsx}",
        "command": "test -f package.json && echo '📊 バンドルサイズをチェック中...' && pnpm run analyze:bundle-size --quiet || true"
      }
    ]
  }
}
```

### 8. セキュリティ強化

```json
{
  "hooks": {
    "write.pre": [
      {
        // 機密情報の検出
        "glob": "**/*",
        "command": "grep -E '(api_key|secret|password|token)\\s*[:=]\\s*[\"\\']\\w+[\"\\']' {file} && echo '🚨 警告: ハードコードされた機密情報を検出しました！' && exit 1 || true"
      }
    ],
    "bash.pre": [
      {
        // .envファイルのコミット防止
        "pattern": "^git add.*\\.env",
        "command": "echo '🛑 .envファイルはコミットできません！' && exit 1"
      }
    ]
  }
}
```

## プロジェクト別の活用例

### React/Next.jsプロジェクト

```json
{
  "hooks": {
    "write.post": [
      {
        // ページコンポーネント作成時にルーティング設定を提案
        "glob": "pages/**/*.tsx",
        "command": "echo '📝 新しいページが作成されました。メタデータとSEO設定を忘れずに！'"
      },
      {
        // カスタムフック作成時にテストファイルを生成
        "glob": "hooks/use*.ts",
        "command": "test ! -f {file%.ts}.test.ts && echo 'import { renderHook } from \"@testing-library/react\";\nimport { {basename} } from \"./{basename}\";\n\ndescribe(\"{basename}\", () => {\n  it(\"should work\", () => {\n    const { result } = renderHook(() => {basename}());\n    expect(result.current).toBeDefined();\n  });\n});' > {file%.ts}.test.ts"
      }
    ]
  }
}
```

### Go プロジェクト

```json
{
  "hooks": {
    "write.post": [
      {
        // インターフェース作成時にモック自動生成
        "glob": "**/*_interface.go",
        "command": "go generate ./..."
      }
    ],
    "edit.post": [
      {
        // import文の自動整理
        "glob": "*.go",
        "command": "goimports -w {file}"
      }
    ]
  }
}
```

### Python プロジェクト

```json
{
  "hooks": {
    "write.post": [
      {
        // __init__.pyの自動生成
        "glob": "**/",
        "command": "test -d {file} && test ! -f {file}/__init__.py && touch {file}/__init__.py && echo '✅ __init__.py を作成しました'"
      }
    ],
    "edit.post": [
      {
        // 型ヒントのチェック
        "glob": "*.py",
        "command": "mypy {file} --ignore-missing-imports || true"
      }
    ]
  }
}
```

## 使い方のTips

1. **条件付き実行**: `test`コマンドを使って条件分岐
2. **エラーハンドリング**: `|| true`で失敗を無視
3. **対話的な確認**: `read`コマンドでユーザー入力を受け付け
4. **環境変数の活用**: プロジェクト固有の設定に対応
5. **複数コマンドの連携**: `&&`や`;`でコマンドを連結

これらのhooksを活用することで、開発フローが大幅に自動化・最適化されます！