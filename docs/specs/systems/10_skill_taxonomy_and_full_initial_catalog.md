# 10. Skill Taxonomy And Full Initial Catalog

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/specs/systems/01_numeric_rules_and_master_schema.md`
> - `docs/specs/content/02_initial_skill_set.md`
> - `docs/specs/systems/02_battle_and_ai_rules.md`
> - `docs/requirements/02_game_design_core.md`
> - `docs/specs/00_master_design_matrix.md`

---

## 1. 目的

- Master Design Matrix で `next` / `open` となっている以下のスキル関連項目をすべて解決する
  - スキルカテゴリ分類体系
  - スキル進化ライン
  - 範囲指定（単体 / 全体 / 列 / ランダム）
  - 呪文MPコスト法則
  - 状態異常特化ビルド設計
  - trait 発動優先順位
  - 固有特性の継承ルール
  - 世界固有スキル
  - 禁止スキルコンボ
- Vertical Slice の 36 技（`02_initial_skill_set.md`）を土台として、最初の 3〜4 世界を通じたフルカタログ（80 技 + 24 trait）を定義する
- 全スキルに正確な数値を与え、`skill_master.csv` にそのまま落とし込める粒度にする

---

## 2. スキルカテゴリ分類体系（Skill Category Taxonomy）

### 2.1 カテゴリ定義

| category_id | 名前 | 略称 | 定義 | MP消費 | 対象制約 |
|-------------|------|------|------|--------|----------|
| `PHY` | 物理攻撃 | 物理 | ATK 依存のダメージ技。属性は任意（none 可） | 0〜8 | 敵のみ |
| `MAG` | 魔法攻撃 | 魔法 | 固定威力帯ダメージ。属性必須 | 3〜16 | 敵のみ |
| `HEL` | 回復 | 回復 | HP / MP / 状態の回復 | 2〜12 | 味方のみ |
| `SUP` | 支援 | 支援 | バフ、壁、フィールド効果の付与 | 2〜10 | 味方のみ |
| `DEB` | 弱体 | 弱体 | ステータス低下、状態異常の付与 | 2〜10 | 敵のみ |
| `PAS` | 特性 | 特性 | 常時発動 / 条件発動の固有能力。MPなし | — | 自動 |
| `FLD` | 探索 | 探索 | 戦闘外のみ使用可。フィールド探索補助 | 0〜4 | フィールド |
| `REA` | 反応 | 反応 | 被攻撃、味方被弾、特定条件で自動発動する技 | 0〜6 | 自動 |

### 2.2 カテゴリ運用ルール

1. **PHY と MAG の区別**: PHY は `ATK * 0.5 - DEF * 0.25` を基盤とする。MAG は `base_spell_power` 固定帯を基盤とする。両方にダメージを出す複合技は PHY を主カテゴリとし、追加効果として MAG 計算を使う
2. **HEL と SUP の区別**: 即時 HP/MP 数値回復は HEL。ステータス段階上昇、壁付与、状態解除は SUP。回復 + 解除の複合技は HEL を主カテゴリとする
3. **DEB は敵対象のみ**: 味方へのデバフ（自傷系）は PHY の副作用として扱い、DEB とはしない
4. **PAS はスキル枠を消費しない**: 特性はモンスターごとに最大 2 枠の専用スロットで管理する。技上限 8 枠とは別管理
5. **REA は条件記述が必須**: `trigger_condition` を明記し、1 ラウンド 1 回までの発動制限を既定とする
6. **封印の対象**: `封印` 状態は MAG カテゴリを封じる。PHY は封印されない。SUP / HEL / DEB は `封印` で半減（成功率 -20）だが完全封鎖はしない

### 2.3 複合カテゴリの扱い

一部のスキルは複数カテゴリの性質を持つ。この場合、以下のルールに従う。

| パターン | 主カテゴリ | 判定ルール |
|----------|------------|------------|
| 物理 + 状態異常付与 | PHY | ダメージは PHY 式、状態異常は DEB 式で別判定 |
| 魔法 + 状態異常付与 | MAG | ダメージは MAG 式、状態異常は DEB 式で別判定 |
| 回復 + 状態解除 | HEL | 回復量は HEL 式、解除は自動成功 |
| 弱体 + 小ダメージ | DEB | ダメージは固定小値、弱体は DEB 式 |
| 支援 + 反応 | SUP | 付与時は SUP、発動時は REA として処理 |

---

## 3. 範囲指定（Range Types）

### 3.1 範囲一覧

| range_id | 表示名 | 対象数 | 効果補正 | 説明 |
|----------|--------|--------|----------|------|
| `SINGLE_ENEMY` | 敵単体 | 1 | 1.00 | 最も基本的な対象指定 |
| `ALL_ENEMY` | 敵全体 | 全敵 | 0.78 | 全体化による威力減衰あり |
| `RANDOM_ENEMY` | ランダム敵 | 1〜4体 | 0.65/hit | ヒット数はスキルごとに固定。同一対象への重複ヒット可 |
| `LINE_ENEMY` | 敵横列 | 1〜2体 | 0.85 | 前衛後衛概念を採用する場合のみ有効。不採用時は `ALL_ENEMY` にフォールバック |
| `SINGLE_ALLY` | 味方単体 | 1 | 1.00 | 回復・支援の基本対象 |
| `ALL_ALLY` | 味方全体 | 全味方 | 0.60 | 全体回復・全体バフ。効果量は大幅減衰 |
| `SELF` | 自身 | 1 | 1.00 | 自己強化、自己回復 |
| `SELF_AND_TARGET` | 自身→単体 | 1+1 | 特殊 | 攻撃後に自身へ効果を付与する複合技 |
| `FIELD` | 場 | 全体 | 特殊 | 敵味方全員に影響する場効果。持続ターン制 |

### 3.2 範囲運用ルール

1. **全体化の威力補正**: `ALL_ENEMY` の `spread_modifier = 0.78` は `02_initial_skill_set.md` の定義を踏襲する
2. **ランダム対象の重複**: `RANDOM_ENEMY` で同一対象に複数ヒットした場合、2 ヒット目以降はダメージ `-10%` ずつ減衰する（最大 4 ヒット時、4 撃目は `0.65 * 0.70 = 0.455` 相当）
3. **LINE_ENEMY のフォールバック**: 現設計では前衛後衛の位置概念は `open` 状態（Master Design Matrix §4）。採用しない場合、`LINE_ENEMY` スキルは `ALL_ENEMY` として処理し、`spread_modifier` を適用する
4. **FIELD の持続**: 場効果は上書き方式。新しい場効果が発動すると古い場効果は消滅する。同時に存在できる場効果は 1 つまで
5. **ALL_ALLY の回復減衰**: 全体回復は単体回復の `0.60` 倍。これにより単体ヒーラーの存在価値を保つ

### 3.3 ターゲット選択の優先順

AI がターゲットを自動選択する際の既定ルールは `02_battle_and_ai_rules.md` §7.8 を参照。ここではスキル側の制約のみ記す。

| range_id | ターゲット選択権 |
|----------|------------------|
| `SINGLE_ENEMY` | AI または MANUAL で選択 |
| `ALL_ENEMY` | 選択不要 |
| `RANDOM_ENEMY` | 選択不可（内部乱数で決定） |
| `SINGLE_ALLY` | AI または MANUAL で選択 |
| `ALL_ALLY` | 選択不要 |
| `SELF` | 選択不要 |
| `SELF_AND_TARGET` | 敵側のみ選択 |
| `FIELD` | 選択不要 |

---

## 4. MP コスト法則（Spell MP Cost Formula）

### 4.1 基本式

```text
base_mp_cost = floor(
  power_factor
  * range_factor
  * category_factor
  * rank_factor
)

final_mp_cost = max(0, base_mp_cost + flat_adjustment)
```

### 4.2 power_factor

スキルの威力帯に応じた基本コスト係数。

| 威力帯 | PHY `power_mod` | MAG `base_power` | `power_factor` |
|--------|-----------------|-------------------|---------------:|
| 微弱 | 0.75〜0.85 | 8〜12 | 1.5 |
| 小 | 0.90〜1.00 | 13〜18 | 2.5 |
| 中 | 1.05〜1.20 | 24〜38 | 4.0 |
| 大 | 1.25〜1.40 | 46〜70 | 6.5 |
| 特大 | 1.45〜1.60 | 82〜120 | 9.0 |

### 4.3 range_factor

| range_id | `range_factor` |
|----------|---------------:|
| `SINGLE_ENEMY` / `SINGLE_ALLY` / `SELF` | 1.00 |
| `ALL_ENEMY` / `ALL_ALLY` | 1.40 |
| `RANDOM_ENEMY` (2hit) | 1.10 |
| `RANDOM_ENEMY` (3hit) | 1.25 |
| `RANDOM_ENEMY` (4hit) | 1.40 |
| `LINE_ENEMY` | 1.20 |
| `FIELD` | 1.50 |
| `SELF_AND_TARGET` | 1.15 |

### 4.4 category_factor

| category_id | `category_factor` |
|-------------|-------------------:|
| PHY | 0.80 |
| MAG | 1.00 |
| HEL | 0.90 |
| SUP | 0.85 |
| DEB | 0.90 |
| REA | 0.70 |
| FLD | 0.50 |

### 4.5 rank_factor

スキルの「格」を示す。進化前 → 進化後で rank が上がる。

| skill_rank | `rank_factor` | 説明 |
|------------|---------------:|------|
| I | 1.00 | 序盤基本技 |
| II | 1.15 | 中盤標準技 |
| III | 1.35 | 終盤 / 配合技 |
| IV | 1.60 | 上位種専用 / 世界固有 |

### 4.6 flat_adjustment

特殊効果に応じた固定加減算。

| 条件 | 調整値 |
|------|-------:|
| 状態異常を副次的に付与 | +1 |
| 自傷・反動あり | -1 |
| `marked` 消費で効果増加 | +1 |
| MP 0 技（基本攻撃クラス） | 結果を 0 に固定 |
| 場効果付与 | +2 |

### 4.7 計算例

`きざみかぜ`（MAG, base_power 14 = 小帯, ALL_ENEMY, rank I）:
```
base_mp_cost = floor(2.5 * 1.40 * 1.00 * 1.00) = floor(3.50) = 3
flat_adjustment = 0
final_mp_cost = 3
```
実装値は 4（+1 の設計余裕を持たせた）。法則からの ±1 は許容範囲とする。

`ねむりごな`（DEB, base_rate 44, SINGLE_ENEMY, rank I）:
```
base_mp_cost = floor(4.0 * 1.00 * 0.90 * 1.00) = floor(3.60) = 3
flat_adjustment = +1（状態異常主目的）
final_mp_cost = 4
```
実装値は 5（睡眠の強力さを考慮し +1 の設計バイアス）。

### 4.8 運用ノート

- MP コスト法則は **目安** であり、最終値はバランステストで ±2 の範囲で調整してよい
- MP 0 の基本攻撃（たいあたり、ついばむ等）は法則の例外として 0 固定
- trait / 特性は MP を消費しない

---

## 5. スキル進化ライン（Skill Evolution Lines）

### 5.1 進化の基本ルール

1. **進化条件**: モンスターが特定レベルに達し、かつ前段階のスキルを習得済みであること
2. **進化時の挙動**: 前段階スキルを「上書き」する。技枠は消費しない。ただしプレイヤーに確認を求め、拒否すると前段階を維持できる
3. **継承時の挙動**: 配合で親が進化後スキルを持っていた場合、子は **前段階** を継承する。子が自力で進化条件を満たせば再進化できる
4. **進化段階**: 最大 3 段階（I → II → III）。一部の特殊技は 2 段階で止まる

### 5.2 進化ラインの設計原則

- 進化は **威力の上昇 + MP コストの上昇** を基本とする
- 一部の進化は威力据え置きで **範囲拡大** または **追加効果付与** を行う
- 進化ごとに `skill_rank` が 1 段階上がる

### 5.3 進化ライン一覧

#### 5.3.1 物理進化ライン

| ライン名 | I (Lv1〜) | II (Lv18〜) | III (Lv35〜) |
|----------|-----------|-------------|--------------|
| 突撃系 | たいあたり (SKL-001) | つきあたり (SKL-041) | すてみのいちげき (SKL-042) |
| 角撃系 | ちいさなつの (SKL-005) | するどいつの (SKL-043) | みだれづき (SKL-044) |
| 噛撃系 | かじる (SKL-004) | くいちぎる (SKL-045) | ほねくだき (SKL-046) |
| 翼撃系 | ついばむ (SKL-002) | かぜのくちばし (SKL-047) | しんくうのつばさ (SKL-048) |

#### 5.3.2 魔法進化ライン

| ライン名 | I (Lv1〜) | II (Lv20〜) | III (Lv38〜) |
|----------|-----------|-------------|--------------|
| 風刃系 | きざみかぜ (SKL-034) | かまいたち (SKL-049) | しんくうは (SKL-050) |
| 闇翼系 | くらがりはね (SKL-019) | よるのはばたき (SKL-051) | やみのあらし (SKL-052) |
| 火系 | ひだね (SKL-053) | ほのおのいき (SKL-054) | れんごく (SKL-055) |
| 水系 | みずのたま (SKL-056) | うずしお (SKL-057) | こうずい (SKL-058) |
| 雷系 | いなびかり (SKL-059) | いかずち (SKL-060) | らいめい (SKL-061) |
| 光系 | ひかりのやいば (SKL-062) | せいなるひかり (SKL-063) | — |

#### 5.3.3 回復進化ライン

| ライン名 | I (Lv1〜) | II (Lv22〜) | III (Lv40〜) |
|----------|-----------|-------------|--------------|
| 草薬系 | くさのしずく (SKL-021) | みどりのしずく (SKL-064) | いのちのしずく (SKL-065) |
| 星水系 | ほしみず (SKL-027) | つきのしずく (SKL-066) | — |
| 浄化系 | こすりなおし (SKL-025) | あらいながし (SKL-067) | おおはらい (SKL-068) |

#### 5.3.4 状態異常進化ライン

| ライン名 | I (Lv1〜) | II (Lv20〜) | III (Lv36〜) |
|----------|-----------|-------------|--------------|
| 毒系 | どくこな (SKL-014) | もうどく (SKL-069) | しのどく (SKL-070) |
| 睡眠系 | ねむりごな (SKL-015) | ふかいねむり (SKL-071) | — |
| 封印系 | ふういん (SKL-018) | だいふういん (SKL-072) | — |

### 5.4 進化レベル閾値

| skill_rank 遷移 | 必要レベル帯 | 備考 |
|-----------------|-------------|------|
| I → II | Lv 18〜22 | 世界 2〜3 の攻略レベル帯 |
| II → III | Lv 35〜40 | 世界 5〜7 の攻略レベル帯 |
| III → IV | Lv 55+ | endgame 手前、配合ルート必須級 |

### 5.5 配合継承時の進化挙動

```text
if parent has evolved_skill (rank II or higher):
  child inherits base_skill (rank I)
  child can re-evolve when reaching evolution_level threshold

if both parents have same evolved_skill:
  child inherits base_skill at rank I
  evolution_level_threshold reduced by 3 levels (bonus)
```

---

## 6. フルスキルカタログ（80 技）

### 6.1 凡例

| 項目 | 説明 |
|------|------|
| `skill_id` | SKL-### 形式の一意 ID |
| `name_jp` / `name_en` | 日本語名 / 英語名 |
| `category` | §2 のカテゴリ ID |
| `element` | none / fire / water / wind / earth / thunder / light / dark |
| `range` | §3 の range_id |
| `mp_cost` | MP 消費量 |
| `power` | PHY: power_mod / MAG: base_power / HEL: base_power |
| `accuracy` | 命中率 / 成功率（基底値） |
| `status_effect` | 付与する状態異常（rate% で記載） |
| `ai_tag` | AI 行動評価用タグ |
| `desc_strip` | 説明帯テキスト（18 文字以内） |
| `learn_src` | level / breed / event / world |
| `evo_from` | 進化元 skill_id（なければ —） |
| `evo_to` | 進化先 skill_id（なければ —） |
| `forbidden` | 同時習得禁止の skill_id（なければ —） |

### 6.2 物理攻撃（PHY）— 20 技

#### SKL-001 たいあたり / Body Slam
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | none |
| range | SINGLE_ENEMY |
| mp_cost | 0 |
| power | power_mod 1.00 |
| accuracy | 95 |
| status_effect | — |
| ai_tag | SAFE_POKE |
| desc_strip | からだでぶつかる |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | SKL-041 |
| forbidden | — |

#### SKL-002 ついばむ / Peck
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | wind |
| range | SINGLE_ENEMY |
| mp_cost | 0 |
| power | power_mod 1.05 |
| accuracy | 97 |
| status_effect | wet 対象に +10% damage |
| ai_tag | RUSH_OPEN |
| desc_strip | くちばしでつつく |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | SKL-047 |
| forbidden | — |

#### SKL-003 ひっかく / Scratch
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | dark |
| range | SINGLE_ENEMY |
| mp_cost | 0 |
| power | power_mod 1.00 |
| accuracy | 98 |
| status_effect | crit_bonus +5% |
| ai_tag | SAFE_POKE |
| desc_strip | するどくひっかく |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-004 かじる / Gnaw
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | earth |
| range | SINGLE_ENEMY |
| mp_cost | 2 |
| power | power_mod 1.10 |
| accuracy | 92 |
| status_effect | fear 15% |
| ai_tag | BREAK_DEF |
| desc_strip | かみついてえぐる |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | SKL-045 |
| forbidden | — |

#### SKL-005 ちいさなつの / Small Horn
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | earth |
| range | SINGLE_ENEMY |
| mp_cost | 2 |
| power | power_mod 1.15 |
| accuracy | 93 |
| status_effect | softened 20% |
| ai_tag | BREAK_DEF |
| desc_strip | つのでつきあげる |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | SKL-043 |
| forbidden | — |

#### SKL-006 つつく / Prod
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | wind |
| range | SINGLE_ENEMY |
| mp_cost | 1 |
| power | power_mod 0.95 |
| accuracy | 100 |
| status_effect | marked 対象に +15% damage |
| ai_tag | RUSH_OPEN |
| desc_strip | するどくつつく |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-007 かすりきず / Graze
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | none |
| range | SINGLE_ENEMY |
| mp_cost | 1 |
| power | power_mod 0.80 |
| accuracy | 100 |
| status_effect | — |
| ai_tag | SAFE_POKE |
| desc_strip | かるくきずつける |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-008 とびのく / Leap Back
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | wind |
| range | SELF_AND_TARGET |
| mp_cost | 3 |
| power | power_mod 0.75 |
| accuracy | 100 |
| status_effect | self: evasion +20% until next hit |
| ai_tag | RUSH_OPEN |
| desc_strip | うちこみ かわす |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-009 みみうち / Ear Slap
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | none |
| range | SINGLE_ENEMY |
| mp_cost | 2 |
| power | power_mod 0.85 |
| accuracy | 95 |
| status_effect | hushed 28% |
| ai_tag | CONTROL |
| desc_strip | みみを うちつける |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-010 しるしうばい / Mark Rend
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | dark |
| range | SINGLE_ENEMY |
| mp_cost | 4 |
| power | power_mod 0.90 (marked: +35%) |
| accuracy | 92 |
| status_effect | consumes marked, strips 1 buff |
| ai_tag | PAYOFF |
| desc_strip | 印をえぐりとる |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-011 きおくのひづめ / Memory Hoof
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | light |
| range | SINGLE_ENEMY |
| mp_cost | 5 |
| power | power_mod 1.35 (HP≤50%: +10%) |
| accuracy | 90 |
| status_effect | self-damage: max_hp * 0.05 |
| ai_tag | PAYOFF |
| desc_strip | いたみごと ふみこむ |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-012 あしもとくずし / Leg Sweep
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | earth |
| range | SINGLE_ENEMY |
| mp_cost | 3 |
| power | power_mod 0.90 |
| accuracy | 94 |
| status_effect | SPD -1 stage 65% |
| ai_tag | BREAK_DEF |
| desc_strip | あしをはらう |
| learn_src | level |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-041 つきあたり / Charge Rush
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | none |
| range | SINGLE_ENEMY |
| mp_cost | 3 |
| power | power_mod 1.20 |
| accuracy | 93 |
| status_effect | — |
| ai_tag | SAFE_POKE |
| desc_strip | いきおいよく つく |
| learn_src | level (Lv18+) |
| evo_from | SKL-001 |
| evo_to | SKL-042 |
| forbidden | — |

#### SKL-042 すてみのいちげき / Reckless Blow
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | none |
| range | SINGLE_ENEMY |
| mp_cost | 6 |
| power | power_mod 1.55 |
| accuracy | 88 |
| status_effect | self-damage: max_hp * 0.08 |
| ai_tag | PAYOFF |
| desc_strip | いのちがけの一撃 |
| learn_src | level (Lv35+) |
| evo_from | SKL-041 |
| evo_to | — |
| forbidden | — |

#### SKL-043 するどいつの / Sharp Horn
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | earth |
| range | SINGLE_ENEMY |
| mp_cost | 4 |
| power | power_mod 1.30 |
| accuracy | 91 |
| status_effect | softened 30% |
| ai_tag | BREAK_DEF |
| desc_strip | つのを深くさす |
| learn_src | level (Lv18+) |
| evo_from | SKL-005 |
| evo_to | SKL-044 |
| forbidden | — |

#### SKL-044 みだれづき / Wild Thrust
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | earth |
| range | RANDOM_ENEMY (3hit) |
| mp_cost | 7 |
| power | power_mod 0.65/hit |
| accuracy | 90 |
| status_effect | softened 15%/hit |
| ai_tag | BREAK_DEF |
| desc_strip | 3回つきまくる |
| learn_src | level (Lv36+) |
| evo_from | SKL-043 |
| evo_to | — |
| forbidden | — |

#### SKL-045 くいちぎる / Tear Bite
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | earth |
| range | SINGLE_ENEMY |
| mp_cost | 4 |
| power | power_mod 1.25 |
| accuracy | 90 |
| status_effect | fear 25% |
| ai_tag | BREAK_DEF |
| desc_strip | にくをくいちぎる |
| learn_src | level (Lv20+) |
| evo_from | SKL-004 |
| evo_to | SKL-046 |
| forbidden | — |

#### SKL-046 ほねくだき / Bone Crush
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | earth |
| range | SINGLE_ENEMY |
| mp_cost | 7 |
| power | power_mod 1.45 |
| accuracy | 88 |
| status_effect | DEF -1 stage 40%, fear 20% |
| ai_tag | BREAK_DEF |
| desc_strip | ほねごとかみくだく |
| learn_src | level (Lv38+) |
| evo_from | SKL-045 |
| evo_to | — |
| forbidden | — |

#### SKL-047 かぜのくちばし / Wind Beak
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | wind |
| range | SINGLE_ENEMY |
| mp_cost | 3 |
| power | power_mod 1.20 |
| accuracy | 96 |
| status_effect | wet 対象に +15% damage |
| ai_tag | RUSH_OPEN |
| desc_strip | かぜをまとい つく |
| learn_src | level (Lv18+) |
| evo_from | SKL-002 |
| evo_to | SKL-048 |
| forbidden | — |

#### SKL-048 しんくうのつばさ / Vacuum Wing
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | wind |
| range | ALL_ENEMY |
| mp_cost | 7 |
| power | power_mod 0.85 |
| accuracy | 94 |
| status_effect | wet 対象に +20% damage |
| ai_tag | RUSH_OPEN |
| desc_strip | 真空のつばさで薙ぐ |
| learn_src | level (Lv36+) |
| evo_from | SKL-047 |
| evo_to | — |
| forbidden | — |

### 6.3 魔法攻撃（MAG）— 16 技

#### SKL-019 くらがりはね / Dark Feather
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | dark |
| range | ALL_ENEMY |
| mp_cost | 5 |
| power | base_power 10 |
| accuracy | 85 |
| status_effect | soot 30% |
| ai_tag | CONTROL |
| desc_strip | やみのはねをまく |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | SKL-051 |
| forbidden | — |

#### SKL-034 きざみかぜ / Cutting Wind
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | wind |
| range | ALL_ENEMY |
| mp_cost | 4 |
| power | base_power 14 |
| accuracy | 100 |
| status_effect | — |
| ai_tag | RUSH_OPEN |
| desc_strip | かぜがきりつける |
| learn_src | level |
| evo_from | — |
| evo_to | SKL-049 |
| forbidden | — |

#### SKL-049 かまいたち / Razor Gale
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | wind |
| range | ALL_ENEMY |
| mp_cost | 7 |
| power | base_power 28 |
| accuracy | 100 |
| status_effect | — |
| ai_tag | RUSH_OPEN |
| desc_strip | するどいかぜが走る |
| learn_src | level (Lv20+) |
| evo_from | SKL-034 |
| evo_to | SKL-050 |
| forbidden | — |

#### SKL-050 しんくうは / Vacuum Blade
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | wind |
| range | ALL_ENEMY |
| mp_cost | 12 |
| power | base_power 52 |
| accuracy | 100 |
| status_effect | — |
| ai_tag | RUSH_OPEN |
| desc_strip | 真空のやいばが裂く |
| learn_src | level (Lv38+) |
| evo_from | SKL-049 |
| evo_to | — |
| forbidden | — |

#### SKL-051 よるのはばたき / Night Flutter
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | dark |
| range | ALL_ENEMY |
| mp_cost | 8 |
| power | base_power 24 |
| accuracy | 88 |
| status_effect | soot 35% |
| ai_tag | CONTROL |
| desc_strip | やみのはばたき |
| learn_src | level (Lv20+) |
| evo_from | SKL-019 |
| evo_to | SKL-052 |
| forbidden | — |

#### SKL-052 やみのあらし / Dark Storm
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | dark |
| range | ALL_ENEMY |
| mp_cost | 14 |
| power | base_power 48 |
| accuracy | 90 |
| status_effect | soot 40%, fear 15% |
| ai_tag | CONTROL |
| desc_strip | 闇が渦を巻く |
| learn_src | level (Lv38+) |
| evo_from | SKL-051 |
| evo_to | — |
| forbidden | — |

#### SKL-053 ひだね / Ember
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | fire |
| range | SINGLE_ENEMY |
| mp_cost | 3 |
| power | base_power 16 |
| accuracy | 100 |
| status_effect | — |
| ai_tag | SAFE_POKE |
| desc_strip | ちいさな火をとばす |
| learn_src | level |
| evo_from | — |
| evo_to | SKL-054 |
| forbidden | — |

#### SKL-054 ほのおのいき / Fire Breath
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | fire |
| range | ALL_ENEMY |
| mp_cost | 8 |
| power | base_power 26 |
| accuracy | 100 |
| status_effect | — |
| ai_tag | RUSH_OPEN |
| desc_strip | ほのおを はきだす |
| learn_src | level (Lv20+) |
| evo_from | SKL-053 |
| evo_to | SKL-055 |
| forbidden | — |

#### SKL-055 れんごく / Inferno
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | fire |
| range | ALL_ENEMY |
| mp_cost | 14 |
| power | base_power 56 |
| accuracy | 100 |
| status_effect | — |
| ai_tag | RUSH_OPEN |
| desc_strip | すべてを焼きつくす |
| learn_src | level (Lv40+) |
| evo_from | SKL-054 |
| evo_to | — |
| forbidden | — |

#### SKL-056 みずのたま / Aqua Orb
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | water |
| range | SINGLE_ENEMY |
| mp_cost | 3 |
| power | base_power 15 |
| accuracy | 100 |
| status_effect | wet 20% |
| ai_tag | SAFE_POKE |
| desc_strip | 水の玉をぶつける |
| learn_src | level |
| evo_from | — |
| evo_to | SKL-057 |
| forbidden | — |

#### SKL-057 うずしお / Whirlpool
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | water |
| range | ALL_ENEMY |
| mp_cost | 8 |
| power | base_power 24 |
| accuracy | 100 |
| status_effect | wet 30% |
| ai_tag | RUSH_OPEN |
| desc_strip | 水流がうずをまく |
| learn_src | level (Lv22+) |
| evo_from | SKL-056 |
| evo_to | SKL-058 |
| forbidden | — |

#### SKL-058 こうずい / Deluge
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | water |
| range | ALL_ENEMY |
| mp_cost | 13 |
| power | base_power 50 |
| accuracy | 100 |
| status_effect | wet 40% |
| ai_tag | RUSH_OPEN |
| desc_strip | 大水が すべてのむ |
| learn_src | level (Lv38+) |
| evo_from | SKL-057 |
| evo_to | — |
| forbidden | — |

#### SKL-059 いなびかり / Spark
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | thunder |
| range | SINGLE_ENEMY |
| mp_cost | 4 |
| power | base_power 18 |
| accuracy | 95 |
| status_effect | paralysis 15% |
| ai_tag | STATUS_SETUP |
| desc_strip | いなずまが走る |
| learn_src | level |
| evo_from | — |
| evo_to | SKL-060 |
| forbidden | — |

#### SKL-060 いかずち / Thunderbolt
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | thunder |
| range | SINGLE_ENEMY |
| mp_cost | 8 |
| power | base_power 36 |
| accuracy | 92 |
| status_effect | paralysis 22% |
| ai_tag | STATUS_SETUP |
| desc_strip | かみなりがうつ |
| learn_src | level (Lv22+) |
| evo_from | SKL-059 |
| evo_to | SKL-061 |
| forbidden | — |

#### SKL-061 らいめい / Thunder Roar
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | thunder |
| range | ALL_ENEMY |
| mp_cost | 14 |
| power | base_power 46 |
| accuracy | 90 |
| status_effect | paralysis 28% |
| ai_tag | STATUS_SETUP |
| desc_strip | 雷鳴がとどろく |
| learn_src | level (Lv38+) |
| evo_from | SKL-060 |
| evo_to | — |
| forbidden | — |

#### SKL-062 ひかりのやいば / Light Blade
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | light |
| range | SINGLE_ENEMY |
| mp_cost | 5 |
| power | base_power 22 |
| accuracy | 100 |
| status_effect | undead 対象に +30% damage |
| ai_tag | SAFE_POKE |
| desc_strip | ひかりの刃をとばす |
| learn_src | level |
| evo_from | — |
| evo_to | SKL-063 |
| forbidden | — |

#### SKL-063 せいなるひかり / Sacred Light
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | light |
| range | ALL_ENEMY |
| mp_cost | 10 |
| power | base_power 38 |
| accuracy | 100 |
| status_effect | undead 対象に +30% damage |
| ai_tag | RUSH_OPEN |
| desc_strip | 聖なるひかりが降る |
| learn_src | level (Lv28+) |
| evo_from | SKL-062 |
| evo_to | — |
| forbidden | — |

### 6.4 回復（HEL）— 8 技

#### SKL-021 くさのしずく / Herb Drop
| 項目 | 値 |
|------|-----|
| category | HEL |
| element | water |
| range | SINGLE_ALLY |
| mp_cost | 3 |
| power | base_power 16 |
| accuracy | 100 |
| status_effect | — |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | くさのしずくで癒す |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | SKL-064 |
| forbidden | — |

#### SKL-025 こすりなおし / Rub Clean
| 項目 | 値 |
|------|-----|
| category | HEL |
| element | light |
| range | SINGLE_ALLY |
| mp_cost | 3 |
| power | base_power 10 |
| accuracy | 100 |
| status_effect | removes soot, hushed |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | けがれをぬぐう |
| learn_src | level |
| evo_from | — |
| evo_to | SKL-067 |
| forbidden | — |

#### SKL-027 ほしみず / Star Water
| 項目 | 値 |
|------|-----|
| category | HEL |
| element | light |
| range | SINGLE_ALLY |
| mp_cost | 5 |
| power | base_power 12 |
| accuracy | 100 |
| status_effect | MP recovery +4 |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | ほしのみずで癒す |
| learn_src | level |
| evo_from | — |
| evo_to | SKL-066 |
| forbidden | — |

#### SKL-064 みどりのしずく / Verdant Drop
| 項目 | 値 |
|------|-----|
| category | HEL |
| element | water |
| range | SINGLE_ALLY |
| mp_cost | 5 |
| power | base_power 32 |
| accuracy | 100 |
| status_effect | — |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | みどりのしずくで癒す |
| learn_src | level (Lv22+) |
| evo_from | SKL-021 |
| evo_to | SKL-065 |
| forbidden | — |

#### SKL-065 いのちのしずく / Life Drop
| 項目 | 値 |
|------|-----|
| category | HEL |
| element | water |
| range | ALL_ALLY |
| mp_cost | 10 |
| power | base_power 28 |
| accuracy | 100 |
| status_effect | — |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | いのちの水がおちる |
| learn_src | level (Lv40+) |
| evo_from | SKL-064 |
| evo_to | — |
| forbidden | — |

#### SKL-066 つきのしずく / Moon Drop
| 項目 | 値 |
|------|-----|
| category | HEL |
| element | light |
| range | SINGLE_ALLY |
| mp_cost | 8 |
| power | base_power 22 |
| accuracy | 100 |
| status_effect | MP recovery +8 |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | つきの光がしみる |
| learn_src | level (Lv24+) |
| evo_from | SKL-027 |
| evo_to | — |
| forbidden | — |

#### SKL-067 あらいながし / Rinse Away
| 項目 | 値 |
|------|-----|
| category | HEL |
| element | light |
| range | SINGLE_ALLY |
| mp_cost | 5 |
| power | base_power 18 |
| accuracy | 100 |
| status_effect | removes soot, hushed, poison, fear |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | あらいながして清める |
| learn_src | level (Lv22+) |
| evo_from | SKL-025 |
| evo_to | SKL-068 |
| forbidden | — |

#### SKL-068 おおはらい / Grand Purge
| 項目 | 値 |
|------|-----|
| category | HEL |
| element | light |
| range | ALL_ALLY |
| mp_cost | 10 |
| power | base_power 12 |
| accuracy | 100 |
| status_effect | removes all negative status from party |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | すべてのけがれを祓う |
| learn_src | level (Lv40+) |
| evo_from | SKL-067 |
| evo_to | — |
| forbidden | — |

### 6.5 弱体 / 状態異常（DEB）— 14 技

#### SKL-013 すすはき / Soot Sweep
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | dark |
| range | SINGLE_ENEMY |
| mp_cost | 2 |
| power | — |
| accuracy | 48 |
| status_effect | soot (accuracy -10%, recruit +4) |
| ai_tag | CONTROL |
| desc_strip | すすをまきちらす |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-014 どくこな / Poison Powder
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | none |
| range | SINGLE_ENEMY |
| mp_cost | 3 |
| power | — |
| accuracy | 55 |
| status_effect | poison 4T |
| ai_tag | STATUS_SETUP |
| desc_strip | どくのこなをまく |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | SKL-069 |
| forbidden | SKL-070 と同時習得不可 |

#### SKL-015 ねむりごな / Sleep Powder
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | none |
| range | SINGLE_ENEMY |
| mp_cost | 5 |
| power | — |
| accuracy | 44 |
| status_effect | sleep 1-3T |
| ai_tag | STATUS_SETUP |
| desc_strip | ねむりのこなをまく |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | SKL-071 |
| forbidden | — |

#### SKL-016 まよわせる / Confuse
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | dark |
| range | SINGLE_ENEMY |
| mp_cost | 4 |
| power | — |
| accuracy | 42 |
| status_effect | confusion 2-3T |
| ai_tag | CONTROL |
| desc_strip | こころをまよわせる |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-017 ささやき / Whisper
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | dark |
| range | SINGLE_ENEMY |
| mp_cost | 3 |
| power | — |
| accuracy | 52 |
| status_effect | fear 50% or hushed 50% (random pick) |
| ai_tag | CONTROL |
| desc_strip | ささやきが聞こえる |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-018 ふういん / Seal
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | light |
| range | SINGLE_ENEMY |
| mp_cost | 4 |
| power | — |
| accuracy | 46 |
| status_effect | seal 3T (MAG category locked) |
| ai_tag | CONTROL |
| desc_strip | じゅもんをふうじる |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | SKL-072 |
| forbidden | — |

#### SKL-020 みみざわりの鈴 / Discordant Bell
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | none |
| range | ALL_ENEMY |
| mp_cost | 4 |
| power | — |
| accuracy | 35 |
| status_effect | hushed 3T |
| ai_tag | CONTROL |
| desc_strip | 鈴の音が耳をさす |
| learn_src | level |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-026 ぬめり / Slime Coat
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | water |
| range | SINGLE_ENEMY |
| mp_cost | 3 |
| power | — |
| accuracy | 95 |
| status_effect | SPD -1 stage, escape rate -15% |
| ai_tag | BREAK_DEF |
| desc_strip | ぬめりで足をとる |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-035 まきつきつる / Binding Vine
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | earth |
| range | SINGLE_ENEMY |
| mp_cost | 4 |
| power | — |
| accuracy | 50 |
| status_effect | paralysis-like bind 1-2T |
| ai_tag | STATUS_SETUP |
| desc_strip | つるが足にまきつく |
| learn_src | level |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-036 にぶいひかり / Dim Light
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | light |
| range | SINGLE_ENEMY |
| mp_cost | 3 |
| power | — |
| accuracy | 92 |
| status_effect | INT -1 stage, RES -1 stage |
| ai_tag | BREAK_DEF |
| desc_strip | にぶい光がつつむ |
| learn_src | level |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-069 もうどく / Vile Toxin
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | none |
| range | SINGLE_ENEMY |
| mp_cost | 5 |
| power | — |
| accuracy | 60 |
| status_effect | poison 4T (damage = max_hp * 1/10) |
| ai_tag | STATUS_SETUP |
| desc_strip | 猛毒がからだをむしばむ |
| learn_src | level (Lv20+) |
| evo_from | SKL-014 |
| evo_to | SKL-070 |
| forbidden | — |

#### SKL-070 しのどく / Death Venom
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | dark |
| range | SINGLE_ENEMY |
| mp_cost | 8 |
| power | — |
| accuracy | 50 |
| status_effect | poison 4T (damage = max_hp * 1/8) + ATK -1 stage |
| ai_tag | STATUS_SETUP |
| desc_strip | 死の毒がまわる |
| learn_src | level (Lv36+) / breed |
| evo_from | SKL-069 |
| evo_to | — |
| forbidden | SKL-014 と同時習得不可 |

#### SKL-071 ふかいねむり / Deep Slumber
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | none |
| range | SINGLE_ENEMY |
| mp_cost | 8 |
| power | — |
| accuracy | 48 |
| status_effect | sleep 2-4T (wake on damage reduced to 20%) |
| ai_tag | STATUS_SETUP |
| desc_strip | ふかいねむりにおちる |
| learn_src | level (Lv22+) |
| evo_from | SKL-015 |
| evo_to | — |
| forbidden | — |

#### SKL-072 だいふういん / Grand Seal
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | light |
| range | ALL_ENEMY |
| mp_cost | 8 |
| power | — |
| accuracy | 38 |
| status_effect | seal 3T (MAG + SUP locked) |
| ai_tag | CONTROL |
| desc_strip | 大いなる封印をかける |
| learn_src | level (Lv24+) |
| evo_from | SKL-018 |
| evo_to | — |
| forbidden | — |

### 6.6 支援（SUP）— 6 技

#### SKL-022 しめり / Moisten
| 項目 | 値 |
|------|-----|
| category | SUP |
| element | water |
| range | SINGLE_ALLY |
| mp_cost | 3 |
| power | — |
| accuracy | 100 |
| status_effect | wet 3T (fire damage -20%, thunder damage +10%) |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | しめりをまとわせる |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-023 やわらかいかべ / Soft Wall
| 項目 | 値 |
|------|-----|
| category | SUP |
| element | earth |
| range | SINGLE_ALLY |
| mp_cost | 4 |
| power | — |
| accuracy | 100 |
| status_effect | guard_shell 3T (physical + earth damage * 0.80) |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | やわらかい壁がまもる |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-024 かばいだて / Bolster
| 項目 | 値 |
|------|-----|
| category | SUP |
| element | none |
| range | SINGLE_ALLY |
| mp_cost | 2 |
| power | — |
| accuracy | 100 |
| status_effect | DEF +1 stage 3T |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | まもりをかためる |
| learn_src | level |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-073 ちからづけ / Embolden
| 項目 | 値 |
|------|-----|
| category | SUP |
| element | none |
| range | SINGLE_ALLY |
| mp_cost | 3 |
| power | — |
| accuracy | 100 |
| status_effect | ATK +1 stage 3T |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | ちからを奮いたたす |
| learn_src | level |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-074 はやめのうた / Hastening Song
| 項目 | 値 |
|------|-----|
| category | SUP |
| element | wind |
| range | ALL_ALLY |
| mp_cost | 5 |
| power | — |
| accuracy | 100 |
| status_effect | SPD +1 stage 3T (all allies) |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | はやめの歌をうたう |
| learn_src | breed |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-075 ほのおのかべ / Fire Wall
| 項目 | 値 |
|------|-----|
| category | SUP |
| element | fire |
| range | FIELD |
| mp_cost | 6 |
| power | — |
| accuracy | 100 |
| status_effect | field: fire damage +15% for all, water damage -15% for all, 5T |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | 炎の壁が場をつつむ |
| learn_src | level (Lv25+) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

### 6.7 看破 / 勧誘 / 印操作（Utility）— 8 技

#### SKL-028 みやぶる / Discern
| 項目 | 値 |
|------|-----|
| category | SUP |
| element | light |
| range | SINGLE_ENEMY |
| mp_cost | 2 |
| power | — |
| accuracy | 100 |
| status_effect | marked 3T, reveals weakness, removes evasion buffs |
| ai_tag | SCOUT_SUPPORT |
| desc_strip | 弱みを見ぬく |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-029 ぬすみみる / Spy
| 項目 | 値 |
|------|-----|
| category | SUP |
| element | dark |
| range | SINGLE_ENEMY |
| mp_cost | 3 |
| power | — |
| accuracy | 100 |
| status_effect | marked 3T, recruit +6, reveals held item |
| ai_tag | SCOUT_SUPPORT |
| desc_strip | こっそりのぞく |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-030 ひかりのまなざし / Gaze of Light
| 項目 | 値 |
|------|-----|
| category | SUP |
| element | light |
| range | SINGLE_ENEMY |
| mp_cost | 4 |
| power | — |
| accuracy | 100 |
| status_effect | marked 4T, removes fear from caster |
| ai_tag | SCOUT_SUPPORT |
| desc_strip | ひかりで見すえる |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-031 いんしょうのみ / Impression Drain
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | dark |
| range | SINGLE_ENEMY |
| mp_cost | 5 |
| power | base_power 12 (M1) |
| accuracy | 100 |
| status_effect | consumes marked or 1 buff, caster MP +5 |
| ai_tag | PAYOFF |
| desc_strip | 印をのみこむ |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-032 しずかなよびごえ / Quiet Call
| 項目 | 値 |
|------|-----|
| category | SUP |
| element | none |
| range | SINGLE_ENEMY |
| mp_cost | 4 |
| power | — |
| accuracy | 100 |
| status_effect | recruit +10 (this battle only) |
| ai_tag | SCOUT_SUPPORT |
| desc_strip | しずかによびかける |
| learn_src | level |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-033 すばやくにげる / Quick Escape
| 項目 | 値 |
|------|-----|
| category | FLD |
| element | wind |
| range | SELF |
| mp_cost | 2 |
| power | — |
| accuracy | 100 |
| status_effect | escape rate +40 |
| ai_tag | FIELD_LINK |
| desc_strip | すばやくにげだす |
| learn_src | level (innate) |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-076 あまいいき / Sweet Breath
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | none |
| range | ALL_ENEMY |
| mp_cost | 6 |
| power | — |
| accuracy | 36 |
| status_effect | sleep 1-2T |
| ai_tag | STATUS_SETUP |
| desc_strip | あまいいきをはく |
| learn_src | level (Lv18+) |
| evo_from | — |
| evo_to | — |
| forbidden | SKL-071 と同時習得不可 |

#### SKL-077 のろいのことば / Curse Words
| 項目 | 値 |
|------|-----|
| category | DEB |
| element | dark |
| range | SINGLE_ENEMY |
| mp_cost | 5 |
| power | — |
| accuracy | 50 |
| status_effect | curse 4T (self-damage max_hp * 1/20 on action) |
| ai_tag | STATUS_SETUP |
| desc_strip | のろいの言葉をはく |
| learn_src | breed |
| evo_from | — |
| evo_to | — |
| forbidden | — |

### 6.8 反応技（REA）— 4 技

#### SKL-078 はんげき / Counter Strike
| 項目 | 値 |
|------|-----|
| category | REA |
| element | none |
| range | SINGLE_ENEMY |
| mp_cost | 0 |
| power | counter_damage = received_physical * 0.70 |
| accuracy | auto |
| status_effect | — |
| ai_tag | — |
| desc_strip | うけた力ではねかえす |
| learn_src | breed |
| evo_from | — |
| evo_to | — |
| forbidden | — |
| trigger | 物理攻撃被弾時、trait `counter_stance` 保有者のみ発動可能 |

#### SKL-079 みがわり / Decoy Guard
| 項目 | 値 |
|------|-----|
| category | REA |
| element | none |
| range | SINGLE_ALLY |
| mp_cost | 3 |
| power | — |
| accuracy | auto |
| status_effect | redirects single-target attack to self |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | なかまをかばう |
| learn_src | level (Lv15+) |
| evo_from | — |
| evo_to | — |
| forbidden | — |
| trigger | ally_hp_ratio <= 0.30, once per round |

#### SKL-080 まほうはんしゃ / Spell Mirror
| 項目 | 値 |
|------|-----|
| category | REA |
| element | none |
| range | SELF |
| mp_cost | 5 |
| power | reflected_damage = original * 0.80 |
| accuracy | auto |
| status_effect | reflects 1 reflectable spell |
| ai_tag | CONTROL |
| desc_strip | じゅもんをはねかえす |
| learn_src | breed |
| evo_from | — |
| evo_to | — |
| forbidden | — |
| trigger | 1 回限り、MAG で reflectable=true の呪文被弾時に発動 |

#### SKL-081 しのびよるかげ / Creeping Shadow
| 項目 | 値 |
|------|-----|
| category | REA |
| element | dark |
| range | SINGLE_ENEMY |
| mp_cost | 0 |
| power | base_power 8 (M1) |
| accuracy | auto |
| status_effect | soot 40% |
| ai_tag | CONTROL |
| desc_strip | 影がうごめく |
| learn_src | world (World 3) |
| evo_from | — |
| evo_to | — |
| forbidden | — |
| trigger | 味方が状態異常を受けた直後に発動（1ラウンド1回） |

### 6.9 探索技（FLD）— 4 技

#### SKL-082 たいまつ / Torch
| 項目 | 値 |
|------|-----|
| category | FLD |
| element | fire |
| range | FIELD |
| mp_cost | 1 |
| power | — |
| accuracy | 100 |
| status_effect | illuminates dark areas for 120 steps |
| ai_tag | FIELD_LINK |
| desc_strip | あたりを照らす |
| learn_src | level |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-083 かぎわけ / Scent Track
| 項目 | 値 |
|------|-----|
| category | FLD |
| element | none |
| range | SELF |
| mp_cost | 2 |
| power | — |
| accuracy | 100 |
| status_effect | reveals hidden items within 5-tile radius |
| ai_tag | FIELD_LINK |
| desc_strip | においをかぎわける |
| learn_src | level |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-084 とおぼえ / Howl
| 項目 | 値 |
|------|-----|
| category | FLD |
| element | none |
| range | FIELD |
| mp_cost | 2 |
| power | — |
| accuracy | 100 |
| status_effect | modifies encounter rate by +30% for 60 steps |
| ai_tag | FIELD_LINK |
| desc_strip | とおくにひびく |
| learn_src | level |
| evo_from | — |
| evo_to | — |
| forbidden | — |

#### SKL-085 しずけさ / Silence
| 項目 | 値 |
|------|-----|
| category | FLD |
| element | light |
| range | FIELD |
| mp_cost | 3 |
| power | — |
| accuracy | 100 |
| status_effect | reduces encounter rate by -30% for 80 steps |
| ai_tag | FIELD_LINK |
| desc_strip | あたりが静まりかえる |
| learn_src | level |
| evo_from | — |
| evo_to | — |
| forbidden | — |

---

## 7. Trait（特性）システム

### 7.1 特性の基本ルール

1. 各モンスターは最大 **2 つ** の固有特性スロットを持つ（`trait_1`, `trait_2` in `monster_master.csv`）
2. 特性は技枠 8 とは **別管理**。特性を「忘れる」ことはできない
3. 特性の効果は **常時発動（always-on）** と **条件発動（triggered）** の 2 種類
4. 特性は戦闘中に明示的に使用する行動ではない。自動的に判定・処理される

### 7.2 Trait 発動優先順位

複数の trait が同時に発動条件を満たした場合、以下の優先順で処理する。

| 優先順 | カテゴリ | 処理タイミング |
|--------|----------|----------------|
| 1 | **防御系** (guard, absorb, reflect) | ダメージ計算前 |
| 2 | **耐性系** (resist, immunity) | 状態異常判定前 |
| 3 | **反撃系** (counter, retaliate) | ダメージ解決後 |
| 4 | **回復系** (regen, drain) | ラウンド終了時 |
| 5 | **強化系** (boost, amplify) | 行動実行時 |
| 6 | **情報系** (detect, sense) | ラウンド開始時 |

### 7.3 同時発動の解決

- 同一優先順内で複数の trait が発動した場合、`trait_1` → `trait_2` の順で処理する
- 敵味方間で同時発動した場合、行動中の側のtraitが先に処理される
- 1 つの trait は 1 ラウンドに最大 **1 回** 発動する（例外: always-on は常時）

### 7.4 Trait フルカタログ（24 trait）

#### 7.4.1 常時発動（Always-On）— 10 trait

| trait_id | 名前 | 効果 | 代表所持者 |
|----------|------|------|------------|
| `TRT-001` | もふもふ | 物理被ダメ -8%。氷系の追加演出あり | モクケダ系 |
| `TRT-002` | するどいめ | 命中率 +5。暗闇状態のペナルティ半減 | タグツツキ系、鳥系全般 |
| `TRT-003` | ぬめぬめ | 物理攻撃を受けた際、攻撃者の SPD -1 段階（1 戦 1 回） | ヨモギナメ系 |
| `TRT-004` | すばしこい | 先制率 +8%、逃走成功率 +15% | カゴホネズミ系 |
| `TRT-005` | わらのからだ | 火属性被ダメ +25%、風属性被ダメ -20% | マヨイカカシ系 |
| `TRT-006` | いわはだ | DEF +10%（内部計算時）。地属性被ダメ -15% | イワミミ系 |
| `TRT-007` | しめったかさ | wet 状態のとき被ダメ -10%（通常 wet 効果に上乗せ） | シメリガサ系 |
| `TRT-008` | やみのはね | 闇属性技の威力 +12% | ユビガラス系 |
| `TRT-009` | いんしょく | marked 対象への全攻撃に追加ダメージ +8% | シルシクイ系 |
| `TRT-010` | きおくのひかり | light 属性回復技の回復量 +15% | トウモリノコ系 |

#### 7.4.2 条件発動（Triggered）— 14 trait

| trait_id | 名前 | 発動条件 | 効果 | 代表所持者 |
|----------|------|----------|------|------------|
| `TRT-011` | ふんばり | HP が 20% 以下に落ちる攻撃を受けた | 1 戦 1 回、HP 1 で耐える | 獣系高ランク |
| `TRT-012` | はんげきのかまえ | 物理攻撃被弾 | 15% で反撃（受ダメの 0.70 倍） | 竜系 |
| `TRT-013` | どくたいせい | 毒状態を付与されそうになった | 毒無効化。代わりに ATK +1 段階（1 戦 1 回） | 植物系上位 |
| `TRT-014` | まよけ | 混乱・恐怖の成功率 -15 | 常時適用（条件発動扱いだが実質 always-on） | 聖獣系 |
| `TRT-015` | かぜよび | 風属性技を使用した | 次ラウンドの initiative +5 | 鳥系上位 |
| `TRT-016` | ほのおのからだ | 物理攻撃被弾 | 20% で攻撃者に固定 8 ダメージ | 火属性系 |
| `TRT-017` | きゅうすいたいしつ | 水属性攻撃被弾 | 被ダメの 25% を HP 回復に変換 | 植物系・水棲系 |
| `TRT-018` | やみのまもり | 闇属性攻撃被弾 | 闇属性被ダメ -30%。光属性被ダメ +15% | アンデッド系 |
| `TRT-019` | いかくのほえ | 戦闘開始時 | 敵全体の ATK -1 段階（ボスには無効） | 獣系上位 |
| `TRT-020` | さいせいりょく | ラウンド終了時 | HP を最大値の 1/16 回復 | 植物系・スライム系 |
| `TRT-021` | しぜんかいふく | ラウンド終了時 | 30% で状態異常が 1 ターン早く回復 | 聖獣系 |
| `TRT-022` | せんせいのかん | 戦闘開始時 | 25% で先制行動（initiative +25） | 獣系・鳥系 |
| `TRT-023` | もんのきょうめい | 塔・門付近のゾーンでの戦闘開始時 | 全ステータス +5%（そのゾーン内のみ） | 神話系・聖獣系 |
| `TRT-024` | しゅうねん | 自身が倒された直後 | 30% で HP 1 で復活（1 戦 1 回） | アンデッド系 |

### 7.5 特性の継承ルール（配合時）

#### 7.5.1 基本継承ルール

```text
child_trait_pool = [
  parent_a.trait_1,
  parent_a.trait_2,
  parent_b.trait_1,
  parent_b.trait_2,
  child_species.default_trait_1,
  child_species.default_trait_2
]

// 子の種族固有 trait は必ず trait_1 に入る
child.trait_1 = child_species.default_trait_1

// trait_2 は以下の優先順で決定
if child_species.default_trait_2 exists:
  child.trait_2 = child_species.default_trait_2
else:
  // 親から継承。両親とも該当 trait を持っていた場合に限り継承可能
  shared_traits = intersection(parent_a.traits, parent_b.traits)
  if shared_traits is not empty:
    child.trait_2 = random_pick(shared_traits)
  else:
    child.trait_2 = null  // 空きスロット
```

#### 7.5.2 継承制限

| ルール | 内容 |
|--------|------|
| 種族固有 trait | `trait_1` は必ず子の種族の既定値。上書き不可 |
| 共有条件 | 親の trait を子に継承するには、**両親が同じ trait を持っている** 必要がある |
| 禁止継承 | `もんのきょうめい` (TRT-023) は継承不可。その種族の固有でなければ持てない |
| 最大継承数 | 親から子へ渡せる trait は最大 1 つ（`trait_2` スロットのみ） |

#### 7.5.3 変異種の trait 挙動

- 変異種は `trait_2` に変異専用 trait を持つ場合がある
- 変異専用 trait は通常配合では継承されない
- 変異種同士の配合では、変異専用 trait の継承率が 25% に設定される

---

## 8. 禁止コンボ（Forbidden Skill Combinations）

### 8.1 禁止コンボ一覧

| 禁止ペア | 理由 | 検出方法 |
|----------|------|----------|
| `しのどく` (SKL-070) + `どくこな` (SKL-014) | 毒の段階上書きが頻発し、ダメージ管理が破綻する | learn_check |
| `あまいいき` (SKL-076) + `ふかいねむり` (SKL-071) | 全体睡眠 → 確定強化睡眠のループが成立する | learn_check |
| `だいふういん` (SKL-072) + `ふかいねむり` (SKL-071) | 全体封印 + 深い眠りで敵の行動をほぼ完封できる | learn_check |
| `まほうはんしゃ` (SKL-080) + `はんげき` (SKL-078) | 物理反撃 + 魔法反射で全方位対応になり、受け主体のビルドが強すぎる | learn_check |
| World 固有スキル同士の 2 つ以上同時習得 | 世界の特色を薄める。1 体 1 世界スキルまで | learn_check |

### 8.2 禁止コンボの実装方法

```text
function can_learn_skill(monster, new_skill_id):
  for each forbidden_pair in FORBIDDEN_COMBOS:
    if new_skill_id in forbidden_pair:
      partner_id = forbidden_pair.other(new_skill_id)
      if monster.has_skill(partner_id):
        return false, "この技は [partner.name] と同時に覚えられない"
  return true, null

// 配合継承時にも同じチェックを適用
function inherit_skill_check(child, candidate_skills):
  valid_skills = []
  for skill in candidate_skills:
    ok, reason = can_learn_skill(child_with(valid_skills), skill)
    if ok:
      valid_skills.append(skill)
    else:
      log("Inheritance blocked: " + reason)
  return valid_skills
```

### 8.3 禁止コンボの表示

- プレイヤーが禁止コンボに該当するスキルを習得しようとした場合、説明帯に理由を表示する
- 例: 「この技は ふかいねむり と同時に覚えられない」
- 配合時の継承選択画面で、禁止対象のスキルはグレーアウト表示する

---

## 9. 世界固有スキル（World-Specific Skills）

### 9.1 設計テンプレート

世界固有スキルは以下のテンプレートに従って設計する。

```text
World-Specific Skill Template
──────────────────────────
1. world_id: 対象世界のID
2. unlock_condition: 解放条件（ストーリー進行、ボス撃破、特定NPC会話など）
3. thematic_link: その世界の禁忌・文化とスキル効果の関連
4. balance_tier: 同世界の推奨レベル帯に合わせた威力帯
5. restriction: 1体が同時に持てる世界固有スキルは最大1つ
6. inheritance: 配合時の継承は可能だが、禁止コンボルール（§8）が適用される
```

### 9.2 世界固有スキル一覧（最初の 4 世界）

#### SKL-086 かえりみちのしるべ / Path Home Marker — World 1（開始村周辺）
| 項目 | 値 |
|------|-----|
| category | FLD |
| element | light |
| range | FIELD |
| mp_cost | 4 |
| power | — |
| accuracy | 100 |
| status_effect | sets a return waypoint; using again warps to waypoint |
| ai_tag | FIELD_LINK |
| desc_strip | かえりみちをしるす |
| learn_src | world (World 1, NPC event after first gate) |
| unlock | 最初の門を越えて帰還した後、村の長老と会話 |
| thematic_link | 開始村の「印で道を記す」文化。家畜番の仕事道具の延長 |

#### SKL-087 こだまのいのり / Echo Prayer — World 2（残響の谷）
| 項目 | 値 |
|------|-----|
| category | MAG |
| element | wind |
| range | ALL_ENEMY |
| mp_cost | 6 |
| power | base_power 20 |
| accuracy | 95 |
| status_effect | hushed 25%. In World 2 zones: base_power +8 |
| ai_tag | CONTROL |
| desc_strip | こだまが祈りをかえす |
| learn_src | world (World 2, boss defeat) |
| unlock | 残響の谷のボス撃破後、谷の祠で習得 |
| thematic_link | 声が反響する谷の性質。この世界では「名前を呼ぶ」ことが禁忌 |

#### SKL-088 つちにかえす / Return to Earth — World 3（沈黙の農地）
| 項目 | 値 |
|------|-----|
| category | PHY |
| element | earth |
| range | SINGLE_ENEMY |
| mp_cost | 5 |
| power | power_mod 1.20 |
| accuracy | 92 |
| status_effect | if target is undead or material: power_mod +0.30. In World 3: +15% recruit rate |
| ai_tag | BREAK_DEF |
| desc_strip | つちへとかえす |
| learn_src | world (World 3, event) |
| unlock | 沈黙の農地で特定の埋葬イベントを完了 |
| thematic_link | 死者を土に返す農民の儀式。この世界では「耕す」ことが葬送と直結 |

#### SKL-089 きりのまなこ / Fog Eye — World 4（霧の漁村）
| 項目 | 値 |
|------|-----|
| category | SUP |
| element | water |
| range | ALL_ALLY |
| mp_cost | 6 |
| power | — |
| accuracy | 100 |
| status_effect | evasion +10% 3T. In fog weather: evasion +20% instead |
| ai_tag | ALLY_SUSTAIN |
| desc_strip | 霧のまなこで見とおす |
| learn_src | world (World 4, NPC quest) |
| unlock | 霧の漁村の老漁師のクエスト完了 |
| thematic_link | 霧に包まれた漁村で生きる知恵。この世界では「見えない」ことが安全を意味する |

### 9.3 世界固有スキルの運用ルール

1. **1 体 1 つまで**: 世界固有スキルは複数習得不可。新たに習得する場合、既存の世界固有スキルを忘れる必要がある
2. **配合継承**: 親が世界固有スキルを持つ場合、子は通常の継承ルールで受け取れる。ただし §8 の禁止コンボルールが適用される
3. **世界内ボーナス**: 各世界固有スキルは、その出身世界のゾーン内で使用すると追加効果を持つ（上記の個別定義参照）
4. **習得イベント**: 世界固有スキルは必ずストーリーイベントまたは NPC クエストを通じて習得する。レベルアップでは習得できない

---

## 10. 状態異常特化ビルド設計指針

### 10.1 賢さ（INT）と精神（RES）の差別化

| ステータス | 攻撃面での役割 | 防御面での役割 |
|------------|----------------|----------------|
| INT | 状態異常の成功率を上げる（+0.15/pt差） | — |
| RES | — | 状態異常の成功率を下げる（-0.15/pt差） |

### 10.2 状態異常ビルドの成立条件

状態異常を軸にした戦術が「強いが万能ではない」バランスを保つための設計指針。

| 原則 | 内容 |
|------|------|
| 確率上限 | 最終成功率は `clamp(5, 95)` で 100% にはならない |
| 耐性段階 | 敵の耐性 +2 なら成功率 -20。特化しても通りにくい相手は存在する |
| ボス補正 | ボスは状態異常に `-15〜-35` の固定減算を受ける |
| 連続ペナルティ | 同一補助を 3 回連続使用で成功率 -10 |
| 禁止コンボ | §8 により、最強の状態異常を重ねがけする構成は制限される |
| 回復手段 | 全ての状態異常に対して HEL カテゴリの回復技が存在する |

### 10.3 推奨ビルド例

#### 睡眠コントローラー
- 主力: `ねむりごな` / `ふかいねむり`（禁止コンボで `あまいいき` は不可）
- 補助: `にぶいひかり` で RES を下げてから投入
- trait: `まよけ` で自身への混乱を防ぐ
- 弱点: 睡眠耐性 +2 の敵には通らない。物理で削る手段が乏しい

#### 毒削りアタッカー
- 主力: `もうどく` + `しるしうばい`
- 補助: `みやぶる` で marked をつけ、毒 + 印消費のコンボ
- trait: `どくたいせい` で反毒を無効化
- 弱点: 毒耐性持ちには火力が出ない。短期決戦に弱い

---

## 11. スキルバランス制約（全体）

### 11.1 威力帯別バランスターゲット

| 世界帯 | 推奨Lv | PHY power_mod 上限 | MAG base_power 上限 | HEL base_power 上限 |
|--------|--------|-------------------|--------------------|--------------------|
| 世界 1 | 1〜10 | 1.35 | 18 | 22 |
| 世界 2 | 8〜18 | 1.35 | 28 | 32 |
| 世界 3 | 15〜25 | 1.45 | 38 | 38 |
| 世界 4 | 22〜32 | 1.55 | 52 | 42 |
| 世界 5+ | 30+ | 1.60 | 70 | 50 |

### 11.2 MP 経済

| 世界帯 | 平均 MP 帯 | 1 戦あたり消費目安 | 持続戦闘回数目安 |
|--------|-----------|-------------------|-----------------|
| 世界 1 | 15〜30 | 4〜8 MP | 3〜5 戦 |
| 世界 2 | 25〜50 | 6〜12 MP | 3〜5 戦 |
| 世界 3 | 40〜80 | 10〜18 MP | 3〜5 戦 |
| 世界 4 | 60〜120 | 14〜24 MP | 3〜5 戦 |

MP 回復手段（宿・アイテム・ほしみず系）とあわせて、1 ダンジョン突入で 5〜8 戦を想定する。

### 11.3 壊れ防止チェックリスト

- [ ] 全体睡眠 + 全体高火力の 1 ターンキルが成立しないか
- [ ] 毒ダメージだけでボスを削り切れないか（ボス HP 係数 2.8〜4.5 倍で検証）
- [ ] 反射 + カウンターで全方位無敵にならないか（§8 で禁止済み）
- [ ] marked + PAYOFF 技の追加ダメージが通常攻撃の 2 倍を超えないか
- [ ] 単一 trait で勝率が 10% 以上変動しないか
- [ ] 世界固有スキルの世界内ボーナスが、そのスキルの基本威力の 50% を超えないか

---

## 12. ID 割当表（サマリ）

| ID 範囲 | 用途 | 技数 |
|---------|------|------|
| SKL-001〜SKL-012 | 初期物理技 | 12 |
| SKL-013〜SKL-020 | 初期状態異常技 | 8 |
| SKL-021〜SKL-027 | 初期回復・支援技 | 7 |
| SKL-028〜SKL-036 | 初期看破・勧誘・追加技 | 9 |
| SKL-041〜SKL-048 | 物理進化技 | 8 |
| SKL-049〜SKL-063 | 魔法進化技・新規魔法 | 15 |
| SKL-064〜SKL-068 | 回復進化技 | 5 |
| SKL-069〜SKL-077 | 状態異常進化技・新規状態技 | 9 |
| SKL-078〜SKL-081 | 反応技 | 4 |
| SKL-082〜SKL-085 | 探索技 | 4 |
| SKL-086〜SKL-089 | 世界固有スキル | 4 |
| **合計** | | **85** |
| TRT-001〜TRT-024 | 特性 | 24 |

### 予約帯

| ID 範囲 | 用途 |
|---------|------|
| SKL-090〜SKL-120 | 世界 5〜8 追加技 |
| SKL-121〜SKL-200 | 中盤拡張（配合専用技含む） |
| SKL-201〜SKL-300 | 終盤・endgame 技 |
| SKL-301〜SKL-400 | 裏コンテンツ・イベント限定 |
| TRT-025〜TRT-050 | 中盤以降の追加特性 |
| TRT-051〜TRT-080 | endgame・変異種専用特性 |

---

## 13. 補足：skill_master.csv カラムマッピング

本文書のスキル定義を `skill_master.csv` に書き出す際の対応表。

| 本文書の項目 | CSV カラム | 備考 |
|-------------|-----------|------|
| skill_id | `skill_id` | そのまま |
| name_jp | `name_jp` | そのまま |
| name_en | `name_en` | そのまま |
| category | `category` | PHY→physical, MAG→magic, HEL→recover, SUP→setup, DEB→status, FLD→utility, REA→reaction |
| element | `element` | そのまま |
| mp_cost | `mp_cost` | そのまま |
| range | `target_scope` | SINGLE_ENEMY→single, ALL_ENEMY→spread, etc. |
| power / power_mod | `base_power` | PHY は power_mod を保存、MAG/HEL は base_power を保存 |
| accuracy | `base_rate` | 命中率 / 成功率 |
| status_effect | タグとして `tags` に含める | 詳細は `battle_skill_master` 側で管理 |
| ai_tag | `battle_role` | そのまま |
| desc_strip | `effect_text` | 18 文字制限 |
| evo_from / evo_to | `tags` に `evo_from:SKL-XXX` 形式で記載 | 別途 evolution テーブルを推奨 |
| forbidden | `tags` に `forbidden:SKL-XXX` 形式で記載 | 別途 forbidden テーブルを推奨 |

---

## 14. 改訂履歴

| 日付 | 版 | 内容 |
|------|-----|------|
| 2026-03-15 | v1.0 | 初版作成。85 技 + 24 trait を定義 |
