# REQ-001 Codex Review Prompts

## Session 01 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-001 Session 01: Canonical Repo And Godot Shell` のレビューをして。  
主眼は、実装先の canonical path が固定されたか、旧Unity系との混線が残っていないか、source-of-truth 文書が stale でないか。  
 findings first で返すこと。

## Session 02 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-001 Session 02: Tooling And CI Baseline` のレビューをして。  
主眼は、lint / format / test / CI が最小でも実用ラインにあるか、将来の Godot 実装を支えられるか。 findings first で返すこと。

## Session 03 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-001 Session 03: Data Pipeline Foundation` のレビューをして。  
主眼は、CSV → Resource が本当に量産前提になっているか、参照整合性が壊れにくいか、10体のサンプルが後戻りしにくい形で作られているか。 findings first で返すこと。

## Session 04 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-001 Session 04: Persistence And Platform Spike` のレビューをして。  
主眼は、セーブ破損や復帰失敗のリスク、iOS export 判定材料の不足、iCloud の扱いが premature になっていないか。 findings first で返すこと。

## Session 05 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-001 Session 05: Field Foundation` のレビューをして。  
主眼は、160×144 / 整数スケール / 4方向移動 / 村と塔の導線が壊れていないか、初期印象が requirements とズレていないか。 findings first で返すこと。

## Session 06 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-001 Session 06: Battle Foundation` のレビューをして。  
主眼は、4コマンド + 作戦AI の文法が守られているか、手入力戦闘へ逆戻りしていないか、数値中心 UI が崩れていないか。 findings first で返すこと。

## Session 07 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-001 Session 07: Recruitment, Inventory, Ranch` のレビューをして。  
主眼は、所持制限が不便で終わらず選択圧になっているか、勧誘が数値露出しすぎていないか、大事な個体を保護できるか。 findings first で返すこと。

## Session 08 Review

`docs/prompts/common/session-common-header.md` を先に読むこと。  
`REQ-001 Session 08: Breeding And Vertical Slice Assembly` のレビューをして。  
主眼は、配合がこの企画の芯として成立しているか、未発見レシピの情報出しが過剰でないか、Vertical Slice が 5〜15分で企画の魅力を伝えられるか。 findings first で返すこと。
