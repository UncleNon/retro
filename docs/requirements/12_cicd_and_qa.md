# 12. CI/CD・品質保証

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15

---

## 12.1 設計方針

> seisan-kunプロジェクトのCI/CD設計を参考に、Godot/iOSゲーム開発向けに適応。任天堂・スクエニ級の品質管理プロセスを一人開発+AI体制で実現する。

---

## 12.2 ブランチ戦略

### ブランチモデル
```
main（本番リリース用）
  ├── develop（開発統合ブランチ）
  │   ├── feat/monster-system     # 機能ブランチ
  │   ├── feat/battle-ui          # 機能ブランチ
  │   ├── fix/damage-calc         # バグ修正
  │   └── data/monster-batch-001  # データ投入
  └── release/v1.0（リリース準備）
```

### ブランチルール
| ルール | 内容 |
|--------|------|
| **main** | 直接プッシュ禁止。release or hotfixからのみマージ |
| **develop** | 日常の統合先。feature→developはPR必須 |
| **feature** | `feat/`プレフィックス。develop から切る |
| **fix** | `fix/`プレフィックス。バグ修正用 |
| **data** | `data/`プレフィックス。データ投入用 |
| **release** | `release/`プレフィックス。リリース準備 |

---

## 12.3 CI パイプライン

### GitHub Actions ワークフロー

#### ci.yml（PR・push時）
```yaml
jobs:
  # 1. コードチェック
  code-check:
    - GDScript構文チェック（godot --headless --check-only）
    - コーディング規約チェック（gdlint）
    - 静的解析（gdlint / GDScript Toolkit）

  # 2. ユニットテスト
  unit-test:
    - バトル計算テスト
    - 配合ロジックテスト
    - セーブ/ロードテスト
    - モンスターデータ整合性テスト

  # 3. データ検証
  data-validation:
    - マスターデータCSVの整合性チェック
    - 配合テーブルの循環参照チェック
    - 全モンスターの必須フィールド検証
    - テキストIDの重複チェック
    - Initial Release は日本語テキスト必須チェック
    - 英語テキストは対応フェーズ以降に欠損チェック

  # 4. アセット検証
  asset-validation:
    - スプライトサイズ検証
    - パレット準拠チェック
    - ファイル命名規則チェック

  # 5. ビルド
  build:
    - Godotプロジェクトのimport / scene load smoke
    - headless or desktop export validation
    - ビルドサイズチェック（上限300MB）

  # 6. iOSリリース検証
  ios-release-validation:
    - macOS runner 上でのみ実行
    - Godot export templates のバージョン固定確認
    - Provisioning Profile / 証明書 / App Store Connect APIキーの存在確認
    - 署名付きiOSエクスポート（release/* or manual dispatch）

  # 7. セキュリティ
  security-scan:
    - ハードコードされたシークレット検出
    - GDExtension依存の脆弱性チェック
```

#### deploy-testflight.yml（releaseブランチ）
```yaml
jobs:
  build-and-deploy:
    - macOS runner で実行
    - Godot iOS署名付きエクスポート
    - Xcodeアーカイブ / exportArchive
    - App Store Connect APIキーでアップロード
    - TestFlightアップロード
    - 通知（Slack/LINE等）
```

### iOS配布パイプラインの前提
- Apple Developer Program 加入済み
- macOS runner を利用可能
- 署名証明書、Provisioning Profile、App Store Connect APIキーを secrets で管理
- Godot export templates と Xcode バージョンを固定し、再現可能なビルド環境を維持

---

## 12.4 テスト戦略

### テストピラミッド
```
          /\
         /  \
        / E2E \          プレイテスト（手動）
       /------\
      /  統合   \        システム間連携テスト
     /----------\
    /  ユニット   \      ロジック単体テスト
   /--------------\
  / データ検証     \     マスターデータ整合性
 /------------------\
```

### ユニットテスト対象
| テスト対象 | テスト内容 |
|-----------|-----------|
| **DamageCalculator** | 物理/魔法ダメージ計算、会心、属性倍率 |
| **BreedingSystem** | 家系配合、特殊配合、変異確率、ステータス継承 |
| **MonsterInstance** | レベルアップ、経験値計算、スキルポイント |
| **SaveSystem** | シリアライズ/デシリアライズ、暗号化/復号 |
| **TournamentManager** | ランク進行、レベル上限判定 |
| **DungeonGenerator** | マップ生成の有効性（到達可能性） |
| **BattleManager** | 行動順決定、逃走判定、勝敗判定 |
| **ScoutSystem** | スカウト成功率計算 |

※テストフレームワーク: **GdUnit4**（Godot用ユニットテストフレームワーク）

### 統合テスト対象
| テスト対象 | テスト内容 |
|-----------|-----------|
| **バトル→経験値→レベルアップ** | 一連のフロー |
| **配合→新モンスター→スキル継承** | 配合の全体フロー |
| **セーブ→ロード→状態復元** | データの完全な往復 |
| **シーン遷移→状態保持** | シーン間でのデータ保持 |

### データ検証テスト
| テスト対象 | テスト内容 |
|-----------|-----------|
| **モンスターマスター** | 対象フェーズの全モンスターの必須フィールド、ステータス範囲、ID重複 |
| **配合テーブル** | 全レシピの参照先存在確認、無限ループ検出 |
| **テキスト** | 全テキストIDの存在・日本語完備、変数置換の整合性 |
| **スキルツリー** | 全スキルの参照先存在確認 |
| **世界定義** | 全世界のモンスター出現テーブルの存在確認 |

### プレイテスト
- 全ストーリーの通しプレイ
- 各世界のバランスチェック
- 配合ルートの実現可能性検証
- 操作感・テンポのチェック
- 難易度の適正確認

---

## 12.5 品質ゲート

### マージ条件（develop → main）
- [ ] 全ユニットテスト合格
- [ ] 全データ検証合格
- [ ] 全アセット検証合格
- [ ] ビルド成功
- [ ] セキュリティスキャン合格
- [ ] プレイテスト合格（リリース時のみ）

### リリース条件（TestFlight配布）
- [ ] 上記全て合格
- [ ] 通しプレイテスト完了
- [ ] Initial Release は日本語テキスト確認
- [ ] 英語対応フェーズ以降はローカライズ確認
- [ ] iCloud同期動作確認（採用時のみ）
- [ ] パフォーマンスプロファイリング合格

---

## 12.6 バグトラッキング

### 管理方法
- GitHub Issues を使用
- ラベルで分類: `bug`, `feature`, `data`, `balance`, `asset`
- 優先度: `P0`(ブロッカー), `P1`(高), `P2`(中), `P3`(低)
- マイルストーンとリンク

### バグレポートテンプレート
```markdown
## 概要
（何が起きるか）

## 再現手順
1. ...
2. ...

## 期待される動作
（正しくはどうなるべきか）

## 実際の動作
（実際に何が起きたか）

## 環境
- iOS:
- デバイス:
- ビルド:

## スクリーンショット/動画
```

---

## 12.7 リリースプロセス

### リリースフロー
```
1. develop の全テスト合格を確認
2. release/vX.Y ブランチを切る
3. リリースノート作成
4. 最終プレイテスト
5. main にマージ
6. タグ付け（vX.Y.Z）
7. CI/CD → TestFlight自動デプロイ
8. TestFlightで最終確認
9. App Store審査提出
```

### バージョニング
- セマンティックバージョニング（MAJOR.MINOR.PATCH）
- MAJOR: 大型アップデート
- MINOR: 新コンテンツ・機能追加
- PATCH: バグ修正・バランス調整
