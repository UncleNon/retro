# 01. Vertical Slice Monsters

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/requirements/04_monster_design.md`
> - `docs/specs/systems/01_numeric_rules_and_master_schema.md`

---

## 1. 10体の設計方針

- 開始村と塔周辺で出る 10体を先に定義する
- 生活圏モチーフを多めにしつつ、塔と失踪の不気味さが混ざるようにする
- スライム直系や既存IPっぽいシルエットは避ける
- E / D ランク中心で、1体だけ C ランク相当の「最初の違和感」枠を置く

---

## 2. モンスター一覧

### 001 モクケダ

| 項目 | 値 |
|------|----|
| `monster_id` | `MON-001` |
| `name_jp` | モクケダ |
| `family` | beast |
| `rank` | E |
| `motif_group` | animal |
| `motif_source` | 羊 + 煤 + 焼印 |
| `silhouette_type` | round |
| `field_sprite_px` | 16 |
| `battle_sprite_px` | 32 |
| `base_level_cap` | 64 |
| `growth_curve_id` | EARLY |
| `base_hp/mp/atk/def/spd/int/res` | `24 / 8 / 12 / 10 / 11 / 7 / 9` |
| `cap_hp/mp/atk/def/spd/int/res` | `182 / 64 / 128 / 118 / 116 / 76 / 92` |
| `trait_1` | けむり毛 |
| `trait_2` | 低温耐性 |
| `innate skills` | たいあたり / すすはき / ちいさなつの |

デザイン意図:

- 村の家畜に近いが、角が炭化していて焼印の痕が毛並みに浮く
- 可愛いだけで終わらず、「飼っているものが少しおかしい」違和感を最初に出す

生成プロンプト:

```text
pixel art, 32x32 battle sprite, 16x16 field sprite, 1px black outline, no anti-aliasing, no gradient, gbc-inspired limited palette, a soot-wool ram creature with rounded silhouette, burnt ear tag, tiny charcoal horns, warm but slightly eerie farm-animal expression, top-left light, readable at 1x, transparent background
```

### 002 タグツツキ

| 項目 | 値 |
|------|----|
| `monster_id` | `MON-002` |
| `name_jp` | タグツツキ |
| `family` | bird |
| `rank` | E |
| `motif_source` | 啄木鳥 + 名札 + 木杭 |
| `silhouette_type` | tall |
| `base_level_cap` | 63 |
| `growth_curve_id` | STANDARD |
| `base_hp/mp/atk/def/spd/int/res` | `20 / 10 / 11 / 8 / 15 / 9 / 9` |
| `cap_hp/mp/atk/def/spd/int/res` | `150 / 70 / 120 / 92 / 142 / 88 / 90` |
| `trait_1` | ついばみ上手 |
| `trait_2` | 回避微増 |
| `innate skills` | ついばむ / かすりきず / みやぶる |

デザイン意図:

- 村の柱や家畜札をつついて削る鳥
- 名前や印を削るモチーフを、序盤の雑魚モンスターに落とす

生成プロンプト:

```text
pixel art, 32x32 battle sprite, vertical bird silhouette, woodpecker mixed with carved tag motif, sharp beak like a peg knife, tiny hanging livestock tags on legs, muted brown and bone palette, unsettling but not grotesque, 1px outline, no anti-aliasing, transparent background
```

### 003 ヨモギナメ

| 項目 | 値 |
|------|----|
| `monster_id` | `MON-003` |
| `name_jp` | ヨモギナメ |
| `family` | plant |
| `rank` | E |
| `motif_source` | 薬草 + ナメクジ + 湿土 |
| `silhouette_type` | wide |
| `base_level_cap` | 66 |
| `growth_curve_id` | EARLY |
| `base_hp/mp/atk/def/spd/int/res` | `22 / 12 / 9 / 11 / 8 / 12 / 12` |
| `cap_hp/mp/atk/def/spd/int/res` | `168 / 92 / 96 / 116 / 82 / 118 / 122` |
| `trait_1` | しめりけ |
| `trait_2` | 毒微耐性 |
| `innate skills` | ぬめり / くさのしずく / どくこな |

デザイン意図:

- 村の薬草畑や墓地の湿り気から出る
- 序盤の回復・毒の両面を担う

生成プロンプト:

```text
pixel art, low slug-like silhouette made of mugwort leaves and wet soil, herbal fantasy creature, slightly translucent mucus, muted green and moss palette, readable 32x32, 1px outline, no anti-aliasing, top-left light, transparent background
```

### 004 カゴホネズミ

| 項目 | 値 |
|------|----|
| `monster_id` | `MON-004` |
| `name_jp` | カゴホネズミ |
| `family` | material |
| `rank` | E |
| `motif_source` | 野ねずみ + 籠 + 骨組み |
| `silhouette_type` | round |
| `base_level_cap` | 62 |
| `growth_curve_id` | EARLY |
| `base_hp/mp/atk/def/spd/int/res` | `18 / 6 / 10 / 9 / 16 / 8 / 8` |
| `cap_hp/mp/atk/def/spd/int/res` | `136 / 50 / 102 / 94 / 148 / 74 / 78` |
| `trait_1` | すりぬけ気味 |
| `trait_2` | 物拾い |
| `innate skills` | かじる / ぬすみみる / すばやくにげる |

### 005 マヨイカカシ

| 項目 | 値 |
|------|----|
| `monster_id` | `MON-005` |
| `name_jp` | マヨイカカシ |
| `family` | material |
| `rank` | D |
| `motif_source` | 案山子 + 道標 + 迷い道 |
| `silhouette_type` | tall |
| `base_level_cap` | 68 |
| `growth_curve_id` | STANDARD |
| `base_hp/mp/atk/def/spd/int/res` | `28 / 14 / 14 / 15 / 10 / 13 / 14` |
| `cap_hp/mp/atk/def/spd/int/res` | `196 / 108 / 132 / 138 / 96 / 116 / 120` |
| `trait_1` | みちまどい |
| `trait_2` | 混乱微付与 |
| `innate skills` | つつく / まよわせる / しるしうばい |

### 006 イワミミ

| 項目 | 値 |
|------|----|
| `monster_id` | `MON-006` |
| `name_jp` | イワミミ |
| `family` | beast |
| `rank` | E |
| `motif_source` | 野うさぎ + 石耳 + 崖 |
| `silhouette_type` | tall |
| `base_level_cap` | 64 |
| `growth_curve_id` | STANDARD |
| `base_hp/mp/atk/def/spd/int/res` | `21 / 7 / 13 / 9 / 17 / 7 / 9` |
| `cap_hp/mp/atk/def/spd/int/res` | `152 / 56 / 128 / 96 / 154 / 72 / 88` |
| `trait_1` | 先手気味 |
| `trait_2` | 風微耐性 |
| `innate skills` | ひっかく / とびのく / みみうち |

### 007 シメリガサ

| 項目 | 値 |
|------|----|
| `monster_id` | `MON-007` |
| `name_jp` | シメリガサ |
| `family` | plant |
| `rank` | D |
| `motif_source` | 湿った茸 + 弔い傘 |
| `silhouette_type` | wide |
| `base_level_cap` | 70 |
| `growth_curve_id` | LATE |
| `base_hp/mp/atk/def/spd/int/res` | `24 / 16 / 10 / 13 / 8 / 16 / 15` |
| `cap_hp/mp/atk/def/spd/int/res` | `188 / 132 / 98 / 124 / 84 / 146 / 130` |
| `trait_1` | しめった胞子 |
| `trait_2` | 眠り微付与 |
| `innate skills` | しめり / ねむりごな / やわらかいかべ |

### 008 ユビガラス

| 項目 | 値 |
|------|----|
| `monster_id` | `MON-008` |
| `name_jp` | ユビガラス |
| `family` | bird |
| `rank` | D |
| `motif_source` | 烏 + 指差し + 噂 |
| `silhouette_type` | tall |
| `base_level_cap` | 69 |
| `growth_curve_id` | STANDARD |
| `base_hp/mp/atk/def/spd/int/res` | `23 / 13 / 15 / 9 / 16 / 14 / 11` |
| `cap_hp/mp/atk/def/spd/int/res` | `170 / 102 / 146 / 92 / 144 / 122 / 98` |
| `trait_1` | よびよせ声 |
| `trait_2` | 闇微耐性 |
| `innate skills` | つつく / ささやき / くらがりはね |

### 009 シルシクイ

| 項目 | 値 |
|------|----|
| `monster_id` | `MON-009` |
| `name_jp` | シルシクイ |
| `family` | magic |
| `rank` | D |
| `motif_source` | 印章 + 守宮 + ひび割れ |
| `silhouette_type` | serpentine |
| `base_level_cap` | 72 |
| `growth_curve_id` | LATE |
| `base_hp/mp/atk/def/spd/int/res` | `19 / 18 / 10 / 10 / 14 / 17 / 16` |
| `cap_hp/mp/atk/def/spd/int/res` | `148 / 142 / 96 / 98 / 132 / 150 / 144` |
| `trait_1` | 封印爪 |
| `trait_2` | 印食い |
| `innate skills` | ひっかき / ふういん / いんしょうのみ |

### 010 トウモリノコ

| 項目 | 値 |
|------|----|
| `monster_id` | `MON-010` |
| `name_jp` | トウモリノコ |
| `family` | divine |
| `rank` | C |
| `motif_source` | 子牛 + 門番像 + 星目 |
| `silhouette_type` | wide |
| `base_level_cap` | 76 |
| `growth_curve_id` | LATE |
| `base_hp/mp/atk/def/spd/int/res` | `30 / 18 / 16 / 16 / 12 / 15 / 16` |
| `cap_hp/mp/atk/def/spd/int/res` | `228 / 136 / 154 / 148 / 118 / 132 / 138` |
| `trait_1` | 門前反応 |
| `trait_2` | 光闇微耐性 |
| `innate skills` | たいあたり / ひかりのまなざし / きおくのひづめ |

デザイン意図:

- 最初の「村の家畜なのに、塔と妙に共鳴する」存在
- 可愛い枠ではなく、静かで神妙な違和感を持たせる

生成プロンプト:

```text
pixel art, mysterious calf-like gate creature, broad silhouette, pale hide with carved stone pattern around the shoulders, one eye reflecting star-like light, mixture of livestock and shrine guardian, limited muted palette, 32x32 battle sprite, 1px black outline, no anti-aliasing, uncanny but not monstrous
```

---

## 3. Vertical Slice 用の配合サンプル

> **注**: 特殊配合は家系マトリクスより優先される。上記レシピはすべて特殊配合として定義されており、家系法則を上書きする。優先順位の詳細は `docs/specs/systems/03_breeding_mutation_and_lineage_rules.md` を参照。

| 親A | 親B | 結果 | ルール |
|-----|-----|------|--------|
| モクケダ | タグツツキ | マヨイカカシ | 特殊配合 |
| ヨモギナメ | イワミミ | シメリガサ | 特殊配合 |
| カゴホネズミ | ユビガラス | シルシクイ | 特殊配合 |
| モクケダ | モクケダ | モクケダ | 同系統強化 |
| タグツツキ | ユビガラス | トウモリノコ | Vertical Slice 限定の到達目標 |

---

## 4. モチーフ法則

### 序盤10体で守ること

- 4体以上は **村の生活圏** から発想する
- 3体以上は **名前 / 印 / 記録 / 噂** に関係するモチーフを混ぜる
- 2体以上は **塔との共鳴** を感じる上位枠にする
- 直接的な神話引用は避け、神話っぽさは形の断片として混ぜる

### モチーフ禁止事項

- 単なる色違い動物
- 既存JRPGモンスターに見えやすい円満スライム型
- 露骨な悪魔角 + コウモリ翼の量産
- 初見で元ネタが一発で分かる有名神話の丸写し
