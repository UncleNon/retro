# 01. Numeric Rules And Master Schema

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/requirements/02_game_design_core.md`
> - `docs/requirements/07_ui_ux.md`
> - `docs/adr/0008-core-experience-design-principles.md`

---

## 1. 設計方針

- ルールは **プレイヤーに全部見せる必要はないが、内部では一貫している** 状態にする
- ランダム性は局所に閉じ込め、長期育成は計画可能にする
- 400体運用を前提に、**テーブル駆動 + 少数の共通式** で回す
- 1体ごとの味は、`モチーフ`, `系統`, `耐性`, `スキル`, `成長プロフィール`, `個体差` の組み合わせで作る

---

## 2. 基本ステータス

### 採用ステータス

| カラム | 説明 | 基本用途 |
|--------|------|----------|
| `hp` | 体力 | 生存力 |
| `mp` | 魔力 | 呪文 / 特技の燃料 |
| `atk` | 攻撃 | 物理ダメージ基礎 |
| `def` | 守備 | 被物理ダメージ軽減 |
| `spd` | 素早さ | 行動順、逃走補正 |
| `int` | 賢さ | 補助 / 状態異常 / AI精度 |
| `res` | 精神 | 属性 / 状態異常耐性、MP防御 |

### 表示上限

| ステータス | 表示上限 |
|------------|----------|
| HP | 999 |
| MP | 999 |
| 攻撃 | 999 |
| 守備 | 999 |
| 素早さ | 999 |
| 賢さ | 999 |
| 精神 | 999 |

Vertical Slice では実数値はもっと低く運用し、3桁上限は将来拡張のために先に確保する。

---

## 3. レベル / 経験値 / 上限

### グローバルルール

| 項目 | 値 |
|------|----|
| グローバル hard cap | 99 |
| 配合可能最低Lv | 10 |
| 基本の種族別レベル上限帯 | 60〜84 |
| 系譜補正 `plus_value` hard cap | 24 |

### 種族別ベース上限

| ランク | `base_level_cap` の目安 |
|--------|-------------------------|
| E | 60〜68 |
| D | 64〜72 |
| C | 68〜76 |
| B | 72〜80 |
| A | 76〜82 |
| S | 80〜84 |

### 実効レベル上限

```text
effective_level_cap = min(99, base_level_cap + plus_value * 2 + mutation_cap_bonus)
```

| 要素 | 値 |
|------|----|
| `plus_value` 1あたり | +2Lv |
| `mutation_cap_bonus` | 0 または +2 |

これにより、低ランク種でも系譜を重ねれば endgame で戦える。

---

## 4. 経験値カーブ

### growth_curve_id

| ID | 名前 | 意味 |
|----|------|------|
| `EARLY` | 早熟 | 序盤で強く、後半は伸びが鈍い |
| `STANDARD` | 標準 | 最も素直な成長 |
| `LATE` | 晩成 | 序盤は低速、後半で伸びる |
| `LEGEND` | 特殊 | 上位種用。育てにくいが高水準 |

### 次レベル必要経験値

```text
next_level_exp(level) = floor(base_exp * curve_factor(level) * rank_factor)
```

#### `base_exp`

| growth_curve_id | `base_exp` |
|-----------------|-----------:|
| `EARLY` | 8 |
| `STANDARD` | 10 |
| `LATE` | 12 |
| `LEGEND` | 16 |

#### `curve_factor(level)`

```text
EARLY    = 1.10 + level * 0.18
STANDARD = 1.20 + level * 0.22
LATE     = 1.00 + level * 0.28
LEGEND   = 1.40 + level * 0.34
```

#### `rank_factor`

| Rank | factor |
|------|--------|
| E | 1.00 |
| D | 1.08 |
| C | 1.18 |
| B | 1.32 |
| A | 1.50 |
| S | 1.75 |

---

## 5. ステータス成長式

### モンスターマスター側で保持する値

各モンスターは stat ごとに以下を持つ。

- `base_{stat}`: Lv1 基準値
- `cap_{stat}`: その種の理論到達値
- `growth_curve_id`

### 基本式

```text
progress = clamp((level - 1) / max(1, effective_level_cap - 1), 0.0, 1.0)
curve(progress, growth_curve_id)

EARLY    = progress ^ 0.72
STANDARD = progress ^ 1.00
LATE     = progress ^ 1.28
LEGEND   = (exp(2.2 * progress) - 1) / (exp(2.2) - 1)

raw_stat =
  base_stat
  + floor((cap_stat - base_stat) * curve(progress, growth_curve_id))
  + lineage_bonus_stat
  + individuality_bonus_stat
  + mutation_bonus_stat

final_stat = floor(raw_stat * personality_multiplier_stat)
```

### 系譜補正

```text
lineage_bonus_hp  = plus_value * 2
lineage_bonus_mp  = plus_value * 1
lineage_bonus_atk = plus_value * 1
lineage_bonus_def = plus_value * 1
lineage_bonus_spd = floor(plus_value * 0.75)
lineage_bonus_int = floor(plus_value * 0.75)
lineage_bonus_res = floor(plus_value * 0.75)
```

### 個体差

各個体は生成時に `nature_seed` を1つ持つ。

| 項目 | 値 |
|------|----|
| favored stat | 1つ |
| weak stat | 1つ |
| favored bonus | `cap_stat * +5%` |
| weak penalty | `cap_stat * -5%` |

### 変異補正

変異種のみ、以下のどちらかを持つ。

- 主要2ステータスに `+8%`
- 主要1ステータスに `+15%`、副作用として別1ステータスに `-8%`

---

## 6. 物理 / 呪文 / 状態異常

### 物理ダメージ

```text
base_damage = floor(attacker.atk * 0.5) - floor(defender.def * 0.25)
stability   = random(0.85, 1.00)
final_damage = max(1, floor(base_damage * stability * element_modifier * crit_modifier))
```

### 呪文ダメージ

攻撃呪文は **ほぼ固定威力帯** とし、賢さで直接爆発させない。

```text
spell_damage = floor(base_spell_power * random(0.90, 1.10) * resist_modifier * field_modifier)
```

### 補助 / 状態異常成功率

```text
status_hit =
  skill_base_rate
  + floor((caster.int - target.res) * 0.15)
  + ailment_synergy_bonus
  + tactic_bonus

final_status_hit = clamp(status_hit, 5, 95)
```

### 行動順

```text
initiative = floor(spd * random(0.80, 1.05)) + tactic_speed_bonus
```

---

## 7. 配合とレベル依存

### 親レベルが効く箇所

| 要素 | 影響 |
|------|------|
| `plus_value` の増加量 | 親の合計Lvで増える |
| 継承ツリー枠 | 親の合計Lvで最大3枠まで拡張 |
| 特殊レシピ開放 | 一部は親Lv条件あり |
| 変異率 | 高世代 + 高Lvで微増 |

### 子の `plus_value`

```text
level_sum = parent_a.level + parent_b.level

level_bonus =
  0  if level_sum < 20
  1  if 20-39
  2  if 40-59
  3  if 60-89
  4  if 90-119
  5  if 120-159
  6  if 160+

child_plus =
  min(
    24,
    max(parent_a.plus_value, parent_b.plus_value)
    + level_bonus
    + special_recipe_bonus
    + mutation_plus_bonus
  )
```

| 補正 | 値 |
|------|----|
| `special_recipe_bonus` | 0 または +1 |
| `mutation_plus_bonus` | 0 または +1 |

### 継承ツリー枠

```text
inherit_tree_slots =
  2
  + 1 if level_sum >= 80
  capped at 3
```

### レベルによる配合結果の変化

- **種そのもの** は家系法則 / 特殊レシピ / 変異で決まる
- **親レベル** は、種の変化よりも `plus_value`, 継承枠, 変異率` に効かせる
- これにより「高レベルまで育てる理由」は強く残しつつ、「レベルを上げないとレシピ自体が読めない」窮屈さは避ける

### `plus_value` と要件定義「+2%/世代」の関係

要件定義（`02_game_design_core.md`）では「1回の配合につき +2%」と記述されているが、実装上はこれを離散的な `plus_value` システムで実現する。`plus_value` 1ポイントあたりの固定ステータス加算（上記 section 5 の `lineage_bonus` 式）は、一般的なステータス帯において元の +2% 設計意図を近似する。`plus_value` は親レベル合計に基づく `level_bonus` で増加するため、「しっかり育てて配合する」ことで世代ごとに着実に強化される設計意図は保たれている。`plus_value` hard cap 24 は、最大で HP +48 / ATK +24 等の加算となり、典型的な cap ステータスに対して概ね +2% × 多世代分に相当する。

---

## 8. ランダム性の扱い

### 基本ルール

- ランダムは以下に限定する
  - エンカウント間隔
  - エンカウントテーブル選出
  - 勧誘成功
  - ダメージブレ
  - 変異判定
  - 個体差 `nature_seed`
- 以下は決定論寄りにする
  - 主要レシピ
  - 成長カーブ
  - 主要ストーリー進行
  - 世界解放条件

---

## 9. エンカウント率

### ゾーンごとの設定値

| カラム | 説明 |
|--------|------|
| `encounter_min_steps` | 最短発生歩数 |
| `encounter_max_steps` | 最長発生歩数 |
| `terrain_rate` | 地形ごとの蓄積倍率 |
| `time_band` | 朝 / 昼 / 夕 / 夜 |
| `table_id` | 出現テーブル参照 |

### 発生式

ゾーン進入時に次遭遇歩数を決める。

```text
next_encounter = random(encounter_min_steps, encounter_max_steps)
encounter_meter += terrain_rate
if encounter_meter >= next_encounter:
  battle_start
  encounter_meter = 0
  next_encounter = random(encounter_min_steps, encounter_max_steps)
```

### 地形倍率

| 地形 | `terrain_rate` |
|------|---------------:|
| 村の道 | 0.00 |
| 草地 | 1.00 |
| 深草 | 1.20 |
| 洞窟 | 1.10 |
| 浅水 | 1.25 |
| 毒沼 | 1.35 |

### Vertical Slice の標準値

| ゾーン | min | max | 平均 |
|--------|----:|----:|-----:|
| 村外れ草地 | 14 | 24 | 19 |
| 塔前荒地 | 12 | 20 | 16 |
| 初期ダンジョン | 10 | 18 | 14 |

---

## 10. 勧誘成功率

### 基本式

```text
recruit_score =
  base_recruit
  + hp_bonus
  + status_bonus
  + bait_bonus
  + level_gap_bonus
  - duplicate_penalty
  - rank_penalty

final_recruit_rate = clamp(recruit_score, 1, 90)
```

### 各補正

| 要素 | 値 |
|------|----|
| `base_recruit` | モンスターごとに 8〜42 |
| `hp_bonus` | `floor((1 - hp_ratio) * 25)` |
| `status_bonus` | 毒 +3 / 麻痺 +6 / 眠り +10 |
| `bait_bonus` | 0 / +8 / +16 / +30 |
| `level_gap_bonus` | `clamp(player_avg_lv - enemy_lv, -8, +12)` |
| `duplicate_penalty` | 同種所持で -12 |
| `rank_penalty` | E 0 / D -4 / C -8 / B -16 / A -28 / S 勧誘不可 |

### 表示文言

| 内部成功率 | 表示 |
|-----------:|------|
| 1〜14 | まったく気を許していない |
| 15〜29 | まだ警戒している |
| 30〜49 | すこしこちらを見ている |
| 50〜69 | かなり気を許したようだ |
| 70〜90 | ついてきたがっている |

---

## 11. モチーフ設計ルール

### 全体配分の目安

| モチーフ群 | 構成比目安 |
|------------|-----------:|
| 動物 / 鳥 / 魚 / 虫 | 35% |
| 植物 / 菌類 / 種 / 蔓 | 15% |
| 鉱物 / 道具 / 家具 / 建材 | 15% |
| 神話 / 伝承 / 儀式 / 葬送 | 20% |
| 星 / 影 / 鏡 / 境界 / 抽象現象 | 15% |

### モチーフ原則

- 現実モチーフをそのまま可愛くするのでなく、**生活、禁忌、塔、失踪** の文脈で歪める
- 神話や古典は直接引用よりも、**断片化して混ぜる**
- 序盤モンスターは村の生活圏に根ざしたモチーフを優先する
- 高ランクになるほど、天体、葬送、神話、境界存在の比率を上げる

---

## 12. マスタースキーマ

### `monster_master.csv`

| カラム | 型 | 説明 |
|--------|----|------|
| `monster_id` | string | 一意ID |
| `slug` | string | 英字識別子 |
| `name_jp` | string | 日本語名 |
| `name_en` | string | 英語名 |
| `family` | enum | 系統 |
| `rank` | enum | E〜S |
| `size_class` | enum | S / M / L |
| `motif_group` | enum | animal / plant / object / myth / astral |
| `motif_source` | string | 具体モチーフ |
| `silhouette_type` | enum | round / tall / wide / cluster / serpentine |
| `palette_id` | string | パレット参照 |
| `field_sprite_px` | int | フィールドスプライトサイズ |
| `battle_sprite_px` | int | バトルスプライトサイズ |
| `base_level_cap` | int | 種族ベース上限 |
| `growth_curve_id` | enum | EARLY / STANDARD / LATE / LEGEND |
| `base_hp` | int | Lv1基準 |
| `cap_hp` | int | 理論到達値 |
| `base_mp` | int | Lv1基準 |
| `cap_mp` | int | 理論到達値 |
| `base_atk` | int | Lv1基準 |
| `cap_atk` | int | 理論到達値 |
| `base_def` | int | Lv1基準 |
| `cap_def` | int | 理論到達値 |
| `base_spd` | int | Lv1基準 |
| `cap_spd` | int | 理論到達値 |
| `base_int` | int | Lv1基準 |
| `cap_int` | int | 理論到達値 |
| `base_res` | int | Lv1基準 |
| `cap_res` | int | 理論到達値 |
| `base_recruit` | int | 勧誘基礎点 |
| `scoutable` | bool | 勧誘可否 |
| `personality_bias` | string | 出やすい性格傾向 |
| `trait_1` | string | 固有特性 |
| `trait_2` | string | 固有特性 |
| `loot_table_id` | string | ドロップ参照 |
| `prompt_id` | string | プロンプト参照 |
| `notes` | string | 備考 |

### `monster_resistance.csv`

| カラム | 型 | 説明 |
|--------|----|------|
| `monster_id` | string | モンスターID |
| `fire` | int | -2〜+2 |
| `water` | int | -2〜+2 |
| `wind` | int | -2〜+2 |
| `earth` | int | -2〜+2 |
| `thunder` | int | -2〜+2 |
| `light` | int | -2〜+2 |
| `dark` | int | -2〜+2 |
| `poison` | int | -2〜+2 |
| `sleep` | int | -2〜+2 |
| `paralysis` | int | -2〜+2 |
| `confusion` | int | -2〜+2 |
| `seal` | int | -2〜+2 |
| `fear` | int | -2〜+2 |
| `instant_death` | int | -2〜+2 |

### `monster_learnset.csv`

| カラム | 型 | 説明 |
|--------|----|------|
| `monster_id` | string | モンスターID |
| `learn_type` | enum | level / innate / breed / event |
| `learn_value` | int | 習得レベル等 |
| `skill_id` | string | スキルID |

### `skill_master.csv`

| カラム | 型 | 説明 |
|--------|----|------|
| `skill_id` | string | スキルID |
| `slug` | string | 英字識別子 |
| `name_jp` | string | 日本語名 |
| `name_en` | string | 英語名 |
| `category` | enum | physical / magic / status / recover / setup / utility |
| `element` | string | 属性キー |
| `mp_cost` | int | MP消費 |
| `target_scope` | string | single / spread / ally_single / self 等 |
| `formula_key` | string | ダメージ / 効果計算キー |
| `base_power` | int | 基礎威力 |
| `base_rate` | int | 命中 / 付与率等 |
| `tags` | string | `|` 区切りタグ |
| `battle_role` | string | AI評価ラベル |
| `effect_text` | string | 短い効果説明 |

### `item_master.csv`

| カラム | 型 | 説明 |
|--------|----|------|
| `item_id` | string | アイテムID |
| `slug` | string | 英字識別子 |
| `name_jp` | string | 日本語名 |
| `name_en` | string | 英語名 |
| `item_kind` | string | heal / mp / cure / bait / field / record / catalyst 等 |
| `subtype` | string | 補助分類 |
| `price` | int | 店売り価格 |
| `sell_price` | int | 売値 |
| `target_scope` | string | single / party / field 等 |
| `effect_key` | string | 実効果キー |
| `effect_value` | string | 数値または複合値 |
| `tags` | string | `|` 区切りタグ |
| `description` | string | 説明帯テキスト |

### `world_master.csv`

| カラム | 型 | 説明 |
|--------|----|------|
| `world_id` | string | 世界ID |
| `slug` | string | 英字識別子 |
| `name_jp` | string | 日本語名 |
| `name_en` | string | 英語名 |
| `act` | string | 幕 |
| `size_class` | enum | small / medium / large |
| `function_class` | string | `echo_world` など世界機能 |
| `level_min` | int | 推奨最低Lv |
| `level_max` | int | 推奨最高Lv |
| `taboo` | string | その世界の禁忌 |
| `biome` | string | 地形・環境 |
| `power_structure` | string | 支配構造 |
| `dominant_families` | string | `|` 区切り family |
| `gate_condition` | string | 解放条件メモ |
| `notes` | string | 備考 |

### `zone_master.csv`

| カラム | 型 | 説明 |
|--------|----|------|
| `zone_id` | string | ゾーンID |
| `world_id` | string | 所属世界 |
| `name_jp` | string | 日本語名 |
| `encounter_min_steps` | int | 最短遭遇歩数 |
| `encounter_max_steps` | int | 最長遭遇歩数 |
| `terrain_rate` | float | 地形補正 |
| `time_band` | enum | any / day / dusk / night |
| `weather` | enum | any / clear / rain / fog |
| `notes` | string | 備考 |

### `encounter_table.csv`

| カラム | 型 | 説明 |
|--------|----|------|
| `zone_id` | string | ゾーンID |
| `slot` | int | スロット番号 |
| `monster_id` | string | 出現モンスター |
| `weight` | int | 重み |
| `min_lv` | int | 最低Lv |
| `max_lv` | int | 最高Lv |
| `time_band` | enum | any / day / dusk / night |
| `weather` | enum | any / clear / rain / fog |

### `breed_rule.csv`

| カラム | 型 | 説明 |
|--------|----|------|
| `rule_id` | string | ルールID |
| `rule_type` | enum | family / special / mutation |
| `parent_a_key` | string | 系統 or monster_id |
| `parent_b_key` | string | 系統 or monster_id |
| `child_monster_id` | string | 生成結果 |
| `priority` | int | 高いほど先 |
| `special_recipe_bonus` | int | `plus_value` 補正 |
| `lv_requirement` | int | 親最低Lv条件 |
| `notes` | string | 備考 |
