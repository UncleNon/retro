# 08. Historical Texture Research Ingestion

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **役割**: 実在史料から得た手触りを、設定へどう抽象化して入れるかの変換ルール
> **参照元**:
> - `docs/specs/story/05_real_incident_inspiration_policy.md`
> - `docs/specs/story/06_millennial_geopolitics_and_personages.md`
> - `docs/specs/worlds/05_world_catalog_and_budget.md`
> - `docs/specs/worlds/07_world_sheet_contract.md`

---

## 1. 目的

- `歴史っぽい雰囲気` で終わらせず、制度、物、言葉、生活癖として取り込む
- 実在の悲劇や宗教実務をそのまま写さず、設定上の機能へ分解する
- 調査メモが world sheet と勢力運用へ直結するようにする

---

## 2. 摂取ルール

1. 実在史料から取るのは `構造`, `媒体`, `運用の癖` であって、事件そのものではない
2. 1 つの史料は、必ず `人間関係 / 制度 / 小道具` の 3 点に分解してから使う
3. 調査由来のモチーフは、最低 2 世界以上で変奏して使う
4. 実在の宗教・戦争・災害の被害者表象を、娯楽的ショックへ直結させない
5. 出典の強さは `公的機関 / archive / museum / university / professional extension` を優先する

---

## 3. 使う史料と取り込み先

| research_id | 史料 / 出典 | 史料の要点 | 設定へ変換する核 | 主な投入先 |
|-------------|-------------|------------|------------------|------------|
| `R-01` | [Surrey County Council: Early parish registers](https://www.surreycc.gov.uk/culture-and-leisure/history-centre/marvels/early-parish-registers) / [Parish registers](https://www.surreycc.gov.uk/culture-and-leisure/history-centre/researchers/guides/parish-registers) | 教会 registers は形式が不統一で、写しや欠落や追記が混在する | `一見公的だが穴だらけの台帳`, `写本文化`, `欠落が差別になる` | `W-010`, `W-018`, `開始村記録`, FAC-03 |
| `R-02` | [National Records of Scotland: Old Parish Registers](https://www.nrscotland.gov.uk/learning-and-events/research-guides/old-parish-registers/) / [Church registers](https://www.scotlandspeople.gov.uk/guides/church-registers) | 旧 register は不完全で、名前表記揺れや未記載が多く、死児の名の再利用もある | `同名の重なり`, `母名欠落`, `後年補記`, `正しいはずの台帳の不確かさ` | `W-009`, `W-013`, `W-018`, 開始村 9件 |
| `R-03` | [Magyar Nemzeti Levéltár: Parish registers](https://mnl.gov.hu/angol/mnl/ol/parish_registers) | 1563 の Council of Trent 後、定期 register が普及。 household census 的な `Status Animarum` や duplicate copy も発達 | `家単位の魂台帳`, `複本`, `家ごとの監督`, `地方と中央の二重保存` | `W-010`, `W-018`, `継聖郭庁`, FAC-03 / FAC-04 |
| `R-04` | [ICRC: The agony and the uncertainty](https://www.icrc.org/en/document/agony-and-uncertainty-missing-loved-ones-and-ambiguous-loss) / [Missing persons must be searched for](https://www.icrcnewsroom.org/story/en/862/missing-persons-must-be-searched-for-their-families-must-receive-answers) | 行方不明は grief を凍らせ、法的・経済的・家族的停滞を生む | `待ち続ける家の作法`, `相続停止`, `再婚の宙吊り`, `曖昧な弔い` | `W-005`, `W-015`, `W-017`, 開始村, FAC-04 |
| `R-05` | [Imperial War Museums: What Is The Cenotaph?](https://www.iwm.org.uk/history/what-is-the-cenotaph) | 空の墓は `遺体なき死` に対する tangible mourning の場になる | `空碑`, `無名墓`, `個々人が意味を投影できる慰霊物` | `開始村空碑`, `W-005`, `W-017`, `W-021` |
| `R-06` | [Mystic Seaport: Bill of Health](https://research.mysticseaport.org/item/l006405/l006405-c005/) / [University of Delaware: Ships' bills of health](https://findingaids.lib.udel.edu/repositories/2/resources/1674) / [Peabody Essex Museum: International Marine Health Certificates](https://pem.as.atlas-sys.com/repositories/2/resources/879) | 出港地の健康状態や cargo, crew, passengers を記す海上証明書が、 quarantine と通行管理を支えた | `清浄証 / 疑証 / 汚証`, `港の健康証が身分証を兼ねる`, `航路と病の言い換え` | `W-004`, `W-012`, `W-019`, FAC-02 / FAC-06 |
| `R-07` | [Hogs, Pigs, and Pork: Baby Pig Management – Birth to Weaning](https://swine.extension.org/baby-pig-management-birth-to-weaning/) / [Penn State: RFID tags for use in swine](https://extension.psu.edu/rfid-tags-for-use-in-swine-in-pennsylvania/) | 耳 notch や tag は pedigree, litter, traceability のための実務識別 | `耳標 / 切り欠きが ownership と lineage を兼ねる`, `読めない識別は存在しないに近い` | `W-001`, `W-008`, `W-016`, 開始村畜札 |
| `R-08` | [Walters Art Museum: Pilgrim Badge](https://art.thewalters.org/detail/36029/pilgrims-badge/) / [British Museum: pilgrim badge](https://www.britishmuseum.org/collection/object/H_OA-665) | 巡礼 badge は安価な lead 製で、聖地訪問の記念かつ可視の身分証になる | `巡礼印`, `布に縫う badge`, `信仰が携帯証票化する` | `W-011`, `W-015`, FAC-04, 黒布巡礼 |
| `R-09` | [Cooper Hewitt: Make Do and Mend](https://www.cooperhewitt.org/2017/01/03/make-do-and-mend-the-art-of-repair/) / [Extreme Mending](https://www.cooperhewitt.org/2012/11/06/extreme-mending/) / [V&A: Visible Mending Workshop - Sashiko](https://www.vam.ac.uk/event/95dGgqLLanE/p22044-visible-mending-workshop-spring-23-session1) | 修繕は節約だけでなく skill, care, lineage を可視化する。 patch は履歴になる | `傷を隠さない継ぎ`, `修繕跡の家格`, `直された物が家系の正統性を帯びる` | `W-016`, `W-020`, 炉雪諸家 |

---

## 4. 要員分解 / 要素分解テンプレート

調査由来の要素は、以下の 6 つへ分けて投入する。

| 分解先 | 質問 | 例 |
|--------|------|----|
| `制度` | それは誰が記録し、誰が監督するか | duplicate register, clean bill, mortcloth fee |
| `人間関係` | それで誰が待たされ、誰が得するか | 未亡人の再婚停止、家督据え置き、宿主の賄賂 |
| `小道具` | プレイヤーが触れる物は何か | 空碑、鈴筒、耳 notch、巡礼 badge |
| `言葉` | 現地の言い換えは何か | `死` を `閉じた`, `失踪` を `返せない` と呼ぶ |
| `建築` | どの壁・棚・道に痕跡が残るか | 札棚、検疫桟橋、黒布掛け、修繕壁 |
| `抜け道` | 貧しい人はどう cheap 版を使うか | 代理供養、偽 clean pass, 借り badge, 安い灰 |

---

## 5. 変換パターン

### 5.1 台帳史料の変換

元史料:

- 不統一な記録様式
- 欠落
- 複本
- 後年補記

設定変換:

- `正しい記録` でなく `都合の良い整合`
- 現地写本と中央複本の食い違い
- 村では死、中央では転出、寺では未完葬送
- 同名重複を悪用した身分のすり替え

主な投入先:

- `W-010 群書の塩庫`
- `W-018 二署の法台`
- 開始村の `SV-08`, `SV-09`

### 5.2 ambiguous loss の変換

元史料:

- 不在が確定しない
- 相続、土地、婚姻が止まる
- grief が共同体全体に沈殿する

設定変換:

- 空碑や空部屋が消えない
- 器だけ残す
- 家の誰かがずっと食事を一人分余計に用意する
- `死んだことにすると楽だが、そう言えない` 人が複数いる

主な投入先:

- 開始村
- `W-005`
- `W-015`
- `W-017`

### 5.3 巡礼 badge / 通行証の変換

元史料:

- 巡礼の可視証票
- 港の health certificate
- 旅人の正当性を見せる紙

設定変換:

- 身分証と宗教証明が混じる
- 布に縫い付けた badge の有無で待遇が変わる
- 港では clean pass がなければ cargo より先に人が止まる
- 偽 badge, 借り badge, 期限切れ pass の市場が生まれる

主な投入先:

- `W-004`
- `W-011`
- `W-012`
- `W-015`

### 5.4 修繕文化の変換

元史料:

- 破れや欠損を skill と care で延命
- patch が履歴そのものになる

設定変換:

- 血統修復が器修復と同じ文法で語られる
- 継ぎ目が美徳でもあり、偽装でもある
- `修繕済み` が名誉と恥の両方になる

主な投入先:

- `W-016`
- `W-020`
- 炉雪諸家の婚姻観

---

## 6. 世界別の投入メモ

| world_id | 重点 research | 具体の盛り込み方 |
|----------|---------------|------------------|
| `W-004` | `R-06` | clean / suspected / foul に相当する通行札の格差を入れる |
| `W-005` | `R-04`, `R-05` | 空碑と香なし供養を `待つための弔い` として置く |
| `W-008` | `R-07` | 印と耳切り欠きの読みが ownership と lineage の言語になる |
| `W-010` | `R-01`, `R-02`, `R-03` | 濡れた台帳、複本、母名欠落、後年補記を混ぜる |
| `W-012` | `R-06` | health certificate と荷札の棚を隣接させ、 human cargo の気配を出す |
| `W-015` | `R-04`, `R-05`, `R-08` | 黒布と巡礼 badge で grief と通行権を兼ねさせる |
| `W-016` | `R-07`, `R-09` | 焼継ぎ文様を pedigree 証明へ転用する |
| `W-018` | `R-01`, `R-02`, `R-03` | 二署の複本と neglected entry 的な後補記を制度化する |
| `W-021` | `R-04`, `R-05` | 確定不能な喪失を camp ごとの待ち方の差として描く |

---

## 7. やってはいけない摂取

- 実在の戦争失踪や災害の固有事件を、そのまま quest にしない
- 実在宗教の儀礼語を少し変えただけで使わない
- 実在の民族差別史を、敵役の flavor として消費しない
- 史料の悲惨さを `不気味で面白い` に短絡させない
- research した事実をそのまま lore dump しない

---

## 8. 次の運用

- world sheet を書くとき、最低 1 つはこの文書の `R-01〜R-09` を参照して変換する
- 同じ research を別世界で使うときは `媒体` を変える
- 新しい research を足すときは、`史料の強さ / 変換核 / 投入先 / 禁止事項` まで書く

---

## 9. QA Checklist

- 調査メモが `世界の見た目` でなく `制度の運用` に落ちているか
- 史料を 1 世界だけの gimmick に閉じず、複数世界へ変奏できているか
- 苦しみの史料が `人の都合` と `家の事情` に接続しているか
- 現地の小道具と語彙に research の痕跡が見えるか
- 実在事件のコピーになっていないか
