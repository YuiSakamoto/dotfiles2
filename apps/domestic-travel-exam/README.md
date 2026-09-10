# 国内旅行業務取扱管理者 試験対策アプリ

ブラウザだけで動く、国内旅行業務取扱管理者試験の学習アプリ。
サーバー不要で、学習履歴は `localStorage` に保存する。

## 機能

- **模擬試験** — 実試験と同じ配分（旅行業法 25問 / 約款 25問 / 運賃・料金 12問 / 観光地理 26問）で出題。
  採点は終了後にまとめて行い、科目ごとの得点と「各科目 60% 以上」の合否を表示
- **分野別ドリル** — 1問ごとに正誤と解説を表示。10問 / 20問 / 全問から選択
- **弱点復習** — 直近で間違えた問題と正答率 50% 未満の問題を再出題
- **成績** — 分野別の正答率、模試・ドリルの履歴、学習記録のリセット
- キーボード操作（`1`〜`4` で選択、`Enter` で次へ、模試中は `←` `→` で移動）、ダークモード対応

## 収録問題

| 分野 | 問数 | ファイル |
| --- | ---: | --- |
| 旅行業法及びこれに基づく命令 | 35 | `src/data/questions/gyoho.ts` |
| 旅行業約款・運送約款・宿泊約款 | 36 | `src/data/questions/yakkan.ts` |
| 国内旅行実務（運賃・料金） | 20 | `src/data/questions/unchin.ts` |
| 国内旅行実務（観光地理） | 40 | `src/data/questions/chiri.ts` |

学習用に作成したオリジナル問題。法令・約款・運賃は改正されることがあるので、
最新の公式資料（観光庁、JR 旅客営業規則、標準旅行業約款など）もあわせて確認すること。

### 問題を追加する

各ファイルの配列に `q(連番, 問題文, [選択肢×4], 正答インデックス, 解説)` を追記するだけでよい。
`pnpm test` が ID の重複・選択肢数・正答インデックスの範囲・模試に必要な問数を検査する。

## 開発

```bash
pnpm install
pnpm dev        # 開発サーバー
pnpm check      # 型チェック + テスト
pnpm build      # dist/ に静的ファイルを出力
pnpm preview    # ビルド結果を確認
```

GitHub Pages などサブパスで配信する場合は `VITE_BASE_PATH=/repo-name/ pnpm build`。

## 構成

```
src/
  types.ts              分野・科目・配点・合格基準の定義
  data/questions/       問題バンク（分野ごとに1ファイル）
  lib/exam.ts           出題（模試・ドリル）と採点の純粋関数
  lib/storage.ts        学習履歴の永続化（localStorage、Result 型で失敗を返す）
  lib/random.ts         シャッフルとシード付き乱数
  components/           Home / Quiz / ResultView / Stats / ChoiceList
```

## 単独リポジトリへ切り出す

dotfiles2 の `apps/domestic-travel-exam/` から履歴ごと取り出す場合:

```bash
cd ~/dotfiles2
git subtree split --prefix=apps/domestic-travel-exam -b domestic-travel-exam-split
gh repo create domestic-travel-exam --private          # 空の新規リポを作る
git push git@github.com:<user>/domestic-travel-exam.git domestic-travel-exam-split:main
```

切り出した後は `.github/workflows/ci.yml` がそのまま CI として動く。
