# REQ-002 Codex Review Prompts

## Session 01 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-002 Session 01: Pipeline Recovery And Drift Freeze` のレビューをして。  
主眼は、data pipeline が現行 CSV と整合したか、test が stale count を固定し続けていないか、generated resources の drift が解消されたか。 findings first で返すこと。

## Session 02 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-002 Session 02: Registry, Gate, And Clue Master Baseline` のレビューをして。  
主眼は、registry / gate / clue の authority が repo 上に materialize されたか、自由記述のまま残る参照が危険でないか。 findings first で返すこと。

## Session 03 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-002 Session 03: Economy, NPC, And Alias Contracts` のレビューをして。  
主眼は、`shop` / `service` / `loot` / alias 契約が specs と一致しているか、legacy alias が runtime canonical ID へ漏れていないか。 findings first で返すこと。

## Session 04 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-002 Session 04: Runtime Content Repository And Save Wiring` のレビューをして。  
主眼は、repository boot が fail-fast できるか、直接 resource path 参照が散らばっていないか、save と progress contract が噛み合っているか。 findings first で返すこと。

## Session 05 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-002 Session 05: Data-Driven Starting Arc Field` のレビューをして。  
主眼は、field が data-driven へ十分に移ったか、story fact や進行条件が hardcoded 分岐へ戻っていないか、field smoke が要求を満たしているか。 findings first で返すこと。

## Session 06 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-002 Session 06: Battle Foundation And Encounter Transition` のレビューをして。  
主眼は、4コマンド文法と作戦AIが守られているか、encounter data と battle runtime が自然につながっているか、後戻りしにくい battle core になっているか。 findings first で返すこと。

## Session 07 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-002 Session 07: Recruit, Inventory, Ranch, Shop, And Codex` のレビューをして。  
主眼は、20枠制限が選択圧として機能しているか、recruit / ranch / shop / codex が save と破綻なく接続されているか。 findings first で返すこと。

## Session 08 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-002 Session 08: Breeding, QA Hardening, And iOS Export Scaffolding` のレビューをして。  
主眼は、breeding が data contract に基づいて成立しているか、QA が drift を防げるか、iOS export scaffolding が次の blocker まで進んでいるか。 findings first で返すこと。
