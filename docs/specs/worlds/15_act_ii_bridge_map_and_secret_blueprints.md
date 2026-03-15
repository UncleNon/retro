# 15. Act II Bridge Map And Secret Blueprints

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16
> **役割**: `W-006〜W-007` の map topology, runtime zone, hidden pocket, revisit payoff を concrete blueprint として固定する
> **参照元**:
> - `docs/specs/worlds/10_act_ii_world_sheets.md`
> - `docs/specs/story/13_act_ii_bridge_relationship_and_faction_map.md`
> - `docs/specs/story/14_cross_system_echo_and_discovery_lattice.md`
> - `docs/specs/content/09_act_i_ii_monster_expansion_and_discovery_pack.md`
> - `docs/specs/systems/17_encounter_authoring_and_balance_sandbox.md`

---

## 1. 目的

- `W-006〜W-007` を `world sheet はあるが、runtime zone と hidden の噛み合わせが曖昧` な状態から抜ける
- `W-005` の grief loop から `W-007` の role-name market へ、map 体験の側でも連続性を作る
- hidden を shortcut より先に **制度の運用証拠** として置く

---

## 2. `W-006` 鈴結びの湿地

### 2.1 runtime zone mapping

| zone_id | maps | beat | local pressure |
|---------|------|------|----------------|
| `ZONE-W06-BRIDGE` | `MAP-W06-001`, `MAP-W06-003` | arrival / settlement lane | 戸口縄と橋脚刻みが belonging を先に決める |
| `ZONE-W06-VILLAGE` | `MAP-W06-002`, `MAP-W06-004` | hub / clue pocket | 徴縄と家結びの実務が visible になる |
| `ZONE-W06-SHRINE` | `MAP-W06-008` | boss approach | 正式慰撫と保留処理が同じ祭具で回る |
| `ZONE-W06-BOG` | `MAP-W06-006`, `MAP-W06-007`, `MAP-W06-009` | danger / hidden | 借り鈴と余り結びが黒水域へ流れ込む |

### 2.2 map roster

| map_id | 名称 | size | 役割 |
|--------|------|------|------|
| `MAP-W06-001` | 結縄の門洲 | `44 x 28` | arrival gate |
| `MAP-W06-002` | 鈴泊浮き床 | `72 x 36` | hub |
| `MAP-W06-003` | 戸口縄桟路 | `40 x 28` | settlement lane |
| `MAP-W06-004` | 税縄棚 | `48 x 30` | clue pocket |
| `MAP-W06-005` | 葦結び外縁 | `60 x 36` | safe route |
| `MAP-W06-006` | 借り鈴筏場 | `52 x 32` | danger route |
| `MAP-W06-007` | ほどけ沼 | `48 x 34` | blackwater pocket |
| `MAP-W06-008` | 沈み社 | `40 x 32` | boss approach |
| `MAP-W06-009` | 古符橋脚 | `26 x 20` | hidden overlook |

### 2.3 route pair

| route | maps | 体験 |
|-------|------|------|
| `main route` | `001 -> 002 -> 003 -> 004 -> 008` | 戸口縄と徴縄実務を正面から見て沈み社へ進む |
| `safe route` | `002 -> 005 -> 008` | 遠回りだが湿地圧が低く、`余り結び` 圧縮の証拠は薄い |
| `danger route` | `003 -> 006 -> 009 -> 007 -> 008` | 借り鈴, 古符号, 保留者処理の本音が濃い |

### 2.4 hidden pockets

| secret_id | 種別 | 場所 | trigger | reward |
|-----------|------|------|---------|--------|
| `SEC-W06-01` | inspect | `税縄棚` | 同じ結び数の袋を 3 つ照合する | 家印を削った `余り結び` まとめ袋 |
| `SEC-W06-02` | route | `借り鈴筏場` | 休まず夜に舟杭の鈴順を追う | 符号彫りのない借り鈴束 |
| `SEC-W06-03` | inspect | `古符橋脚` | 夕方の引き水時だけ橋脚刻みを読める | 人名を削って符号へ彫り直した古刻み |
| `SEC-W06-04` | encounter | `ほどけ沼` | `符号なし新鈴` を見た後に再訪 | 同じ音色で鳴る借り鈴の送り列 |

### 2.5 clear 後 state shift

- `税縄棚` の外に `余り` 用の小棚が増え、一本だけ色違いの戸口縄を隠さない家が出る
- `借り鈴筏場` は閉鎖されず `仮慰撫` の名で半公認化され、隠し運用が整え直される

---

## 3. `W-007` 削名の階市

### 3.1 runtime zone mapping

| zone_id | maps | beat | local pressure |
|---------|------|------|----------------|
| `ZONE-W07-BRIDGE` | `MAP-W07-001`, `MAP-W07-003` | arrival / ascent | 橋を渡った時点で role-name economy が始まる |
| `ZONE-W07-WORKSHOP` | `MAP-W07-002`, `MAP-W07-004` | lower hub / clue workshop | badge 刻みと一夜階位章の売買が visible になる |
| `ZONE-W07-HALL` | `MAP-W07-007`, `MAP-W07-008`, `MAP-W07-009` | mid hub / archive | 祖棚と役名棚が同じ inventory logic で回る |
| `ZONE-W07-UPPER` | `MAP-W07-010`, `MAP-W07-011`, `MAP-W07-012` | boss / upper tier | 上へ行くほど role が人名より先に処理される |

### 3.2 map roster

| map_id | 名称 | size | 役割 |
|--------|------|------|------|
| `MAP-W07-001` | 下札橋 | `48 x 28` | arrival gate |
| `MAP-W07-002` | 三十段下市 | `72 x 36` | lower hub |
| `MAP-W07-003` | 荷役坂 | `56 x 32` | main ascent |
| `MAP-W07-004` | 役名工房 | `40 x 28` | clue workshop |
| `MAP-W07-005` | 代書横路 | `44 x 26` | safe detour |
| `MAP-W07-006` | 借り章の石段 | `48 x 30` | danger route |
| `MAP-W07-007` | 十七段中市 | `64 x 34` | mid hub |
| `MAP-W07-008` | 祖棚廊 | `56 x 32` | clue pocket |
| `MAP-W07-009` | 棚位裏庫 | `30 x 24` | hidden archive |
| `MAP-W07-010` | 検刻関段 | `44 x 28` | boss approach |
| `MAP-W07-011` | 空階の上段 | `50 x 32` | final high tier |
| `MAP-W07-012` | 落名見晴らし | `26 x 20` | post-clear overlook |

### 3.3 route pair

| route | maps | 体験 |
|-------|------|------|
| `main route` | `001 -> 002 -> 003 -> 004 -> 007 -> 008 -> 010 -> 011` | 公式の役名取得と棚位運用を正面から登る |
| `safe route` | `004 -> 005 -> 007 -> 010` | 荷役階段を回る遠回り。消耗は軽いが死者役名の痕は薄い |
| `danger route` | `003 -> 006 -> 009 -> 008 -> 011` | 借り役名, 空き slot 売り, 二重 badge の証拠が濃い |

### 3.4 hidden pockets

| secret_id | 種別 | 場所 | trigger | reward |
|-----------|------|------|---------|--------|
| `SEC-W07-01` | inspect | `役名工房` | 削り粉箱と廃 badge を 2 組照合する | 死者役名の彫り直し見本片 |
| `SEC-W07-02` | route | `借り章の石段` | 階位章を買わず運び人列に紛れて登る | 一夜階位章の包みと返却札 |
| `SEC-W07-03` | inspect | `棚位裏庫` | 先祖棚裏の控え帳を読む | 祖棚と役名棚を同じ帳面で管理した控え |
| `SEC-W07-04` | encounter | `三十段下市` 夜再訪 | `棚位裏庫` の証拠入手後 | 死者役名の競りと、本名欄だけ削られた借り役名札 |

### 3.5 clear 後 state shift

- `F -> E` の暫定解放で `検刻関段` に下層向け lane が一本増え、`十七段中市` までの往来が少しだけ混ざる
- `祖棚廊` は先祖棚と役名棚を色分けするが、貸し借り自体は別帳面で続き `整理` として吸収される

---

## 4. Secret Ledger

| secret_id | world | reward type | 主 reward | clue 接続 |
|-----------|-------|-------------|-----------|-----------|
| `SEC-W06-01` | `W-006` | evidence | `余り結び` まとめ袋 | `CL-019` を補強 |
| `SEC-W06-02` | `W-006` | logistics proof | 符号なし借り鈴束 | `CL-020` を補強 |
| `SEC-W06-03` | `W-006` | archive | 古符橋脚の削り直し刻み | `CL-019`, `CL-020` を接続 |
| `SEC-W07-01` | `W-007` | material proof | 死者役名の彫り直し見本片 | `CL-021` を補強 |
| `SEC-W07-02` | `W-007` | market proof | 一夜階位章の包み | `CL-021` を補強 |
| `SEC-W07-03` | `W-007` | ledger | 棚位裏庫の控え帳 | `CL-022` を補強 |
| `SEC-W07-04` | `W-007` | emotional residue | 本名欄だけ削られた借り役名札 | `CL-021`, `CL-022` を結ぶ |

## 5. Ambient Echo Ledger

| world | place | echo seed | delayed payoff |
|-------|-------|-----------|----------------|
| `W-006` | `税縄棚` | 色替え縄の返し順が空家封じ紐と同じ | `CL-059` |
| `W-006` | `古符橋脚` | 人名から符号への削り直しが露骨に残る | `CL-060` |
| `W-007` | `役名工房` | 鍵札と badge の切り屑が同じ箱へ落ちる | `ECH-MON-03` |
| `W-007` | `祖棚廊` | 棚間隔が `待ち器回廊` の pair spacing と同じ | `CL-061`, `CL-062` |

---

## 6. QA Checklist

- runtime zone 名と map blueprint の語彙が `W-006〜W-007` でも一致しているか
- hidden が `親切な宝箱` でなく `制度運用の証拠` として機能しているか
- `W-006` の湿地と `W-007` の階段都市が、route pair の差でちゃんと別の遊びになるか
- clear 後 state shift が `改善` でなく `整理と最適化` に見えるか
