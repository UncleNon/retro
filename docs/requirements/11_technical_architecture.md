# 11. 技術アーキテクチャ

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **ADR**: Unity 6 LTS → Godot 4.4 に変更（2026-03-15）

---

## 11.1 技術スタック

| レイヤー | 技術 | バージョン |
|----------|------|-----------|
| **エンジン** | Godot 4.4 | 最新安定版 |
| **レンダリング** | Godot ネイティブ2D | ピクセルパーフェクト対応 |
| **言語** | GDScript（メイン）/ C#（必要に応じて） | Godot 4.4対応 |
| **クラウド同期** | ローカルセーブ必須 / iCloud (CloudKit) は Phase 0 で採否判定 | iOS標準候補 |
| **データ形式** | Godot Resource + CSV | — |
| **バージョン管理** | Git + Git LFS | — |
| **CI/CD** | GitHub Actions | — |
| **配布** | TestFlight → App Store | — |
| **ライセンス** | MIT（エンジン自体のライセンスリスクゼロ） | — |

### エンジン変更の理由（ADR）
- **ネイティブ2Dパイプライン**: GBC風160×144pxのピクセルパーフェクト描画に最適
- **軽量エディタ**: 120MB、即起動。ソロ+AI開発でのイテレーション速度を最大化
- **ライセンスリスクゼロ**: MITライセンス。趣味プロジェクトに最適
- **2Dゲームとしての実績**: Cassette Beasts（モンスター育成RPG）、Brotato等
- **切替コスト**: 既存C#コード1,500行のみ、シーン/アセットゼロの段階で最小

---

## 11.2 プロジェクト構成

`Project RETRO` の canonical runtime root は repo root とする。`project/` のような別ルートは切らない。

```
repo-root/
├── project.godot          # Godot canonical entrypoint
├── icon.svg               # 仮アイコン
├── scenes/
│   ├── main/              # 起動・ルーティング
│   ├── title/
│   ├── field/
│   ├── battle/
│   ├── menu/
│   └── loading/
├── scripts/
│   ├── main/              # app_root など起動シーン用
│   ├── core/              # GameManager 等の基盤
│   ├── data/              # Resource クラス定義
│   ├── monster/
│   ├── battle/
│   ├── ui/
│   ├── tournament/
│   ├── dungeon/
│   ├── audio/
│   ├── world/
│   ├── npc/
│   ├── item/
│   ├── localization/
│   ├── save/
│   ├── input/
│   └── utils/
├── resources/
│   ├── monsters/          # 生成済み MonsterData .tres
│   ├── skills/            # 生成済み SkillData .tres
│   ├── items/             # 生成済み ItemData .tres
│   ├── worlds/            # 生成済み WorldData .tres
│   ├── encounters/        # 生成済み EncounterZoneData .tres
│   └── breeding/          # 生成済み BreedRuleData .tres
├── assets/
│   ├── sprites/
│   │   ├── monsters/
│   │   ├── characters/
│   │   ├── tilesets/
│   │   ├── effects/
│   │   └── ui/
│   ├── audio/
│   │   ├── bgm/
│   │   ├── se/
│   │   └── jingles/
│   ├── fonts/
│   └── tilemaps/
├── addons/
│   └── csv_importer/      # editor plugin の受け皿
├── data/
│   ├── csv/               # canonical master CSV
│   ├── generated/         # build manifest 等の生成物
│   └── localization/
├── tests/
│   ├── python/            # パイプライン / スキーマ検証
│   └── gdunit/            # Godot 側テストの受け皿
├── tools/
│   ├── palette-remap/     # パレット変換の canonical path
│   ├── data/              # CSV → Resource build
│   └── qa/                # lint / format / smoke / unit wrappers
├── export/
├── docs/                  # source of truth docs
├── retro-claude/          # 参照用旧資産（.gdignore）
├── retro-codex/           # 参照用旧資産（.gdignore）
└── legacy-root-assets/    # 旧 root Assets の退避先（.gdignore）
```

### 参照用ディレクトリの扱い
- `docs/`, `retro-claude/`, `retro-codex/`, `legacy-root-assets/`, `tools/` には `.gdignore` を置き、Godot import 対象から外す
- 旧Unity系資産は削除せず、参照専用として隔離する
- 実装先は repo root 配下の lowercase ディレクトリに統一する

---

## 11.3 アーキテクチャ設計

### Godot固有の設計パターン

| パターン | 適用箇所 | Godotでの実現方法 |
|----------|---------|------------------|
| **Autoload（シングルトン）** | GameManager, AudioManager, SaveSystem | プロジェクト設定でAutoload登録 |
| **State Machine** | BattleManager, GameState | Nodeベースのステートマシン |
| **Signal（Observer）** | ゲームイベント全般 | Godot組み込みのSignalシステム |
| **Resource** | マスターデータ全般 | Godot Resourceクラス（.tres） |
| **Object Pool** | エフェクト, UI要素 | カスタムプールノード |
| **Command** | バトルアクション | Resourceベースのコマンド |
| **Strategy** | AI作戦システム | 差し替え可能なスクリプト |
| **Scene as Prefab** | モンスター, UI部品 | .tscnファイルをインスタンス化 |

### システム間依存関係
```
GameManager（Autoload・全体統括）
├── SceneManager（シーン遷移）
├── SaveSystem（セーブ/ロード/iCloud）
├── AudioManager（BGM/SE）
├── InputManager（バーチャルパッド）
├── LocalizationManager（言語管理）
│
├── BattleManager
│   ├── DamageCalculator
│   ├── AIController（作戦AI）
│   ├── BattleUI
│   └── EffectManager
│
├── MonsterManager
│   ├── MonsterDatabase（マスターデータ）
│   ├── BreedingSystem（配合）
│   ├── MonsterParty（パーティ管理）
│   └── MonsterRanch（牧場管理）
│
├── WorldManager
│   ├── DungeonGenerator
│   ├── EncounterSystem（エンカウント）
│   ├── NPCManager
│   └── EventSystem
│
├── TournamentManager
├── ItemManager
└── UIManager
    ├── MenuUI
    ├── BattleUI
    ├── DialogueUI
    └── HUDManager
```

### Session 01 時点の最小 Autoload
- `GameManager`
- `SaveSystem`
- `AudioManager`
- `InputManager`

これらは空プロジェクト起動と今後の依存注入先を固定するための最小 shell として先に置く。

---

## 11.4 データ管理

### マスターデータ パイプライン
```
data/csv/*.csv
    ↓
tools/data/build_resources.py
    ↓
resources/{monsters,skills,items,worlds,encounters,breeding}/*.tres
    ↓
data/generated/resource_manifest.json
    ↓
ランタイム読み込み
```

- Session 03 の canonical build entrypoint は `tools/data/build_resources.py`
- `addons/csv_importer/` は editor plugin 化の受け皿として残すが、現時点の正は build script
- build は `monster_master.csv`, `monster_resistance.csv`, `monster_learnset.csv`, `skill_master.csv`, `item_master.csv`, `world_master.csv`, `zone_master.csv`, `encounter_table.csv`, `breed_rule.csv` を読む

### マスターデータ一覧
| データ | 形式 | 初期状態 |
|--------|------|----------|
| モンスターマスター | CSV → Resource | Session 03 で 10体 seed |
| 技・特技 | CSV → Resource | Session 03 で 36種 seed |
| アイテム | CSV → Resource | Session 03 で 16種 seed |
| 世界定義 | CSV → Resource | Session 03 で 4世界 seed |
| エンカウント | CSV → Resource | Session 03 で 5ゾーン seed |
| 配合ルール | CSV → Resource | Session 03 で 12ルール seed |
| NPC | CSV → Resource | 今後追加 |
| テキスト | CSV/JSON | 今後追加 |

### Godot Resource 定義例（MonsterData）
```gdscript
extends Resource

@export var monster_id: String
@export var slug: String
@export var name_jp: String
@export var name_en: String
@export var family: String
@export var rank: String
@export var size_class: String
@export var motif_group: String
@export var motif_source: String
@export var silhouette_type: String
@export var palette_id: String
@export var field_sprite_px: int
@export var battle_sprite_px: int
@export var base_level_cap: int
@export var growth_curve_id: String
@export var base_stats: Dictionary
@export var cap_stats: Dictionary
@export var base_recruit: int
@export var scoutable: bool
@export var personality_bias: String
@export var trait_1: String
@export var trait_2: String
@export var loot_table_id: String
@export var prompt_id: String
@export var notes: String
@export var resistances: Dictionary
@export var learnset: Array
```

### ランタイムデータ（Session 04 baseline）
Session 04 時点では、セーブは `Resource` 直列化ではなく **versioned JSON payload** を canonical とする。

```gdscript
{
  "schema_version": "0.2.0",
  "player": {
    "name": "",
    "gold": 0,
    "play_time_seconds": 0,
    "current_scene": "res://scenes/main/app_root.tscn",
    "current_position": {"x": 0, "y": 0}
  },
  "party": [],
  "ranch": [],
  "inventory": [],
  "vault": [],
  "progress": {
    "main": {
      "act": 1,
      "chapter": 0,
      "story_complete": false,
      "postgame_open": false,
      "true_name_awareness": 0,
      "silence_broken": false
    }
  },
  "worlds": {},
  "gates": {},
  "npcs": {},
  "clues": {},
  "codex": {
    "monster_count_seen": 0,
    "monster_count_recruited": 0,
    "recipe_count_known": 0,
    "recipe_count_resolved": 0,
    "mutation_count_seen": 0
  },
  "stats": {
    "total_battles": 0,
    "total_wins": 0,
    "total_recruits": 0,
    "total_breeds": 0,
    "total_mutations": 0,
    "tower_entries": 0,
    "worlds_cleared": 0,
    "clues_logged": 0
  }
}
```

- キー構造の正は `docs/specs/systems/07_progress_flags_and_save_state_model.md`
- 将来的に `Resource` ラッパーや binary save へ移る場合も、この payload shape を先に守る

---

## 11.5 セーブシステム

### 仕様
| 項目 | 仕様 |
|------|------|
| **手動セーブ** | 3スロット |
| **オートセーブ** | 1スロット（マップ遷移・バトル終了時） |
| **異常終了復帰** | `session.lock.json` + `recovery.save.json` で検知 / 復旧 |
| **保存形式** | versioned JSON envelope |
| **保存先** | `user://saves` |
| **クラウド同期** | 不採用。Phase 0 では採否判定材料だけ残す |
| **iCloud同期** | 候補: iOS CloudKit経由（Phase 0スパイク通過時のみ v1対象） |

- **原則**: ローカルセーブ単独で完結する構成を維持し、クラウド同期の有無でゲーム本編の成立を左右させない

### Session 04 実装 baseline

#### 保存ファイル
```
user://saves/
├── slot_01.save.json
├── slot_02.save.json
├── slot_03.save.json
├── autosave.save.json
├── recovery.save.json
├── save_index.json
└── session.lock.json
```

#### Envelope 構造
```json
{
  "schema_version": "0.2.0",
  "saved_at_utc": "2026-03-15T12:00:00Z",
  "save_kind": "manual | autosave",
  "slot_id": 1,
  "payload": { "...normalized save payload..." }
}
```

#### 復帰の流れ
1. bootstrap 時に `session.lock.json` の残存を確認
2. lock が残っていれば dirty shutdown 扱いにする
3. `recovery.save.json` があれば復帰候補として提示できる状態にする
4. clean shutdown 時は session lock を消す

### 将来の hardening 候補
- 改ざん検知用 checksum / signature
- iOS Keychain と連携した鍵管理
- 暗号化 save
- iCloud / CloudKit バックアップ

これらは **今の baseline では未採用** とし、save loop を固めた後に別判断で入れる。

### iCloud同期フロー（採用時）
```
ローカルセーブ
    ↓
iCloudへアップロード（バックグラウンド、GDExtension経由）
    ↓
他デバイスからログイン時
    ↓
ローカル vs iCloud のタイムスタンプ比較
    ↓
新しい方を使用（競合時はユーザーに選択肢表示）
```

### iOS連携の実装方針
- GDExtension（GodotのネイティブC++プラグイン機構）でiOS固有APIにアクセス
- iCloud (CloudKit)、Keychain、GameCenter（将来）等
- オープンソースのGodot iOSプラグインを活用 or 自作
- Phase 0で「ローカルのみ出荷」と「iCloud対応」の両方を比較し、実装コストに対して価値が見合うか判断する

### Session 04 iOSスパイク結果
- ローカル検証環境:
  - Godot editor: `4.6.1.stable`
  - Xcode: `26.3`
- 2026-03-15 時点の blockers:
  - Godot export templates が未導入
  - `export_presets.cfg` が未作成
  - codesigning identity が未設定
- canonical report:
  - `export/ios/ios_export_smoke_report.json`
  - `export/ios/ios_export_smoke_report.md`
- したがって、**iOS export は「前提条件未充足のため blocked」** と判断する

---

## 11.6 パフォーマンス設計

### ターゲット
| 項目 | 目標 |
|------|------|
| **FPS** | 60fps安定 |
| **ロード時間** | シーン遷移 < 2秒 |
| **メモリ** | < 300MB（Godotは軽量なので余裕あり） |
| **ストレージ** | アプリ全体 < 300MB |
| **バッテリー** | 連続プレイ3時間+を目標 |

### 最適化方針
- **TileMap最適化**: Godotネイティブのチャンクベースカリング
- **Object Pooling**: エフェクト、UI要素の再利用
- **遅延ロード**: ResourceLoader.load_threaded で非同期ロード
- **スプライトアトラス**: AtlasTexture でドローコール削減
- **オーディオ**: BGMはOGGストリーミング、SEはWAV

---

## 11.7 解像度・画面設計

| 項目 | 仕様 |
|------|------|
| **ゲーム内部解像度** | 160×144px（GBC準拠） |
| **ウィンドウ設定** | `viewport` stretch mode + `integer` stretch aspect |
| **テクスチャフィルタ** | Nearest（ピクセルパーフェクト） |
| **アスペクト比** | 10:9（GBC準拠、上下に黒帯 or 装飾） |

### Godotプロジェクト設定
```
display/window/size/viewport_width = 160
display/window/size/viewport_height = 144
display/window/stretch/mode = "viewport"
display/window/stretch/aspect = "keep"
rendering/textures/canvas_textures/default_texture_filter = 0  # Nearest
rendering/2d/snap/snap_2d_vertices_to_pixel = true
rendering/2d/snap/snap_2d_transforms_to_pixel = true
```

### iPhone対応
- GBCアスペクト比は現代スマホ（19.5:9等）と異なる
- 上下の余白領域にゲーム外UIを配置する案:
  - 上部: ミニマップ or ステータスサマリ
  - 下部: バーチャルパッド
- ゲーム画面自体は中央にピクセルパーフェクトで表示

---

## 11.8 シーン管理

### シーン構成
| シーン | 常駐 | 説明 |
|--------|------|------|
| **Main** | ✓ | Autoloadノード群（常駐） |
| **Title** | — | タイトル画面 |
| **Field** | — | フィールド探索 |
| **Battle** | — | バトル画面（オーバーレイ） |
| **Menu** | — | メニュー（オーバーレイ） |

### シーン遷移方式
- `SceneTree.change_scene_to_packed()` でメインシーン切替
- バトル・メニューは `add_child()` でオーバーレイ追加
- フェードイン/フェードアウト（黒画面、0.3秒）
- `ResourceLoader.load_threaded_request()` でバックグラウンドロード

---

## 11.9 TileMap設計

### Godot TileMap活用
- Godot 4.4のTileMapノードはネイティブ2D専用設計
- レイヤー構成:
  - Layer 0: 地面
  - Layer 1: 壁・障害物（コリジョン付き）
  - Layer 2: 装飾（上に重なるもの）
  - Layer 3: イベントタイル（不可視、トリガー用）
- オートタイル（TileSet Terrain）で地形の境界を自動処理
- Physics Layer でコリジョンを設定

### TileSetの構成
- 8×8pxタイルをTileSetリソースとして登録
- 世界ごとに別TileSetを用意
- 共通タイル（階段、扉、宝箱）は共有TileSet

---

## 11.10 入力システム

### Godot InputMap
```
# project.godot の input_map 設定
move_up → バーチャルパッド上
move_down → バーチャルパッド下
move_left → バーチャルパッド左
move_right → バーチャルパッド右
action_a → Aボタン（決定）
action_b → Bボタン（キャンセル）
menu → メニューボタン
pause → ポーズボタン
```

### バーチャルパッド実装
- TouchScreenButton ノード or カスタムControl
- 位置・サイズ・透過度のカスタマイズ対応
- GBC画面の外側（上下の余白領域）に配置
