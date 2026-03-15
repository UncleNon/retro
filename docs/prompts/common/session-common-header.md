# Session Common Header

- source of truth は `docs/requirements/` と `docs/adr/`
- 実装前に対象セッションの受け入れ基準を確認する
- 無関係な改善へ広げない
- 旧Unity資産や未整理ディレクトリを勝手に破壊しない
- 便利機能は許容しても、既定値でレトロ体験を壊さない
- push はレビュー完了までしない
- 実装後は、触った source-of-truth 文書があれば同ターンで同期する

参照必須:

- `docs/plans/REQ-001-foundation-and-vertical-slice.md`
- `docs/adr/0008-core-experience-design-principles.md`
- `docs/adr/0009-story-mystery-architecture.md`
