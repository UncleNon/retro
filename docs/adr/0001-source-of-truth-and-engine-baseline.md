# ADR-0001 Source of Truth and Engine Baseline

- Status: Accepted
- Date: 2026-03-15

## Context

`docs/design/` と `docs/requirements/` が競合しており、前者は Unity 前提、後者は Godot 前提になっていた。さらに、iCloud同期はドキュメント上では確定仕様に見える一方、実装可否は未検証だった。

## Decision

- 現行の source of truth は `docs/requirements/` とする
- `docs/design/` は旧設計アーカイブとして残し、今後の更新対象から外す
- エンジンの基準は Godot 4.4 とする
- セーブの基準線はローカルセーブとし、iCloud同期は Phase 0 の技術スパイク結果で採否を判定する

## Rationale

- 実装前に canonical doc を一本化しないと、以後の設計判断が分岐して破綻する
- Godot 4.4 は本企画の 2D / pixel-perfect 要件に合致している
- iCloud は価値がある一方で、GDExtension と iOS連携の検証が未了なため、ゲーム本編の成立条件からは切り離すべき

## Consequences

- 新しい計画、実装、レビューは `docs/requirements/` を参照する
- `docs/design/` は参照してもよいが、仕様確定の根拠にはしない
- Phase 0 で iOS配布、ローカル保存、iCloud の技術リスクを先に潰す
