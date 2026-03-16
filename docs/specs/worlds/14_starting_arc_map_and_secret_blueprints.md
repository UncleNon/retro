# 14. Starting Arc Map And Secret Blueprints

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16
> **役割**: `開始村〜W-005` の map topology, route pair, hidden pocket, state change を concrete blueprint として固定する
> **参照元**:
> - `docs/specs/worlds/05_world_catalog_and_budget.md`
> - `docs/specs/worlds/09_act_i_world_sheets.md`
> - `docs/specs/worlds/10_act_ii_world_sheets.md`
> - `docs/specs/content/08_starting_region_ecology_and_monster_web.md`
> - `docs/specs/content/09_act_i_ii_monster_expansion_and_discovery_pack.md`
> - `docs/specs/content/11_item_history_and_monster_resonance_matrix.md`
> - `docs/specs/story/12_starting_arc_relationship_and_faction_map.md`
> - `docs/specs/story/14_cross_system_echo_and_discovery_lattice.md`

---

## 1. 目的

- 序盤〜前半の世界を `world sheet は濃いが、実際の map loop が曖昧` な状態から抜ける
- `safe route / danger route / clue pocket / hidden pocket` を、map 単位で設計できる粒度に落とす
- hidden element を `やり込み` でなく、**世界の制度圧を別角度から見せる導線** として配置する

---

## 2. Shared Rules

### 2.1 route pair

| route type | 役割 |
|------------|------|
| `main route` | 迷わず進んだときに通る標準導線 |
| `safe route` | 遠回りだが status tax が低い |
| `danger route` | 短いが rare / clue / resource が濃い |
| `hidden pocket` | mainline では必須でないが、関係図や制度理解を深める |

### 2.2 hidden の置き方

- 1 世界につき `inspect secret 2`, `route secret 1`, `encounter secret 1` を最低ラインにする
- 強アイテムより先に `語彙`, `証拠`, `残滓` を reward にする
- secret は `世界の本音` を見せる。便利ショートカットだけで終わらせない

---

## 3. `Prologue / 開始村`

### 3.1 field provenance placements

| field | spot | tied item | 何が見えるか | どの pressure へ返るか | inspect seed |
|-------|------|-----------|--------------|------------------------|-------------|
| `FIELD-VIL-001` | 記録小屋の削れた家畜札 | `item_key_borrowedtag`, `item_record_rubbingset` | 牛印の下に人名の横画が残り、札穴も二度使われている | `SV-05` の人札と畜札の混線が、生活物の修繕として隠される | `牛の印の下に、人名の横画だけが薄く残っている。` |
| `FIELD-VIL-001` | 外された表札跡 | `item_key_borrowedtag` | 戸口の木肌だけ色が違い、削り跡が二層以上重なる | `SV-09` だけでなく古い失踪処理まで `空き家` へ押し込まれている | `戸口の木肌だけ色が違う。空き家は一度でできていない。` |
| `FIELD-VIL-001` | 墓地の空碑 | `item_key_memorialoffering`, `item_key_gravesalt` | 刻みかけの一画と乾いた塩だけが残る | `SV-03`, `SV-07`, `SV-09` の未決着が一つの碑へ畳まれる | `死者とも不在者とも決めきれなかった名の置き場に見える。` |
| `FIELD-VIL-001` | 雑貨棚 / 手当所の薬棚 | `item_heal_dryherb`, `item_mp_clearwater`, `item_record_rubbingset` | 冬越しの薬草、澄み水、写し道具が同じ商い圏で回る | 日常物の棚に `借り名の冬`, `数え直し`, `写し直し` の実務が混ざっている | `澄み水と拓本具が同じ棚にある。診るのは傷だけじゃない。` |

### 3.2 ambient carriers

| carrier | 何を漏らすか | delayed payoff |
|---------|--------------|----------------|
| 記録番 | `整理` という言い換えで札の混線を処理する | `W-018` の台帳優先 logic |
| 墓守 | `待つ` を死でも帰還でもない第三の扱いで保つ | `W-005` の空碑運用 |
| 道具屋 / 手当所 | 干し草薬、澄み水、拓本具が生活物として売られる | 事件の痕跡が店棚へ吸収される恐さ |

---

## 4. `W-002` 灰乳の谷

### 3.1 map roster

| map_id | 名称 | size | 役割 |
|--------|------|------|------|
| `MAP-W02-001` | 灰印の門盆 | `40 x 28` | arrival, first proof |
| `MAP-W02-002` | 判乳盆 | `56 x 40` | hub |
| `MAP-W02-003` | 白灰の斜面 | `64 x 40` | main route |
| `MAP-W02-004` | 継乳棚 | `48 x 32` | clue pocket |
| `MAP-W02-005` | 薄印斜面 | `40 x 30` | danger route |
| `MAP-W02-006` | 母谷の祠穴 | `36 x 32` | boss approach |
| `MAP-W02-007` | 灰塚見張り台 | `24 x 20` | hidden overlook |

### 3.2 route pair

| route | maps | 体験 |
|-------|------|------|
| `main route` | `001 -> 002 -> 003 -> 004 -> 006` | 家系判定の実務を順に見て進む |
| `safe route` | `002 -> 003` 外縁道 | 戦闘は軽いが、薄印の情報は薄い |
| `danger route` | `003 -> 005 -> 007 -> 006` | rare bird と灰塚証拠が濃い |

### 3.3 hidden pockets

| secret_id | 種別 | 場所 | trigger | reward |
|-----------|------|------|---------|--------|
| `SEC-W02-01` | inspect | `継乳棚` の裏板 | 乳壺を 2 個調べる | 他家の色に縫い直した借り乳布 |
| `SEC-W02-02` | route | `薄印斜面` の崩れ道 | 斜面の獣足跡を追う | `コナヒヅメ` 固定影 |
| `SEC-W02-03` | inspect | `灰塚見張り台` | 夕方にだけ登れる | 直系から外された子の灰塚台帳断片 |
| `SEC-W02-04` | encounter | `判乳盆` 夜再訪 | `判乳鉢` 調査後 | `チチススリ` の濃い群れ |

### 3.3.1 item provenance placements

| map | spot | tied item | 何が見えるか | どの pressure へ返るか | inspect seed |
|-----|------|-----------|--------------|------------------------|-------------|
| `MAP-W02-002` | 第一母屋の冷灰棚 | `item_heal_stillmilk` | 直系用だけ壺口が白布で封じられている | care が selection と同じ棚で配られる | `白布の結びだけ新しい。誰に飲ませる壺か、最初から決まっている。` |
| `MAP-W02-004` | 発酵桶の影 | `item_bait_sourmilk` | 判乳残りを酸ませた餌桶が獣番の私札つきで置かれる | 判定残滓がそのまま monster bait になる | `乳の残りを獣へ回した匂いがする。谷では余り物にも順番がある。` |
| `MAP-W02-006` | 裏龕の灰盤 | `item_key_ashbrand` | 灰印片だけ三色灰で囲われて保管される | 一片の印が家順を動かす | `灰の色が三度重ねられている。これ一枚で、娘の行き先まで変わる。` |

### 3.4 clear 後 state shift

- `継乳棚` に空き slot が増え、婚礼停止が風景に出る
- `薄印斜面` の見張りが減り、danger route が safe route に寄る

---

## 5. `W-003` 継灯の宿場

### 4.1 map roster

| map_id | 名称 | size | 役割 |
|--------|------|------|------|
| `MAP-W03-001` | 灯泊門 | `44 x 28` | arrival gate |
| `MAP-W03-002` | 灯泊町表路 | `72 x 36` | hub street |
| `MAP-W03-003` | 灯預宿 | `32 x 28` | inn interior |
| `MAP-W03-004` | 鍵札小路 | `40 x 24` | clue lane |
| `MAP-W03-005` | 裏荷庭 | `56 x 32` | danger route |
| `MAP-W03-006` | 油路地 | `32 x 24` | status pocket |
| `MAP-W03-007` | 無窓の離れ | `30 x 26` | boss approach |
| `MAP-W03-008` | 裏帳格子庫 | `24 x 20` | hidden archive |
| `MAP-W03-009` | 門灯中庭 | `28 x 18` | post-clear return |

### 4.2 route pair

| route | maps | 体験 |
|-------|------|------|
| `main route` | `001 -> 002 -> 003 -> 004 -> 007` | 宿名と役名の運用を正面から見る |
| `safe route` | `002 -> 004 -> 007` | 戦闘は薄めだが裏帳証拠が足りない |
| `danger route` | `002 -> 005 -> 006 -> 008 -> 007` | `ネムインク` と密泊導線が濃い |

### 4.3 hidden pockets

| secret_id | 種別 | 場所 | trigger | reward |
|-----------|------|------|---------|--------|
| `SEC-W03-01` | inspect | `灯預宿` の鍵棚 | 同じ灯番号を 2 回見る | 重複灯番号メモ |
| `SEC-W03-02` | route | `裏荷庭` の荷台裏 | 宿で休まず夜へ進む | `カギアシテン` 固定出現 |
| `SEC-W03-03` | inspect | `裏帳格子庫` | 焼け残り帳面を読む | 役名再利用の痕跡 |
| `SEC-W03-04` | encounter | `門灯中庭` | `裏帳` 発見後に再訪 | `トモシガ` が名の近い灯を囲う演出 |

### 4.3.1 item provenance placements

| map | spot | tied item | 何が見えるか | どの pressure へ返るか | inspect seed |
|-----|------|-----------|--------------|------------------------|-------------|
| `MAP-W03-001` | 門前の喉桶台 | `item_mp_clearwater` | 宿帳改め前だけ水差しが満たされ、客名の代わりに灯番号で呼ばれる | 回復と検査が同じ儀礼になる | `水を飲む前に、名ではなく灯番号を聞かれる。喉を潤す順まで帳面のうちだ。` |
| `MAP-W03-003` | 奥灯棚 | `item_key_hostellamp` | 返ってこない客の灯だけ煤色が濃い | refuge に見える宿が検査場でもある | `煤の濃い灯は、帰らなかった客の分だという。消さずに残すのは、待つためではない。` |
| `MAP-W03-004` | 代書机の抽斗 | `item_record_tagcase` | 借り名札, 宿鍵札, 通行鋲が一つの case 規格へ収まる | provisional identity の同寸文化 | `札も鋲も同じ深さで収まる。違う名目のものを、同じ手つきで隠せる。` |

### 4.4 clear 後 state shift

- 表路の灯色が少し揃い、重複灯番号が禁止された結果だけが visible になる
- `裏荷庭` の通行は残り、制度は改善でなく最適化されたと分かる

---

## 6. `W-004` 札差しの岬

### 5.1 map roster

| map_id | 名称 | size | 役割 |
|--------|------|------|------|
| `MAP-W04-001` | 白札坂 | `52 x 30` | arrival ascent |
| `MAP-W04-002` | 潮別関前 | `40 x 28` | hub |
| `MAP-W04-003` | 検潮棚 | `48 x 28` | clue platform |
| `MAP-W04-004` | 灰宿表口 | `40 x 24` | safe detour |
| `MAP-W04-005` | 灰宿裏路 | `44 x 28` | danger route |
| `MAP-W04-006` | 札捨て干潟 | `48 x 30` | ecology pocket |
| `MAP-W04-007` | 東桟橋封門 | `50 x 28` | boss approach |
| `MAP-W04-008` | 黒札波蝕棚 | `28 x 20` | hidden shelf |
| `MAP-W04-009` | 門潮割れ目 | `24 x 20` | rare sight line |
| `MAP-W04-010` | 裏舟発着場 | `30 x 18` | post-clear branch |

### 5.2 route pair

| route | maps | 体験 |
|-------|------|------|
| `main route` | `001 -> 002 -> 003 -> 007` | clean / gray / black の選別実務を直視する |
| `safe route` | `002 -> 004 -> 007` | 消耗は少ないが裏舟事情が見えない |
| `danger route` | `002 -> 005 -> 006 -> 008 -> 009 -> 007` | 密航と門事故の本音が濃い |

### 5.3 hidden pockets

| secret_id | 種別 | 場所 | trigger | reward |
|-----------|------|------|---------|--------|
| `SEC-W04-01` | inspect | `札捨て干潟` | 札屑棚を 3 回調べる | `フダガニ` 甲片メモ |
| `SEC-W04-02` | route | `黒札波蝕棚` | `灰宿裏路` からのみ降りられる | 疑い札押しつけの実例 |
| `SEC-W04-03` | inspect | `門潮割れ目` | 雨夜のみ | 門事故を神罰扱いした古記録 |
| `SEC-W04-04` | encounter | `東桟橋封門` | 黒札会話後 | `サシミサゴ` 先読み飛来 |

### 5.3.1 item provenance placements

| map | spot | tied item | 何が見えるか | どの pressure へ返るか | inspect seed |
|-----|------|-----------|--------------|------------------------|-------------|
| `MAP-W04-002` | peg board | `item_key_passpeg` | peg 一本ごとに `通す / 待たせる / 黒へ回す` の溝色が違う | 通行順が選別順でもある | `同じ peg なのに、削れ方が違う。通された数より、待たせた数の方が深く残っている。` |
| `MAP-W04-003` | 塩鈴籠 | `item_catalyst_bellsalt` | 検潮用の塩と借り鈴補修塩が同じ籠へ混ぜて置かれる | bell-route が触媒商売へ転化している | `潮を見る塩と、鈴を継ぐ塩が一つの籠に入っている。ここでは通すことも商品だ。` |
| `MAP-W04-010` | 退避杭 | `item_field_bonerope` | 舟子の縄だけ骨樋搬送と同じ返し結びを持つ | 物流と逃がし運用が同じ技法で回る | `逃がし舟の縄が、遺骨運びと同じ手で結ばれている。渡す先が違うだけだ。` |

### 5.4 clear 後 state shift

- `裏舟発着場` が visible になり、制度の裏口が消えていないと分かる
- `白札坂` の traffic は減るが、黒札処理は別導線で続く

---

## 7. `W-005` 香なしの墓苑

### 6.1 map roster

| map_id | 名称 | size | 役割 |
|--------|------|------|------|
| `MAP-W05-001` | 香断ち門 | `40 x 24` | arrival |
| `MAP-W05-002` | 無香墓庭 | `52 x 36` | hub |
| `MAP-W05-003` | 空碑苑 | `60 x 36` | main grave field |
| `MAP-W05-004` | 灰水路 | `44 x 30` | danger route |
| `MAP-W05-005` | 供香小屋 | `28 x 22` | clue pocket |
| `MAP-W05-006` | 無銘納骨穴 | `34 x 28` | boss approach |
| `MAP-W05-007` | 待ち器回廊 | `22 x 18` | hidden memorial pocket |

### 6.2 route pair

| route | maps | 体験 |
|-------|------|------|
| `main route` | `001 -> 002 -> 003 -> 005 -> 006` | `閉じる` 実務を正面から追う |
| `safe route` | `002 -> 003 -> 006` | 消耗は軽いが、香と器の意味が薄い |
| `danger route` | `002 -> 004 -> 007 -> 006` | 残響種と待機文化が濃い |

### 6.3 hidden pockets

| secret_id | 種別 | 場所 | trigger | reward |
|-----------|------|------|---------|--------|
| `SEC-W05-01` | inspect | `供香小屋` の棚裏 | 香を買わずに墓地を回る | 無煙供香の仕入れ札 |
| `SEC-W05-02` | route | `待ち器回廊` | 空碑を 3 基見た後 | 二人分の器が並ぶ小祭壇 |
| `SEC-W05-03` | inspect | `灰水路` の水門 | 夜霧時のみ | `カオリナシ` が香を奪う演出 |
| `SEC-W05-04` | encounter | `無銘納骨穴` 前 | 呼び声イベント 3 件後 | `カエラズジカ` silhouette |

### 6.3.1 item provenance placements

| map | spot | tied item | 何が見えるか | どの pressure へ返るか | inspect seed |
|-----|------|-----------|--------------|------------------------|-------------|
| `MAP-W05-002` | 湿石の手当棚 | `item_heal_softmoss` | 待ち器の横だけ柔苔包みが積まれ、閉じた者の棚には置かれない | `待つ / 閉じる` が healing 分配にも出る | `柔苔包みは、待つ家の器のそばにだけ置かれている。手当てにも順番がある。` |
| `MAP-W05-005` | 粉灯壺と供物束棚 | `item_bait_graveflour`, `item_key_memorialoffering` | 残響 bait と代用供物が同じ小屋で売られる | grief と商売の境界が溶ける | `呼び戻す粉と、閉じるための供物が並んでいる。ここでは未練も商品のうちだ。` |
| `MAP-W05-006` | 閉じ盆 | `item_key_gravesalt` | 閉じ塩だけが納骨穴の前で湿らず保たれている | 七灰葬の最後が story key 化している | `塩だけが湿らない。閉じるために置かれたものは、妙に長持ちする。` |

### 6.4 clear 後 state shift

- 一部の墓へ小さな香皿が戻るが、教義自体は崩れず `例外処理` として片づけられる
- `待ち器回廊` が visible になり、待つ者の数が風景に出る

---

## 8. Secret Ledger

| secret_id | world | reward type | 主 reward | clue 接続 |
|-----------|-------|-------------|-----------|-----------|
| `SEC-W02-01` | `W-002` | evidence | 借り乳布 | `CL-011` を強化 |
| `SEC-W02-03` | `W-002` | evidence | 灰塚台帳断片 | `CL-012` を補強 |
| `SEC-W03-01` | `W-003` | evidence | 重複灯番号メモ | `CL-013` を補強 |
| `SEC-W03-03` | `W-003` | evidence | 裏帳痕跡 | `CL-014` を補強 |
| `SEC-W04-01` | `W-004` | ecology note | 甲片メモ | `CL-015` を補強 |
| `SEC-W04-03` | `W-004` | archive | 門事故古記録 | `CL-016` を補強 |
| `SEC-W05-01` | `W-005` | market proof | 無煙供香札 | `CL-018` を補強 |
| `SEC-W05-02` | `W-005` | emotional residue | 待ち器祭壇 | `CL-017` を補強 |

## 9. Ambient Echo Ledger

| world | place | echo seed | delayed payoff |
|-------|-------|-----------|----------------|
| `W-002` | `継乳棚` | slot 幅が `W-007` の badge rack と同じ | `CL-061` |
| `W-002` | `灰塚見張り台` | 見張り紐の返し結びが待ち器と同型 | `CL-058` |
| `W-003` | `灯預宿` | 灯 hook の穴幅が借り札系と揃う | `CL-056` |
| `W-003` | `裏帳格子庫` | 分銅縁に `判乳鉢` と同じ slime 食痕 | `ECH-MON-01` |
| `W-004` | `検潮棚` | peg rack の刻み間隔が村畜舎札棚と同じ | `CL-057` |
| `W-004` | `黒札波蝕棚` | 結び袋の返却結びが `W-006` 借り鈴束へ繋がる | `CL-060` |
| `W-005` | `供香小屋` | 無煙供香札の連番打ちが宿灯番号と同型 | `ECH-MON-02` |
| `W-005` | `待ち器回廊` | pair spacing がカジ宅の二器配置と同じ | `ECH-NPC-01` |

---

## 9. QA Checklist

- 各世界に `route pair` があり、片方だけ通っても mainline は詰まらないか
- hidden が `強アイテムのご褒美` でなく、制度の別角度の証拠になっているか
- encounter zone 名と map blueprint の語彙が一致しているか
- clear 後 state shift が `全部解決した感じ` でなく、改善された顔をした継続に見えるか
