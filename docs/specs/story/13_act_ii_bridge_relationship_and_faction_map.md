# 13. Act II Bridge Relationship And Faction Map

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16
> **役割**: `W-006〜W-007` の `人間関係`, `local front`, `勢力圧`, `伏線担務` を、Act II 前半の橋渡し層として固定する
> **参照元**:
> - `docs/specs/story/09_silence_economy_and_powerbrokers.md`
> - `docs/specs/story/10_starting_arc_engagement_playbook.md`
> - `docs/specs/story/12_starting_arc_relationship_and_faction_map.md`
> - `docs/specs/story/14_cross_system_echo_and_discovery_lattice.md`
> - `docs/specs/content/09_act_i_ii_monster_expansion_and_discovery_pack.md`
> - `docs/specs/worlds/10_act_ii_world_sheets.md`

---

## 1. 目的

- `W-006〜W-007` を単なる cultural detour で終わらせず、**失踪 / 弔い / 記号化 / 役名化** が同じ圧力線だと読めるようにする
- `W-005` の grief management から `W-007` の role-name market まで、人が人を `数えやすい形` へ変えていく流れを固定する
- clue `CL-019〜CL-022` を `誰がどの都合で滑らせるか` まで具体化する

---

## 2. `W-006` 鈴結びの湿地 Fronts

### 2.1 local blocs

| bloc_id | 名称 | 中心人物 | 表の目的 | hidden motive | 嫌がる露見 |
|---------|------|----------|----------|---------------|------------|
| `MIC-W06-01` | 余り圧縮派 | ハユ, ロク | 保留者数を減らして家を楽にする | missing を `余り` として数え直し、税と食卓を守りたい | 同じ `余り結び袋` が複数家で回っていること |
| `MIC-W06-02` | 借り鈴融通派 | セイカ, ネリ, 筏場の渡し手 | 不在者の家へ一時的な慰撫を回す | 借り鈴を流して grief と移動を商売に変える | 生者用と不在者用で同じ鈴が再利用されていること |
| `MIC-W06-03` | 家結び保全派 | 氏族古参, 戸口縄番 | 正式な家結びを守る | 継子と戻り者をいつまでも provisional に置きたい | 戸口縄の色替えが後付けだと見抜かれること |

### 2.2 key edges

| source | target | 表の関係 | hidden leverage | break point |
|--------|--------|----------|-----------------|-------------|
| ハユ | ロク | 古老と税縄計り | 保留者数を減らせば家が保つという打算が一致する | `税縄棚` の袋が使い回されていたと出る |
| ネリ | セイカ | 渡し手と祈祷師 | 兄の `余り結び` を借り鈴運用へ滑り込ませている | 同じ鈴音が別家で鳴る |
| ハユ | ネリ | 年長者と若い舟娘 | compassion を装いながら家結びの境界だけは崩さない | 兄の鈴筒だけ別符号だと露見する |
| ロク | セイカ | 徴収と慰撫の実務提携 | 仮慰撫を official relief のように帳面へ寄せている | 借り鈴束の返却札が税縄棚に混じる |

---

## 3. `W-007` 削名の階市 Fronts

### 3.1 local blocs

| bloc_id | 名称 | 中心人物 | 表の目的 | hidden motive | 嫌がる露見 |
|---------|------|----------|----------|---------------|------------|
| `MIC-W07-01` | 棚位保全派 | ミヤ, 上層書記, 棚番 | 祖棚と階位棚の秩序を守る | 先祖棚と役名棚を同じ credit machine として回し続けたい | 同一人物の badge が二つの棚位へ供えられていること |
| `MIC-W07-02` | 借り役名仲介派 | エンガ, badge 仲買, 工房切削役 | 下層にも上昇口を残す | 死者役名と一夜階位章を回して debt を吸う | 死者 badge inventory が現物で残っていること |
| `MIC-W07-03` | 下層上昇派 | ソウジ, リクホ, 荷役坂の若手 | 実力で上へ上がりたい | 自分の出自を切り捨てても role を掴みたい | 借り役名で昇ったことが暴かれること |

### 3.2 key edges

| source | target | 表の関係 | hidden leverage | break point |
|--------|--------|----------|-----------------|-------------|
| エンガ | ミヤ | badge 仲買と棚番 | 祖棚の空き slot と借り役名の流通を同じ台帳で回す | `棚位裏庫` の控え帳が出る |
| エンガ | ソウジ | 仲介人と運び人 | 死者役名を貸し、階段運びで返済させている | 兄の badge と借り役名の番号が重なる |
| ミヤ | リクホ | 棚番と監査走り | 下層出身を黙認する代わりに控え帳改竄へ加担させる | 二重 badge が監査線へ流れる |
| ソウジ | リクホ | 上昇を狙う若手同士 | 互いの本名を握って role market で牽制する | `検刻関段` の暫定 lane でどちらかが売られる |

---

## 4. Faction Overlay

| world | local front | 背後勢力 | どう歪むか | 主 proof |
|-------|-------------|----------|------------|----------|
| `W-006` | 余り圧縮派 | `FAC-04`, `FAC-02` | 未完葬送の運用が、湿地税と household sorting に変質する | `符号なし新鈴`, `余り結び袋` |
| `W-006` | 借り鈴融通派 | `FAC-04`, `FAC-06` | 慰撫と流通が混ざり、 belonging が temporary commodity になる | `借り鈴束`, `返却札` |
| `W-007` | 棚位保全派 | `FAC-03`, `FAC-07` | 祖先信仰が badge finance へ直結する | `二重 badge`, `棚位裏庫` |
| `W-007` | 借り役名仲介派 | `FAC-03`, `FAC-06` | social mobility の顔で dead role market が回る | `一夜階位章`, `削り直し見本片` |

---

## 5. Clue Carrier Map

| clue | carrier | 初見の意味 | 後で反転する意味 |
|------|---------|------------|------------------|
| `CL-019` | `税縄棚`, ハユ, `MON-024` | 余り結びの管理は慈悲に見える | `missing を manageable count へ丸める` 実務でもある |
| `CL-020` | `借り鈴束`, ネリ, `MON-026` | 借り鈴は過渡期の救済に見える | belonging を temporary symbol にして流通させている |
| `CL-021` | `役名工房`, エンガ, `MON-027` | badge は upward tool に見える | 死者役名の再利用と debt 管理でもある |
| `CL-022` | `祖棚廊`, ミヤ, `MON-028〜029` | 棚位は祖先と役割を整える秩序に見える | 祖棚と役名棚が同じ inventory logic で回っている |

---

## 6. Reveal Ladder

| beat | 壊れる関係 | 開く問い |
|------|------------|----------|
| `Clear W-006` | ハユ ↔ ロク / ネリ ↔ セイカ | `待つこと` はどこで税と belonging の実務に変わったのか |
| `Return from W-006` | 開始村の待機継続派 ↔ 外気流入派 | 不在者を provisional にする文法は村外でも共有されていたのか |
| `Clear W-007` | エンガ ↔ ミヤ / ソウジ ↔ リクホ | 役名は出世のためか、それとも inventory のためか |
| `Return from W-007` | 開始村の帳面静穏派 ↔ 外気流入派 | 村で抜いた紙は、外の role market とどこで繋がっているのか |

## 7. Shared Props / Euphemisms

| echo | `W-006` surface | `W-007` surface | payoff |
|------|-----------------|-----------------|--------|
| `余り` | 余り結び袋, 余り小棚 | 下段行きの控え札, 暫定 lane | provisional belonging が bookkeeping へ吸われる |
| `借り` | 借り鈴束, 返却札 | 借り役名, 一夜階位章 | 一時救済が debt market に変わる |
| `削り直し` | 古符橋脚の人名削り | badge と本名欄の削り直し | 名を消すのでなく役に寄せる実務 |
| `色替え` | 戸口縄の色差し替え | 棚位色分けの整理 | 改善ではなく分類の最適化に見せる |

---

## 8. Writing Rules

- `W-006` は compassion と圧縮を同じ手つきで出す
- `W-007` は aspiration と搾取を同じ階段で出す
- confession より `帳面 / 棚 / 鈴 / 結び / badge` の運用差で露見させる
- player には `誰が正しいか` より `誰がどのコストを他人へ送ったか` を先に読ませる

## 9. QA Checklist

- `W-006` が `湿地の祈り` でなく `湿地の bookkeeping` としても読めるか
- `W-007` が `都市の身分制度` でなく `role inventory` として立っているか
- `CL-019〜CL-022` が人間関係の break point と結びついているか
- `W-005` の grief management と `W-007` の role market が別問題に見えすぎていないか
