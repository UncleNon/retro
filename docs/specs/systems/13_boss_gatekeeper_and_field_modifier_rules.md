# 13. Boss, Gatekeeper And Field Modifier Rules

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/specs/systems/01_numeric_rules_and_master_schema.md`
> - `docs/specs/systems/02_battle_and_ai_rules.md`
> - `docs/specs/story/04_main_story_beats_and_world_sequence.md`
> - `docs/specs/worlds/04_dungeon_template_catalog.md`

---

## 1. 目的

- 通常戦と違う `ボス戦の読み合い` を、作戦AI前提の文法で成立させる
- 門守、世界ボス、終盤ボスがすべて別の難しさを持つようにする
- 場効果、phase 遷移、telegraph の規格を先に固定して後工程の破綻を防ぐ

---

## 2. ボスの分類

| boss_class | 役割 | 主な配置 |
|------------|------|----------|
| `gatekeeper` | 世界導入 / 門解放の節目 | 序盤〜中盤 |
| `warden` | その世界の禁忌を体現する | 各 world 主ボス |
| `arbiter` | rank / 闘技 / 制度の選別者 | judgment worlds |
| `fracture_host` | 残響、変異、継ぎ目を前面化 | fracture worlds |
| `terminal_core` | 本編終盤の責任主体 | Act IV-V |
| `postgame_aberration` | 深層や裏要素用 | postgame |

### 2.1 battle length の目安

| class | 目標時間 |
|-------|---------:|
| `gatekeeper` | 60〜120秒 |
| `warden` | 90〜180秒 |
| `arbiter` | 90〜150秒 |
| `fracture_host` | 120〜210秒 |
| `terminal_core` | 150〜240秒 |

---

## 3. phase 規格

### 3.1 phase 数

| boss tier | 既定 phase 数 |
|-----------|---------------|
| 序盤 | 1〜2 |
| 中盤 | 2 |
| 終盤 | 2〜3 |
| postgame | 3 まで許可 |

### 3.2 trigger

| trigger_type | 例 |
|--------------|----|
| `hp_threshold` | `75%`, `45%`, `20%` |
| `turn_count` | 3T 経過 |
| `part_break` | 支柱破壊、印章剥離 |
| `field_state` | 霧解除、鐘停止 |
| `ally_down` | 召喚体全滅 |

### 3.3 phase transition ルール

- 切替時に 1 行以上の telegraph text を必ず出す
- 切替直後の即死級行動は禁止
- phase 切替は `戦況が変わる合図` であって `理不尽な裏切り` ではない
- 作戦AIでも対応可能な情報差に留める

---

## 4. telegraph 規格

### 4.1 出し方

| 種類 | 伝え方 |
|------|--------|
| 視覚 | 色変化、紋様点灯、支柱脈動 |
| 文言 | 1〜2 行の短文 |
| 音 | 鈴、唸り、膜音、無音化 |
| 行動前兆 | 構え、吸気、足止め、空間の歪み |

### 4.2 原則

- 予兆は最低 1 ターン前に見せる
- 重要行動は `一度見たら学習できる` こと
- telegraph 文はシステム用語でなく世界語彙で返す

### 4.3 禁止

- 予兆なしの全体即死
- phase 遷移と同ターンに回避不能の壊滅技
- battle log を 3 文以上連続で流してテンポを壊すこと

---

## 5. gatekeeper 設計ルール

### 5.1 gatekeeper が教えるもの

各 gatekeeper は次のどれか 2 つ以上を教える。

- 作戦切替
- 状態異常対策
- `marked / hush / seal / wet` など本作固有状態
- bait を温存する判断
- 壁 / 防御 / 守りの価値
- 属性相性

### 5.2 序盤 gatekeeper の禁止

- 3 phase
- 全体 2 連打
- 連続蘇生
- 戦闘中の複雑な add 管理

### 5.3 序盤 gatekeeper の許可

- `marked` 奪取
- 単純な場効果 1 つ
- telegraph つき強打
- 状態異常 1 種中心

---

## 6. field modifier 規格

### 6.1 設計原則

- 場効果は `雰囲気` でなく `戦術の軸` として使う
- 1 戦に同時適用する field modifier は 2 つまでを基本とする
- その世界の禁忌や生態と接続する名前にする

### 6.2 既定 field modifier

| field_modifier | 効果 |
|----------------|------|
| `wet_field` | 水 / 雷が強まり、火が弱まる |
| `ash_field` | 命中微減、封印系が強まる |
| `wind_shear` | bird / light bodies が先制しやすい |
| `grave_hush` | `hush` 成功率増、回復量微減 |
| `bell_resonance` | `marked` の発生率増 |
| `mirror_glare` | 単体補助の target 読みが揺れる |
| `gate_pressure` | mutation 系 / divine 系が強くなる |
| `thin_air` | MP消費 +1, 逃走率低下 |

### 6.3 数値帯

| 効果種別 | 目安 |
|----------|------|
| 属性補正 | `±10%〜20%` |
| 命中補正 | `±4〜10` |
| initiative 補正 | `±2〜8` |
| 状態成功率補正 | `±4〜12` |

---

## 7. add / support body 規格

### 7.1 許可条件

- 中盤以降
- そのボスの論理と繋がっている
- `add を無視して本体だけ殴る` が唯一解にならない

### 7.2 数

| boss tier | 常時 add 数 |
|-----------|------------:|
| 序盤 | 0 |
| 中盤 | 0〜1 |
| 終盤 | 1〜2 |
| postgame | 2〜3 |

### 7.3 add の役割

- 回復補助
- mark / seal / hush の付与
- field modifier の維持
- 本体の防壁

---

## 8. boss AI profile

### 8.1 基本 profile

| profile_id | 役割 |
|------------|------|
| `BRUTE` | 物理圧 |
| `HEXER` | 状態異常とデバフ |
| `WARDEN` | 守りと召喚 |
| `JUDGE` | 条件分岐で裁く |
| `FRACTURE` | 残響、mark、所属剥離 |
| `CORE` | 複合型、phase 切替強め |

### 8.2 AI 優先度の原則

- 同じ強行動を 3 回以上連続しない
- 作戦AIで対策しにくい完全メタ読みをしない
- `player weakness exploit` は 50% 以下に抑える

---

## 9. defeat / retry ポリシー

### 9.1 ボス前リトライ

- 主要 boss には直前ショート復帰を許可する
- ただし消耗品消費は巻き戻さない
- 学習と資源圧を両立する

### 9.2 escape

| 戦闘種別 | 逃走 |
|----------|------|
| 通常戦 | 可 |
| gatekeeper | 不可 |
| world warden | 不可 |
| 任意再戦ボス | 可にしてもよい |

---

## 10. reward 規格

### 10.1 勝利報酬

| 要素 | 原則 |
|------|------|
| 経験値 | 通常戦の `2.5〜6.0` 倍 |
| 金 | その時点の回復 / bait 補充に意味がある額 |
| ドロップ | 触媒、記録物、進行鍵のいずれか |
| 解放 | gate, shop, NPC phase, clue resolved のどれか |

### 10.2 禁止

- 勝っても戦術理解が進まない報酬構成
- 単に数値の強い装備に相当するもの

---

## 11. Vertical Slice のボス線

### 11.1 `逆杭のマヨイカカシ`

- class: `gatekeeper`
- phase: 2
- teaches:
  - `marked` の危険
  - `みやぶる` と `seal` の価値
  - `wall / defense` の使いどころ

### 11.2 phase 例

| phase | 条件 | 主行動 |
|-------|------|--------|
| 1 | 開幕 | `marked`, `shirushiubai`, `hushed` |
| 2 | HP 50% 以下 | 自己強化 + telegraph つき重打 |

---

## 12. QA Checklist

- このボスは何を教える戦いか一文で言えるか
- phase 遷移に予兆があるか
- 場効果がただの数値ノイズになっていないか
- 作戦AIでも対処可能な情報差か
- 勝って得る理解が、次の世界や門の文法に繋がるか
