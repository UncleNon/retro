# 20. Battle Implementation Blueprint

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16
> **参照元**:
> - `docs/specs/systems/02_battle_and_ai_rules.md`
> - `docs/specs/systems/08_enemy_ai_and_encounter_design.md`
> - `docs/specs/systems/09_status_ailments_and_field_effects.md`
> - `docs/specs/systems/10_skill_taxonomy_and_full_initial_catalog.md`
> - `docs/specs/systems/12_ui_screen_catalog_and_input_rules.md`
> - `docs/requirements/02_game_design_core.md`

---

## 1. 目的

- Session 06 (Battle Foundation) の実装者が、spec を読まなくても着手できるクラス設計を提供する
- ステートマシン、ターン解決、AI、UI接続を Godot 4.4 の Signal / Resource / Node 体系で定義する
- 「設計書を読んだがコードに落とせない」を防ぐ

---

## 2. 前提

- Godot 4.4, GDScript
- 解像度 160×144, 整数スケール
- パーティ最大3体 vs 敵最大3体
- 4コマンド: たたかう / さくせん / どうぐ / にげる
- 作戦AI: 5種（全力で攻めろ / バランスよく / 命を守れ / とくぎつかうな / めいれいさせろ）
- 乱数はバトル内のみ許可

---

## 3. ノードツリー

```
BattleRoot (Node2D)
├── BattleStateMachine (Node)
├── BattleModel (Node)
│   ├── PartySlot[0..2] (Resource references)
│   └── EnemySlot[0..2] (Resource references)
├── BattleView (CanvasLayer)
│   ├── EnemySpriteContainer (Node2D)
│   ├── PartyHUD (Control)
│   ├── MessageWindow (Control)
│   └── CommandMenu (Control)
├── BattleAI (Node)
├── TurnResolver (Node)
└── BattleAudioBridge (Node)
```

---

## 4. ステートマシン

### 4.1 状態一覧

| 状態 | 説明 | 次状態 |
|------|------|--------|
| `ENCOUNTER_INTRO` | 遭遇演出（フラッシュ + SE + 敵表示） | `COMMAND_SELECT` or `PRE_EMPTIVE` |
| `PRE_EMPTIVE` | 先制判定成功時、味方が先に1ターン行動 | `COMMAND_SELECT` |
| `AMBUSH` | 不意打ち判定成功時、敵が先に1ターン行動 | `COMMAND_SELECT` |
| `COMMAND_SELECT` | プレイヤーがコマンドを選ぶ | `TURN_RESOLVE` or `ESCAPE_ATTEMPT` |
| `TURN_RESOLVE` | 行動順で全員の行動を解決 | `TURN_END` |
| `ESCAPE_ATTEMPT` | 逃走判定 | `TURN_END` or `ESCAPE_SUCCESS` |
| `TURN_END` | 状態異常持続、毒ダメ、KOチェック | `COMMAND_SELECT` or `VICTORY` or `DEFEAT` |
| `VICTORY` | 勝利演出 + 報酬 | `RECRUIT_CHECK` or `RESULT` |
| `RECRUIT_CHECK` | 勧誘判定（bait使用時） | `RESULT` |
| `DEFEAT` | 全滅演出 | `PENALTY` |
| `ESCAPE_SUCCESS` | 逃走成功 | `EXIT` |
| `RESULT` | 経験値、ドロップ、図鑑更新 | `EXIT` |
| `PENALTY` | 金10-15%ロスト、拠点帰還 | `EXIT` |
| `EXIT` | フィールドに戻る | - |

### 4.2 GDScript 骨格

```gdscript
class_name BattleStateMachine extends Node

enum State {
    ENCOUNTER_INTRO,
    PRE_EMPTIVE,
    AMBUSH,
    COMMAND_SELECT,
    TURN_RESOLVE,
    ESCAPE_ATTEMPT,
    TURN_END,
    VICTORY,
    RECRUIT_CHECK,
    DEFEAT,
    ESCAPE_SUCCESS,
    RESULT,
    PENALTY,
    EXIT,
}

signal state_changed(old_state: State, new_state: State)
signal battle_ended(outcome: StringName)

var current_state: State = State.ENCOUNTER_INTRO

func transition_to(new_state: State) -> void:
    var old := current_state
    current_state = new_state
    state_changed.emit(old, new_state)
```

---

## 5. BattleModel

### 5.1 責務

- パーティと敵のスロット管理
- HP/MP/状態異常の権威データ
- ターン数カウント
- 配置と行動ログ

### 5.2 BattleFighter

戦闘参加者1体分のランタイムデータ。

```gdscript
class_name BattleFighter extends RefCounted

var source_data: MonsterData  # .tres から読み込んだ静的データ
var display_name: String
var level: int
var current_hp: int
var max_hp: int
var current_mp: int
var max_mp: int
var stats: Dictionary  # {atk, def, spd, int, res}
var active_ailments: Array[ActiveAilment]
var active_buffs: Array[ActiveBuff]
var tactic: StringName  # 作戦名
var personality: StringName
var loyalty: int
var is_ally: bool
var slot_index: int

func is_alive() -> bool:
    return current_hp > 0

func apply_damage(amount: int) -> int:
    var actual := mini(current_hp, maxi(1, amount))
    current_hp -= actual
    return actual

func apply_heal(amount: int) -> int:
    var actual := mini(max_hp - current_hp, amount)
    current_hp += actual
    return actual
```

### 5.3 ActiveAilment

```gdscript
class_name ActiveAilment extends RefCounted

var ailment_id: StringName  # poison, sleep, etc.
var remaining_turns: int
var source_int: int  # 付与者のINT（持続判定に使用）
var stacks: int = 1
```

---

## 6. TurnResolver

### 6.1 ターン解決の手順

```
1. 全参加者の行動を決定
   - 味方: tactic == "めいれいさせろ" → プレイヤー選択済み
   - 味方: tactic != "めいれいさせろ" → BattleAI が自動選択
   - 敵: BattleAI が ai_type に基づいて選択

2. 行動順を算出
   initiative = floor(spd * randf_range(0.80, 1.05)) + tactic_speed_bonus

3. initiative 降順にソート

4. 順番に行動を実行
   - 対象が既にKOなら再ターゲット or スキップ
   - ダメージ計算
   - 状態異常付与判定
   - 演出シグナル発火

5. ターン末処理
   - 毒ダメージ
   - 状態異常の残りターン減少
   - 0になった状態異常の解除
   - KOチェック（全滅判定）
```

### 6.2 ダメージ計算

```gdscript
func calc_physical_damage(attacker: BattleFighter, defender: BattleFighter, skill: SkillData) -> int:
    var base := floori(attacker.stats.atk * 0.5) - floori(defender.stats.def * 0.25)
    var stability := randf_range(0.85, 1.00)
    var element_mod := get_element_modifier(skill.element, defender)
    var crit_mod := 1.0
    if _roll_critical(attacker):
        crit_mod = 1.5
    var raw := floori(base * stability * element_mod * crit_mod * skill.power_multiplier)
    return maxi(1, raw)

func calc_magic_damage(skill: SkillData, defender: BattleFighter) -> int:
    var base := skill.base_power
    var stability := randf_range(0.90, 1.10)
    var resist_mod := get_element_modifier(skill.element, defender)
    return maxi(1, floori(base * stability * resist_mod))
```

### 6.3 属性相性

```gdscript
const RESIST_TABLE := {
    -2: 1.50,  # 大弱点
    -1: 1.25,  # 弱点
     0: 1.00,  # 等倍
     1: 0.75,  # 耐性
     2: 0.50,  # 大耐性
}

func get_element_modifier(element: StringName, defender: BattleFighter) -> float:
    if element == &"none":
        return 1.0
    var resist_value: int = defender.source_data.get_resistance(element)
    return RESIST_TABLE.get(resist_value, 1.0)
```

---

## 7. BattleAI

### 7.1 作戦別の行動選択

```gdscript
func choose_action(fighter: BattleFighter, model: BattleModel) -> BattleAction:
    match fighter.tactic:
        &"全力で攻めろ":
            return _aggressive_ai(fighter, model)
        &"バランスよく":
            return _balanced_ai(fighter, model)
        &"命を守れ":
            return _defensive_ai(fighter, model)
        &"とくぎつかうな":
            return _basic_attack_only(fighter, model)
        &"めいれいさせろ":
            return _player_selected_action(fighter)
    return _balanced_ai(fighter, model)
```

### 7.2 忠誠度による作戦無視

```gdscript
func _should_disobey(fighter: BattleFighter) -> bool:
    if fighter.loyalty >= 60:
        return false
    var disobey_rate: float
    if fighter.loyalty >= 40:
        disobey_rate = 0.10
    elif fighter.loyalty >= 20:
        disobey_rate = 0.20
    else:
        disobey_rate = 0.35
    return randf() < disobey_rate
```

### 7.3 敵AI

```gdscript
func choose_enemy_action(fighter: BattleFighter, model: BattleModel) -> BattleAction:
    var ai_type: StringName = fighter.source_data.ai_type
    match ai_type:
        &"FERAL":
            return _feral_ai(fighter, model)
        &"PACK":
            return _pack_ai(fighter, model)
        &"INTELLIGENT":
            return _intelligent_ai(fighter, model)
        &"RITUAL":
            return _ritual_ai(fighter, model)
        &"GATE_GUARDIAN":
            return _gate_guardian_ai(fighter, model)
        &"ELDER_BOSS":
            return _elder_boss_ai(fighter, model)
        _:
            return _feral_ai(fighter, model)
```

---

## 8. BattleView のシグナル接続

```gdscript
# BattleRoot での接続
func _ready() -> void:
    state_machine.state_changed.connect(_on_state_changed)
    turn_resolver.action_executed.connect(view.play_action_animation)
    turn_resolver.damage_dealt.connect(view.show_damage_number)
    turn_resolver.ailment_applied.connect(view.show_ailment_icon)
    turn_resolver.fighter_ko.connect(view.play_ko_animation)
    command_menu.command_selected.connect(_on_command_selected)
```

---

## 9. 勧誘判定

```gdscript
func calc_recruit_score(target: BattleFighter, bait_bonus: int, party_avg_lv: int) -> int:
    var base: int = target.source_data.base_recruit
    var hp_bonus: int = floori((1.0 - float(target.current_hp) / float(target.max_hp)) * 25)
    var status_bonus: int = _get_status_recruit_bonus(target)
    var level_gap: int = clampi(party_avg_lv - target.level, -8, 12)
    var duplicate_penalty: int = -12 if _party_has_same_species(target) else 0
    var rank_penalty: int = _get_rank_recruit_penalty(target.source_data.rank)
    var score: int = base + hp_bonus + status_bonus + bait_bonus + level_gap + duplicate_penalty - rank_penalty
    return clampi(score, 1, 90)
```

---

## 10. 演出タイミング

| 演出 | 長さ | SE |
|------|-----:|------|
| 遭遇フラッシュ | 0.3s | SE-BTL-ENCOUNTER |
| 敵登場 | 0.5s | - |
| コマンド選択待ち | 無制限 | - |
| 物理攻撃モーション | 0.3s | SE-BTL-PHYS-* |
| 呪文エフェクト | 0.4s | SE-BTL-{element} |
| ダメージ表示 | 0.5s | SE-BTL-DAMAGE-* |
| KO演出 | 0.6s | SE-BTL-KO |
| ターン間の間 | 0.2s | - |
| 勝利ジングル | 3-5s | JNG-VICTORY |
| 経験値加算 | 0.8s | SE-SYS-LEVELUP (Lv上昇時) |
| 勧誘判定表示 | 1.0s | SE-BREED-HATCH (成功時) |

---

## 11. テストケース

### 11.1 最低限のスモークテスト

1. 3v1 の戦闘が開始～勝利まで通る
2. 全4コマンドが選択可能
3. 「めいれいさせろ」でスキル選択ができる
4. 逃走が成功/失敗する
5. 全滅でペナルティ処理が走る
6. 勧誘判定が成功/失敗する

### 11.2 テンポ計測

- 1戦 20〜45秒を目標
- コマンド入力なし（全員「全力で攻めろ」）で 15〜25秒
- 「めいれいさせろ」3体フル操作で 30〜45秒

### 11.3 AI挙動確認

- 「命を守れ」で回復が優先される
- 「とくぎつかうな」で通常攻撃のみ
- 忠誠度20以下で作戦無視が発生する
- ボス戦で逃走不可
