# 05. ID, Naming, Validation And Registry Rules

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15

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
| Map | `MAP-XXX-###` | `MAP-VIL-001` |
| NPC | `NPC-XXX-###` | `NPC-VIL-004` |
| Quest/Event (ドキュメントID) | `EVT-XXX-###` | `EVT-VIL-002` |
| Event Flag (コード内) | `EVT_XXX_###_DESC` | `EVT_VIL_010_TAG_TRACE_FOUND` |
| Breed Rule | `BRD-####` | `BRD-0104` |
| Loot Table | `LUT-###` | `LUT-007` |
| Prompt | `PRM-XXX-###` | `PRM-MON-001` |

> **注**: ドキュメント上のIDにはハイフン区切りを使用する。GDScript 等コード内のイベントフラグは `UPPER_SNAKE_CASE` を使用する。ドキュメントID とランタイム flag 名は別物として扱う。

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

### `asset_registry.csv` の列

| カラム | 説明 |
|--------|------|
| `asset_id` | 一意ID |
| `asset_type` | sprite / tileset / ui / bgm / se |
| `owner_id` | `MON-001` など |
| `source_file` | 元データ |
| `export_file` | 出力先 |
| `prompt_id` | prompt 参照 |
| `generator` | niji / gpt-image / nanobanana 等 |
| `generator_version` | バージョン |
| `seed_or_settings` | 再現用 |
| `edited_by_hand` | bool |
| `approved` | bool |

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

1. `master_index.csv` の実体
2. `asset_registry.csv` の実体
3. localization key validator
4. breed rule conflict validator
