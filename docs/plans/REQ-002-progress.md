# REQ-002 Progress

> **最終更新**: 2026-03-16

| Session | 状態 | 実装担当 | レビュー担当 | ブランチ |
|---------|------|----------|--------------|----------|
| Session 01: Pipeline Recovery And Drift Freeze | completed | Claude / Codex | Codex / Claude | main |
| Session 02: Registry, Gate, And Clue Master Baseline | completed | Claude / Codex | Codex / Claude | main |
| Session 03: Economy, NPC, And Alias Contracts | completed | Claude / Codex | Codex / Claude | main |
| Session 04: Runtime Content Repository And Save Wiring | completed | Claude / Codex | Codex / Claude | main |
| Session 05: Data-Driven Starting Arc Field | completed | Claude / Codex | Codex / Claude | main |
| Session 06: Battle Foundation And Encounter Transition | completed | Claude / Codex | Codex / Claude | main |
| Session 07: Recruit, Inventory, Ranch, Shop, And Codex | completed | Claude / Codex | Codex / Claude | main |
| Session 08: Breeding, QA Hardening, And iOS Export Scaffolding | completed | Claude / Codex | Codex / Claude | main |

注記:

- `REQ-001 Session 01〜05` は foundation 完了として扱う
- 残 backlog は `REQ-001 Session 06〜08` をそのまま実行せず、drift を織り込んだ `REQ-002` の順序で進める
- Session 01 で `build_resources.py --check`, `tools/qa/test.py`, `build_resources.py` を通し、manifest と `resources/*` を current CSV と同期した
- repo-wide `tools/qa/lint.py` と `tools/qa/format.py --check` は `scripts/battle/*` 系の別作業差分で fail しており、Session 01 の scope 外として残した
- Session 02 で `master_index.csv`, `asset_registry.csv`, `localization_registry.csv`, `world_dependency_map.csv`, `clue_master.csv`, `progress_gate_master.csv` を materialize し、`npc/world/clue/gate` cross-reference validator を `build_resources.py` に追加した
- Session 02 で `python3 tools/data/build_resources.py --check`, `python3 tools/qa/test.py`, `python3 tools/data/build_resources.py` を通した。生成件数は `453 monsters / 349 skills / 62 items / 21 worlds / 90 encounters / 335 breeding`
- repo-wide `python3 tools/qa/lint.py` と `python3 tools/qa/format.py --check` は `scripts/battle/battle_root.gd` と `scripts/ui/menu_root.gd` の既存差分で fail しており、Session 02 の scope 外として残した
- Session 03 で `shop_master.csv`, `shop_inventory_master.csv`, `service_master.csv`, `shop_service_master.csv`, `loot_table_master.csv`, `loot_entry_master.csv`, `entity_alias_master.csv` を materialize し、`npc_master.shop_id/service_id` と `monster_master.loot_table_id` を alias → canonical に正規化する validator / resource build を追加した
- Session 03 で `python3 tools/data/build_resources.py --check`, `python3 tests/python/test_build_resources.py`, `python3 tools/data/build_resources.py` を通した。生成件数は `453 monsters / 349 skills / 62 items / 21 worlds / 90 encounters / 335 breeding / 250 npcs / 45 shops / 34 services / 453 loot_tables`
- repo-wide `python3 tools/qa/lint.py` と `python3 tools/qa/format.py --check` は `scripts/battle/battle_root.gd` と `scripts/ui/menu_root.gd` の既存差分で fail しており、Session 03 の scope 外として残した
- Session 04 で `ResourceRegistry` を runtime repository として確立し、`GameManager` / `AppRoot` boot から `monster / skill / item / world / encounter / npc / shop / service / loot_table / gate / clue / registry` lookup を引ける状態にした
- Session 04 で save schema を `0.3.0` に更新し、`gates -> nested gate state`, `clues -> nested clue state`, `npcs -> {phase}` を canonical にした。`npc_phases` は runtime/smoke compatibility mirror として保持する
- Session 04 で `gate / clue / npc_phases` の runtime snapshot と autosave 復帰 smoke を追加した。`python3 tools/qa/resource_registry_smoke.py`, `python3 tools/qa/session04_repository_runtime_smoke.py`, `python3 tools/qa/save_smoke.py`, `python3 tools/qa/runtime_smokes.py`, `python3 tools/qa/godot_smoke.py`, `python3 tools/data/build_resources.py --check`, `python3 tools/qa/test.py`, `python3 tools/qa/lint.py`, `python3 tools/qa/format.py --check` を通した
- Session 04 時点の build counts は `453 monsters / 349 skills / 62 items / 21 worlds / 90 encounters / 335 breeding / 250 npcs / 57 shops / 34 services / 453 loot_tables`
- Session 05 で `field_scene_master.csv`, `field_rect_master.csv`, `field_point_master.csv`, `field_trigger_master.csv`, `field_interaction_master.csv` を starting arc の canonical field source として接続し、`scripts/world/starting_village_layout.gd` と `field_root.gd` を data-driven runtime へ更新した
- Session 05 で `field_scene_master` を canonical field header として固定し、`ResourceRegistry`, `build_resources.py`, `master_index.csv`, `resource_registry_smoke.gd` の field repository 契約を `field_scenes` ベースへ同期した
- Session 05 で `python3 tools/data/build_resources.py --check`, `python3 tools/qa/lint.py`, `python3 tools/qa/format.py --check`, `python3 tools/qa/resource_registry_smoke.py`, `python3 tools/qa/field_smoke.py`, `python3 tools/qa/app_root_battle_transition_smoke.py`, `python3 tools/qa/app_root_facility_interaction_smoke.py`, `python3 tools/qa/session08_vertical_slice_smoke.py` を通した
- Session 06 で `scenes/battle/battle_root.tscn`, `scripts/battle/*`, `tests/gdscript/battle_smoke.gd`, `tools/qa/battle_smoke.py` を battle baseline として定着させ、field encounter から battle 起動・終了復帰・4コマンド・作戦 AI・直接指示を runtime に接続した
- Session 06 で `python3 tools/qa/format.py --check`, `python3 tools/qa/lint.py`, `python3 tools/qa/battle_smoke.py`, `python3 tools/qa/app_root_battle_transition_smoke.py`, `python3 tools/qa/field_smoke.py`, `python3 tools/qa/godot_smoke.py` を通した
- Session 07 で `scripts/item/inventory_runtime.gd`, `scripts/monster/monster_collection.gd`, `scripts/monster/recruitment_service.gd`, `scenes/menu/menu_root.tscn`, `scripts/ui/menu_root.gd`, `tests/gdscript/session07_runtime_smoke.gd`, `tools/qa/session07_runtime_smoke.py` を runtime contract として定着させ、recruit / carry 20 / party 3 / ranch / lock / shop / healer / codex/save loop を接続した
- Session 07 で `python3 tools/qa/format.py --check`, `python3 tools/qa/lint.py`, `python3 tools/qa/session07_runtime_smoke.py`, `python3 tools/qa/app_root_facility_interaction_smoke.py` を通した
- Session 08 で `tests/gdunit/test_breeding_service.gd`, `tests/gdunit/test_inventory_runtime.gd`, `tests/gdunit/test_monster_collection.gd`, `tests/gdunit/test_recruitment_service.gd` と `tools/qa/gdunit_smoke.py` を定着させ、`tests/gdunit/*.gd` を canonical な実 suite path として固定した
- Session 08 で `python3 tools/qa/session08_vertical_slice_smoke.py` を追加し、field encounter -> battle -> breeding -> gate awakening -> reload 復帰までの vertical slice runtime が headless Godot で通る状態にした
- Session 08 で `python3 tools/qa/runtime_smokes.py` に `session08_vertical_slice_smoke.py` を組み込み、repo 標準の runtime QA に vertical slice を昇格させた
- Session 08 で `export_presets.cfg` と `python3 tools/qa/ios_export_smoke.py` を同期し、iOS blocker を `export templates 未導入 / codesigning identity 未設定` に正規化した
- Session 08 で `python3 tools/qa/format.py --check`, `python3 tools/qa/lint.py`, `python3 tools/data/build_resources.py --check`, `python3 tools/qa/test.py`, `python3 tools/qa/gdunit_smoke.py`, `python3 tools/qa/resource_registry_smoke.py`, `python3 tools/qa/runtime_smokes.py`, `python3 tools/qa/session08_vertical_slice_smoke.py`, `python3 tools/qa/godot_smoke.py`, `python3 tools/qa/local_baseline.py --allow-missing`, `python3 tools/qa/ios_export_smoke.py` を通した
- Session 08 完了後の QA sync として `tools/qa/local_baseline.py` に `ios_export_smoke.py` を追加し、README と `12_cicd_and_qa.md` の baseline 記述を repo 実装へ合わせた
- Session 08 完了後の CI sync として `.github/workflows/ci.yml` に `python tools/qa/gdunit_smoke.py --allow-missing` と `python tools/qa/ios_export_smoke.py` を追加し、CI baseline と requirements の記述を一致させた
- 現在の残 blocker はローカル環境側の `Godot export templates / codesigning identity` が未充足である点のみ
- `REQ-002` の 8 session はすべて completed
