# REQ-001 Progress

> **最終更新**: 2026-03-15

| Session | 状態 | 実装担当 | レビュー担当 | ブランチ |
|---------|------|----------|--------------|----------|
| Session 01: Canonical Repo And Godot Shell | completed | Claude / Codex | Codex / Claude | main |
| Session 02: Tooling And CI Baseline | completed | Claude / Codex | Codex / Claude | main |
| Session 03: Data Pipeline Foundation | completed | Claude / Codex | Codex / Claude | main |
| Session 04: Persistence And Platform Spike | completed | Claude / Codex | Codex / Claude | main |
| Session 05: Field Foundation | completed | Claude / Codex | Codex / Claude | main |
| Session 06: Battle Foundation | todo | Claude / Codex | Codex / Claude | 未定 |
| Session 07: Recruitment, Inventory, Ranch | todo | Claude / Codex | Codex / Claude | 未定 |
| Session 08: Breeding And Vertical Slice Assembly | todo | Claude / Codex | Codex / Claude | 未定 |

注記:

- Session 01〜03 は local verification まで完了
- 実行済み: `gdlint`, `gdformat --check`, `build_resources.py --check`, `build_resources.py`, Python unit tests, Godot headless smoke
- GdUnit4 は `tests/gdunit/` を canonical path として確保済み。実テスト追加時に plugin 本統合へ進む
- Session 04 で `SaveSystem` の manual / autosave / recovery baseline を実装し、`tools/qa/save_smoke.py` で検証
- Session 04 で `tools/qa/ios_export_smoke.py` を追加し、`export/ios/ios_export_smoke_report.*` に blocker report を出力
- Session 05 で `scenes/field/field_root.tscn` を追加し、開始村 → 塔前荒地の placeholder field foundation を実装
- Session 05 で `tools/qa/field_smoke.py` を追加し、移動 / 調査 / 遭遇導線を headless Godot で検証
