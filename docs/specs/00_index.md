# 詳細設計インデックス

> **ステータス**: Draft v1.1
> **最終更新**: 2026-03-16
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
| [systems/08_enemy_ai_and_encounter_design.md](./systems/08_enemy_ai_and_encounter_design.md) | 敵AI 8類型、決定木、ボスフェーズ、先制/不意打ち、敵スケーリング |
| [systems/09_status_ailments_and_field_effects.md](./systems/09_status_ailments_and_field_effects.md) | 12状態異常、持続、耐性式、フィールド効果、地形ハザード |
| [systems/10_skill_taxonomy_and_full_initial_catalog.md](./systems/10_skill_taxonomy_and_full_initial_catalog.md) | スキル体系、MP計算式、進化ライン、60-80スキルカタログ、trait |
| [systems/11_protagonist_party_and_ranch_rules.md](./systems/11_protagonist_party_and_ranch_rules.md) | 主人公初期状態、パーティ3枠、牧場38体、忠誠度、性格9種 |
| [systems/12_ui_screen_catalog_and_input_rules.md](./systems/12_ui_screen_catalog_and_input_rules.md) | 全画面レイアウト、入力体系、仮想パッド、テキスト速度、設定 |
| [systems/13_boss_gatekeeper_and_field_modifier_rules.md](./systems/13_boss_gatekeeper_and_field_modifier_rules.md) | ボス分類、phase、telegraph、場効果、門守戦の規格 |
| [systems/14_item_shop_loot_and_service_contract.md](./systems/14_item_shop_loot_and_service_contract.md) | item / shop / loot / service / reward の canonical 契約 |
| [systems/15_save_migration_and_compatibility_policy.md](./systems/15_save_migration_and_compatibility_policy.md) | schema version、migration、backup、rollback、互換運用 |
| [systems/16_monster_canonical_package_and_pipeline.md](./systems/16_monster_canonical_package_and_pipeline.md) | モンスター1体を concept / art / data / asset で束ねる canonical package |
| [systems/17_encounter_authoring_and_balance_sandbox.md](./systems/17_encounter_authoring_and_balance_sandbox.md) | zone / pack / rarity / scouting pressure / route pair を扱う遭遇設計 sandbox |
| [systems/18_playtest_measurement_and_smoke_contract.md](./systems/18_playtest_measurement_and_smoke_contract.md) | save/export/readability の smoke と battle/recruit/breed の体感計測契約 |
| [systems/20_battle_implementation_blueprint.md](./systems/20_battle_implementation_blueprint.md) | バトルのステートマシン、ターン解決、AI、UI接続のGodot実装設計 |
| [systems/21_breeding_implementation_blueprint.md](./systems/21_breeding_implementation_blueprint.md) | 配合のレシピ判定、継承、変異、UIフロー、永続化のGodot実装設計 |

---

## 4. Story

| ファイル | 役割 |
|---------|------|
| [story/01_story_bible.md](./story/01_story_bible.md) | 物語、世界法則、塔、失踪、真実契約の canonical bible |
| [story/02_culture_faction_matrix.md](./story/02_culture_faction_matrix.md) | 世界ごとの文化、政治、宗教、勢力、タブー変奏 |
| [story/03_foreshadow_allocation_map.md](./story/03_foreshadow_allocation_map.md) | 50+伏線を媒体、世界、幕、回収時期へ割り当てる台帳 |
| [story/04_main_story_beats_and_world_sequence.md](./story/04_main_story_beats_and_world_sequence.md) | 20+世界を跨ぐ本編の進行骨格 |
| [story/05_real_incident_inspiration_policy.md](./story/05_real_incident_inspiration_policy.md) | 実在の神隠し譚、未解決事件、共同体伝承の抽象化ルール |
| [story/06_millennial_geopolitics_and_personages.md](./story/06_millennial_geopolitics_and_personages.md) | 大分裂以後1000年の政治史、国家形成、事件、傑物、現行勢力図 |
| [story/07_starting_village_incident_and_silence_matrix.md](./story/07_starting_village_incident_and_silence_matrix.md) | 開始村9件失踪の内訳、沈黙回路、主人公年齢との接続 |
| [story/08_historical_texture_research_ingestion.md](./story/08_historical_texture_research_ingestion.md) | 実在史料の構造を設定へ抽象化して入れるための research-to-lore 変換規則 |
| [story/09_silence_economy_and_powerbrokers.md](./story/09_silence_economy_and_powerbrokers.md) | 勢力ごとの沈黙、口止め、金、物流、改竄実務の運用具体 |
| [story/10_starting_arc_engagement_playbook.md](./story/10_starting_arc_engagement_playbook.md) | 開始村〜`W-005` を飽きさせず引っ張るための問い設計、帰村ショック、人物泥設計 |
| [story/11_session_pacing_and_curiosity_contract.md](./story/11_session_pacing_and_curiosity_contract.md) | `5分 / 15分 / 60分` の遊び単位、報酬拍動、ノート価値のある情報密度の契約 |
| [story/12_starting_arc_relationship_and_faction_map.md](./story/12_starting_arc_relationship_and_faction_map.md) | 開始村〜`W-005` の関係図、勢力圧、伏線担務を同じ圧力線で読むための地図 |
| [story/13_act_ii_bridge_relationship_and_faction_map.md](./story/13_act_ii_bridge_relationship_and_faction_map.md) | `W-006〜W-007` の local front, relation edge, clue carrier を Act II の橋渡し層として固定する |
| [story/14_cross_system_echo_and_discovery_lattice.md](./story/14_cross_system_echo_and_discovery_lattice.md) | monster, 人物, 物, map prop, 婉曲語にまたがる discovery echo の配置台帳 |

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
| [content/07_starting_village_full_npc_catalog.md](./content/07_starting_village_full_npc_catalog.md) | 開始村20人NPC完全カタログ（座標、巡回、会話フェーズ、伏線担務） |
| [content/08_starting_region_ecology_and_monster_web.md](./content/08_starting_region_ecology_and_monster_web.md) | 開始村〜`W-005` の生態系、食物連鎖、違法利用、地形修正案、怪物 draft |
| [content/09_act_i_ii_monster_expansion_and_discovery_pack.md](./content/09_act_i_ii_monster_expansion_and_discovery_pack.md) | `W-002`〜`W-007` 追加19体の runtime roster、hidden discovery、配合導線 |
| [content/10_vertical_slice_codex_entries.md](./content/10_vertical_slice_codex_entries.md) | 序盤10体の図鑑文、説明帯、生態メモ |
| [content/11_item_history_and_monster_resonance_matrix.md](./content/11_item_history_and_monster_resonance_matrix.md) | item を歴史事件、勢力欲、monster ecology、店棚、hidden payoff へ接続する matrix |
| [content/12_item_provenance_inspect_and_shop_text_pack.md](./content/12_item_provenance_inspect_and_shop_text_pack.md) | provenance item の inspect 文、repeat 差分、棚帯、売り手台詞を固定する text pack |
| [content/13_act_i_ii_item_text_routing_ledger.md](./content/13_act_i_ii_item_text_routing_ledger.md) | `W-002`〜`W-007` の item text を point / interaction / ambient へ結ぶ routing 台帳 |

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
| [worlds/07_world_sheet_contract.md](./worlds/07_world_sheet_contract.md) | 1世界を concrete detail へ落とすための canonical world sheet schema |
| [worlds/08_world_sheet_template_and_variation_rules.md](./worlds/08_world_sheet_template_and_variation_rules.md) | 21世界を同じ密度で量産するための template と variation 軸 |
| [worlds/09_act_i_world_sheets.md](./worlds/09_act_i_world_sheets.md) | Act I 4世界の concrete world sheet 集 |
| [worlds/10_act_ii_world_sheets.md](./worlds/10_act_ii_world_sheets.md) | Act II 5世界の concrete world sheet 集 |
| [worlds/11_act_iii_world_sheets.md](./worlds/11_act_iii_world_sheets.md) | Act III 5世界の concrete world sheet 集 |
| [worlds/12_act_iv_world_sheets.md](./worlds/12_act_iv_world_sheets.md) | Act IV 5世界の concrete world sheet 集 |
| [worlds/13_act_v_world_sheets.md](./worlds/13_act_v_world_sheets.md) | Act V 2世界の concrete world sheet 集、本編決着と終止符 |
| [worlds/14_starting_arc_map_and_secret_blueprints.md](./worlds/14_starting_arc_map_and_secret_blueprints.md) | 開始村〜`W-005` の map loop, hidden route, revisit payoff を固定する地図台帳 |
| [worlds/15_act_ii_bridge_map_and_secret_blueprints.md](./worlds/15_act_ii_bridge_map_and_secret_blueprints.md) | `W-006〜W-007` の runtime zone, map loop, hidden pocket, revisit payoff を固定する地図台帳 |

---

## 7. Art

| ファイル | 役割 |
|---------|------|
| [art/01_style_bible.md](./art/01_style_bible.md) | 視覚哲学、パレット、アウトライン、UI、タイル、生成禁止事項 |
| [art/02_monster_sprite_production_manual.md](./art/02_monster_sprite_production_manual.md) | 400体量産向けの canonical monster sprite production manual |
| [art/03_sound_design_bible.md](./art/03_sound_design_bible.md) | BGM 16カテゴリ、SE 70種辞書、アンビエント、塔/門の音響設計、AI生成方針 |
| [art/04_ui_font_and_component_rules.md](./art/04_ui_font_and_component_rules.md) | UIの文字セル、説明帯、window、cursor、mobile touch の簡潔規格 |
| [art/05_ui_sprite_production_manual.md](./art/05_ui_sprite_production_manual.md) | UI/HUD sprite, font, window, icon, touch layout の production manual |
| [art/06_sound_design_production_manual.md](./art/06_sound_design_production_manual.md) | BGM / SE / jingle の production manual と export 基準 |
| [art/07_character_sprite_production_manual.md](./art/07_character_sprite_production_manual.md) | 主人公とNPCの16x16 character sprite production manual |
| [art/08_asset_provenance_and_ai_generation_registry.md](./art/08_asset_provenance_and_ai_generation_registry.md) | prompt, seed, review, IP, edit log を追う provenance 契約 |
| [art/09_tileset_and_map_art_production_manual.md](./art/09_tileset_and_map_art_production_manual.md) | タイルセット、建材、地面、門、マップオブジェクトの production manual |

### Legacy（参照のみ、正とはしない）

| ファイル | 役割 |
|---------|------|
| [art/90_monster_sprite_production_spec_legacy.md](./art/90_monster_sprite_production_spec_legacy.md) | 旧版モンスタースプライト制作仕様（art/02 に統合済み） |
| [art/91_monster_sprite_prompt_and_output_spec_legacy.md](./art/91_monster_sprite_prompt_and_output_spec_legacy.md) | 旧版プロンプト・出力仕様（art/02 + content/06 に統合済み） |

---

## 8. 実装前の最低確認

### バトルを触る前

- `systems/01`
- `systems/02`
- `systems/06`
- `systems/08`
- `systems/09`
- `systems/10`
- `systems/13`
- `systems/17`

### 配合や図鑑を触る前

- `systems/03`
- `systems/16`
- `content/01`
- `content/06`
- `systems/07`

### マップやNPCを触る前

- `worlds/01`
- `worlds/04`
- `worlds/06`
- `worlds/07`
- `worlds/08`
- `worlds/09`
- `worlds/10`
- `worlds/11`
- `worlds/12`
- `worlds/13`
- `worlds/14`
- `worlds/15`
- `content/03`
- `content/07`
- `content/08`
- `content/09`
- `systems/11`
- `systems/17`

### ストーリーやテキストを触る前

- `story/01`
- `story/02`
- `story/03`
- `story/04`
- `story/05`
- `story/06`
- `story/07`
- `story/08`
- `story/09`
- `story/10`
- `story/11`
- `story/12`
- `story/13`
- `story/14`
- `content/05`

### アセット量産を触る前

- `art/01`
- `art/02`
- `art/03`
- `art/04`
- `art/05`
- `art/06`
- `art/07`
- `art/08`
- `art/09`
- `content/06`

---

## 9. 今の設計で特に重要な横断原則

1. `unique-my-monster` を壊す仕様変更はしない
2. 確率は局所に閉じ込め、長期目標は決定論で支える
3. デフォルト体験はレトロ、快適化はオプション
4. 400体と20+世界は数だけでなく、役割と記憶に残る導線を持たせる
5. 物語は本編完結を守り、深層宇宙論は postgame に送る
