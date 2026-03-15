# 13. 開発フロー・プロジェクト管理

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15

---

## 13.1 開発体制

| 役割 | 担当 |
|------|------|
| **プロジェクトオーナー** | UncleNon |
| **コード実装** | UncleNon + AI（Claude Code, Codex） |
| **設計・アーキテクチャ** | UncleNon + AI |
| **アセット生成** | AI（niji 7, Nano Banana, Grok, GPT, etc.） |
| **サウンド生成** | AI（Suno, Udio等） |
| **テキスト生成** | AI（Claude, GPT） |
| **品質管理** | 自動テスト + UncleNon |
| **役割分担の最終判断** | UncleNon |

---

## 13.2 マイルストーン計画

### Phase 0: 基盤整備
- [x] リポジトリ構造整理
- [x] `docs/requirements/` を source of truth に固定し、`docs/design/` をアーカイブ扱いにする
- [x] CI/CDパイプライン構築（baseline）
- [x] Godot 4.4 プロジェクトセットアップ（ネイティブ2D, Pixel Perfect設定）
- [x] エディタプラグイン（CSVインポーター）作成
- [x] 共通基盤システム実装（GameManager, SaveSystem, AudioManager, InputManager）
- [ ] GdUnit4テストフレームワーク導入（実テスト追加前の本統合）
- [x] Git LFS設定
- [x] `retro-claude/tools/palette-remap/` を repo-root の `tools/palette-remap/` に移設
- [x] iOSエクスポート前提条件の技術スパイク（blocked report 生成まで）
- [x] ローカルセーブ / オートセーブ / 異常終了復帰の技術スパイク
- [ ] iCloud連携用GDExtension調査・プロトタイプ

### Phase 1: コアループ実証（Vertical Slice）
- [ ] モンスター10体分のデータ作成
- [ ] バトルシステム（3v3、UIまで）
- [ ] 配合システム（基本配合、UIまで）
- [x] フィールド移動（1マップ）
- [ ] エンカウント→バトル→勝利の一連のフロー
- [x] 仮アセット（プレースホルダー）で動作確認
- [ ] **成果物: 「5分間遊べるプロトタイプ」**

### Phase Gate: 初回リリーススコープ確定
- [ ] Vertical Slice の実装速度から、1世界あたりの実コストを見積もる
- [ ] iOS配布、保存、iCloudの技術リスクを再評価する
- [ ] 初回リリースの最終言語対応範囲を確定する
- [ ] MVP（5世界 / 30体）の実績を踏まえ、本番リリースの規模を確定する
- [ ] 初回リリースは日本語先行で出すことを前提に、英語対応は後続フェーズへ分離する

### Phase 2: 世界観・データ設計
- [x] 世界の詳細設計（21 mainline worlds + `W-022+` reserved deep regions の定義書作成）
- [x] 歴史年表の詳細化
- [ ] モンスター400体の設計（データ定義・配合テーブル）
- [x] ストーリープロット策定
- [ ] NPC設計
- [ ] アイテム・スキル設計
- [ ] **成果物: 完全な設計ドキュメント群**

注記:

- `docs/specs/worlds/09〜13`, `docs/specs/story/01〜10` により、Initial Release を支える world / story / history の canonical baseline は作成済み
- ここで未完了として残しているのは、400体の個票、全世界分の NPC 実表、後半 item / skill / loot の完全 roster など、量産と実データ化の層

### Phase 3: コンテンツ実装・前半
- [ ] 世界1〜10の実装（マップ、ダンジョン、NPC、イベント）
- [ ] モンスター200体のアセット生成・統合
- [ ] メインストーリー前半
- [ ] トーナメントG〜Dランク
- [ ] UI全画面実装
- [ ] サウンド前半

### Phase 4: コンテンツ実装・後半
- [ ] 世界11〜21の実装
- [ ] モンスター残り200体のアセット生成・統合
- [ ] メインストーリー後半
- [ ] トーナメントC〜スターフォール
- [ ] サウンド後半
- [ ] Initial Release 時点でメインストーリーが完結していることを確認

### Phase 5: エンドコンテンツ
- [ ] 裏ストーリー実装
- [ ] 裏ダンジョン群
- [ ] 裏ボス
- [ ] 高難度トーナメント
- [ ] 無限ダンジョン
- [ ] 変異種システム最終調整
- [ ] Initial Release に必要なエンドコンテンツの完成確認

### Phase 6: ローカライズ・ポリッシュ
- [ ] 全テキストの英語翻訳
- [ ] バランス調整
- [ ] パフォーマンス最適化
- [ ] バグ修正
- [ ] 通しプレイテスト
- [ ] iCloud同期最終テスト（採用時のみ）

### Phase 7: リリース準備
- [ ] App Store素材作成（スクリーンショット、説明文、アイコン）
- [ ] プライバシーポリシー
- [ ] TestFlight配布・最終テスト
- [ ] App Store審査提出

---

## 13.3 開発の進め方

### 日常の開発フロー
```
1. `docs/plans/REQ-xxx...` と `REQ-xxx-progress.md` で対象セッションを確認
2. セッション境界と受け入れ基準を確認
3. 実装（必要なら short-lived branch）
4. `tools/qa/` と `tools/data/build_resources.py --check` でローカル確認
5. 触った source-of-truth 文書を同ターンで同期
6. review handoff を作る
7. レビュー後にコミット・プッシュ
```

Session 04 以降のローカル最低確認:

- `python tools/qa/lint.py`
- `python tools/qa/format.py --check`
- `python tools/data/build_resources.py --check`
- `python tools/qa/test.py`
- `python tools/qa/godot_smoke.py`
- `python tools/qa/save_smoke.py`
- `python tools/qa/field_smoke.py`
- `python tools/qa/ios_export_smoke.py`

### ADR（Architecture Decision Records）
- 重要な設計判断はADRとして文書化
- `docs/adr/NNN-title.md` に記録
- seisan-kunと同じフォーマット: Context → Decision → Rationale

### タスク管理
- GitHub Issues + GitHub Projects
- ラベル体系:
  - `phase/0` 〜 `phase/7`: フェーズ
  - `type/feature`, `type/bug`, `type/data`, `type/asset`, `type/doc`: 種別
  - `priority/P0` 〜 `priority/P3`: 優先度
  - `status/todo`, `status/in-progress`, `status/review`, `status/done`: 状態

---

## 13.4 ドキュメント管理

### ドキュメント構成
```
docs/
├── requirements/      # 要件定義書（本書）
├── adr/               # 設計判断記録
├── specs/             # 数値設計、マスタースキーマ、レイアウト、初期コンテンツ詳細
├── plans/             # セッション計画、進捗管理、REQごとの実行計画
├── prompts/           # 実装 / レビュー / アセット生成 prompt pack
│   ├── common/        # 共通ヘッダー
│   ├── claude/        # 実装用
│   └── codex/         # レビュー用
└── design/            # 旧案アーカイブ（現行設計の source of truth ではない）
```

### ドキュメント更新ルール
- コードの変更に伴う仕様変更はドキュメントも同時に更新
- Source of Truth同期チェック（seisan-kun方式）
- ドキュメントのレビューはPRと一緒に
- 現行設計は `docs/requirements/` と `docs/adr/` を基準にし、`docs/design/` は参照専用アーカイブとして扱う
- 実装順と完了状態は `docs/plans/REQ-001-progress.md` を更新して追う

---

## 13.5 コーディング規約

### GDScript コーディング規約
| 項目 | ルール |
|------|--------|
| **命名** | snake_case（変数、関数）、PascalCase（クラス名、列挙型） |
| **ファイル名** | snake_case（例: `battle_manager.gd`） |
| **コメント** | 自明なコードにはコメント不要。WHYのみコメント |
| **マジックナンバー** | 禁止。定数化 or Resource化 |
| **ハードコード** | データのハードコード禁止。全てデータ駆動 |
| **型ヒント** | 可能な限り型ヒントを使用（`var hp: int = 100`） |
| **Signal** | 過去形で命名（`monster_defeated`, `level_up_completed`） |

### gdlint / GDScript Toolkit
- gdformat でコード整形
- gdlint でリントチェック
- CIで自動実行

---

## 13.6 Git運用

### コミットメッセージ規約
```
<type>(<scope>): <subject>

<body>

Co-Authored-By: ...
```

| type | 用途 |
|------|------|
| feat | 新機能 |
| fix | バグ修正 |
| data | データ追加・修正 |
| asset | アセット追加・修正 |
| docs | ドキュメント |
| test | テスト |
| refactor | リファクタ |
| ci | CI/CD |
| chore | その他 |

### Git LFS
- 対象: `.png`, `.wav`, `.ogg`, `.psd`, `.aseprite`
- `.gitattributes` で設定
