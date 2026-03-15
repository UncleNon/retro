# REQ-001 Foundation And Vertical Slice

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **source of truth**: [requirements/00_index.md](../requirements/00_index.md)

---

## 1. 背景 / 問題

現在の `Project RETRO` は、世界観、ゲームデザイン、UI、技術方針の要件は揃っているが、実装に着手するための **順序付きセッション計画** と **レビュー可能な単位** が未定義である。

さらに、以下の不確実性が残っている。

- 旧Unity系ディレクトリと新Godot方針が同居している
- Godot 4.4 / iOS / 保存まわりの技術リスクが高い
- データ駆動の量産フローを先に固めないと、400体 / 20+世界で破綻する
- 配合、作戦、情報密度などの「体験の芯」を、早い段階で検証する必要がある

この REQ は、**Phase 0〜1 を破綻しにくい順序で実行するための計画書** として使う。

---

## 2. 目的

- `docs/requirements/` を前提に、Phase 0〜1 をセッション単位へ分解する
- 高リスク要素を序盤のスパイクで判定できるようにする
- Claude 実装 / Codex レビューの handoff を標準化する
- Vertical Slice 到達までの受け入れ条件を明文化する

---

## 3. スコープ

### In Scope

- Godot 4.4 ベースの初期プロジェクト基盤
- 160×144 / 20×18 / 8×8 の表示・UI基準
- Phase 0〜1 に必要なツール、CI、保存、データ、バトル、配合、導入導線
- 5分〜15分遊べる Vertical Slice の完成
- 実装 / レビュー prompt pack

### Out Of Scope

- 20+世界 / 400体の本実装
- 本番アセット量産
- フルストーリー実装
- iCloud の本採用確定
- 英語対応
- App Store 提出物一式

---

## 4. 制約 / 既存設計との整合

### source of truth

- 要件本体: `docs/requirements/`
- 設計判断: `docs/adr/`
- 本計画: `docs/plans/REQ-001-foundation-and-vertical-slice.md`

### 守るべきADR

- `0001`: `docs/requirements/` が source of truth
- `0002`: `MVP` と `Initial Release` を混同しない
- `0005`: 主人公は無言
- `0007`: 世界間移動は `塔 + 生きた門`
- `0008`: `unique-my-monster`、不可逆性と救済、4コマンド + 作戦AI、既定値はレトロ
- `0009`: 村 / 塔 / 失踪 / 名前と所属の揺らぎを物語骨格にする

### 実装上の制約

- 旧Unity資産は即時破棄せず、**参照価値を確認するまで破壊しない**
- `project.godot` と新ディレクトリ構成を repo root に寄せる
- データはハードコードせず、CSV / Resource 駆動を前提にする
- 便利機能は許容するが、既定値で体験を壊さない

---

## 5. リスク登録簿

| ID | リスク | 影響 | 対応 |
|----|--------|------|------|
| R-01 | Godot iOS エクスポートが詰まる | TestFlight まで行けず開発判断が遅れる | Session 04 でスモークテストを先行実施 |
| R-02 | 保存 / 復帰まわりが不安定 | プレイ継続性が壊れる | ローカルセーブ、オートセーブ、異常終了復帰を早期に実装・検証 |
| R-03 | データ量産フロー未整備で 400体 / 20+世界が破綻 | 後工程で手作業が爆発する | Session 03 で CSV → Resource パイプラインを固める |
| R-04 | 旧Unityディレクトリと新Godot構成が混線 | 実装場所がぶれる | Session 01 で canonical path を確定し docs も同期 |
| R-05 | UIが現代化しすぎてレトロ感が消える | 体験の芯が崩れる | 4コマンド、数値UI、説明帯、既定値レトロをレビュー基準化 |
| R-06 | 配合支援が答えを出しすぎる | 発見の喜びが消える | 未発見レシピは傾向ヒント止まりに固定 |
| R-07 | ビットマップフォントの可読性不足 | 日本語UIが破綻する | Vertical Slice で会話、バトル、メニューの3場面を必ず評価 |
| R-08 | AIアセットの出自管理が甘い | 再生成不能 / 権利説明不能 | Session 02〜03 で台帳フォーマットを準備 |

---

## 6. 実装セッション計画

### Session 01: Canonical Repo And Godot Shell

- 目的:
  - repo root を Godot 向けの canonical 入口へ揃える
  - 旧Unity系との混線を止める
- 対象:
  - repo root
  - `docs/requirements/11_technical_architecture.md`
  - `docs/requirements/13_dev_process.md`
  - `tools/`
- 実施内容:
  - `project.godot` と最小ディレクトリ骨格を作る
  - `scenes/`, `scripts/`, `resources/`, `assets/`, `tests/`, `addons/`, `data/` の canonical path を確定
  - `tools/palette-remap` のルート運用を確定
  - `Assets/`, `retro-claude/`, `retro-codex/` の扱いを「参照用旧資産」に整理し、誤実装を防ぐ
- 受け入れ基準:
  - Godot で空プロジェクトが起動する
  - docs 上の canonical path が一貫する
  - 実装先が repo root の Godot 構成に固定される
- 依存:
  - なし

### Session 02: Tooling And CI Baseline

- 目的:
  - 最低限の品質ゲートを先に置く
- 対象:
  - `.github/workflows/`
  - `tests/`
  - `docs/requirements/12_cicd_and_qa.md`
- 実施内容:
  - `gdformat`, `gdlint`, `GdUnit4`, Git LFS の導入
  - headless 構文チェックとテストの CI 雛形
  - アセット / プロンプト / 生成メタデータの管理方針雛形
- 受け入れ基準:
  - ローカルで lint / format / テストが一通り動く
  - CI 雛形が存在し、Godot headless チェックが通る
- 依存:
  - Session 01

### Session 03: Data Pipeline Foundation

- 目的:
  - 量産前提のデータ駆動基盤を作る
- 対象:
  - `data/`
  - `resources/`
  - `addons/csv_importer/`
  - `docs/requirements/11_technical_architecture.md`
- 実施内容:
  - Monster / Skill / Item / World の最小 CSV スキーマを定義
  - CSV → Resource 変換の editor plugin か build script を作る
  - 参照整合性の検証を行う
- 受け入れ基準:
  - 10体分の最小モンスターデータが Resource 化できる
  - 壊れた参照を検出して fail できる
- 依存:
  - Session 01, 02

### Session 04: Persistence And Platform Spike

- 目的:
  - 保存と iOS 配布の可否を早期判定する
- 対象:
  - `scripts/save/`
  - `export/`
  - `docs/requirements/11_technical_architecture.md`
  - `docs/adr/`
- 実施内容:
  - ローカルセーブ、オートセーブ、異常終了復帰の最小実装
  - iOS エクスポートの smoke test
  - iCloud は採用条件だけを整理し、可否判定材料を残す
- 受け入れ基準:
  - セーブ / ロード / オートセーブが空アプリ上で動く
  - iOS export の可否と詰まりどころが文書化される
- 依存:
  - Session 01, 02

### Session 05: Field Foundation

- 目的:
  - 歩く、調べる、遭遇する、という冒険の基礎を作る
- 対象:
  - `scenes/field/`
  - `scripts/world/`
  - `assets/tilemaps/`
- 実施内容:
  - 160×144 表示、整数スケール、4方向移動、衝突、簡易イベント
  - 小さな村と塔周辺の仮マップ
  - エンカウント開始までの導線
- 受け入れ基準:
  - 村から塔周辺へ歩ける
  - 触れる / 調べる / 遭遇するが一連で動く
- 依存:
  - Session 01, 03, 04

### Session 06: Battle Foundation

- 目的:
  - 4コマンド + 作戦AI の戦闘文法を成立させる
- 対象:
  - `scenes/battle/`
  - `scripts/battle/`
  - `docs/requirements/02_game_design_core.md`
  - `docs/requirements/07_ui_ux.md`
- 実施内容:
  - `たたかう / さくせん / どうぐ / にげる`
  - 数値中心 HUD
  - 作戦AI
  - 物理 / 呪文 / 状態異常 / 行動順の最小実装
- 受け入れ基準:
  - 3v3 の基本戦闘が成立する
  - `めいれいさせろ` を含む作戦切り替えが機能する
  - 1戦のテンポが 20〜45秒程度に収まる
- 依存:
  - Session 03, 04, 05

### Session 07: Recruitment, Inventory, Ranch

- 目的:
  - 集める、選ぶ、預ける、という判断圧を実装する
- 対象:
  - `scripts/monster/`
  - `scripts/item/`
  - `scenes/menu/`
- 実施内容:
  - 勧誘用アイテムベースの加入
  - 携行20枠、パーティ3枠、牧場
  - お気に入りロック
  - 図鑑の最小導線
- 受け入れ基準:
  - 勧誘が成功 / 失敗する
  - 所持制限と牧場管理が体験上機能する
  - 大事なモンスターを誤消費しない
- 依存:
  - Session 03, 05, 06

### Session 08: Breeding And Vertical Slice Assembly

- 目的:
  - この企画の芯である配合中毒ループを成立させる
- 対象:
  - `scripts/monster/`
  - `scenes/menu/`
  - `data/`
  - `docs/requirements/03_world_and_story.md`
- 実施内容:
  - 家系配合、特殊配合、未知レシピヒント、継承、配合履歴
  - 10体規模の最小データ
  - 村 → 塔 → 最初の越境までの導入
- 受け入れ基準:
  - 1回の配合で「親が消えるが前進感がある」と評価できる
  - 5〜15分の Vertical Slice が成立する
  - 世界観、作戦AI、勧誘、配合が一本の流れとして体験できる
- 依存:
  - Session 03, 05, 06, 07

---

## 7. テスト要件

### 技術テスト

- project 起動
- headless lint / format / unit test
- save / load / autosave
- CSV → Resource 変換
- iOS export smoke

### 体験テスト

- プレイヤーが 10〜15分以内に 1体勧誘できる
- プレイヤーが 1回以上配合できる
- プレイヤーが 4コマンド戦闘を理解できる
- プレイヤーが「この個体は自分のものだ」と感じる導線がある
- 村 / 塔 / 禁忌 / 失踪の違和感が序盤で成立する

---

## 8. 受け入れ基準

### REQ-001 完了条件

- Godot プロジェクトの canonical 構成が repo root に定着している
- lint / format / test の最低限品質ゲートがある
- データ駆動で 10体分のモンスターを扱える
- 村探索、遭遇、戦闘、勧誘、牧場、配合まで一通り動く
- 5〜15分の Vertical Slice を他人に渡しても、企画の芯が伝わる

---

## 9. ロールバック / 移行

- 旧Unity系ディレクトリは、参照価値が完全に消えるまで削除しない
- iCloud は不採用になっても、ローカルセーブ構成を壊さない設計にする
- 配合UIや現代補助が体験を壊す場合、既定値をレトロ寄りへ戻せるよう feature flag 的に扱う
- 量産前に破綻が見えた場合、`Initial Release` ではなく `MVP` の基準で再評価する
