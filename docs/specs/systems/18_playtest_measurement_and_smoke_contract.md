# 18. Playtest Measurement And Smoke Contract

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16
> **役割**: save / export / readability の smoke test と、battle / recruit / breeding の体感計測を canonical な契約として固定する
> **参照元**:
> - `docs/requirements/12_cicd_and_qa.md`
> - `docs/requirements/14_non_functional.md`
> - `docs/specs/systems/06_randomness_policy_and_probability_budgets.md`
> - `docs/specs/systems/12_ui_screen_catalog_and_input_rules.md`
> - `docs/specs/systems/15_save_migration_and_compatibility_policy.md`
> - `docs/specs/systems/17_encounter_authoring_and_balance_sandbox.md`

---

## 1. 目的

- `面白いはず` を感覚だけで済ませず、最低限の smoke と体感計測で壊れ方を先に固定する
- docs 上で決めた `20〜45秒 battle`, `10〜15分で初回勧誘`, `1回の配合で前進感` を測定可能にする
- 実装後に QA が場当たりにならないよう、テスト観点と pass/fail を先に決める

---

## 2. authority

この文書は以下を authoritative に扱う。

- smoke test の最小ケース
- playtest measurement の target と観測方法
- telemetry が満たすべき最小粒度

以下の authority は既存文書へ残す。

| 主題 | authority |
|------|-----------|
| save schema / migration / recovery | `systems/15_save_migration_and_compatibility_policy.md` |
| UI 入力と画面仕様 | `systems/12_ui_screen_catalog_and_input_rules.md` |
| RNG / pity / recruit 公平性 | `systems/06_randomness_policy_and_probability_budgets.md` |
| encounter sandbox の zone / pack 設計 | `systems/17_encounter_authoring_and_balance_sandbox.md` |

---

## 3. Smoke Test Minimum Set

### 3.1 `save_corruption_smoke`

| case_id | 想定事故 | 期待挙動 |
|---------|----------|----------|
| `save_truncated` | save file が途中で切れている | 壊れた slot を検知し、復旧導線か backup へ落とす |
| `save_schema_old` | 古い `schema_version` | migration 実行。不可なら read-only warning |
| `save_midwrite_crash` | write 中に異常終了 | 前回正常 save へ復帰。中途半端 save を正としない |
| `save_flag_unknown` | 未来フラグ混入 | 既知フィールドだけ読む。未知は無視 or 退避 |
| `save_registry_missing` | codex / clue 部分破損 | 本編進行を巻き戻さず補完できる範囲で再構築 |

Pass 条件:

- 起動不能にならない
- 本編進行 `main.*` が壊れたままロードされない
- 復旧メッセージは 2 画面以内で終わる

### 3.2 `ios_export_smoke`

| step | 確認項目 | Pass 条件 |
|------|----------|----------|
| 1 | build 成功 | archive / export が通る |
| 2 | 起動 | title まで 10 秒以内で到達 |
| 3 | フィールド操作 | 移動、menu、決定、キャンセルが詰まらない |
| 4 | 戦闘 | 1戦闘を開始して完了できる |
| 5 | save/load | 保存して再起動後に復帰できる |
| 6 | audio | BGM / SE が二重再生・無音化しない |
| 7 | suspend/resume | バックグラウンド復帰で入力 / 音 / save が壊れない |

### 3.3 `font_readability_smoke`

| surface | 条件 | Pass 条件 |
|---------|------|----------|
| dialogue 2行 | 160x144 相当 | 1x 想定で判読可能 |
| item list | 説明帯あり | 選択中行と説明が見分けられる |
| battle log | 下段6行 | 重要語が潰れない |
| mobile touch hint | iPhone 実機想定 | UI と文字が競合しない |

判読失敗の基準:

- 似た字が 2 組以上連続して誤読される
- 1 画面で視線が 3 往復以上必要
- cursor と文字が重なって読む速度が落ちる

---

## 4. Measurement Contracts

### 4.1 `battle_tempo`

序盤通常戦の体感を `速いが薄くない` に保つ。

| 対象 | target |
|------|--------|
| 序盤通常戦 median | `20〜45秒` |
| 序盤通常戦 p90 | `<= 60秒` |
| gatekeeper 戦 median | `60〜120秒` |
| ログ滞留 | 1 ラウンドで 3 文連続を避ける |

観測方法:

- `battle_start` / `battle_end`
- `battle_time_sec`
- `round_count`
- `used_plan`
- `used_items`

Fail 例:

- 序盤通常戦 median > 45 秒
- 速いが入力不要で退屈
- 速くても reward / clue / scout の判断が起きない

### 4.2 `recruit_stress`

`初回勧誘が遠すぎる` と core loop が立たない。

| 対象 | target |
|------|--------|
| onboarding first recruit | `10〜15分` 以内 |
| matched bait + weakened target success | 明確に手応えがある |
| failure streak | pity 込みで理不尽感を抑える |

観測方法:

- `recruit_attempt`
- `target_monster_id`
- `hp_ratio`
- `status_count`
- `bait_type`
- `success`
- `elapsed_since_new_game_min`

Fail 例:

- 15 分を超えても初回勧誘が見えない
- bait を使っても改善実感がない
- 勧誘に寄ると戦闘や回復が破綻する

### 4.3 `breeding_forward_progress`

配合は、数値が上がっただけではなく `前に進んだ` と感じさせる必要がある。

| 対象 | target |
|------|--------|
| 初回配合後 | 1 つ以上の目に見える前進がある |
| 3回以内の配合 | recipe, skill, plus, mutation hint のどれかが増える |
| 配合直後の次目標 | 一文で言える |

`前進` とみなすもの:

- 新 skill 候補
- `plus_value` 上昇
- 新しい family bridge
- recipe hint 解放
- world / gate で試したくなる相手が増える

観測方法:

- `breed_start`
- `breed_end`
- `child_id`
- `plus_delta`
- `new_skill_count`
- `new_recipe_hint_count`
- `next_goal_tag`

Fail 例:

- 子ができたが、何が良くなったか分からない
- 強さは上がったが血統の意味が増えない
- 連続配合しないと快感が出ない

---

## 5. Playtest Profiles

### 5.1 基本3プロファイル

| profile | 目的 |
|---------|------|
| `fresh_reader` | lore を知らない人が読めるか |
| `system_greedy` | recruit / breed / route 最適化欲が立つか |
| `returning_short_session` | 短時間再開で迷わないか |

### 5.2 1ケースあたりの最小サンプル

- `battle_tempo`: 20 戦
- `recruit_stress`: new game 3 本
- `breeding_forward_progress`: 初回〜3回配合の 5 ケース
- `font_readability_smoke`: 2 名以上

---

## 6. Telemetry Minimum Fields

### 6.1 必須

| event | 必須フィールド |
|-------|----------------|
| `battle_end` | `battle_time_sec`, `round_count`, `won`, `fled` |
| `recruit_attempt` | `target_monster_id`, `hp_ratio`, `bait_type`, `success` |
| `breed_end` | `child_id`, `plus_delta`, `new_skill_count`, `new_recipe_hint_count` |
| `menu_open` | `screen_id`, `duration_ms` |
| `save_write_result` | `schema_version`, `success`, `recovered_from_backup` |

### 6.2 集計で必ず見るもの

- 序盤通常戦 median / p90
- 初回勧誘までの分数
- 初回配合後の継続率
- save recovery 発生回数
- readability fail 件数

---

## 7. QA Checklist

- smoke が `起動できるか` だけでなく `続けられるか` を見ているか
- テンポ計測が boss 戦と通常戦を混ぜていないか
- recruit の不満を `確率を上げる` だけで誤魔化していないか
- breeding の前進感を `数値上昇だけ` で判定していないか
- readability を開発者の慣れで判断していないか
