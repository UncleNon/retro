# 06. Monster Taxonomy And Motif Rules

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/requirements/04_monster_design.md`
> - `docs/specs/art/01_style_bible.md`
> - `docs/specs/systems/01_numeric_rules_and_master_schema.md`
> - `docs/specs/story/01_story_bible.md`

---

## 1. 目的

- 400体を量産しても、`同じAI絵の焼き直し` に見えないようにする
- モンスター1体ごとに、見た目、役割、世界観、配合価値、図鑑文が一本化されるようにする
- モチーフ選定とプロンプト構築を、職人芸ではなく再現可能な工程にする

---

## 2. モンスター設計の抽象原則

### 2.1 一文原則

> モンスターは「ただの生き物」でも「ただの神話引用」でもなく、生活、制度、禁忌、自然、継承のどれか二つ以上が交差した存在として設計する。

### 2.2 必須の二層構造

各モンスターは最低でも次の二層を持つ。

| 層 | 内容 |
|----|------|
| 表層 | 一目で分かるモチーフ。動物、植物、道具、気象、儀礼具など |
| 深層 | この世界での意味。名前、所属、弔い、配合、塔、門、共同体の記憶など |

### 2.3 禁止

- 元ネタが透けすぎる神話直写
- 既存IPの系統定番をなぞるだけの骨格
- 「不気味さ」を血や目玉の量で済ませる造形
- 配合素材としてしか存在理由がない空疎なデザイン

---

## 3. モチーフの大分類

### 3.1 主モチーフ系

| `motif_group` | 説明 | 目標体数 |
|---------------|------|---------:|
| `animal` | 現実動物、家畜、害獣、野生生物 | 110 |
| `plant` | 植物、菌、穀物、草、根、実 | 60 |
| `tool` | 生活道具、農具、記録具、葬具、建材 | 55 |
| `ritual` | 供物、祭具、印、札、鐘、仮面 | 45 |
| `weather` | 霧、風、雨、雷、煤、温度差 | 30 |
| `myth` | 神話、民話、寓話の断片 | 40 |
| `corporeal` | 骨、皮、歯、臓器、脱皮、殻 | 30 |
| `abstract` | 名、記録、沈黙、祈り、所属、境界 | 30 |

### 3.2 補助モチーフ系

| `secondary_motif_group` | 説明 |
|-------------------------|------|
| `household` | 台所、納屋、囲い、洗濯、火床 |
| `pastoral` | 放牧、焼印、鈴、首輪、柵 |
| `funerary` | 墓、供花、位牌、香、弔い布 |
| `bureaucratic` | 台帳、印章、登録札、戸口印 |
| `astral` | 星図、反射、月齢、観測器 |
| `gatebound` | 門、継ぎ目、境界杭、通行証 |

### 3.3 体数配分ルール

- 全400体のうち、`animal + plant + tool` で `55%〜65%` を占める
- `myth` は単独で使わず、必ず別カテゴリと混ぜる
- `abstract` は高ランク比率を高くし、序盤で多用しない
- `funerary`, `bureaucratic`, `gatebound` は本作固有性の核なので、合計 `30%` 以上に関与させる

---

## 4. family とモチーフの相性表

| family | 相性が良い主モチーフ | 注意点 |
|--------|----------------------|--------|
| `beast` | `animal`, `pastoral`, `corporeal` | ただの獣に戻りやすい |
| `bird` | `animal`, `weather`, `bureaucratic` | generic コウモリ悪魔化を避ける |
| `plant` | `plant`, `funerary`, `weather` | 花一本の記号化を避ける |
| `material` | `tool`, `ritual`, `gatebound` | 顔だけ付けた道具化を避ける |
| `magic` | `abstract`, `astral`, `bureaucratic` | 霊体玉の凡庸化に注意 |
| `undead` | `funerary`, `corporeal`, `ritual` | 露悪的腐敗に逃げない |
| `dragon` | `animal`, `myth`, `astral` | 既視感の西洋竜を避ける |
| `divine` | `myth`, `ritual`, `gatebound` | 単なる神聖化で終わらせない |

---

## 5. ランク別の設計圧

| rank | 設計ルール |
|------|------------|
| E | 一目で読める、生活圏にいそう、役割も単純 |
| D | 部位か挙動に一つだけ異物感を入れる |
| C | 由来や制度の匂いが図鑑なしでも少し滲む |
| B | 見た目の時点で世界の禁忌を背負う |
| A | 骨格、儀礼、階級性のどれかが一段複雑になる |
| S | 一体で小神話や事件の中心になれる格 |

---

## 6. 変形法則

### 6.1 動物由来

- 家畜なら `首 / 耳 / 足首 / 角` に管理の痕を入れる
- 野生動物なら `環境適応` と `人間社会の痕跡` を同時に持たせる
- 群れで認識される動物は、`数えるための印` を入れる

### 6.2 植物由来

- 食用、薬用、供物用の区別を持たせる
- 根、葉、種、花のどこに人格があるかを先に決める
- 湿気、腐葉、灰、供養具のどれかと接続する

### 6.3 道具由来

- 道具単体ではなく `使われた履歴` を持たせる
- 壊れ、修繕、名前書き、煤、血でなく `生活の摩耗` を優先する
- 顔を置くより先に `どう動くか` を決める

### 6.4 神話由来

- 固有名詞を借りない
- 神話の `役割`, `姿勢`, `禁忌構図`, `祭祀関係` を抽出して再構成する
- 生活圏へ縮退させる。大英雄ではなく村の棚や祠に落とす

### 6.5 抽象由来

- 何を可視化した存在かを一文で言えるようにする
- 抽象だけでは弱いので、必ず `身体` か `道具` を与える
- 名、所属、沈黙、記録は UI や図鑑にも接続させる

---

## 7. 400体の配分骨格

### 7.1 family 配分案

| family | 目標体数 |
|--------|---------:|
| `beast` | 72 |
| `bird` | 44 |
| `plant` | 46 |
| `material` | 58 |
| `magic` | 52 |
| `undead` | 40 |
| `dragon` | 42 |
| `divine` | 46 |

### 7.2 world participation ルール

- 1体につき `native_world_count` は原則 `1〜3`
- `tower_touched` な個体は追加で `+1` 世界に顔を出してよい
- 変異種は `native_world_count` に含めず、`mutation_occurrence_worlds` で管理する

### 7.3 tier 分布

| ランク | 目標体数 |
|--------|---------:|
| E | 96 |
| D | 94 |
| C | 82 |
| B | 60 |
| A | 42 |
| S | 26 |

---

## 8. モンスター1体の必須設計項目

### 8.1 世界観側

- `monster_id`
- `name_jp`
- `family`
- `rank`
- `motif_group`
- `motif_source`
- `secondary_motif_group`
- `world_context`
- `taboo_link`
- `lore_hook`

### 8.2 運用側

- `battle_role`
- `recruit_difficulty`
- `breed_role`
- `mutation_profile`
- `native_world_count`
- `sprite_size`
- `field_presence_type`

### 8.3 美術側

- `silhouette_type`
- `primary_palette_keys`
- `outline_rule`
- `animation_budget`
- `must_keep_shape`
- `ai_generation_notes`

---

## 9. Prompt Architecture

### 9.1 構造

各モンスターのプロンプトは、以下の6ブロックで構成する。

1. `Invariant`
2. `Body`
3. `Lore`
4. `Pixel Constraints`
5. `Negative`
6. `Edit Notes`

### 9.2 `Invariant`

```text
pixel art, transparent background, no anti-aliasing, 1px outline, top-left light,
gbc-inspired limited palette, readable at 1x, strong silhouette, no text, no logo,
no trademark, no existing IP resemblance
```

### 9.3 `Body`

```text
family: {family}, rank: {rank}, silhouette: {silhouette_type},
motif: {motif_source}, secondary motif: {secondary_motif_group},
battle sprite size: {battle_sprite_px}px, field sprite size: {field_sprite_px}px
```

### 9.4 `Lore`

```text
This creature belongs to a dark pastoral fantasy world where names, lineage, ownership,
gate rituals, and village taboo leave visible marks on living beings.
It should suggest: {world_context}. It must imply: {taboo_link}.
```

### 9.5 `Pixel Constraints`

```text
use 4-8 colors only, avoid texture noise, keep major read in three shape masses,
do not over-detail interior pixels, no smooth shading, no modern glossy rendering
```

### 9.6 `Negative`

```text
do not make it pokemon-like, dragon-quest-like, disney-like, anime mascot style,
do not use generic demon bat wings unless explicitly requested,
do not create busy background, no weapons unless the motif requires it
```

### 9.7 `Edit Notes`

```text
change only: {delta_request}. keep silhouette, palette logic, outline thickness,
lighting, and motif hierarchy unchanged.
```

---

## 10. 量産テンプレ

```yaml
monster_id: MON-###
name_jp: ""
family: beast|bird|plant|material|magic|undead|dragon|divine
rank: E|D|C|B|A|S
motif_group: animal|plant|tool|ritual|weather|myth|corporeal|abstract
motif_source: ""
secondary_motif_group: household|pastoral|funerary|bureaucratic|astral|gatebound
world_context: ""
taboo_link: ""
lore_hook: ""
battle_role: striker|tank|healer|controller|bait-specialist|mutation-key
breed_role: common-source|family-bridge|special-recipe|mutation-anchor|legend-chain
silhouette_type: round|wide|tall|serpentine|floating|tripod|massive
field_sprite_px: 16
battle_sprite_px: 32
primary_palette_keys:
  - ""
must_keep_shape:
  - ""
ai_generation_notes:
  - ""
```

---

## 11. Review Checklist

### 11.1 デザイン

- 一文で何の生き物か言えるか
- 一文でなぜこの世界の生き物か言えるか
- 同系統の別個体とシルエットで区別できるか
- 配合素材としての役割があるか

### 11.2 美術

- 1x で読めるか
- palette over していないか
- interior noise が多すぎないか
- field sprite へ縮めたときに死なないか

### 11.3 世界観

- 村、塔、門、禁忌のいずれかに接続しているか
- 図鑑文を書けるだけの意味があるか
- ただの既存神話の変名になっていないか

### 11.4 IP safety

- 既存IPに寄せた語を使っていないか
- 既視感の強い骨格になっていないか
- 参照元の固有記号を引きずっていないか
