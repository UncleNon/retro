# 08. Enemy AI And Encounter Design

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/specs/systems/01_numeric_rules_and_master_schema.md`
> - `docs/specs/systems/02_battle_and_ai_rules.md`
> - `docs/requirements/02_game_design_core.md`
> - `docs/specs/00_master_design_matrix.md`

---

## 1. 目的

- 敵AIを類型化し、戦闘ごとの体験差を設計可能にする
- 「同じ敵でもグループ構成で戦い方が変わる」をシステムとして保証する
- ボス戦のフェーズ設計を一貫したテンプレートで管理する
- エンカウント周辺のルール（先制、逃走、スケーリング、レア敵）を一箇所に集約する

---

## 2. 敵AIタイプ分類

### 2.1 タイプ一覧

| AI Type ID | 名称 | 概要 |
|------------|------|------|
| `FERAL` | 野獣型 | 本能的な攻撃優先、HP低下で暴走 |
| `PACK` | 群れ型 | グループ内で役割分担、連携行動 |
| `TERRITORIAL` | 縄張り型 | 位置・防御優先、守備的に戦う |
| `INTELLIGENT` | 知性型 | MP管理、弱点狙い、回復判断 |
| `RITUAL` | 祭司型 | バフ/デバフのサイクル、パターン行動 |
| `AMBUSH` | 奇襲型 | 初手バースト、不意打ち特化 |
| `GATE_GUARDIAN` | 門守型 | フェーズ遷移、ギミックチェック |
| `ELDER_BOSS` | 長老/ボス型 | 多段フェーズ、激昂、絶望行動 |

### 2.2 タイプとモチーフの対応指針

| AI Type | 主に使われる系統 | 世界観上の理由 |
|---------|------------------|----------------|
| `FERAL` | ビースト、プラント | 本能で動く野生体 |
| `PACK` | ビースト、スライム | 群棲する種 |
| `TERRITORIAL` | マテリアル、ドラゴン | 領域を守る存在 |
| `INTELLIGENT` | マジック、ディバイン | 高い知性を持つ |
| `RITUAL` | アンデッド、ディバイン | 儀式的な存在 |
| `AMBUSH` | バード、ビースト | 狩猟本能を持つ種 |
| `GATE_GUARDIAN` | マテリアル、ディバイン | 門に紐づく守護者 |
| `ELDER_BOSS` | 全系統 | ストーリーボス全般 |

---

## 3. AI決定ツリー詳細

### 3.1 共通構造

すべての敵AIは以下の共通フレームで行動を決定する。

```text
1. 状態チェック（自身の状態異常、HP残量、MP残量）
2. グループ状況チェック（味方生存数、HP割合、バフ/デバフ状態）
3. 脅威評価（プレイヤー側の誰が危険か）
4. タイプ固有の優先度テーブルを参照
5. 行動候補にスコアを付与
6. 最高スコアの行動を採用（同点はランダム）
```

### 3.2 FERAL（野獣型）

**設計意図**: 単純だが攻撃的。序盤の基本敵。HP低下で暴走し、予測しやすいが油断すると痛い。

#### 優先度テーブル

| 優先順 | 条件 | 行動 | スコア補正 |
|--------|------|------|-----------|
| 1 | `self.hp_ratio <= 0.20` | 最大火力技（暴走） | +30 |
| 2 | `self.hp_ratio <= 0.40` | 攻撃技（火力優先） | +20 |
| 3 | `target.hp_ratio <= 0.25` | 撃破狙い通常攻撃 | +18 |
| 4 | 常時 | 通常攻撃 | +10 |
| 5 | `self.hp_ratio <= 0.50` | 全体攻撃（持っていれば） | +8 |
| 6 | 常時 | ランダム攻撃技 | +6 |

#### 暴走ルール

```text
berserk_trigger = self.hp_ratio <= 0.20
berserk_atk_bonus = floor(self.atk * 0.25)
berserk_def_penalty = floor(self.def * 0.15)
berserk_accuracy_penalty = -8
```

- 暴走中は回復・補助行動を一切選択しない
- 暴走中の対象選択はランダム（最も弱い対象を狙わない）

### 3.3 PACK（群れ型）

**設計意図**: 2〜3体で連携する。1体だけ倒しても残りが補い合う。

#### 役割割り当て

グループ生成時に各個体へ `pack_role` を割り当てる。

| pack_role | 行動傾向 | 割り当て条件 |
|-----------|----------|-------------|
| `alpha` | 攻撃主力、号令 | ATK最大の個体 |
| `flanker` | 弱点突き、妨害 | SPD最大の個体 |
| `guard` | 防御、かばう | DEF最大の個体 |

#### 優先度テーブル

| 優先順 | 条件 | 行動 | スコア補正 |
|--------|------|------|-----------|
| 1 | `alpha` 生存 & `alpha.hp_ratio <= 0.30` & self is `guard` | かばう（alpha） | +28 |
| 2 | `group_alive_count == 1` | 暴走モード（FERAL切替） | +25 |
| 3 | self is `alpha` & `target` に弱点あり | 弱点属性攻撃 | +22 |
| 4 | self is `flanker` & `target` に状態異常なし | 妨害技（麻痺、暗闇等） | +20 |
| 5 | self is `guard` & `ally.hp_ratio <= 0.50` | 防御 or かばう | +18 |
| 6 | self is `alpha` | 最大火力技 | +16 |
| 7 | self is `flanker` | 速攻技（priority_offset高） | +14 |
| 8 | 常時 | 通常攻撃 | +8 |

#### 連携行動ルール

```text
pack_synergy_check:
  if alpha uses 全体攻撃 this round:
    flanker gains synergy_bonus = +6 to 追撃技
  if guard uses かばう this round:
    alpha gains synergy_bonus = +4 to 大技
  if group_alive_count <= floor(group_start_count / 2):
    all survivors gain rage_bonus_atk = floor(base_atk * 0.15)
```

### 3.4 TERRITORIAL（縄張り型）

**設計意図**: 守備的に構え、侵入者を追い出そうとする。正面からの殴り合いに強いが、搦め手に弱い。

#### 優先度テーブル

| 優先順 | 条件 | 行動 | スコア補正 |
|--------|------|------|-----------|
| 1 | `round_count == 1` | 防御 or バフ（自己強化） | +26 |
| 2 | `self.has_buff == false` | 自己バフ（DEF上昇、反射） | +22 |
| 3 | `target` が最もダメージを与えた相手 | 報復攻撃 | +20 |
| 4 | `self.hp_ratio <= 0.50` | 防御 | +18 |
| 5 | `self.hp_ratio <= 0.30` | 全体威嚇（恐怖付与） | +16 |
| 6 | `target` が最もHPの高い相手 | 重撃 | +14 |
| 7 | 常時 | 通常攻撃 | +10 |

#### 報復メモリ

```text
retaliation_target = actor_who_dealt_most_damage_last_round
retaliation_bonus = +8 to attacks targeting retaliation_target
retaliation_memory_duration = 2 rounds
```

### 3.5 INTELLIGENT（知性型）

**設計意図**: 弱点を突き、MP管理し、回復を使う。中盤以降の主要な脅威。

#### 優先度テーブル

| 優先順 | 条件 | 行動 | スコア補正 |
|--------|------|------|-----------|
| 1 | `ally.hp_ratio <= 0.25` & 回復技所持 | 回復技 | +28 |
| 2 | `target` に弱点属性あり | 弱点属性呪文 | +24 |
| 3 | `self.mp_ratio <= 0.15` | 通常攻撃（MP温存） | +22 |
| 4 | `target` に状態異常なし & 異常技所持 | 状態異常技（封印 > 眠り > 麻痺） | +20 |
| 5 | `ally` にバフなし & バフ技所持 | 味方バフ | +18 |
| 6 | `target.healer_flag == true` | ヒーラー優先攻撃 | +16 |
| 7 | `self.mp >= high_cost_threshold` | 高火力呪文 | +14 |
| 8 | 常時 | 中火力呪文 or 通常攻撃 | +10 |

#### MP管理ルール

```text
mp_conservation_mode:
  if self.mp_ratio <= 0.30:
    spell_cost_penalty = -12 (高コスト技のスコアを大幅減)
  if self.mp_ratio <= 0.15:
    force_physical_attack = true (呪文を選択しない)

high_cost_threshold = floor(self.max_mp * 0.25)
```

#### 弱点学習

```text
weakness_memory:
  if attack with element X dealt >= 1.25x expected damage:
    mark target as weak_to_X
    future attacks with element X gain +10 score
  if attack with element X dealt <= 0.75x expected damage:
    mark target as resist_X
    future attacks with element X gain -15 score
  memory persists for entire battle
```

### 3.6 RITUAL（祭司型）

**設計意図**: 決まったサイクルでバフ/デバフを回す。パターンを読めば対処できるが、放置すると場が崩壊する。

#### 行動サイクル

```text
ritual_cycle (repeats every 4 rounds):
  round 1: 自己バフ or 味方バフ (DEF+20%, RES+20%)
  round 2: 敵デバフ (ATK-15%, SPD-15%)
  round 3: 属性攻撃 (field_element に合致するもの)
  round 4: 状態異常技 (呪い > 封印 > 恐怖)
```

#### 優先度テーブル

| 優先順 | 条件 | 行動 | スコア補正 |
|--------|------|------|-----------|
| 1 | サイクル行動（上記） | サイクルに従う | +30 |
| 2 | `self.hp_ratio <= 0.20` | 自爆技 or 全体呪い | +28 |
| 3 | `ally.hp_ratio <= 0.30` & 回復技あり | 回復 | +22 |
| 4 | サイクル行動が不可能（MP不足、封印中） | 通常攻撃 | +10 |

#### サイクル破壊条件

```text
cycle_break:
  if self receives 封印 ailment:
    cycle resets to round 1 on recovery
  if self.hp_ratio <= 0.35:
    cycle accelerates (skip buff rounds, attack-only)
  if all allies dead:
    switch to FERAL behavior
```

### 3.7 AMBUSH（奇襲型）

**設計意図**: 初手で大ダメージを与え、その後は弱体化する。不意打ちと組み合わせて脅威度が高い。

#### 優先度テーブル

| 優先順 | 条件 | 行動 | スコア補正 |
|--------|------|------|-----------|
| 1 | `round_count == 1` | 最大火力技（バースト） | +35 |
| 2 | `round_count == 2` & バースト技2あり | 第二撃 | +28 |
| 3 | `round_count >= 3` & `self.hp_ratio >= 0.60` | 逃走試行 | +22 |
| 4 | `target.hp_ratio <= 0.20` | 追撃（撃破狙い） | +20 |
| 5 | `round_count >= 3` | 通常攻撃（弱体化） | +8 |

#### バースト補正

```text
ambush_burst:
  round 1 damage_modifier = 1.40
  round 2 damage_modifier = 1.15
  round 3+ damage_modifier = 0.85

  if battle started with 不意打ち (ambushed state):
    round 1 damage_modifier = 1.60
    guaranteed_crit_round_1 = true
```

#### 逃走AI

```text
ambush_flee:
  if round_count >= 3 and self.hp_ratio >= 0.60:
    flee_score = +22
  if round_count >= 5:
    flee_score = +30
  flee blocked by: boss_flag, ritual_battle_flag, gate_trial_flag
```

### 3.8 GATE_GUARDIAN（門守型）

**設計意図**: 門に紐づく試練の番人。特定のギミックを解かないと倒せない or 著しく不利になる。

#### フェーズ構造

```text
phase 1 (HP 100% - 60%):
  通常行動。攻撃 + 軽い状態異常
  telegraph: 「門守は〇〇の力を溜めている...」

phase 2 (HP 60% - 30%):
  ギミック発動。特定条件を満たさないと被ダメ大幅軽減
  mechanic_check: 属性弱点 or 特定状態異常付与 or 特定系統モンスター所持

phase 3 (HP 30% - 0%):
  激昂モード。行動回数増加、全体技解禁
```

#### 優先度テーブル

| 優先順 | 条件 | 行動 | スコア補正 |
|--------|------|------|-----------|
| 1 | `phase == 2` & ギミック未解除 | 防御態勢（被ダメ 0.30倍） | +35 |
| 2 | `phase == 2` & ギミック解除済み | 大技（全体 or 高火力） | +28 |
| 3 | `phase == 3` | 激昂行動（2回行動、全体技） | +30 |
| 4 | `telegraph_ready == true` | 予兆行動（次ラウンド大技） | +26 |
| 5 | `target` に状態異常なし | 状態異常技 | +18 |
| 6 | 常時 | 属性攻撃 | +14 |
| 7 | 常時 | 通常攻撃 | +10 |

#### ギミック例

| ギミック種別 | 解法 | 解除効果 |
|-------------|------|----------|
| 属性シールド | 弱点属性で攻撃 | 防御態勢解除 + 1ラウンドスタン |
| 封印壁 | 封印状態異常を付与 | バフ全解除 + DEF-30% |
| 系譜認証 | 特定系統モンスターでパーティ構成 | 被ダメ通常化 + 弱点露出 |
| 反射鏡 | 物理攻撃を3回当てる | 反射解除 + SPD-20% |

### 3.9 ELDER_BOSS（長老/ボス型）

**設計意図**: ストーリーボス。多段フェーズ、激昂、絶望行動を持つ。

#### フェーズ構造テンプレート

```text
phase 1 (HP 100% - 65%):
  探り行動。プレイヤーのパーティ構成を学習
  行動回数: 1.0回/ラウンド
  AI: INTELLIGENT ベース

phase 2 (HP 65% - 35%):
  本気行動。固有技解禁、状態異常攻撃
  行動回数: 1.5回/ラウンド（2ラウンドに1回追加行動）
  AI: INTELLIGENT + 固有パターン

phase 3 (HP 35% - 0%):
  激昂行動。全体技連打、絶望技
  行動回数: 2.0回/ラウンド
  AI: 攻撃最優先 + 絶望トリガー
```

#### 優先度テーブル（Phase 1）

| 優先順 | 条件 | 行動 | スコア補正 |
|--------|------|------|-----------|
| 1 | `target` に弱点あり（学習済み） | 弱点属性攻撃 | +24 |
| 2 | `round_count <= 2` | 探り攻撃（多属性で様子見） | +22 |
| 3 | `target.healer_flag == true` | ヒーラー狙い | +20 |
| 4 | 常時 | 中火力攻撃 | +14 |

#### 優先度テーブル（Phase 2）

| 優先順 | 条件 | 行動 | スコア補正 |
|--------|------|------|-----------|
| 1 | `signature_move_cooldown == 0` | 固有大技 | +30 |
| 2 | `party_buff_count >= 3` | 全体デバフ or バフ解除 | +26 |
| 3 | `target` に状態異常なし | 状態異常攻撃 | +22 |
| 4 | `self.hp_ratio` が phase 3 境界付近 | 自己バフ（激昂準備） | +20 |
| 5 | 常時 | 高火力攻撃 | +18 |

#### 優先度テーブル（Phase 3 -- 激昂）

| 優先順 | 条件 | 行動 | スコア補正 |
|--------|------|------|-----------|
| 1 | `desperation_ready == true` | 絶望技（全体超高火力、1戦1回） | +40 |
| 2 | `self.hp_ratio <= 0.10` | 最終行動（自爆 or 全力攻撃） | +35 |
| 3 | 常時 | 全体攻撃 | +28 |
| 4 | `target.hp_ratio <= 0.30` | 撃破狙い単体攻撃 | +26 |
| 5 | 常時 | 高火力単体攻撃 | +22 |

#### 激昂（Rage）ルール

```text
rage_trigger = phase_transition to phase 3
rage_effects:
  atk_bonus = floor(base_atk * 0.30)
  spd_bonus = floor(base_spd * 0.15)
  def_penalty = floor(base_def * 0.10)
  ailment_resist_bonus = +20 (all ailments)
  action_count = 2.0 per round
```

#### 絶望技（Desperation Move）

```text
desperation_trigger:
  self.hp_ratio <= 0.15
  AND desperation_used == false

desperation_rules:
  telegraph: 前ラウンド終了時に「〇〇は禍々しい力を溜めている！」
  damage: base_spell_power * 2.5 (全体)
  accuracy: 100% (回避不可)
  guard_modifier: 0.50 適用可
  one_use_per_battle: true
```

---

## 4. グループ連携ルール

### 4.1 グループ構成パターン

| パターン | 構成 | 連携タイプ |
|----------|------|-----------|
| 単体 | 1体 | 連携なし |
| 同種ペア | 同種2体 | 同調攻撃 |
| 同種トリオ | 同種3体 | 群れ補正 |
| 混成ペア | 異種2体 | 役割補完 |
| 混成トリオ | 異種3体 | フル連携 |
| ボス+雑魚 | ボス1+雑魚1-2 | 護衛行動 |

### 4.2 同調攻撃

```text
sync_attack_trigger:
  group contains 2+ same monster_id
  AND both can act this round
  AND neither is under 状態異常 that prevents action

sync_attack_effect:
  both attack same target
  second attacker gains damage_bonus = floor(base_damage * 0.15)
  initiative of second attacker = first attacker initiative - 1
```

### 4.3 役割補完

```text
role_complement_rules:
  if group contains healer_role AND attacker_role:
    healer prioritizes healing attacker when attacker.hp_ratio <= 0.40
    attacker gains confidence_bonus = +4 to attack score

  if group contains controller_role AND attacker_role:
    controller prioritizes status on target that attacker is targeting
    attacker gains weakness_exploit_bonus = +6 if target has 状態異常

  if group contains tank_role AND any_role:
    tank prioritizes かばう for lowest HP ally
    protected ally gains action_freedom_bonus = +4 to non-defensive scores
```

### 4.4 護衛行動（ボス+雑魚）

```text
escort_rules:
  minion_ai_override:
    priority 1: かばう boss if boss.hp_ratio <= 0.50 (score +30)
    priority 2: 回復 boss if 回復技所持 and boss.hp_ratio <= 0.40 (score +28)
    priority 3: バフ boss (score +20)
    priority 4: 妨害 player party (score +16)
    priority 5: 通常攻撃 (score +8)

  boss_minion_interaction:
    if all minions dead:
      boss gains rage_bonus (see section 3.9)
    if boss uses 召喚:
      new minion spawns with escort_rules active
```

### 4.5 連携禁止条件

以下の場合、連携は発生しない。

- 連携元が状態異常（眠り、麻痺、混乱、恐怖）中
- 連携元のHP比率が `<= 0.15`（自己保存優先）
- 連携先が既に撃破されている
- 封印中で連携に必要な技が使用不可

---

## 5. ボスフェーズ設計テンプレート

### 5.1 データ構造

```text
boss_phase_master:
  boss_id: string
  phase_no: int (1-based)
  phase_trigger: string (条件式)
  ai_profile_id: string (AIタイプ参照)
  action_pool: string[] (使用可能技リスト)
  immunities: string[] (無効化する属性/状態異常)
  action_count_per_round: float (1.0 / 1.5 / 2.0)
  summon_rules: object | null
  telegraph_text_id: string
  rage_config: object | null
  desperation_config: object | null
  music_cue: string | null
  visual_cue: string | null
```

### 5.2 フェーズ遷移条件

| 条件タイプ | 式 | 使用例 |
|-----------|------|--------|
| `hp_ratio` | `self.hp_ratio <= X` | 最も基本的。X = 0.65, 0.35 等 |
| `turn_count` | `round_count >= X` | 長期戦ボス。X = 8, 12 等 |
| `minions_cleared` | `alive_minion_count == 0` | 召喚型ボス |
| `ailment_received` | `self.has_ailment(X)` | ギミック解法型。X = 封印, 暗闇等 |
| `damage_threshold` | `damage_taken_this_phase >= X` | 一定ダメージで移行 |
| `player_action` | `player_used_skill(X)` | 特定行動で移行（儀式戦闘等） |

### 5.3 フェーズ遷移演出

```text
phase_transition_sequence:
  1. 現在の行動キューをクリア
  2. 遷移テキスト表示（telegraph_text_id 参照）
  3. 遷移アニメーション再生（visual_cue）
  4. BGM変更（music_cue、設定があれば）
  5. ステータス変更適用（rage, immunities 等）
  6. 次フェーズのaction_poolに切替
  7. 遷移ターンは敵の残り行動をスキップ（遷移 = ターン消費）
```

### 5.4 召喚ルール

```text
summon_rules:
  max_summons_per_phase: int (0-2)
  summon_trigger: string (条件式)
  summon_monster_id: string
  summon_level_formula: floor(boss_level * 0.70)
  summon_ai_override: "ESCORT" (護衛行動)
  summon_count_per_trigger: int (1-2)

  constraints:
    total_enemy_count <= 3 (3体制限は常に維持)
    summon blocked if enemy_slots_full
    summoned monsters give reduced EXP (50%)
    summoned monsters are not recruitable
```

### 5.5 ボスアーキタイプ別テンプレート

#### Crusher（圧殺型）

```text
phase 1: 単体高火力。予兆付き大技。
phase 2: 全体攻撃解禁。攻撃頻度増加。
phase 3: 激昂。毎ラウンド全体技 + 単体大技。

key_stats: ATK最大、HP高め、SPD中、RES低め
weakness_design: 状態異常（特に麻痺、恐怖）で行動を止める
counter_play: 防御タイミング合わせ、かばうで味方保護
```

#### Warden（守護型）

```text
phase 1: 自己バフ + 反射。攻撃は控えめ。
phase 2: カウンター行動解禁。攻撃に反応して反撃。
phase 3: バフ解除不可 + 高火力。

key_stats: DEF最大、RES高め、ATK中、SPD低め
weakness_design: guard_break技、バフ解除、持続ダメージ
counter_play: デバフ積み、毒/呪いの継続ダメージ
```

#### Conductor（指揮型）

```text
phase 1: 雑魚召喚 + バフ配り。自身はほぼ攻撃しない。
phase 2: 雑魚を囮に使いつつ全体デバフ。
phase 3: 全雑魚撃破で激昂。単体で高火力連打。

key_stats: INT最大、SPD高め、HP中、DEF低め
weakness_design: 本体を直接狙う、召喚を無視して速攻
counter_play: 全体攻撃で雑魚処理、ボス集中攻撃
```

#### Heretic（異端型）

```text
phase 1: 状態異常ばらまき。毒 + 封印 + 暗闇。
phase 2: デバフ重ね。ATK下げ + SPD下げ + 呪い。
phase 3: 状態異常中の相手へ特効攻撃。

key_stats: INT最大、RES最大、SPD中、ATK低め
weakness_design: 高RESパーティ、状態異常回復手段の確保
counter_play: 浄化技、耐性装備、先手を取って封印
```

---

## 6. 先制 / 不意打ちルール

### 6.1 基本判定式

`02_battle_and_ai_rules.md` Section 3.3 を正とし、以下に補足する。

```text
advantage_score =
  zone_advantage_bias
  + floor((party_avg_spd - enemy_avg_spd) * 0.20)
  + scout_awareness_bonus
  + trait_advantage_bonus

preemptive_rate = clamp(10 + advantage_score, 5, 35)
ambushed_rate   = clamp(10 - advantage_score, 3, 25)
```

### 6.2 zone_advantage_bias

| ゾーン条件 | bias値 |
|-----------|--------|
| 通常フィールド | 0 |
| 深層ダンジョン | -3 |
| AMBUSH型出現ゾーン | -5 |
| 見晴らしの良いフィールド | +3 |
| 安全圏隣接 | +2 |
| 夜間 | -2 |
| 霧 | -4 |

### 6.3 scout_awareness_bonus

```text
scout_awareness_bonus:
  if party has trait "鋭い感覚": +5
  if party has trait "夜目": +3 (夜間のみ)
  if party has item "偵察の鈴" equipped: +4
  if party_avg_int >= enemy_avg_int + 20: +2
```

### 6.4 先制 / 不意打ちの効果

| 状態 | 効果 |
|------|------|
| 先制 | 味方全員 `initiative +25`、1ラウンド目の命中率 +5 |
| 不意打ち | 敵全員 `initiative +25`、味方1ラウンド目の防御 -15% |
| 通常 | 補正なし |

### 6.5 AMBUSH型敵の特殊ルール

```text
ambush_enemy_preemptive:
  if enemy_group contains AMBUSH type:
    ambushed_rate += 10
    if ambush succeeds:
      AMBUSH型の初手ダメージ補正 = 1.60 (通常は 1.40)
      guaranteed_crit_round_1 = true for AMBUSH type enemies
```

---

## 7. 逃走ルール

### 7.1 基本式

```text
flee_rate =
  floor((party_avg_spd / enemy_avg_spd) * 50)
  + flee_attempt_bonus
  + item_flee_bonus
  + trait_flee_bonus

final_flee_rate = clamp(flee_rate, 10, 95)
```

### 7.2 逃走試行ボーナス

```text
flee_attempt_bonus:
  attempt 1: +0
  attempt 2: +15
  attempt 3: +30
  attempt 4+: +50
```

### 7.3 逃走不可条件

| 条件 | フラグ | 適用場面 |
|------|--------|----------|
| ボス戦 | `boss_flag = true` | すべてのボス戦 |
| 儀式戦闘 | `ritual_battle_flag = true` | 世界固有の儀式イベント |
| 門試練 | `gate_trial_flag = true` | 門守との戦闘 |
| 包囲 | `surrounded_flag = true` | 特定ダンジョンの遭遇パターン |
| 契約戦闘 | `contract_battle_flag = true` | トーナメント、挑戦状 |

### 7.4 逃走失敗時

```text
flee_failure_penalty:
  party loses remainder of current round actions
  all party members: initiative -5 next round
  enemy AI gains target_bonus = +4 against flee_attempter (if identifiable)
```

### 7.5 逃走成功時

```text
flee_success:
  no EXP, no Gold, no drops
  no recruit chance
  encounter_meter reset
  party returns to field position before encounter
  10% chance enemy group persists in same zone tile (re-encounter possible)
```

---

## 8. 敵スケーリング

### 8.1 基本式

```text
enemy_stat(stat) =
  floor(
    base_stat_at_level(enemy_level)
    * world_multiplier
    * floor_depth_multiplier
    * time_band_modifier
    * elite_modifier
  )
```

### 8.2 world_multiplier

| 世界帯 | 推奨Lv帯 | world_multiplier |
|--------|----------|------------------|
| 序盤（世界1-5） | 1-15 | 1.00 |
| 中盤前期（世界6-9） | 14-30 | 1.08 |
| 中盤後期（世界10-12） | 28-45 | 1.15 |
| 終盤前期（世界13-16） | 42-60 | 1.22 |
| 終盤後期（世界17-20） | 55-75 | 1.30 |
| エンドゲーム（裏世界） | 70-99 | 1.40 |

### 8.3 floor_depth_multiplier

```text
floor_depth_multiplier =
  1.00 + (floor_index * depth_step)

depth_step per world_size:
  small (3-5 floors):  0.04
  medium (6-10 floors): 0.03
  large (11-15 floors): 0.02
```

| 例: medium ダンジョン | floor | multiplier |
|----------------------|-------|-----------|
| 1F | 1.00 | |
| 3F | 1.06 | |
| 5F | 1.12 | |
| 8F | 1.21 | |
| 10F | 1.27 | |

### 8.4 time_band_modifier

| 時間帯 | modifier |
|--------|---------|
| 朝 | 0.95 |
| 昼 | 1.00 |
| 夕 | 1.03 |
| 夜 | 1.08 |

### 8.5 敵レベル決定

```text
enemy_level =
  random(zone_min_lv, zone_max_lv)
  + floor_depth_lv_bonus
  + elite_lv_bonus

floor_depth_lv_bonus = floor_index (1F = +0, 2F = +1, ...)
elite_lv_bonus:
  normal: +0
  elite: +3
  rare: +5
```

---

## 9. エリート / レア敵ルール

### 9.1 出現率

```text
encounter_rarity_roll (0-999):
  0-849:   通常個体 (85.0%)
  850-949: エリート個体 (10.0%)
  950-989: レア個体 (4.0%)
  990-999: 超レア個体 (1.0%)
```

### 9.2 エリート個体

```text
elite_modifiers:
  stat_multiplier: 1.20 (全ステータス)
  hp_multiplier: 1.40
  ai_upgrade: AI type を1段階上位に変更
    FERAL -> PACK
    PACK -> INTELLIGENT
    TERRITORIAL -> GATE_GUARDIAN (lite版)
    AMBUSH -> AMBUSH (変更なし、バースト倍率 +0.10)
  drop_bonus: ドロップ率 x 1.50
  exp_bonus: 獲得EXP x 1.30
  gold_bonus: 獲得Gold x 1.25
  visual_cue: 通常スプライトに光のエフェクト追加
  name_prefix: "強〇〇" (例: 強スライム)
```

### 9.3 レア個体

```text
rare_modifiers:
  stat_multiplier: 1.35
  hp_multiplier: 1.60
  ai_upgrade: INTELLIGENT ベースに強制変更
  unique_skill: 通常は覚えない技を1つ追加所持
  drop_bonus: ドロップ率 x 2.00 + レア専用ドロップ1枠追加
  exp_bonus: 獲得EXP x 1.80
  gold_bonus: 獲得Gold x 1.60
  recruit_bonus: 勧誘基礎率 +8
  visual_cue: 色違いスプライト（パレット差し替え）
  name_prefix: "輝く〇〇"
```

### 9.4 超レア個体

```text
ultra_rare_modifiers:
  stat_multiplier: 1.50
  hp_multiplier: 2.00
  ai_type: ELDER_BOSS (lite版、phase 1-2のみ)
  unique_skill_count: 2
  drop_bonus: 確定レアドロップ + 超レア専用ドロップ1枠
  exp_bonus: 獲得EXP x 2.50
  gold_bonus: 獲得Gold x 2.00
  recruit_bonus: 勧誘基礎率 +15
  visual_cue: 色違い + オーラエフェクト
  name_prefix: "伝説の〇〇"
  encounter_music: 専用BGM
```

### 9.5 AI段階変更の詳細

| 元のAI | エリート時のAI | 変更点 |
|--------|---------------|--------|
| `FERAL` | `PACK` | 役割意識が追加、暴走閾値が0.15に低下 |
| `PACK` | `INTELLIGENT` | MP管理・弱点学習が追加 |
| `TERRITORIAL` | `GATE_GUARDIAN` lite | 軽いギミック（自己バフ時に弱点露出）追加 |
| `RITUAL` | `RITUAL` 強化版 | サイクルが3ラウンド周期に短縮 |
| `AMBUSH` | `AMBUSH` 強化版 | バースト倍率 +0.10、逃走閾値が0.70に上昇 |
| `INTELLIGENT` | `INTELLIGENT` 強化版 | 弱点学習が即時（1回の攻撃で学習完了） |

### 9.6 Pity（救済）システム

```text
pity_counter:
  エリート未遭遇が 20戦 連続: 次戦のエリート率 = 50%
  レア未遭遇が 80戦 連続: 次戦のレア率 = 25%
  超レア未遭遇が 300戦 連続: 次戦の超レア率 = 10%

  pity_counter はゾーン移動でリセットしない
  pity_counter はセーブ/ロードで保持
  pity_counter は対象レア度の敵に遭遇した時点でリセット
```

---

## 10. 戦闘バランス数値目標

### 10.1 通常戦の想定

| 指標 | 序盤 | 中盤 | 終盤 | エンドゲーム |
|------|------|------|------|-------------|
| 戦闘時間 | 20-45秒 | 30-55秒 | 35-60秒 | 40-70秒 |
| ラウンド数 | 2-3 | 2-4 | 3-4 | 3-5 |
| 味方被害HP割合 | 10-30% | 15-40% | 20-45% | 25-50% |
| 通常戦勝率 | 85-90% | 80-88% | 75-85% | 70-82% |

### 10.2 ボス戦の想定

| 指標 | 目標 |
|------|------|
| 初見勝率 | 25-45% |
| 対策後勝率 | 70-85% |
| 戦闘時間 | 2-4分（通常ボス） / 4-8分（エンドゲーム） |
| 使用アイテム数 | 2-5個 |
| フェーズ遷移回数 | 1-3回 |
| 全滅原因の理想分布 | 無対策40% / 状態異常20% / 火力不足20% / 事故20% |

### 10.3 エリート/レア戦の想定

| 指標 | エリート | レア | 超レア |
|------|---------|------|--------|
| 戦闘時間 | 通常の1.5倍 | 通常の2.0倍 | 通常の2.5-3.0倍 |
| 初見勝率 | 65-80% | 50-70% | 35-55% |
| 逃走推奨 | いいえ | 状況次第 | 弱い場合は推奨 |

---

## 11. テレメトリ連携

### 11.1 敵AI関連の追加テレメトリ

| event | フィールド |
|-------|----------|
| `enemy_ai_decision` | `enemy_id`, `ai_type`, `action_chosen`, `action_score`, `alternatives_count`, `round_no` |
| `enemy_group_composition` | `group_id`, `ai_types[]`, `pack_roles[]`, `rarity_levels[]` |
| `boss_phase_transition` | `boss_id`, `from_phase`, `to_phase`, `trigger_type`, `round_no`, `elapsed_sec` |
| `elite_encounter` | `zone_id`, `rarity_level`, `pity_counter_value`, `player_power_score` |
| `escape_attempt` | `zone_id`, `attempt_number`, `flee_rate`, `success`, `enemy_group_id` |

### 11.2 アラート条件

- エリート戦勝率が `50%` を下回る: スケーリング過剰
- ボス初見勝率が `15%` 未満: 難易度過剰
- ボス初見勝率が `60%` 超: 難易度不足
- PACK型の連携発動率が `20%` 未満: 連携条件が厳しすぎる
- AMBUSH型の初手撃破率が `30%` 超: バースト過剰
- 超レア遭遇率が設計値 `1%` から +/-0.5% 以上乖離: Pity調整必要
- 逃走成功率が `40%` 未満: 逃走式調整必要

---

## 12. 付録: AIタイプ早見表

| AI Type | 攻撃性 | 防御性 | 知性 | 連携 | 特殊 |
|---------|--------|--------|------|------|------|
| `FERAL` | 4/5 | 1/5 | 1/5 | 1/5 | 暴走 |
| `PACK` | 3/5 | 2/5 | 2/5 | 4/5 | 役割分担 |
| `TERRITORIAL` | 2/5 | 4/5 | 2/5 | 1/5 | 報復 |
| `INTELLIGENT` | 3/5 | 3/5 | 4/5 | 2/5 | 学習 |
| `RITUAL` | 2/5 | 2/5 | 3/5 | 2/5 | サイクル |
| `AMBUSH` | 5/5 | 1/5 | 2/5 | 1/5 | バースト |
| `GATE_GUARDIAN` | 3/5 | 4/5 | 3/5 | 2/5 | ギミック |
| `ELDER_BOSS` | 4/5 | 3/5 | 4/5 | 3/5 | 多段フェーズ |
