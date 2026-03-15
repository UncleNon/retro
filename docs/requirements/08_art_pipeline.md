# 08. アート・アセットパイプライン

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15

---

## 8.1 設計方針

> AI生成をメインとしつつ、一貫性・品質・IP安全性を厳密に管理する。「AIが作った安っぽいゲーム」ではなく、「プロが品質管理したAI活用ゲーム」を目指す。

---

## 8.2 アートスタイル基本ルール

### GBC準拠の制約
| 項目 | 仕様 | 理由 |
|------|------|------|
| **マスターパレット** | 32色（BG 8パレット×4色 + Sprite 8パレット×3色+透過） | GBC仕様準拠 |
| **アウトライン** | 1px 黒縁（#000000） | GBC時代の標準表現 |
| **シェーディング** | 2トーン（ベース色+影色） | 色数制限内での立体表現 |
| **アンチエイリアシング** | 禁止 | ピクセルパーフェクト維持 |
| **ディザリング** | 禁止 | GBCの美学に反する |
| **グラデーション** | 禁止 | 色数制限との矛盾 |
| **サブピクセル** | 禁止 | 整数ピクセルのみ |

### マスターパレット定義
（canonical path は repo-root の `tools/palette-remap/master_palette.hex` とする。現状 `retro-claude/tools/palette-remap/` にある実装は Phase 0 で移設する）

---

## 8.3 アセットカテゴリと仕様

### モンスタースプライト
| ランク | バトル | フィールド | アニメーション |
|--------|--------|-----------|-------------|
| E | 24×24px | 16×16px | 待機2F |
| D | 32×32px | 16×16px | 待機2F |
| C | 32×32px | 16×16px | 待機2F |
| B | 48×48px | 16×16px | 待機2F |
| A | 48×48px | 16×16px | 待機2F |
| S | 56×56px | 16×16px | 待機2F + 攻撃3F |

### キャラクタースプライト
| 対象 | サイズ | フレーム数 |
|------|--------|-----------|
| 主人公（男） | 16×16px | 2F歩行 × 4方向 = 8F |
| 主人公（女） | 16×16px | 2F歩行 × 4方向 = 8F |
| NPC | 16×16px | 2F歩行 × 4方向 = 8F（主要NPC）、1F × 1方向（モブ） |

### タイルセット
| 対象 | サイズ | 枚数目安 |
|------|--------|---------|
| 各世界のタイルセット | 8×8px/タイル | 最低64タイル/セット |
| 共通タイル | 8×8px | 32タイル |
| 全世界合計 | — | 20+セット |

### UIアセット
| 対象 | サイズ | 備考 |
|------|--------|------|
| ウィンドウ | 9-slice（8×8pxコーナー） | 2〜3バリエーション |
| カーソル | 8×8px | 2Fアニメーション |
| 数値用UIマーカー | 4px高 × 小型 | 危険時の色変化、点滅、残量補助 |
| アイコン | 16×16px | アイテム、属性、状態異常 |
| ボタン | 可変 | バーチャルパッド用 |

### エフェクト
| 対象 | サイズ | フレーム数 |
|------|--------|-----------|
| 属性攻撃エフェクト | 32×32px〜48×48px | 4〜6F |
| ステータスエフェクト | 16×16px | 2〜4F |
| ヒット/ダメージ | 16×16px | 2F |
| レベルアップ | 画面全体 | 特殊演出 |

---

## 8.4 AI生成パイプライン

### ツールチェーン

```
[コンセプト生成]          [スプライトシート化]       [アニメーション化]
niji 7 / GPT Image      Nano Banana 2/Pro        Grok
     ↓                       ↓                      ↓
コンセプトアート          3×3グリッド（9ポーズ）    アニメーションGIF
     ↓                       ↓                      ↓
[品質チェック]           [パレット正規化]           [フレーム分割]
目視確認 + IPチェック    palette_remap.py          手動 or スクリプト
     ↓                       ↓                      ↓
                    [Godot統合]
                    AtlasTexture + SpriteFrames + AnimationPlayer
```

### ツール選定基準
| 工程 | 第一選択 | 代替 | 選定理由 |
|------|---------|------|---------|
| **コンセプト生成** | niji 7（Midjourney） | GPT Image 1.5 | ピクセルアートの品質が最も安定 |
| **スプライトシート化** | Nano Banana 2/Pro | GPT Image | 同一キャラの複数ポーズ生成に強い |
| **アニメーション化** | Grok | — | スプライトシートからの動画生成 |
| **パレット正規化** | palette_remap.py（自作） | Aseprite一括処理 | マスターパレットへの自動マッピング |
| **最終調整** | Aseprite | — | ピクセル単位の手動修正 |
| **IPチェック** | Google画像検索 + 目視 | — | 類似キャラクターの検出 |

### ツール選定の更新方針
- AI画像生成ツールは急速に進化している
- 定期的に（月1回程度）最新ツールの品質を評価
- X（Twitter）の画像生成コミュニティで最新情報を収集
- より品質の高いツールが出たら随時パイプラインに組み込む
- **ただし、パイプライン変更時は既存アセットとの一貫性を必ずチェック**

---

## 8.5 プロンプト設計

### プロンプト構造（モンスター用）

```
[共通ヘッダー]
pixel art, {sprite_size}x{sprite_size} pixels, black outline 1px,
2-tone cel shading, no anti-aliasing, no dithering, no gradients,
game boy color style, {palette_colors}

[モンスター固有]
{motif_description}, {silhouette_type}, {rank_impression},
{family_visual_cues}, {element_visual_cues}

[禁止事項]
--no realistic, no 3D, no smooth shading, no gradient,
not similar to [既知の類似キャラクター名]

[技術指定]
--ar 1:1 --niji 7
```

### プロンプトテンプレート管理
- 全モンスターのプロンプトをCSV/JSONで一元管理
- 共通部分はテンプレート化、モンスター固有部分のみ個別記述
- プロンプトのバージョン管理（生成結果の再現性確保）

### プロンプト例

#### Eランク・スライム系
```
pixel art, 24x24 pixels, black outline 1px,
2-tone cel shading, no anti-aliasing, no dithering,
game boy color style, limited palette [#306850, #86c06c, #0f380f, #000000],

a small round slime creature with simple dot eyes,
soft rounded silhouette, E-rank (simple and cute),
slime family visual cues (translucent body, droplet shape),
water element (blue tint, slight shine),

--no realistic, no 3D, no smooth shading,
--ar 1:1 --niji 7
```

#### Sランク・ドラゴン系
```
pixel art, 56x56 pixels, black outline 1px,
2-tone cel shading, no anti-aliasing, no dithering,
game boy color style, limited palette [#8b0000, #ff4500, #ffd700, #000000],

an ancient dragon emperor with multiple horns and tattered wings,
imposing asymmetric silhouette, S-rank (overwhelming and majestic),
dragon family visual cues (scales, serpentine body, fierce eyes),
dark element (shadow aura, ominous presence),
design should convey millennia of power and forbidden knowledge,

--no realistic, no 3D, no smooth shading,
--ar 1:1 --niji 7
```

---

## 8.6 品質管理プロセス

### アセットレビューフロー
```
1. AI生成（初稿）
   ↓
2. 自動チェック
   - パレット準拠チェック（palette_remap.py）
   - サイズ検証（ピクセル数）
   - 透過チェック
   ↓
3. 目視レビュー
   - シルエットの独自性
   - 同族内での差別化
   - 世界観との整合性
   - GBC美学への準拠
   ↓
4. IPチェック
   - 類似キャラクター検索
   - 商標リスク評価
   ↓
5. 手動修正（必要な場合）
   - Asepriteでピクセル調整
   - パレット手動修正
   ↓
6. Godot統合テスト
   - ゲーム内での見え方確認
   - アニメーション動作確認
   ↓
7. 承認 → approved フラグ
```

### 品質基準（Pass/Fail）
| チェック項目 | Pass条件 |
|-------------|---------|
| パレット | マスターパレット32色以内 |
| サイズ | ランクに応じた規定サイズ |
| アウトライン | 1px黒縁が全周にある |
| アンチエイリアス | 存在しない |
| シルエット | 同族内で3体以上と被らない |
| IP | 既知キャラとの類似度が低い |
| 世界観 | 設定と矛盾しない |

---

## 8.7 アセット管理

### ファイル命名規則
```
[カテゴリ]_[ID]_[用途]_[バリエーション].png

例:
monster_M001_battle_idle_01.png
monster_M001_battle_idle_02.png
monster_M001_field_walk_down_01.png
tileset_W001_forest_ground.png
ui_window_default.png
effect_fire_01.png
```

### ディレクトリ構造
```
assets/
├── sprites/
│   ├── monsters/
│   │   ├── M001/
│   │   │   ├── battle/
│   │   │   └── field/
│   │   ├── M002/
│   │   └── ...
│   ├── characters/
│   │   ├── player_male/
│   │   ├── player_female/
│   │   └── npcs/
│   ├── tilesets/
│   │   ├── W001_forest/
│   │   ├── W002_desert/
│   │   └── ...
│   ├── effects/
│   └── ui/
├── atlases/
├── animation_libraries/
│   ├── monsters/
│   ├── characters/
│   └── effects/
└── metadata/
    ├── prompts/
    └── reviews/
```

### バージョン管理方針
- 全アセットをGitで管理（Git LFS使用）
- 生成元プロンプトをメタデータとして記録
- 承認済みアセットのみmainブランチにマージ
- Godotの`.import`ファイルはGit管理に含める（再インポート防止）
