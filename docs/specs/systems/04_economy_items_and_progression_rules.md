# 04. Economy Items And Progression Rules

> **ステータス**: Draft v1.1
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/requirements/02_game_design_core.md`
> - `docs/requirements/05_map_and_worlds.md`
> - `docs/requirements/06_endgame_content.md`
> - `docs/specs/systems/01_numeric_rules_and_master_schema.md`

---

## 1. 目的

- 所持制限と資源圧は不便のためではなく、判断圧のために置く
- 金は序盤から終盤まで意味を持ち、余剰になりにくい設計にする
- 世界解放、トーナメント進行、裏導線はレベルだけでなく準備と情報理解を要求する

---

## 2. 実装対象と前提

### 2.1 必須マスターデータ

| テーブル | 必須カラム |
|----------|------------|
| `item_master` | `item_id`, `category`, `tier`, `scarcity`, `stack_limit`, `field_usable`, `battle_usable`, `sellable`, `base_effect_value`, `price_override`, `flags` |
| `shop_master` | `shop_id`, `world_id`, `story_gate`, `rank_gate`, `inventory_band`, `price_modifier`, `stock_mode`, `services` |
| `shop_inventory_master` | `shop_id`, `item_id`, `unlock_flag`, `restock_rule`, `max_stock`, `display_priority` |
| `loot_table_master` | `loot_table_id`, `enemy_rank`, `drop_slot_type`, `item_id`, `base_drop_rate`, `quantity_min`, `quantity_max`, `first_clear_bonus` |
| `tournament_reward_master` | `rank_id`, `clear_count`, `gold_reward`, `item_reward_id`, `hint_reward_id`, `unlock_flag_reward` |
| `progress_gate_master` | `gate_id`, `gate_type`, `required_flag`, `required_item`, `required_rank`, `required_family_resonance`, `required_record_count` |

### 2.2 経済の設計原則

- アイテム20枠という制限を崩さない
- `HP回復`, `MP回復`, `bait`, `触媒` の4本柱で常時支出を発生させる
- 進行上の詰まりを「金不足」ではなく「何を持ち込むか」で感じさせる
- レア品を値段だけで制限せず、世界、トーナメント、噂、断片情報に紐付ける

---

## 3. アイテム taxonomy

### 3.1 アイテムカテゴリ

| category | 役割 | 使用タイミング |
|----------|------|----------------|
| `heal_hp` | HP回復 | 戦闘 / フィールド |
| `heal_mp` | MP回復 | 戦闘 / フィールド |
| `cure_status` | 状態異常解除 | 戦闘 / フィールド |
| `bait` | 勧誘補助 | 戦闘のみ |
| `combat_buff` | 一時強化 | 戦闘のみ |
| `combat_debuff` | 一時弱体 | 戦闘のみ |
| `escape` | ダンジョン脱出 | フィールドのみ |
| `map_tool` | 探索補助 | フィールドのみ |
| `breed_catalyst` | 変異、特殊配合補助 | 配合施設のみ |
| `key_item` | 進行専用 | 自動参照 |
| `record_item` | 図鑑、台帳、レシピ補助 | フィールド / 施設 |

### 3.2 携行制限

| 項目 | 値 |
|------|----|
| 携行枠 | 20 |
| 同一アイテム上限 | 99 |
| `key_item` | 別枠 |
| `record_item` | 原則別枠、消耗しない |
| 倉庫 | 牧場 / 塔側の一括管理。フィールドから直接アクセス不可 |

### 3.3 Vertical Slice 必須カテゴリ

- `heal_hp`
- `heal_mp`
- `cure_status`
- `bait`
- `escape`
- `breed_catalyst`

---

## 4. 価格ルール

### 4.1 基本価格式

```text
item_price =
  floor(
    base_price_by_tier
    * category_modifier
    * scarcity_modifier
    * world_price_modifier
  )
```

### 4.2 `base_price_by_tier`

| tier | 基準価格 |
|------|---------:|
| 1 | 20 |
| 2 | 40 |
| 3 | 80 |
| 4 | 150 |
| 5 | 280 |
| 6 | 500 |
| 7 | 900 |

### 4.3 `category_modifier`

| category | 係数 |
|----------|-----:|
| `heal_hp` | 1.0 |
| `heal_mp` | 1.2 |
| `cure_status` | 1.1 |
| `bait` | 1.3 |
| `combat_buff` | 1.4 |
| `combat_debuff` | 1.4 |
| `escape` | 1.5 |
| `map_tool` | 1.4 |
| `breed_catalyst` | 2.2 |
| `record_item` | 2.5 |

### 4.4 `scarcity_modifier`

| scarcity | 係数 |
|----------|-----:|
| `common` | 1.0 |
| `uncommon` | 1.4 |
| `rare` | 2.0 |
| `relic` | 3.0 |

### 4.5 `world_price_modifier`

| 店舗属性 | 係数 |
|----------|-----:|
| 普通の村 | 1.00 |
| 辺境、小規模 | 1.10 |
| 危険地帯の行商 | 1.20 |
| 商業都市 | 0.95 |
| 闘技場特約店 | 1.05 |

### 4.6 売値

```text
sell_price =
  floor(item_price * sell_rate)
```

| 種別 | `sell_rate` |
|------|------------:|
| 通常消耗品 | 0.45 |
| `bait` | 0.35 |
| `breed_catalyst` | 0.25 |
| `record_item` | 0.20 |
| `key_item` | 売却不可 |

### 4.7 価格運用ルール

- 店ごとの個性は `world_price_modifier` で表現し、完全別価格体系にしない
- `price_override` はボス報酬、限定品、記録品のみで使用
- 初期村のHP回復は `20`, MP回復は `45` を基準に据える

---

## 5. アイテム帯と在庫設計

### 5.1 Vertical Slice 推奨価格帯

| item_id | 種別 | 価格 | 役割 |
|---------|------|-----:|------|
| `herb_small` | HP回復 | 20 | 基本回復 |
| `herb_bundle` | HP回復 | 55 | 中量回復 |
| `water_mild` | MP回復 | 45 | 基本MP回復 |
| `antidote_leaf` | 状態解除 | 35 | 毒解除 |
| `focus_salt` | 状態解除 | 60 | 恐怖、封印解除 |
| `bait_dry` | 勧誘 | 55 | 初級bait |
| `bait_smoked` | 勧誘 | 120 | 中級bait |
| `rope_bone` | 脱出 | 80 | ダンジョン脱出 |
| `chalk_mark` | 探索補助 | 60 | 簡易マップ補助 |
| `ash_seed` | 配合触媒 | 150 | mutation率微増 |

### 5.2 ショップ在庫帯

| 段階 | HP回復 | MP回復 | 状態解除 | bait | 触媒 |
|------|--------|--------|----------|------|------|
| 開始村 | 2 | 1 | 1 | 1 | 0 |
| 世界2以降 | 3 | 2 | 2 | 2 | 1 |
| 中盤町 | 4 | 3 | 3 | 3 | 2 |
| 終盤町 | 5 | 4 | 4 | 4 | 3 |

### 5.3 restock 規則

| 方式 | ルール |
|------|--------|
| `infinite_common` | commonは無限在庫 |
| `daily_limited` | rare bait, catalyst は拠点帰還ごとに再入荷 |
| `one_time_unlock` | 記録品、台帳片は一度購入で消える |
| `tournament_vendor` | ランク到達時に追加陳列 |

---

## 6. money sinks

### 6.1 恒常sink

| sink | 目標比率 |
|------|---------:|
| 消耗品補充 | 35% |
| `bait` | 25% |
| `breed_catalyst` | 20% |
| 宿、回復施設 | 10% |
| 記録、情報 | 10% |

### 6.2 中盤以降sink

- 高級bait
- 特殊触媒
- recipe断片購入
- tournament再登録、解析費
- 図鑑照合費、禁忌記録の解読費

### 6.3 失敗時sink

| 状態 | ペナルティ |
|------|------------|
| 通常敗北 | 所持金 `10%` を失う |
| 塔深層での敗北 | 所持金 `15%` + consumable 1枠ロスト候補 |
| rank戦敗北 | 参加費消費のみ |

### 6.4 設計上の禁止事項

- 宿代だけで金を吸いすぎない
- 敗北ペナルティでやる気を折らない
- 触媒価格を高騰させすぎて mutation 遊びを殺さない

---

## 7. ドロップルール

### 7.1 基本ドロップ率

| rarity | 基本率 |
|--------|-------:|
| `common` | 28% |
| `uncommon` | 10% |
| `rare` | 3% |
| `relic` | 0.5% |

### 7.2 ドロップ式

```text
drop_rate =
  base_drop_rate
  + trait_drop_bonus
  + first_clear_bonus
  - rank_penalty
  - overkill_penalty

final_drop_rate = clamp(drop_rate, 0.5, 60)
```

| 補正 | 値 |
|------|----|
| `trait_drop_bonus` | `+1〜5` |
| `first_clear_bonus` | `+5` |
| B以上の敵 | `-2` |
| Aランク敵 | `-4` |
| Sランク敵 | `-8` |
| `overkill_penalty` | `-3` |

### 7.3 ドロップ枠構成

| slot_type | ルール |
|-----------|--------|
| `guaranteed` | ボス、初回撃破報酬 |
| `common_pool` | 通常素材、回復類 |
| `rare_pool` | bait, catalyst, recipe片 |
| `record_pool` | 記録断片、禁忌資料 |

### 7.4 anti-flood

- common item が3連続で落ちた場合、4回目だけ `uncommon` を再ロール
- `rare`, `relic` には pity を入れない
- ただし `first_clear_bonus` と `record_pool` で物語進行の詰まりは防ぐ

---

## 8. progression gating

### 8.1 gate type

| gate_type | 内容 |
|-----------|------|
| `story_gate` | 物語進行で解放 |
| `rank_gate` | tournament rank で解放 |
| `item_gate` | key item、封印片、印が必要 |
| `family_gate` | 特定familyの共鳴が必要 |
| `record_gate` | 台帳、断片、失踪記録の収集数が必要 |

### 8.2 gate 設計原則

- 新世界の解放は `前世界の核心行動` と結び付ける
- 同時に3種以上の gate 条件を積まない
- 主体的に「次に必要なのは何か」が推測できる状態を保つ
- main story の gate は金額では解放しない

### 8.3 gateごとの見せ方

| gate_type | UI方針 |
|-----------|--------|
| `story_gate` | 会話、イベント、塔の変化で示す |
| `rank_gate` | 闘技場受付と塔の門表示で示す |
| `item_gate` | 鍵穴、印、祭具など視覚ギミック |
| `family_gate` | 門の反応、共鳴文、個体演出 |
| `record_gate` | 記録官、台帳、碑文の更新で示す |

### 8.4 gating の数値基準

| ゲート | 想定 |
|--------|------|
| 世界2解放 | 初回配合または初回rank勝利 |
| 世界5到達 | 基本3系統の理解、D rank相当 |
| 中盤の塔深層 | B rank相当 + record進行 |
| 裏導線 | A rank相当 + 特定断片群 |

---

## 9. tournament unlock rules

### 9.1 ランク解放条件

| ランク | 推奨Lv | 解放条件 | 主報酬軸 |
|--------|-------:|----------|----------|
| G | 8 | 導入イベント後 | 金、基本bait |
| F | 12 | 世界2到達 | 触媒、図鑑断片 |
| E | 18 | 初回配合達成 | 特殊recipe噂 |
| D | 24 | 世界4核心イベント | 新gate解放 |
| C | 32 | 複数世界の禁忌解決 | rare bait、trait情報 |
| B | 42 | 中盤山場突破 | 裏gate断片 |
| A | 58 | 本編終盤前 | 裏ダンジョン入口 |
| `STARFALL` | 75+ | 本編終盤 | 終盤核心 |

### 9.2 参加費

```text
tournament_entry_fee =
  floor(20 * rank_multiplier)
```

| ランク | `rank_multiplier` | 参加費 |
|--------|------------------:|-------:|
| G | 1.0 | 20 |
| F | 1.5 | 30 |
| E | 2.5 | 50 |
| D | 4.0 | 80 |
| C | 6.0 | 120 |
| B | 10.0 | 200 |
| A | 18.0 | 360 |
| `STARFALL` | 30.0 | 600 |

### 9.3 賞金

```text
tournament_gold_reward =
  floor(entry_fee * reward_multiplier)
```

| 結果 | `reward_multiplier` |
|------|--------------------:|
| 優勝 | 4.0 |
| 準優勝 | 2.0 |
| 参加のみ | 0.5 |

### 9.4 報酬設計の原則

- 金だけで終わらせない
- `gate`, `recipe hint`, `catalyst`, `unique bait`, `record_item` のどれかを必ず混ぜる
- 連敗しても挑戦価値が残るよう、少額の参加報酬を維持する

---

## 10. resource pressure targets

### 10.1 序盤ダンジョン目標

| 指標 | 目標 |
|------|------|
| HP回復消費 | 2〜4個 |
| MP回復消費 | 0〜2個 |
| bait消費 | 0〜2個 |
| 脱出アイテム使用率 | 10%未満 |
| 満杯帰還率 | 25〜40% |

### 10.2 1時間あたり目標

| 指標 | 目標 |
|------|------|
| 金収入 | 250〜500 |
| 回復消耗 | 120〜220 |
| bait消耗 | 50〜180 |
| 純利益 | 50〜180 |

### 10.3 中盤以降目標

| 指標 | 目標 |
|------|------|
| 触媒購入頻度 | 1〜3個 / 時間 |
| recipe片購入頻度 | 0〜1回 / 時間 |
| tournament参加回数 | 1〜2回 / 時間 |
| 所持金天井感 | できるだけ発生させない |

### 10.4 endgame 目標

- 所持金が余るだけの状態を避ける
- `rare bait` と `breed_catalyst` が常に sink になる
- money sink を「税金」でなく「次の挑戦を速める投資」と感じさせる

---

## 11. 進行と経済の失敗条件

以下を検知した場合、再調整対象とする。

- 序盤30分で金不足による詰まりが発生する
- `bait` が高すぎて勧誘導線を使わなくなる
- 触媒が高すぎて mutation を試さなくなる
- common drop が多すぎて買い物が要らなくなる
- tournament 賞金だけで終盤まで回ってしまう

