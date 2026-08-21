# cmux

macOS ネイティブのターミナル/エージェント管理アプリ [cmux](https://github.com/manaflow-ai/cmux)
(`com.cmuxterm.app`) の設定。`~/.config/cmux/` へディレクトリごと symlink される。

## 見た目の設定がどこにあるか

cmux の外観は 2 系統に分かれている。

| 対象 | 設定ファイル |
| --- | --- |
| ターミナル部分（配色・フォント・余白・透過・カーソル） | [`../ghostty/config`](../ghostty/config) |
| アプリ UI（サイドバー tint、ライト/ダーク、ワークスペース色） | `cmux.json`（このディレクトリ） |

cmux は ghostty を内蔵しているため、ターミナルの見た目は ghostty の設定がそのまま効く。
同梱テーマは 463 個あり、一覧は次で確認できる。

```
ls /Applications/cmux.app/Contents/Resources/ghostty/themes
```

## cmux.json の扱い

- **ここに書いたキーは "file-managed" になり、cmux の Settings UI から変更できなくなる**。
  そのため外観に関わるキーだけを書き、挙動系（`copyOnSelect` や shortcuts など）は
  UI 側に委ねている。
- UI で変更した設定は `defaults`（`com.cmuxterm.app`）に保存されるので、repo は汚れない。
- 設定可能なキーの全体像は、cmux が初回起動時に生成する雛形か、
  `cmux.json` の `$schema` が指す JSON Schema を参照する。

## 反映方法

cmux のコマンドパレット（`Cmd+Shift+P`）から `reload_config` を実行する。
ghostty 側の設定と cmux 側の設定が同時に読み直される。
