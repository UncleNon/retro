# GdUnit Smoke Report

- Checked At (UTC): `2026-03-16T05:07:54.954202+00:00`
- Status: `scaffolded_plugin_missing`
- Suites: `4`

## Blockers

- `addons/gdUnit4` plugin が未導入

## Warnings

- canonical suite は repo に追加済みだが、plugin 未導入のため未実行

## Suites

- `tests/gdunit/test_breeding_service.gd`
- `tests/gdunit/test_inventory_runtime.gd`
- `tests/gdunit/test_monster_collection.gd`
- `tests/gdunit/test_recruitment_service.gd`

## Tooling

- Godot Found: `True`
- GdUnit Plugin Present: `False`
- GdUnit Runner Present: `False`
- Runner Attempted: `False`

## Next Steps

- local Godot version と互換のある GdUnit4 plugin を `addons/gdUnit4` に導入する
- plugin 導入後に `python3 tools/qa/gdunit_smoke.py` を再実行する
