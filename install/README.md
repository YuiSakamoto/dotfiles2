# install/

パッケージインストール関連のファイル置き場。

## ファイル

| ファイル | 用途 |
| --- | --- |
| `Brewfile` | macOS 用。`brew bundle --file=install/Brewfile` で使用。 |
| `apt-packages.txt` | Debian/Ubuntu/WSL 用。`#` コメントと空行を無視してパッケージ名を読む。 |
| `common-post.sh` | OS共通の後処理。starship / mise / peco / fisher など、パッケージマネージャにない or 古いものを公式ルートで導入する。 |

## 方針

- **macOS は brew / Linux は apt** が原則。
- **apt に載っていない or 古い**ものだけ `common-post.sh` で個別導入。ここが増えすぎたら chezmoi 等への移行を検討する。
- GUI/フォント/IDE などは各OS固有なので、共通管理は CLI に絞る。

## apt-packages.txt を編集したら

```bash
./setup.sh install   # Linux側の取り込み
```

## Brewfile を編集したら

```bash
./setup.sh install   # macOS側の取り込み
# もしくは
brew bundle --file=install/Brewfile
```
