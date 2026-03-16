# REQ-003 Act I Field Expansion And World Routing

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16
> **source of truth**: [requirements/00_index.md](../requirements/00_index.md)

---

## 1. 背景 / 問題

`REQ-002` により、starting arc の battle / recruit / inventory / breeding / save baseline は成立した。  
一方で、runtime の field traversal はまだ `FIELD-VIL-001` 1枚にほぼ固定されている。

- `field_scene_master.csv` は実質 1 field row のみで、21世界の world data が runtime に接続されていない
- `field_root.gd` は generic な layout loader を持ちながら、起動時は default field 前提で固定されている
- `app_root.gd` の save wiring は `worlds["starting_village"]` にのみ snapshot を格納しており、複数 field を跨ぐと復帰位置が壊れる
- `W-001` 以降の NPC / shop / service / encounter / clue data は master 側に存在するが、実際に歩ける map routing がない
- 最初の門は `開いた` までは成立しているが、`越えた` という runtime 体験がまだ無い

この REQ は、Act I の world traversal を始めるために、単一 field 前提を壊し、`門 -> 次フィールド -> 戻り` の最小 world routing を canonical contract として固定する。

---

## 2. 目的

- runtime/save を `arbitrary field_id` 前提へ一般化する
- `starting village -> first beyond gate field -> return` の往復を data-driven に成立させる
- `W-001` の最初の hub / route pair を、既存 world/NPC/shop/service/clue data に接続する
- 後続の `REQ-004` 以降で会話密度や gate 判定を増やしても崩れない field routing contract を置く

---

## 3. スコープ

### In Scope

- field interaction からの map transition contract
- `field_id` ごとの save / restore / autosave 復帰
- `FIELD-VIL-001` から `W-001` への最小遷移
- `W-001` の最小 playable field 1枚
- world transition を検証する headless smoke の追加

### Out Of Scope

- `W-001` 全マップの完全再現
- generic gate evaluation の全面導入
- 20人規模の NPC phase dialogue routing
- `W-002` 以降の本格 traversal
- arena / gatekeeper / rank unlock runtime

---

## 4. 制約 / 既存設計との整合

### source of truth

- world topology: `docs/specs/worlds/03_first_beyond_gate_world.md`
- route budget: `docs/specs/worlds/09_act_i_world_sheets.md`
- secret / route pair blueprint: `docs/specs/worlds/14_starting_arc_map_and_secret_blueprints.md`
- current runtime baseline: `docs/plans/REQ-002-data-contracts-and-runtime-integration.md`

### 守るべき制約

- field data は `field_scene / rect / point / trigger / interaction` master に寄せる
- transition の条件分岐を GDScript の hardcode に戻しすぎない
- `GATE-001` の現行 special case は温存してよいが、save 契約は field 固定名から脱却する
- 戦闘や施設 runtime を壊さず、field traversal の最小差分で進める
- default の体験はレトロで、`A で門に触れる` 文法を優先する

---

## 5. 要件

### R-01 Multi-Field Runtime Baseline

- `field_root` は `field_id` 指定で layout を切り替えられる
- field snapshot は `field_id` を保持し、異なる field を restore できる
- `app_root` は `player.current_field_id` と `worlds[field_id]` を使って save/load する

### R-02 Transition Contract

- field interaction から `target_field_id / target_point_id / target_facing` を指定できる
- transition 実行時に現在 field snapshot を保存し、遷移先 field を load する
- 任意の transition message を arrival 後に表示できる

### R-03 First Beyond Gate Slice

- `FIELD-VIL-001` から `W-001` の最小 field へ遷移できる
- `W-001` field には最低限 `inspect / NPC talk / facility / encounter / return gate` がある
- `W-001` は既存の `npc_master / shop_master / service_master / zone_master / clue_master` と整合する

### R-04 QA

- field transition の smoke がある
- autosave 復帰で current field が保持される
- 既存の `field_smoke`, `session07_runtime_smoke`, `session08_vertical_slice_smoke` を壊さない

---

## 6. 実装セッション計画

### Session 01: Multi-Field Transition Baseline

- 目的:
  - single-field 前提を壊し、最初の越境を runtime で通す
- 対象:
  - `scripts/world/field_root.gd`
  - `scripts/world/starting_village_layout.gd`
  - `scripts/main/app_root.gd`
  - `data/csv/field_scene_master.csv`
  - `data/csv/field_rect_master.csv`
  - `data/csv/field_point_master.csv`
  - `data/csv/field_interaction_master.csv`
  - `tools/data/build_resources.py`
  - `tests/gdscript/`
- 実施内容:
  - field interaction に transition payload を追加する
  - field load/restore/save を `field_id` 基準へ更新する
  - `FIELD-W01-001` を追加し、`FIELD-VIL-001 -> FIELD-W01-001 -> FIELD-VIL-001` を往復できるようにする
  - field transition smoke を追加する
- 受け入れ基準:
  - 塔前から最初の門を越えて `W-001` field へ移動できる
  - return transition で開始村へ戻れる
  - autosave reload 後に current field が維持される
  - `python3 tools/qa/field_smoke.py` と新規 transition smoke が通る
- 依存:
  - `REQ-002` 完了

### Session 02: W-001 Hub And Facility Pass

- 目的:
  - 名伏せの野の最小 hub を play loop に接続する
- 対象:
  - `data/csv/field_*`
  - `scripts/world/`
  - `tests/gdscript/`
- 実施内容:
  - `NPC-W01-001..010` のうち P0 会話導線を field data に載せる
  - merchant / healer / clue routing を `W-001` 側へ接続する
  - objective progression を field-generic にする
- 受け入れ基準:
  - `W-001` で clue / merchant / healer / talk の最小 loop が動く
  - hardcoded W-001 文言を app_root へ持ち込まない
- 依存:
  - Session 01

### Session 03: Route Pair And Return-Ready Save Contract

- 目的:
  - `safe route / danger route / return flow` の最小 world loop を作る
- 対象:
  - `data/csv/field_*`
  - `scripts/world/`
  - `tests/gdscript/`
- 実施内容:
  - `W-001` 内に route pair を追加する
  - encounter / clue / return gate の往復を強化する
  - field save snapshot の互換確認と smoke を増やす
- 受け入れ基準:
  - `W-001` 内で 1 つ以上の route choice が発生する
  - field save / restore が 2 field 以上で安定する
- 依存:
  - Session 02

---

## 7. テスト要件

- Session 01:
  - `python3 tools/qa/format.py --check`
  - `python3 tools/qa/lint.py`
  - `python3 tools/data/build_resources.py --check`
  - `python3 tools/qa/field_smoke.py`
  - `python3 tools/qa/session07_runtime_smoke.py`
  - `python3 tools/qa/session08_vertical_slice_smoke.py`
  - `python3 tools/qa/field_transition_smoke.py`

---

## 8. 受け入れ基準

1. 最初の門が `開いた` だけでなく `越えられる`
2. field traversal が `worlds["starting_village"]` 固定ではない
3. `W-001` の既存 master data を使った最初の hub/route 断片が遊べる
4. current field の autosave/reload が壊れない

---

## 9. ロールバック / 移行

- transition contract が不安定なら、`FIELD-W01-001` row と transition interaction を一時的に外し、starting village 単体 slice へ戻せるようにする
- save 互換は `player.current_field_id` 欠損時に `FIELD-VIL-001` へフォールバックする
- 既存 `GATE-001` special case はこの REQ では消さない。一般化は後続 REQ に分離する
