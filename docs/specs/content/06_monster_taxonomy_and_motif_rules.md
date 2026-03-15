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
| `slime` | `weather`, `abstract`, `corporeal` | 定番の雫シルエットに戻ると既視感が強すぎる |
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

### 5.1 rank ごとの運用役割

`見た目の格` と `ゲーム内の役目` を分離しないため、各 rank は次の役割帯を基本にする。

| rank | encounter での基本役割 | recruit / breed での役割 | lore の背負い方 |
|------|------------------------|--------------------------|------------------|
| E | 生活圏の顔、序盤の比較対象、群れの底支え | 初期 recipe source、family 入門、bait 反応が分かりやすい | 世界の空気を一番素直に運ぶ |
| D | 序盤〜中盤の標準戦力、軽い status tax、地域差の見せ場 | common bridge、同系統強化の土台 | 制度の傷が少し見える |
| C | 役割が立つ utility / controller、branch route の旨味 | family bridge、条件付き recipe の入口 | 図鑑を読むと意味が反転し始める |
| B | world taboo を戦術で体現する、danger route の看板 | 特殊 recipe の核、変異触媒との相性が出る | 見た目の時点で禁忌を背負う |
| A | gatekeeper 周辺、権力側の飼養種、地域 elite | mutation anchor、後半 bloodline の方向づけ | 世界事件や勢力運用の文脈を強く背負う |
| S | 本編外周・終盤・postgame の apex | 最終 chain、legend recipe、単純勧誘禁止が基本 | 1体で神話、事故、制度の中心になれる |

### 5.2 authoring guardrail

- E と D は `可愛さ / 分かりやすさ` を優先してもよいが、世界の語彙から外さない
- C 以上は、`戦闘役割`, `血統価値`, `世界の意味` の 3 つが同時に説明できること
- B 以上をただの数値上位互換にしない
- S は希少性より `世界を読み替える力` を優先する

---

## 6. 変形法則

### 6.1 スライム由来

- 本作の `slime` はマスコット的な雫ではなく、`乳膜`, `塩ゼリー`, `煤泥`, `墓水の膜`, `帳面インクのにじみ` など `残留物が生き物化したもの` として設計する
- 左右対称の滴型より、`垂れ`, `偏り`, `染み`, `薄膜` を優先する
- `gate-touched` や `record-bent` と相性が良く、門の湿り気、札の糊、焼け跡の粘りを body language にできる
- 既存JRPG直系の「丸い青スライム」は禁止。色も `乳白`, `鈍灰`, `藍墨`, `塩緑` を主に使う

### 6.2 動物由来

- 家畜なら `首 / 耳 / 足首 / 角` に管理の痕を入れる
- 野生動物なら `環境適応` と `人間社会の痕跡` を同時に持たせる
- 群れで認識される動物は、`数えるための印` を入れる

### 6.3 植物由来

- 食用、薬用、供物用の区別を持たせる
- 根、葉、種、花のどこに人格があるかを先に決める
- 湿気、腐葉、灰、供養具のどれかと接続する

### 6.4 道具由来

- 道具単体ではなく `使われた履歴` を持たせる
- 壊れ、修繕、名前書き、煤、血でなく `生活の摩耗` を優先する
- 顔を置くより先に `どう動くか` を決める

### 6.5 神話由来

- 固有名詞を借りない
- 神話の `役割`, `姿勢`, `禁忌構図`, `祭祀関係` を抽出して再構成する
- 生活圏へ縮退させる。大英雄ではなく村の棚や祠に落とす

### 6.6 抽象由来

- 何を可視化した存在かを一文で言えるようにする
- 抽象だけでは弱いので、必ず `身体` か `道具` を与える
- 名、所属、沈黙、記録は UI や図鑑にも接続させる

---

## 7. 400体の配分骨格

### 7.1 family 配分案

| family | 目標体数 |
|--------|---------:|
| `slime` | 35 |
| `beast` | 55 |
| `bird` | 40 |
| `plant` | 40 |
| `magic` | 45 |
| `material` | 40 |
| `undead` | 45 |
| `dragon` | 50 |
| `divine` | 50 |

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

### 7.4 ontology class ルール

family とは別に、各個体は `ontology_class` を持つ。これにより「どういう存在なのか」を世界観側で追跡できる。

| `ontology_class` | 内容 | 主に出る場所 |
|------------------|------|--------------|
| `wildborn` | 世界分岐後に安定化した在来個体 | 生活圏、通常フィールド |
| `gate_touched` | 門や継ぎ目の影響を受け、形質や挙動がずれた個体 | 塔周辺、境界地帯、Hungry worlds |
| `bred_line` | 人間の配合・選抜・飼養で固定された系統 | 牧場、闘技会、市場、名家の囲い |
| `record_bent` | 名札、印章、帳簿、家印などの記録物に反応する個体 | social / material worlds |
| `remnant_bearing` | 失踪者や場所の残響を薄く宿す個体 | fracture / terminal worlds, 深層イベント |

- 1世界につき最低2 class を混在させる
- `remnant_bearing` は roster 全体の `10%` を超えない
- `slime`, `magic`, `undead` は `record_bent` や `remnant_bearing` を持ちやすい
- `beast`, `plant`, `bird` は `wildborn` を基礎にし、必要な世界だけ `gate_touched` を被せる

---

## 7.5 ランク別の戦闘・配合役割

| ランク | 戦闘での主要役割 | 配合での役割 | 入手経路 |
|--------|----------------|-------------|----------|
| E | 初期戦力、学習用、序盤のスカウト対象 | 系統チェーンの基盤素材。数を揃えやすく、家系法則の基礎練習台 | 序盤世界で野生出現。全プレイヤーが必ず触れる |
| D | 中盤の主力、属性カバー要員 | 系統橋渡し素材。一部の特殊レシピ入力にもなる | 中盤世界で野生出現、E同士の配合でも生成可能 |
| C | 戦略的スペシャリスト、ボス戦の準備枠 | 特殊レシピの出力先、変異アンカー。ここから配合の奥行きが増す | 野生は稀少。D+E または D+D の配合が主な入手手段 |
| B | 後半の中核戦力、エンドゲーム準備の柱 | 複数ステップの配合チェーン結果。伝説チェーンへの入力素材にもなる | **配合専用**（野生出現なし）。最低2世代の配合履歴が必要 |
| A | エンドゲームの精鋭。属性・スキルが高度に特化 | 複雑な多世代チェーンの到達点。S ランクへの入力 | **配合専用**。3世代以上の配合深度が必要 |
| S | 究極個体。ボス級の格と圧を持つ | 頂点レシピ。A+A または特定 A の組み合わせのみ | **配合専用**。5世代以上の配合深度が最低条件。勧誘不可 |

設計原則:
- B 以上が野生に出ないことで、「配合でしか手に入らない」価値が生まれる
- ランクが上がるほど配合世代数が深くなり、`unique-my-monster` の実感が強まる
- E–D は量で、C は転換点で、B–S は質で存在意義を持たせる

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
- `ontology_class`
- `world_context`
- `taboo_link`
- `lore_hook`
- `resonance_grade`
- `human_pressure_tags`

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

### 9.0 Prompt Design Rules

以下のルールはすべてのモンスタープロンプトに適用される。

#### Output specification rules

- Always specify exact pixel size for the target sprite (e.g., "32x32 pixels")
- Always specify "transparent background"
- Always specify "1px black outline" or "1px darkest-color outline"
- Always specify "top-left lighting"
- Always specify "no anti-aliasing, no dithering, no gradient, no smooth shading"
- Always specify "readable at 1x scale" (the sprite must be identifiable at native resolution)

#### Composition rules

- The creature should fill 70-85% of the canvas area
- Major visual read should come from 3 shape masses maximum
- Interior detail should use flat color fills, not texture noise
- The silhouette alone must identify the family type

#### Color specification rules

- E-D rank: specify "4-6 color limited palette"
- C-B rank: specify "5-8 color limited palette"
- A-S rank: specify "6-10 color limited palette"
- Always name 2-3 dominant color tones (e.g., "muted brown and bone", "cold grey-blue and pale gold")
- Reserve one "accent color" for the element/attribute marker

#### Motif integration rules

- Primary motif comes first in the description
- Secondary motif (pastoral/funerary/bureaucratic/gatebound etc.) is woven as a visual detail, not stated abstractly
- The motif should be described as a physical feature, not a concept (e.g., "burnt ear tag" not "livestock ownership concept")
- World context appears as material texture or wear pattern, not as narrative text

#### What NOT to include in prompts

- Character names
- Story spoilers or plot points
- Abstract game mechanics ("this monster has high DEF")
- References to existing IPs by name
- Multiple creatures in one prompt
- Complex poses or action scenes (keep idle/standing pose)

#### Tool-specific suffix rules

- For niji 7: append `--ar 1:1 --niji 7`
- For Nano Banana: describe the grid layout if requesting sprite sheet
- For GPT Image: no special suffix needed, but add "pixel art style" emphasis

### 9.1 構造

各モンスターのプロンプトは、以下の6ブロックで構成する。

1. `Invariant`
2. `Body`
3. `Lore Context`
4. `Pixel Constraints`
5. `Negative`
6. `Edit Notes`

### 9.2 `Invariant`

```text
pixel art, {battle_sprite_px}x{battle_sprite_px} battle sprite, transparent background,
1px black outline, top-left lighting, no anti-aliasing, no dithering, no gradient,
no smooth shading, gbc-inspired limited palette, readable at 1x, no text, no logo
```

### 9.3 `Body`

```text
{specific creature description with primary motif first, physical details,
silhouette type, and idle/standing pose},
{rank-appropriate color count} color palette, dominant tones: {2-3 named color tones},
accent color: {element/attribute accent color}
```

### 9.4 `Lore Context`

```text
{1-2 short visual cues described as physical textures, marks, or wear patterns
that connect the creature to the world — not narrative or backstory}
```

### 9.5 `Pixel Constraints`

```text
{color count} color palette, fill 70-85% canvas, 3 shape masses maximum,
flat interior fills, strong silhouette read, no texture noise, no smooth shading
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

Example: `change only: darken the horn tips to charcoal black. keep silhouette, palette logic, outline thickness, lighting, and motif hierarchy unchanged.`

### 9.8 Prompt Phrase Bank

実際のプロンプトで使える具体的な描写フレーズ集。

#### Village / pastoral marks

- "burnt ear tag", "faded brand mark on hide", "frayed rope collar", "tally notch on horn"
- "dried mud on hooves", "straw stuck in fur", "barn-dust patina"

#### Record / name / seal marks

- "scratched name plate hanging from neck", "ink-stained claws", "wax seal impression on shell"
- "faded registry stamp on flank", "carved tally marks on bone"

#### Funeral / mourning marks

- "wilted flower crown", "ash-dusted surface", "hollow eye sockets with dim glow"
- "wrapped in thin burial cloth strips", "incense-smoke colored wisps"

#### Gate / tower / boundary marks

- "stone-carved pattern on shoulder", "one eye reflecting distant light", "geometric cracks along spine"
- "moss pattern matching tower masonry", "cold metallic sheen on horns"

#### Texture descriptors for pixel art

- "rough wool texture in flat pixel clusters", "smooth chitin in 2-tone shading"
- "translucent membrane with single highlight pixel", "cracked stone surface in 3 values"

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
