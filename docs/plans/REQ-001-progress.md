# REQ-001 Progress

> **最終更新**: 2026-03-16

| Session | 状態 | 実装担当 | レビュー担当 | ブランチ |
|---------|------|----------|--------------|----------|
| Session 01: Canonical Repo And Godot Shell | completed | Claude / Codex | Codex / Claude | main |
| Session 02: Tooling And CI Baseline | completed | Claude / Codex | Codex / Claude | main |
| Session 03: Data Pipeline Foundation | completed | Claude / Codex | Codex / Claude | main |
| Session 04: Persistence And Platform Spike | completed | Claude / Codex | Codex / Claude | main |
| Session 05: Field Foundation | completed | Claude / Codex | Codex / Claude | main |
| Session 06: Battle Foundation | completed | Claude / Codex | Codex / Claude | main |
| Session 07: Recruitment, Inventory, Ranch | completed | Claude / Codex | Codex / Claude | main |
| Session 08: Breeding And Vertical Slice Assembly | completed | Claude / Codex | Codex / Claude | main |

注記:

- Session 01〜03 は local verification まで完了
- 実行済み: `gdlint`, `gdformat --check`, `build_resources.py --check`, `build_resources.py`, Python unit tests, Godot headless smoke
- GdUnit4 は `tests/gdunit/` を canonical path とし、`test_breeding_service.gd`, `test_inventory_runtime.gd`, `test_monster_collection.gd`, `test_recruitment_service.gd` と `tools/qa/gdunit_smoke.py` まで定着済み。plugin 本体は未 vendor のため `scaffolded_plugin_missing` を許容している
- Session 04 で `SaveSystem` の manual / autosave / recovery baseline を実装し、`tools/qa/save_smoke.py` で検証
- Session 04 で `tools/qa/ios_export_smoke.py` を追加し、`export/ios/ios_export_smoke_report.*` に blocker report を出力
- Session 05 で `scenes/field/field_root.tscn` を追加し、開始村 → 塔前荒地の placeholder field foundation を実装
- Session 05 で `tools/qa/field_smoke.py` を追加し、移動 / 調査 / 遭遇導線を headless Godot で検証
- Session 06 で `scenes/battle/battle_root.tscn` と `scripts/battle/` を追加し、3v3 の 4コマンド戦闘、作戦 AI、`直接指示`、遭遇からの戦闘遷移を実装
- Session 06 で `tools/qa/battle_smoke.py` を追加し、戦術変更、直接指示、どうぐ消費、勝利遷移を headless Godot で検証
- Session 07 で `scripts/monster/`, `scripts/item/`, `scenes/menu/` に勧誘、所持20枠、パーティ3枠、牧場、ロック、図鑑入口の最小ランタイムを追加
- Session 07 で `scripts/main/app_root.gd` に autosave / runtime state / menu / battle-result recruit 連携を実装
- Session 07 で `tools/qa/session07_runtime_smoke.py` を追加し、inventory 上限、menu / ranch 操作、勧誘成功 / 失敗、autosave round-trip を headless Godot で検証
- Session 08 で `scripts/monster/breeding_service.gd`、`scripts/main/app_root.gd`、`scripts/world/field_root.gd` を拡張し、特殊配合、継承、配合履歴、レシピ既知/解決、門の listening -> awakened 進行を追加
- Session 08 で `tools/qa/session08_vertical_slice_smoke.py` を追加し、塔前 battle -> 配合 -> first crossing 解放 -> autosave reload の縦切りを headless Godot で検証
