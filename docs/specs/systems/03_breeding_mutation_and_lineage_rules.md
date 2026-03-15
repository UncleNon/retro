# 03. Breeding Mutation And Lineage Rules

> **ステータス**: Draft v1.1
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/specs/systems/01_numeric_rules_and_master_schema.md`
> - `docs/requirements/02_game_design_core.md`
> - `docs/requirements/04_monster_design.md`
> - `docs/adr/0008-core-experience-design-principles.md`

---

## 1. 目的

- 配合は「答えを見たら終わる一覧表」ではなく、知ってから血統設計が始まる中核システムとする
- 子の種は主に決定論で決まり、強さと希少性は `plus_value`, 継承、変異、育成履歴で差が付く
- 親消滅の痛みを残しつつ、子へ必ず前進感が残る

---

## 2. 実装対象と前提

### 2.1 必須マスターデータ

| テーブル | 必須カラム |
|----------|------------|
| `monster_master` | `monster_id`, `family_id`, `rank`, `ikai_index`, `base_level_cap`, `growth_curve_id`, `breed_tags`, `forbidden_tags`, `mutation_profile_id` |
| `breeding_rule_master` | `rule_id`, `priority`, `rule_type`, `parent_a_key`, `parent_b_key`, `child_monster_id`, `child_family_id`, `child_rank_delta`, `unlock_flag`, `required_location_id`, `required_trait_tags`, `required_min_level_sum`, `special_recipe_bonus` |
| `breeding_hint_master` | `hint_id`, `rule_id`, `hint_layer`, `text_id`, `source_type`, `unlock_flag` |
| `mutation_profile_master` | `mutation_profile_id`, `base_rate`, `allowed_classes`, `forbidden_classes`, `palette_table_id`, `trait_pool_id`, `aberrant_pool_id` |
| `genealogy_log` | `child_instance_id`, `parent_instance_ids`, `ancestor_ids`, `generation_depth`, `plus_history`, `mutation_history`, `world_of_birth`, `catalyst_used`, `breed_timestamp` |

### 2.2 family 一覧

| family_id | 説明 |
|-----------|------|
| `slime` | 柔体、粘性、流動 |
| `beast` | 獣、家畜、野生 |
| `bird` | 鳥、飛行、観測 |
| `plant` | 植物、菌類、蔓 |
| `magic` | 呪術、幻、印 |
| `material` | 石、金属、木工、器物 |
| `undead` | 死骸、残響、葬送 |
| `dragon` | 竜、爬、熱量、高位暴力 |
| `divine` | 聖性、門守、超越 |

### 2.3 配合解決の原則

- まず「成立するか」を判定し、その後に「何が生まれるか」を解決する
- 子の結果は `forbidden check -> special recipe -> family matrix -> mutation overlay` の順で決める
- 親レベルは種そのものより `plus_value`, 継承枠, mutation chance` に効かせる

---

## 3. 配合解決フロー

### 3.1 フローチャート

```text
input parents
  -> base validation
  -> forbidden breeding check
  -> special recipe resolution
  -> family matrix resolution
  -> same-family lineage adjustment
  -> child rank / ikai selection
  -> plus inheritance
  -> inherit candidate pool build
  -> mutation roll
  -> genealogy write
  -> result preview / confirm
```

### 3.2 base validation

両親とも以下を満たすこと。

- `level >= 10`
- 戦闘不能、ロック中、編成固定イベント中ではない
- 牧場枠に空きがある
- `gate_key` タグ付き個体ではない
- ストーリー封印中の `unlock_flag` に抵触しない

### 3.3 forbidden breeding check

禁止判定は special recipe 解決より前に走る。禁止なら配合画面で異常反応文を返し、実行不可。

```text
if parent_a.forbidden_tags ∩ parent_b.forbidden_tags triggers rule:
  reject
```

---

## 4. 優先順位と special recipe

### 4.1 解決順

```text
0. forbidden rule
1. ordered exact monster x exact monster
2. unordered exact monster x exact monster
3. ordered exact monster x family
4. ordered family x exact monster
5. unordered exact monster x family
6. family x family matrix
7. same-family lineage override
8. mutation overlay
```

### 4.2 priority ルール

- `priority` が高いレシピを優先
- `priority` が同値なら `rule_id` の昇順
- 左右非対称レシピは `ordered = true` とし、親の順序を厳密一致させる

### 4.3 special recipe の分類

| `rule_type` | 条件 |
|-------------|------|
| `exact_pair_ordered` | 完全指定、順序あり |
| `exact_pair` | 完全指定、順序なし |
| `exact_family` | 特定モンスター + family |
| `lv_gated` | 親合計Lv条件あり |
| `trait_gated` | trait tag 条件あり |
| `location_gated` | 特定施設、世界、塔の層条件あり |
| `story_gated` | 物語進行フラグが必要 |

### 4.4 special recipe 量の目安

| 範囲 | 目安 |
|------|-----:|
| Vertical Slice | 12〜20 |
| MVP | 40〜70 |
| Initial Release | 220〜320 |

### 4.5 special recipe の設計制約

- 総数を増やすだけでなく、「なぜこの2体からこれが生まれるのか」が視覚、世界観、役割で理解できること
- 少なくとも `20%` は世界、図鑑、NPC噂、失踪事件の断片と直結させる
- `story_gated` の多用は避ける。秘密の重みは保ちつつ、単なる進行ロックだらけにしない

---

## 5. family matrix logic

### 5.1 family result matrix

| A＼B | slime | beast | bird | plant | magic | material | undead | dragon | divine |
|------|-------|-------|------|-------|-------|----------|--------|--------|--------|
| slime | slime | beast | bird | plant | magic | material | undead | dragon | divine |
| beast | beast | beast | bird | plant | magic | beast | undead | dragon | divine |
| bird | bird | bird | bird | plant | magic | material | undead | dragon | divine |
| plant | plant | plant | plant | plant | magic | material | undead | dragon | divine |
| magic | magic | magic | magic | magic | magic | material | undead | dragon | divine |
| material | material | beast | material | material | magic | material | undead | dragon | divine |
| undead | undead | undead | undead | undead | undead | undead | undead | dragon | divine |
| dragon | dragon | dragon | dragon | dragon | dragon | dragon | dragon | dragon | divine |
| divine | divine | divine | divine | divine | divine | divine | divine | divine | divine |

### 5.2 子familyの決め方

```text
if special recipe matched:
  child_family = recipe child or child_family override
else:
  child_family = family_result_matrix[parent_a.family][parent_b.family]
```

### 5.3 子rankの決め方

```text
parent_rank_score = max(rank_score(a), rank_score(b))
base_rank_delta =
  0 if mixed family
  +1 if same family and lineage upgrade possible

child_rank_score =
  clamp(
    parent_rank_score + recipe.child_rank_delta + base_rank_delta,
    E,
    S
  )
```

| rank | score |
|------|------:|
| E | 1 |
| D | 2 |
| C | 3 |
| B | 4 |
| A | 5 |
| S | 6 |

### 5.4 `ikai_index` による種選択

- 各 family は `ikai_index` 昇順の内部ラダーを持つ
- 候補は `child_family + child_rank_score` で絞る
- 候補中から `avg(parent_a.ikai_index, parent_b.ikai_index)` に最も近い上位個体を選ぶ
- 候補が存在しない場合は、同 rank 内の最下位個体を採用

```text
target_ikai =
  ceil((parent_a.ikai_index + parent_b.ikai_index) / 2)

child_species =
  nearest_species_in_family_rank(child_family, child_rank_score, target_ikai)
```

### 5.5 same-family lineage override

- 同系統配合は `lineage_keep` を優先
- 同 rank 内に上位種が存在する場合は `ikai_index +1`
- 上位種が存在しない場合は種維持とし、`plus_value` と mutation chance のみ上昇

---

## 6. 継承ルール

### 6.1 `plus_value` 継承

`01_numeric_rules_and_master_schema.md` を正本とし、以下を採用する。

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

### 6.2 `plus_value` 設計意図

- 親を高レベルまで育てる理由を残す
- 低ランク種でも endgame に通用する成長余地を確保する
- 種そのものの解法と、血統育成の解法を分離する

### 6.3 継承ツリー枠

```text
inherit_tree_slots =
  2
  + 1 if parent_a.level + parent_b.level >= 80
  capped at 3
```

### 6.4 継承候補プール

継承候補は以下の順で構築する。

1. 親Aの最終習得ツリー
2. 親Bの最終習得ツリー
3. 子の系統固有ツリー
4. `special recipe` 固有ツリー
5. mutation による追加ツリー

### 6.5 継承候補の圧縮規則

- 同カテゴリの完全上位互換ツリーは下位を折りたたむ
- `forbidden_inheritance_tag` を持つツリーは除外
- UIには最大8件まで表示し、内部候補が8件を超える場合はカテゴリ代表を表示

### 6.6 trait 継承

- trait は原則として直接継承しない
- `inheritable_trait_pool` 指定のある trait のみ抽選対象
- 抽選ルールは `child_trait_slots = 1` を基本とし、変異または special recipe で `2` まで拡張可能

---

## 7. mutation rules

### 7.1 mutation 判定式

```text
mutation_rate =
  base_mutation_rate
  + parent_generation_bonus
  + catalyst_bonus
  + location_bonus
  + moon_phase_bonus
  + tower_resonance_bonus

final_mutation_rate = clamp(mutation_rate, 0, 25)
```

### 7.2 基本値

| 要素 | 値 |
|------|----|
| `base_mutation_rate` | 3% |
| `parent_generation_bonus` | 高い方の世代数 x `0.5%`、最大 `+4%` |
| `catalyst_bonus` | `+3〜8%` |
| `location_bonus` | `+2〜5%` |
| `moon_phase_bonus` | `+2%` |
| `tower_resonance_bonus` | `+3%` |

### 7.3 mutation class

| class | 内容 | 基本比率 |
|-------|------|---------:|
| `palette_shift` | 色変化 + 小trait差 | 45 |
| `role_shift` | 主力2ステータス傾向の入替 | 25 |
| `trait_shift` | trait追加 / 差し替え | 20 |
| `aberrant` | 別種へ逸脱、見た目も強く変化 | 10 |

### 7.4 class別ルール

| class | ルール |
|-------|--------|
| `palette_shift` | 種維持。図鑑は通常種の派生として記録 |
| `role_shift` | 種維持。`cap_stat` の主要2値に再配分 |
| `trait_shift` | 種維持。trait抽選を1回追加 |
| `aberrant` | rank は通常結果の `+1` まで。専用プールから選出 |

### 7.5 aberrant 制約

- Vertical Slice では出さないか、1〜2件まで
- Initial Release でも全配合結果の `2%未満` に抑える
- 再現条件は endgame まで完全公開しない

### 7.6 mutation と見た目の関係

- `palette_shift` は色差 + 紋様差のみ
- `role_shift` はシルエット維持、部位バランスのみ変化
- `trait_shift` は部位の追加、欠損、表情差
- `aberrant` は silhouette から大きく変えてよい

---

## 8. forbidden breeding

### 8.1 目的

- 世界観上の禁忌をシステムに接続する
- 単なる「ゲーム的に禁止」でなく、理由が気配として残る拒否反応を返す

### 8.2 forbidden class

| class | ルール |
|-------|--------|
| `human_trace` | 失踪者残響が強い個体同士の再配合を禁止 |
| `grave_meld` | `undead + divine` の一部 exact pair を封印 |
| `gate_key` | 門の核として使う個体は親にできない |
| `story_seal` | 本編特定段階までは不可 |
| `collapse_pair` | 成立すると設定が崩れる pair を開発上封印 |

### 8.3 拒否時のUI

- `配合できない` の固定文言だけでは終わらせない
- 異常反応テキストは `3〜5パターン` を持たせる
- 完全理由は出さず、図鑑、噂、記録官、塔の断片文で後から補完する

---

## 9. recipe hinting rules

### 9.1 ヒント階層

| Layer | 開示内容 |
|-------|----------|
| 1 | `family / rank` の傾向のみ |
| 2 | 世界やNPCが断片的な比喩ヒントを返す |
| 3 | 一度見た組み合わせは履歴に残る |
| 4 | 発見済みレシピは施設で正式表示 |

### 9.2 情報源

| source_type | 例 |
|-------------|----|
| `npc_rumor` | 村人、商人、記録官 |
| `bestiary` | 図鑑文の末尾 |
| `tower_echo` | 塔で見る断片文 |
| `tournament_reward` | 勝利報酬のレシピ片 |
| `field_note` | 世界内のメモ、碑文 |

### 9.3 プレイヤーに見せる情報

| 状態 | 表示 |
|------|------|
| 未発見 | `??系 / D〜Cランクかもしれない` |
| 片親だけ既知 | `鳥に近いが、骨が混じる` のような断片説明 |
| 発見済み | 正式名、family、rank、継承候補 |

### 9.4 見せない情報

- 未発見レシピの exact child name
- mutation chance の内部数値
- forbidden recipe の完全条件
- `aberrant` の再現条件

---

## 10. genealogy record rules

### 10.1 保存項目

| 項目 | 保持数 |
|------|-------:|
| 親ID | 2 |
| 祖父母ID | 4 |
| 曾祖父母以降 | 6世代ぶん summary |
| 世代数 | 1 |
| `plus_value` 履歴 | 4世代分 |
| mutation 履歴 | 4件 |
| `world_of_birth` | 1 |
| `catalyst_used` | 1 |
| `special_recipe_rule_id` | 1 |

### 10.2 書き込み規則

- 配合確定時に `genealogy_log` を1件作成
- 子がさらに親になった場合、祖先は `child_instance_id` 起点で連結
- 6世代目以降は全文系譜でなく summary 化して軽量化する

### 10.3 UI表示

- 通常画面では `親2体 + 世代数 + 直近mutation + 出生世界`
- 詳細画面で4世代ツリーを展開
- 6世代目以降は `古い血統が折り重なっている` などの summary 表現に置き換える

### 10.4 gameplay利用

- 特定の大会、門、隠し施設は `generation_depth` や `world_of_birth` を参照して条件化できる
- ただし本編必須条件に genealogy 深堀りを多用しない

---

## 11. 配合UI制約

### 11.1 画面制約

| 項目 | 制約 |
|------|------|
| 画面深度 | 最大3階層 |
| 親選択候補 | 1ページ 6体まで |
| 継承候補表示 | 1画面 8件まで |
| 未発見レシピ表示 | exact 名称非表示 |
| 危険操作 | お気に入りロック、`gate_key` は確認必須 |

### 11.2 標準フロー

```text
親A選択
  -> 親B選択
  -> 結果プレビュー
  -> 継承選択
  -> 確認
  -> 誕生
```

### 11.3 プレビュー表示ルール

| 状態 | プレビュー内容 |
|------|----------------|
| 未発見 | silhouette, family, rank帯, 危険文言 |
| 既知 | 名前, family, rank, 推定役割 |
| 特殊 | 名前の代わりに `何かが混じっている` を返してもよい |

### 11.4 実行前チェック

- 両親Lv10以上
- 親がロックされていない
- forbidden class に触れていない
- 牧場枠に空きがある
- `story gate`, `world gate`, `location gate` を満たしている

### 11.5 UX原則

- 配合は儀式感を持たせるが、周回で煩わしくならない速度にする
- 失う痛みは残すが、確認ダイアログを二重にして操作事故は防ぐ
- 答えを出しすぎず、しかし失敗理由が完全不明にはならない線で制御する

