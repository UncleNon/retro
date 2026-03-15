# Project RETRO

`Project RETRO` の canonical runtime root はこの repo root。

## Canonical Runtime Directories

- `project.godot`
- `scenes/`
- `scripts/`
- `resources/`
- `assets/`
- `addons/`
- `data/`
- `tests/`
- `tools/`

## Reference-Only Directories

以下は現行の実装先ではなく、参照専用の legacy / archive 扱い。

- `docs/`
- `retro-claude/`
- `retro-codex/`
- `legacy-root-assets/`

Godot から誤って import しないよう、reference-only directories には `.gdignore` を置く。

## Local QA Commands

- `python3 tools/qa/lint.py`
- `python3 tools/qa/format.py --check`
- `python3 tools/data/build_resources.py --check`
- `python3 tools/qa/test.py`
- `python3 tools/qa/godot_smoke.py`
- `python3 tools/qa/save_smoke.py`
- `python3 tools/qa/field_smoke.py`
- `python3 tools/qa/ios_export_smoke.py`
