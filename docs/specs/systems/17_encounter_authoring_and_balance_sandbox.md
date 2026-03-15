# 17. Encounter Authoring And Balance Sandbox

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **役割**: `zone_master.csv` / `encounter_table.csv` の上にある、遭遇設計の canonical authoring と balance sandbox 契約
> **参照元**:
> - `docs/requirements/02_game_design_core.md`
> - `docs/requirements/05_map_and_worlds.md`
> - `docs/requirements/11_technical_architecture.md`
> - `docs/specs/systems/01_numeric_rules_and_master_schema.md`
> - `docs/specs/systems/06_randomness_policy_and_probability_budgets.md`
> - `docs/specs/systems/08_enemy_ai_and_encounter_design.md`
> - `docs/specs/systems/11_protagonist_party_and_ranch_rules.md`
> - `docs/specs/systems/13_boss_gatekeeper_and_field_modifier_rules.md`
> - `docs/specs/systems/14_item_shop_loot_and_service_contract.md`
> - `docs/specs/systems/16_monster_canonical_package_and_pipeline.md`
> - `docs/specs/worlds/05_world_catalog_and_budget.md`
> - `docs/specs/worlds/07_world_sheet_contract.md`
> - `docs/specs/worlds/08_world_sheet_template_and_variation_rules.md`
> - `docs/specs/content/04_initial_items_and_shops.md`

---

## 1. 目的

- wild encounter を `ただの出現表` でなく、`世界証明`, `勧誘欲`, `資源圧`, `ルート選択` を同時に扱う authoring 対象として固定する
- 3体パーティ前提の通常戦が、短く回るが薄くならない encounter grammar を作る
- `safe route / danger route / boss approach` の難しさを、感覚語でなく sandbox 可能な数値目標に落とす
- `world sheet`, `monster canonical package`, `zone_master.csv`, `encounter_table.csv`, telemetry を一つの文法で接続する

---

## 2. この仕様の立ち位置

### 2.1 authority

この仕様は、**encounter authoring の正** を定義する。
特に以下を authoritative に扱う。

- zone の encounter purpose
- pack composition と pressure budget
- rarity band の使用制約
- scouting pressure の目標帯
- route pair のトレードオフ
- boss 前後の遭遇 shaping
- sandbox の入出力と pass/fail

### 2.2 上書きしないもの

以下の authority は既存文書に残す。

| 主題 | authority |
|------|-----------|
| 遭遇発生式、勧誘基本式、CSV列 | `systems/01_numeric_rules_and_master_schema.md` |
| RNG 許可範囲、pity、fairness 原則 | `systems/06_randomness_policy_and_probability_budgets.md` |
| 敵AIタイプ、先制 / 不意打ち、レア個体補正 | `systems/08_enemy_ai_and_encounter_design.md` |
| 3体パーティ、牧場、bait 好み | `systems/11_protagonist_party_and_ranch_rules.md` |
| boss class, field modifier, add 規格 | `systems/13_boss_gatekeeper_and_field_modifier_rules.md` |
| item / loot / service の ID 契約 | `systems/14_item_shop_loot_and_service_contract.md` |
| monster package の canonical fields | `systems/16_monster_canonical_package_and_pipeline.md` |

この文書は、上記 authority を **遭遇設計の実務へ束ねる文書** として扱う。

---

## 3. Encounter Design Principles

### 3.1 3体パーティ原則

- 通常 wild encounter は **敵3体まで** を canonical upper bound とする
- 通常戦は `3v3` で読み切れる情報量を守る
- 脅威は headcount だけでなく、`pack role`, `status tax`, `route pressure`, `scout temptation` の組み合わせで出す
- `数が多いだけの長い戦闘` を禁止する

### 3.2 遭遇はルート選択の文法

- encounter は `ただの消耗` ではなく、`安全に進む` か `危険を踏んででも得る` かを選ばせる
- safe route は `退屈な一本道` にしてはならない
- danger route は `ただの罰ゲーム` にしてはならない
- どちらにも世界観の理由が要る

### 3.3 scouting pressure は任意の greed

- 勧誘圧はプレイヤーを誘惑するものであり、必須進行の足かせにしない
- `強い / 珍しい / world-theme に刺さる / 配合価値がある` のいずれかがあるときだけ高 scout pressure を許可する
- 近傍拠点や route reward と bait 系統が噛んでいることを前提にする

### 3.4 clue と story は RNG に乗せない

- 本編主線の clue, gate condition, 進行鍵を random encounter のみで回収させてはならない
- encounter は `世界の証拠` を増幅できるが、`唯一の回収経路` にはならない
- rare spawn は深化や再解釈に使い、本編必須の確定情報は object / NPC / boss / fixed event に寄せる

### 3.5 boss 前後は学習の導線

- boss 前の encounter は、ボスの文法を前倒しで教える
- boss 直前に新情報を詰め込みすぎない
- `直前で資源を空にする` 難しさではなく、`事前理解のある人が有利になる` 難しさにする

---

## 4. Canonical Encounter Surfaces

### 4.1 runtime で既に存在する面

| サーフェス | 役割 |
|------------|------|
| `world_master.csv` | 世界単位の level band, family bias, gate 条件 |
| `zone_master.csv` | zone ごとの歩数帯、天候、時間帯、table 紐づけ |
| `encounter_table.csv` | zone ごとの出現 row |
| `monster canonical package` | species, world presence, scoutability, battle role, recruit 基本値 |

### 4.2 この文書が定義する authoring 面

runtime export の前段として、以下の論理面を定義する。

| 論理面 | 粒度 | 役割 |
|--------|------|------|
| `encounter_zone_sheet` | 1 zone : 1 | zone の目的、圧、route 位置づけ、sandbox target |
| `encounter_pack_sheet` | 1 zone : N | どの pack がどういう役割で出るか |
| `encounter_sandbox_case` | 1 zone : N | party 条件別の simulation case |
| `encounter_balance_report` | 1 zone : N | sandbox 出力と pass/fail |

### 4.3 ID と naming

既存の `zone_id` はそのまま使う。
pack と sandbox case は、general registry 拡張前につき **typed snake_case** を canonical とする。

| 要素 | 形式 | 例 |
|------|------|----|
| `zone_id` | 既存準拠 | `zone_w001_pasture_north` |
| `encounter_pack_id` | `enc_pack_<world>_<area>_<nn>` | `enc_pack_w001_pasture_01` |
| `sandbox_case_id` | `enc_sandbox_<zone>_<profile>` | `enc_sandbox_w001_pasture_onlevel` |

### 4.4 export の原則

- `encounter_zone_sheet` から `zone_master.csv` へ export するときは、歩数帯、時間帯、天候、notes を同期する
- `encounter_pack_sheet` は row 展開されて `encounter_table.csv` へ落ちる
- runtime 側で pack の意味が失われないよう、`notes` または別 manifest に `encounter_pack_id` を残す
- `encounter_table.csv` だけを直接直し、pack / zone sheet を更新しない変更は drift とみなす

---

## 5. Pack Composition Rules

### 5.1 用語

| 用語 | 意味 |
|------|------|
| `battle_role` | monster package 側の種族役割。`striker`, `tank`, `healer`, `controller`, `bait_specialist`, `mutation_key` |
| `pack_role` | `systems/08` が group 生成時に個体へ割り当てる局所役割。`alpha`, `flanker`, `guard` など |
| `pack_shape` | authoring 時点での構成タイプ。solo, duo, triangle など |
| `pressure_payload` | その pack が主にかける圧。HP, MP, status, scout, flee のどれか |

### 5.2 pack_shape

| `pack_shape` | 人数 | 説明 | 主な用途 |
|--------------|-----:|------|----------|
| `solo_anchor` | 1 | 単体で印象を残す | rare 個体、縄張り型、入口の顔 |
| `paired_trade` | 2 | 攻守 or 状態と火力の二項 | Act I-II の基準 |
| `triangle_pressure` | 3 | 3役で圧を分担 | 中盤以降の標準 |
| `swarm_lowbody` | 3 | 個々は弱いが数で押す | 序盤雑魚、scout bait |
| `escort_elite` | 2〜3 | 強個体を下位種が支える | 中盤以降の danger route |
| `ritual_cell` | 2〜3 | field modifier と status を回す | ritual / fracture 世界 |

### 5.3 act 別 headcount 上限

| 幕 | 通常の主力人数 | 3体 pack の扱い | 禁止 |
|----|----------------|-----------------|------|
| Act I (`W-001〜W-004`) | 1〜2 | 弱個体 swarm のみ許可 | `controller + healer + striker` の完成 trio |
| Act II (`W-005〜W-009`) | 1〜3 | 標準化可 | 3体とも上位 rank |
| Act III (`W-010〜W-014`) | 2〜3 | 標準 | 同一強 status を3体重ね |
| Act IV (`W-015〜W-019`) | 2〜3 | 標準 | boss mechanic を直前通常戦で全開示 |
| Act V (`W-020〜W-021`) | 1〜3 | 標準 | 4体相当の情報量を出す複合 gimmick |

### 5.4 battle_role の重ね方

通常 wild encounter では、1 pack 内に同時採用できる battle_role を以下で制限する。

| role | pack 内上限 | 備考 |
|------|------------:|------|
| `striker` | 2 | 2 を超えるなら他個体は low rank にする |
| `tank` | 1 | 長期化を防ぐ |
| `healer` | 1 | Act III 以降中心 |
| `controller` | 1 | boss 前 2 連続導入禁止 |
| `bait_specialist` | 1 | scout temptation の核 |
| `mutation_key` | 0〜1 | story mainline の通常導線では常用しない |

### 5.5 authoring の guardrail

- 1 pack に `healer + controller + tank` を同時搭載して長期戦化させない
- 同じ status pressure を 2 体以上で高率重ねしない
- `bait_specialist` を出す pack は、同時に高 attrition をかけすぎない
- rare band pack は `scoutable` と `倒す価値` のどちらかを必ず持つ
- `mutation_key` を含む pack は、mainline では `見えるが確定収穫ではない` 程度に留める

---

## 6. Zone Budget

### 6.1 zone purpose

| `zone_purpose` | 役割 |
|----------------|------|
| `approach` | 世界に入った直後の文法提示 |
| `main_route` | 普通に進んだとき最も多く踏む導線 |
| `safe_route` | 低圧で進める遠回り / 安定導線 |
| `danger_route` | 高圧だが短い / 旨い / clue が濃い導線 |
| `resource_loop` | bait, drop, recruit, catalyst の周回点 |
| `clue_pocket` | 固定証拠の周辺にある短区間 |
| `boss_approach` | boss 前の学習導線 |
| `post_clear_revisit` | クリア後に文脈が変わる再訪区間 |

### 6.2 world size ごとの combat zone 目安

| world size | combat zone 数目安 | 必須 zone_purpose |
|------------|-------------------:|-------------------|
| `small` | 3〜5 | `approach`, `main_route`, `boss_approach` |
| `medium` | 5〜7 | `approach`, `main_route`, `safe_route` or `danger_route`, `boss_approach` |
| `large` | 7〜10 | `approach`, `main_route`, `safe_route`, `danger_route`, `boss_approach` |

### 6.3 zone ごとの species budget

| zone_purpose | 種数目安 | dominant family 数 |
|--------------|----------:|-------------------:|
| `approach` | 3〜5 | 1〜2 |
| `main_route` | 4〜6 | 1〜3 |
| `safe_route` | 3〜5 | 1〜2 |
| `danger_route` | 4〜7 | 2〜3 |
| `resource_loop` | 3〜6 | 1〜2 |
| `boss_approach` | 2〜4 | 1〜2 |

### 6.4 pressure band

zone は少なくとも以下 4 指標で authoring する。

| 指標 | 説明 |
|------|------|
| `attrition_pressure` | HP / MP / cure の消耗 |
| `status_pressure` | 毒, 眠り, 封印, hush, marked などの付着圧 |
| `scout_pressure` | 勧誘したくなる誘惑圧 |
| `escape_friction` | 逃走しづらさ、不意打ちされやすさ |

#### pressure band の定義

| band | 体感 | 主な使いどころ |
|------|------|----------------|
| `low` | 安心して抜けられる | safe route, town 隣接 |
| `standard` | 普通に消耗する | main route |
| `high` | 注意すれば通れるが greed を罰する | danger route |
| `spike` | 短く鋭い山 | boss_approach, late-game branch |

### 6.5 traversal あたりの pack 数

`1回の素通り` を基準にした目安。

| zone_purpose | pack 数目安 |
|--------------|------------:|
| `approach` | 1〜3 |
| `main_route` | 3〜6 |
| `safe_route` | 2〜4 |
| `danger_route` | 3〜5 |
| `resource_loop` | 2〜5 |
| `boss_approach` | 1〜3 |

### 6.6 zone authoring に必要な summary

各 zone は最低でも次を埋める。

- `zone_id`
- `world_id`
- `zone_purpose`
- `recommended_level_band`
- `time_band`, `weather`
- `paired_route_zone_id` 任意
- `attrition_pressure_band`
- `scout_pressure_band`
- `eligible_rarity_bands`
- `dominant_families`
- `encounter_pack_ids`
- `boss_echo_mechanic` 任意
- `sandbox_target_profile`

### 6.7 `recommended_level_band` 契約

world sheet 側の `recommended_level_band` を正とし、各 zone はそこから相対オフセットで band を切る。

| `zone_purpose` | lower offset | upper offset | 説明 |
|----------------|-------------:|-------------:|------|
| `approach` | `-2` | `0` | 世界導入。新種は見せるが即詰みを避ける |
| `main_route` | `0` | `+1` | その世界の標準戦 |
| `safe_route` | `-1` | `0` | 安定導線。bait や回復を節約しやすい |
| `danger_route` | `+1` | `+3` | greed を誘う枝。rare / clue / shortcut と交換 |
| `resource_loop` | `0` | `+2` | 周回前提。scout / catalyst の欲を乗せてよい |
| `clue_pocket` | `0` | `+1` | 物語証拠の周辺。情報を厚くし、難度は上げすぎない |
| `boss_approach` | `+2` | `+4` | ボス文法の予習。消耗は増やすが壊滅は狙わない |
| `post_clear_revisit` | `+2` | `+6` | 再訪差分。main clear 後の上振れ帯 |

補足:

- level は `1` 未満にしない
- zone 内の通常 pack の level spread は `3` 以内
- elite pack だけが zone upper を `+2` まで超えてよい
- recruit を強く誘う個体は、原則 `zone lower 〜 mid` に置く

### 6.8 tower-adjacent anomaly / mutation 出現ポリシー

`tower_touched` と `mutation_only` は雰囲気用の記号でなく、距離と gate state に応じて段階的に増やす。

| proximity band | 代表 zone | `tower_touched` 目安 | `mutation_only` 目安 | ルール |
|----------------|-----------|---------------------:|---------------------:|--------|
| `trace` | 塔が遠景に見える生活圏 | `0%〜3%` | `0%` | 違和感だけ見せる |
| `fringe` | 塔前荒地、門外縁 | `3%〜8%` | `0%〜2%` | 夜 / 天候 / elite row 限定で mutation を許可 |
| `gate_front` | 門前、boss approach | `8%〜16%` | `2%〜6%` | telegraph つき。通常生態を消さない |
| `rupture` | fracture 世界の境界区画 | `12%〜22%` | `4%〜10%` | 明確に異常圧を感じさせてよい |
| `deep_gate` | terminal / postgame 深部 | `18%〜30%` | `8%〜16%` | mainline でも終盤のみ。早期多用禁止 |

authoring rule:

- `mutation_only` を本編必須進行の収穫源にしない
- `tower_touched + mutation_only` の合計 row 比率は、通常 world では `30%` を超えない
- boss approach にも `native` pack を最低 1 系統残す
- anomaly pack の drop は main progress で必須にしない
- `tower_touched` は clue / mood の補強、`mutation_only` は rare greed の補強として使い分ける

---

## 7. Rarity Bands

### 7.1 band の意味

rarity の当たり判定そのものは `systems/08` を正とする。
この文書では、**zone authoring 上どの band を使ってよいか** を決める。

| band | runtime 意味 | authoring 上の扱い |
|------|--------------|-------------------|
| `normal` | 通常個体 | zone の主力 |
| `elite` | 強個体 | 変化点、route の山 |
| `rare` | 価値個体 | scout / loot / codex の誘因 |
| `ultra_rare` | 最高位の希少個体 | mainline では厳格に制限 |

### 7.2 zone purpose 別の許可

| zone_purpose | `elite` | `rare` | `ultra_rare` |
|--------------|---------|--------|--------------|
| `approach` | 可 | 早期 mainline では原則不可 | 不可 |
| `main_route` | 可 | 可 | 原則不可 |
| `safe_route` | 可だが低頻度 | 低頻度 | 不可 |
| `danger_route` | 可 | 可 | Act IV 以降のみ例外許可 |
| `resource_loop` | 可 | 可 | 例外許可 |
| `boss_approach` | 可だが明示制御 | 原則不可 | 不可 |

### 7.3 mainline 21世界での扱い

- `W-001〜W-004`: `rare` は zone の顔として 1系統まで。`ultra_rare` 禁止
- `W-005〜W-009`: `rare` を branch / scout reward に使ってよい。`ultra_rare` はまだ禁止
- `W-010〜W-019`: `rare` は標準運用可。`ultra_rare` は optional branch / resource loop 限定
- `W-020〜W-021`: `rare` は物語圧に寄せ、`ultra_rare` は mainline 道中で使わない

### 7.4 rarity band と reward の関係

- `rare` を置くなら、少なくとも `scout`, `drop`, `codex`, `world-theme` のどれか 2 つに意味を持たせる
- `ultra_rare` を置くなら、通常主線より `revisit / side loop / optional pocket` へ寄せる
- boss 前 zone では `rare` を greed trap に使わない

---

## 8. Scouting Pressure

### 8.1 定義

`scout_pressure` とは、**戦闘勝利そのものより勧誘したくなる気持ちが前に出る圧** である。

これは次の合成で決まる。

- recruit desirability
- recruitability
- bait coverage
- duplication risk
- battle danger

### 8.2 band 定義

| band | 目標体感 | 10 encounter あたりの bait 使用目安 |
|------|----------|------------------------------------:|
| `none` | 勧誘欲はほぼ出ない | 0 |
| `light` | たまに試したくなる | 0〜1 |
| `medium` | 適正 bait があれば積極的に試す | 1〜3 |
| `heavy` | 周回 / hunting の中心になる | 3〜5 |

### 8.3 scouting pressure を上げてよい条件

以下のいずれか 2 件以上を満たすときのみ `medium` 以上を許可する。

- その世界の dominant family と強く噛む
- 近傍 shop / vendor で対応 bait が買える
- 配合橋渡し役として価値がある
- codex / world-theme として強い固有性がある
- rare drop 以外にも recruit value がある

### 8.4 bait 接続の原則

- 1 世界につき、**その世界で本当に欲しい recruit 候補へ刺さる bait が最低 1 種** は拠点近傍で供給されること
- danger route でしか欲しい recruit が出ない場合、その route に入る前に対応 bait の情報か入手機会を置く
- `重い scout pressure + bait 供給なし` は hard fail

### 8.5 recruit unfairness の禁止

- `scoutable=false` のみで zone を埋めない
- 同一 zone に `duplicate_penalty` を強く受ける同系統ばかりを過剰配置しない
- boss approach で `今しか勧誘できない rare` を置いてリソース判断を歪めない

---

## 9. Safe Route vs Danger Route

### 9.1 route pair の基本

pair を作る場合、`safe route` と `danger route` は以下のどちらかを明確に交換する。

| safe route が得るもの | danger route が得るもの |
|------------------------|--------------------------|
| 低い attrition | 高い scout value |
| 低い status pressure | 近道 |
| 安定した pack readability | catalyst / record / loot |
| 逃走しやすさ | rare pack / richer ecology |

### 9.2 pair 成立条件

paired route は、少なくとも以下を満たす。

- safe route の `attrition_pressure` は danger route より 1 band 低い
- または safe route の expected HP drain が 25% 以上低い
- danger route は safe route より 1 つ以上明確な見返りを持つ
- 見返りは `短い`, `勧誘価値`, `希少資源`, `濃い clue atmosphere` のいずれか

### 9.3 禁止

- danger route が safe route の完全上位互換
- safe route が単に空で退屈
- 違いが encounter 率だけで、pack 内容も報酬も同じ

### 9.4 mainline での使用目安

| world size | pair 推奨数 |
|------------|------------:|
| `small` | 0〜1 |
| `medium` | 1 |
| `large` | 1〜2 |

---

## 10. Boss-Adjacent Encounter Shaping

### 10.1 定義

`boss_approach` は、boss room 直前 1〜3 zone、または boss へ至る最後の traversal を指す。

### 10.2 目的

- boss の `field modifier`, `status`, `pack logic`, `telegraph language` を先に見せる
- ただし boss そのものの答えは見せない
- 学習と資源圧を両立する

### 10.3 boss_class 別の drain budget

初見挑戦前の「boss room 到達時点」の目標。

| boss_class | HP消耗 | MP消耗 | cure 消費 | bait 消費 |
|------------|--------|--------|-----------|-----------|
| `gatekeeper` | 10%〜20% | 0%〜15% | 0〜1 | 0〜1 |
| `warden` | 15%〜25% | 10%〜20% | 0〜1 | 0〜1 |
| `arbiter` | 15%〜25% | 10%〜20% | 0〜1 | 0 |
| `fracture_host` | 20%〜35% | 15%〜25% | 1〜2 | 0 |
| `terminal_core` | 20%〜35% | 15%〜25% | 1〜2 | 0 |

### 10.4 boss_echo_mechanic

boss_approach では、boss の主文法から **1つだけ** 先出しする。

| boss 側文法 | approach 側で出す量 |
|------------|---------------------|
| `marked`, `hush`, `seal` | 1 pack で単独導入 |
| `field_modifier` | 常時または 1 zone 固有で導入 |
| `escort / add` 論理 | 弱い2体構成で導入 |
| `telegraph` 文化 | 文言と構えだけ先出し |

### 10.5 boss 前 zone の rarity clamp

- `ultra_rare` 禁止
- `rare` は原則禁止。使うなら optional pocket に隔離
- `bait_specialist` を出す場合も、boss 挑戦に必要な資源判断を歪めないこと

### 10.6 boss 前 zone の禁止

- 最後の2 pack で新 status を追加導入
- boss 本体と同じ負け筋を雑魚側で全部見せる
- 直前3 pack すべてを `high` 以上にする
- 逃走不可 wild encounter を boss 前道中に混ぜる

---

## 11. Encounter Sandbox

### 11.1 sandbox の目的

- `面白い` を主観だけでなく再現可能な case で比較する
- zone authoring を `一回遊んでみた感じ` に依存させない
- world 間で pressure の粒度を揃える

### 11.2 必須 input

| 入力 | 内容 |
|------|------|
| `world_id`, `zone_id` | 対象世界 / zone |
| `zone_purpose` | route 上の役割 |
| `time_band`, `weather` | 出現補正条件 |
| `encounter_pack_ids[]` | 候補 pack |
| `iteration_count` | 試行回数 |
| `rng_seed` | 再現用 |
| `party_profile` | 3体編成、平均Lv、作戦、trait |
| `resource_profile` | HP/MP開始割合、heal/cure/bait/field item 所持数 |
| `play_intent` | 速抜け, 全戦, scout 優先, low-resource など |
| `flee_policy` | 逃げない / 危険時逃げる / rare 以外逃げる |

### 11.3 canonical party profiles

最低限、各 zone は以下 5 case を持つ。

| `party_profile_id` | 想定 |
|--------------------|------|
| `onlevel_baseline` | 推奨帯中央、標準作戦、手持ち平均的 |
| `onlevel_scout_hunter` | 推奨帯中央、bait 多め、勧誘優先 |
| `underlevel_cautious` | 推奨帯下限 -2〜-3Lv、逃走判断あり |
| `overlevel_fastclear` | 推奨帯上限 +3〜+5Lv、時短志向 |
| `low_resource_revisit` | HP/MP半端、消耗品少なめ、再訪導線 |

### 11.4 output

| 出力 | 説明 |
|------|------|
| `win_rate` | 全滅せず抜けた割合 |
| `avg_battle_time_sec` | 1戦平均時間 |
| `avg_rounds` | 1戦平均ラウンド |
| `avg_hp_loss_pct` | 1 traversal あたりHP消耗 |
| `avg_mp_loss_pct` | 1 traversal あたりMP消耗 |
| `avg_cure_items_used` | 状態解除の使用量 |
| `avg_bait_items_used` | bait 消費量 |
| `scout_attempt_rate` | 勧誘試行率 |
| `scout_success_rate` | 勧誘成功率 |
| `escape_rate` | 逃走試行 / 成功率 |
| `elite_seen_rate` | elite 遭遇率 |
| `rare_seen_rate` | rare 遭遇率 |
| `status_infliction_rate` | 主要 status の付着率 |
| `top_fail_causes[]` | 敗因上位 |

### 11.5 pass targets

`systems/08` の大きい数値目標を外さない前提で、zone 単位では以下を目安にする。

| zone_purpose | `onlevel_baseline` 勝率 | 1戦時間 | traversal HP消耗 |
|--------------|------------------------|----------|------------------|
| `approach` | 88%〜95% | 20〜35秒 | 5%〜15% |
| `main_route` | 82%〜90% | 20〜45秒 | 10%〜25% |
| `safe_route` | 88%〜95% | 20〜40秒 | 8%〜18% |
| `danger_route` | 75%〜88% | 25〜55秒 | 18%〜35% |
| `boss_approach` | 82%〜90% | 25〜45秒 | 10%〜25% |

### 11.6 fail 判定

以下は sandbox hard fail とする。

- `main_route` の `onlevel_baseline` 勝率が 70% 未満
- `safe_route` が paired danger route より attrition で優位を持たない
- `boss_approach` が boss_class 別 drain budget を超えている
- `danger_route` に見返りがない
- `scout_pressure=heavy` なのに bait supply が近傍にない

---

## 12. Validation Rules

### 12.1 hard fail

- `zone_id` が存在しない
- `encounter_pack_id` が zone に属していない
- pack に 4体以上の通常敵を入れている
- zone の出現候補が `monster_world_presence` と整合しない
- mainline 通常 zone が `scoutable=false` だけで構成される
- `boss_approach` で `ultra_rare` を許可している
- pair 指定された `safe_route` / `danger_route` が差別化できていない
- clue / key progression を random encounter 限定にしている
- dominant family と zone pack が無関係

### 12.2 warning

- 同一 world 内で同じ pack shape が続きすぎる
- `controller` の採用率が高すぎる
- scout pressure が 2 world 連続で `heavy`
- bait 対応 family が 1 種に偏りすぎる
- rare band があるのに recruit, drop, codex のいずれにも意味が薄い
- same role の trio が多く、見た目以上に単調

### 12.3 authoring review 質問

1. この zone の encounter は、その世界の `何を証明しているか`
2. ここで bait を切る理由はあるか
3. ここで逃げる理由はあるか
4. boss 前なら、boss の何を予告しているか
5. pack の違いが見た目だけでなく行動にも出ているか

---

## 13. Telemetry Contract

### 13.1 既存 event の再利用

以下は `systems/08` の event をそのまま使う。

- `enemy_group_composition`
- `elite_encounter`
- `escape_attempt`

### 13.2 encounter authoring 追加 event

| event | フィールド |
|-------|------------|
| `encounter_zone_enter` | `world_id`, `zone_id`, `zone_purpose`, `route_kind`, `time_band`, `weather` |
| `encounter_pack_spawned` | `world_id`, `zone_id`, `encounter_pack_id`, `pack_shape`, `rarity_band`, `enemy_ids[]` |
| `encounter_pack_resolved` | `zone_id`, `encounter_pack_id`, `battle_time_sec`, `rounds`, `hp_loss_pct`, `mp_loss_pct`, `fled`, `won` |
| `encounter_resource_delta` | `zone_id`, `heal_used`, `cure_used`, `bait_used`, `field_items_used` |
| `encounter_scout_window` | `zone_id`, `encounter_pack_id`, `target_monster_id`, `bait_family_match`, `scout_attempted`, `success` |
| `boss_approach_drain_summary` | `world_id`, `zone_id`, `boss_class`, `hp_loss_pct`, `mp_loss_pct`, `cure_used`, `arrived_with_party_alive` |
| `route_choice` | `world_id`, `from_zone_id`, `chosen_zone_id`, `route_kind`, `player_level_band`, `inventory_pressure` |

### 13.3 telemetry alert

- `safe_route` 選択率が極端に低いのに勝率差もない
- `danger_route` 選択率が高いのに reward uplift が見合っていない
- scout-heavy zone で bait 使用率が低い
- boss_approach の HP drain が class 目標を超過
- 同一 zone の flee 率が 40% を超え、戦う意味が薄い

---

## 14. Connection To World Sheets

### 14.1 world sheet 必須接続

各 world sheet は、encounter 側に最低限以下を渡す。

- `world_id`
- `recommended_level_band`
- `native_family_bias`
- `shop_band`
- `boss_class`
- `boss_teaches`
- `foreshadow_ids`
- `record_objects`
- `taboo axes`

### 14.2 world sheet 側で encounter を記述すべきこと

world sheet 本体または子文書では、最低でも以下を持つ。

- combat zone 一覧
- `safe_route` / `danger_route` の有無
- world の主 scout targets
- boss_approach で echo する mechanic
- post-clear で変化する encounter

### 14.3 21 mainline scope での使い方

- `W-001〜W-021` の各世界は、world size に応じた combat zone 数を満たす
- `W-022+` reserved worlds は本仕様に従ってよいが、mainline の budget を先に満たす
- world sheet が concrete になる条件に、encounter zone summary を含める

---

## 15. Connection To Monster Canonical Package

### 15.1 encounter candidate selection に使う canonical fields

encounter authoring は、monster package の以下を読む。

| package 面 | 主な使用 field |
|------------|----------------|
| `monster_species` | `monster_id`, `family`, `rank`, `battle_role`, `ontology_class` |
| `monster_world_presence` | `world_id`, `presence_type`, `is_primary` |
| `monster_taboo_link` | `world_id`, `link_type`, `severity` |
| `monster_human_pressure` | `pressure_type`, `intensity`, `source_world_id` |
| `monster_combat_profile` | 成長帯、元素、trait、基礎数値 |
| `monster_breeding_profile` | `scoutable`, `base_recruit`, loot / mutation 価値 |

### 15.2 encounter authoring での読み方

- `monster_world_presence` がない種を、その world の通常 zone に置いてはならない
- `tower_touched`, `migratory`, `mutation_only` は例外 pack の根拠として使う
- `battle_role` は pack の戦術差を出すために使い、`family` は地形と生活圏を合わせるために使う
- `scoutable`, `base_recruit`, bait family 相性で scout pressure を決める

### 15.3 encounter から package へ返すべき知見

sandbox や live telemetry で以下が見えた場合、monster package 側の再設計候補とする。

- どの zone でも `battle_role` が死んでいる
- 想定より bait が刺さらない
- rare にしたのに recruit value が弱い
- same family 内で encounter 上の見分けがつかない

---

## 16. Deliverables And DoD

### 16.1 1 zone 完了条件

- `encounter_zone_sheet` が埋まっている
- pack が 2 種以上ある
- sandbox 5 case が通っている
- telemetry event の field が定義されている
- world sheet と monster package の参照が通っている

### 16.2 1 world 完了条件

- combat zone 数が size budget を満たす
- safe / danger / boss approach の設計有無が明示されている
- world の dominant family が encounter に反映されている
- scout pressure と近傍 bait supply の関係が説明できる
- boss 前後の encounter shaping が boss_class と整合している

---

## 17. QA Checklist

- 3体パーティで読める戦闘量か
- danger route の魅力が単なる数字でなく世界性を持つか
- safe route が空虚な消化試合になっていないか
- 勧誘圧が greed として機能しているか
- boss 前の道中が `学習` になっていて `嫌がらせ` になっていないか
- world sheet の禁忌、shop の bait、monster package の world presence が一つの論理で繋がっているか
