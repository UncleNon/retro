# REQ-001 Claude Implementation Prompts

## Session 01

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-001 Session 01: Canonical Repo And Godot Shell` を実装して。  
source of truth は `docs/plans/REQ-001-foundation-and-vertical-slice.md`。  
目的は、repo root を Godot 4.4 ベースの canonical 入口に揃え、今後の実装先を固定すること。`project.godot`、基本ディレクトリ骨格、`tools/` の canonical path、旧Unity系ディレクトリの扱い整理、関連ドキュメント同期まで含める。  
受け入れ基準を満たす最小差分で進め、無関係な機能実装には入らないこと。push はしない。

## Session 02

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-001 Session 02: Tooling And CI Baseline` を実装して。  
対象は lint / format / test / Git LFS / CI 雛形。Godot headless チェック、`gdformat`、`gdlint`、`GdUnit4` を中心に、ローカルと CI の最低限品質ゲートを揃える。  
要件・ADRとズレる場合は source-of-truth 文書を同時更新する。push はしない。

## Session 03

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-001 Session 03: Data Pipeline Foundation` を実装して。  
CSV → Resource パイプライン、最小スキーマ、参照整合性チェック、10体分のサンプルデータまでを対象にする。  
ハードコードを避け、後続の 400体量産に耐える前提で設計する。push はしない。

## Session 04

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-001 Session 04: Persistence And Platform Spike` を実装して。  
ローカルセーブ、オートセーブ、異常終了復帰の最小成立を優先し、Godot iOS export の smoke test と詰まりどころの記録まで行う。  
iCloud は本採用しなくてよい。採否判断に必要な材料を残すこと。push はしない。

## Session 05

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-001 Session 05: Field Foundation` を実装して。  
160×144 の表示、整数スケール、4方向移動、衝突、簡易イベント、村と塔周辺の仮マップ、遭遇開始導線までを作る。  
世界観は `小さな村 + 塔 + 禁忌` の初期印象が出る最小構成に留める。push はしない。

## Session 06

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-001 Session 06: Battle Foundation` を実装して。  
4コマンド (`たたかう / さくせん / どうぐ / にげる`)、数値中心 HUD、作戦AI、物理 / 呪文 / 状態異常の最小成立を対象にする。  
「普段は高速、難所では介入可能」のリズムを壊さないこと。push はしない。

## Session 07

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-001 Session 07: Recruitment, Inventory, Ranch` を実装して。  
勧誘用アイテムベースの加入、携行20枠、パーティ3枠、牧場、お気に入りロック、最小図鑑導線までを作る。  
数値を全部見せるのではなく、手応え文言で勧誘を返す方針を守る。push はしない。

## Session 08

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-001 Session 08: Breeding And Vertical Slice Assembly` を実装して。  
家系配合、特殊配合、未知レシピヒント、継承、配合履歴、村→塔→最初の越境までの導入、10体分データをまとめ、5〜15分の Vertical Slice に仕上げる。  
発見の喜びを殺す完全答え合わせ UI は標準で出さないこと。push はしない。
