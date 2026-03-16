# REQ-003 Claude Implementation Prompts

## Session 01

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-003 Session 01: Multi-Field Transition Baseline` を実装して。  
source of truth は `docs/plans/REQ-003-act-i-field-expansion-and-world-routing.md`。  
目的は、single-field 前提を壊し、`FIELD-VIL-001 -> FIELD-W01-001 -> FIELD-VIL-001` の往復を runtime/save で成立させること。field interaction に transition payload を追加し、autosave reload まで壊さないこと。push はしない。

## Session 02

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-003 Session 02: W-001 Hub And Facility Pass` を実装して。  
`W-001` の最小 hub を既存 `npc/shop/service/clue` master に接続し、merchant / healer / talk / clue loop を増やす。world 固有の story text を app_root へ埋め戻さないこと。push はしない。

## Session 03

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-003 Session 03: Route Pair And Return-Ready Save Contract` を実装して。  
`W-001` に route pair を足し、field snapshot/save contract を 2 field 超でも安定させる。safe route / danger route の違いが data で追えるようにすること。push はしない。
