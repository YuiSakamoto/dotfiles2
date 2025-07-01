# tmux設定

tmuxの設定ファイルとその使い方の説明です。

## 基本設定

- **Prefix**: `Ctrl+T`（デフォルトの`Ctrl+B`から変更）
- **設定再読み込み**: `Prefix + r`

## キーバインディング

### ペイン操作

#### 移動
- `Prefix + h`: 左のペインに移動
- `Prefix + j`: 下のペインに移動
- `Prefix + k`: 上のペインに移動
- `Prefix + l`: 右のペインに移動

#### 分割
- `Prefix + |`: 縦分割（現在のディレクトリを維持）
- `Prefix + -`: 横分割（現在のディレクトリを維持）

#### リサイズ
- `Prefix + H`: 左に5文字分縮小
- `Prefix + J`: 下に5行分拡大
- `Prefix + K`: 上に5行分縮小
- `Prefix + L`: 右に5文字分拡大

### コピーモード

- `Prefix + [`: コピーモード開始
- `Prefix + ]`: ペースト
- コピーモード内：
  - `v`: 選択開始（Vim風）
  - `y`: コピー＆終了
  - `Enter`: コピー＆終了

## Pane Title機能（新機能）

各ペインにタイトルを設定して、作業内容を識別しやすくできます。

### キーバインディング
- `Prefix + T`: ペインタイトルを設定
- `Prefix + Ctrl+T`: ペインタイトルをクリア

### コマンドライン（fishシェル）
```bash
# タイトルを設定
tpt "API Server"
tpt "Database Connection"
tpt "ログ監視"

# タイトルをクリア
tpt
```

### 表示例
```
┌─ 0 : API Server ─────────────┐
│ $ npm run dev                │
│ Server running on port 3000  │
└──────────────────────────────┘

┌─ 1 : Database ───────────────┐
│ $ psql -U user mydb          │
│ mydb=#                       │
└──────────────────────────────┘
```

## その他の機能

### マウス操作
- マウスでペインをクリックして選択
- マウスホイールでスクロール

### ステータスバー
- 左側：ホスト名とペイン番号
- 中央：ウィンドウリスト
- 右側：WiFi状態、バッテリー、日時

### カラー設定
- 256色対応
- アクティブペインが視覚的に判別しやすい配色

## トラブルシューティング

### 設定が反映されない場合
```bash
# tmux内で
tmux source-file ~/.tmux.conf

# または
# Prefix + r
```

### macOSでコピーが動作しない場合
`reattach-to-user-namespace`が必要です：
```bash
brew install reattach-to-user-namespace
```

### ペインタイトルが表示されない場合
tmuxのバージョンが2.3以上である必要があります：
```bash
tmux -V
```