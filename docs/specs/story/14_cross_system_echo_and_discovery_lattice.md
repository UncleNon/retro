# 14. Cross-System Echo And Discovery Lattice

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16
> **役割**: モンスター, 人物, 地形, 物品, 勢力語彙にまたがる `薄い接続` を管理し、`気づけば深い / 初見では説明しすぎない` discovery 設計を canonical 化する
> **参照元**:
> - `docs/specs/story/03_foreshadow_allocation_map.md`
> - `docs/specs/story/10_starting_arc_engagement_playbook.md`
> - `docs/specs/story/12_starting_arc_relationship_and_faction_map.md`
> - `docs/specs/story/13_act_ii_bridge_relationship_and_faction_map.md`
> - `docs/specs/content/09_act_i_ii_monster_expansion_and_discovery_pack.md`
> - `docs/specs/worlds/14_starting_arc_map_and_secret_blueprints.md`
> - `docs/specs/worlds/15_act_ii_bridge_map_and_secret_blueprints.md`

---

## 1. 目的

- `retro` の深みを `設定量` でなく、**離れた場所に同じ傷が別の顔で残っている** 感触で作る
- `実は関係していた` を安売りせず、観察したプレイヤーだけが 1 手先に気づける discovery density を固定する
- モンスター同士の hidden relation を、人物の手癖、物の寸法、言い換え語、地図上の配置、配合線まで横断で支える

---

## 2. 発見のいい塩梅 Contract

| rule | 内容 |
|------|------|
| `three-contact rule` | 関係性は `初見の違和感 -> 別媒体での反復 -> 任意の確信材料` の 3 接点で管理する |
| `cross-medium rule` | 同じ relation を `NPC 会話` だけで重ねない。最低 2 媒体以上で見せる |
| `not-too-clean rule` | relation の 1 回目は証拠に見えすぎない。生活物や生態癖に埋める |
| `optional-proof rule` | 3 接点目は mainline 必須にしない。気づいた人が嬉しい位置へ置く |
| `bigger-structure rule` | relation の payoff は `この 2 体が親戚` で終わらず、制度や圧力線の共通性へ開く |

### 2.1 禁止事項

- 同じ場面で `説明 -> 具体例 -> 正解` を全部出さない
- relation の確証を villain の monologue へ預けない
- hidden relation の reward を強アイテムだけにしない
- `見落とすと損をする` を主目的にしない

---

## 3. Echo Type Taxonomy

| type | 何を揃えるか | 置きやすい媒体 |
|------|--------------|----------------|
| `geometry echo` | 穴幅, slot 幅, 結び方, 棚の段数 | map prop, item, secret inspect |
| `residue echo` | 灰, 煤, 蝋, 墨, 塩, 乳膜 | monster habitat, item text, ground decal |
| `behavior echo` | 先に食う場所, 戻る動き, 集め方, 鳴きの欠け方 | encounter演出, codex, hidden fixed spawn |
| `speech echo` | 言い換え, 婉曲語, 呼び方の欠け | NPC会話, ledger, notice board |
| `bookkeeping echo` | provisional list, 借り札, 二重帳, 仮置き棚 | story proof, secret ledger, map archive |

---

## 4. Monster Echo Lattice

| echo_id | 関係する種 | buried common pressure | first contact | second contact | optional payoff |
|---------|------------|-----------------------|---------------|----------------|-----------------|
| `ECH-MON-01` | `MON-011` チチススリ / `MON-016` ネムインク | `人の所属を決める器具の縁` を先に食う | `W-002` 判乳鉢の縁だけ半月状に薄い | `W-003` 帳場の分銅と帳面端に同じ濡れ欠け | `BRD-0211` と `CL-055` |
| `ECH-MON-02` | `MON-014` トモシガ / `MON-020` ムメイボタル | `まだ閉じ切っていない名` の周囲を回る灯 | 宿名灯のうち `返ってこない客` の灯だけ囲う | 無銘墓板のうち `待たれている側` へだけ降りる | `BRD-0212` |
| `ECH-MON-03` | `MON-015` カギアシテン / `MON-027` シルシアリ | `持ち主不明の番号物` を並べ直す癖 | 鍵紐を穴幅順に巣へ積む | badge 欠けを段順に運ぶ | `BRD-0213` |
| `ECH-MON-04` | `MON-017` フダガニ / `MON-009` シルシクイ | `証明物の縁` から食い始める | 札穴の周りだけ先に舐める | 封印の外周だけ削って中身を残す | `BRD-0214` と `CL-057` |
| `ECH-MON-05` | `MON-018` サシミサゴ / `MON-026` スズワタリ | `信号を持った移動体` へ先に反応する鳥系 | 黒札や未検査 movement を追う | 借り鈴や返却札を持つ movement を追う | `SEC-W06-02` の読み替え |
| `ECH-MON-06` | `MON-019` ウシオアギト / `MON-023` カエラズジカ | `帰還失敗の導線` に寄る gate-touched | 門潮の裂け目に現れる | 帰り道ではなく別門筋へ立つ | `BRD-0205` と `CL-066` |
| `ECH-MON-07` | `MON-024` アマリスズ / `MON-028` ヤクナシ | 名を `音 / 役名` に圧縮する圧 | 借り鈴の音程が人名の代わりになる | 本名を抜いて役名欄だけ残す影として出る | `BRD-0208` |
| `ECH-MON-08` | `MON-025` クグリヨシ / `MON-029` タナスベリ | 公式導線の外に細い生存路を作る | 根道で仮橋を増やす | 棚渡りで下段から上段へ抜ける | `W-006 -> W-007` の route echo |
| `ECH-MON-09` | `MON-013` ハイトサカ / `MON-022` コエガエシ | `儀礼を完了させない` 方向へ鳴きと反響が働く | 婚礼前の戸口灰印をついばむ | 呼び声の最後だけ返して締めを壊す | `SEC-W05-02` の読み替え |
| `ECH-MON-10` | `MON-002` タグツツキ / `MON-017` フダガニ | `番号穴` を餌場の入口にする | 村の札穴木屑を巣材にする | 岬の札穴に甲片を擦りつける | `CL-056`, `CL-057` |
| `ECH-MON-11` | `MON-008` ユビガラス / `MON-022` コエガエシ | 人の呼び声を `最後だけ残す` | 役割名だけ真似る | 呼び声の最後だけ返す | `call fragment` 系 secret の共通線 |
| `ECH-MON-12` | `MON-010` トウモリノコ / `MON-014` トモシガ / `MON-020` ムメイボタル | 光が記録する `門前 / 宿帳 / 墓前` の差 | 主人公前だけ風に逆らう | 帰れない客の灯へ寄る | 無銘墓で待たれている名へ降りる |

### 4.1 payoff の原則

- 正解は `同種です` でなく `同じ pressure が別の媒体へ出ている` に置く
- 配合は relation の確定でなく `この組み合わせも腑に落ちる` の段階で解けるようにする
- 図鑑の二段目や hidden spawn は、relation の再確認に使う

---

## 5. Non-Monster Echo Weave

### 5.1 NPC と生活物の echo

| echo_id | village / world surface | mirror surface | 伝えたいこと |
|---------|-------------------------|----------------|--------------|
| `ECH-NPC-01` | カジが二人分の器を片づけかけて戻す | `W-005` 待ち器回廊の小祭壇 | `待つ` は情と保身が分かれない |
| `ECH-NPC-02` | ヒサメが布裏へ一文字を隠す | `W-015` 黒布裏の家名縫い | 名は消すより裏へ回す方が多い |
| `ECH-NPC-03` | サエが帳面を閉じる前に灰を払う | `W-002` 判乳棚の灰匙束 | 記録と判定が同じ灰を使う |
| `ECH-NPC-04` | タズリが杭を削る手つき | `W-004` 通行札の削り直し台 | 境界標識と通行証が同じ実務にある |
| `ECH-NPC-05` | ミナワが歌の末尾だけ飲み込む | `MON-008`, `MON-022` の呼び返し | 声の欠けは共同体側にもある |
| `ECH-NPC-06` | クロベの灰窯が弔い灰と帳面灰を兼ねる | `W-005` 無煙供香札 / `W-003` 帳場乾燥 | 生活の資材が共同の罪を支える |
| `ECH-NPC-07` | ユラが布を返し折りに畳む | `W-006` 借り鈴束の返却結び | 戻るものは本人でなく記号だけでもよい社会 |
| `ECH-NPC-08` | オトが写し紙だけ抜く | `W-007` 本名欄だけ削る role sheet | 若い世代も `全部は消さない` 方向へ学習している |

### 5.2 Item と素材 provenance の echo

| item / cluster | subtle hint | delayed payoff |
|----------------|-------------|----------------|
| `item_record_tagcase` / key items | `借り名札`, `灰印片`, `宿名灯`, `通行鋲` がほぼ同寸で収まる | `証明物は用途が違っても同じ slot economy で作られている` |
| `item_record_inkpaste` | 帳面だけでなく badge や墓札の削り直し痕も浮く | `記録改竄と身分改竄が同じ技術帯にある` |
| `item_record_belltube` | 宿灯の微細な音孔差と借り鈴の音程差を拾う | `名を音で代理する文化圏` を感じる |
| `item_record_namefoil` | 貼り替え痕は紙だけでなく布札や木札にも残る | 名札と役名札の違いが薄いと見せる |
| `item_field_silentcloth` | 鐘, 呼び返し, 門反応を同時に鈍らせる | `音の管理が belonging の管理でもある` |
| `item_key_gravesalt` / `item_key_passpeg` | 塩と鋲は見た目が違っても `閉じる` 方向の key として同じ位置へ置かれる | W-005 以降の gate / memorial 接続 |

### 5.3 言い換え語の連鎖

| root euphemism | world variants | 読ませたいこと |
|----------------|---------------|----------------|
| `回す` | `谷下へ回す`, `裏庭へ回す`, `潮待ちへ回す`, `待ちへ回す`, `余りへ回す`, `下段へ回す` | expel や discard を言わず routing に言い換える文化 |
| `借り` | `借り名`, `借り乳布`, `借り灯`, `借り鈴`, `借り役名` | belonging を temporary token にする手つきが各地で反復する |
| `落ち着かせる` | 札を落ち着かせる, 香を落ち着かせる, 鈴を落ち着かせる | violence を calm へ言い換える共同体語 |
| `戻る / 還る` | 帰れない旅人, 戻り嫁, 還らぬ者, 帰り道でない別門筋 | return の意味が世界ごとにずれる |

---

## 6. Map Placement Ledger

| world | placement | faint echo | payoff |
|-------|-----------|------------|--------|
| `W-002` | `継乳棚` の slot 幅 | `W-007` の badge 棚とほぼ同じ寸法 | `CL-061` |
| `W-002` | `灰塚見張り台` の結び紐 | `W-005` 待ち器の返し結びと同型 | `CL-058` |
| `W-003` | `灯預宿` の灯 hook | `W-001` 借り名札の穴幅と同じ金具癖 | `CL-056` |
| `W-003` | `裏帳格子庫` の分銅縁 | `判乳鉢` と同じ半月状の食痕 | `ECH-MON-01` |
| `W-004` | `検潮棚` の peg rack | 村畜舎の札棚と同じ間隔 | `CL-057` |
| `W-004` | `黒札波蝕棚` の袋結び | `W-006` 借り鈴束の返却結びへ繋がる | `CL-060` |
| `W-005` | `供香小屋` の仕入れ札 | 宿灯番号と同じ連番の打ち方 | `ECH-MON-02` |
| `W-005` | `待ち器回廊` の器間隔 | 開始村カジ宅の二器配置と同じ | `ECH-NPC-01` |
| `W-006` | `税縄棚` の色替え縄 | 空家封じ紐と同じ返し順 | `CL-059` |
| `W-006` | `古符橋脚` の削り直し刻み | 人名 -> 符号の過渡痕が見える | `CL-060` |
| `W-007` | `役名工房` の削り粉箱 | 宿鍵札と badge の切り屑が混じる | `ECH-MON-03` |
| `W-007` | `祖棚廊` の棚間隔 | `待ち器回廊` と同じ pair spacing | `CL-061`, `CL-062` |

---

## 7. Payoff Placement Rules

| payoff type | 置き場所 | 使い方 |
|-------------|----------|--------|
| `soft payoff` | ambient prop, NPC pause, encounter演出 | 気づいた人だけが relation を仮説化できる |
| `medium payoff` | secret ledger, codex 2 行目, record item 使用時の追加文 | 2 接点を見た後に確信度を上げる |
| `hard payoff` | hidden breed recipe, optional side scene, late ledger proof | relation が wider system の一部だったと固まる |

### 7.1 実装優先順

1. map prop と inspect 文
2. hidden pocket の reward text
3. record item 使用時の差分文
4. breed hint / codex 2 行目

---

## 8. QA Checklist

- 1 つの relation が同じ世界の同じ媒体だけで完結していないか
- relation を知らなくても mainline が分かるか
- relation を知ると `設定が深い` でなく `制度が広い` と感じるか
- monster だけに寄らず、物, 人, 地形, 語彙にも echo が散っているか
