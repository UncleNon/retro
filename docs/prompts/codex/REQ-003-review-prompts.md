# REQ-003 Codex Review Prompts

## Session 01 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-003 Session 01: Multi-Field Transition Baseline` のレビューをして。  
主眼は、field traversal/save が `starting_village` 固定から抜けたか、transition contract が data-driven で過剰 hardcode になっていないか、autosave reload が壊れていないか。 findings first で返すこと。

## Session 02 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-003 Session 02: W-001 Hub And Facility Pass` のレビューをして。  
主眼は、`W-001` の NPC / facility / clue loop が既存 master と整合しているか、world 固有会話が runtime hardcode に戻っていないか。 findings first で返すこと。

## Session 03 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-003 Session 03: Route Pair And Return-Ready Save Contract` のレビューをして。  
主眼は、route pair が data で追跡できるか、複数 field の save/restore が drift なく維持されるか。 findings first で返すこと。
