# 5. データ要件とマスタ設計

> **Archived**: この文書は旧設計。現行の source of truth は `docs/requirements/`。

"ちゃんとプレイできる情報量をデータで持つ"ためには、コードより先にマスタの分割単位を固定する必要がある。AsepriteはCLI exportでatlas + jsonを吐ける [R7]。ゲーム本体は『実行系』、コンテンツは『外部データ』として分離する。UnityではScriptableObjectとJSON/CSVの併用でデータ駆動を実現する。デザイナがコードを触らずにモンスター、遭遇、ショップ、NPC、イベント条件を更新できることを必須要件とする。

| **マスタ**       | **最低件数** | **用途**                          | **主担当**     |
|------------------|--------------|-----------------------------------|----------------|
| monster_master   | 120          | 種族・能力・特性・進化/継承元     | ゲームデザイン |
| skill_master     | 84           | 技能効果・消費・対象・属性        | ゲームデザイン |
| trait_master     | 36           | パッシブ特性・条件・重複規則      | ゲームデザイン |
| item_master      | 60           | 回復・触媒・技書・外観アイテム    | ゲームデザイン |
| map_master       | 39           | 各マップの基本情報・BGM・進行条件 | レベルデザイン |
| encounter_master | 35           | 遭遇テーブル / 出現率 / 時間帯    | レベルデザイン |
| npc_spawn        | 250+         | 配置座標・向き・会話・条件        | レベルデザイン |
| shop_stock       | 20           | 店ごとの品揃え・章進行解放        | ゲームデザイン |
| quest_master     | 36           | 依頼・報酬・条件・再訪導線        | シナリオ/企画  |
| recipe_master    | 18 + rule    | exact recipe と family+rank rule  | ゲームデザイン |
| dialogue_text    | 3500行+      | 会話文・ヘルプ・図鑑説明          | シナリオ       |

## 5.1 必須フィールド定義

| **データ種別** | **必須フィールド**                                            | **備考**                                                            |
|----------------|---------------------------------------------------------------|---------------------------------------------------------------------|
| monster_master | id, name, family, rank, stats, growth, traits, learnset_id    | sprite_id, encyclopedia_text_id, recruit_base, habitat_tag を推奨。 |
| skill_master   | id, name, element, power, cost, target, formula, tags         | 演出IDとSE IDを分離。                                               |
| map_master     | id, name, region, map_type, music_id, tileset_set, enter_rule | Tilemapシーン参照とspawn tableへの参照を持つ。                      |
| npc_spawn      | id, map_id, x, y, facing, sprite_id, script_id                | quest_id, shop_id, active_flag で分岐。                             |
| shop_stock     | shop_id, item_id, price, unlock_chapter, quantity_rule        | 章条件、クエスト条件、在庫無限/有限を持つ。                         |

> **monster_master のサンプル行**
>
> ```json
> {
>   "id": "mon_seed_001",
>   "name": "モスピン",
>   "family": "芽族",
>   "rank": "F",
>   "base_stats": {"hp": 22, "atk": 9, "def": 8, "mag": 11, "res": 10, "spd": 12, "luk": 9},
>   "growth_curve": "balanced_fast",
>   "traits": ["regen_small", "wetland_affinity"],
>   "learnset_id": "ls_seed_001",
>   "recruit_base": 0.18,
>   "habitat_tag": ["grassland", "wet"],
>   "sprite_id": "spr_mon_seed_001"
> }
> ```
