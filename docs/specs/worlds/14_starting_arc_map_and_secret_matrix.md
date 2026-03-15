# 14. Starting Arc Map And Secret Matrix

> **注記**: この草稿は [14_starting_arc_map_and_secret_blueprints.md](./14_starting_arc_map_and_secret_blueprints.md) へ統合済み。以後の更新はそちらを正とする。

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16
> **役割**: 開始村から `W-005` までの map topology, hidden route, revisit payoff を同じ粒度で固定する
> **参照元**:
> - `docs/specs/worlds/01_starting_village_layout.md`
> - `docs/specs/worlds/03_first_beyond_gate_world.md`
> - `docs/specs/worlds/06_settlement_layout_and_route_rules.md`
> - `docs/specs/worlds/09_act_i_world_sheets.md`
> - `docs/specs/worlds/10_act_ii_world_sheets.md`
> - `docs/specs/story/10_starting_arc_engagement_playbook.md`
> - `docs/specs/content/08_starting_region_ecology_and_monster_web.md`
> - `docs/specs/content/09_act_i_ii_monster_expansion_and_discovery_pack.md`
> - `docs/specs/systems/17_encounter_authoring_and_balance_sandbox.md`

---

## 1. 目的

- `世界はあるが map loop が弱い` 状態を防ぐ
- 各 world に `safe route / danger route / hidden route / revisit shift` を最低 1 本ずつ与える
- runtime の `zone_id` と story 側の route beat を結び、実装が lore から浮かないようにする

---

## 2. Zone Mapping

| location | runtime zone_id | route beat 上の役割 | その場で教えること |
|----------|-----------------|---------------------|----------------------|
| 開始村 | `ZONE-VIL-TOWER` | 村外れの異物導線 | 村だけ encounter が切れていて、塔前だけ空気が変わる |
| `W-001` | `ZONE-W01-GATE` | 到着 / 文法提示 | 札と鈴が環境インフラになっている |
| `W-001` | `ZONE-W01-FIELD` | main route | `marked -> recruit` の基礎 |
| `W-001` | `ZONE-W01-MARSH` | danger route | `sleep / poison / wet` を短く学ぶ |
| `W-001` | `ZONE-W01-SHRINE` | boss approach | 祠と所属誤誘導の結びつき |
| `W-002` | `ZONE-W02-GATE` | 到着 / 見た目の変化 | 灰と乳が自然物の顔をした制度だと見せる |
| `W-002` | `ZONE-W02-SLOPE` | safe route | 家畜目線では正しそうに見える判定文化 |
| `W-002` | `ZONE-W02-PASTURE` | main route | 家畜管理と婚資管理が同じ語彙になる |
| `W-002` | `ZONE-W02-CAVE` | danger route | 判定器具の裏と不正の痕跡 |
| `W-002` | `ZONE-W02-RIDGE` | boss approach | 母屋の視線と選別圧 |
| `W-003` | `ZONE-W03-GATE` | 到着 / 物流提示 | 宿場では移動そのものが管理対象 |
| `W-003` | `ZONE-W03-LODGES` | main route | 宿名, 鍵札, 売買の接続 |
| `W-003` | `ZONE-W03-BACK` | safe route | 宿の裏だけ会話と戦闘が噛み合う |
| `W-003` | `ZONE-W03-ANNEX` | boss approach | 帳面そのものがモンスター資源になる |
| `W-004` | `ZONE-W04-PASS` | 到着 / 公的選別の顔 | 通行札が存在証明になる |
| `W-004` | `ZONE-W04-LEDGER` | main route | 断崖移動と検札圧を実務化した中枢 |
| `W-004` | `ZONE-W04-BACK` | danger route | 密輸と疑い札の裏路 |
| `W-004` | `ZONE-W04-PIER` | boss approach | 門事故を神罰に偽装する空間 |
| `W-005` | `ZONE-W05-GATE` | 到着 / ルール提示 | 香を断つことが map 運用に組み込まれている |
| `W-005` | `ZONE-W05-GARDEN` | main route | 空碑と待機葬送の標準風景 |
| `W-005` | `ZONE-W05-CANAL` | danger route | 灰水路が attrition を強める |
| `W-005` | `ZONE-W05-OSSUARY` | boss approach | `閉じた扱い` を押し込む最奥 |

---

## 3. Route Topology

| location | hub / 視点 | safe route | danger route | hidden route | revisit payoff |
|----------|------------|------------|--------------|--------------|----------------|
| 開始村 | 井戸広場と記録小屋 | 主人公宅から畜舎経由で北道へ出る通常導線 | 墓地裏の湿地沿いを通ると早いが不穏物が増える | 空家裏の薪棚を調べると `外された表札跡` へ回り込める | `W-003` 後に写し帳の隠し場所、`W-005` 後に空碑の裏刻みが読める |
| `W-001` | 継札集落 | 門前から集落外れを抜ける柵沿い | 葦原を横切る短路。sleep / poison 圧が高い | 借り札の乾し棚を抜けると祠裏へ出られる | clear 後に `返名の中庭` から柵の向きが見直せる |
| `W-002` | 判乳盆 | 石灰斜面から乾草場へ回る外周 | 灰印の洞を抜ける短路。証拠は濃いが seal / fear が増える | 継乳棚の裏板を外すと `灰匙束` に先行アクセスできる | clear 後に `薄印斜面` の cradle 杭が一部抜かれている |
| `W-003` | 灯泊町 | 市場裏の荷道を通ると宿場中央を避けられる | 灯番の小径から archive へ入る短路。sleep / seal 圧が高い | 乾き井戸の底から `無窓の離れ` の荷置き場へ抜ける | clear 後に灯番号の並びが一つだけ正常化する |
| `W-004` | 潮別関 | 灯台崖を使う遠回り。戦闘数は増えるが attrition は低い | 密輸の入江を抜ける短路。mark されやすい | 検潮棚の裏梯子から `削り直し札台` を先に見つけられる | clear 後に灰宿裏路の chalk 印が消え始める |
| `W-005` | 無香墓庭 | 空碑苑を回る広い外周 | 灰水路を渡る短路。wet と fear が強い | 香断ち門の脇石を調べると `貸し墓札` の隠し棚へ出られる | clear 後に空碑の一部で `待つ` と `閉じる` の表記差が出る |

---

## 4. Secret Registry

| secret_id | world | trigger | reward | story meaning |
|-----------|-------|---------|--------|---------------|
| `SEC-VIL-01` | 開始村 | 記録小屋の梁を 2 回調べる | `item_record_rubbingset` | 村の違和感は会話より先に物へ刻まれている |
| `SEC-VIL-02` | 開始村 | 空家裏から薪棚を抜ける | `CL-004` 補強会話 | 空家管理も制度の一部だと分かる |
| `SEC-W01-01` | `W-001` | 乾し棚の濡れ札をすべて調べる | `item_field_chalktag` | 所属仮止めは環境の一部になっている |
| `SEC-W01-02` | `W-001` | 祠裏の鈴順を正しく鳴らす | `item_bait_bellgrain` | 鈴は呼び声の代用品である |
| `SEC-W02-01` | `W-002` | 継乳棚の裏板を押す | `item_catalyst_ashseed` | 家系判定と配合触媒の語彙が接続する |
| `SEC-W02-02` | `W-002` | 判乳盆の水面で別名を読む | `CL-012` 先行認知 | 同一人物へ別名が重ねられている |
| `SEC-W03-01` | `W-003` | 宿鍵札の欠番を 3 つ照合する | `item_cure_focussalt` | 匿名は保護でなく圧縮実務でもある |
| `SEC-W03-02` | `W-003` | archive の棚順を直す | `MON-016` rare hint | ネムインクが一行目から食う理由が分かる |
| `SEC-W04-01` | `W-004` | 検潮棚の裏梯子を降りる | `BRD-0007` hint | 公的選別が apex を作る |
| `SEC-W04-02` | `W-004` | 入江の無番号札を 4 枚集める | `item_field_bonerope` | 札のない者は逃走具に頼るしかない |
| `SEC-W05-01` | `W-005` | 貸し墓札の棚で同じ札を二度読む | `BRD-0008` hint | 未完葬送が hidden recipe に直結する |
| `SEC-W05-02` | `W-005` | 空碑の並びを `待つ / 閉じる / 待つ` で読む | `CL-017` 補強 | 墓苑の分類そのものが story clue である |

---

## 5. Landmark And Status Pressure

| location | 必須ランドマーク | 主 status pressure | map で見せるべき異常 |
|----------|------------------|--------------------|------------------------|
| 開始村 | 井戸広場, 記録小屋, 空碑, 北道杭 | なし | 同じ村なのに塔前だけ ambient が死ぬ |
| `W-001` | 借り札の乾し棚, 濡れ札の浅水域, 内向きの柵 | `sleep`, `poison`, `wet` | 柵と札が自然地形のように置かれている |
| `W-002` | 判乳盆, 継乳棚, 薄印斜面, 灰匙束 | `mark`, `fear`, `softened` | 乳と灰の道具が家の景色に溶け込む |
| `W-003` | 灯番棚, 無窓の離れ, 裏荷庭の油水路 | `sleep`, `seal`, `hushed` | 匿名が暖かい宿の顔で包装されている |
| `W-004` | 三色札台, 検潮棚, 待機檻, 封門 | `marked`, `rush`, `break` | 公的選別の設備がそのまま捕食圧を作る |
| `W-005` | 香断ち門, 空碑苑, 灰水路, 無銘納骨穴 | `fear`, `sleep`, `wet` | 弔い施設が `終わらせない運用` の装置にも見える |

---

## 6. Return-State Matrix

| timing | state change | player emotion target |
|--------|--------------|-----------------------|
| `W-001` clear 後 | 開始村の歌詞と `W-001` の鈴語彙が繋がり、空家がただの噂でなくなる | 村だけが異常ではない |
| `W-002` clear 後 | 婚礼布, 乳桶, 産婆話が一斉に重くなる | 家族の言葉が安全地帯でなくなる |
| `W-003` clear 後 | 帳面を閉じる音, 鍵, 戸口札が全部気持ち悪くなる | 匿名が自由でなく処理だと分かる |
| `W-004` clear 後 | 杭と柵が `守り` でなく `留める向き` に見える | 制度への不信が確信へ変わる |
| `W-005` clear 後 | 墓, 香, 待つことの美しさに管理の匂いが混ざる | 優しさと搾取の線が消える |
