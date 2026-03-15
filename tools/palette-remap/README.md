# Palette Remap

`tools/palette-remap/` は、パレット変換スクリプトの canonical path。

- `master_palette.hex`: 基準パレット
- `palette_remap.py`: 変換スクリプト

由来:

- 元データは `retro-claude/tools/palette-remap/` にあった参照用資産
- Session 01 で repo root canonical path へ複製した

運用ルール:

- 今後の自動処理やアセット生成パイプラインは、このパスを参照する
- `retro-claude/` 側は参照専用として保持し、実装の正にはしない
