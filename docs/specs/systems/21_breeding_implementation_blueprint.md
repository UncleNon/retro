# 21. Breeding Implementation Blueprint

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16
> **参照元**:
> - `docs/specs/systems/03_breeding_mutation_and_lineage_rules.md`
> - `docs/specs/systems/11_protagonist_party_and_ranch_rules.md`
> - `docs/specs/systems/12_ui_screen_catalog_and_input_rules.md`

---

## 1. 目的

- Session 08 (Breeding And Vertical Slice Assembly) の実装向けクラス設計
- 配合判定、継承、変異、UIフロー、データ永続化を Godot 4.4 で定義

---

## 2. 配合フロー全体

```
1. 配合施設に入る（村の畜舎 or 世界の配合場）
2. 親A を選ぶ（パーティ + 牧場から）
3. 親B を選ぶ（異性、Lv10以上、お気に入りロック外）
4. レシピ判定（special → family → fallback）
5. 子の種族決定
6. 継承スキル選択（2〜3枠）
7. 確認ダイアログ（2回確認）
8. 演出（親が消える → 卵 → 子誕生）
9. 名前入力
10. 子がパーティ or 牧場に加わる
11. 親のデータが永久に削除される
```

---

## 3. レシピ判定

### 3.1 優先順位

```gdscript
func resolve_breed(parent_a: MonsterData, parent_b: MonsterData) -> MonsterData:
    # 1. special recipe (monster_id × monster_id)
    var special := _find_special_recipe(parent_a.monster_id, parent_b.monster_id)
    if special:
        return special

    # 2. family × family
    var family_result := _find_family_recipe(parent_a.family, parent_b.family)
    if family_result:
        return family_result

    # 3. same family → lineage keep (同系統強化)
    if parent_a.family == parent_b.family:
        return _lineage_keep(parent_a, parent_b)

    # 4. fallback → higher rank parent の種族を維持
    return _fallback(parent_a, parent_b)
```

### 3.2 同系統強化

```gdscript
func _lineage_keep(a: MonsterData, b: MonsterData) -> MonsterData:
    # 同じ family で、位階（rank の数値化）が高い方を子の種族にする
    var higher := a if _rank_to_int(a.rank) >= _rank_to_int(b.rank) else b
    return higher  # 種は変えず、plus_value で強化
```

---

## 4. plus_value 計算

```gdscript
func calc_child_plus(parent_a: BattleFighter, parent_b: BattleFighter,
                      is_special: bool, is_mutation: bool) -> int:
    var level_sum := parent_a.level + parent_b.level
    var level_bonus: int
    if level_sum < 20:
        level_bonus = 0
    elif level_sum < 40:
        level_bonus = 1
    elif level_sum < 60:
        level_bonus = 2
    elif level_sum < 90:
        level_bonus = 3
    elif level_sum < 120:
        level_bonus = 4
    elif level_sum < 160:
        level_bonus = 5
    else:
        level_bonus = 6

    var special_bonus := 1 if is_special else 0
    var mutation_bonus := 1 if is_mutation else 0
    var base_plus := maxi(parent_a.plus_value, parent_b.plus_value)

    return mini(24, base_plus + level_bonus + special_bonus + mutation_bonus)
```

---

## 5. 継承スキル

### 5.1 継承枠数

```gdscript
func get_inherit_slots(parent_a: BattleFighter, parent_b: BattleFighter) -> int:
    var level_sum := parent_a.level + parent_b.level
    if level_sum >= 80:
        return 3
    return 2
```

### 5.2 継承候補の生成

```gdscript
func get_inherit_candidates(parent_a: BattleFighter, parent_b: BattleFighter,
                             child_data: MonsterData) -> Array[SkillData]:
    var pool: Array[SkillData] = []

    # 親Aの現在の習得スキル
    pool.append_array(parent_a.learned_skills)
    # 親Bの現在の習得スキル
    pool.append_array(parent_b.learned_skills)

    # 子の種族固有スキル（innate）は自動で入るため候補から除外
    var innate_ids := child_data.innate_skill_ids
    pool = pool.filter(func(s): return s.skill_id not in innate_ids)

    # 重複除去
    var seen := {}
    var unique: Array[SkillData] = []
    for skill in pool:
        if skill.skill_id not in seen:
            seen[skill.skill_id] = true
            unique.append(skill)

    return unique
```

---

## 6. 変異判定

```gdscript
func check_mutation(parent_a: BattleFighter, parent_b: BattleFighter,
                     catalyst_bonus: float, world_bonus: float) -> Dictionary:
    var base_rate := 0.015  # 1.5%
    var generation_bonus := mini(parent_a.plus_value + parent_b.plus_value, 10) * 0.005
    var level_bonus := 0.005 if (parent_a.level + parent_b.level) >= 40 else 0.0

    var total := base_rate + generation_bonus + level_bonus + catalyst_bonus + world_bonus
    total = minf(total, 0.12)  # hard cap 12%

    var is_mutation := randf() < total

    return {
        "is_mutation": is_mutation,
        "rate": total,
        "mutation_type": _select_mutation_type() if is_mutation else "",
    }
```

---

## 7. 子のステータス初期値

```gdscript
func calc_child_base_stats(parent_a: BattleFighter, parent_b: BattleFighter,
                            child_data: MonsterData) -> Dictionary:
    var stats := {}
    for stat_key in ["hp", "mp", "atk", "def", "spd", "int", "res"]:
        var parent_sum: int = parent_a.stats[stat_key] + parent_b.stats[stat_key]
        var inherited: int = floori(parent_sum / 4.0)
        stats[stat_key] = maxi(child_data.get("base_" + stat_key), inherited)
    return stats
```

---

## 8. UI フロー (Godot シーン)

```
BreedingRoot (Control)
├── BreedingStateMachine (Node)
├── ParentSelectScreen (Control)
│   ├── MonsterList (VBoxContainer)
│   └── DescriptionStrip (Control)
├── PreviewScreen (Control)
│   ├── ChildInfo (Control)
│   ├── InheritSkillSelector (Control)
│   └── ConfirmDialog (Control)
├── CeremonyScreen (Control)  # 演出
│   ├── ParentSprites (Node2D)
│   ├── EggSprite (Node2D)
│   └── ChildReveal (Node2D)
└── NameInputScreen (Control)
    └── NameInput (LineEdit)  # 最大6文字
```

### 8.1 ステートマシン

| 状態 | 次状態 |
|------|--------|
| `SELECT_PARENT_A` | `SELECT_PARENT_B` |
| `SELECT_PARENT_B` | `PREVIEW` |
| `PREVIEW` | `INHERIT_SELECT` |
| `INHERIT_SELECT` | `CONFIRM` |
| `CONFIRM` | `CEREMONY` or `SELECT_PARENT_A` (キャンセル) |
| `CEREMONY` | `NAME_INPUT` |
| `NAME_INPUT` | `RESULT` |
| `RESULT` | `EXIT` |

---

## 9. データ永続化

### 9.1 親の削除

```gdscript
func execute_breeding(parent_a_id: int, parent_b_id: int, child: BattleFighter) -> void:
    # 牧場/パーティから親を削除
    ranch.remove_monster(parent_a_id)
    ranch.remove_monster(parent_b_id)

    # 子を追加
    if party.has_space():
        party.add_monster(child)
    elif ranch.has_space():
        ranch.add_monster(child)
    else:
        # 牧場満杯 → リリース or 入替を要求
        _show_full_ranch_dialog(child)

    # 配合履歴に記録
    breed_log.add_entry({
        "parent_a": parent_a_id,
        "parent_b": parent_b_id,
        "child_monster_id": child.source_data.monster_id,
        "child_name": child.display_name,
        "plus_value": child.plus_value,
        "is_mutation": child.is_mutation,
        "timestamp": Time.get_unix_time_from_system(),
    })

    # 図鑑更新
    codex.register_bred(child.source_data.monster_id)

    # オートセーブ
    SaveSystem.auto_save()
```

### 9.2 配合履歴

- 最新50件をセーブデータに保存
- 系譜ツリー表示は endgame 解放後

---

## 10. 演出タイミング

| 演出 | 長さ | SE |
|------|-----:|------|
| 親が祭壇に寄る | 1.0s | - |
| 光の収束 | 0.8s | SE-BREED-START |
| 親フェードアウト | 0.6s | - |
| 卵出現 | 0.5s | - |
| 卵が割れる | 0.8s | SE-BREED-HATCH |
| 子スプライト登場 | 0.6s | JNG-BREED-SUCCESS |
| 変異時の追加演出 | 1.0s | SE-BREED-MUTATION + JNG-MUTATION |
| 名前入力画面 | 無制限 | - |
| 結果表示 | 無制限 | - |

---

## 11. テストケース

1. 特殊レシピ配合が正しい子を生む
2. 同系統配合で種が維持される
3. 継承枠が level_sum で増える
4. plus_value が正しく計算される
5. 変異率が触媒で上がる
6. 親がパーティ/牧場から消える
7. お気に入りロック個体が親候補から除外される
8. 配合後にオートセーブが走る
9. 牧場満杯時にエラーでなくリリース選択が出る
10. 配合履歴に正しく記録される
