# 02. Initial Skill Set

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/specs/systems/01_numeric_rules_and_master_schema.md`
> - `docs/specs/content/01_vertical_slice_monsters.md`
> - `docs/requirements/02_game_design_core.md`
> - `docs/requirements/07_ui_ux.md`

---

## 1. 目的

- 序盤 10 体のモンスターと、開始村から最初の門の向こう側までを支える初期スキル群を固定する
- 戦闘テンポは短く保ちつつ、`準備が勝敗を決める` 体験を最初から成立させる
- 塔、家印、改名、湿り気、獣柵、失踪のモチーフを、スキル名と副作用にも混ぜ込む
- 後で 400 体まで増えても壊れにくいよう、**少数の計算キー + 多数のタグ** で拡張できる形にする

---

## 2. 設計原則

### 2.1 初期スキルセットの役割

| 役割 | 内容 |
|------|------|
| 序盤の読みやすさ | 1戦 20〜45 秒目標。テキストを増やさず判断できる |
| 個体差の体感 | 同じ種でもスキル構成が違えば役割が変わる |
| 配合の理由づけ | 継承したい技が早期から明確にある |
| 世界観への接続 | 名前、印、湿気、柵、囁き、光の反応が物語伏線になる |
| AI作戦との相性 | `たたかう / さくせん / どうぐ / にげる` の4コマンドでも成立する |

### 2.2 初期スキルの禁止事項

- 序盤から全体高火力を乱発しない
- 賢さ一点盛りで呪文が壊れる構造にしない
- 状態異常が 100% 前提で通る技を置かない
- `敵の true name を暴く` など設定の核心を明言する効果文にしない
- スキル単体で配合の最適解を固定しない

---

## 3. 共通計算キー

この文書では各スキルが `formula_key` を参照する。元の土台式は [01_numeric_rules_and_master_schema.md](/Users/yuki/projects/retro/docs/specs/systems/01_numeric_rules_and_master_schema.md) に従う。

### 3.1 ダメージ計算キー

| `formula_key` | 用途 | 式 |
|---------------|------|----|
| `P1` | 標準単体物理 | `max(1, floor((ATK*0.5 - DEF*0.25) * power_mod * rng))` |
| `P2` | 軽量物理 / 命中安定 | `max(1, floor((ATK*0.45 - DEF*0.20) * power_mod * rng))` |
| `P3` | 防御崩し物理 | `max(1, floor((ATK*0.5 - DEF*0.15) * power_mod * rng))` |
| `P4` | 退避込み物理 | `P1` を適用後、自身に回避補正 |
| `P5` | 反動付き重打 | `P1` を `power_mod > 1.20` で計算し、自傷 `max_hp * 0.05` |
| `M1` | 固定帯呪文 / 特技 | `floor(base_power * rng * resist_modifier * field_modifier)` |
| `M2` | 低威力多段 / 全体魔法 | `floor(base_power * rng * resist_modifier * spread_modifier)` |
| `H1` | 単体回復 | `floor(base_power + INT*0.35 + rng_flat)` |
| `H2` | 継続回復 / 小回復 | `floor(base_power + INT*0.20 + rng_flat)` |
| `R1` | 勧誘補助 | `battle_recruit_bonus += fixed_value` |

### 3.2 状態 / 補助計算キー

| `formula_key` | 用途 | 式 |
|---------------|------|----|
| `S1` | 単体状態異常 | `clamp(base_rate + (INT-RES)*0.15 + tactic_bonus, 5, 95)` |
| `S2` | 軽状態 + 追加効果 | `clamp(base_rate + (INT-RES)*0.10, 5, 85)` |
| `B1` | 単体能力上昇 | 3ターン持続、指定能力 `+1段階` |
| `B2` | 単体能力低下 | 3ターン持続、指定能力 `-1段階` |
| `B3` | 壁 / 軽減 | 3ターン持続、被ダメ `0.80倍` または属性補正付与 |
| `U1` | 看破 / 露見 | 弱点表示、回避補正解除、`marked` 付与 |
| `U2` | 印食い | 対象の `marked` またはバフを 1 つ消費し MP 回復 or 追加ダメージ |
| `F1` | フィールド補助 | フィールド探索用。戦闘外のみ |

### 3.3 乱数レンジ

| 種別 | 値 |
|------|----|
| `rng` | `0.90 - 1.05` |
| `rng_flat` | `0 - 3` |
| 全体化 `spread_modifier` | `0.78` |
| 連続使用ペナルティ | 同一補助を 3 回連続で使うと成功率 `-10` |

---

## 4. 初期状態キーワード

初期スキル群で使う独自状態。UI では短く表示し、詳細説明は下部説明帯と図鑑ヘルプに逃がす。

| 状態 | 効果 |
|------|------|
| `marked` | 弱点表示済み。`しるしうばい`, `いんしょうのみ`, `ひかりのまなざし` が追加効果 |
| `soot` | 命中 `-10%`。勧誘率 `+4`。`すすはき` 由来 |
| `wet` | 火属性被ダメ `-20%`、雷属性被ダメ `+10%` |
| `softened` | 守備 `-1段階` と同義ではなく、物理被ダメ計算時の DEF 係数を `-10%` |
| `hushed` | 次の補助 / 呪文の成功率 `-10`。囁き、封印系の前段 |
| `guard_shell` | 物理と土属性ダメージを `0.80倍` |

---

## 5. タグ体系

### 5.1 バトルタグ

| タグ | 意味 |
|------|------|
| `starter` | 序盤バランス基準技 |
| `single` | 単体対象 |
| `spread` | 全体 or 横列対象 |
| `physical` | 物理依存 |
| `fixed_magic` | 固定帯魔法 / 特技 |
| `status` | 状態異常主目的 |
| `setup` | 強化 / 弱体 / 下準備 |
| `recover` | HP / MP 回復 |
| `recruit` | 勧誘成功率に影響 |
| `escape` | 離脱、行動順、位置補正 |
| `mark` | `marked` を使う / 付与する |
| `tower_reactive` | 塔 or 門周辺で追加演出を許可 |

### 5.2 モチーフタグ

| タグ | 意味 |
|------|------|
| `beast`, `bird`, `plant`, `material`, `magic`, `divine` | 系統相性 |
| `soot`, `tag`, `reed`, `bone`, `bell`, `herb`, `fog` | 世界観モチーフ |

---

## 6. デザインロール

| ロールID | 役割 |
|----------|------|
| `RUSH_OPEN` | 開幕のテンポを作る先手技 |
| `SAFE_POKE` | 低リスクで削る |
| `BREAK_DEF` | 守備や回避を崩す |
| `STATUS_SETUP` | 睡眠 / 毒 / 混乱などの起点を作る |
| `SCOUT_SUPPORT` | 勧誘の成功率を押し上げる |
| `ALLY_SUSTAIN` | HP / 壁 / 被害軽減で耐える |
| `CONTROL` | 封印、暗闇、恐れ、命中低下 |
| `PAYOFF` | `marked`, `soot`, `wet` 等を回収して伸びる |
| `FIELD_LINK` | フィールド探索や塔演出に接続する |

---

## 7. 初期スキル一覧（36種）

### 7.1 物理 / 打撃 / 噛みつき系

| `skill_id` | 名前 | 分類 | 属性 | MP | 対象 | `formula_key` | 基本値 | 命中 / 成功 | タグ | 役割 | 効果 |
|------------|------|------|------|---:|------|---------------|--------|-------------|------|------|------|
| `SKL-001` | たいあたり | 物理 | none | 0 | 単体 | `P1` | `power_mod 1.00` | 95 | `starter,single,physical,beast` | `SAFE_POKE` | 基準単体技 |
| `SKL-002` | ついばむ | 物理 | wind | 0 | 単体 | `P2` | `power_mod 1.05` | 97 | `starter,single,physical,bird` | `RUSH_OPEN` | 鳥系の基準技。`wet` 対象に `+10%` |
| `SKL-003` | ひっかく | 物理 | dark | 0 | 単体 | `P2` | `power_mod 1.00` | 98 | `starter,single,physical,beast` | `SAFE_POKE` | 会心率 `+5%` |
| `SKL-004` | かじる | 物理 | earth | 2 | 単体 | `P3` | `power_mod 1.10` | 92 | `single,physical,material,beast` | `BREAK_DEF` | `15%` で `fear` |
| `SKL-005` | ちいさなつの | 物理 | earth | 2 | 単体 | `P3` | `power_mod 1.15` | 93 | `single,physical,beast` | `BREAK_DEF` | `20%` で `softened` |
| `SKL-006` | つつく | 物理 | wind | 1 | 単体 | `P1` | `power_mod 0.95` | 100 | `single,physical,bird,tag` | `RUSH_OPEN` | `marked` 対象へ `+15%` |
| `SKL-007` | かすりきず | 物理 | none | 1 | 単体 | `P2` | `power_mod 0.80` | 100 | `single,physical,starter` | `SAFE_POKE` | 低威力だが必中。勧誘目的の削りに使う |
| `SKL-008` | とびのく | 補助付き物理 | wind | 3 | 自身→単体 | `P4` | `power_mod 0.75` | 100 | `single,physical,escape,bird` | `RUSH_OPEN` | 使用後、次の被弾まで回避 `+20%` |
| `SKL-009` | みみうち | 状態付き物理 | none | 2 | 単体 | `P2` | `power_mod 0.85` | 95 / 28 | `single,physical,status,beast` | `CONTROL` | 追加で `hushed` |
| `SKL-010` | しるしうばい | 特殊物理 | dark | 4 | 単体 | `P2` | `power_mod 0.90` | 92 | `single,physical,mark,tag` | `PAYOFF` | 対象が `marked` なら追加ダメージ `+35%`、バフ 1 個を消す |
| `SKL-011` | きおくのひづめ | 物理 | light | 5 | 単体 | `P5` | `power_mod 1.35` | 90 | `single,physical,divine,tower_reactive` | `PAYOFF` | 使用者の HP が半分以下なら威力 `+10%` |
| `SKL-012` | あしもとくずし | 弱体物理 | earth | 3 | 単体 | `P2` | `power_mod 0.90` | 94 / 65 | `single,physical,setup` | `BREAK_DEF` | 追加で SPD `-1段階` |

### 7.2 暗闇 / 毒 / 睡眠 / 封印系

| `skill_id` | 名前 | 分類 | 属性 | MP | 対象 | `formula_key` | 基本値 | 命中 / 成功 | タグ | 役割 | 効果 |
|------------|------|------|------|---:|------|---------------|--------|-------------|------|------|------|
| `SKL-013` | すすはき | 状態 | dark | 2 | 単体 | `S2` | `base_rate 48` | 48 | `status,soot,starter` | `CONTROL` | `soot` を付与。命中低下 + 勧誘率 `+4` |
| `SKL-014` | どくこな | 状態 | poison | 3 | 単体 | `S1` | `base_rate 55` | 55 | `status,plant,starter` | `STATUS_SETUP` | 毒付与 |
| `SKL-015` | ねむりごな | 状態 | none | 5 | 単体 | `S1` | `base_rate 44` | 44 | `status,plant,fog` | `STATUS_SETUP` | 睡眠付与 |
| `SKL-016` | まよわせる | 状態 | dark | 4 | 単体 | `S1` | `base_rate 42` | 42 | `status,material,fog` | `CONTROL` | 混乱付与 |
| `SKL-017` | ささやき | 状態 | dark | 3 | 単体 | `S2` | `base_rate 52` | 52 | `status,magic,bell` | `CONTROL` | `fear` または `hushed` の軽い二択 |
| `SKL-018` | ふういん | 状態 | light | 4 | 単体 | `S1` | `base_rate 46` | 46 | `status,magic,mark` | `CONTROL` | 呪文 / 補助封印 |
| `SKL-019` | くらがりはね | 状態付き魔法 | dark | 5 | 全体 | `M2` | `base_power 10` | 85 / 30 | `spread,fixed_magic,status,bird` | `CONTROL` | 全体に小ダメージ + `30%` で `soot` |
| `SKL-020` | みみざわりの鈴 | 状態 | none | 4 | 全体 | `S2` | `base_rate 35` | 35 | `spread,status,bell` | `CONTROL` | 全体に `hushed`。塔内部では効果音のみ変わる |

### 7.3 回復 / 壁 / 生存補助

| `skill_id` | 名前 | 分類 | 属性 | MP | 対象 | `formula_key` | 基本値 | 命中 / 成功 | タグ | 役割 | 効果 |
|------------|------|------|------|---:|------|---------------|--------|-------------|------|------|------|
| `SKL-021` | くさのしずく | 回復 | water | 3 | 味方単体 | `H1` | `base_power 16` | 100 | `recover,plant,starter,herb` | `ALLY_SUSTAIN` | 小回復 |
| `SKL-022` | しめり | 補助 | water | 3 | 味方単体 | `B3` | `wet` 付与 | 100 | `setup,plant,water` | `ALLY_SUSTAIN` | 3ターン `wet` |
| `SKL-023` | やわらかいかべ | 補助 | earth | 4 | 味方単体 | `B3` | `guard_shell` | 100 | `setup,plant,material` | `ALLY_SUSTAIN` | 3ターン物理軽減 |
| `SKL-024` | かばいだて | 補助 | none | 2 | 味方単体 | `B1` | DEF `+1` | 100 | `setup,single` | `ALLY_SUSTAIN` | 対象 DEF `+1段階` |
| `SKL-025` | こすりなおし | 回復補助 | light | 3 | 味方単体 | `H2` | `base_power 10` | 100 | `recover,setup,tag` | `ALLY_SUSTAIN` | 小回復 + `soot` / `hushed` を解除 |
| `SKL-026` | ぬめり | 弱体 | water | 3 | 単体 | `B2` | SPD `-1` | 95 | `status,setup,plant` | `BREAK_DEF` | 追加で逃走率 `-15%` |
| `SKL-027` | ほしみず | 回復 | light | 5 | 味方単体 | `H1` | `base_power 12` | 100 | `recover,divine,tower_reactive` | `ALLY_SUSTAIN` | HP小回復 + MP `4` 回復 |

### 7.4 勧誘 / 看破 / 印操作

| `skill_id` | 名前 | 分類 | 属性 | MP | 対象 | `formula_key` | 基本値 | 命中 / 成功 | タグ | 役割 | 効果 |
|------------|------|------|------|---:|------|---------------|--------|-------------|------|------|------|
| `SKL-028` | みやぶる | 看破 | light | 2 | 単体 | `U1` | `marked 3T` | 100 | `mark,setup,starter` | `SCOUT_SUPPORT` | 弱点表示、回避補正解除、`marked` |
| `SKL-029` | ぬすみみる | 看破 / 補助 | dark | 3 | 単体 | `U1` | recruit `+6` | 100 | `mark,recruit,material` | `SCOUT_SUPPORT` | 所持品ヒント表示 + この戦闘中勧誘率 `+6` |
| `SKL-030` | ひかりのまなざし | 看破 | light | 4 | 単体 | `U1` | `marked 4T` | 100 | `mark,divine,tower_reactive` | `SCOUT_SUPPORT` | `marked` と同時に `fear` を解除 |
| `SKL-031` | いんしょうのみ | 印操作 | dark | 5 | 単体 | `U2` | `mp_gain 5` | 100 | `mark,payoff,magic` | `PAYOFF` | `marked` かバフを消費して MP 回復。対象に小ダメージ `M1 base 12` |
| `SKL-032` | しずかなよびごえ | 勧誘補助 | none | 4 | 単体 | `R1` | `fixed_value 10` | 100 | `recruit,bell,setup` | `SCOUT_SUPPORT` | この戦闘のみ勧誘率 `+10` |
| `SKL-033` | すばやくにげる | 離脱 | wind | 2 | 自身 | `F1` | escape `+40` | 100 | `escape,starter` | `FIELD_LINK` | 戦闘では離脱率大幅上昇。探索では狭路移動補助に転用可能 |

### 7.5 初期レベル帯の追加習得候補

| `skill_id` | 名前 | 分類 | 属性 | MP | 対象 | `formula_key` | 基本値 | 命中 / 成功 | タグ | 役割 | 効果 |
|------------|------|------|------|---:|------|---------------|--------|-------------|------|------|------|
| `SKL-034` | きざみかぜ | 魔法 | wind | 4 | 全体 | `M2` | `base_power 14` | 100 | `spread,fixed_magic,bird,fog` | `RUSH_OPEN` | 全体小ダメージ |
| `SKL-035` | まきつきつる | 状態 | earth | 4 | 単体 | `S1` | `base_rate 50` | 50 | `status,plant,earth` | `STATUS_SETUP` | `paralysis` に近い足止め 1〜2ターン |
| `SKL-036` | にぶいひかり | 弱体 | light | 3 | 単体 | `B2` | INT / RES `-1` | 92 | `setup,light,mark` | `BREAK_DEF` | 呪文耐性と補助精度を崩す |

---

## 8. 初期 10 体への習得割り当て

### 8.1 初期習得

| モンスター | 初期 3 技 |
|------------|-----------|
| モクケダ | たいあたり / すすはき / ちいさなつの |
| タグツツキ | ついばむ / かすりきず / みやぶる |
| ヨモギナメ | ぬめり / くさのしずく / どくこな |
| カゴホネズミ | かじる / ぬすみみる / すばやくにげる |
| マヨイカカシ | つつく / まよわせる / しるしうばい |
| イワミミ | ひっかく / とびのく / みみうち |
| シメリガサ | しめり / ねむりごな / やわらかいかべ |
| ユビガラス | つつく / ささやき / くらがりはね |
| シルシクイ | ひっかく / ふういん / いんしょうのみ |
| トウモリノコ | たいあたり / ひかりのまなざし / きおくのひづめ |

### 8.2 序盤追加習得候補

| モンスター | Lv習得候補 |
|------------|------------|
| モクケダ | `Lv 7: かばいだて`, `Lv 12: こすりなおし` |
| タグツツキ | `Lv 6: しずかなよびごえ`, `Lv 11: きざみかぜ` |
| ヨモギナメ | `Lv 8: まきつきつる`, `Lv 13: しめり` |
| カゴホネズミ | `Lv 7: あしもとくずし`, `Lv 12: みやぶる` |
| マヨイカカシ | `Lv 9: みみざわりの鈴`, `Lv 14: にぶいひかり` |
| イワミミ | `Lv 8: かすりきず`, `Lv 13: すばやくにげる` |
| シメリガサ | `Lv 9: くさのしずく`, `Lv 15: ほしみず` |
| ユビガラス | `Lv 8: しるしうばい`, `Lv 14: しずかなよびごえ` |
| シルシクイ | `Lv 9: みやぶる`, `Lv 15: にぶいひかり` |
| トウモリノコ | `Lv 10: かばいだて`, `Lv 16: ほしみず` |

---

## 9. AI作戦との相性

| 作戦 | 優先されやすいスキルタグ |
|------|--------------------------|
| `ガンガン` | `physical`, `fixed_magic`, `PAYOFF` |
| `いろいろ` | `starter`, `mark`, `status`, `recover` |
| `命を守れ` | `recover`, `ALLY_SUSTAIN`, `CONTROL` |
| `さくせんなし` | MP 0 の通常攻撃を優先 |

### AI上の個別例外

- `みやぶる` は同一対象に `marked` がある間は再使用しない
- `しずかなよびごえ` は敵 HP が `50%以下` の時だけ候補に入る
- `きおくのひづめ` は使用者 HP が `35%未満` なら優先度 `+1`
- `くさのしずく` は対象 HP が `45%以下` で解禁
- `ふういん` は敵が MP を持つ場合のみ優先候補

---

## 10. フィールド / UI 実装ルール

### 10.1 下部説明帯の文言ルール

- 1行目は `何をする技か`
- 2行目は `属性 / 命中の癖 / 副作用`
- 18文字相当を超える説明は図鑑ヘルプへ逃がす

例:

| 技 | 1行目 | 2行目 |
|----|--------|--------|
| みやぶる | あいての弱みを見ぬく | 印をつけ 回避を消す |
| しるしうばい | つけた印をえぐりとる | 印つき相手に強い |
| こすりなおし | けがれをぬぐい 小回復 | すす / ささやきを消す |

### 10.2 塔反応演出

`tower_reactive` タグ付きスキルは、塔や門の近辺で以下の演出を許可する。

- 効果音の末尾だけ逆再生風に変質
- 一部メッセージで対象名が一瞬だけ揺れる
- ダメージや回復量は変えない

---

## 11. 初期バランス制約

| 項目 | 制約 |
|------|------|
| 序盤単体通常火力 | `power_mod 0.95 - 1.15` |
| 序盤重打 | `power_mod 1.35` まで |
| 序盤全体固定ダメージ | `base_power 10 - 14` |
| 毒 / 睡眠初期成功率 | `42 - 55` |
| 初期単体回復 | `16 - 22` 回復域 |
| 勧誘補助 | 1 技あたり `+10` を上限 |

### 壊れ防止

- `marked` を前提とする技は、単体高火力になりすぎないよう追加補正を `+35%` で止める
- 睡眠 + 高火力の即死ループを避けるため、睡眠中被ダメ補正は序盤 `+10%` にとどめる
- `しずかなよびごえ` と bait bonus は加算するが、最終勧誘率は hard cap `90` を超えない

---

## 12. 今後の拡張余地

- `burn`, `freeze`, `curse`, `name_scramble` などの深層状態は中盤以降に追加する
- 初期 36 技は、400体全体では「基幹語彙」として残し、上位版 / 派生版 / world variant を派生させる
- `tag` と `mark` のモチーフは、後半では制度、家系、門の認証、真名の回復と接続する
