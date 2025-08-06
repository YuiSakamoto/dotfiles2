# Claude Code Commands

このディレクトリには、Claude Codeのhooksから呼び出されるスクリプトが含まれています。

## スクリプト一覧

### format-file.sh
ファイル編集後に自動的にフォーマッターを実行します。
- JavaScript/TypeScript: Prettier + ESLint
- Python: ruff format + ruff check
- Go: go fmt + golangci-lint
- YAML: yamllint
- シェルスクリプト: 実行権限の自動付与

### check-command.sh
Bashコマンド実行前のチェックを行います。
- npm/yarn → pnpmへの警告
- 危険なrmコマンドのブロック
- force pushの確認
- git commitのヒント

### notify-completion.sh
タスク完了時に音と通知を表示します。
- システムサウンドの再生（Glass.aiff）
- デスクトップ通知の表示
- 長時間タスクの場合は追加通知（Hero.aiff）

## macOS通知の設定

初回実行時に通知権限の設定が必要です：

1. **スクリプトエディタを開く**
   ```bash
   open -a "Script Editor"
   ```

2. **以下のスクリプトを実行**
   ```applescript
   display notification "テスト通知" with title "Claude Code"
   ```

3. **システム設定で通知を許可**
   - システム設定 → 通知とフォーカス
   - スクリプトエディタを探して通知を許可

4. **ターミナルにも通知権限を付与**
   - 同様にターミナル（またはiTerm2等）の通知も許可

## カスタマイズ

### サウンドの変更
`notify-completion.sh`内の`SOUND_FILE`変数を変更してください。

利用可能なサウンド：
- Basso（低音）
- Blow（吹く音）
- Bottle（ボトル）
- Frog（カエル）
- Funk（ファンク）
- Glass（グラス）✨ デフォルト
- Hero（ヒーロー）🎺 長時間タスク用
- Morse（モールス）
- Ping（ピン）
- Pop（ポップ）
- Purr（ゴロゴロ）
- Sosumi（ソースミ）
- Submarine（潜水艦）
- Tink（チンク）

### 通知メッセージのカスタマイズ
`notify-completion.sh`内のメッセージを編集して、お好みの通知文言に変更できます。

## トラブルシューティング

### 通知が表示されない場合
1. システム設定で通知権限を確認
2. おやすみモードがオフになっているか確認
3. `osascript`コマンドが使用可能か確認：
   ```bash
   which osascript
   ```

### 音が鳴らない場合
1. システムの音量設定を確認
2. サウンドファイルの存在を確認：
   ```bash
   ls /System/Library/Sounds/
   ```

## 注意事項

- これらのスクリプトはmacOS専用です
- Linux/Windowsで使用する場合は、通知部分の修正が必要です
- Claude Codeを再起動すると設定が反映されます