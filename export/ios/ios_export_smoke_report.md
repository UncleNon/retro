# iOS Export Smoke Report

- Checked At (UTC): `2026-03-15T12:20:42.375609+00:00`
- Status: `blocked`

## Blockers

- Godot export templates が未導入
- `export_presets.cfg` が未作成
- codesigning identity が未設定

## Warnings

- ローカル検証は Godot 4.6.1 editor 上で実施

## Tooling

- Godot: `4.6.1.stable.official.14d19694e`
- Xcode: `Xcode 26.3
Build version 17C529`
- Export Templates Present: `False`
- export_presets.cfg Present: `False`
- iOS Preset Present: `False`
- Codesigning Identities: `0`

## Next Steps

- Godot export templates をインストールする
- `export_presets.cfg` に iOS preset を追加する
- Apple Developer Program の署名証明書 / Provisioning Profile を用意する
- iCloud は local save loop が安定した後に別スパイクで評価する
