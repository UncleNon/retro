# Specs

`docs/specs/` は、`docs/requirements/` を実装可能な粒度へ落とした詳細設計を置く。

原則:

- 企画の正は `docs/requirements/` と `docs/adr/`
- `docs/specs/` は、その要件を数値、カラム、レイアウト、運用規則へ分解した実装補助
- 要件と矛盾する詳細設計は置かない
- 実装で設計判断が発生した場合は、必要に応じて `docs/adr/` へ戻す

まずは [00_index.md](./00_index.md) を起点に読む。

主要カテゴリ:

- `00_master_design_matrix.md`: 決めるべき設計面の母表
- `systems/`: 数式、確率、成長、戦闘、配合、経済、registry
- `story/`: 世界法則、勢力、伏線配置、開示順
- `content/`: モンスター、スキル、NPC、アイテム、テキスト、モチーフ
- `worlds/`: マップ寸法、座標、導線、施設配置、世界配分
- `art/`: style-bible、視覚言語、禁止事項
- `02_content_budget_and_definition_of_done.md`: コンテンツ量と完了条件
