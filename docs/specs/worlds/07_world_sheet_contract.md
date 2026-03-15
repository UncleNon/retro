# 07. World Sheet Contract

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **役割**: 1 世界を `制作に回せる具体性` まで固定するための共通 schema
> **参照元**:
> - `docs/specs/story/01_story_bible.md`
> - `docs/specs/story/02_culture_faction_matrix.md`
> - `docs/specs/story/03_foreshadow_allocation_map.md`
> - `docs/specs/story/04_main_story_beats_and_world_sequence.md`
> - `docs/specs/story/06_millennial_geopolitics_and_personages.md`
> - `docs/specs/story/10_starting_arc_engagement_playbook.md`
> - `docs/specs/story/11_session_pacing_and_curiosity_contract.md`
> - `docs/specs/worlds/05_world_catalog_and_budget.md`
> - `docs/specs/worlds/06_settlement_layout_and_route_rules.md`
> - `docs/specs/worlds/08_world_sheet_template_and_variation_rules.md`
> - `docs/specs/content/08_starting_region_ecology_and_monster_web.md`

---

## 1. 目的

- `05_world_catalog_and_budget.md` の行台帳と、個別世界詳細仕様のあいだを埋める
- 21 世界を同じ粒度で比較できるようにし、どこが未確定かを見える化する
- `人間関係`, `制度の歪み`, `日用品に沈殿した歴史`, `門/モンスター圧` を 1 枚に載せる

---

## 2. この文書で固定する責務

### 2.1 world sheet が持つ責務

1. その世界が `何を証明するか` を一文で固定する
2. 禁忌がどう生活運用へ変換されているかを示す
3. `Power / Faith / Work / Blood / Monster / Boundary` の 6 軸を具体で埋める
4. 拠点、道順、ダンジョン、証拠物、NPC slot を最低限確定する
5. clue / corridor / chain / gate condition を既存台帳へ接続する

### 2.2 world sheet が持たない責務

- 個別 NPC の全文台詞
- モンスター 1 体ごとの完全数値
- タイル座標レベルのマップ配置
- カットシーンの台本全文
- 原初世界や上位存在の断定

これらは `content/*`, `systems/*`, `individual world detail docs` に逃がす。

### 2.3 child surfaces

world sheet は 1 枚で世界を完結させない。以下の child surface を前提にする。

| child surface | 役割 |
|---------------|------|
| `story hook surface` | foreshadow, return shock, local answer / bigger question, research texture を保持する |
| `ecology surface` | gate state, habitat revision, illegal use, food web, monster misuse を保持する |
| `runtime row` | `world_master.csv` に落とす最小 runtime 属性だけを保持する |

runtime row は world sheet の要約であり、world sheet の代替ではない。

---

## 3. 参照優先順位

| レイヤ | 正とする文書 | world sheet でやること |
|--------|--------------|-------------------------|
| 物語契約 | `story/01`, `story/04` | その世界が受け持つ reveal と責任範囲を写す |
| 文化 / 勢力 | `story/02`, `story/06` | 具体の地方運用、方言、私益へ落とす |
| 伏線 | `story/03` | `CL-xxx` を初出 / 回収で接続する |
| 予算 / world row | `worlds/05` | map, settlement, monster, gimmick 予算を守る |
| 導線規格 | `worlds/06` | 拠点とルート骨格をルール内で具体化する |

world sheet は上位文書を上書きしない。
矛盾が出た場合は world sheet 側を修正する。

---

## 4. 必須 section

各世界は、少なくとも以下 10 section を埋めたときに `concrete` と見なす。

### 4.1 Proof Contract

最低限必要:

- `world_id`
- 一文 premise
- `world_function`
- `何を証明する世界か`
- `corridor_id`, `chain_id`
- `bloc / front factions`
- `clue IDs`
- `signature_evidence_object`

### 4.2 Taboo Surface / Actual Operation / Silence Circuit

最低限必要:

- 表向きの禁忌
- 実務上どう運用されるか
- 誰が沈黙を支えるか
- 生活者が使う安い抜け道
- 禁忌に触れた者をどう言い換えるか

### 4.3 Six Axes Concrete

| 軸 | 必須中身 |
|----|----------|
| `Power` | 支配者、徴収単位、現地の反抗点 |
| `Faith` | 塔 / 門 / 失踪の意味づけと教義の綻び |
| `Work` | 主産業、流通、誰が汚れ仕事を担うか |
| `Blood` | 婚姻、養子、相続、名前の継ぎ方 |
| `Monster` | 社会的位置、法的位置、搾取のされ方 |
| `Boundary` | 越境、改名、未登録者、門接触者への扱い |

### 4.4 Settlement / Route / Dungeon Skeleton

最低限必要:

- 拠点 1 つ以上
- メインルート 3〜6 ビート
- 地元民が避ける場所 1 つ
- 中盤で意味が変わる建築物 1 つ
- ボス前に置く `制度の証拠` 1 つ

### 4.5 Local Term & Prop Registry

最低限必要:

- 現地の塔呼称 1
- 現地の失踪言い換え 2
- 禁句 / 避ける語 2
- 小道具 4
- 建築癖 2

### 4.6 NPC Role Slots

最低限必要:

- 地元の実務者
- 地元の被害者家族
- 制度の末端加担者
- よそ者 or 外部監査役

各 slot には `私的欲望` と `隠していること` を 1 つずつ持たせる。

### 4.7 Monster Ecology & Boss Concept

最低限必要:

- 優勢 family
- その世界でモンスターが何として見られるか
- 地形との噛み方
- ボスがプレイヤーへ教える system lesson

### 4.8 Clue / Gate / Resolution

最低限必要:

- `CL-xxx` 2 件以上
- gate 条件
- クリア時に何が確定し、何がまだ曖昧か
- `post-clear` で会話や物流がどう変わるか

### 4.9 Visible / Hidden Flow

最低限必要:

- 目に見える流通物
- 実際に流れているもの
- 誰が儲けるか
- 誰が帳消しになるか

### 4.10 Daily History Residues 3x

必須 3 点:

- `家の中` に残る歴史痕 1
- `市場 / 制度` に残る歴史痕 1
- `建築 / 生活物` に残る歴史痕 1

---

## 5. 行台帳に持ち込み、個票に逃がすもの

### 5.1 sheet 本体に持つ

- 支配構造
- 歴史の傷
- 火種
- hush network
- shortcut market
- 証拠物
- clue 接続
- 3〜4 名の role NPC

### 5.2 子文書へ逃がす

- 完全な NPC 会話
- map ごとの座標
- native monster encounter tables
- shop inventory
- cutscene timing

---

## 6. 重複禁止ルール

1. `story/06_millennial` にある年表や国家説明を長くコピペしない
2. `worlds/05` の world row をそのまま再掲しない
3. 同じ説明を世界ごとに言い換えず繰り返さない
4. `この世界も同じように` で済ませない
5. 人間関係を `住民たちは恐れている` の一文で片付けない

---

## 7. 書き味の基準

- 抽象語より `誰が何をしたいか` を先に書く
- 共同体を一枚岩にしない
- 優しさと卑怯さを同居させる
- 歴史は演説より `器 / 布 / 壁 / 台帳 / 歌詞 / 札` に残す
- 正義の側にも `保身`, `負債`, `家の事情`, `出世欲` を混ぜる

---

## 8. world sheet 最低カラム

| カラム | 内容 |
|--------|------|
| `world_id` | join key |
| `one_line_proof` | 何を証明する世界か |
| `bloc_and_front` | 所属圏と前線勢力 |
| `historical_wound` | 歴史の傷 |
| `current_flashpoint` | 今の火種 |
| `taboo_surface` | 表向き禁忌 |
| `actual_operation` | 実務上の歪み |
| `silence_circuit` | 沈黙回路 |
| `shortcut_market` | 安い抜け道 |
| `hub_and_route` | 拠点と主要道筋 |
| `local_actors` | 3〜4 名の role actor |
| `evidence_object` | 証拠物 |
| `visible_hidden_flow` | 表物流 / 裏物流 |
| `lexicon` | 避ける語、言い換え語 |
| `daily_residues` | 生活に残る 3 痕 |
| `monster_law` | モンスターの法的位置 |
| `boss_lesson` | ボスが教えること |
| `clue_ids` | 接続 clue |
| `gate_condition` | 門条件。`worlds/08` の canonical block に従う |
| `post_clear_shift` | クリア後の変化 |

---

## 9. QA Checklist

- その世界だけの `私益` が見えるか
- 禁忌が宗教文句でなく生活運用になっているか
- 証拠物が物語と gameplay の両方に効くか
- 現地 NPC が `解説役` でなく `自分の都合で喋っている` か
- 歴史痕が 3 か所以上に沈殿しているか
- clue が `story/03` と食い違っていないか
- クリア後に町の空気が 1 段変わるか
- `この世界を抜くと何が証明不能になるか` を説明できるか
