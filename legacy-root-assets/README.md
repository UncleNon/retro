# Legacy Root Assets

このディレクトリは、repo root に残っていた旧 Unity 風 `Assets/` ツリーを
macOS の case-insensitive filesystem 上で `assets/` と衝突させないために
退避したもの。

現行の runtime asset root は `assets/`。
ここは参照専用で、現行実装の source of truth ではない。
