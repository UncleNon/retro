# 07. Progress Flags And Save State Model

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/requirements/11_technical_architecture.md`
> - `docs/specs/story/01_story_bible.md`
> - `docs/specs/systems/04_economy_items_and_progression_rules.md`
> - `docs/specs/worlds/06_settlement_layout_and_route_rules.md`

---

## 1. 目的

- 20+世界、400体、複数勢力、50+伏線を扱ってもフラグ管理が崩壊しないようにする
- `世界解放`, `門状態`, `会話段階`, `ボス撃破`, `伏線回収`, `図鑑発見` を別軸で扱えるようにする
- 後から条件を追加してもセーブ互換性を保ちやすい構造にする

---

## 2. 原則

1. `ブール一発` で済むものと `段階値` が必要なものを分ける
2. ストーリー進行は `chapter` だけで持たず、世界別の局所進行も持つ
3. 会話差分は `story flag` と `npc phase` の掛け算で管理する
4. 門解放は `unlock`, `enterable`, `stable`, `cleared` を分ける
5. 伏線は `見た / 理解した / 回収した` を同じ扱いにしない

---

## 3. フラグ分類

| 種別 | キー形式 | 値型 | 用途 |
|------|----------|------|------|
| グローバル進行 | `main.*` | int / bool | 幕、章、主要分岐 |
| 世界進行 | `world.{world_id}.*` | int / bool | その世界の局所進行 |
| 門状態 | `gate.{gate_id}.*` | int / bool | 解放、安定化、崩壊 |
| NPC段階 | `npc.{npc_id}.phase` | int | 会話差分 |
| 施設状態 | `facility.{facility_id}.*` | int / bool | 開店、拡張、閉鎖 |
| 伏線 | `clue.{clue_id}.*` | int / bool | 見た、記録した、回収した |
| ボス状態 | `boss.{boss_id}.*` | bool | 遭遇、撃破、再戦 |
| 図鑑 / 記録 | `codex.*` | int / bool | 発見数、読了 |
| トーナメント | `arena.*` | int / bool | 階級、初回クリア、連勝 |
| 解放コンテンツ | `unlock.*` | bool | UI、機能、難易度、裏要素 |

---

## 4. グローバル進行モデル

### 4.1 必須フィールド

| フィールド | 型 | 説明 |
|------------|----|------|
| `main.act` | int | 1〜5 |
| `main.chapter` | int | 幕内の進行段階 |
| `main.story_complete` | bool | 本編完結 |
| `main.postgame_open` | bool | 裏導線解放 |
| `main.true_name_awareness` | int | 主人公が禁忌構造をどこまで理解したか |
| `main.silence_broken` | bool | 終盤の決定的選択を越えたか |

### 4.2 `main.true_name_awareness`

| 値 | 意味 |
|----|------|
| 0 | 塔は不吉なだけだと思っている |
| 1 | 村以外にも似た禁忌があると知る |
| 2 | 名、所属、家系の歪みが鍵だと知る |
| 3 | 制度側の責任に気づく |
| 4 | 配合と門の法則接続を理解する |
| 5 | 本編終盤の真相水準へ到達 |

---

## 5. 世界進行モデル

### 5.1 基本キー

| キー | 型 | 説明 |
|------|----|------|
| `world.{world_id}.state` | int | 未到達、到達、問題露出、解決、再訪 |
| `world.{world_id}.evidence_count` | int | 回収した証拠数 |
| `world.{world_id}.boss_cleared` | bool | 主ボス撃破 |
| `world.{world_id}.taboo_understood` | bool | その世界の禁忌を理解した扱い |
| `world.{world_id}.record_restored` | bool | 記録改竄系の回復完了 |

### 5.2 `state` 値

| 値 | 意味 |
|----|------|
| 0 | 未到達 |
| 1 | 到達直後 |
| 2 | 現地問題を認識 |
| 3 | 中核施設 or ダンジョン進行中 |
| 4 | ボス撃破 / 事件収束 |
| 5 | 再訪時差分あり |

---

## 6. 門状態モデル

### 6.1 必須キー

| キー | 型 | 説明 |
|------|----|------|
| `gate.{gate_id}.revealed` | bool | 塔内で存在が見えている |
| `gate.{gate_id}.listening` | bool | 反応し始めた |
| `gate.{gate_id}.awakened` | bool | 解放済み |
| `gate.{gate_id}.stable` | bool | 往復可能 |
| `gate.{gate_id}.ruptured` | bool | 異常化 |
| `gate.{gate_id}.first_cross_complete` | bool | 初回越境済み |

### 6.2 ゲート条件解決

`progress_gate_master` の条件は、以下の優先順で判定する。

1. `required_flag`
2. `required_item`
3. `required_rank`
4. `required_family_resonance`
5. `required_record_count`

ゲート開放演出は `listening -> awakened -> stable` の順で進める。

---

## 7. NPC 段階管理

### 7.1 基本方針

- NPC の会話は `story phase` と `local phase` の掛け算で管理する
- 同じイベントで 30人全員に個別フラグを持たせない
- 基本は `npc.{npc_id}.phase` と `world.{world_id}.state` で吸収する

### 7.2 標準 phase

| phase | 説明 |
|-------|------|
| 0 | 初対面前 |
| 1 | 初期日常 |
| 2 | 問題認識後 |
| 3 | 中盤協力 or 対立 |
| 4 | 解決直前 |
| 5 | 解決後 |
| 6 | postgame 差分 |

---

## 8. 伏線状態モデル

### 8.1 `clue` は三段階で持つ

| キー | 型 | 説明 |
|------|----|------|
| `clue.{clue_id}.seen` | bool | 演出、会話、物を見た |
| `clue.{clue_id}.logged` | bool | 記録帳や図鑑に残った |
| `clue.{clue_id}.resolved` | bool | 回収先イベントまで到達 |

### 8.2 ルール

- missable に見せても `resolved` を詰ませない
- `seen` が false でも本編完結は可能にする
- `logged` はコレクション欲と再読導線に使う

---

## 9. セーブデータ最小モデル

### 9.1 セクション

| セクション | 内容 |
|------------|------|
| `player` | 主人公名、見た目、所持金、プレイ時間 |
| `party` | パーティ3体 |
| `ranch` | 牧場 / 預かり |
| `inventory` | 携行品 |
| `vault` | 倉庫 |
| `progress` | グローバル進行 |
| `worlds` | 世界別進行 |
| `gates` | 門状態 |
| `npcs` | 主要NPC phase |
| `clues` | 伏線状態 |
| `codex` | 図鑑、レシピ、変異録 |
| `stats` | 総戦闘数、配合数、勧誘数など |

### 9.2 互換性

- セーブには `schema_version` を持たせる
- 新規追加フラグは既定値で補完できる構造にする
- 削除せず非推奨化で吸収する

---

## 10. 実績 / 統計

### 10.1 プレイヤー統計

| キー | 型 |
|------|----|
| `stats.total_battles` | int |
| `stats.total_wins` | int |
| `stats.total_recruits` | int |
| `stats.total_breeds` | int |
| `stats.total_mutations` | int |
| `stats.tower_entries` | int |
| `stats.worlds_cleared` | int |
| `stats.clues_logged` | int |

### 10.2 解放UIに使う値

- `codex.monster_count_seen`
- `codex.monster_count_recruited`
- `codex.recipe_count_known`
- `codex.recipe_count_resolved`
- `codex.mutation_count_seen`

---

## 11. 命名ルール

| 種別 | 例 |
|------|----|
| main flag | `main.story_complete` |
| world flag | `world.W-001.boss_cleared` |
| gate flag | `gate.G-004.awakened` |
| npc phase | `npc.NPC-W01-004.phase` |
| clue flag | `clue.CL-018.logged` |

禁止:

- `flag_001` のような意味のない名前
- UI文言と1対1でしか読めない曖昧名称
- ストーリー / 世界 / NPC を一つの配列番号だけで持つ運用

---

## 12. QA Checklist

- そのフラグは bool で足りるか
- phase にするなら 3段階以上の意味があるか
- 世界進行と NPC進行が二重定義になっていないか
- 本編完結に不要な `seen` 依存を置いていないか
- postgame 用フラグが本編導線へ混入していないか
