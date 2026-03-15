# 16. Monster Canonical Package And Pipeline

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/requirements/04_monster_design.md`
> - `docs/requirements/08_art_pipeline.md`
> - `docs/requirements/11_technical_architecture.md`
> - `docs/specs/content/01_vertical_slice_monsters.md`
> - `docs/specs/content/06_monster_taxonomy_and_motif_rules.md`
> - `docs/specs/art/02_monster_sprite_production_manual.md`
> - `docs/specs/systems/01_numeric_rules_and_master_schema.md`
> - `docs/specs/systems/03_breeding_mutation_and_lineage_rules.md`
> - `docs/specs/systems/05_id_naming_validation_and_registry_rules.md`

---

## 1. 目的

- モンスターの概念設計、アート生成、数値設定、ランタイム実装の間で `同じ種を別フォーマットで二重管理する` 状態を終わらせる
- `docs/specs/content/06_monster_taxonomy_and_motif_rules.md` で先に定義された世界観フィールドと、`monster_master.csv` / `MonsterData` の実行用フィールドを、1つの canonical package に束ねる
- `idea -> prompt -> sprite -> animation -> data hookup -> QA -> approved` の進行状態を、アセットとデータの両方に対して一貫管理する
- 名前変更、slug 変更、概念修正、承認後の差し替えが発生しても、alias / deprecation / change log によって追跡可能にする

---

## 2. スコープ

### 2.1 この仕様が定義するもの

- 種族単位のモンスター master data の canonical package
- canonical package の論理テーブル分割
- required fields と派生先の対応
- monster concept から runtime export までの state machine
- 変更管理、alias、deprecation、drift 防止ルール

### 2.2 この仕様が上書きしないもの

- 数式、数値レンジ、耐性値の意味: `docs/specs/systems/01_numeric_rules_and_master_schema.md`
- 配合ロジックと mutation 解決順: `docs/specs/systems/03_breeding_mutation_and_lineage_rules.md`
- pixel art の厳密な production rule: `docs/specs/art/02_monster_sprite_production_manual.md`
- ID 形式と registry の一般原則: `docs/specs/systems/05_id_naming_validation_and_registry_rules.md`

この文書は「何を source of truth とし、どこへ export するか」を定義する。数式やアート品質基準そのものの authority は上記の参照先に残す。

---

## 3. Source Of Truth 階層

| 層 | サーフェス | 役割 | authority |
|----|------------|------|-----------|
| L0 | `monster canonical package` | モンスター1体の唯一の正 | 最上位 |
| L1 | `monster_master.csv`, `monster_resistance.csv`, `monster_learnset.csv` | ランタイム向け export | canonical package から生成 / 同期 |
| L1 | `resources/monsters/*.tres`, `scripts/data/monster_data.gd` の payload | Godot runtime resource | export 生成物 |
| L1 | `asset_registry.csv` | 生成済み prompt / sprite / animation の追跡 | canonical package の asset rows と同期 |
| L2 | `docs/specs/content/*`, `docs/specs/art/*`, vertical slice 例 | 設計・例示・production guide | 新しい canonical fact は追加しない |

### 3.1 衝突時の優先順位

1. canonical package
2. canonical package から派生した export
3. 説明用ドキュメント、例示ドキュメント

`monster_master.csv` や `resources/monsters/*.tres` だけを直接修正して canonical package 側へ反映しない変更は drift と見なす。

---

## 4. Monster Canonical Package の定義

モンスター canonical package とは、**1つの `monster_id` に紐づく種族定義、世界観定義、数値定義、配合定義、アート定義、アセット定義、状態定義、監査履歴の総体** である。

### 4.1 package の不変条件

- package の主キーは `monster_id` で、形式は `MON-###`
- `monster_id` は不変。名前や slug を変えても ID は変えない
- package は `package_version` を持つ
- package はちょうど1つの `canonical_state` を持つ
- approved 後に意味変更が入った場合、必ず `monster_change_log` を増やす
- deprecated package は削除しない。`canonical_state=deprecated` と alias / replacement で追跡する

### 4.2 package header (`monster_package`)

| カラム | 型 | 必須 | 説明 |
|--------|----|------|------|
| `monster_id` | string | 必須 | 種族ID |
| `package_version` | semver string | 必須 | `MAJOR.MINOR.PATCH` |
| `canonical_state` | enum | 必須 | `idea`, `prompt`, `sprite`, `animation`, `data_hookup`, `qa`, `approved`, `deprecated` |
| `created_at` | datetime | 必須 | 初回作成日時 |
| `updated_at` | datetime | 必須 | 最終更新日時 |
| `content_owner` | string | 必須 | 世界観 / taxonomy 責任者 |
| `systems_owner` | string | 必須 | 数値 / runtime export 責任者 |
| `art_owner` | string | 必須 | prompt / sprite / animation 責任者 |
| `release_target` | string | 任意 | VS / MVP / 1.0 など |
| `deprecation_reason` | string | 任意 | deprecated 時のみ |
| `replacement_monster_id` | string | 任意 | 置換先がある場合のみ |

---

## 5. Canonical Table Split

### 5.1 論理テーブル一覧

| テーブル | 粒度 | 目的 | 主な派生先 |
|----------|------|------|------------|
| `monster_package` | 1:1 | version / state / ownership | QA gating, approval |
| `monster_species` | 1:1 | ID, taxonomy, ontology, display identity | `monster_master.csv` 一部, localization |
| `monster_world_context` | 1:1 | 世界観の要約と主 world 接続 | codex, prompt context |
| `monster_world_presence` | 1:N | world ごとの出現 / 生態 /役割 | encounter planning, lore validation |
| `monster_taboo_link` | 1:N | taboo との接続 | lore QA, prompt context |
| `monster_human_pressure` | 0:N | 家畜化、登録、狩猟などの圧力記録 | lore QA, codex, breeding flavor |
| `monster_combat_profile` | 1:1 | 数値、属性、trait、成長 | `monster_master.csv` |
| `monster_resistance_profile` | 1:1 | 属性 / 状態異常耐性 | `monster_resistance.csv` |
| `monster_learnset` | 1:N | 習得スキル | `monster_learnset.csv` |
| `monster_breeding_profile` | 1:1 | scout / breeding / mutation / loot | `monster_master.csv`, breeding tables |
| `monster_art_profile` | 1:1 | prompt, palette, sprite size, animation budget | prompt export, `monster_master.csv` 一部 |
| `monster_asset` | 1:N | source / export / animation file と承認状態 | `asset_registry.csv` |
| `monster_alias_registry` | 0:N | 名前、slug、legacy enum の alias | migration, search, compatibility |
| `monster_change_log` | 0:N | approved 後の変更監査 | audit, release note |

### 5.2 正規化の原則

- 1つの意味を持つ canonical field は 1箇所にしか置かない
- 1:N の値は pipe 区切りや free text に押し込まない
- `notes` は説明補助に限る。canonical fact の唯一の置き場にしてはならない
- `world_context`, `taboo_link`, `human_pressure_tags` は child table へ分解し、summary text は view 扱いにする

---

## 6. Required Fields

### 6.1 `monster_species`

`monster_species` は identity と taxonomy の authoritative row である。approved package では以下を必須とする。

- `monster_id`
- `slug`
- `name_jp`
- `name_en`
- `family`
- `rank`
- `size_class`
- `motif_group`
- `secondary_motif_group`
- `motif_source`
- `ontology_class`
- `silhouette_type`
- `battle_role`

ローカライズキーは `docs/specs/systems/05_id_naming_validation_and_registry_rules.md` に従い `monster.{monster_id}.name`, `monster.{monster_id}.codex` を導出する。key 名を monster package 内で重複保持してはならない。

#### canonical enum

| フィールド | canonical 値 |
|-----------|--------------|
| `family` | `slime`, `beast`, `bird`, `plant`, `magic`, `material`, `undead`, `dragon`, `divine` |
| `rank` | `E`, `D`, `C`, `B`, `A`, `S` |
| `motif_group` | `animal`, `plant`, `tool`, `ritual`, `weather`, `myth`, `corporeal`, `abstract` |
| `secondary_motif_group` | `household`, `pastoral`, `funerary`, `bureaucratic`, `astral`, `gatebound` |
| `ontology_class` | `wildborn`, `gate_touched`, `bred_line`, `record_bent`, `remnant_bearing` |
| `silhouette_type` | `round`, `wide`, `tall`, `serpentine`, `floating`, `tripod`, `massive` |
| `battle_role` | `striker`, `tank`, `healer`, `controller`, `bait_specialist`, `mutation_key` |

#### enum authority と legacy 値

- `motif_group` は `docs/specs/content/06_monster_taxonomy_and_motif_rules.md` を authority とする
- legacy の `object` は alias であり、新規 package では使用禁止。canonical 値は `tool`
- legacy の `astral` primary motif は使用禁止。必要なら `motif_group=abstract` と `secondary_motif_group=astral` に分解する
- `silhouette_type` は art spec の enum を authority とする
- legacy の `cluster` silhouette は使用禁止。`tripod` または `massive` へ migration する

### 6.2 `monster_world_context`

`monster_world_context` は free text の置き場ではなく、world child tables を読んだ人間が把握しやすい summary row とする。必須:

- `monster_id`
- `primary_world_id`
- `world_context_summary`
- `ecology_role`
- `relationship_with_humans`
- `lore_hook`
- `resonance_grade`

#### canonical enum

| フィールド | canonical 値 |
|-----------|--------------|
| `resonance_grade` | `none`, `low`, `medium`, `high`, `critical` |

### 6.3 `monster_world_presence`

approved package では最低1行必要。必須:

- `monster_id`
- `world_id`
- `presence_type`
- `is_primary`
- `habitat_note`
- `appearance_reason`

#### canonical enum

| フィールド | canonical 値 |
|-----------|--------------|
| `presence_type` | `native`, `migratory`, `tower_touched`, `quest_only`, `mutation_only` |

`native_world_count` は canonical field として別保存しない。`monster_world_presence` の `presence_type in (native, migratory)` の件数から導出する。

### 6.4 `monster_taboo_link`

approved package では最低1行必要。必須:

- `monster_id`
- `world_id`
- `taboo_ref`
- `link_type`
- `severity`
- `evidence`

#### canonical enum

| フィールド | canonical 値 |
|-----------|--------------|
| `link_type` | `embodies`, `violates`, `enforces`, `attracts`, `warns_of`, `created_by` |
| `severity` | `low`, `medium`, `high`, `critical` |

#### `taboo_ref` ルール

- 現行 schema では `world_master.csv` に `taboo` が1列しかないため、当面は `W-###:taboo` 形式の stable ref とする
- 将来 `taboo_registry` が導入されても、monster 側の意味は `world 内のどの taboo にどう接続するか` のまま維持する
- `monster_taboo_link.evidence` は説明文であり、参照そのものではない

### 6.5 `monster_human_pressure`

0行以上。人間社会との関係があるモンスターでは最低1行必要。必須:

- `monster_id`
- `pressure_type`
- `intensity`
- `source_world_id`

#### canonical enum

| フィールド | canonical 値 |
|-----------|--------------|
| `pressure_type` | `domesticated`, `registered`, `ritualized`, `hunted`, `quarantined`, `weaponized`, `worshipped`, `exterminated` |
| `intensity` | `trace`, `light`, `moderate`, `heavy` |

### 6.6 `monster_combat_profile`

approved package では必須。以下を持つ。

- `monster_id`
- `element_primary`
- `element_secondary` 任意
- `growth_curve_id`
- `base_level_cap`
- `base_hp`, `cap_hp`
- `base_mp`, `cap_mp`
- `base_atk`, `cap_atk`
- `base_def`, `cap_def`
- `base_spd`, `cap_spd`
- `base_int`, `cap_int`
- `base_res`, `cap_res`
- `personality_bias`
- `trait_1`
- `trait_2`

#### canonical enum

| フィールド | canonical 値 |
|-----------|--------------|
| `element_primary` / `element_secondary` | `none`, `fire`, `water`, `wind`, `earth`, `thunder`, `light`, `dark` |
| `growth_curve_id` | `EARLY`, `STANDARD`, `LATE`, `LEGEND` |

### 6.7 `monster_resistance_profile`

現行 runtime export との互換性のため 1:1 で分離する。必須:

- `monster_id`
- `fire`, `water`, `wind`, `earth`, `thunder`, `light`, `dark`
- `poison`, `sleep`, `paralysis`, `confusion`, `seal`, `fear`, `instant_death`

値域と意味は `docs/specs/systems/01_numeric_rules_and_master_schema.md` と `docs/specs/systems/09_status_ailments_and_field_effects.md` に従う。

### 6.8 `monster_learnset`

1行以上。必須:

- `monster_id`
- `learn_type`
- `learn_value`
- `skill_id`

#### canonical enum

| フィールド | canonical 値 |
|-----------|--------------|
| `learn_type` | `innate`, `level`, `breed`, `event` |

### 6.9 `monster_breeding_profile`

approved package では必須。以下を持つ。

- `monster_id`
- `scoutable`
- `base_recruit`
- `breed_role`
- `mutation_profile_id`
- `breed_tags`
- `forbidden_tags`
- `loot_table_id`

#### canonical enum

| フィールド | canonical 値 |
|-----------|--------------|
| `breed_role` | `common_source`, `family_bridge`, `special_recipe`, `mutation_anchor`, `legend_chain` |

`mutation_profile` は free text ではなく `mutation_profile_id` として保持し、配合仕様側の profile master と結ぶ。

### 6.10 `monster_art_profile`

prompt と production constraints の authoritative row。approved package では必須:

- `monster_id`
- `prompt_id`
- `battle_sprite_px`
- `field_sprite_px`
- `palette_id`
- `primary_palette_keys`
- `must_keep_shape`
- `prompt_text`
- `negative_prompt`
- `ai_generation_notes`
- `animation_budget_id`
- `idle_frames`
- `attack_frames`
- `field_frames`
- `prompt_spec_version`

`sprite_size` は canonical field 名ではない。`battle_sprite_px` と `field_sprite_px` に分解する。

### 6.11 `monster_asset`

state が `sprite` 以降なら必須。asset_type ごとに1行以上持つ。

- `monster_id`
- `asset_type`
- `asset_id`
- `file_role`
- `file_name`
- `prompt_id`
- `generator_tool`
- `generator_version`
- `seed_or_settings`
- `cleanup_status`
- `ip_check_status`
- `reviewer`
- `approved_at`

#### canonical enum

| フィールド | canonical 値 |
|-----------|--------------|
| `asset_type` | `concept`, `battle_sprite`, `field_sprite`, `menu_icon`, `animation_sheet`, `source_file` |
| `file_role` | `source`, `export` |
| `cleanup_status` | `draft`, `cleaned`, `approved` |
| `ip_check_status` | `pending`, `passed`, `failed` |

### 6.12 `monster_alias_registry`

0行以上。alias が1つでも存在する場合は必須。

- `monster_id`
- `alias_kind`
- `alias_value`
- `alias_status`
- `introduced_in_version`
- `retired_in_version` 任意
- `replacement_monster_id` 任意
- `reason`

#### canonical enum

| フィールド | canonical 値 |
|-----------|--------------|
| `alias_kind` | `slug`, `name_jp`, `name_en`, `prompt_id`, `legacy_enum`, `legacy_id` |
| `alias_status` | `active_redirect`, `search_only`, `deprecated` |

### 6.13 `monster_change_log`

approved package に変更が入るたびに1行追加する。必須:

- `monster_id`
- `package_version`
- `change_type`
- `changed_fields`
- `reason`
- `requested_by`
- `approved_by`
- `impacted_exports`
- `changed_at`

---

## 7. Concept Fields の Canonical Mapping

`docs/specs/content/06_monster_taxonomy_and_motif_rules.md` にある高レベル field は、そのまま prose として複製しない。以下の crosswalk に従って canonical data へ落とす。

| concept field | canonical 格納先 | ルール | drift guard |
|---------------|------------------|--------|-------------|
| `ontology_class` | `monster_species.ontology_class` | enum で保持 | `notes` や prompt text のみで定義してはならない |
| `world_context` | `monster_world_context.world_context_summary` + `monster_world_presence` | summary と構造化 row に分解 | summary に存在しない `world_id` を書いたら fail |
| `taboo_link` | `monster_taboo_link` | taboo 参照と link 種別を分離 | `taboo_ref` 未解決は fail |
| `lore_hook` | `monster_world_context.lore_hook` | 短い hook 文として保存 | codex 文そのものを兼ねない |
| `resonance_grade` | `monster_world_context.resonance_grade` | enum で保持 | free text の「強い気配」等で代用しない |
| `human_pressure_tags` | `monster_human_pressure` | tag を row 化 | pipe 区切り文字列禁止 |
| `battle_role` | `monster_species.battle_role` | monster の役割ラベル | `skill_master.battle_role` と混同しない |
| `breed_role` | `monster_breeding_profile.breed_role` | breeding 上の役割 | combat role と統合しない |
| `mutation_profile` | `monster_breeding_profile.mutation_profile_id` | profile ID で参照 | prose のみで mutation 条件を書かない |
| `sprite_size` | `monster_art_profile.battle_sprite_px`, `field_sprite_px` | pixel 数に分解 | rank ごとの art spec を validator で確認 |
| `animation_budget` | `monster_art_profile.animation_budget_id`, `idle_frames`, `attack_frames`, `field_frames` | budget と実フレーム数を持つ | 「多め」「少なめ」のような曖昧語禁止 |

---

## 8. Runtime / Build Export Crosswalk

### 8.1 現行 runtime export

| export 先 | canonical source | 備考 |
|-----------|------------------|------|
| `monster_master.csv` | `monster_species` + `monster_combat_profile` + `monster_breeding_profile` + `monster_art_profile` | build の直接入力 |
| `monster_resistance.csv` | `monster_resistance_profile` | 現行形式を維持 |
| `monster_learnset.csv` | `monster_learnset` | 現行形式を維持 |
| `resources/monsters/*.tres` | 上記 3 CSV の union | `tools/data/build_resources.py` が生成 |
| `asset_registry.csv` | `monster_asset` | `approved` 前に登録済みであること |

### 8.2 現行 runtime にまだ出ていないが canonical では必須の field

- `secondary_motif_group`
- `ontology_class`
- `element_primary`, `element_secondary`
- `monster.{monster_id}.codex` に紐づく text entry
- `world_context_summary`
- `monster_world_presence`
- `monster_taboo_link`
- `monster_human_pressure`
- `breed_role`
- `mutation_profile_id`
- `animation_budget_id`

これらは「まだ runtime にないから optional」ではない。canonical package では必須であり、prompt generation、codex、QA、将来の breeding / encounter tooling で使う。

### 8.3 export ルール

- `monster_master.csv` は canonical enum をそのまま通せる string column を優先し、旧文書の enum 記述が狭い場合は canonical 側を正とする
- `MonsterData` の `.tres` は generated artifact であり、手編集禁止
- `asset_registry.csv` は `monster_asset` と同じ `prompt_id` / asset metadata を持つ。差異があれば package 側が正
- `notes` は export してよいが、build がそこから canonical field を推定してはならない

---

## 9. Lifecycle State Machine

### 9.1 正式状態

```text
idea -> prompt -> sprite -> animation -> data_hookup -> QA -> approved
```

canonical では保存値を lowercase enum に揃えるため、実値は `qa` を使用する。

### 9.2 各 state の完了条件

| state | 完了条件 | 必須成果物 |
|-------|----------|------------|
| `idea` | identity, ontology, primary world, taboo 接続が成立 | `monster_package`, `monster_species`, `monster_world_context`, primary `monster_world_presence`, 1行以上の `monster_taboo_link` |
| `prompt` | prompt と pixel target が lock された | `monster_art_profile` の required fields 一式 |
| `sprite` | battle / field / icon の静止画が review 済み | `monster_asset` に sprite 系 row、`cleanup_status!=draft`, `ip_check_status=passed` |
| `animation` | idle / attack / field animation が lock された | animation asset row、frame 数、anchor 整合 |
| `data_hookup` | runtime export に必要な数値・配合・learnset が全て揃った | `monster_combat_profile`, `monster_resistance_profile`, `monster_learnset`, `monster_breeding_profile` |
| `qa` | build / data validation / lore QA / art QA / IP QA が通った | export 同期、registry 同期、検証記録 |
| `approved` | release 候補として凍結可能 | package version 確定、必要 owner 承認、change log 完備 |

### 9.3 rollback ルール

- `name`, `slug`, `family`, `rank`, `motif_group`, `ontology_class`, `primary_world_id` を変えたら最低でも `idea` へ戻す
- `prompt_text`, `battle_sprite_px`, `field_sprite_px`, `must_keep_shape`, `palette_id` を変えたら最低でも `prompt` へ戻す
- battle / field / icon の静止画を差し替えたら最低でも `sprite` へ戻す
- animation sheet または frame count を変えたら最低でも `animation` へ戻す
- stats, resistances, learnset, breed / mutation / loot / scout 周りを変えたら最低でも `data_hookup` へ戻す
- QA fail は常に一段前へ戻すのではなく、失敗原因が属する最小 state まで戻す

### 9.4 `approved` の意味

`approved` は「見た目が良い」の意味ではない。以下が同時に成立して初めて `approved` とする。

- canonical package の required fields が全て埋まっている
- runtime export と asset registry が package と同期している
- lore / taxonomy / art / systems の owner がそれぞれ必要な承認を出している
- 承認時点の `package_version` が change log に残っている

---

## 10. Change Control

### 10.1 変更分類

| change type | 例 | version bump | 必要承認 | 最低 rollback |
|-------------|----|--------------|----------|---------------|
| `editorial` | typo 修正、説明文の明確化 | PATCH | 当該 owner 1名 | なしまたは `qa` |
| `lore_structural` | `world_context`, `taboo_link`, `ontology_class`, `lore_hook` 変更 | MINOR | content owner + QA | `idea` |
| `art_structural` | silhouette, palette, prompt, sprite 差し替え | MINOR | art owner + content owner | `prompt` or `sprite` |
| `gameplay_structural` | stats, resistances, learnset, breeding 変更 | MINOR | systems owner + QA | `data_hookup` |
| `identity_breaking` | `slug`, display name, rank, family の再定義 | MAJOR | content + systems + art | `idea` |
| `deprecation` | 種の retirement, merge, replacement | MAJOR | 全 owner | `deprecated` へ移行 |

### 10.2 必須ルール

- approved package への変更は必ず `monster_change_log` を更新する
- export に影響する変更は、同一 change set で派生物も更新する
- 変更理由は `reason` に残し、`changed_fields` は field 名の列挙で誤魔化さない
- `monster_id` を改名して継続利用してはならない。必要なら deprecated + 新規 package

### 10.3 drift と見なす変更

- `monster_master.csv` のみ編集し、canonical package を更新しない
- prompt 文だけを書き換え、`prompt_id` や `monster_art_profile` を更新しない
- asset registry だけ修正し、対応する `monster_asset` row を直さない
- `notes` にだけ world / taboo / mutation の canonical fact を追記する

---

## 11. Alias And Deprecation Policy

### 11.1 alias の原則

- alias は `monster_alias_registry` にのみ定義する
- alias は package の複製ではない。同じ種に対する歴史的な呼び名、slug、legacy 値の追跡である
- active export は常に current canonical 値を使う

### 11.2 alias を持てる対象

- `slug` の変更
- `name_jp`, `name_en` の旧称
- `prompt_id` の付け替え
- legacy enum migration
- 廃止された旧 ID から新 ID への redirect

### 11.3 deprecation の原則

- deprecated になった package は削除しない
- deprecated package は `monster_package.canonical_state=deprecated` とし、`deprecation_reason` を必須にする
- 置換先がある場合は `replacement_monster_id` を必須にする
- deprecated package の `monster_id` は永久欠番。再利用禁止

### 11.4 legacy enum migration policy

| legacy 値 | canonical 扱い |
|-----------|----------------|
| `motif_group=object` | `tool` の alias。新規定義禁止 |
| `motif_group=astral` | `abstract` + `secondary_motif_group=astral` へ migration |
| `silhouette_type=cluster` | case-by-case で `tripod` または `massive` へ migration |
| hyphenated role (`bait-specialist`, `mutation-key`, `family-bridge` など) | canonical では snake_case (`bait_specialist`, `mutation_key`, `family_bridge`) |

---

## 12. Non-Drift Validation Rules

- `world_context_summary` は `monster_world_presence`, `monster_taboo_link`, `monster_human_pressure` に存在しない事実を追加してはならない
- `lore_hook` は `taboo_link` と矛盾してはならない
- `ontology_class=gate_touched` または `remnant_bearing` の個体で `monster_taboo_link` が0件なら fail
- `battle_role` と `learnset` が明確に逆行する場合は warning ではなく review 必須
- `battle_sprite_px` / `field_sprite_px` は rank と art spec の size rule に一致しなければ fail
- `prompt_id` は `monster_art_profile` と `monster_asset` で一致しなければ fail
- `asset_registry.csv` に記録済みの asset が `monster_asset` に存在しなければ fail
- canonical enum の alias は import 時に正規化してよいが、export 時には canonical 値だけを出す

---

## 13. Approval Checklist

approved へ進める前に、最低でも以下を満たすこと。

- `monster_package` の owner, state, version が埋まっている
- `monster_species`, `monster_world_context`, `monster_combat_profile`, `monster_breeding_profile`, `monster_art_profile` が complete
- `monster_world_presence` が1行以上、`monster_taboo_link` が1行以上ある
- `monster_resistance_profile` と `monster_learnset` が runtime export と一致する
- sprite / field / icon / animation の asset row があり、`ip_check_status=passed`
- `asset_registry.csv` と package asset metadata が一致する
- approved に至る直前の変更が `monster_change_log` に残っている

---

## 14. 採用判断

本仕様の採用後、モンスター定義の正は `monster canonical package` とする。現行の `monster_master.csv`, `monster_resistance.csv`, `monster_learnset.csv`, `resources/monsters/*.tres`, `asset_registry.csv` は、運用上必要でも source of truth ではない。

この方針により、monster concept docs で先に定義された `ontology_class`, `world_context`, `taboo_link`, `lore_hook`, `human_pressure`, `breed_role`, `mutation_profile`, `animation_budget` を runtime schema と同じ系で追跡できるようにし、concept と build の間に新しい情報落ちや二重定義を作らない。
