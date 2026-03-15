# 12. CI/CD・品質保証

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15

---

## 12.1 設計方針

> seisan-kunプロジェクトのCI/CD設計を参考に、Godot/iOSゲーム開発向けに適応。任天堂・スクエニ級の品質管理プロセスを一人開発+AI体制で実現する。

---

## 12.2 ブランチ戦略

### 現在の運用
```
main（canonical branch）
  ├── feat/*
  ├── fix/*
  ├── data/*
  └── session/*
```

### ブランチルール
| ルール | 内容 |
|--------|------|
| **main** | source of truth。長期ブランチは増やしすぎない |
| **feat** | 機能実装用。必要時のみ切る |
| **fix** | バグ修正用 |
| **data** | データ投入 / 生成物更新用 |
| **session** | `REQ-xxx Session N` の分割実装用 |

- `develop` 常設は、複数人並行や release cadence が必要になってから導入する
- 現段階では `main + short-lived branch` を正とする

---

## 12.3 CI パイプライン

### GitHub Actions ワークフロー

#### 現在の `ci.yml` baseline
```yaml
jobs:
  baseline:
    - checkout（LFS有効）
    - setup-python 3.11
    - pip install gdtoolkit
    - python tools/qa/lint.py
    - python tools/qa/format.py --check
    - python tools/data/build_resources.py --check
    - python tools/qa/test.py
    - python tools/qa/godot_smoke.py --allow-missing
```

### baseline の意味
- Session 02 時点の最小品質ゲートを先に固定する
- `gdlint`, `gdformat`, `data build`, Python unit test, Godot smoke の入口を用意する
- CI runner 上の Godot 本体導入は、現時点では optional 扱いで `--allow-missing` を使う

### 今後追加するジョブ
- GdUnit4 による Godot 側ユニットテスト
- scene load / save-load / battle loop 統合テスト
- asset registry / localization validator
- iOS export smoke
- release / TestFlight deploy

#### deploy-testflight.yml（tag push / optional release branch）
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

※テストフレームワーク:
- Session 02 時点の実働: Python `unittest` でデータパイプラインを検証
- Godot 側の正式なユニットテスト基盤は **GdUnit4** を採用予定とし、`tests/gdunit/` を canonical 受け皿にする

### 統合テスト対象
| テスト対象 | テスト内容 |
|-----------|-----------|
| **バトル→経験値→レベルアップ** | 一連のフロー |
| **配合→新モンスター→スキル継承** | 配合の全体フロー |
| **セーブ→ロード→状態復元** | manual / autosave / recovery の往復 |
| **シーン遷移→状態保持** | シーン間でのデータ保持 |

### Session 04 で追加した smoke
| コマンド | 役割 |
|---------|------|
| `python tools/qa/save_smoke.py` | SaveSystem の manual / autosave / dirty shutdown recovery を headless Godot で確認 |
| `python tools/qa/ios_export_smoke.py` | iOS export の前提条件を検査し、`export/ios/` に report を出力 |

### Session 05 で追加した smoke
| コマンド | 役割 |
|---------|------|
| `python tools/qa/field_smoke.py` | 開始村から塔前荒地までの移動、調査、遭遇導線を headless Godot で確認 |

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

### マージ条件（現時点）
- [ ] `python tools/qa/lint.py` 合格
- [ ] `python tools/qa/format.py --check` 合格
- [ ] `python tools/data/build_resources.py --check` 合格
- [ ] `python tools/qa/test.py` 合格
- [ ] `python tools/qa/godot_smoke.py` がローカルでは合格、CI では少なくとも fail-safe に動く
- [ ] `python tools/qa/save_smoke.py` がローカルで合格
- [ ] `python tools/qa/field_smoke.py` がローカルで合格
- [ ] `python tools/qa/ios_export_smoke.py` が report を生成し、blocker が可視化されている

### 将来のマージ条件（拡張後）
- [ ] GdUnit4 テスト合格
- [ ] 全データ検証合格
- [ ] 全アセット検証合格
- [ ] ビルド成功
- [ ] iOS export smoke が blocker なし
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
1. releasable commit（通常は `main`、必要なら short-lived `release/*`）の全テスト合格を確認
2. 必要な場合のみ `release/vX.Y.Z` の凍結ブランチを切る
3. リリースノート作成
4. 最終プレイテスト
5. 配布対象 commit にタグ付け（`vX.Y.Z`）
6. CI/CD → tag build から TestFlight 自動デプロイ
7. TestFlight で最終確認
8. optional release branch を使った場合のみ `main` へ戻す
9. App Store 審査提出
```

### バージョニング
- セマンティックバージョニング（MAJOR.MINOR.PATCH）
- MAJOR: 大型アップデート
- MINOR: 新コンテンツ・機能追加
- PATCH: バグ修正・バランス調整
