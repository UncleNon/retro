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

### ゾーン別出現Lvレンジ

各ゾーンに出現するモンスターのLv帯と、プレイヤーの想定到達Lvの標準値。World tier が1上がるごとに +4 を基本とする。

| ゾーン | モンスターLv帯 | プレイヤー想定Lv |
|--------|---------------:|----------------:|
| 開始村外れ | 1–4 | 1–5 |
| 塔前荒地 | 2–5 | 3–6 |
| World 1 フィールド | 4–8 | 6–10 |
| World 1 ダンジョン | 6–10 | 8–12 |
| World 2 フィールド | 8–12 | 10–14 |
| World 2 ダンジョン | 10–14 | 12–16 |
| World 3 フィールド | 12–16 | 14–18 |
| World 3 ダンジョン | 14–18 | 16–20 |
| World 4 フィールド | 16–20 | 18–22 |
| World 4 ダンジョン | 18–22 | 20–24 |
| …以降 World tier +1 ごとに +4… | | |
| World 10 フィールド | 40–46 | 42–50 |
| World 10 ダンジョン | 44–50 | 46–54 |
| World 15 フィールド | 48–54 | 50–58 |
| World 15 ダンジョン | 50–56 | 52–60 |
| World 20 フィールド | 52–58 | 54–62 |
| World 20 ダンジョン | 56–64 | 58–66 |
| World 21（最終） | 60–68 | 62–70 |
| Postgame ダンジョン | 70–90 | 70–99 |

### 塔周辺・門近傍の野生変異出現

通常エンカウントに加え、特定ゾーンでは野生変異個体（色違い・ステータス偏差）が出現する。変異率は配合変異とは別系統で、encounter 側に持たせる。

| ゾーン種別 | 野生変異加算率 | 備考 |
|------------|-------------:|------|
| 塔前荒地 | +1% | base encounter mutation 0% に加算 |
| 塔内部 | +2% | 塔が門に近いほど高い |
| 門隣接ゾーン | +3% | gate state が Hungry 以上で適用 |

- 配合時の変異率（systems/03 の base 3%）とは **独立** に判定する
- 野生変異 = 通常種の色差分 or ステータス偏差個体。種族は変わらない
- 複数条件が重なった場合、加算率は **合算** する（例: 塔内部 + 門隣接 = +5%）
- 野生変異個体は勧誘可能だが `base_recruit` に -8 のペナルティが付く

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

---

## 13. Session Design Targets

プレイヤーのセッション長に応じて、達成できる体験と報酬密度を規定する。設計方針 ADR-0008「準備が勝ちを決める」「デフォルトは当時感」に基づき、どのセッション長でも前進感が残るように設計する。

### 13.1 セッション長ごとの体験設計

#### 5分セッション（通勤電車）

- バトル 1–2 回
- 勧誘チャンス 0–1 回
- 牧場確認、アイテム整理
- 目安: フィールド移動 + 1戦闘 + セーブで完結

#### 15分セッション（昼休み）

- ダンジョン1フロア踏破
- バトル 3–5 回
- 配合 1 回（事前に親を育てていた場合）
- パーティ入替、装備調整
- 目安: ダンジョン進入 → ボス前セーブポイント到達

#### 60分セッション（夕方じっくり）

- ダンジョン1つ完全攻略
- ストーリー進行（1世界の主要イベント）
- 配合 2–3 回
- 世界探索、NPC会話回収
- 門解放 or 闘技場ランク挑戦
- 目安: 1世界の主要導線を完了

### 13.2 報酬イベント発生間隔

| 報酬イベント | 目標発生間隔 | 対応セッション |
|-------------|-------------|---------------|
| レベルアップ | 戦闘 3–5 分ごと | 5分セッションでも1回は起きる |
| 新規勧誘成功 | 10–15 分ごと | 15分セッションで1体 |
| 配合機会 | 20–30 分ごと | 60分セッションで2–3回 |
| 新世界・門解放 | 60–90 分ごと | 60分セッション1回で到達可能 |
| ストーリー開示 | 30–60 分ごと | 15分×2–4回で1つ |

---

## 14. Reward Cadence

プレイヤー心理の「報酬点」を明確にし、ドーパミンヒットの間隔を管理する。

### 14.1 報酬イベントと演出

| 報酬イベント | 演出カテゴリ | 具体的な演出 |
|-------------|-------------|-------------|
| バトル勝利 | 小報酬 | 勝利ファンファーレ（1秒） + EXP獲得表示 + ドロップ表示 |
| 勧誘成功 | 中報酬 | 専用SE + 「○○はなかまになりたそうにこちらを見ている！」+ 加入演出 |
| レベルアップ | 中報酬 | レベルアップファンファーレ + ステータス上昇表示（差分強調） |
| 新スキル習得 | 中報酬 | スキル名表示 + 短いジングル + 効果テキスト |
| 配合誕生 | 大報酬 | 専用セレモニー（3–5秒）。親消滅 → 光演出 → 子登場。不可逆性の重みを演出で支える |
| 変異発見 | 大報酬 | 専用ジングル + 色変化エフェクト + 「突然変異が起きた！」テキスト |
| 門解放 | 特大報酬 | 門反応演出（5–8秒）。門の身体的描写 + 世界名表示 + 専用BGM切替 |
| 図鑑登録 | 小報酬 | 登録SE + 図鑑アイコン点滅（画面端） |
| 手がかり記録 | 中報酬 | 手がかりSE + 「手がかりが記録された」テキスト + 手帳アイコン点滅 |
| ボス撃破 | 特大報酬 | 専用ファンファーレ + 特殊ドロップ + ストーリー進行テキスト |

### 14.2 大報酬の最低間隔保証

「大報酬」以上（配合誕生、門解放、ボス撃破）は、プレイ中 **30分以上間が空かない** ように設計する。

- 30分間どの大報酬にも到達しない導線が発生した場合、以下のいずれかで補填する:
  - 闘技場ランク挑戦可能なタイミングを挟む
  - NPC からの手がかり開示を配置する
  - 配合可能な親の育成が完了する Lv 帯に到達させる
- この保証は「自動的に報酬を与える」のではなく、「報酬に到達できる導線を常に30分圏内に置く」ことで実現する

---

## 15. Information Disclosure Policy（ノートを取りたくなる設計）

ADR-0008「デフォルトは当時感」に基づき、プレイヤーが自分でメモを取りたくなるヒント密度を目指す。答えを教えすぎず、かつ理不尽に隠さない。

### 15.1 配合ヒント

- NPC の会話で系統の組み合わせを **曖昧に** 示唆する
  - 例:「獣と鳥を合わせると不思議なことが起きるそうじゃ」
  - 例:「植物の血に竜の気を混ぜた者がおったとか」
- 具体的なレシピ（monster_id + monster_id = 結果）は **一切** NPC から教えない
- 配合履歴に成功例は記録されるが、未試行の組み合わせ候補は表示しない

### 15.2 図鑑ヒント

- 発見済みモンスターは所属 family が表示される → 配合の系統絞り込みに使える
- 図鑑文に生態や由来の手がかりを含め、関連レシピの方向性を暗示する
- 「配合で生まれる」か「野生で出る」かの区別は図鑑に明示する

### 15.3 門条件ヒント

- 各世界の NPC が門条件の **部分的な** 手がかりを語る
  - 例:「この門は古い家印に反応するらしい」
  - 例:「闘技場で認められた者でないと、あの門は開かぬ」
- 具体的な条件値（「Lv15以上の beast が必要」等）は NPC からは教えない
- 門に近づいた際、反応の有無で条件充足を判断できる（反応なし / 微弱 / 強）

### 15.4 記録・手がかりアイテム

- 手がかりアイテムは入手時にテキストを表示するが、**何を意味するかは説明しない**
- 手帳UIに手がかりテキストを時系列で蓄積する
- プレイヤーが手がかり同士の関連を自分で見出すことを期待する

### 15.5 バトル弱点ヒント

- 弱点属性で攻撃した際、敵が **一瞬光る**（色は属性に対応）
- 「効果抜群」等の明示テキストは **表示しない**
- ダメージ数値の大きさで有効性を推測させる
- 属性相性表は **ゲーム内に存在しない**。プレイヤーが自分で記録する

### 15.6 設計目標

- プレイヤーが **メモを取りたくなる** が、 **取らなくても詰まない**
- メモを取ったプレイヤーは明確に有利になる（効率的な配合、弱点突き、門条件把握）
- 2周目プレイヤーは1周目のメモが活きる体験を得る
