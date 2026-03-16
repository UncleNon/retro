# 05. ID, Naming, Validation And Registry Rules

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16

---

## 1. 目的

- 400体、20+世界、数百NPC、数千テキストを破綻なく管理する
- ID の揺れ、重複、参照切れ、命名崩壊を防ぐ
- AI生成アセットとゲーム内データを追跡可能にする

---

## 2. ID規約

### 共通原則

- 人間可読
- 連番だけに依存しない
- カテゴリが見える
- 外部公開名と内部IDを分ける

### フォーマット

| 種別 | 形式 | 例 |
|------|------|----|
| Monster | `MON-###` | `MON-001` |
| Skill | `SKL-###` | `SKL-012` |
| Item | `ITM-###` | `ITM-004` |
| World | `W-###` | `W-003` |
| Gate | `GATE-###` | `GATE-001` |
| Clue | `CL-###` | `CL-001` |
| Map | `MAP-XXX-###` | `MAP-VIL-001` |
| Field Scene | `FIELD-XXX-###` | `FIELD-VIL-001` |
| Field Rect | `FRECT-###` | `FRECT-031` |
| Field Point | `FPOINT-###` | `FPOINT-005` |
| Field Trigger | `FTRIG-###` | `FTRIG-002` |
| Field Interaction | `FINT-###` | `FINT-016` |
| NPC | `NPC-XXX-###` | `NPC-VIL-004` |
| Quest/Event (ドキュメントID) | `EVT-XXX-###` | `EVT-VIL-002` |
| Event Flag (コード内) | `EVT_XXX_###_DESC` | `EVT_VIL_010_TAG_TRACE_FOUND` |
| Breed Rule | `BRD-####` | `BRD-0104` |
| Loot Table | `LUT-###` | `LUT-007` |
| Prompt | `PRM-XXX-###` | `PRM-MON-001` |

> **注**: ドキュメント上のIDにはハイフン区切りを使用する。GDScript 等コード内のイベントフラグは `UPPER_SNAKE_CASE` を使用する。ドキュメントID とランタイム flag 名は別物として扱う。

Field runtime 補足:

- `MAP-VIL-001` は narrative / layout spec の ID として残してよい
- data-driven runtime では `FIELD-VIL-001` を canonical field_id とし、geometry / trigger / interaction は `FRECT-*`, `FPOINT-*`, `FTRIG-*`, `FINT-*` で追跡する

---

## 3. slug 規約

### ルール

- 英小文字 + `_`
- 先頭は英字
- 略称を使いすぎない
- 1ファイル内で一意

### 例

| 種別 | 良い例 | 悪い例 |
|------|--------|--------|
| monster slug | `mokkeda` | `monster1` |
| world slug | `ash_village` | `world_a` |
| skill slug | `ember_breath` | `atk_fire_01` |

---

## 4. ローカライズキー

| 種別 | 形式 |
|------|------|
| monster name | `monster.MON-001.name` |
| monster codex | `monster.MON-001.codex` |
| skill name | `skill.SKL-012.name` |
| skill desc | `skill.SKL-012.desc` |
| npc line | `npc.NPC-VIL-004.line.01` |
| quest title | `quest.EVT-VIL-002.title` |

---

## 5. ファイル命名

| 対象 | 形式 |
|------|------|
| GDScript | `snake_case.gd` |
| Scene | `snake_case.tscn` |
| Resource | `snake_case.tres` |
| Sprite source | `mon_001_mokkeda_b32.aseprite` |
| Exported sprite | `mon_001_mokkeda_b32.png` |
| Prompt json/csv | `monster_prompts.csv` |

---

## 6. レジストリ

### 必須レジストリ

| レジストリ | 目的 |
|------------|------|
| `master_index.csv` | 全 master file の一覧 |
| `asset_registry.csv` | 画像 / 音 / prompt の紐付け |
| `localization_registry.csv` | キー存在確認 |
| `world_dependency_map.csv` | 世界、NPC、イベント、モンスターの参照関係 |

Session 02 baseline:

- `master_index.csv` は `data/csv/*.csv` を全件登録する
- `asset_registry.csv` は provenance pipeline を壊さないため、まず seed row + sidecar manifest を置く
- `localization_registry.csv` は `data/localization/{ja,en}.csv` の bootstrap key を追跡する
- `world_dependency_map.csv` は `VIL`, `TWR`, `W-001`〜`W-021` の scope graph を正とする

### `asset_registry.csv` の列

- canonical schema は `docs/specs/art/08_asset_provenance_and_ai_generation_registry.md` を正とする
- Session 02 では、その full schema に従った baseline row を `data/csv/asset_registry.csv` に materialize する
- minimum validation は `asset_id + revision` の一意性、`export_file` / `manifest_path` の存在、`export_sha256` 一致までを hard fail とする

### Session 02 で materialize した補助台帳

#### `master_index.csv`

| カラム | 説明 |
|--------|------|
| `master_id` | 台帳行ID |
| `file_path` | `data/csv/` 配下の対象 CSV |
| `primary_key_column` | 最低限存在しなければならない列 |
| `domain` | monster / world / npc / progress など |
| `notes` | 補足 |

- `master_index.csv` は `data/csv/*.csv` の実ファイル集合と一致しなければならない
- 新規 master を増やしたら、同ターンでこの index を更新する
- `item_text_master.csv` のような content routing 用 CSV も例外ではなく index 対象に含める

#### `localization_registry.csv`

| カラム | 説明 |
|--------|------|
| `registry_id` | registry 行ID |
| `key_pattern` | `system.project_name`, `world.{world_id}.name` など |
| `locale` | `ja` / `en` |
| `source_path` | key namespace の canonical source |
| `backing_file` | 実文字列を置く localization CSV |
| `status` | `seed` / `planned` / `active` |
| `notes` | 補足 |

- `seed` 行は `backing_file` 側に同名 key が存在しなければ fail
- `planned` 行は namespace 予約であり、全文字列の実体化は後続 session で行う

#### `entity_alias_master.csv`

| カラム | 説明 |
|--------|------|
| `entity_type` | `item / shop / loot / service / reward` |
| `alias_value` | legacy alias (`SHP-*`, `SVC-*`, `LUT-*`, `SHOP-*`) |
| `canonical_id` | 正規化先の `*_id` |
| `alias_kind` | `registry / legacy_runtime / legacy_doc / temp_migration` |
| `active` | validator が受理するか |
| `source_doc` | 由来ファイル |

- alias は canonical ID と同じ文字列を再利用してはならない
- alias 解決は import / validation でのみ許可し、generated resource と save には canonical ID のみを出す

#### `world_dependency_map.csv`

| カラム | 説明 |
|--------|------|
| `scope_id` | `VIL`, `TWR`, `W-001`, `ACT4-CLIMAX` など |
| `scope_kind` | `village` / `tower` / `world` / `milestone` |
| `world_id` | anchor になる `world_id` |
| `entry_gate_id` | その scope に入る gate |
| `prerequisite_scope_id` | 直前に依存する scope |
| `notes` | 補足 |

- clue の `origin_scope_id` / `payoff_scope_id`、NPC の `world_id` はこの map に解決できなければならない

#### `clue_master.csv`

| カラム | 説明 |
|--------|------|
| `clue_id` | `CL-###` |
| `tier` | `T1`〜`T5` |
| `origin_scope_id` | clue 初出 scope |
| `origin_medium` | `NPC`, `建築`, `門反応` など |
| `payoff_scope_id` | 回収先 scope |
| `summary_jp` | clue 要約 |
| `source_doc` | 抽出元 doc |
| `notes` | 補足 |

#### `progress_gate_master.csv`

| カラム | 説明 |
|--------|------|
| `gate_id` | `GATE-W-001` 形式 |
| `world_id` | 対象世界 |
| `gate_index` | 1-origin の並び順 |
| `gate_type` | `story_flag` / `arena_rank` / `key_item` / `clue_count` / `family_resonance` / `composite` |
| `visible_surface` | 門前で見える試験表面 |
| `required_flag` | `EVT_*`, `FLAG_*`, `main.*`, `world.W-###.*` |
| `required_item` | canonical item id か予約済み `item_key_*` |
| `required_rank` | `G`〜`S` |
| `required_family_resonance` | `<family>:<min_level>` |
| `required_record_count` | 手帳 / record count の最低値 |
| `notes` | 補足 |

- `composite` は上記 requirement を 2 種以上使う
- Session 02 時点では `item_key_*` の一部が gate placeholder として先行予約される

---

## 7. バリデーションルール

### hard fail

- ID 重複
- 存在しない参照先
- ローカライズキー欠損
- asset registry 未登録
- 出現テーブルに `scoutable=false` 専用種しかいない
- breed rule の優先順位衝突
- world に拠点0

### warning

- モチーフ偏り過多
- 同じランク / 系統で silhouette 被りが多い
- 図鑑文のトーン不統一
- 世界ごとの禁忌が差別化できていない

---

## 8. 命名ガイド

### モンスター名

- 2〜6モーラ程度を基本
- 完全カタカナ連打にしない
- 村の生活語、道具、季語、痕跡語を混ぜる
- 露骨な元ネタ名を避ける

### 世界名

- 抽象名だけに逃げない
- 地形 + 儀礼 + 生活の匂いがあること
- “闇の世界” のような雑な名前は禁止

### NPC名

- 世界ごとの naming rules に従う
- 役割だけで記号化しない
- 同じ世界内では音韻ルールを揃える

---

## 9. 実装時チェックリスト

- 新規 master を追加したか
- ID はルール通りか
- localization key を切ったか
- asset registry に入れたか
- requirements / specs / 実データの名前が揺れていないか

---

## 10. 次に必要なもの

1. `asset_registry.csv` の実 asset row 拡張
2. localization namespace の全文字列化
3. save migration / runtime repository で alias 読み込みを canonical write に統一
4. breed rule conflict validator
