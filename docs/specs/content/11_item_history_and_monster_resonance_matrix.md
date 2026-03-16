# 11. Item History And Monster Resonance Matrix

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16
> **役割**: item を単なる consumable で終わらせず、`1000年史の事件`, `勢力の欲望`, `モンスター生態`, `店棚`, `hidden payoff` へ結び直す canonical matrix
> **参照元**:
> - `docs/specs/content/04_initial_items_and_shops.md`
> - `docs/specs/content/08_starting_region_ecology_and_monster_web.md`
> - `docs/specs/content/09_act_i_ii_monster_expansion_and_discovery_pack.md`
> - `docs/specs/story/06_millennial_geopolitics_and_personages.md`
> - `docs/specs/story/09_silence_economy_and_powerbrokers.md`
> - `docs/specs/story/14_cross_system_echo_and_discovery_lattice.md`
> - `docs/specs/worlds/09_act_i_world_sheets.md`
> - `docs/specs/worlds/10_act_ii_world_sheets.md`
> - `docs/specs/worlds/14_starting_arc_map_and_secret_blueprints.md`
> - `docs/specs/worlds/15_act_ii_bridge_map_and_secret_blueprints.md`
> - `docs/specs/content/12_item_provenance_inspect_and_shop_text_pack.md`

---

## 1. 目的

- 序盤〜Act II 前半の item を、`効能` だけでなく **誰が何を隠すために持つか** まで固定する
- `歴史イベント -> 制度残滓 -> 店棚 / field prop -> monster ecology -> hidden payoff` の一続きの導線を作る
- `全部の item に lore を背負わせる` のでなく、各世界に `2〜4 個の記憶の濃い item` を置いて厚みを作る
- 現地の棚, 壺, 布, peg, 祖棚への配置は `worlds/14`, `worlds/15` の provenance placement を正とする

---

## 2. Design Contract

| rule | 内容 |
|------|------|
| `item remembers institution` | item は素材より先に制度の癖を覚える。寸法、結び方、保管法が歴史を語る |
| `utility and abuse coexist` | 正規用途と汚れた用途を必ず 1 つずつ持たせる |
| `monster eats residue` | モンスターは item そのものより、item を支える残滓 `灰 / 墨 / 塩 / 鈴屑 / 札穴 / 蝋` に寄る |
| `shelf reveals profit` | どの店で売られているかで、誰が事件の後始末から儲けているかが見える |
| `selected density` | 全 item を lore heavy にしない。旅の手触りが変わる item を優先して意味づける |

### 2.1 item へ入れるべき深みの最低単位

1. どの事件の残りか
2. どの勢力 / 家 / 実務者が運用しているか
3. その残りを食う / まとう monster は何か
4. それを持つ人の欲望は何か
5. 後でどの clue / secret / recruit / breed に返るか

---

## 3. Historical Residue Clusters

### 3.1 `CL-ITEM-01` 借り名と余り物の生存経済

- 歴史核: `H-1001 借り名の冬`
- 何が残ったか: 仮所属札、余り分の配給、同寸の札文化、`本名を聞かない方が回る` 生活作法
- 今の担い手: 開始村の世話役筋、仮親家、荷分け番、塔前仮商
- 欲望: ひと冬だけ守る名目で、子や避難民を **正式記録の外** に置きたい
- late echo: `H-1007 冬名戦` で provisional naming が家督武器へ変質し、`item_key_evidencebundle` に繋がる

| item_id | monster resonance | world / holder | 正規用途 | 汚れた用途 | payoff |
|---------|-------------------|----------------|----------|------------|--------|
| `item_heal_dryherb` | `MON-001`, `MON-003` | 開始村の台所、仮親家 | 飢えを越えるための乾燥常備薬 | 借り名札の子へだけ帳外配給する | 村の乾し棚と `item_key_borrowedtag` の寸法 echo |
| `item_bait_drycrumb` | `MON-001`, `MON-002`, `MON-008` | 畜舎番、見張り番 | 家畜や小型獣の気を引く | `余り分` 名目で差別配給に使う | `MON-002` が札穴つき布袋を巣材にする |
| `item_field_chalktag` | `MON-002`, `MON-024` | 捜索隊、塔前仮商 | 迷路や湿地に道標を残す | 行方不明の捜索経路を都合よく書き換える | `W-001` と `W-006` の同寸札 echo |
| `item_key_borrowedtag` | `MON-002`, `MON-008` | 主人公の村、古い仮親家 | `W-001` の正規進行 key | 誰を `一時預かり` にしたかの責任をぼかす | 開始村の失踪件数と `H-1014` の記録揺れへ返る |

### 3.2 `CL-ITEM-02` 閉じきれない弔いと待ち墓

- 歴史核: `H-1002 七灰葬の取り決め` + `H-1014 開始村最後の確認失踪`
- 何が残ったか: 無銘墓、閉じ塩、香なし供物、待ち続ける遺族向けの半端な実用品
- 今の担い手: 墓守、香巡教圏の末端、黒布巡礼、開始村の遺族
- 欲望: 死者扱いしたい人と、まだ戻ると信じたい人の両方から金を取る
- late echo: `item_key_memorialoffering` は `待つ grief` を gate 解放の鍵へ転用したものとして扱う

| item_id | monster resonance | world / holder | 正規用途 | 汚れた用途 | payoff |
|---------|-------------------|----------------|----------|------------|--------|
| `item_heal_softmoss` | `MON-021`, `MON-022` | `W-005` 墓苑端の売り子 | 墓石の湿苔を利用した応急包み | `待つ者の手当て` 名目で寄付金を吸う | 待ち器回廊と村の空き家の湿りを繋ぐ |
| `item_bait_graveflour` | `MON-020`, `MON-021`, `MON-023` | 墓守、遺族、密祈祷師 | 残響種への餌 | 失踪者が戻るか試す危険な呼び餌 | `DH-MON-07〜10` と直結する |
| `item_field_repelash` | `MON-020`, `MON-021` | 墓苑の作業班 | 低位残響を遠ざける | 追悼の場から都合の悪い兆候だけ消す | `item_key_gravesalt` の閉じ塩文化を補強 |
| `item_key_gravesalt` | `MON-021`, `MON-022` | 墓守、香巡教圏 | `W-005` の story key | 遺族へ `ここで閉じろ` と圧をかける | `閉じる / 待つ` の選択が mainline の感情圧になる |
| `item_record_rubbingset` | `MON-020`, `MON-028` | 村の記録番、遺族 | 削除痕の採取 | 消された名を勝手に掘り返し商売にする | `H-1014` の削れた札と記録改竄の proof に返る |

### 3.3 `CL-ITEM-03` 宿場帳簿と通行権の物流

- 歴史核: `H-1003 岬灯誓約` + `H-1008 塩骨通商条`
- 何が残ったか: 宿名灯、宿帳検査、通行札、骨樋搬送、鈴と札が同じ物流で動く市場
- 今の担い手: 宿場商会、海路侯の徴税人、灯番宿、札差しの岬の検札役
- 欲望: `安全のため` と言いながら、越境そのものを収益化したい

| item_id | monster resonance | world / holder | 正規用途 | 汚れた用途 | payoff |
|---------|-------------------|----------------|----------|------------|--------|
| `item_mp_clearwater` | `MON-014`, `MON-015` | `W-003` 灯番宿 | 宿帳改め前に旅人を落ち着かせる | 声色と本名の揺れを見極める時間稼ぎ | 宿名灯と旅人の扱いの冷たさが残る |
| `item_heal_bundleleaf` | `MON-014`, `MON-015`, `MON-016` | 宿継ぎ衆、荷役番 | 長距離移動の定番薬 | 記録される旅人だけに優先配布する | `W-003` の宿格差を棚だけで示す |
| `item_record_tagcase` | `MON-015`, `MON-017`, `MON-027` | 商人、代書屋、密航屋 | 札や鋲を濡らさず保管 | 複数の所属を同じ寸法の case で使い回す | `借り名札 / 通行鋲 / 役名 badge` 同寸 echo |
| `item_catalyst_bellsalt` | `MON-018`, `MON-024`, `MON-026` | 岬の塩庫、湿地の借り鈴商 | bird / divine 配合触媒 | 通行資格を持つ血統だけを高値で売る | `W-004 -> W-006` の bell route を接続 |
| `item_field_bonerope` | `MON-017`, `MON-023` | 骨樋番、墓苑搬送役 | 危険地帯からの退避 | 証拠ごと荷を引き上げる隠蔽実務 | `塩 / 骨 / 門` が同じ物流だと分かる |
| `item_key_hostellamp` | `MON-014`, `MON-016` | `W-003` 宿主筋 | `W-003` の story key | 真名客だけを識別する差別的指標 | 宿が refuge でなく検査場だと固まる |
| `item_key_passpeg` | `MON-017`, `MON-018`, `MON-019` | `W-004` 岬検札所 | `W-004` の story key | 非合格者を潮待ちへ回す順番管理 | `H-1012` の選別制度へ下地を引く |

### 3.4 `CL-ITEM-04` 閉鐘と逆誓の音管理

- 歴史核: `H-1005 閉鐘第一次封止` + `H-1009 逆誓焼却`
- 何が残ったか: 呼名禁止、沈鐘の破片、逆唱による保全、`聞こえないこと` を作る仕事
- 今の担い手: 閉鐘都の実務監筋、修院末端、黒布巡礼、湿地の借り鈴役
- 欲望: 真実を守る名目で、声と記憶の流れ自体を管理したい
- late echo: `item_key_blackcloth` は `隠す grief` を通行規格へまで延ばした象徴物

| item_id | monster resonance | world / holder | 正規用途 | 汚れた用途 | payoff |
|---------|-------------------|----------------|----------|------------|--------|
| `item_mp_silentwax` | `MON-014`, `MON-024` | 宿場の夜番、閉鐘系の祈祷役 | 雑音を消して集中する | 証言前に声を鈍らせる | `item_field_silentcloth` と paired use になる |
| `item_cure_focussalt` | `MON-020`, `MON-022`, `MON-024` | 修院薬棚、湿地の実務者 | seal / hushed の解除 | 逆誓詞の痺れだけ解いて尋問を通す | `逆誓を守る / 破る` 両面の顔を持つ |
| `item_debuff_dullbell` | `MON-022`, `MON-024`, `MON-026` | 閉鐘守の古道具屋 | 敵の命中を落とす | 探し人を呼ぶ声だけ外す | 鐘の欠片が戦闘と生活の両方で使われる |
| `item_field_silentcloth` | `MON-022`, `MON-024` | 門守、巡礼、密輸役 | 反応軽減 | 閉じた現場から悲鳴を漏らさない | `W-005`, `W-006` の静けさが同じ圧から来る |
| `item_record_belltube` | `MON-024`, `MON-026` | 借り鈴検査役、鐘楼守 | 音孔差の記録 | 非正規の鈴便だけ洗い出す | `人名 -> 音程` 圧縮文化の証拠になる |

### 3.5 `CL-ITEM-05` 二署台帳と役名市場

- 歴史核: `H-1006 二署分立令` + `H-1010 焼継印統一`
- 何が残ったか: 二重台帳、貼り替え痕、役名 badge、家督仲介、欠けた印章を食う害獣
- 今の担い手: 帳法院連署、鍛印屋、削名の階市、家督仲介人
- 欲望: 本名や出生より、`今この仕事に使える所属` を優先して売買したい
- late echo: `item_key_recordseal` と `item_key_forgemark` は、`書類の正統` と `継ぎ目の正統` が同じ市場論理へ落ちた証拠

| item_id | monster resonance | world / holder | 正規用途 | 汚れた用途 | payoff |
|---------|-------------------|----------------|----------|------------|--------|
| `item_mp_bitterdew` | `MON-016`, `MON-028` | 若い書記、夜勤法官 | 台帳照合時の眠気覚まし | 片方の署だけ先に処理し、人を机の上で消す | スズネの黒簿と実務の冷たさへ接続 |
| `item_bait_inkmeat` | `MON-016`, `MON-027`, `MON-028`, `MON-029` | 工房街の裏店 | 記号食い系モンスターへの bait | 削除痕を食わせて証拠隠滅に使う | `W-003` と `W-007` の same pressure を示す |
| `item_record_inkpaste` | `MON-016`, `MON-027` | 改竄屋、記録番、闘籍院の裏方 | 台帳照合回数追加 | 都合の悪い追記だけ浮かせて値を吊る | `二署の食い違い` を player proof に変える |
| `item_record_namefoil` | `MON-027`, `MON-028`, `MON-029` | 役名工房、祖棚廊の古物店 | 貼り替え痕の可視化 | 役名の剥がし跡を脅しの種にする | `W-007` の怪物害と制度害を一本化する |
| `item_catalyst_bloodchalk` | `MON-011`, `MON-027`, `MON-028` | 系譜仲介人、鍛印屋 | material / undead 配合補助 | 血筋や門筋の偽装商品 | `BRD-0208`, `BRD-0210` の後ろ暗さを補強 |

### 3.6 `CL-ITEM-06` 配合再命名と選抜娯楽

- 歴史核: `H-1011 配合再命名勅` + `H-1012 通行験試令` + `H-1013 第一門競大会`
- 何が残ったか: 血統証、継承保護、空欄印、試験用通牒、競技用強化餌
- 今の担い手: 継聖郭庁、闘籍院、配合商、興行師、上位 breeder
- 欲望: 危険な選別と継ぎ足しを `夢` と `努力` に言い換えて売りたい

| item_id | monster resonance | world / holder | 正規用途 | 汚れた用途 | payoff |
|---------|-------------------|----------------|----------|------------|--------|
| `item_catalyst_namewax` | `MON-023`, `MON-028`, `MON-029` | 配合商、家門の代理人 | 継承候補の保護 | 都合の悪い lineage を蝋で塗り直す | `配合 = 再命名` の本質を player が掴む |
| `item_catalyst_emptyseal` | `MON-019`, `MON-028`, `MON-029` | 闘籍院、辺境門監局 | mutation 方向指定 | `所属空欄でも使える個体` を作るための危険印 | `通行験試令` の選抜思想を露骨に見せる |
| `item_catalyst_starbone` | `MON-019`, `MON-023` | 門競整備班、上位 breeder | plus_value 判定補助 | 門事故の残滓を強化資源として流す | `神罰` が実は resource 化されていると分かる |
| `item_bait_starmarrow` | `MON-019` | 興行屋、競技場の調教師 | divine / dragon 向け bait | 門競前の興奮剤として使う | rare 勧誘の裏に見世物経済がある |
| `item_bait_truefeast` | `MON-019`, `MON-023`, 上位種全般 | 闘籍院、豪商スポンサー | 上位汎用 bait | 勝者演出の残飯で強者だけ寄せる | `観戦文化が選別圧を正当化する` 証拠になる |
| `item_key_towerwrit` | `MON-019`, `MON-029` | 塔保全機構、門監局 | 中盤以降の正規通行 key | 非合格者を存在しないことにする通牒 | `使える者だけ抜く制度` を story key 自体で背負う |

---

## 4. Monster / Item Resonance Picks

| pair | why it feels good in play | deeper meaning |
|------|---------------------------|----------------|
| `item_bait_sourmilk` × `MON-011 チチススリ` | 乳膜を吸う種へ、判乳残りを使う bait が直感的に効く | 母系判定の余り物が、そのまま異常生態の餌になっている |
| `item_record_tagcase` × `MON-015 カギアシテン` | 鍵と札を集める種に、同寸 case が一目で似合う | 旅の自由が `鍵` と `所属札` の両方で管理されている |
| `item_mp_clearwater` × `MON-014 トモシガ` | 灯へ寄る種の前で、旅人が喉を整える行為が印象に残る | 宿場は癒やしの場でなく検査の前室でもある |
| `item_catalyst_bellsalt` × `MON-018 サシミサゴ` / `MON-026 スズワタリ` | bell 系統が鳥モンスターへの lure / catalyst として気持ちよく繋がる | 通行権と物流の音が、種の移動圧まで規定している |
| `item_bait_graveflour` × `MON-020 ムメイボタル` | 無銘墓へ寄る光に、墓粉餌が露骨に効く | `帰るかもしれない者` を餌にしてしまう遺族の泥が見える |
| `item_field_silentcloth` × `MON-022 コエガエシ` | 呼び声反響系へ静音布を使うのが戦術として腑に落ちる | 声を抑える道具が、哀悼と隠蔽の両方に使われる |
| `item_record_belltube` × `MON-024 アマリスズ` | 音程ずれに反応する record item が discovery と噛み合う | 人名を音へ圧縮する文化が物の使い方に現れる |
| `item_bait_inkmeat` × `MON-028 ヤクナシ` | 役名だけ抜く影に、墨肉 bait が視覚的にも合う | 役名 economy が monster ecology にまで滲んでいる |
| `item_record_namefoil` × `MON-029 タナスベリ` | 棚と badge の貼り替え痕を追う探索が楽しい | 位牌棚と役名棚が同型で、死者と労働力が同じ棚論理で扱われる |
| `item_catalyst_emptyseal` × `MON-019 ウシオアギト` | gate-touched へ blank-seal catalyst を当てると危うさが伝わる | 通行験試の本質が `適応者の生産` にあると露骨になる |

---

## 5. Shelf Storytelling

| shop | dominant cluster | player が棚を見るだけで拾うこと |
|------|------------------|--------------------------------|
| `SHOP-001` 故郷の村 | `CL-ITEM-01` | 村は優しいが、余り物配給の論理で人を守ってきた |
| `SHOP-002` 塔前仮商 | `CL-ITEM-01`, `CL-ITEM-04` | 越境直前から already `記録 / 静音 / 拓本` が必要な世界だと分かる |
| `SHOP-W01` 名伏せの野 | `CL-ITEM-01` | 借り札, 灰, 鈴の組み合わせで belonging が仮置きだと見える |
| `SHOP-W02` 灰乳の谷 | `CL-ITEM-02`, `CL-ITEM-05` | 乳と灰が healing と lineage 判定を兼ねる怖さが出る |
| `SHOP-W03` 継灯の宿場 | `CL-ITEM-03`, `CL-ITEM-05` | 宿は休む場所ではなく、照合と保留のための場所でもある |
| `SHOP-W04` 札差しの岬 | `CL-ITEM-03`, `CL-ITEM-06` | 通行のための道具が、選別と競争の前段階でもある |

---

## 6. Authoring Rules For Future Items

- 新規 item を足すときは、まず `事件` でなく `誰の手垢が付いているか` を決める
- `素材名 + 効能` で完結させず、寸法, 収納法, 匂い, 乾き方, 削り跡のどれかを history residue にする
- monster と結ぶときは `その item を食う` より `その item の残りを食う` を優先する
- key item は `扉を開ける` だけでなく、`誰が誰を通してきたか` を背負わせる
- bait / catalyst は欲望の市場性が最も出る枠なので、必ず `どの層が高値で欲しがるか` を決める
- story payoff は item 説明文だけに閉じず、shop shelf, inspect text, codex 2 行目, breed hint の最低 2 媒体で返す

### 6.1 やらないこと

- lore を説明文の長文化だけで済ませる
- item を全部 relic っぽくし、日用品の湿った感じを失う
- `昔の事件の名残です` で止め、今の誰がその名残で稼いでいるかを曖昧にする

---

## 7. QA Checklist

- selected item の説明文だけ見ても、`誰かの都合` がうっすら見えるか
- item と monster の接続が `属性一致` だけでなく、生態残滓の一致になっているか
- 同じ歴史イベントが別世界で別の物へ残っているか
- shop 在庫が純粋な difficulty curve ではなく、世界の棚顔を持っているか
- mainline を読まなくても item の違和感は残り、深掘ると 1000年史へ繋がるか
