# 08. World Sheet Template And Variation Rules

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/specs/worlds/05_world_catalog_and_budget.md`
> - `docs/specs/worlds/06_settlement_layout_and_route_rules.md`
> - `docs/specs/worlds/07_world_sheet_contract.md`
> - `docs/specs/story/04_main_story_beats_and_world_sequence.md`
> - `docs/specs/story/03_foreshadow_allocation_map.md`
> - `docs/specs/story/10_starting_arc_engagement_playbook.md`
> - `docs/specs/story/11_session_pacing_and_curiosity_contract.md`
> - `docs/specs/content/08_starting_region_ecology_and_monster_web.md`

---

## 1. 目的

- 21 世界を個別詳細へ落とすときに、毎回ゼロから考えて薄くなるのを防ぐ
- `景色`, `政治`, `禁忌`, `モンスター`, `経済`, `伏線`, `門条件` を同じフォーマットで揃える
- small / medium / large の世界差を、規模だけでなく情報密度でも管理する

---

## 2. world sheet の必須項目

### 2.1 基本情報

- `world_id`
- `name_jp`
- `name_en`
- `act`
- `size_class`
- `world_function`
- `recommended_level_band`
- `one_sentence_premise`

### 2.2 世界の論理

- `public_face`
- `hidden_wound`
- `primary_taboo`
- `taboo_surface_phrase`
- `political_structure`
- `economic_structure`
- `ritual_structure`
- `gate_relationship`

### 2.3 コンテンツ運用

- `map_budget`
- `settlement_count`
- `dungeon_count`
- `native_monster_count`
- `native_family_bias`
- `shop_band`
- `boss_class`
- `boss_teaches`

### 2.4 ストーリー

- `foreshadow_ids`
- `main_reveal_role`
- `cross_world_echoes`
- `record_objects`
- `npc_roster_min`
- `return_visit_delta`
- `local_answer`
- `bigger_question`

### 2.5 child surfaces

- `story_hook_surface`
- `ecology_surface`
- `runtime_row`

---

## 3. size class ごとの期待値

| 項目 | `small` | `medium` | `large` |
|------|---------|----------|---------|
| maps | 6〜9 | 9〜12 | 12〜18 |
| settlements | 1 | 1〜2 | 2〜3 |
| dungeons | 1 | 1〜2 | 2〜3 |
| major NPC | 3〜5 | 4〜7 | 6〜10 |
| unique clue payload | 2〜3 | 3〜5 | 5〜7 |
| shop bands | 1 | 1〜2 | 2〜3 |

---

## 4. taboo variation axis

### 4.1 変奏の軸

各世界は最低 2 軸、多くて 4 軸を使う。

| axis | 内容 |
|------|------|
| `name` | 真名、借り名、役名、冬名、洗名 |
| `lineage` | 実親、養親、継子、血統、修復系譜 |
| `ownership` | 家印、焼印、札、通行証、戸口印 |
| `record` | 台帳、寺院記録、宿帳、闘籍、墓碑 |
| `body` | 角、耳、骨、皮、継ぎ痕、印痕 |
| `ritual` | 誓詞、弔い、供物、巡礼、通過儀礼 |
| `labor` | 家畜管理、荷役、収穫、徴税、登録 |

### 4.2 ルール

- 同じ axis を使っても `どう怖いか` を変える
- 序盤は `name`, `ownership`, `record` を中心にする
- 中盤から `lineage`, `ritual`, `labor` を重ねる
- 終盤では `body` を絡めて世界の継ぎ目へ寄せる

---

## 5. world sheet テンプレート

```yaml
world_id: W-###
name_jp: ""
name_en: ""
act: I|II|III|IV|V
size_class: small|medium|large
world_function: echo_world|social_world|material_world|ritual_world|fracture_world|judgment_world|terminal_world
recommended_level_band: "00-00"
one_sentence_premise: ""

public_face: ""
hidden_wound: ""
primary_taboo: ""
taboo_surface_phrase: ""
political_structure: ""
economic_structure: ""
ritual_structure: ""
gate_relationship: ""

taboo_axes:
  - name
  - record

map_budget:
  total_maps: 0
  settlements: 0
  dungeons: 0
  fields: 0
  interiors: 0

content_budget:
  native_monster_count: 0
  major_npcs: 0
  clues: []
  record_objects: []
  shops: []

native_family_bias:
  - beast
  - material

boss:
  boss_class: gatekeeper|warden|arbiter|fracture_host|terminal_core
  teaches:
    - ""
  field_modifier:
    - ""

cross_world_echoes:
  - W-###
  - W-###

gate_condition:
  gate_condition_type: story_flag|item|rank|family_resonance|record_count|ritual_state|composite
  visible_surface: ""
  backend_requirements:
    required_flag: ""
    required_item: ""
    required_rank: ""
    required_family_resonance: ""
    required_record_count: 0
  fail_feedback: ""
  success_shift: ""

return_visit_delta: ""
```

### 5.1 gate condition templates

`gate_condition` は free text の感想欄でなく、進行設計の契約として使う。

| `gate_condition_type` | 何を要求するか | 向いている world |
|-----------------------|----------------|------------------|
| `story_flag` | 世界内事件の解決、主要 actor の phase 進行 | すべて。最も基本 |
| `item` | key item, writ, seal, rubbing, ritual object | early echo / material worlds |
| `rank` | 闘技、通行資格、公的序列 | judgment worlds |
| `family_resonance` | 特定 family / ontology の同伴や提示 | pastoral, gatebound, fracture |
| `record_count` | 台帳、拓本、clue log の累積 | ledger / ritual / terminal |
| `ritual_state` | 誓詞、弔い、鐘、供物の正しい手順 | ritual worlds |
| `composite` | 上記 2 つ以上の組み合わせ | Act IV-V, terminal worlds |

### 5.2 act 別の複雑さ上限

| Act | 基本形 | 禁止 |
|-----|--------|------|
| I | `story_flag` 単独、または `story_flag + item` | 3条件以上の複合 |
| II | 単独 or 2条件 | missable clue 前提 |
| III | 2条件中心 | UI だけ見ないと解けない不可視条件 |
| IV | 2条件 + visible surface を強く出す | lore を知らないと理不尽になる鍵探し |
| V | `composite` 可。ただし本編完結に必須の条件は再確認導線を必ず置く | RNG 依存、rare spawn 依存 |

### 5.3 visible surface rule

どの gate も、プレイヤーに `何を試されているか` の表面を先に見せる。

| surface | 例 |
|---------|----|
| `資格` | 門札、階位章、通行検査台 |
| `記録` | 拓本台、帳場、照合棚 |
| `血統 / family` | 柵、焼印台、共鳴柱 |
| `儀礼` | 鐘、供物台、逆誓詞、灰匙 |

ルール:

- backend requirement は hidden でも、visible surface は hidden にしない
- fail feedback は `世界語彙` で返す
- success shift は `listening -> awakened -> stable` のどこが進むかを書き残す

---

## 6. cross-world echo の持たせ方

### 6.1 必須 echo

各世界は最低 3 つ持つ。

- `material echo`: 札、鈴、灰、骨、帳、布など
- `social echo`: 呼び方、席順、登録手続き、婚姻、相続など
- `monster echo`: 図鑑文、生態、trait、落とし物

### 6.2 禁止

- ただ同じオブジェクトを繰り返すだけ
- 他世界との差別化が説明できない echo

---

## 7. settlement sheet との接続

### 7.1 1 world あたり最低 1 拠点

拠点 sheet には以下を最低限引き継ぐ。

- 世界の表の顔
- 禁忌の生活化
- shop band
- NPC tone
- record object 1 件以上

### 7.2 世界と拠点の関係

| 拠点種別 | 役割 |
|----------|------|
| `main_settlement` | その世界の公共ルールを見せる |
| `edge_hamlet` | 禁忌の被害や変奏を見せる |
| `ritual_site` | 世界観の歪みを濃縮する |

---

## 8. dungeon との接続

### 8.1 必須整合

- dungeon template が世界 function と噛むこと
- field modifier が地形と政治の両方に意味を持つこと
- ボスの teaches がその世界の taboo axis を反転させること

### 8.2 例

| world_function | dungeon に欲しいこと |
|----------------|----------------------|
| `echo_world` | 故郷の変奏を短く強く見せる |
| `social_world` | 記録庫、役所、登録の空間 |
| `material_world` | 荷、骨、印、修繕の物流 |
| `ritual_world` | 供物、弔い、誓詞、巡礼 |
| `fracture_world` | 残響、鏡、名前の崩れ |
| `terminal_world` | 深層への通路、責任の集約 |

---

## 9. 先に決めるべき世界別項目

各個別 world sheet を書く前に、最低限これを埋める。

1. この世界は何を証明するか
2. この世界の禁忌は日常語で何と言われるか
3. 何が売られ、何が数えられ、何が隠されるか
4. どの family が自然に出るか
5. 何の clue を置くか
6. どの gate condition を進めるか
7. ボスが何を教えるか

---

## 10. DoD

1 世界の world sheet は、以下で完成扱いにする。

- テンプレ全項目が埋まっている
- `foreshadow_ids` が 2 件以上ある
- `boss_class` と `boss_teaches` が定義済み
- `native_family_bias` と `economic_structure` が繋がっている
- `taboo_axes` と `record_objects` が繋がっている
- `cross_world_echoes` が 2 世界以上に張られている

---

## 11. QA Checklist

- この世界の禁忌は一文で言えるか
- 故郷との echo があるか
- 他世界との差が地形だけで終わっていないか
- ボス、店、NPC、モンスターが同じ論理で動いているか
- `small` なのに情報過多、`large` なのに薄い、になっていないか
