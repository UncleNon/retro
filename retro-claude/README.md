> **Archived**: このディレクトリは旧Unity設計のアーカイブ。現行の source of truth は `docs/requirements/`。

# Monster Chronicle（モンスタークロニクル）

DQMリスペクト × GBドット絵 × モバイルRPG

## 概要

ゲームボーイカラー時代のドット絵クオリティを完全再現した、モンスター育成・配合RPG。
「配合」「育成」「トーナメント」を三本柱とし、レトロ感と現代モバイルUXを両立。

## 技術スタック

| 項目 | 内容 |
|------|------|
| エンジン | Unity 6 LTS (C#) |
| レンダリング | URP 2D + 2D Pixel Perfect |
| 解像度 | 160×144px (GBC準拠) |
| プラットフォーム | iOS / Android |
| アート | GBC風ドット絵 (32色パレット) |

## プロジェクト構成

```
monster-chronicle/
├── docs/                    設計ドキュメント
│   ├── requirements.docx    要件定義書
│   ├── style-bible.md       アートスタイル規約
│   ├── monster-list.csv     モンスターマスターデータ
│   ├── breeding-table.csv   配合テーブル
│   └── prompts/             AI生成プロンプト集
├── Assets/                  Unity プロジェクト
│   ├── Scripts/             C# スクリプト
│   ├── ScriptableObjects/   モンスターデータ等
│   ├── Sprites/             ドット絵アセット
│   ├── Audio/               BGM / SE
│   ├── Tilemaps/            タイルマップ
│   ├── Prefabs/             プレハブ
│   ├── Fonts/               ドット絵フォント
│   └── Scenes/              シーン
└── tools/                   開発支援ツール
    └── palette-remap/       パレット正規化スクリプト
```

## セットアップ

1. Unity Hub で Unity 6 LTS をインストール
2. 新規 2D (URP) プロジェクト作成
3. Package Manager から `2D Pixel Perfect` をインストール
4. 本リポの `Assets/` 以下を Unity プロジェクトの `Assets/` にコピー
5. `docs/` と `tools/` はプロジェクトルートに配置

## AI アセット生成ワークフロー

詳細は `docs/style-bible.md` と `docs/prompts/` を参照。

1. **パレット確定** → Lospec から GBC 互換パレット選定
2. **リファレンス手描き** → Aseprite で主要スプライト作成
3. **AI バッチ生成** → PixelLab + GPT-4o でバッチ生成
4. **パレット正規化** → `tools/palette-remap/` で全アセット統一
5. **手動補正** → Aseprite でアウトライン・ミクセル修正

## 開発フロー

- `main` ブランチ: リリース用
- `develop` ブランチ: 開発統合
- `feature/*` ブランチ: 機能開発
