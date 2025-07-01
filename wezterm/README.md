# WezTerm設定

WezTermは、GPUアクセラレーション対応の高機能ターミナルエミュレータです。

## 特徴

- GPU描画による高速レンダリング
- 豊富な設定オプション
- Lua設定ファイル
- タブ・ペイン機能
- 複数プラットフォーム対応（macOS、Linux、Windows）

## 設定ファイル

```
wezterm/
└── wezterm.lua   # メイン設定ファイル（Lua形式）
```

## 主な設定内容

### フォント設定

- メインフォント：お使いの環境に合わせて設定
- Powerline対応フォント推奨
- フォントサイズ：12pt（デフォルト）

### カラースキーム

- デフォルトのカラースキームまたはカスタムテーマ
- 背景透過設定
- カーソルカラーのカスタマイズ

### キーバインディング

WezTerm独自のキーバインディング：

#### タブ操作
```
Cmd+T         # 新規タブ
Cmd+W         # タブを閉じる
Cmd+1-9       # タブ切り替え
Cmd+Shift+[   # 前のタブ
Cmd+Shift+]   # 次のタブ
```

#### ペイン操作
```
Cmd+D         # 縦分割
Cmd+Shift+D   # 横分割
Cmd+[         # 前のペイン
Cmd+]         # 次のペイン
```

### その他の機能

- マウス操作のサポート
- URL自動検出とクリック
- 検索機能
- コピー＆ペーストの最適化

## インストール

### macOS
```bash
# Homebrewを使用
brew install --cask wezterm
```

### Linux
```bash
# AppImageをダウンロード
curl -LO https://github.com/wez/wezterm/releases/download/nightly/WezTerm.AppImage
chmod +x WezTerm.AppImage
```

## 設定のカスタマイズ

`wezterm.lua`を編集して設定をカスタマイズ：

```lua
local wezterm = require 'wezterm'

return {
  -- フォント設定
  font = wezterm.font("Hack Nerd Font"),
  font_size = 12.0,
  
  -- カラースキーム
  color_scheme = "Gruvbox Dark",
  
  -- 背景透過
  window_background_opacity = 0.95,
  
  -- その他の設定
  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,
}
```

## tmuxとの連携

WezTermは独自のマルチプレクサ機能を持っていますが、tmuxとも併用可能です：

- tmux内でも高速な描画性能
- True Color（24ビットカラー）サポート
- 適切なTERM環境変数の設定

## トラブルシューティング

### フォントが正しく表示されない

1. Nerd Fontsをインストール：
```bash
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font
```

2. 設定ファイルでフォントを指定：
```lua
font = wezterm.font("Hack Nerd Font")
```

### 日本語が文字化けする

1. 日本語フォントを追加：
```lua
font = wezterm.font_with_fallback({
  "Hack Nerd Font",
  "Hiragino Sans",
})
```

### 設定が反映されない

- WezTermを再起動
- 設定ファイルの構文エラーをチェック
- `wezterm --config-file path/to/wezterm.lua`で起動

## パフォーマンスチューニング

### GPU設定
```lua
-- GPUアクセラレーションの設定
enable_wayland = false,  -- Linux
front_end = "OpenGL",    -- または "Software"
```

### レンダリング最適化
```lua
-- スクロールバックの制限
scrollback_lines = 10000,

-- アニメーションの無効化（低スペック環境）
animation_fps = 1,
cursor_blink_rate = 0,
```

## 便利な機能

### Quick Select Mode
`Ctrl+Shift+Space`でQuick Selectモードに入り、画面上のテキストを選択

### Search Mode
`Ctrl+Shift+F`で検索モード

### Copy Mode
`Ctrl+Shift+X`でコピーモード（vimライクな操作）

## 参考リンク

- [公式ドキュメント](https://wezfurlong.org/wezterm/)
- [設定例](https://github.com/wez/wezterm/tree/main/assets/config)