# REQ-002 Claude Implementation Prompts

## Session 01

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-002 Session 01: Pipeline Recovery And Drift Freeze` を実装して。  
source of truth は `docs/plans/REQ-002-data-contracts-and-runtime-integration.md`。  
目的は、`build_resources` / Python test / generated resources の drift を解消し、後続 session の前提を安定させること。`snow` weather 対応、stale count test の更新、manifest / resources 再生成まで含める。push はしない。

## Session 02

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-002 Session 02: Registry, Gate, And Clue Master Baseline` を実装して。  
必須 registry と `clue` / `gate` master を repo に materialize し、自由記述の門条件を structured data へ寄せる。validator で欠損や参照切れを fail にすること。push はしない。

## Session 03

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-002 Session 03: Economy, NPC, And Alias Contracts` を実装して。  
`shop` / `service` / `loot` / `alias` 系 master を追加し、`npc_master` と `monster_master` の参照を実体へ接続する。runtime canonical ID と legacy alias を混同しないこと。push はしない。

## Session 04

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-002 Session 04: Runtime Content Repository And Save Wiring` を実装して。  
app boot から content repository を初期化し、monster / skill / item / world / encounter / npc / shop / gate / clue を lookup できる状態へ進める。save progress と repository の接続まで含める。push はしない。

## Session 05

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-002 Session 05: Data-Driven Starting Arc Field` を実装して。  
開始村〜塔前の layout, NPC, inspect, encounter, clue, gate reaction を hardcode から data-driven に置き換える。field smoke を壊さず、story fact を GDScript に埋め戻さないこと。push はしない。

## Session 06

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-002 Session 06: Battle Foundation And Encounter Transition` を実装して。  
encounter data から battle を起動し、4コマンド、作戦AI、skill / item / status の最小成立まで進める。field から battle への遷移と復帰を成立させること。push はしない。

## Session 07

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-002 Session 07: Recruit, Inventory, Ranch, Shop, And Codex` を実装して。  
recruit item、carry 20、party 3、ranch、favorite lock、shop / service UI、codex / clue log を current data contract に接続する。数値を出しすぎる recruit UI にはしないこと。push はしない。

## Session 08

`docs/prompts/common/session-common-header.md` を先に読むこと。

`REQ-002 Session 08: Breeding, QA Hardening, And iOS Export Scaffolding` を実装して。  
breed rule に基づく配合 loop、hint UI、QA 拡張、GdUnit4 実 test、`export_presets.cfg` と iOS export scaffolding を追加する。署名済み配布までは求めないが、repo の足場は揃えること。push はしない。
