# 12. Item Provenance Inspect And Shop Text Pack

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16
> **役割**: item provenance を actual game text へ落とし、`inspect`, `repeat inspect`, `shelf strip`, `売り手の一言` まで固定する
> **参照元**:
> - `docs/specs/content/04_initial_items_and_shops.md`
> - `docs/specs/content/05_text_tone_and_lore_delivery_rules.md`
> - `docs/specs/content/11_item_history_and_monster_resonance_matrix.md`
> - `docs/specs/content/13_act_i_ii_item_text_routing_ledger.md`
> - `docs/specs/story/03_foreshadow_allocation_map.md`
> - `docs/specs/worlds/14_starting_arc_map_and_secret_blueprints.md`
> - `docs/specs/worlds/15_act_ii_bridge_map_and_secret_blueprints.md`
> - `docs/specs/systems/12_ui_screen_catalog_and_input_rules.md`

---

## 1. 目的

- `item provenance placement` を table の seed で終わらせず、実際に表示する文へ落とす
- item と歴史のつながりを `説明` ではなく、**棚 / 壺 / 布 / peg / 工房の気持ち悪さ** として見せる
- 売り手や持ち主の一言に、利害、言い換え、保身、未練を滲ませる

---

## 2. Format Contract

### 2.1 inspect text

- 1 テキストボックス = `全角18文字 x 最大3行`
- provenance inspect は `初回 1 box` を基本とし、重大証拠だけ `2 box` を許可する
- 1 行目で触った物の具体を出す
- 最終行で制度か感情の歪みを 1 つだけ滲ませる

### 2.2 repeat inspect

- `1〜2 行` を基本とする
- 情報追加より、見え方の固定に使う
- `同じ棚だが、嫌な意味が分かった後の短さ` を優先する

### 2.3 shelf strip / nearby voice

- `shelf strip` は `18文字以内`
- `nearby voice` は 1 box 以内
- 商売人はまず practical に喋り、そのあと euphemism や本音が少し漏れる

### 2.4 tone rule

- inspect 文は narrator 説明でなく、主人公が見て拾う違和感に寄せる
- 売り手は真相を説明しない
- `怖い` と言わず、`妙に乾く`, `色が違う`, `よく揃いすぎる` など物の挙動で出す

---

## 3. Pack

### 3.0 `Prologue / 開始村`

**ITX-VIL-01**
- spot: `FIELD-VIL-001` 外された表札跡
- tied item: `item_key_borrowedtag`
- clue: `CL-001`

初回 inspect:
```text
戸口の木肌だけ
色が違う。空き家は
一度でできてない。
```

repeat:
```text
釘穴が一つ多い。
前の名も外されてる。
```

shelf strip: `外し跡のある戸口`

nearby voice:
```text
「前のものを
　外しただけさ。」
```

**ITX-VIL-02**
- spot: `FIELD-VIL-001` 記録小屋の削れた家畜札
- tied item: `item_key_borrowedtag`, `item_record_rubbingset`
- clue: `CL-003`

初回 inspect:
```text
牛の印の下に
人名の横画だけ
薄く残っている。
```

repeat:
```text
古い穴が二つ。
別の家にも
掛かっていた札だ。
```

shelf strip: `削れた家畜札`

nearby voice:
```text
「整理の札だよ。
　気にするな。」
```

**ITX-VIL-03**
- spot: `FIELD-VIL-001` 墓地の空碑
- tied item: `item_key_memorialoffering`, `item_key_gravesalt`
- clue: `CL-005`

初回 inspect:
```text
刻みかけの一画と
灰だけが残る。
死とも言い切れない。
```

repeat:
```text
裏の塩だけ
湿っていない。
```

shelf strip: `名の入らない空碑`

nearby voice:
```text
「まだ入れる名が
　ないんだよ。」
```

**ITX-VIL-04**
- spot: `FIELD-VIL-001` 開始村 雑貨棚
- tied item: `item_heal_dryherb`, `item_bait_drycrumb`

初回 inspect:
```text
干し草薬と
余り餌が一段に
詰め込まれている。
```

repeat:
```text
冬越しの品だけ
よく減っている。
```

shelf strip: `借り名の冬の棚`

nearby voice:
```text
「干し棚の品は
　切らせないからね。」
```

**ITX-VIL-05**
- spot: `FIELD-VIL-001` 開始村 手当所の薬棚
- tied item: `item_mp_clearwater`, `item_record_rubbingset`

初回 inspect:
```text
澄み水と拓本具が
同じ棚にある。
診るのは傷だけじゃない。
```

repeat:
```text
写し道具の方が
薬より乾いている。
```

shelf strip: `手当てと写しの棚`

nearby voice:
```text
「診る前にまず
　見返すのさ。」
```

### 3.1 `W-002` 灰乳の谷

**ITX-W02-01**
- spot: `MAP-W02-002` 第一母屋の冷灰棚
- tied item: `item_heal_stillmilk`
- clue: `CL-067`

初回 inspect:
```text
白布の結びだけ
新しい。夜に出す
壺らしい。
```

repeat:
```text
白布の壺だけ
棚の奥へ戻る。
```

shelf strip: `直系だけの静乳壺`

nearby voice:
```text
「それは家の夜分だ。
　昼に開けるな。」
```

**ITX-W02-02**
- spot: `MAP-W02-004` 発酵桶の影
- tied item: `item_bait_sourmilk`
- clue: `CL-011`

初回 inspect:
```text
酸い乳の匂いが
きつい。判り残りを
餌へ回した桶だ。
```

repeat:
```text
余りは獣へ回す。
谷の癖が残る。
```

shelf strip: `判乳残りの酸乳桶`

nearby voice:
```text
「捨てるより
　ましだろうさ。」
```

**ITX-W02-03**
- spot: `MAP-W02-006` 裏龕の灰盤
- tied item: `item_key_ashbrand`
- clue: `CL-012`

初回 inspect:
```text
灰の色が三つ。
一片だけで家の
順まで決まる。
```

repeat:
```text
灰印片だけ
妙に乾いている。
```

shelf strip: `三色灰の灰印片`

nearby voice:
```text
「触るな。
　それは娘の行き先だ。」
```

### 3.2 `W-003` 継灯の宿場

**ITX-W03-01**
- spot: `MAP-W03-001` 門前の喉桶台
- tied item: `item_mp_clearwater`
- clue: `CL-013`

初回 inspect:
```text
水差しは満ちてる。
名前より先に
喉を整えさせる。
```

repeat:
```text
灯番号が先。
水はその後だ。
```

shelf strip: `帳前の透き水`

nearby voice:
```text
「声が乾くと
　帳が合わない。」
```

**ITX-W03-02**
- spot: `MAP-W03-003` 奥灯棚
- tied item: `item_key_hostellamp`
- clue: `CL-014`

初回 inspect:
```text
煤の濃い灯だけ
棚の奥へ戻らない。
待ちではなさそうだ。
```

repeat:
```text
帰らぬ灯ほど
よく磨かれる。
```

shelf strip: `返らぬ客の宿名灯`

nearby voice:
```text
「消すと困る客も
　いるんだよ。」
```

**ITX-W03-03**
- spot: `MAP-W03-004` 代書机の抽斗
- tied item: `item_record_tagcase`
- clue: `CL-068`

初回 inspect:
```text
札も鋲も同じ深さ。
違う名目を
同じ箱へ隠せる。
```

repeat:
```text
寸法が揃いすぎて
気味が悪い。
```

shelf strip: `同寸札の札筒`

nearby voice:
```text
「旅の身なら
　合う箱が要る。」
```

### 3.3 `W-004` 札差しの岬

**ITX-W04-01**
- spot: `MAP-W04-002` peg board
- tied item: `item_key_passpeg`
- clue: `CL-015`

初回 inspect:
```text
peg の溝色が違う。
通す順より
待たせる順が深い。
```

repeat:
```text
通行順と
隔離順が同じ板だ。
```

shelf strip: `通し順の関所 peg`

nearby voice:
```text
「潮待ちは待ちだ。
　追い返しじゃない。」
```

**ITX-W04-02**
- spot: `MAP-W04-003` 塩鈴籠
- tied item: `item_catalyst_bellsalt`
- clue: `CL-069`

初回 inspect:
```text
塩と鈴屑が
一つの籠に混じる。
通す音まで商いだ。
```

repeat:
```text
海の塩より
鈴の粉が高い。
```

shelf strip: `岬灯まじりの鈴塩`

nearby voice:
```text
「鳥も門も
　音で寄るからね。」
```

**ITX-W04-03**
- spot: `MAP-W04-010` 退避杭
- tied item: `item_field_bonerope`
- clue: `CL-031`

初回 inspect:
```text
返し結びが古い。
遺骨運びと同じ手で
舟を出している。
```

repeat:
```text
逃がし縄まで
樋運びの手つきだ。
```

shelf strip: `骨樋くせの退避縄`

nearby voice:
```text
「渡す先が違うだけさ。」
```

### 3.4 `W-005` 香なしの墓苑

**ITX-W05-01**
- spot: `MAP-W05-002` 湿石の手当棚
- tied item: `item_heal_softmoss`
- clue: `CL-017`

初回 inspect:
```text
柔苔包みは
待ち器の横だけ厚い。
閉じた棚は空だ。
```

repeat:
```text
待つ家のほうへ
手当てが寄る。
```

shelf strip: `待ち墓の柔苔包み`

nearby voice:
```text
「戻ると言う家には
　少し多く置く。」
```

**ITX-W05-02**
- spot: `MAP-W05-005` 粉灯壺と供物束棚
- tied item: `item_bait_graveflour`, `item_key_memorialoffering`
- clue: `CL-070`

初回 inspect:
```text
呼ぶ粉と閉じる束が
同じ棚に並ぶ。
未練も商いだ。
```

repeat:
```text
戻す道具と
閉じる道具が近すぎる。
```

shelf strip: `墓粉と代え供物`

nearby voice:
```text
「待つなら待つで
　金は要る。」
```

**ITX-W05-03**
- spot: `MAP-W05-006` 閉じ盆
- tied item: `item_key_gravesalt`
- clue: `CL-018`

初回 inspect:
```text
塩だけ湿らない。
閉じるためのものは
妙に長持ちする。
```

repeat:
```text
墓塩だけ
減り方が遅い。
```

shelf strip: `閉じ盆の墓塩`

nearby voice:
```text
「これを振れば
　件が片づく。」
```

### 3.5 `W-006` 鈴結びの湿地

**ITX-W06-01**
- spot: `MAP-W06-004` 音孔見本板
- tied item: `item_record_belltube`
- clue: `CL-020`

初回 inspect:
```text
名ではなく音の癖が
見本板に並ぶ。
人より先に鈴が数だ。
```

repeat:
```text
音程のずれだけで
誰かが決まる。
```

shelf strip: `符号読みの鈴筒`

nearby voice:
```text
「声より鈴のほうが
　間違えない。」
```

**ITX-W06-02**
- spot: `MAP-W06-006` 穀袋台
- tied item: `item_bait_bellgrain`
- clue: `CL-019`

初回 inspect:
```text
借り鈴の屑穀が
餌袋へ落ちている。
送り数まで食わせる。
```

repeat:
```text
返り鈴の屑が
餌になる。
```

shelf strip: `借り鈴くずの鈴穀`

nearby voice:
```text
「余ったぶんは
　鳥に回すよ。」
```

**ITX-W06-03**
- spot: `MAP-W06-008` 乾し縄
- tied item: `item_field_silentcloth`
- clue: `CL-071`

初回 inspect:
```text
高く干された布だけ
風を吸わない。
静かにする値が高い。
```

repeat:
```text
慰めの布か
黙らせる布か。
```

shelf strip: `夜渡しの無音布`

nearby voice:
```text
「夜渡しにゃ
　よく売れる。」
```

### 3.6 `W-007` 削名の階市

**ITX-W07-01**
- spot: `MAP-W07-004` 貼り替え机
- tied item: `item_record_namefoil`
- clue: `CL-072`

初回 inspect:
```text
はがした跡の形が
位牌札でも badge でも
同じだ。
```

repeat:
```text
残すのは名でなく
枠らしい。
```

shelf strip: `貼り替え見る名箔`

nearby voice:
```text
「祖棚も役棚も
　貼り直しは同じさ。」
```

**ITX-W07-02**
- spot: `MAP-W07-009` 湿写し台
- tied item: `item_record_inkpaste`
- clue: `CL-021`

初回 inspect:
```text
祖棚控えも役控えも
同じ墨で直される。
隠し方がよく似る。
```

repeat:
```text
直しの墨と
消しの墨が近すぎる。
```

shelf strip: `両棚直しの墨膏`

nearby voice:
```text
「読めりゃいい。
　誰の字でもね。」
```

**ITX-W07-03**
- spot: `MAP-W07-006` 再封小棚
- tied item: `item_catalyst_namewax`
- clue: `CL-022`

初回 inspect:
```text
badge 封の蝋と
家筋封の蝋が
一鍋で溶けている。
```

repeat:
```text
役名も家名も
同じ鍋の匂いだ。
```

shelf strip: `再封用の名蝋`

nearby voice:
```text
「通る名なら
　蝋は同じで足りる。」
```

---

## 4. Runtime Hook Notes

- `inspect_first` は point interaction の初回 flag で分岐させる
- `repeat` は `default_interaction_message` 差し替えか、inspect point 専用 state で返す
- `shelf strip` は 16px 説明帯向けの短文としても再利用できる
- `nearby voice` は `npc ambient` か `shop prompt` の短文差分へ流用してよい
- runtime baseline では `shelf strip / nearby voice` を `data/csv/item_text_master.csv` に materialize し、`text_source` に `ITX-xxx:strip|voice` を残す
- provenance inspect と secret reward text は同じ場所で重ねすぎない。先に provenance、深掘りで secret を開く
- `point_id / condition_key / carrier_stub` の routing authority は [13_act_i_ii_item_text_routing_ledger.md](./13_act_i_ii_item_text_routing_ledger.md) を正とする

---

## 5. QA Checklist

- 1 回目の inspect で具体物が見え、2 回目で制度の嫌さが定着するか
- 売り手の台詞が lore explanation でなく、商売口調のまま濁れているか
- `shelf strip` が 18 文字以内に収まり、説明帯へ再利用できるか
- 世界ごとに euphemism が変わっているか
- `item -> place -> clue` の往復が、[11_item_history_and_monster_resonance_matrix.md](./11_item_history_and_monster_resonance_matrix.md) と矛盾しないか
