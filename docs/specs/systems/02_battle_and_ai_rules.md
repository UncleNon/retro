# 02. Battle And AI Rules

> **ステータス**: Draft v1.1
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/specs/systems/01_numeric_rules_and_master_schema.md`
> - `docs/requirements/02_game_design_core.md`
> - `docs/requirements/07_ui_ux.md`
> - `docs/adr/0008-core-experience-design-principles.md`

---

## 1. 目的

- バトルは短く、勝敗の主因は戦闘中の操作量ではなく、育成、配合、作戦設定、持ち込み準備に置く
- 通常戦は高速に回り、ボス戦では相性理解、異常管理、役割分担が効く
- 内部ルールは数式として一貫させるが、UI上は必要以上に数値を露出しない

---

## 2. 実装対象と前提

### 2.1 バトル前提

| 項目 | 仕様 |
|------|------|
| 形式 | 3v3ターン制 |
| 標準コマンド | `たたかう / さくせん / どうぐ / にげる` |
| 通常入力方針 | `たたかう` を基本とし、AI作戦で行動決定 |
| 直接指示 | `めいれいさせろ` を作戦として許可 |
| 1ラウンドの想定入力数 | 1〜4入力 |
| 通常戦目標時間 | 20〜45秒 |
| ボス戦目標時間 | 2〜4分 |

### 2.2 必須マスターデータ

| テーブル | 必須カラム |
|----------|------------|
| `battle_skill_master` | `skill_id`, `action_type`, `target_rule`, `power_band`, `accuracy`, `mp_cost`, `element`, `ailment_id`, `ailment_base_rate`, `priority_offset`, `counterable`, `reflectable`, `guard_break`, `ai_tags` |
| `battle_trait_master` | `trait_id`, `trigger`, `effect_type`, `effect_value`, `stack_rule`, `boss_allowed` |
| `enemy_group_master` | `group_id`, `members`, `advantage_bias`, `drop_table_id`, `recruitable_flags` |
| `boss_phase_master` | `boss_id`, `phase_no`, `phase_trigger`, `ai_profile_id`, `action_pool`, `immunities`, `summon_rules`, `telegraph_text_id` |

---

## 3. バトル状態遷移

### 3.1 フローチャート

```text
encounter_start
  -> advantage_check
  -> pre_battle_setup
  -> round_start
  -> command_input
  -> action_build
  -> initiative_sort
  -> action_resolve
  -> round_end
  -> next_round / victory / defeat / run
```

### 3.2 フェーズ定義

| フェーズ | 内容 |
|----------|------|
| `encounter_start` | 敵グループ生成、地形、天候、場補正の固定 |
| `advantage_check` | 先制、不意打ち、奇襲耐性を判定 |
| `pre_battle_setup` | 常時trait、装備外補正、ボスphase初期化 |
| `round_start` | 継続ダメージ、自然回復、残ターン更新 |
| `command_input` | プレイヤーが4コマンドを選択。`たたかう` で各個体AIを確定 |
| `action_build` | 行動候補の構築、対象決定、消費リソース仮押さえ |
| `initiative_sort` | 行動順を計算して降順ソート |
| `action_resolve` | 各アクションを順に解決。死亡、反撃、割込みを含む |
| `round_end` | 勝敗判定、戦闘不能整理、ログ確定 |
| `victory` | 経験値、金、ドロップ、勧誘判定 |
| `defeat` | 送還、敗北ペナルティ |

### 3.3 先制 / 不意打ち

```text
advantage_score =
  zone_advantage_bias
  + floor((party_avg_spd - enemy_avg_spd) * 0.20)
  + scout_awareness_bonus
  + trait_advantage_bonus

preemptive_rate = clamp(10 + advantage_score, 5, 35)
ambushed_rate   = clamp(10 - advantage_score, 3, 25)
```

| 状態 | 効果 |
|------|------|
| 先制 | 味方全員 `initiative +25` |
| 不意打ち | 敵全員 `initiative +25` |
| 通常 | 補正なし |

---

## 4. コマンドモデル

### 4.1 コマンド仕様

| コマンド | 内容 |
|----------|------|
| `たたかう` | その時点の作戦を参照して3体ぶんの行動をAI決定 |
| `さくせん` | 個体別作戦変更。1ターン消費なし |
| `どうぐ` | 1ターンに1アイテムのみ使用可 |
| `にげる` | パーティ全体として逃走判定 |

### 4.2 作戦一覧

| 作戦ID | 役割 |
|--------|------|
| `GO_ALL_OUT` | 最大火力優先 |
| `DO_YOUR_BEST` | バランス型 |
| `SUPPORT_ME` | 補助、デバフ、場作り |
| `STAY_SAFE` | 回復、防御、生存優先 |
| `NO_SPELLS` | MP温存、通常攻撃中心 |
| `MANUAL` | 直接入力 |

### 4.3 行動優先度

同じ `initiative` になった場合の tie-break は以下。

1. `skill.priority_offset` が高い
2. `spd` が高い
3. プレイヤー側優先
4. 左から順

---

## 5. 数式ルール

### 5.1 丸め規則

- すべての中間値は `floor` を基本とする
- 最終ダメージは `min 1` を保証する。ただし完全無効、吸収、反射は除く
- パーセント表示は内部値ではなく UI 用に丸めてよい

### 5.2 行動順

`01_numeric_rules_and_master_schema.md` を正とし、バトルでは以下を採用する。

```text
initiative =
  floor(spd * random(0.80, 1.05))
  + tactic_speed_bonus
  + skill.priority_offset
  + advantage_bonus
  + ailment_speed_modifier
```

| 補正 | 値 |
|------|----|
| `GO_ALL_OUT` | +2 |
| `DO_YOUR_BEST` | 0 |
| `SUPPORT_ME` | +1 |
| `STAY_SAFE` | -2 |
| `NO_SPELLS` | 0 |
| 麻痺 | -8 |
| 恐怖 | -5 |
| ぼうぎょ直後 | -4 |

### 5.3 物理命中率

```text
physical_hit =
  skill_base_accuracy
  + floor((attacker.spd - defender.spd) * 0.10)
  + tactic_accuracy_bonus
  + field_accuracy_bonus
  + ailment_accuracy_bonus

final_physical_hit = clamp(physical_hit, 70, 99)
```

| 要素 | 値 |
|------|----|
| 通常攻撃 `skill_base_accuracy` | 95 |
| 重い単発技 | 88〜92 |
| 多段技 | 90〜96 |
| `MANUAL` | +4 |
| `GO_ALL_OUT` | -2 |
| 暗闇状態の攻撃側 | -12 |
| 暗闇状態の防御側 | +6 |

### 5.4 呪文 / 特技命中率

攻撃呪文は高命中、補助は `int - res` 差で動かす。

```text
spell_hit =
  skill_base_rate
  + floor((caster.int - target.res) * 0.15)
  + ailment_synergy_bonus
  + target_resist_step_bonus
  + tactic_control_bonus

final_spell_hit = clamp(spell_hit, 5, 95)
```

| 耐性段階 | 命中補正 |
|----------|---------:|
| `-2` | +12 |
| `-1` | +6 |
| `0` | 0 |
| `+1` | -10 |
| `+2` | -20 |

### 5.5 物理ダメージ

```text
base_damage =
  floor(attacker.atk * 0.5)
  - floor(defender.def * 0.25)

scaled_damage =
  max(1, floor(base_damage * skill_power_modifier))

final_damage =
  max(
    1,
    floor(
      scaled_damage
      * random(0.85, 1.00)
      * element_modifier
      * guard_modifier
      * crit_modifier
      * phase_damage_modifier
    )
  )
```

| `skill_power_modifier` | 用途 |
|------------------------|------|
| `1.00` | 通常攻撃 |
| `0.65 x 2〜4hit` | 連打技 |
| `1.25` | 重撃 |
| `0.85 all` | 全体物理 |
| `1.10` | 貫通技 |

### 5.6 呪文ダメージ

呪文火力は固定威力帯ベースで、賢さは主に成功率とAI精度へ効かせる。

```text
spell_damage =
  floor(
    base_spell_power
    * random(0.90, 1.10)
    * resist_modifier
    * field_modifier
    * phase_damage_modifier
  )
```

| `base_spell_power` 帯 | 目安 |
|-----------------------|------|
| 小 | 10〜18 |
| 中 | 24〜38 |
| 大 | 46〜70 |
| 特大 | 82〜120 |

### 5.7 会心率

```text
crit_rate =
  base_crit
  + trait_crit_bonus
  + personality_crit_bonus
  + skill_crit_bonus

final_crit_rate = clamp(crit_rate, 0, 25)
```

| 要素 | 値 |
|------|----|
| `base_crit` | 4% |
| 攻撃的 / 野生的性格 | +2% |
| 会心trait | +3〜8% |
| 会心技 | +10〜20% |

### 5.8 会心処理

```text
crit_modifier = 1.50
effective_def_on_crit = floor(defender.def * 0.50)
```

- 通常会心は `def` の50%を無視する
- 多段技は原則1ヒット目のみ会心判定可。例外は `skill_flags.allow_multi_crit = true`

### 5.9 防御

```text
guard_modifier = 0.50
guard_status_resist_bonus = +10
guard_next_round_initiative_penalty = -4
```

- `ぼうぎょ` は被ダメージ半減
- 補助、状態異常にも軽く強くなる
- 常用最適化を防ぐため、次ラウンドの `initiative` へ軽いペナルティを付与

### 5.10 かばう / 反撃 / 反射

#### かばう

```text
cover_trigger =
  ally_hp_ratio <= 0.30
  and self_can_act = true
  and not self_is_silenced_for_cover
```

- `cover` は対象を味方1体に固定
- 1ラウンド1回まで
- 全体技は肩代わり不可

#### カウンター

```text
counter_rate =
  base_counter_rate
  + trait_counter_bonus
  + skill_counter_bonus

counter_damage = floor(received_physical_damage * 0.70)
```

| 要素 | 値 |
|------|----|
| `base_counter_rate` | 0 |
| カウンターtrait | 15〜30% |
| ボスギミック | 20〜40% |

#### 反射

- `reflectable = true` の呪文のみ対象
- 反射後ダメージは元威力の `0.80`
- 反射の再反射は不可

---

## 6. 属性 / 耐性 / 状態異常

### 6.1 属性一覧

| 属性 | 主用途 |
|------|--------|
| 火 | 直接火力、燃焼 |
| 水 | 安定火力、速度干渉 |
| 風 | 命中干渉、列、順序操作 |
| 地 | 重撃、防御崩し |
| 雷 | 麻痺、対機動 |
| 光 | 浄化、回復補助、対アンデッド |
| 闇 | 呪い、封印、損耗 |

### 6.2 耐性マッピング

耐性値は `-2..+2` の5段階を採用する。

| 値 | 表示 | ダメージ倍率 | 状態異常補正 |
|----|------|-------------:|-------------:|
| `-2` | 弱点 | 1.50 | +12 |
| `-1` | やや弱い | 1.25 | +6 |
| `0` | ふつう | 1.00 | 0 |
| `+1` | 耐性 | 0.75 | -10 |
| `+2` | 強耐性 | 0.50 | -20 |

### 6.3 状態異常

| 状態 | 基本持続 | 効果 |
|------|----------|------|
| 毒 | 4ターン | ターン終了時に最大HPの `1/16` |
| 麻痺 | 2〜4ターン | 行動失敗率 `25%` |
| 眠り | 1〜3ターン | 行動不能、被ダメ時 `35%` で解除 |
| 混乱 | 2〜3ターン | 自傷率 `33%` |
| 呪い | 4ターン | 行動時に最大HPの `1/20` |
| 封印 | 3ターン | 呪文または特技カテゴリ単位で封じる |
| 恐怖 | 2ターン | 行動キャンセル率 `20%`、`initiative -5` |
| 暗闇 | 3ターン | 物理命中 `-12` |

### 6.4 重複規則

- 眠りと麻痺は同時付与不可。後から入る方を優先しない
- 毒と呪いは同時付与可
- 封印と恐怖は同時付与可
- 同一状態の再付与は `残ターン延長` ではなく `高い持続で上書き`

### 6.5 状態異常成功率の最終式

```text
status_hit =
  ailment_base_rate
  + floor((caster.int - target.res) * 0.15)
  + ailment_synergy_bonus
  + target_resist_step_bonus
  + phase_ailment_bonus

final_status_hit = clamp(status_hit, 5, 95)
```

---

## 7. AI行動決定

### 7.1 行動スコア式

各モンスターは使用可能なアクションごとに `action_score` を計算し、最上位を採用する。

```text
action_score =
  tactic_weight
  + lethality_score
  + survival_score
  + efficiency_score
  + synergy_score
  + role_bias
  - risk_penalty
  + memory_bias
```

### 7.2 各スコアの意味

| 項目 | 内容 |
|------|------|
| `tactic_weight` | 作戦ごとの大枠方針 |
| `lethality_score` | 倒せる見込み、削り効率 |
| `survival_score` | 回復、防御、肩代わりの必要性 |
| `efficiency_score` | MP効率、残りラウンド効率 |
| `synergy_score` | 味方のtrait、異常、場との相性 |
| `role_bias` | ヒーラー、アタッカー等の役割補正 |
| `risk_penalty` | 無効属性、オーバーキル、空打ち |
| `memory_bias` | 前ラウンドの失敗、通りやすさの学習 |

### 7.3 作戦ごとの重み

| 作戦 | 火力 | 回復 | 補助 | MP節約 | 安全 |
|------|-----:|-----:|-----:|-------:|-----:|
| `GO_ALL_OUT` | +18 | -12 | -6 | -8 | -4 |
| `DO_YOUR_BEST` | +8 | +4 | +4 | 0 | +2 |
| `SUPPORT_ME` | -4 | +8 | +16 | -2 | +4 |
| `STAY_SAFE` | -10 | +20 | +6 | +4 | +12 |
| `NO_SPELLS` | +6 | -8 | -6 | +18 | +2 |
| `MANUAL` | プレイヤー入力 | プレイヤー入力 | プレイヤー入力 | プレイヤー入力 | プレイヤー入力 |

### 7.4 火力評価

```text
expected_damage =
  estimated_damage
  * expected_hit_rate
  * target_priority_modifier

lethality_score =
  floor(expected_damage / 4)
  + kill_bonus
  + break_bonus
```

| 条件 | 補正 |
|------|------|
| 倒し切り見込み | `+18` |
| 2体以上を同時に半壊 | `+12` |
| guard_break 成功見込み | `+8` |
| 弱点を突く | `+6` |

### 7.5 生存評価

```text
survival_score =
  low_hp_ally_score
  + cleanse_need_score
  + guard_value_score
  + cover_value_score
```

| 条件 | 補正 |
|------|------|
| 味方HP30%未満 | `+18` |
| 味方HP50%未満 | `+10` |
| ボスの大技予兆中に防御 | `+14` |
| 味方2体が異常中 | `+8` |

### 7.6 効率評価

```text
efficiency_score =
  mp_sustain_score
  + low_cost_bonus
  - overkill_penalty
  - empty_support_penalty
```

| 条件 | 補正 |
|------|------|
| MP20%以下で高コスト技 | `-12` |
| 同効果の補助を上書き | `-10` |
| オーバーキル見込み過大 | `-8` |
| 低MPで通常攻撃選択 | `+8` |

### 7.7 役割バイアス

| role_tag | 優先行動 |
|----------|----------|
| `attacker` | 単体火力、弱点突き |
| `breaker` | 防御低下、封印、guard_break |
| `support` | バフ、回復、速度操作 |
| `tank` | かばう、防御、挑発 |
| `controller` | 眠り、麻痺、恐怖 |

### 7.8 ターゲット選択

```text
target_score =
  kill_probability_bonus
  + weakness_bonus
  + healer_priority_bonus
  + squishy_bonus
  - taunt_penalty
  - overfocus_penalty
```

| 条件 | 補正 |
|------|------|
| 撃破可能 | `+14` |
| 回復役 / 蘇生役 | `+10` |
| 弱点が明確 | `+8` |
| 同ターンに味方2体以上が同一対象集中済み | `-6` |

### 7.9 AI禁止事項

- 完全無効属性を連打しない
- HP95%以上の味方へ回復を優先しない
- MPを枯らす高コスト技を、撃破見込みなしで連打しない
- 同じ補助効果を意味なく上書きしない
- 逃走不能戦で `run` を選ばない

### 7.10 AIの意図的な不完全さ

- `GO_ALL_OUT` は最適解よりも派手な高火力を優先する
- `DO_YOUR_BEST` は完全最適でなく、“人間が見て納得できる選択” を優先する
- プレイヤー側AIを過剰に賢くしすぎず、上級者の `MANUAL` 介入余地を残す

---

## 8. ボス設計ルール

### 8.1 基本制約

- ボスは `数値だけ硬い敵` にしない
- `2〜4種類` の攻略ルートを許可する
- 弱点は属性だけでなく、行動順、補助、異常、育成系譜のどれかでも成立する
- 単一buildで完封させないが、対策してきたパーティが正しく楽になる構造を維持する

### 8.2 ボス構成テンプレ

| 項目 | 制約 |
|------|------|
| `phase_count` | 1〜3 |
| `signature_moves` | 2個以上 |
| `counter_gimmicks` | 0〜2個 |
| `hard_immunity` | 0〜2個まで |
| `summon_count` | 0〜1回 / phase |
| `telegraph_actions` | 1個以上 |

### 8.3 数値補正

| 補正 | 値 |
|------|----|
| HP係数 | 通常敵の `2.8〜4.5倍` |
| 状態異常補正 | 成功率に `-15〜-35` |
| 行動回数補正 | `1.0〜1.5` 回 / round 相当 |
| EXP / Gold | 通常敵の `3〜5倍` |

### 8.4 ボスアーキタイプ

| archetype | 目的 |
|-----------|------|
| `crusher` | 高火力、短期決戦圧 |
| `warden` | 防御、反射、守り崩し要求 |
| `conductor` | 召喚、場支配、速度管理 |
| `heretic` | 状態異常、封印、継続損耗 |

### 8.5 フェーズ遷移条件

| 条件 | 使い方 |
|------|--------|
| `hp_ratio <= x` | 基本 |
| `minions_cleared` | 召喚型 |
| `turn_count >= x` | 長期戦型 |
| `specific_ailment_received` | gimmick 解法型 |

### 8.6 endgame ボス追加制約

- 1戦の目標時間は `4〜8分`
- 形態変化は最大3回
- 明確な build check を1つ入れるが、詰み条件にはしない
- 変異種、系譜、trait理解が効くギミックを必ず1つ入れる

---

## 9. ログ / テレメトリ / バランスターゲット

### 9.1 バトルログ必須項目

- 行動者ID
- 使用アクションID
- 対象ID
- 命中 / ミス
- ダメージ / 回復量
- 状態異常付与 / 解除
- trait発動
- phase遷移

### 9.2 テレメトリイベント

| event | 必須フィールド |
|-------|----------------|
| `battle_start` | `zone_id`, `enemy_group_id`, `advantage_state`, `party_power_score`, `enemy_power_score` |
| `battle_round_end` | `round_no`, `party_hp_ratio`, `enemy_hp_ratio`, `alive_party_count`, `alive_enemy_count` |
| `battle_action` | `actor_id`, `action_id`, `target_id`, `tactic_id`, `hit`, `damage`, `ailment_applied`, `counter_triggered` |
| `battle_end` | `outcome`, `duration_sec`, `round_count`, `items_used`, `knockout_count`, `gold_gain`, `exp_gain` |

### 9.3 数値目標

| 指標 | 目標 |
|------|------|
| 序盤通常戦時間 | `20〜45秒` |
| 中盤通常戦時間 | `30〜55秒` |
| ボス戦時間 | `2〜4分` |
| endgameボス戦時間 | `4〜8分` |
| 1戦の平均入力数 | `4〜8` |
| `たたかう` 選択率 | `60%以上` |
| `さくせん` 変更率 | `10〜25%` |
| 通常戦勝率 | `75〜88%` |
| ボス戦初見勝率 | `25〜45%` |

### 9.4 アラート条件

- 通常戦平均時間が `60秒` を超える
- 通常戦平均入力数が `10` を超える
- `GO_ALL_OUT` での同一アクション連打率が `75%` を超える
- 状態異常成功率が想定より `+15pt` 以上ずれる
- ボス戦初見勝率が `15%未満` または `60%超`

