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
| `battle_sprite_px` | 24 |
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

```
[Invariant]
pixel art, 24x24 battle sprite, transparent background,
1px black outline, top-left lighting, no anti-aliasing, no dithering, no gradient,
no smooth shading, gbc-inspired limited palette, readable at 1x, no text, no logo

[Body]
A round soot-wool ram creature in idle standing pose, compact rounded silhouette,
thick smoky fleece with faded brand mark on hide, tiny charcoal-black horns,
burnt ear tag on left ear, warm but slightly eerie farm-animal expression,
4-6 color palette, dominant tones: warm soot-grey and dirty cream,
accent color: charcoal black on horns and brand

[Lore Context]
barn-dust patina across fleece, faded brand mark on hindquarter

[Pixel Constraints]
5 color palette, fill 70-85% canvas, 3 shape masses maximum,
flat interior fills, strong silhouette read

[Negative]
not pokemon-like, not dragon-quest-like, not anime mascot, no busy background,
no weapons unless motif requires, no realistic rendering

[Tool Suffix]
--ar 1:1 --niji 7
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
| `field_sprite_px` | 16 |
| `battle_sprite_px` | 24 |
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

```
[Invariant]
pixel art, 24x24 battle sprite, transparent background,
1px black outline, top-left lighting, no anti-aliasing, no dithering, no gradient,
no smooth shading, gbc-inspired limited palette, readable at 1x, no text, no logo

[Body]
A tall upright woodpecker-like bird in idle perched pose, sharp beak shaped like
a peg knife, tiny hanging livestock tags dangling from its legs, vertical narrow
silhouette with stiff tail brace, scratched wood-grain texture on wing feathers,
4-6 color palette, dominant tones: muted brown and bone-white,
accent color: dull copper on the hanging tags

[Lore Context]
scratched name plate hanging from neck, carved tally marks on beak tip

[Pixel Constraints]
5 color palette, fill 70-85% canvas, 3 shape masses maximum,
flat interior fills, strong silhouette read

[Negative]
not pokemon-like, not dragon-quest-like, not anime mascot, no busy background,
no weapons unless motif requires, no realistic rendering

[Tool Suffix]
--ar 1:1 --niji 7
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
| `field_sprite_px` | 16 |
| `battle_sprite_px` | 24 |
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

```
[Invariant]
pixel art, 24x24 battle sprite, transparent background,
1px black outline, top-left lighting, no anti-aliasing, no dithering, no gradient,
no smooth shading, gbc-inspired limited palette, readable at 1x, no text, no logo

[Body]
A low wide slug-like creature made of mugwort leaves and wet soil in idle resting pose,
broad flat silhouette hugging the ground, slightly translucent mucus trail,
leaf-vein patterns across the back, small herb-sprout antenna,
4-6 color palette, dominant tones: muted green and wet moss-brown,
accent color: pale yellow-green on the mucus highlight

[Lore Context]
wilted flower crown half-absorbed into body, ash-dusted surface near the tail

[Pixel Constraints]
5 color palette, fill 70-85% canvas, 3 shape masses maximum,
flat interior fills, strong silhouette read

[Negative]
not pokemon-like, not dragon-quest-like, not anime mascot, no busy background,
no weapons unless motif requires, no realistic rendering

[Tool Suffix]
--ar 1:1 --niji 7
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
| `field_sprite_px` | 16 |
| `battle_sprite_px` | 24 |
| `innate skills` | かじる / ぬすみみる / すばやくにげる |

デザイン意図:

- 村の納屋や墓の下に住む小さなねずみが、骨の籠を背負って走る
- 物を拾い集める習性と、骨格の檻が一体化した不思議な存在

生成プロンプト:

```
[Invariant]
pixel art, 24x24 battle sprite, transparent background,
1px black outline, top-left lighting, no anti-aliasing, no dithering, no gradient,
no smooth shading, gbc-inspired limited palette, readable at 1x, no text, no logo

[Body]
A small round mouse-like creature in idle crouching pose, body partially formed
from a woven bone cage, tiny ribs arching over its back like a basket frame,
bits of found objects caught between the ribs — a button, a coin, a scrap of cloth,
bright beady eyes peering from inside the cage structure,
4-6 color palette, dominant tones: pale bone-white and dirty straw-yellow,
accent color: dark rust on the found objects

[Lore Context]
carved tally marks on bone ribs, straw stuck in fur around the haunches

[Pixel Constraints]
5 color palette, fill 70-85% canvas, 3 shape masses maximum,
flat interior fills, strong silhouette read

[Negative]
not pokemon-like, not dragon-quest-like, not anime mascot, no busy background,
no weapons unless motif requires, no realistic rendering

[Tool Suffix]
--ar 1:1 --niji 7
```

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
| `field_sprite_px` | 16 |
| `battle_sprite_px` | 32 |
| `innate skills` | つつく / まよわせる / しるしうばい |

デザイン意図:

- 村はずれの分かれ道に立つ案山子が、道標と混ざって動き出した存在
- 腕が複数方向を指すことで「迷い」を視覚化する

生成プロンプト:

```
[Invariant]
pixel art, 32x32 battle sprite, transparent background,
1px black outline, top-left lighting, no anti-aliasing, no dithering, no gradient,
no smooth shading, gbc-inspired limited palette, readable at 1x, no text, no logo

[Body]
A tall crooked scarecrow creature in idle standing pose, multiple thin arms
pointing in different directions like broken signposts, faded paint on wooden
plank limbs, a stolen name tag hanging from one arm on a frayed string,
straw leaking from torn burlap torso, lopsided head with single button eye,
4-6 color palette, dominant tones: weathered wood-brown and faded ochre,
accent color: dull red on the stolen name tag

[Lore Context]
faded registry stamp on chest plank, frayed rope collar around the neck post

[Pixel Constraints]
6 color palette, fill 70-85% canvas, 3 shape masses maximum,
flat interior fills, strong silhouette read

[Negative]
not pokemon-like, not dragon-quest-like, not anime mascot, no busy background,
no weapons unless motif requires, no realistic rendering

[Tool Suffix]
--ar 1:1 --niji 7
```

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
| `field_sprite_px` | 16 |
| `battle_sprite_px` | 24 |
| `innate skills` | ひっかく / とびのく / みみうち |

デザイン意図:

- 崖地に住む野うさぎが、石灰岩と苔で耳が硬化した姿
- すばしこい生き物に鉱物的な重さを混ぜる違和感

生成プロンプト:

```
[Invariant]
pixel art, 24x24 battle sprite, transparent background,
1px black outline, top-left lighting, no anti-aliasing, no dithering, no gradient,
no smooth shading, gbc-inspired limited palette, readable at 1x, no text, no logo

[Body]
A lean alert rabbit in idle perched pose, tall silhouette with ears made of flat
stone slabs, lichen growing in patches on the stone ears, tense hind legs ready
to bolt, compact wiry body with short fur, rough stone texture on ears contrasting
soft body,
4-6 color palette, dominant tones: grey-brown and moss-green,
accent color: pale lichen-yellow on the ear surfaces

[Lore Context]
moss pattern matching cliff-face masonry, dried mud on hind feet

[Pixel Constraints]
5 color palette, fill 70-85% canvas, 3 shape masses maximum,
flat interior fills, strong silhouette read

[Negative]
not pokemon-like, not dragon-quest-like, not anime mascot, no busy background,
no weapons unless motif requires, no realistic rendering

[Tool Suffix]
--ar 1:1 --niji 7
```

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
| `field_sprite_px` | 16 |
| `battle_sprite_px` | 32 |
| `innate skills` | しめり / ねむりごな / やわらかいかべ |

デザイン意図:

- 弔いの場に生える湿った茸が傘を広げた姿
- 眠りを誘う胞子と、喪の静けさを重ねる

生成プロンプト:

```
[Invariant]
pixel art, 32x32 battle sprite, transparent background,
1px black outline, top-left lighting, no anti-aliasing, no dithering, no gradient,
no smooth shading, gbc-inspired limited palette, readable at 1x, no text, no logo

[Body]
A wide drooping mushroom creature in idle standing pose, large cap that sags
downward like a mourning umbrella, damp spots and tiny droplet pixels on the
cap surface, short stubby stem-legs, pale spore clouds drifting from the cap
edges, soft sagging silhouette,
4-6 color palette, dominant tones: dark teal and grey-brown,
accent color: pale off-white on the spore clouds

[Lore Context]
ash-dusted surface on cap rim, incense-smoke colored wisps rising from gills

[Pixel Constraints]
6 color palette, fill 70-85% canvas, 3 shape masses maximum,
flat interior fills, strong silhouette read

[Negative]
not pokemon-like, not dragon-quest-like, not anime mascot, no busy background,
no weapons unless motif requires, no realistic rendering

[Tool Suffix]
--ar 1:1 --niji 7
```

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
| `field_sprite_px` | 16 |
| `battle_sprite_px` | 32 |
| `innate skills` | つつく / ささやき / くらがりはね |

デザイン意図:

- 噂を運ぶ烏が、指差しのような翼を持つ
- 誰かを指し示す不吉さを、鳥の形に落とす

生成プロンプト:

```
[Invariant]
pixel art, 32x32 battle sprite, transparent background,
1px black outline, top-left lighting, no anti-aliasing, no dithering, no gradient,
no smooth shading, gbc-inspired limited palette, readable at 1x, no text, no logo

[Body]
A tall crow-like bird in idle standing pose, one wing extended and shaped like
a pointing finger with feather-tips forming distinct digits, dark sleek plumage,
pale bone-white throat patch, sharp watchful eyes that seem to track something
unseen, tall upright posture,
4-6 color palette, dominant tones: deep indigo and bone-white,
accent color: dull amber in the eye

[Lore Context]
ink-stained claws from perching on record posts, faded registry stamp on leg band

[Pixel Constraints]
6 color palette, fill 70-85% canvas, 3 shape masses maximum,
flat interior fills, strong silhouette read

[Negative]
not pokemon-like, not dragon-quest-like, not anime mascot, no busy background,
no weapons unless motif requires, no realistic rendering

[Tool Suffix]
--ar 1:1 --niji 7
```

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
| `field_sprite_px` | 16 |
| `battle_sprite_px` | 32 |
| `innate skills` | ひっかき / ふういん / いんしょうのみ |

デザイン意図:

- 封印や刻印を食べる守宮のような魔法生物
- 壁を這い、通った跡にひび割れが広がる不穏さ

生成プロンプト:

```
[Invariant]
pixel art, 32x32 battle sprite, transparent background,
1px black outline, top-left lighting, no anti-aliasing, no dithering, no gradient,
no smooth shading, gbc-inspired limited palette, readable at 1x, no text, no logo

[Body]
A serpentine gecko-like creature in idle clinging pose, flat splayed body with
stamp-pad patterns on its wide toe pads, cracks radiating from under its feet,
long curling tail with seal-impression rings, smooth ink-dark body with faded
red seal marks along the spine, liquid-like posture as if flowing along a wall,
4-6 color palette, dominant tones: ink-black and faded vermillion red,
accent color: pale cracked-stone grey on the spreading cracks

[Lore Context]
wax seal impression on belly scales, geometric cracks along spine matching
registry seal patterns

[Pixel Constraints]
6 color palette, fill 70-85% canvas, 3 shape masses maximum,
flat interior fills, strong silhouette read

[Negative]
not pokemon-like, not dragon-quest-like, not anime mascot, no busy background,
no weapons unless motif requires, no realistic rendering

[Tool Suffix]
--ar 1:1 --niji 7
```

### 010 トウモリノコ

| 項目 | 値 |
|------|----|
| `monster_id` | `MON-010` |
| `name_jp` | トウモリノコ |
| `family` | divine |
| `rank` | C |
| `motif_source` | 子牛 + 門番像 + 星目 |
| `silhouette_type` | wide |
| `field_sprite_px` | 16 |
| `battle_sprite_px` | 32 |
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

```
[Invariant]
pixel art, 32x32 battle sprite, transparent background,
1px black outline, top-left lighting, no anti-aliasing, no dithering, no gradient,
no smooth shading, gbc-inspired limited palette, readable at 1x, no text, no logo

[Body]
A broad sturdy calf-like creature in idle standing pose, wide stocky silhouette
mixing livestock and shrine guardian proportions, pale hide with carved stone
pattern etched around the shoulders, one eye reflecting a faint star-like light
while the other is dark and bovine, heavy hooves with geometric carvings,
short thick horns with cold metallic sheen, uncanny but not monstrous expression,
5-8 color palette, dominant tones: cold grey-blue and pale gold,
accent color: faint star-white in the reflecting eye

[Lore Context]
stone-carved pattern on shoulder matching tower masonry, tally notch on left horn

[Pixel Constraints]
7 color palette, fill 70-85% canvas, 3 shape masses maximum,
flat interior fills, strong silhouette read

[Negative]
not pokemon-like, not dragon-quest-like, not anime mascot, no busy background,
no weapons unless motif requires, no realistic rendering

[Tool Suffix]
--ar 1:1 --niji 7
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
