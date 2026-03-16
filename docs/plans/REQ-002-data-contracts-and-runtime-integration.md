# REQ-002 Data Contracts And Runtime Integration

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16
> **source of truth**: [requirements/00_index.md](../requirements/00_index.md)

---

## 1. 背景 / 問題

`REQ-001 Session 01〜05` により、repo root の canonical 化、最低限の QA、CSV → Resource 基盤、save baseline、開始村の field placeholder は成立した。

一方で、残 backlog は `Battle / Recruit / Ranch / Breeding` だけではない。実装直前の棚卸しで、以下の drift と未実体化が確認された。

- `tools/data/build_resources.py --check` が `encounter_table.weather=snow` を受け付けず fail する
- `tests/python/test_build_resources.py` の期待件数が古く、現行 CSV 行数と同期していない
- `resources/monsters`, `skills`, `encounters`, `breeding` が現行 CSV とズレた stale 生成物になっている
- `npc_master.csv` は存在するが、`shop_id`, `service_id`, `clue_ids` の受け先 master が未実体化
- gate / clue / registry / localization / asset provenance の契約は specs にあるが、repo 上の canonical file と validator が不足している
- `scenes/battle`, `scenes/menu`, `scripts/battle`, `scripts/monster`, `scripts/item`, `scripts/ui`, `scripts/npc` などが空で、runtime integration が未着手
- 開始村 field は requirements を表現する placeholder にはなっているが、依然として hardcoded layout / dialogue / inspect logic に依存している

この REQ は、上記の backlog を「実装可能な順序」に並べ替え、Vertical Slice 完成までの残作業を reviewable な session に分解する。

---

## 2. 目的

- data pipeline と生成物の trust を回復する
- shop / service / loot / gate / clue / registry / localization の canonical file を materialize する
- runtime boot を hardcoded shell から data-driven repository へ移す
- field → battle → recruit / inventory → breeding / codex の slice を、現行 data contract に基づいて接続する
- 未決ルールを実装可能な粒度で凍結し、後続 session の迷いを止める

---

## 3. スコープ

### In Scope

- `build_resources.py` と関連 test / CI の復旧
- registry / localization / gate / clue / economy 系 master の追加
- `npc_master.csv` / `monster_master.csv` / `world_master.csv` の参照整合性回復
- runtime content repository, save progress wiring, field data integration
- battle, recruit, inventory, ranch, shop / service, breeding, codex の Vertical Slice 実装
- GdUnit4 導入の着手、smoke / validator 拡張
- iOS export の preset / report / repo scaffolding

### Out Of Scope

- 21世界すべてを遊び切れる本編実装
- 本番アセット量産、全モンスター sprite / animation 完成
- postgame, 無限ダンジョン, 日替わりチャレンジ
- signed iOS 配布の完了
- iPad 最適化
- 正式タイトル決定

---

## 4. 制約 / 既存設計との整合

### source of truth

- 要件本体: `docs/requirements/`
- 設計判断: `docs/adr/`
- 現行 foundation plan: `docs/plans/REQ-001-foundation-and-vertical-slice.md`
- 残 backlog 実行計画: `docs/plans/REQ-002-data-contracts-and-runtime-integration.md`

### REQ-001 との関係

- `REQ-001 Session 01〜05` は完了済みの基盤として扱う
- `REQ-001 Session 06〜08` は、この REQ で見つかった precondition drift を織り込んだ形で再分解する
- 以後の実作業は、battle 以降であっても原則 `REQ-002` の session 順序に従う

### 守るべき制約

- canonical runtime root は repo root のまま維持する
- item / shop / service / reward の runtime 参照は `typed snake_case *_id` を正とする
- `registry_id` / legacy alias は import / validation で吸収しても、save / runtime の正規値には残さない
- 旧資産や reference-only directory を実装先へ戻さない
- convenience を足しても、既定値でレトロ体験を壊さない

---

## 5. 実装前に凍結する判断

| 項目 | 決定 |
|------|------|
| 時間システム | Vertical Slice では `歩数ベースの時間帯遷移` を採用する。real-time 連動は採用しない |
| 天候システム | canonical weather enum は `any / clear / rain / fog / snow` とする。Vertical Slice では zone 固定値のみ扱い、動的 weather simulation は後回し |
| 共生ボーナス | `party bonus` の明示システムは Vertical Slice から外す。現段階では encounter ecology / codex / lore 表現に留める |
| 無限ダンジョンの死亡ペナルティ / seed | 本 REQ の対象外。save schema では拡張余地だけ残し、runtime 実装は行わない |
| 小文字フォント | Vertical Slice では `8x8` と `16x16` のみを正とし、`4x8` は採用しない |
| デバイス範囲 | Vertical Slice は `iPhone portrait` を正とし、iPad layout は後回し |
| タイトル | repo / docs / build 上の作業名は当面 `Project RETRO` のまま進める |

---

## 6. 要件

### R-01 Data Pipeline Recovery

- `build_resources.py --check` が現行 CSV 一式に対して pass する
- Python unit test が fixed stale count ではなく、現行 canonical data と整合する形で pass する
- `resources/` と `data/generated/resource_manifest.json` が current CSV に対して deterministic に再生成できる

### R-02 Missing Masters And Registries

- `master_index.csv`, `asset_registry.csv`, `localization_registry.csv`, `world_dependency_map.csv` を実体化する
- `clue`, `gate`, `shop`, `service`, `loot`, `alias` の canonical master を追加する
- `npc_master`, `monster_master`, `world_master`, `item_master` の参照先は validator で解決できるようにする

### R-03 Runtime Content Repository

- app boot 時に manifest / master / resource を集約ロードする content repository を導入する
- runtime 側の lookup は直接 `res://resources/...` を散発参照せず、repository 経由を基本とする
- content load failure は早い段階で fail-fast できるようにする

### R-04 Data-Driven Field

- 開始村〜塔前の layout, NPC, inspect point, encounter, clue, gate reaction を hardcode から data-driven へ移す
- save progress と clue / gate / npc phase の更新が field 経由で走る

### R-05 Battle And Slice Systems

- 4コマンド battle, recruit, inventory, ranch, shop / service, breeding, codex を current data contract で接続する
- `20 carry / 3 party / ranch overflow / favorite lock` を守る
- 未発見 recipe は答えを出しすぎない hint UI に留める

### R-06 QA And Export Hardening

- CI / local QA が data drift, registry drift, localization drift, resource stale を検知できる
- GdUnit4 canonical path を placeholder で終わらせず、少なくとも runtime session で導入を始める
- iOS export は signed build 完了までは不要だが、`export_presets.cfg` と smoke report が repo に揃っている状態まで進める

---

## 7. 実装セッション計画

### Session 01: Pipeline Recovery And Drift Freeze

- 目的:
  - build / test / generated resource の trust を回復する
  - 後続 session を止めている未決ルールを凍結する
- 対象:
  - `tools/data/build_resources.py`
  - `tests/python/test_build_resources.py`
  - `data/generated/resource_manifest.json`
  - `resources/`
  - `docs/plans/REQ-002-data-contracts-and-runtime-integration.md`
- 実施内容:
  - `snow` を含む current weather contract に validator を合わせる
  - stale な fixed count test を現行 canonical data と整合する形へ更新する
  - resource 再生成を行い、manifest と `resources/*` の同期を回復する
  - current rule freeze を docs に反映する
- 受け入れ基準:
  - `python3 tools/data/build_resources.py --check` が通る
  - `python3 tools/qa/test.py` が通る
  - `resources/monsters`, `skills`, `encounters`, `breeding` の件数が CSV と整合する
- 依存:
  - なし

### Session 02: Registry, Gate, And Clue Master Baseline

- 目的:
  - 仕様だけ存在する台帳を repo 上の canonical file に落とす
- 対象:
  - `data/csv/`
  - `data/localization/`
  - `tools/data/`
  - `docs/specs/systems/05_id_naming_validation_and_registry_rules.md`
  - `docs/specs/systems/07_progress_flags_and_save_state_model.md`
  - `docs/specs/worlds/05_world_catalog_and_budget.md`
- 実施内容:
  - `master_index`, `asset_registry`, `localization_registry`, `world_dependency_map` を materialize する
  - `clue_master`, `progress_gate_master` を追加する
  - `world_master.gate_condition` の自由記述を参照可能な gate row へ正規化する
  - validator で registry / gate / clue の欠損を fail にする
- 受け入れ基準:
  - gate 21件分の条件が structured data として参照できる
  - NPC / world / clue / gate の cross-reference が validator で解決できる
  - registry 系 CSV が repo に存在し、最低限の row を持つ
- 依存:
  - Session 01

### Session 03: Economy, NPC, And Alias Contracts

- 目的:
  - NPC が持つ `shop_id`, `service_id`, `clue_ids` を実体へ接続する
- 対象:
  - `data/csv/`
  - `tools/data/`
  - `scripts/data/`
  - `docs/specs/systems/14_item_shop_loot_and_service_contract.md`
- 実施内容:
  - `shop_master`, `shop_inventory_master`, `service_master`, `shop_service_master`, `loot_table_master`, `loot_entry_master`, `entity_alias_master` を追加する
  - `SHOP-*`, `SHP-*`, `SVC-*`, `LUT-*` の legacy alias と canonical ID の対応を定義する
  - `npc_master` / `monster_master` の参照整合性 validator を追加する
  - 必要なら `NpcData` / `ShopData` / `ServiceData` / `LootData` の runtime resource 生成を導入する
- 受け入れ基準:
  - `npc_master.csv` に存在する `shop_id`, `service_id`, `clue_ids` がすべて実体へ解決する
  - `monster_master.csv` の `loot_table_id` がすべて解決する
  - alias policy が import / validation レイヤーで実装される
- 依存:
  - Session 01, 02

### Session 04: Runtime Content Repository And Save Wiring

- 目的:
  - runtime shell を content-driven boot へ切り替える
- 対象:
  - `scripts/core/`
  - `scripts/main/`
  - `scripts/data/`
  - `scripts/save/`
  - `tests/`
- 実施内容:
  - manifest / master / resource を束ねる content repository を追加する
  - `GameManager` / `AppRoot` から repository bootstrap を行う
  - save progress と `gate / clue / npc phase / codex` 参照を repository と接続する
  - repository failure の smoke / unit test を追加する
- 受け入れ基準:
  - app boot 時に content bootstrap が走る
  - repository 経由で monster / skill / item / world / encounter / npc / shop / gate / clue を引ける
  - save 側に gate / clue / npc phase を扱う最小 wiring がある
- 依存:
  - Session 02, 03

### Session 05: Data-Driven Starting Arc Field

- 目的:
  - 開始村 field を hardcoded placeholder から脱出させる
- 対象:
  - `scenes/field/`
  - `scripts/world/`
  - `data/csv/`
  - `resources/`
- 実施内容:
  - layout, inspect point, NPC spawn, encounter, clue, tower reaction を data から読む形へ置き換える
  - `field_root.gd` 内の story text / object logic の hardcode を最小化する
  - clue / gate progress の更新を save に反映する
- 受け入れ基準:
  - `python3 tools/qa/field_smoke.py` が通る
  - 開始村〜塔前導線が data-driven に維持される
  - 主要な story fact が GDScript の分岐に埋もれず data 側で追跡できる
- 依存:
  - Session 04

### Session 06: Battle Foundation And Encounter Transition

- 目的:
  - encounter data から battle を起動できる最小 loop を成立させる
- 対象:
  - `scenes/battle/`
  - `scripts/battle/`
  - `scripts/ui/`
  - `scripts/item/`
  - `tests/`
- 実施内容:
  - `たたかう / さくせん / どうぐ / にげる` の最小 battle UI を作る
  - encounter zone から enemy party を構築し、battle 開始 / 終了 / 復帰をつなぐ
  - skill / item / status / initiative の最小実装を data 駆動で行う
- 受け入れ基準:
  - field encounter から battle に遷移し、戦闘終了後に復帰できる
  - 4コマンド文法と作戦AIが成立している
  - smoke もしくは test で battle baseline を検証できる
- 依存:
  - Session 04, 05

### Session 07: Recruit, Inventory, Ranch, Shop, And Codex

- 目的:
  - 集める / 買う / 預ける / 調べる の周辺 loop を成立させる
- 対象:
  - `scenes/menu/`
  - `scripts/monster/`
  - `scripts/item/`
  - `scripts/npc/`
  - `scripts/ui/`
  - `tests/`
- 実施内容:
  - recruit item を使った加入判定
  - carry 20 / party 3 / ranch / favorite lock
  - merchant / healer / breeder などの shop / service UI
  - codex count / minimal detail / clue log 導線
- 受け入れ基準:
  - recruit 成否と inventory 消費が機能する
  - ranch 退避と favorite lock が機能する
  - shop / service 経由で item / restore / facility action を実行できる
  - codex / clue の更新が save と整合する
- 依存:
  - Session 03, 04, 06

### Session 08: Breeding, QA Hardening, And iOS Export Scaffolding

- 目的:
  - Vertical Slice の芯を閉じ、後戻りしにくい QA と export scaffolding を置く
- 対象:
  - `scripts/monster/`
  - `scenes/menu/`
  - `tests/gdunit/`
  - `tools/qa/`
  - `export/`
- 実施内容:
  - breed rule に基づく child resolution, hint UI, recipe / mutation / codex 更新
  - GdUnit4 の実 test 導入
  - stale resource / registry / localization drift を検出する QA を追加
  - `export_presets.cfg` と iOS smoke report を repo ベースで前進させる
- 受け入れ基準:
  - breeding loop が runtime で成立する
  - QA に data / registry / localization / runtime の複数系統チェックがある
  - iOS export blocker が「preset 不在」以降の段階まで進む
- 依存:
  - Session 03, 04, 06, 07

---

## 8. テスト要件

- 毎 session 共通:
  - `python3 tools/qa/lint.py`
  - `python3 tools/qa/format.py --check`
  - `python3 tools/data/build_resources.py --check`
  - `python3 tools/qa/test.py`
- Session 04 以降:
  - `python3 tools/qa/godot_smoke.py`
  - 追加した runtime / repository test
- Session 05 以降:
  - `python3 tools/qa/field_smoke.py`
- Session 06 以降:
  - battle smoke または同等の headless runtime check
- Session 08:
  - GdUnit4 test
  - `python3 tools/qa/ios_export_smoke.py`

---

## 9. 受け入れ基準

- current CSV, generated resources, manifest, tests, CI が一致している
- specs 上の必須 registry / gate / clue / economy contract が repo に materialize されている
- runtime boot, field, battle, recruit, inventory, ranch, breeding, codex が current data contract に接続されている
- save が gate / clue / npc / codex / inventory / party / ranch を破綻なく保持する
- iOS export は signed release 未満でも、repo に必要な preset / report / QA 足場が揃っている

---

## 10. ロールバック / 移行

- legacy alias は import / validation でのみ吸収し、save / runtime へ持ち込まない
- `world_master.gate_condition` などの自由記述列は、移行期間は残しても authority は structured master 側へ寄せる
- stale resource は再生成で置き換える。手編集を前提にしない
- 既存 `REQ-001` は foundation の履歴として残すが、残 backlog 実行時の一次計画は本 REQ を優先する
