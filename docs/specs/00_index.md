# 詳細設計インデックス

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **役割**: `docs/requirements/` と `docs/adr/` を、実装可能な粒度の数値・表・台帳へ接続する入口

---

## 1. Source Of Truth の関係

| レイヤ | 役割 | 正とする場所 |
|--------|------|--------------|
| ビジョン / 目標 /大方針 | 何を作るか、何を避けるか | `docs/requirements/` |
| 重要判断 | 分岐の理由、固定した設計判断 | `docs/adr/` |
| 詳細数値 / カラム / 台帳 | 実装、量産、レビューに使う細部 | `docs/specs/` |
| セッション分割 / handoff | 実装順、レビュー順、運用導線 | `docs/plans/`, `docs/prompts/` |

### 読む順番

1. `docs/requirements/00_index.md`
2. `docs/adr/`
3. この文書
4. 該当する `systems/`, `story/`, `content/`, `worlds/`, `art/`

---

## 2. 共通文書

| ファイル | 役割 |
|---------|------|
| [00_master_design_matrix.md](./00_master_design_matrix.md) | 決めるべき要素の棚卸しと状態管理 |
| [02_content_budget_and_definition_of_done.md](./02_content_budget_and_definition_of_done.md) | コンテンツ予算、Definition of Done、量産時の最低管理粒度 |

---

## 3. Systems

| ファイル | 役割 |
|---------|------|
| [systems/01_numeric_rules_and_master_schema.md](./systems/01_numeric_rules_and_master_schema.md) | ステータス、成長、遭遇、勧誘、配合、マスタースキーマの基礎数式 |
| [systems/02_battle_and_ai_rules.md](./systems/02_battle_and_ai_rules.md) | バトル状態遷移、命中、ダメージ、作戦AI、先制、不意打ち |
| [systems/03_breeding_mutation_and_lineage_rules.md](./systems/03_breeding_mutation_and_lineage_rules.md) | 家系、特殊配合、変異、血統履歴、継承圧 |
| [systems/04_economy_items_and_progression_rules.md](./systems/04_economy_items_and_progression_rules.md) | 経済、進行ゲート、店、報酬、金の沈み先 |
| [systems/05_id_naming_validation_and_registry_rules.md](./systems/05_id_naming_validation_and_registry_rules.md) | ID、slug、registry、命名と validation のルール |
| [systems/06_randomness_policy_and_probability_budgets.md](./systems/06_randomness_policy_and_probability_budgets.md) | 確率を許す場所、禁止する場所、確率帯、救済、streak 制御 |
| [systems/07_progress_flags_and_save_state_model.md](./systems/07_progress_flags_and_save_state_model.md) | 進行フラグ、門状態、NPC phase、セーブ構造 |

---

## 4. Story

| ファイル | 役割 |
|---------|------|
| [story/01_story_bible.md](./story/01_story_bible.md) | 物語、世界法則、塔、失踪、真実契約の canonical bible |
| [story/02_culture_faction_matrix.md](./story/02_culture_faction_matrix.md) | 世界ごとの文化、政治、宗教、勢力、タブー変奏 |
| [story/03_foreshadow_allocation_map.md](./story/03_foreshadow_allocation_map.md) | 50+伏線を媒体、世界、幕、回収時期へ割り当てる台帳 |
| [story/04_main_story_beats_and_world_sequence.md](./story/04_main_story_beats_and_world_sequence.md) | 20+世界を跨ぐ本編の進行骨格 |
| [story/05_real_incident_inspiration_policy.md](./story/05_real_incident_inspiration_policy.md) | 実在の神隠し譚、未解決事件、共同体伝承の抽象化ルール |

---

## 5. Content

| ファイル | 役割 |
|---------|------|
| [content/01_vertical_slice_monsters.md](./content/01_vertical_slice_monsters.md) | 序盤10体の詳細、数値、役割、プロンプト |
| [content/02_initial_skill_set.md](./content/02_initial_skill_set.md) | 初期スキル群、数値、AIタグ、役割分担 |
| [content/03_starting_village_npcs.md](./content/03_starting_village_npcs.md) | 開始村NPCの位置、役割、会話、伏線担務 |
| [content/04_initial_items_and_shops.md](./content/04_initial_items_and_shops.md) | 初期アイテム群、価格、店棚、レアリティ、用途 |
| [content/05_text_tone_and_lore_delivery_rules.md](./content/05_text_tone_and_lore_delivery_rules.md) | テキストの文体、無言主人公、媒体ごとの情報量、AIレビュー方針 |
| [content/06_monster_taxonomy_and_motif_rules.md](./content/06_monster_taxonomy_and_motif_rules.md) | 400体のモチーフ配分、変形法則、prompt metadata |

---

## 6. Worlds

| ファイル | 役割 |
|---------|------|
| [worlds/01_starting_village_layout.md](./worlds/01_starting_village_layout.md) | 開始村と塔前荒地の寸法、座標、導線 |
| [worlds/02_tower_outer_and_inner_spec.md](./worlds/02_tower_outer_and_inner_spec.md) | 塔外観、塔内部、門の提示、反応、演出段階 |
| [worlds/03_first_beyond_gate_world.md](./worlds/03_first_beyond_gate_world.md) | 最初の越境世界の設計とゲームプレイ役割 |
| [worlds/04_dungeon_template_catalog.md](./worlds/04_dungeon_template_catalog.md) | ダンジョン archetype、gimmick、長さ、禁止事項 |
| [worlds/05_world_catalog_and_budget.md](./worlds/05_world_catalog_and_budget.md) | 初回リリース20+世界の配分、役割、予算、解放順 |
| [worlds/06_settlement_layout_and_route_rules.md](./worlds/06_settlement_layout_and_route_rules.md) | 村、町、都市、聖域、市場、街道の数値規格と量産ルール |

---

## 7. Art

| ファイル | 役割 |
|---------|------|
| [art/01_style_bible.md](./art/01_style_bible.md) | 視覚哲学、パレット、アウトライン、UI、タイル、生成禁止事項 |

---

## 8. 実装前の最低確認

### バトルを触る前

- `systems/01`
- `systems/02`
- `systems/06`

### 配合や図鑑を触る前

- `systems/03`
- `content/01`
- `content/06`
- `systems/07`

### マップやNPCを触る前

- `worlds/01`
- `worlds/04`
- `worlds/06`
- `content/03`

### ストーリーやテキストを触る前

- `story/01`
- `story/02`
- `story/03`
- `story/04`
- `story/05`
- `content/05`

---

## 9. 今の設計で特に重要な横断原則

1. `unique-my-monster` を壊す仕様変更はしない
2. 確率は局所に閉じ込め、長期目標は決定論で支える
3. デフォルト体験はレトロ、快適化はオプション
4. 400体と20+世界は数だけでなく、役割と記憶に残る導線を持たせる
5. 物語は本編完結を守り、深層宇宙論は postgame に送る
