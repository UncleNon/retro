# 要件定義書 — Project RETRO（仮題）

> **ステータス**: Draft v1.0
> **作成日**: 2026-03-15
> **最終更新**: 2026-03-15
> **作成者**: Claude Code × UncleNon
> **source of truth**: 現行要件は `docs/requirements/` を正とする。`docs/design/` は旧案アーカイブ。

---

## 目次

| # | セクション | ファイル | 概要 |
|---|-----------|---------|------|
| 01 | [プロジェクト概要・ビジョン](./01_project_vision.md) | `01_project_vision.md` | ゴール、スコープ、ターゲット、プラットフォーム |
| 02 | [ゲームデザイン — コアループ](./02_game_design_core.md) | `02_game_design_core.md` | コアループ、バトル、配合、育成、トーナメント |
| 03 | [世界観・ストーリー設計](./03_world_and_story.md) | `03_world_and_story.md` | 世界構造、歴史、文化、ダークファンタジー設計方針 |
| 04 | [モンスター設計](./04_monster_design.md) | `04_monster_design.md` | 400体設計、デザイン哲学、生態系、変異種、配合 |
| 05 | [マップ・ワールド構成](./05_map_and_worlds.md) | `05_map_and_worlds.md` | 20+世界、ダンジョン、拠点、マップ構造 |
| 06 | [エンドコンテンツ](./06_endgame_content.md) | `06_endgame_content.md` | 裏ボス、無限ダンジョン、高難度、やり込み要素 |
| 07 | [UI/UX設計](./07_ui_ux.md) | `07_ui_ux.md` | GBCレトロ+現代UX融合、操作体系 |
| 08 | [アート・アセットパイプライン](./08_art_pipeline.md) | `08_art_pipeline.md` | ツール選定、プロンプト設計、デザインルール |
| 09 | [サウンド設計](./09_sound_design.md) | `09_sound_design.md` | BGM、SE、8bit音源方針 |
| 10 | [テキスト・ローカライズ](./10_text_localization.md) | `10_text_localization.md` | テキスト量、AI生成フロー、日英対応 |
| 11 | [技術アーキテクチャ](./11_technical_architecture.md) | `11_technical_architecture.md` | Godot 4.4、iCloud、セキュリティ、データ管理 |
| 12 | [CI/CD・品質保証](./12_cicd_and_qa.md) | `12_cicd_and_qa.md` | パイプライン、テスト戦略、品質ゲート |
| 13 | [開発フロー・プロジェクト管理](./13_dev_process.md) | `13_dev_process.md` | ブランチ戦略、マイルストーン、タスク管理 |
| 14 | [非機能要件](./14_non_functional.md) | `14_non_functional.md` | 対応OS、パフォーマンス、オフライン、アクセシビリティ |

---

## 詳細設計の入口

要件を実装可能な粒度へ落とした詳細設計は `docs/specs/` を参照する。

| 種別 | ファイル | 概要 |
|------|---------|------|
| 詳細設計 index | [../specs/00_index.md](../specs/00_index.md) | story / systems / content / worlds の総合入口 |
| 母表 | [../specs/00_master_design_matrix.md](../specs/00_master_design_matrix.md) | 決めるべき設計面の棚卸し |
| 数式 / スキーマ | [../specs/systems/01_numeric_rules_and_master_schema.md](../specs/systems/01_numeric_rules_and_master_schema.md) | レベル、成長、勧誘、遭遇、配合、CSV列定義 |
| 乱数ポリシー | [../specs/systems/06_randomness_policy_and_probability_budgets.md](../specs/systems/06_randomness_policy_and_probability_budgets.md) | 確率を許す場所、禁止する場所、救済方針 |
| 進行フラグ / セーブ | [../specs/systems/07_progress_flags_and_save_state_model.md](../specs/systems/07_progress_flags_and_save_state_model.md) | 章、世界、門、NPC、clue、save state の管理 |
| 遭遇設計 sandbox | [../specs/systems/17_encounter_authoring_and_balance_sandbox.md](../specs/systems/17_encounter_authoring_and_balance_sandbox.md) | zone purpose、pack composition、scouting pressure、route pair、sandbox 検証 |
| playtest / smoke 契約 | [../specs/systems/18_playtest_measurement_and_smoke_contract.md](../specs/systems/18_playtest_measurement_and_smoke_contract.md) | save, export, readability の smoke と battle/recruit/breed 計測 |
| モンスター canonical package | [../specs/systems/16_monster_canonical_package_and_pipeline.md](../specs/systems/16_monster_canonical_package_and_pipeline.md) | monster を concept / art / data / asset で束ねる正本契約 |
| 初期モンスター | [../specs/content/01_vertical_slice_monsters.md](../specs/content/01_vertical_slice_monsters.md) | 序盤10体の詳細、数値、プロンプト |
| モチーフ設計 | [../specs/content/06_monster_taxonomy_and_motif_rules.md](../specs/content/06_monster_taxonomy_and_motif_rules.md) | 400体のモチーフ配分、変形法則、命名、prompt metadata |
| 初期アイテム / 店 | [../specs/content/04_initial_items_and_shops.md](../specs/content/04_initial_items_and_shops.md) | 回復、餌、触媒、記録物、店棚の実表 |
| モンスター sprite production | [../specs/art/02_monster_sprite_production_manual.md](../specs/art/02_monster_sprite_production_manual.md) | サイズ、透過、目、輪郭、アニメ、prompt、export の canonical manual |
| UI font / component 規格 | [../specs/art/04_ui_font_and_component_rules.md](../specs/art/04_ui_font_and_component_rules.md) | フォント、説明帯、window、cursor、mobile touch の簡潔規格 |
| UI/HUD sprite production | [../specs/art/05_ui_sprite_production_manual.md](../specs/art/05_ui_sprite_production_manual.md) | UI asset と HUD の exhaustive production manual |
| asset provenance / AI registry | [../specs/art/08_asset_provenance_and_ai_generation_registry.md](../specs/art/08_asset_provenance_and_ai_generation_registry.md) | prompt, seed, review, IP, edit log を追う provenance 契約 |
| tileset / map art production | [../specs/art/09_tileset_and_map_art_production_manual.md](../specs/art/09_tileset_and_map_art_production_manual.md) | 地面、建材、装飾、塔、門、マップ用アートの production manual |
| ストーリー聖書 | [../specs/story/01_story_bible.md](../specs/story/01_story_bible.md) | canonical truth、世界法則、5幕構成 |
| 伏線台帳 | [../specs/story/03_foreshadow_allocation_map.md](../specs/story/03_foreshadow_allocation_map.md) | 66件の伏線配置と回収先 |
| 事件参照ポリシー | [../specs/story/05_real_incident_inspiration_policy.md](../specs/story/05_real_incident_inspiration_policy.md) | 神隠し、失踪、共同体伝承を抽象化して使うためのルール |
| 歴史 texture 変換 | [../specs/story/08_historical_texture_research_ingestion.md](../specs/story/08_historical_texture_research_ingestion.md) | 実在史料を制度、物、言葉、生活癖へ変換する research 運用 |
| 沈黙経済 / 勢力運用 | [../specs/story/09_silence_economy_and_powerbrokers.md](../specs/story/09_silence_economy_and_powerbrokers.md) | faction ごとの口止め、物流、日銭、改竄実務 |
| 開始弧の引っ張り設計 | [../specs/story/10_starting_arc_engagement_playbook.md](../specs/story/10_starting_arc_engagement_playbook.md) | 開始村〜`W-005` の問い更新、帰村ショック、人間泥の構造 |
| session / curiosity 契約 | [../specs/story/11_session_pacing_and_curiosity_contract.md](../specs/story/11_session_pacing_and_curiosity_contract.md) | `5分 / 15分 / 60分` の遊び単位、報酬拍動、メモを取りたくなる情報密度 |
| 開始弧の関係図 / 勢力圧 | [../specs/story/12_starting_arc_relationship_and_faction_map.md](../specs/story/12_starting_arc_relationship_and_faction_map.md) | 開始村〜`W-005` の関係図、勢力圧、伏線担務の圧力線 |
| Act II bridge の関係図 / 勢力圧 | [../specs/story/13_act_ii_bridge_relationship_and_faction_map.md](../specs/story/13_act_ii_bridge_relationship_and_faction_map.md) | `W-006〜W-007` の local front, relation edge, clue carrier を固定する台帳 |
| cross-system echo 台帳 | [../specs/story/14_cross_system_echo_and_discovery_lattice.md](../specs/story/14_cross_system_echo_and_discovery_lattice.md) | monster, 物, map prop, 言い換え語を横断する discovery echo の正本 |
| 世界配分表 | [../specs/worlds/05_world_catalog_and_budget.md](../specs/worlds/05_world_catalog_and_budget.md) | 21世界の機能、禁忌、予算 |
| 開始村レイアウト | [../specs/worlds/01_starting_village_layout.md](../specs/worlds/01_starting_village_layout.md) | 村と塔周辺の寸法、座標、導線 |
| 拠点量産規格 | [../specs/worlds/06_settlement_layout_and_route_rules.md](../specs/worlds/06_settlement_layout_and_route_rules.md) | 村、町、都市、街道の数値規格と導線ルール |
| world sheet 契約 | [../specs/worlds/07_world_sheet_contract.md](../specs/worlds/07_world_sheet_contract.md) | 個別世界仕様が満たすべき concrete schema と責務分担 |
| world sheet テンプレ | [../specs/worlds/08_world_sheet_template_and_variation_rules.md](../specs/worlds/08_world_sheet_template_and_variation_rules.md) | 21世界を個別詳細へ落とすための必須項目と variation 軸 |
| Act I / II / III / IV / V 個票 | [../specs/worlds/09_act_i_world_sheets.md](../specs/worlds/09_act_i_world_sheets.md) / [../specs/worlds/10_act_ii_world_sheets.md](../specs/worlds/10_act_ii_world_sheets.md) / [../specs/worlds/11_act_iii_world_sheets.md](../specs/worlds/11_act_iii_world_sheets.md) / [../specs/worlds/12_act_iv_world_sheets.md](../specs/worlds/12_act_iv_world_sheets.md) / [../specs/worlds/13_act_v_world_sheets.md](../specs/worlds/13_act_v_world_sheets.md) | world sheet を concrete に埋めた実例集 |
| 開始弧の map / hidden 台帳 | [../specs/worlds/14_starting_arc_map_and_secret_blueprints.md](../specs/worlds/14_starting_arc_map_and_secret_blueprints.md) | 開始村〜`W-005` の map loop, hidden route, revisit payoff を固定する台帳 |
| Act II bridge の map / hidden 台帳 | [../specs/worlds/15_act_ii_bridge_map_and_secret_blueprints.md](../specs/worlds/15_act_ii_bridge_map_and_secret_blueprints.md) | `W-006〜W-007` の runtime zone, hidden pocket, revisit payoff を固定する台帳 |
| 開始村 full NPC | [../specs/content/07_starting_village_full_npc_catalog.md](../specs/content/07_starting_village_full_npc_catalog.md) | 開始村20人の fear / gain / tenderness / shame と会話 phase |
| 開始地域 ecology | [../specs/content/08_starting_region_ecology_and_monster_web.md](../specs/content/08_starting_region_ecology_and_monster_web.md) | 開始村〜`W-005` の食物連鎖、人為誤用、monster draft |
| Act I-II monster roster | [../specs/content/09_act_i_ii_monster_expansion_and_discovery_pack.md](../specs/content/09_act_i_ii_monster_expansion_and_discovery_pack.md) | `W-002`〜`W-007` の monster data, hidden discovery, special recipe 導線 |
| ボス / 門守 / 場効果 | [../specs/systems/13_boss_gatekeeper_and_field_modifier_rules.md](../specs/systems/13_boss_gatekeeper_and_field_modifier_rules.md) | phase, telegraph, field modifier, boss reward の規格 |
| item / shop / loot 契約 | [../specs/systems/14_item_shop_loot_and_service_contract.md](../specs/systems/14_item_shop_loot_and_service_contract.md) | item, shop, loot, service, reward の canonical 契約 |
| save migration / 互換 | [../specs/systems/15_save_migration_and_compatibility_policy.md](../specs/systems/15_save_migration_and_compatibility_policy.md) | schema_version, migration, backup, rollback の運用基準 |
| 予算 / DoD | [../specs/02_content_budget_and_definition_of_done.md](../specs/02_content_budget_and_definition_of_done.md) | 量産時の完了条件と必要数 |

---

## ヒアリング結果サマリ

### 基本情報
- **プラットフォーム**: iOS（将来的にソロ完結後、対戦拡張検討）
- **マネタイズ**: なし（趣味プロジェクト）
- **リリース目標**: 期限なし
- **ターゲット**: レトロゲーマー（DQM世代）
- **開発体制**: 一人+AI軍団（Claude Max, GPT Pro, Gemini Pro, Codex）

### ゲームデザイン
- **ジャンル**: GBC風ドット絵モンスター育成RPG
- **規模**: DQM2の1.5〜2倍のボリューム
- **MVP目安**: 5世界、モンスター30体
- **初回リリース方針**: North Star にできるだけ近い本番品質を目指す
- **初回リリース世界数**: 20以上
- **初回リリースモンスター数**: 400体
- **プレイ時間**: メインクリア60〜80時間、やり込み500〜1000時間
- **難易度**: ガチ寄り（戦略・配合を考えないと詰む）
- **North Star**: モンスター400体、世界20以上
- **主人公**: 45歳のおっさん/おばさん（選択制、無言）
- **主人公の立場**: 塔の中の人ではなく、その世界で暮らす住人
- **主人公の生業**: 家畜番
- **開始地点**: 小さな村
- **導入のきっかけ**: 事件に押されるのでなく、主人公が自分から塔へ向かう
- **塔へ向かう理由**: 昔から塔が気になっていた
- **塔への距離感**: 村では昔から「近づくな」と言われてきた
- **禁忌の根拠**: 単なる迷信ではなく、実際に被害が出ている
- **被害の性質**: 失踪
- **失踪者の範囲**: 村人
- **失踪の扱い**: 昔の出来事として今も語り継がれている
- **マルチプレイ**: v1はソロ完結、将来拡張検討
- **エンドコンテンツ**: 裏ボス、裏ダンジョン、無限ダンジョン、高難度トーナメント、図鑑コンプ

### 世界観
- **トーン**: ダークファンタジー（表は綺麗、裏はドロドロ）
- **テーマ**: 禁忌、タブー、人間の闇、社会の裏側
- **歴史**: 1000年単位の詳細な世界史
- **ストーリー構造**: 「終わったと思ったらまだ深みがある」多層構造
- **世界間移動**: 世界の中に実在する異物建築 `塔` + 生きた門
- **失踪の共通項**: 書き換えられた家系・名前・所属を持つ村人たち
- **伏線設計**: 50+の違和感を分散配置し、図鑑・台詞・配合・記録・建築で回収

### モンスター設計
- **配合**: 簡単に覚えられないレベルの複雑さ
- **変異種**: ランダム発生
- **個体差**: スキルカスタマイズ、同じモンスターでも唯一の存在
- **生態系**: モンスター同士の関係性、社会構造、自然環境との連動
- **愛着設計**: 特別感を持たせる仕組み

### 技術
- **エンジン**: Godot 4.4（ネイティブ2D + Pixel Perfect）
- **言語**: GDScript（必要に応じてC#併用）
- **解像度**: 160×144px（GBC準拠）
- **クラウド同期**: ローカルセーブ必須、iCloudはPhase 0で採否判定
- **セキュリティ**: プロ水準（暗号化キー外部化、チート対策）
- **データ管理**: Godot Resource + CSVインポーター
- **CI/CD**: 自動テスト→ステージング→本番（seisan-kun準拠）
- **テスト**: ユニット/インテグレーション/リグレッション/プレイテスト

### アート・サウンド
- **アート制作**: AI生成メイン（niji 7 → Nano Banana → Grok パイプライン）
- **デザインルール**: パレット制限、アウトライン規則、サイズ規定を厳密に設計
- **デザイン哲学**: モンスターごとにモチーフ・背景含むプロンプト用意
- **BGM/SE**: AI生成（8bit音源風）
- **UIスタイル**: GBCレトロベース+現代UXの利便性融合

### ローカライズ
- **Initial Release**: 日本語先行
- **将来対応**: 英語は後続フェーズで追加
- **テキスト生成**: AI生成 + 人力レビュー

### 操作
- **入力方式**: バーチャルパッド

### インスピレーション
- ドラゴンクエストモンスターズ（配合の深さ）
- ポケモン（モンスターへの愛着）
- メダロット（カスタマイズ性）
- 風来のシレン（ランダム性・緊張感）

### ツール活用情報
- **アセット生成パイプライン**: niji 7（キャラデザ）→ Nano Banana（スプライトシート化）→ Grok（アニメーション化）
- **参考開発フロー**: seisan-kunプロジェクト（CI/CD、ブランチ戦略、品質管理）
