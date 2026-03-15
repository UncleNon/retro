> **Archived**: このディレクトリは旧設計のアーカイブ。現行の source of truth は `docs/requirements/`。

# 低解像度モンスター育成RPG 要件定義書

このフォルダは、要件定義書を Markdown 運用しやすい形に分割したもの。

- フル版: `retro_md_package/requirements_full.md`
- 分割版: `retro_md_package/` 以下の章ごとの `.md`
- 原本版数: Version 0.9 / 2026-03-15

## 章一覧
- [目次](./retro_md_package/00_index.md)
- [1. 結論サマリー](./retro_md_package/01_conclusion_summary.md)
- [2. 調査結果: 何を再現すべきか](./retro_md_package/02_research_what_to_recreate.md)
- [3. 製品コンセプトとゲーム全体像](./retro_md_package/03_product_concept.md)
- [4. コアシステム要件](./retro_md_package/04_core_systems.md)
- [5. データ要件とマスタ設計](./retro_md_package/05_data_and_master_design.md)
- [6. コンテンツ設計案（マップ / ストーリー / モンスター / NPC / ショップ）](./retro_md_package/06_content_design.md)
- [7. UI / UX 要件](./retro_md_package/07_ui_ux.md)
- [8. アート / 音 / 素材の制作要件](./retro_md_package/08_art_audio_assets.md)
- [9. AI生成ツール評価と一貫性維持ワークフロー](./retro_md_package/09_ai_tooling_and_consistency.md)
- [10. 技術構成 / 実装方針 / 保存設計](./retro_md_package/10_technical_architecture.md)
- [11. 進行計画 / 体制 / QA / リスク管理](./retro_md_package/11_production_qa_risks.md)
- [付録A. サンプルデータ](./retro_md_package/appendix_a_sample_data.md)
- [付録B. プロンプト雛形](./retro_md_package/appendix_b_prompt_templates.md)
- [付録C. 参照ソース一覧](./retro_md_package/appendix_c_sources.md)

## 運用メモ
- 今後の追記は Markdown を正本にする。
- マスターデータは別途 `data/` に JSON / CSV で切り出す。
- 画像生成プロンプトは付録Bを起点に、キャラ・モンスター・タイルセット単位でさらに分割する。
