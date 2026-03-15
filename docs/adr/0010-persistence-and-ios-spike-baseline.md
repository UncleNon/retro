# ADR-0010 Persistence And iOS Spike Baseline

- Status: Accepted
- Date: 2026-03-15

## Context

Phase 0 の Session 04 では、保存方式と iOS 配布の可否を早期に判定する必要がある。ここで必要なのは完成された本番同期基盤ではなく、Vertical Slice 以降の開発を止めない最低限の persistence baseline と、iOS export の詰まりどころを repo に残すことだった。

一方、既存ドキュメントには AES 暗号化、Keychain、CloudKit 連携など将来候補が仕様のように書かれており、現時点の実装とズレていた。

## Decision

- Session 04 の canonical save baseline は **ローカル完結の versioned JSON save** とする
- SaveSystem は `user://saves` 配下に以下を管理する
  - `slot_01..03.save.json`
  - `autosave.save.json`
  - `recovery.save.json`
  - `save_index.json`
  - `session.lock.json`
- 異常終了復帰は **stale session lock + recovery snapshot** で検知 / 復旧する
- iOS export は Session 04 では **signed export 完了** を要求せず、前提条件を検査して report 化する
- iCloud / CloudKit / Keychain / save encryption は将来候補として保持するが、**Phase 0 の成立条件から外す**

## Rationale

- まず必要なのはプレイ継続を壊さない保存導線であり、クラウド同期ではない
- 3 manual slots + autosave + recovery があれば Vertical Slice 以降の検証には十分
- iOS export は Xcode、Godot export templates、export presets、codesigning identity の前提が揃わないと進まないため、まず blockers を可視化するのが正しい
- 将来の暗号化や CloudKit を baseline に混ぜると、未実装なのに「ある前提」で設計が進んでしまう

## Consequences

- `docs/requirements/11_technical_architecture.md` は Session 04 baseline に同期する
- `tools/qa/save_smoke.py` をローカルの save smoke として使う
- `tools/qa/ios_export_smoke.py` と `export/ios/ios_export_smoke_report.*` を iOS 前提条件の証跡として使う
- iCloud を再度 v1 候補へ上げるには、local save loop 安定、export presets、templates、codesigning、CloudKit bridge 方針の再評価が必要
