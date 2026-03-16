# 14. Item, Shop, Loot, And Service Contract

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16
> **参照元**:
> - `docs/specs/systems/01_numeric_rules_and_master_schema.md`
> - `docs/specs/systems/04_economy_items_and_progression_rules.md`
> - `docs/specs/systems/05_id_naming_validation_and_registry_rules.md`
> - `docs/specs/systems/07_progress_flags_and_save_state_model.md`
> - `docs/specs/systems/13_boss_gatekeeper_and_field_modifier_rules.md`
> - `docs/specs/systems/11_protagonist_party_and_ranch_rules.md`
> - `docs/specs/content/04_initial_items_and_shops.md`

---

## 1. 目的

- `item_master`, `shop`, `loot`, `service`, `reward` の参照契約を1本化する
- `ITM-###` のようなレジストリIDと、`item_heal_dryherb` のような実運用IDの役割を分離する
- 世界別価格、店ごとの陳列、戦利品、ボス/大会報酬、鍵/記録アイテムを同じ文法で扱えるようにする
- 既存仕様との互換を保ちながら、移行順序と validator の基準を固定する

---

## 2. 契約の結論

### 2.1 IDレイヤー

本契約では **3層の識別子** を使い分ける。

| 層 | 用途 | canonical か | 例 |
|----|------|---------------|----|
| `*_id` | 実データの主キー、外部キー、保存データ、CSV参照 | はい | `item_heal_dryherb` |
| `slug` | 人間可読な短縮識別子、ファイル名、内部UI補助 | はい | `heal_dryherb` |
| `registry_id` | 文書・棚卸し・レビュー用のコード | いいえ | `ITM-004` |

### 2.2 canonical internal ID 方針

- 保存データ、マスターデータ、コード内参照は **必ず typed snake_case の `*_id`** を使う
- `registry_id` は管理番号であり、**外部キーとして使わない**
- `slug` は人間が読めることを優先し、同一テーブル内で一意とする
- alias 解決は import / migration 時だけ許可し、永続化時は canonical `*_id` に正規化する

### 2.3 エンティティ別命名規約

| エンティティ | canonical `*_id` | `slug` | `registry_id` |
|--------------|------------------|--------|---------------|
| Item | `item_<category>_<name>` | `<category>_<name>` | `ITM-###` |
| Shop | `shop_<location>_<name>` | `<location>_<name>` | legacy `SHOP-*` を許容 |
| Loot Table | `loot_<source>_<name>` | `<source>_<name>` | `LUT-###` |
| Service | `service_<type>_<name>` | `<type>_<name>` | 将来予約 `SRV-###` |
| Reward Bundle | `reward_<source>_<name>` | `<source>_<name>` | 将来予約 `RWD-###` |
| Price Profile | `price_<scope>_<name>` | `<scope>_<name>` | 任意 |

### 2.4 drift 解消の正式判断

- `item_*` 形式は **canonical runtime ID** とする
- `ITM-###` は **item の registry / alias** とする
- `SHOP-001`, `SHOP-W01` など既存の shop コードは **legacy registry alias** とし、今後の join 先には使わない
- `systems/05` の Item 行にある `ITM-###` は、「item が registry code を持つ」という意味で継続し、`item_id` の意味には使わない
- Session 03 baseline では `shop_*`, `service_*`, `loot_*` を canonical runtime ID とし、`SHP-*`, `SVC-*`, `LUT-*`, `SHOP-*` は `registry_id` または `entity_alias_master` で吸収する

---

## 3. Alias Policy

### 3.1 alias の原則

- alias は **canonical ID に1対1で解決** される
- alias から alias への多段解決は禁止
- 同じ alias 文字列を複数エンティティへ割り当ててはならない
- 大文字小文字は区別する
- export, save, log の正本出力は canonical `*_id` のみ

### 3.2 `entity_alias_master`

| カラム | 型 | 説明 |
|--------|----|------|
| `entity_type` | enum | `item / shop / loot / service / reward` |
| `alias_value` | string | legacy 名称や旧ID |
| `canonical_id` | string | 正規化先の `*_id` |
| `alias_kind` | enum | `registry / legacy_runtime / legacy_doc / temp_migration` |
| `source_doc` | string | 由来文書。例: `content/04_initial_items_and_shops.md` |
| `active` | bool | validator が受け付けるか |
| `sunset_version` | string nullable | 受け付け終了予定 |
| `notes` | string | 備考 |

### 3.3 alias の運用境界

- CSV import, 手入力 migration, レビュー差分比較では alias を受け付けてよい
- runtime API, save data, network payload, デバッグログ集計では alias を禁止する
- `registry_id` も alias の一種として扱うが、列として保持する値は別管理してよい

---

## 4. 共有モデリング規約

### 4.1 共通列

以下は item/shop/loot/service/reward 系の master に共通して持たせてよい。

| カラム | 説明 |
|--------|------|
| `*_id` | canonical 主キー |
| `slug` | 人間可読 slug |
| `registry_id` | legacy / 棚卸し用コード |
| `name_jp` | 日本語表示名 |
| `name_en` | 英語表示名 |
| `status` | `active / deprecated / disabled / planned` |
| `tags` | `|` 区切りタグ |
| `notes` | 補足 |

### 4.2 参照の原則

- すべての外部キーは canonical `*_id` に向ける
- 複数値列は既存 master 仕様に合わせて `|` 区切り文字列を使ってよい
- `world_id`, `flag_id`, `rank_id`, `zone_id` は既存 master の canonical ID を参照する
- CSV 互換性のため、複合オブジェクトは JSON ではなく分解列で持つ

### 4.3 status の意味

| 値 | 意味 |
|----|------|
| `active` | 現行ビルドで使用する |
| `deprecated` | 読み込み互換はあるが新規参照禁止 |
| `disabled` | 残置のみ。runtime 不使用 |
| `planned` | 予約済み。未配布 |

---

## 5. Canonical Tables

### 5.1 `item_master`

`item_master` は **アイテムそのものの定義** を持つ。店の値段差や一時的な解放条件はここに持ち込まない。

| カラム | 型 | 説明 |
|--------|----|------|
| `item_id` | string | canonical ID。例: `item_heal_dryherb` |
| `slug` | string | 例: `heal_dryherb` |
| `registry_id` | string nullable | 例: `ITM-004` |
| `name_jp` | string | 日本語名 |
| `name_en` | string | 英語名 |
| `item_category` | enum | `heal_hp / heal_mp / cure_status / bait / combat_buff / combat_debuff / escape / map_tool / breed_catalyst / key_item / record_item` |
| `item_subtype` | string | 毒解除、bird用bait など |
| `rarity` | enum | `common / uncommon / rare / relic` |
| `tier` | int | 価格と進行帯の基準 |
| `inventory_bucket` | enum | `carry / keyring / record_log / facility_only` |
| `consumption_mode` | enum | `consumable / reusable / persistent_unique` |
| `stack_limit` | int | 同一所持上限 |
| `field_usable` | bool | フィールド使用可 |
| `battle_usable` | bool | 戦闘使用可 |
| `facility_usable` | bool | 施設内専用か |
| `sellable` | bool | 売却可否 |
| `base_buy_price` | int | 基準購入価格 |
| `base_sell_price` | int | 基準売値。profile 適用前 |
| `effect_key` | string | 実効果キー |
| `effect_value` | string | 実効果パラメータ |
| `auto_grant_flag` | string nullable | 取得時/所持時に参照する進行フラグ |
| `sort_order` | int | UI並び順 |
| `status` | enum | 共通 status |
| `tags` | string | `|` 区切り |
| `notes` | string | 備考 |

### 5.2 key item / record item の固定ルール

| 項目 | `key_item` | `record_item` |
|------|------------|---------------|
| `inventory_bucket` | 原則 `keyring` | 原則 `record_log` |
| `consumption_mode` | `persistent_unique` | 原則 `persistent_unique`、消耗型のみ `consumable` |
| `stack_limit` | 1 固定 | 原則 1。消耗型は個別設定可 |
| `sellable` | `false` 固定 | 原則 `false`。売却可能にする場合は明示理由必須 |
| `loot` | repeatable drop 禁止 | repeatable 可だが重複処理を明示 |
| `shop` | 一回売り切りのみ | `one_time_unlock` または別枠販売を推奨 |

補足:

- `item_key_worktag`, `item_key_oldtag` のような進行鍵は canonical item として保持する
- 記録系で「知識は残るが消耗品もある」場合は、永続知識を `record_log` 側、消耗材料を `carry` 側へ分離する

### 5.3 `shop_master`

`shop_master` は **売り場単位の定義** を持つ。販売物一覧や service 一覧は別テーブルで正規化する。

| カラム | 型 | 説明 |
|--------|----|------|
| `shop_id` | string | canonical ID。例: `shop_home_village_general` |
| `slug` | string | 例: `home_village_general` |
| `registry_id` | string nullable | 例: `SHOP-001` |
| `name_jp` | string | 表示名 |
| `name_en` | string | 表示名英語 |
| `shop_type` | enum | `general / field_vendor / tournament_vendor / record_vendor / specialist` |
| `scope_id` | string | 所属 scope。通常は `W-###`、開始村は `VIL` |
| `zone_id` | string nullable | より細かい位置 |
| `story_gate_flag` | string nullable | 解放条件 |
| `rank_gate` | string nullable | ランク条件 |
| `inventory_band` | string | `starter / world_1 / mid / endgame` 等 |
| `base_price_multiplier` | decimal | 店全体の係数。通常は `1.00` |
| `restock_clock` | enum | `none / return_to_hub / daily / story_progress` |
| `currency_type` | enum | 現状 `gold` 固定 |
| `status` | enum | 共通 status |
| `tags` | string | `|` 区切り |
| `notes` | string | 備考 |

### 5.4 `shop_inventory_master`

| カラム | 型 | 説明 |
|--------|----|------|
| `shop_id` | string | `shop_master` 参照 |
| `slot_no` | int | 同一 shop 内で一意 |
| `item_id` | string | `item_master` 参照 |
| `unlock_flag` | string nullable | 陳列解放条件 |
| `unlock_rank` | string nullable | ランク条件 |
| `stock_mode` | enum | `infinite_common / daily_limited / one_time_unlock / tournament_vendor` |
| `max_stock` | int nullable | 在庫上限。無限なら null |
| `restock_rule` | string | 帰還、日次、章進行など |
| `buy_limit_per_save` | int nullable | セーブ単位購入制限 |
| `price_override` | int nullable | 最終購入価格の絶対値 override |
| `price_multiplier` | decimal nullable | 行単位係数 |
| `display_priority` | int | 表示順 |
| `hidden_until_unlocked` | bool | 未解放時非表示か |
| `status` | enum | 共通 status |
| `notes` | string | 備考 |

### 5.5 `service_master`

service は **アイテムを介さない取引** を表す。宿泊、全体回復、解析、記録照合、参加登録などを item 化しない。

| カラム | 型 | 説明 |
|--------|----|------|
| `service_id` | string | canonical ID。例: `service_inn_basic_rest` |
| `slug` | string | 例: `inn_basic_rest` |
| `registry_id` | string nullable | 将来 `SRV-###` を予約 |
| `name_jp` | string | 表示名 |
| `name_en` | string | 表示名英語 |
| `service_category` | enum | `inn_rest / party_restore / storage / record_decode / recipe_reveal / tournament_entry / fusion_assist / clue_exchange` |
| `scope_id` | string | 提供元 scope。通常は `W-###`、開始村は `VIL` |
| `pricing_basis` | enum | `flat / per_party / per_level_band / per_attempt / per_record_page` |
| `base_price` | int | 基準価格 |
| `effect_key` | string | 実効果キー |
| `effect_value` | string | 実効果パラメータ |
| `uses_per_reset` | int nullable | リセット単位回数制限 |
| `story_gate_flag` | string nullable | 解放条件 |
| `status` | enum | 共通 status |
| `tags` | string | `|` 区切り |
| `notes` | string | 備考 |

### 5.6 `shop_service_master`

| カラム | 型 | 説明 |
|--------|----|------|
| `shop_id` | string | `shop_master` 参照 |
| `service_id` | string | `service_master` 参照 |
| `unlock_flag` | string nullable | 個別解放条件 |
| `price_override` | int nullable | 最終価格の絶対値 override |
| `price_multiplier` | decimal nullable | 個別価格係数 |
| `uses_per_reset_override` | int nullable | shop 側制限 |
| `display_priority` | int | 表示順 |
| `status` | enum | 共通 status |
| `notes` | string | 備考 |

### 5.7 `price_profile_master`

世界別価格と店別価格差は `price_profile_master` で扱う。個別商品の固定値は inventory/service 側 override を使う。

| カラム | 型 | 説明 |
|--------|----|------|
| `price_profile_id` | string | canonical ID |
| `scope_type` | enum | `world / shop` |
| `scope_id` | string | `world_id` または `shop_id` |
| `target_kind` | enum | `item_category / item_id / service_category / service_id` |
| `target_ref` | string | 対象カテゴリまたは対象ID |
| `buy_multiplier` | decimal | 購入価格係数 |
| `sell_multiplier` | decimal | 売値係数 |
| `flat_delta` | int | 固定加減算 |
| `rounding_rule` | enum | `floor / ceil / nearest` |
| `priority` | int | 高いほど優先 |
| `status` | enum | 共通 status |
| `notes` | string | 備考 |

### 5.8 `loot_table_master`

`loot_table_master` は **テーブルのヘッダ** を持つ。ドロップ行は別テーブルへ分ける。

| カラム | 型 | 説明 |
|--------|----|------|
| `loot_table_id` | string | canonical ID |
| `slug` | string | 人間可読 slug |
| `registry_id` | string nullable | `LUT-###` |
| `source_type` | enum | `enemy / boss / chest / gather / first_clear / event` |
| `source_ref` | string | 参照元ID |
| `world_id` | string nullable | 世界別補正に使う |
| `roll_policy` | enum | `single_pick / weighted_multi / guaranteed_plus_weighted / first_clear_once` |
| `roll_count_min` | int | 最小ロール数 |
| `roll_count_max` | int | 最大ロール数 |
| `first_clear_reward_id` | string nullable | `reward_bundle_id` 参照 |
| `status` | enum | 共通 status |
| `tags` | string | `|` 区切り |
| `notes` | string | 備考 |

### 5.9 `loot_entry_master`

| カラム | 型 | 説明 |
|--------|----|------|
| `loot_table_id` | string | `loot_table_master` 参照 |
| `entry_no` | int | 同一 table 内で一意 |
| `grant_type` | enum | `item / reward_bundle` |
| `grant_id` | string | `item_id` または `reward_bundle_id` |
| `drop_slot_type` | enum | `common / uncommon / rare / relic / guaranteed / first_clear` |
| `base_drop_rate` | decimal | 基本率 |
| `quantity_min` | int | 最小個数 |
| `quantity_max` | int | 最大個数 |
| `weight` | int | 重み。rate 方式と併用しない |
| `first_clear_only` | bool | 初回限定 |
| `unique_once` | bool | 一度入手したら以後無効 |
| `condition_flag` | string nullable | 条件付き出現 |
| `status` | enum | 共通 status |
| `notes` | string | 備考 |

### 5.10 `reward_bundle_master`

報酬は item, gold, flag, service unlock を **bundle 単位** で扱う。大会、ボス、初回踏破で列構造を変えない。

| カラム | 型 | 説明 |
|--------|----|------|
| `reward_bundle_id` | string | canonical ID |
| `slug` | string | 人間可読 slug |
| `registry_id` | string nullable | 将来 `RWD-###` を予約 |
| `name_jp` | string | 省略可だが推奨 |
| `name_en` | string | 省略可だが推奨 |
| `delivery_mode` | enum | `direct / mailbox / system_unlock` |
| `repeat_policy` | enum | `once / repeatable / first_clear_only` |
| `status` | enum | 共通 status |
| `tags` | string | `|` 区切り |
| `notes` | string | 備考 |

### 5.11 `reward_bundle_entry_master`

| カラム | 型 | 説明 |
|--------|----|------|
| `reward_bundle_id` | string | `reward_bundle_master` 参照 |
| `entry_no` | int | 行番号 |
| `grant_type` | enum | `gold / item / service_unlock / flag / clue / recipe_unlock / shop_unlock` |
| `grant_ref` | string | 対象IDまたは論理キー |
| `amount` | int | 金額または個数。unlock は `1` |
| `delivery_bucket` | enum | `carry / keyring / record_log / system` |
| `duplicate_rule` | enum | `stack / ignore / convert_to_gold / fail` |
| `status` | enum | 共通 status |
| `notes` | string | 備考 |

### 5.12 `reward_source_master`

`reward_source_master` は「どの出来事がどの bundle を付与するか」を持つ。既存の大会報酬テーブルはここへ吸収する。

| カラム | 型 | 説明 |
|--------|----|------|
| `reward_source_id` | string | canonical ID |
| `source_type` | enum | `tournament_rank_clear / boss_clear / gate_clear / quest_clear / discovery / shop_bonus` |
| `source_ref` | string | rank_id, boss_id, flag_id など |
| `clear_count` | int nullable | 何回目報酬か |
| `unlock_flag` | string nullable | 条件 |
| `reward_bundle_id` | string | `reward_bundle_master` 参照 |
| `status` | enum | 共通 status |
| `notes` | string | 備考 |

---

## 6. 価格解決ルール

### 6.1 item の購入価格

```text
resolved_buy_price(item, shop) =
  if shop_inventory.price_override != null:
    shop_inventory.price_override
  else:
    round_rule(
      (
        item.base_buy_price
        * world_profile_multiplier
        * shop.base_price_multiplier
        * shop_profile_multiplier
        * coalesce(shop_inventory.price_multiplier, 1.0)
      ) + profile_flat_delta
    )
```

### 6.2 service の購入価格

```text
resolved_service_price(service, shop) =
  if shop_service.price_override != null:
    shop_service.price_override
  else:
    round_rule(
      (
        service.base_price
        * world_profile_multiplier
        * shop.base_price_multiplier
        * shop_profile_multiplier
        * coalesce(shop_service.price_multiplier, 1.0)
      ) + profile_flat_delta
    )
```

### 6.3 優先順位

1. 行単位の `price_override`
2. shop scope の `price_profile_master`
3. `shop_master.base_price_multiplier`
4. world scope の `price_profile_master`
5. `item_master.base_buy_price` / `service_master.base_price`

### 6.4 override 利用の原則

- 恒常的な世界差は `price_profile_master` に置く
- 「この店だけこの品が妙に高い/安い」は `shop_master.base_price_multiplier` または shop scope profile で表現する
- 特定の棚だけ固定価格にしたい場合のみ `price_override` を使う
- `item_master` に世界依存価格を直書きしてはならない

---

## 7. Inventory, Loot, Service, Reward の運用規約

### 7.1 shop inventory

- `shop_master` の `services` 文字列列は廃止し、必ず `shop_service_master` に分解する
- 同一 `shop_id` 内で同じ `item_id` を複数行持つ場合は、解放条件か価格が重複してはならない
- `display_priority` は shop ごとに単調増加とし、暗黙順を作らない
- `one_time_unlock` 商品は `buy_limit_per_save = 1` を原則にする

### 7.2 loot

- `loot_table_master` はヘッダ、`loot_entry_master` は行明細という責務を崩さない
- `grant_type=item` の通常戦利品は消耗品か記録片を原則とし、進行鍵は `first_clear_reward_id` または `reward_source_master` で与える
- `key_item` を repeatable loot に置くことは禁止
- `record_item` の重複時挙動は `reward_bundle_entry_master.duplicate_rule` または個別 notes に明示する

### 7.3 service

- service は「UI上の買い物」に見えても item に偽装しない
- 宿泊、解析、エントリー料、レシピ開示は `service_master` で管理する
- service が item を副次的に付与する場合は `reward_bundle_id` を返すのではなく、service 効果側で bundle を参照してよい
- breeder / arena のような facility service は `shop_service_master` に必ずしもぶら下げず、NPC が `service_id` を直接持つ standalone service として扱ってよい

### 7.4 reward

- 2種類以上の付与を持つ報酬は必ず `reward_bundle_master` を経由する
- `tournament_reward_master` のような source 固有列構造を新設してはならない
- boss, tournament, gate, clue 解決はすべて `reward_source_master -> reward_bundle_master -> reward_bundle_entry_master` で表現する

---

## 8. 既存仕様との差分整理

### 8.1 canonical 化する列名

| 既存表記 | 新契約での canonical | 方針 |
|----------|----------------------|------|
| `item_master.item_kind` | `item_master.item_category` | `item_kind` は廃止予定 alias |
| `item_master.category` | `item_master.item_category` | `systems/04` 側の語を統一 |
| `base_effect_value` | `effect_value` | 効果値の一般化 |
| `price_override` in `item_master` | 非推奨 | 商品個別価格は inventory/service 側へ移す |
| `shop_master.services` | 廃止 | `shop_service_master` に正規化 |
| `loot_table_master` 1行1ドロップ | 分割 | `loot_table_master` + `loot_entry_master` |
| `tournament_reward_master` | 分割 | `reward_source_master` + `reward_bundle_*` |

### 8.2 ID drift の整理

| 既存表記 | 位置づけ | 例 |
|----------|----------|----|
| `ITM-###` | item の registry / alias | `ITM-004` |
| `item_*` | item の canonical ID | `item_heal_dryherb` |
| `SHP-*` | shop の runtime legacy alias | `SHP-W07-001` |
| `SHOP-*` | shop の legacy registry alias | `SHOP-001`, `SHOP-W01` |
| `SVC-*` | service の runtime legacy alias | `SVC-W18-ARENA` |
| `LUT-###` | loot table の registry ID | `LUT-007` |

### 8.3 content doc との整合

- `content/04_initial_items_and_shops.md` にある `item_heal_dryherb` などは **そのまま canonical item_id** として採用する
- 同文書の `SHOP-001` などは canonical shop_id ではなく **legacy alias** とみなす
- `systems/11_protagonist_party_and_ranch_rules.md` にある `item_key_worktag` 等も canonical item_id として継続する

---

## 9. Validation Rules

### 9.1 hard fail

- canonical `*_id` 重複
- `slug` 重複
- `registry_id` 重複
- alias が複数 canonical へ解決される
- alias が別エンティティの canonical ID と衝突する
- 存在しない `item_id`, `shop_id`, `service_id`, `reward_bundle_id`, `world_id`, `flag_id` 参照
- `key_item` なのに `inventory_bucket != keyring`
- `key_item` なのに `stack_limit != 1`
- `key_item` なのに `sellable = true`
- `record_item` が `persistent_unique` なのに `stack_limit != 1`
- `shop_inventory_master` で同一 shop 内に同じ item の重複行があり、解放条件・価格条件まで一致している
- `loot_entry_master` で `quantity_min > quantity_max`
- `loot_entry_master` で `grant_type=item` なのに `grant_id` が item でない
- `reward_bundle_entry_master` で `grant_type` と `delivery_bucket` の組み合わせが不正
- `price_profile_master` の `scope_id` と `scope_type` が対応しない

### 9.2 warning

- `registry_id` 未付番の active row
- `slug` が canonical ID と意味的に乖離しすぎている
- `record_item` が `carry` bucket だが、対応する `record_log` 側の永続知識 item / flag / codex entry のいずれも定義されていない
- 同一 world 内で price multiplier が極端にばらつく
- `price_override` が多すぎて profile で吸収可能な調整を壊している
- 同一報酬 source に bundle が乱立し、source 粒度の設計が崩れている

---

## 10. Migration Guidance

### 10.1 移行の原則

- **まず canonical ID を確定し、その後 alias を吸収する**
- 既存 content で実際に使われている `item_*` は基本的に据え置く
- 数値 registry は後付け可能だが、canonical runtime ID は後から揺らさない

### 10.2 推奨移行順

1. `item_master` に `registry_id`, `slug`, `inventory_bucket`, `consumption_mode`, `base_buy_price`, `base_sell_price` を追加する
2. `item_kind` / `category` の揺れを `item_category` へ統一する
3. `shop_master.services` を `shop_service_master` へ分離する
4. `loot_table_master` の1行1ドロップ形式を、header と entry に分割する
5. `tournament_reward_master` を `reward_source_master` と `reward_bundle_*` へ移す
6. `entity_alias_master` を作り、`ITM-###`, `SHOP-*` を登録する
7. importer / validator を「入力で alias 許可、保存で canonical 化」に切り替える

### 10.3 legacy 名称からの具体的な読み替え

| legacy | 移行先 | 備考 |
|--------|--------|------|
| `ITM-004` | `item_master.registry_id` または `entity_alias_master.alias_value` | join 先には使わない |
| `item_heal_dryherb` | `item_master.item_id` | そのまま canonical |
| `SHOP-001` | `shop_master.registry_id` または `entity_alias_master.alias_value` | canonical shop_id は別途付与 |
| `SHOP-W01` | 同上 | world 付き legacy code |
| `item_master.price_override` | `shop_inventory_master.price_override` または `price_profile_master` | item 固有常設価格なら `base_buy_price` に吸収 |
| `tournament_reward_master.item_reward_id` | `reward_bundle_entry_master(grant_type=item)` | bundle 経由へ移行 |
| `tournament_reward_master.gold_reward` | `reward_bundle_entry_master(grant_type=gold)` | bundle 経由へ移行 |
| `tournament_reward_master.unlock_flag_reward` | `reward_bundle_entry_master(grant_type=flag)` | bundle 経由へ移行 |

### 10.4 非推奨にする legacy パターン

- `ITM-###` を save data に保存する
- `SHOP-*` を外部キーに使う
- item の価格差を `item_master` に世界別で複製する
- 報酬 source ごとに専用の列セットを増やす
- service をダミー item として販売する

---

## 11. Cross-Reference の読み方

- `systems/01_numeric_rules_and_master_schema.md` は item master の最小列定義を持つが、本契約が item/shop/loot/service/reward の canonical schema を上書きする
- `systems/04_economy_items_and_progression_rules.md` は経済思想と価格ロジックの元文書であり、本契約はその実装列構造を正規化する
- `systems/05_id_naming_validation_and_registry_rules.md` は registry code の原則を維持するが、item 系では `registry_id` と `item_id` を分離して読む
- `content/04_initial_items_and_shops.md` は初期 content の正本であり、そこにある `item_*` は canonical item_id として扱う
- `systems/13_boss_gatekeeper_and_field_modifier_rules.md` の reward 規格は、本契約では `reward_bundle_*` によって実装する

---

## 12. 決定事項の要約

- item は `item_*` を canonical runtime ID、`ITM-###` を registry alias とする
- shop は canonical `shop_*` を新設し、既存 `SHOP-*` は alias とする
- service は item と分離した正式 master を持つ
- loot は header / entry に分割し、報酬は bundle に正規化する
- 世界別価格は `price_profile_master`、棚単位固定値は `price_override` で扱う
- key / record item は inventory bucket と consumption mode で厳密に区別する
