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

```
project/
├── scenes/
│   ├── main/              # メインシーン（起動・ルーティング）
│   ├── title/             # タイトル画面
│   ├── field/             # フィールド探索
│   ├── battle/            # バトル画面
│   ├── menu/              # メニュー画面群
│   └── loading/           # ローディング
├── scripts/
│   ├── core/              # ゲーム基盤（GameManager, SaveSystem, etc.）
│   ├── monster/           # モンスター関連（データ, 配合, 図鑑）
│   ├── battle/            # バトルシステム
│   ├── ui/                # UI管理
│   ├── tournament/        # トーナメント
│   ├── dungeon/           # ダンジョン生成
│   ├── audio/             # オーディオ管理
│   ├── world/             # ワールド管理・シーン遷移
│   ├── npc/               # NPC・会話システム
│   ├── item/              # アイテムシステム
│   ├── localization/      # ローカライズシステム
│   ├── save/              # セーブ・iCloud同期
│   ├── input/             # 入力管理（バーチャルパッド）
│   └── utils/             # ユーティリティ
├── resources/
│   ├── monsters/          # 400体分のMonsterData（.tres）
│   ├── skills/            # スキルツリー定義
│   ├── items/             # アイテム定義
│   ├── worlds/            # 世界定義
│   └── breeding_table/    # 配合テーブル
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
├── addons/                # Godotプラグイン（エディタ拡張等）
│   └── csv_importer/      # CSVインポーター
├── data/
│   ├── csv/               # マスターデータCSV
│   └── localization/      # 翻訳テキスト（CSV/JSON）
├── tests/                 # GdUnit4テスト
├── export/                # エクスポート設定
├── project.godot          # プロジェクト設定
└── .gdignore
```

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

---

## 11.4 データ管理

### マスターデータ パイプライン
```
CSVファイル（人間が編集可能）
    ↓
エディタプラグイン（CSVインポーター）
    ↓
Godot Resource（.tres）（ゲームが読み込む）
    ↓
ランタイムデータ（ゲーム中に参照）
```

### マスターデータ一覧
| データ | 形式 | レコード数 |
|--------|------|-----------|
| モンスターマスター | CSV → Resource | 400 |
| スキルツリー | CSV → Resource | 100+ |
| 技・特技 | CSV → Resource | 300+ |
| 配合テーブル（家系） | CSV → Resource | 81 |
| 配合テーブル（特殊） | CSV → Resource | 200〜400 |
| アイテム | CSV → Resource | 100+ |
| 世界定義 | CSV → Resource | 20+ |
| NPC | CSV → Resource | 200+ |
| テキスト | CSV/JSON | 数千 |

### Godot Resource 定義例（MonsterData）
```gdscript
class_name MonsterData
extends Resource

@export var id: String
@export var name_jp: String
@export var name_en: String
@export var family: MonsterFamily
@export var element: Element
@export var rank: MonsterRank
@export var growth_type: GrowthType
@export var sprite_size: int

# ステータス（Lv1基準）
@export var base_hp: int
@export var base_mp: int
@export var base_atk: int
@export var base_def: int
@export var base_spd: int
@export var base_int: int
@export var base_res: int

# 属性耐性
@export var resistances: Dictionary

# スキルツリー
@export var skill_trees: Array[SkillTreeData]

# 図鑑
@export_multiline var description_jp: String
@export_multiline var description_en: String

enum MonsterFamily { SLIME, BEAST, BIRD, PLANT, MAGIC, MATERIAL, UNDEAD, DRAGON, DIVINE }
enum Element { NONE, FIRE, WATER, WIND, EARTH, THUNDER, LIGHT, DARK }
enum MonsterRank { E, D, C, B, A, S }
enum GrowthType { EARLY, NORMAL, LATE, SPECIAL }
```

### ランタイムデータ（セーブデータ）
```gdscript
class_name SaveData
extends Resource

# プレイヤー情報
@export var player_name: String
@export var player_gender: int       # 0=男, 1=女
@export var gold: int
@export var play_time: float
@export var story_chapter: int
@export var tournament_rank: int

# モンスター
@export var party: Array[MonsterSaveData]   # 最大3体
@export var ranch: Array[MonsterSaveData]   # 最大200体
@export var pokedex: Array[bool]            # 400枠
@export var mutation_log: Array[bool]       # 変異種発見記録

# インベントリ
@export var inventory: Array[ItemSaveData]
@export var key_items: Array[ItemSaveData]

# 世界・進行
@export var current_scene: String
@export var current_position: Vector2
@export var world_unlocked: Array[bool]
@export var event_flags: Dictionary

# 統計
@export var total_battles: int
@export var total_breedings: int
@export var total_mutations: int
```

---

## 11.5 セーブシステム

### 仕様
| 項目 | 仕様 |
|------|------|
| **手動セーブ** | 3スロット |
| **オートセーブ** | 1スロット（マップ遷移・バトル終了時） |
| **保存形式** | JSON（暗号化） |
| **保存先** | OS.get_user_data_dir() |
| **暗号化** | AES-256（Godot Crypto APIまたはGDExtension） |
| **iCloud同期** | 候補: iOS CloudKit経由（Phase 0スパイク通過時のみ v1対象） |

- **原則**: ローカルセーブ単独で完結する構成を維持し、クラウド同期の有無でゲーム本編の成立を左右させない

### セキュリティ
- **暗号化キー**: ハードコード禁止。iOS Keychainに保管（GDExtension経由）
- **データ整合性**: チェックサム付き（改ざん検知）
- **バックアップ**: ローカルバックアップを標準とし、iCloud採用時のみクラウドバックアップを追加
- **チート対策**:
  - セーブデータの署名検証
  - 異常値検出（ステータス上限チェック等）
  - メモリ上の重要値を難読化

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
