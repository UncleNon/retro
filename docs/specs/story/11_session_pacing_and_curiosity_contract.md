# 11. Session Pacing And Curiosity Contract

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16
> **役割**: `5分 / 15分 / 60分` の遊び単位、報酬の拍動、ノートを取りたくなる情報密度を、全編で再利用できる契約として固定する
> **参照元**:
> - `docs/requirements/02_game_design_core.md`
> - `docs/specs/story/03_foreshadow_allocation_map.md`
> - `docs/specs/story/04_main_story_beats_and_world_sequence.md`
> - `docs/specs/story/10_starting_arc_engagement_playbook.md`
> - `docs/specs/systems/17_encounter_authoring_and_balance_sandbox.md`

---

## 1. 目的

- 本作の `短い戦闘 + 深い世界 + 長い血統計画` を、実際のプレイ時間単位へ落とす
- `何が起きるか分からない` ではなく、`次に何が分かりそうか分かる` 推進力を作る
- lore の深さと session の切れ目が喧嘩しないよう、報酬と問いの更新頻度を先に固定する

---

## 2. authority

この文書は、以下を authoritative に扱う。

- 5分 / 15分 / 60分 単位の進行期待値
- 報酬の `micro / mid / macro` の拍動
- curiosity を支える情報密度と未解決数の上限
- `ノートを取りたくなる` 情報の最低条件

以下は既存文書へ残す。

| 主題 | authority |
|------|-----------|
| 序盤 `W-005` までの引っ張り方 | `story/10_starting_arc_engagement_playbook.md` |
| 伏線の個票配置 | `story/03_foreshadow_allocation_map.md` |
| 世界順と本編 reveal ladder | `story/04_main_story_beats_and_world_sequence.md` |
| 遭遇 / route / scout / sandbox | `systems/17_encounter_authoring_and_balance_sandbox.md` |

---

## 3. Session Anchors

### 3.1 3つの時間単位

| anchor | 目安時間 | プレイヤー感覚 | 必ず起こすこと |
|--------|---------:|----------------|----------------|
| `micro` | 4〜8分 | 「少し進んだ」 | 小判断1回、戦闘1〜3回、情報更新1回 |
| `short` | 12〜18分 | 「一区切りついた」 | zone / floor / local task を1つ閉じる |
| `medium` | 45〜70分 | 「今夜の成果が出た」 | local answer 1つ、bigger question 1つ、進行変化1つ |

### 3.2 `micro` の契約

`micro` は、細かい作業の連打で終わらせない。最低でも次のどれか 2 つを含む。

- 新しい pack / world object / NPC との接触
- 回復、bait、route のどれかに関する小判断
- clue の `seen` か `logged`
- 図鑑更新、素材入手、gate 反応のいずれか

### 3.3 `short` の契約

`short` は、プレイヤーが「今日はここまででも前進した」と言える単位とする。

| 必須 | 内容 |
|------|------|
| `closed unit` | zone, floor, local side task, boss approach のいずれか 1 つを閉じる |
| `reward beat` | item, recruit chance, codex, NPC phase, gate progress のいずれかを得る |
| `question update` | 既存の謎が 1 段深くなるか、別の世界へ繋がる |

### 3.4 `medium` の契約

`medium` は世界観の手応えが要る。最低ノルマ:

1. `local answer` を 1 つ閉じる
2. `bigger question` を 1 つ開く
3. 拠点 / gate / party / codex のいずれかに `持ち帰れる変化` を残す
4. 次回起動時の明確な行き先を 1 つ残す

---

## 4. Reward Heartbeat

### 4.1 reward の層

| 層 | 更新頻度 | 例 |
|----|---------|----|
| `micro reward` | 2〜6分ごと | 戦闘勝利、素材、図鑑1件、短文 clue、経路短縮 |
| `mid reward` | 10〜18分ごと | recruit 成功、shop band 更新、zone clear、gate progress、NPC crack |
| `macro reward` | 45〜70分ごと | 世界クリア、血統の前進、main reveal、帰村ショック、世界間の意味更新 |

### 4.2 starvation rule

以下を超えて `何も起きていない感` を作ってはならない。

| 要素 | 最大無更新時間 |
|------|---------------:|
| 視覚的新情報 | 5分 |
| 判断材料の増加 | 8分 |
| 明示的報酬 | 12分 |
| 謎の意味更新 | 18分 |

### 4.3 報酬点の種類

| reward point | プレイヤー感情 | 目安頻度 | 代表媒体 |
|--------------|----------------|---------|----------|
| `combat mastery` | 準備が噛んだ | 高 | 戦闘、作戦切替、field modifier |
| `recruit desire` | 仲間にしたい | 中 | encounter, bait, rarity |
| `breed foresight` | 後で効く種を拾えた | 中 | recruit, codex, recipe hint |
| `world proof` | 世界の論理が読めた | 中 | object, NPC, dungeon, monster lore |
| `record crack` | 記録の嘘が見えた | 中 | 台帳、碑文、札、宿帳 |
| `gate progress` | 境界を一歩押した | 低〜中 | gate reaction, item, phase |
| `return shock` | 故郷が変わった | 低 | 帰村差分、会話温度差 |
| `codex satisfaction` | ノートが埋まる | 高 | 図鑑、clue log, recipe log |

### 4.4 報酬の組み合わせ原則

- `micro reward` を 3 回以上続けたら、次は `mid reward` を入れる
- `mid reward` だけで 40 分以上引っ張らない。必ず `macro reward` の予告を出す
- `macro reward` の直後は、次の `micro reward` を 2〜4 分以内に返す

---

## 5. Curiosity Contract

### 5.1 一度に抱えさせる未解決数

| 範囲 | 上限 | ルール |
|------|-----:|--------|
| 1 zone 内の即時疑問 | 2 | 今すぐ行動を変える問いは 2 つまで |
| 1 world 内の主謎 | 3 | `local answer`, `制度の傷`, `次世界 promise` の 3 本まで |
| Act をまたぐ大謎 | 5 | それ以上は `logged` で保持し、同時前景化しない |

### 5.2 情報の出し方

1. `同じ記号が別文脈で再登場する`
2. `別媒体でもう一度見る`
3. `意味が少しだけ更新される`
4. その後で初めて、ノート価値が生まれる

### 5.3 notebook trigger の条件

プレイヤーがメモを取りたくなる情報は、次の 4 条件のうち 3 つ以上を満たす。

- 2媒体以上で反復した
- 世界をまたいで再登場した
- 1回目と2回目で意味が変わった
- 近い将来に実利へ変わりそうだと感じられる

### 5.4 禁止

- 固有名詞を一気に3つ以上増やす
- 1つの cutscene で謎を3段階進める
- 言葉だけで重要 clue を処理する
- ノートが必要なのに、再確認導線がない

---

## 6. 5分 / 15分 / 60分の理想構造

### 6.1 5分

```text
探索導入
→ 小戦闘 or 調べ物
→ 小判断（回復 / bait / route / 戻る）
→ clue or codex or object の更新
```

達成条件:

- 「どこへ向かうか」が更新された
- 少なくとも1つ、前より解像度が上がったものがある

### 6.2 15分

```text
zone 進入
→ 遭遇2〜5回
→ object / NPC / fixed clue
→ local obstacle 解消
→ reward beat
→ 次区画の promise
```

達成条件:

- zone / floor / local errand を 1 つ閉じた
- 1 つ以上の中報酬を得た
- 次の問いが明文化された

### 6.3 60分

```text
world problem 提示
→ 主要 zone 群の突破
→ local actors の利害露出
→ boss or decisive fixed event
→ local answer
→ gate / village / codex / bloodline のいずれかが前進
→ bigger question 開示
```

達成条件:

- 世界を一つ読み解いた感触がある
- それでも全体の真相はむしろ遠くなったと感じる
- 次回ログイン時の明確な目標が一つ残る

---

## 7. Return-To-Village Rule

帰村は休憩であると同時に、感情コストの更新地点でもある。

| world clear 後 | 必ず起こすこと |
|----------------|----------------|
| `W-001〜W-005` | 開始村の誰か 1 人の会話温度差分 |
| `W-006〜W-014` | 村の沈黙が制度側と繋がって見える差分 |
| `W-015〜W-021` | 共同体が持っていた正当化の限界が露出する差分 |

禁止:

- 世界を越えたのに村が何も変わらない
- 帰村が補給だけで終わる

---

## 8. QA Checklist

- 5分単位で `視覚 / 判断 / 情報` のどれかが更新されるか
- 15分単位で `一区切り` と言える閉じがあるか
- 60分単位で `local answer + bigger question` が両立しているか
- 報酬が `数値` だけでなく `意味の更新` になっているか
- メモを取りたくなる情報が、単なる不親切さではなく反復と再文脈化で生まれているか
- 起動終了時に、次回やることを一文で言えるか
