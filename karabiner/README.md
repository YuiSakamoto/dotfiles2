# Karabiner-Elements設定

macOS用のキーボードカスタマイズツール「Karabiner-Elements」の設定ファイルです。

## 概要

Karabiner-Elementsを使用して、キーボードの動作をカスタマイズします。特に、Vimライクな操作やプログラミングに便利なキーバインドを設定しています。

## 主な設定内容

### Caps Lockキーの活用

Caps Lockキーを「Hyper Key」として活用：
- 単体押し：ESC
- 組み合わせ：Control + Shift + Option + Command

### Vimライクなカーソル移動

Caps Lock（Hyper）+ Vimキーでカーソル移動：
```
Caps Lock + h → ←（左）
Caps Lock + j → ↓（下）
Caps Lock + k → ↑（上）
Caps Lock + l → →（右）
```

### その他のカスタマイズ

- 日本語キーボードの最適化
- アプリケーション固有の設定
- Complex Modificationsによる高度な設定

## 設定ファイル

```
karabiner/
└── karabiner.json   # メイン設定ファイル
```

## インストールと設定

### 1. Karabiner-Elementsのインストール

```bash
# Homebrewを使用
brew install --cask karabiner-elements
```

### 2. 設定ファイルのシンボリックリンク

`setup.sh`を実行することで自動的に設定されます：
```bash
./setup.sh
```

手動で設定する場合：
```bash
ln -sf ~/src/github.com/YuiSakamoto/dotfiles2/karabiner ~/.config/karabiner
```

### 3. Karabiner-Elementsを起動

1. アプリケーションから「Karabiner-Elements」を起動
2. システム環境設定でアクセシビリティの許可を与える
3. 設定が自動的に読み込まれます

## Complex Modifications

より高度なカスタマイズを行う場合は、Complex Modificationsを使用します。

### 追加方法

1. Karabiner-Elementsの設定画面を開く
2. 「Complex Modifications」タブを選択
3. 「Add rule」から必要なルールを追加

### おすすめのルール

- **Change caps_lock to escape**: Caps Lockを押すとESC
- **Vim Style Arrows**: Vimスタイルの矢印キー
- **Emacs key bindings**: Emacsスタイルのキーバインド

## トラブルシューティング

### 設定が反映されない

1. Karabiner-Elementsを再起動
2. システム環境設定でアクセシビリティの許可を確認
3. 設定ファイルの文法エラーをチェック

### キーが効かなくなった

1. Karabiner-Elementsの「Devices」タブを確認
2. 使用しているキーボードがチェックされているか確認
3. 「Simple Modifications」で意図しない設定がないか確認

### 設定のバックアップ

設定ファイルは自動的にバックアップされます：
```
~/.config/karabiner/automatic_backups/
```

## 注意事項

- macOSのアップデート後は動作確認が必要
- 外部キーボードと内蔵キーボードで異なる設定が可能
- セキュリティソフトと競合する場合があります

## カスタマイズのヒント

### 新しいルールの追加

`karabiner.json`の`rules`セクションに追加：

```json
{
  "description": "説明",
  "manipulators": [
    {
      "type": "basic",
      "from": {
        "key_code": "元のキー"
      },
      "to": [
        {
          "key_code": "変換後のキー"
        }
      ]
    }
  ]
}
```

### デバッグ

Event Viewerを使用してキーイベントを確認：
1. Karabiner-Elements → Misc → Open Event Viewer
2. キーを押してイベントを確認