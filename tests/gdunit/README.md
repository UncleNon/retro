# GdUnit4 Tests

`tests/gdunit/` は Project RETRO の canonical な GdUnit4 suite 置き場。

現時点で含む suite:

- `test_breeding_service.gd`
- `test_inventory_runtime.gd`
- `test_monster_collection.gd`
- `test_recruitment_service.gd`

ローカルの最低確認は `python3 tools/qa/gdunit_smoke.py`。

- repo 上の suite を列挙する
- `test_*.gd` と `*_test.gd` を候補として走査する
- `extends GdUnitTestSuite` と `func test_*` を持つ実 suite だけを数える
- `addons/gdUnit4` plugin と `runtest.sh` の有無を確認する
- 実行可能なら suite を走らせ、report を `export/gdunit/` に出力する

2026-03-16 時点の blocker:

- repo には `addons/gdUnit4` plugin がまだ入っていない
- そのため Session 08 では `tests/gdunit/` を canonical path として維持しつつ、runtime の成立確認は `tools/qa/session08_vertical_slice_smoke.py` を正としている
