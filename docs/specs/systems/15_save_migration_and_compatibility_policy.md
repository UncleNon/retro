# 15. Save Migration And Compatibility Policy

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/requirements/11_technical_architecture.md`
> - `docs/specs/systems/07_progress_flags_and_save_state_model.md`
> - `docs/specs/systems/05_id_naming_validation_and_registry_rules.md`
> - `scripts/save/save_system.gd`
> - `tests/gdscript/save_system_smoke.gd`
> - `tools/qa/save_smoke.py`

---

## 1. 目的

- セーブデータを長期運用しても破損、取りこぼし、無言リセットが起きない互換性基準を定める
- `schema_version` を単なる表示値ではなく、移行・検証・復旧の実行契約として扱う
- save payload の拡張、ID改名、統計再計算、異常終了復旧、将来の rollback を同一方針で運用する

---

## 2. 適用範囲と source of truth

### 2.1 正とする面

| 面 | 正とする内容 |
|----|--------------|
| `docs/specs/systems/07_progress_flags_and_save_state_model.md` | payload shape と進行フラグの意味 |
| `docs/requirements/11_technical_architecture.md` | save ファイル配置、envelope、復旧フロー |
| `docs/specs/systems/05_id_naming_validation_and_registry_rules.md` | save 内で参照する ID の規約 |
| `scripts/save/save_system.gd` | 現行 runtime baseline |

### 2.2 この文書が規定するもの

- `schema_version` の付け方と更新規律
- migration chain の実行順、停止条件、determinism
- alias / deprecation / backfill / derived value 再計算のルール
- corruption 判定、backup、rollback、unsupported save の扱い
- リリース前に通すべき migration QA と変更管理

### 2.3 この文書が直接定義しないもの

- 各 payload キーの意味そのもの
- 世界進行や数値バランス
- クラウド同期の採否

それらは参照元文書の正に従う。

---

## 3. 互換性原則

1. **無言破壊禁止**: 読めない save を空データへ置き換えてはならない
2. **追記優先**: 追加項目は既定値 backfill で吸収し、既存キーの即時削除を避ける
3. **単方向 migration**: 古い schema から新しい schema への deterministic な前方移行のみを正式サポートする
4. **原本保全**: migration 前の元ファイルは上書きせず、backup を残してから新 save を作る
5. **pure function**: migration は時刻、乱数、ネットワーク、外部状態に依存してはならない
6. **canonical write**: 保存時に出力してよいのは current schema の canonical key のみとする
7. **ID 安定性優先**: `05` の ID は公開後なるべく改名しない。必要時は alias を必須とする
8. **index は cache**: `save_index.json` は補助情報であり、slot / autosave 本体より優先しない

---

## 4. Schema Versioning Policy

### 4.1 基本ルール

- 全 save envelope と payload は `schema_version` を持つ
- 正規 save 時には envelope と payload の `schema_version` は一致していなければならない
- `schema_version` は app version と切り離して管理する
- 現行 baseline は `scripts/save/save_system.gd` の `SAVE_SCHEMA_VERSION` で定義される

### 4.2 バージョンの意味

| 変更種別 | 例 | bump |
|----------|----|------|
| payload shape 不変の実装修正 | validator bug fix、保存順序のみ修正 | `patch` |
| backfill で吸収可能な追加 / rename / derived 再計算 | 新フラグ追加、統計再定義、 alias 追加 | `minor` |
| 自動移行できない破壊的変更 | セクション分割、意味衝突、削除を伴う大改修 | `major` |

### 4.3 運用値

runtime は少なくとも以下を持つものとして設計する。

| 値 | 意味 |
|----|------|
| `current_schema_version` | 新規保存時に書く version |
| `minimum_supported_schema_version` | 自動 migration 対象の最古 version |
| `latest_tested_legacy_version` | fixture と migration test を維持している最古 version |

`minimum_supported_schema_version` を引き上げる変更は release note と unsupported policy 更新を必須とする。

### 4.4 envelope / payload の不一致

| 状態 | 扱い |
|------|------|
| 片方のみ欠落 | legacy save とみなし、判定可能なら migration 対象にする |
| 両方存在し一致 | 正常 |
| 両方存在し不一致 | 構造破損扱い。自動保存で上書きせず backup を残して停止する |

---

## 5. Canonical Migration Pipeline

### 5.1 読み込みパイプライン

1. JSON parse
2. envelope structural validation
3. pre-migration backup の作成
4. version 判定
5. step migration chain 実行
6. alias resolution
7. default backfill
8. derived value 再計算
9. semantic validation
10. current schema へ normalize
11. memory 上でロード完了

### 5.2 step migration の原則

- migrator は `from -> to` の単段だけを扱う
- `0.2.0 -> 0.4.0` のような飛び越し migrator を正規経路にしない
- 各 step は入力 version と出力 version を明示する
- 失敗時は途中結果を save slot 本体へ書き戻してはならない
- 成功後にだけ canonical schema で再保存できる

### 5.3 migration 実装契約

- 入力: envelope または payload の深いコピー
- 出力: 新しい Dictionary
- 禁止:
  - `Time.get_datetime_*` 依存の分岐
  - `randomize()` や seed 非固定の乱数
  - live master data を参照して結果が変わる変換
  - disk I/O を挟んだ部分更新

### 5.4 unknown field の扱い

- 同一 major 系の save については、解釈不能でも安全な field はできる限り保持する
- canonical schema に存在しない field でも、`ext` や将来拡張用 metadata は勝手に削除しない
- セキュリティ上危険、または validator 上明確に不正な field のみ破棄候補とする

---

## 6. Alias And Deprecation Policy

### 6.1 rename の原則

- 公開済み save に登場した key / enum / ID は即削除しない
- rename は `alias read + canonical write` で吸収する
- 旧名を読めても、新 save には旧名を書き戻さない

### 6.2 alias の対象

| 対象 | 例 | ルール |
|------|----|--------|
| key alias | `progress.main.chapter_no -> progress.main.chapter` | 読み込み時に canonical key へ統合 |
| enum alias | `AWAKE -> awakened` | canonical 値へ正規化 |
| content ID alias | `W-OLD-003 -> W-003` | `05` の規約に従い明示マップで吸収 |

### 6.3 deprecation window

- deprecated key は **少なくとも 2 minor schema**、または **1 public release cycle** の長い方だけ読み取り互換を維持する
- removal 予定の alias には `since`, `remove_after`, `migration_note` を記録する
- deprecation window を終了する変更は release checklist で明示レビューする

### 6.4 ID 改名時の追加ルール

- `05` の stable ID を原則維持する
- 改名が unavoidable な場合は save alias だけでなく、master data 側の参照検証も同時更新する
- 参照不能 ID を `null` 化して黙殺するのは禁止する

---

## 7. Backfill And Derived Recalculation

### 7.1 field の分類

| 分類 | 例 | ルール |
|------|----|--------|
| canonical state | `progress`, `worlds`, `gates` | migration 後も意味を保持する |
| derived stats | `stats.worlds_cleared`, `stats.clues_logged` | canonical state から再計算可能なら再計算を優先 |
| presentation cache | index metadata、並び順 cache | 欠落時は再生成してよい |

### 7.2 backfill の原則

- 新規 field 追加時は deterministic な既定値を定義する
- 既定値は `07` の payload 契約に従う
- `false` / `0` / `[]` / `{}` のみで意味が壊れる場合は、親 state から導出する migration を書く
- backfill は順序依存を最小化し、どの save でも同じ入力なら同じ出力にする

### 7.3 derived value 再計算

以下は stale 値を信用せず、可能なら rebuild を優先する。

- `stats.*` の集計値
- `save_index.json` のメタデータ
- 将来追加される UI cache、search index、sort key

### 7.4 section 欠落時の扱い

| 欠落セクション | 扱い |
|---------------|------|
| `stats`, `codex` | backfill で再生成可 |
| `progress.main`, `player` | 必須。補完不能なら fatal corruption |
| `worlds`, `gates`, `npcs`, `clues` | 空集合へ backfill 可。ただし既存参照と矛盾しないこと |

---

## 8. Corruption Handling, Backup, And Rollback

### 8.1 corruption の分類

| 種別 | 例 | 扱い |
|------|----|------|
| parse corruption | JSON 破損、truncated file | 読み込み停止、原本保全、recovery / backup を案内 |
| structural corruption | 必須 root 欠落、version 不一致 | 自動保存で上書きしない |
| semantic corruption | 不正 ID、型不正、到達不能 state | salvage 可能範囲を評価し、無理なら unsupported 扱い |
| cache corruption | `save_index.json` のみ破損 | index 再生成で回復 |

### 8.2 backup ルール

- migration 対象 save を初めて current schema へ引き上げる前に、元ファイルの read-only backup を作る
- backup は slot / autosave ごとに元 version が追跡できる命名を用いる
- backup は rollback と不具合調査のため、少なくとも直近 1 世代を保持する

### 8.3 write ルール

- 本体 save の更新は atomic write を維持する
- migration 途中の中間状態を slot 本体へ保存しない
- migration 後の自動再保存は validation 完了後のみ許可する

### 8.4 dirty shutdown / recovery との関係

- `session.lock.json` と `recovery.save.json` の異常終了復旧は `11_technical_architecture` の baseline を維持する
- migration 導入後も dirty shutdown 検知を無効化しない
- `recovery.save.json` は runtime crash 用、pre-migration backup は schema rollback 用として用途を分ける

### 8.5 rollback 方針

- release 後に migration bug が判明した場合、rollback は backup からの復元を正規手段とする
- 旧 app version が future schema save を読むことは保証しない
- rollback release を出す場合でも、壊れた current save をさらに上書きしてはならない

---

## 9. Unsupported Save Policy

### 9.1 自動サポート範囲

| 条件 | 扱い |
|------|------|
| `minimum_supported_schema_version <= save < current` | 自動 migration 対象 |
| `save == current` | そのまま load |
| `save > current` | future save 扱い。読み込み拒否、update を促す |
| `save < minimum_supported_schema_version` | unsupported legacy 扱い。自動 load しない |

### 9.2 unsupported 時の必須挙動

- 元ファイルを保持したまま、理由を UI / log に明示する
- `new game` を勝手に開始しない
- slot 一覧では metadata が読める範囲だけ表示し、失敗理由を添える
- import tool や one-shot upgrader が未実装でも、その不在を明示する

### 9.3 support floor 引き上げの条件

- 直近 release で十分な告知期間を取る
- fixture と migration test の保守コストを見積もる
- backup から戻せる運用手順を release note に載せる

`0.x` 開発中であっても、compatibility break を免責にしない。

---

## 10. Deterministic Migration Test Policy

### 10.1 必須テスト

1. 各 legacy schema fixture から current までの full-chain migration
2. 各 step migrator の direct test
3. 既に current な save の no-op test
4. alias 解決 test
5. backfill / derived stats 再計算 test
6. corruption / unsupported / future version test
7. backup 作成と original 非破壊 test
8. migrate -> save -> reload の round-trip test

### 10.2 deterministic 条件

- fixture は version ごとに固定 JSON を保存する
- テスト中の時刻は stub か固定値を使う
- locale、timezone、platform 差で結果が変わってはならない
- JSON key 順序や配列順が仕様化されている箇所は golden 比較する

### 10.3 repo 上の基準点

- `tests/gdscript/save_system_smoke.gd` は baseline smoke として維持する
- `tools/qa/save_smoke.py` は headless 実行の入口として維持する
- migration test 追加時も、この baseline smoke を壊さない

### 10.4 fixture 更新ルール

- bug を直しただけで current fixture を安易に更新しない
- fixture 更新時は「仕様変更」か「fixture が誤っていたか」を PR で明示する
- unsupported floor から外した schema fixture を削除する場合は、削除理由を release note に残す

---

## 11. Release Discipline

### 11.1 schema 変更 PR の必須項目

- `SAVE_SCHEMA_VERSION` の bump 要否を判断し、必要なら更新する
- payload shape が変わるなら `07` を更新する
- 互換性ポリシーや support window が変わるなら本書を更新する
- migrator、alias map、backfill rule、validator を同じ PR に含める
- legacy fixture と migration test を追加 / 更新する
- smoke test と migration test の両方を通す

### 11.2 release 前チェック

- slot save / autosave / recovery / index の全 surface を確認したか
- dirty shutdown 復旧が migration 導入後も成立するか
- unsupported save の UI / log メッセージが更新されたか
- rollback 用 backup の運用説明があるか

### 11.3 禁止事項

- schema を変えたのに version を据え置く
- migrator なしで payload key を rename / delete する
- save bug の暫定回避として無条件 `normalize -> overwrite` を入れる
- QA fixture なしで support floor を動かす

---

## 12. 実装チェックリスト

- 新しい field は deterministic default を持つか
- rename した key / ID に alias があるか
- derived stats は rebuild したほうが安全ではないか
- `save_index.json` を source of truth と誤用していないか
- failure 時に original save が残るか
- future save と unsupported legacy save を区別できるか
- migration test が時刻・乱数・外部 master 更新に依存していないか
