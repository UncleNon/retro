# 04. Initial Items And Shops

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/specs/systems/04_economy_items_and_progression_rules.md`
> - `docs/specs/systems/06_randomness_policy_and_probability_budgets.md`
> - `docs/specs/story/01_story_bible.md`

---

## 1. 目的

- 序盤〜中盤前半で本当に使うアイテム群を実表で固定する
- `20枠制限` の中で `回復 / 勧誘 / 探索 / 配合 / 記録` を競合させる
- 世界観と経済を分離せず、店棚だけでもその世界の文化が見える状態にする

---

## 2. アイテム一覧

### 2.1 HP回復

| item_id | 名称 | 価格 | 回復量 | rarity |
|---------|------|-----:|-------:|--------|
| `item_heal_dryherb` | ひからび草 | 20 | 20 | common |
| `item_heal_softmoss` | やわ苔包み | 36 | 35 | common |
| `item_heal_bundleleaf` | 束薬葉 | 55 | 55 | common |
| `item_heal_fatbroth` | 脂の煮汁 | 78 | 75 | uncommon |
| `item_heal_whitebulb` | 白球根 | 110 | 100 | uncommon |
| `item_heal_stillmilk` | 静乳の壺 | 165 | 140 | rare |
| `item_heal_embersap` | 燠樹液 | 240 | 220 | rare |
| `item_heal_blackfeast` | 黒盛り皿 | 360 | 320 | relic |

### 2.2 MP回復

| item_id | 名称 | 価格 | 回復量 | rarity |
|---------|------|-----:|-------:|--------|
| `item_mp_clearwater` | 透き水 | 45 | 12 | common |
| `item_mp_bitterdew` | 苦露瓶 | 72 | 20 | common |
| `item_mp_milksalt` | 乳塩湯 | 98 | 28 | uncommon |
| `item_mp_silentwax` | 無音蝋 | 130 | 36 | uncommon |
| `item_mp_bluepith` | 青髄片 | 190 | 48 | rare |
| `item_mp_starcurd` | 星酪 | 280 | 70 | rare |

### 2.3 状態解除

| item_id | 名称 | 価格 | 解除対象 |
|---------|------|-----:|----------|
| `item_cure_saltleaf` | 塩葉 | 35 | 毒 |
| `item_cure_wakebud` | 目覚め蕾 | 42 | 眠り |
| `item_cure_focussalt` | 澄塩 | 60 | 封印 / 沈黙 |
| `item_cure_tangleknife` | ほぐし刃 | 68 | 混乱 |
| `item_cure_warmbone` | 温骨札 | 90 | 凍え / 麻痺 |
| `item_cure_duskthread` | 暮糸包み | 120 | 二状態解除 |

### 2.4 勧誘補助

| item_id | 名称 | 価格 | 補正 | 対象傾向 |
|---------|------|-----:|-----:|----------|
| `item_bait_drycrumb` | 乾き餌 | 55 | +8 | 汎用序盤 |
| `item_bait_smokedfat` | 燻脂餌 | 120 | +16 | 汎用中盤 |
| `item_bait_bellgrain` | 鈴穀餌 | 160 | +22 | beast / bird |
| `item_bait_sourmilk` | 酸乳餌 | 180 | +22 | beast / plant |
| `item_bait_graveflour` | 墓粉餌 | 210 | +24 | undead / magic |
| `item_bait_inkmeat` | 墨肉片 | 240 | +24 | material / magic |
| `item_bait_starmarrow` | 星髄餌 | 320 | +26 | divine / dragon |
| `item_bait_truefeast` | 真宴片 | 460 | +32 | 上位汎用 |

### 2.5 戦闘補助

| item_id | 名称 | 価格 | 効果 |
|---------|------|-----:|------|
| `item_buff_ironmeal` | 鉄食い粉 | 70 | 3T 攻撃+ |
| `item_buff_hideoil` | 皮油 | 70 | 3T 守備+ |
| `item_buff_quicksap` | 疾樹液 | 80 | 3T 素早さ+ |
| `item_buff_clearash` | 透灰 | 95 | 3T 精神+ |
| `item_debuff_tarseed` | 瀝種 | 75 | 敵1体素早さ- |
| `item_debuff_dullbell` | 鈍鈴片 | 92 | 敵全体命中-小 |

### 2.6 探索補助

| item_id | 名称 | 価格 | 効果 |
|---------|------|-----:|------|
| `item_field_bonerope` | 骨縄 | 80 | ダンジョン脱出 |
| `item_field_chalktag` | 印粉札 | 60 | 道標表示 |
| `item_field_repelash` | よけ灰 | 95 | 低ランク遭遇抑制 |
| `item_field_luremist` | 寄霧瓶 | 100 | 特定系統遭遇増 |
| `item_field_silentcloth` | 無音布 | 130 | 鐘 / 反応軽減 |
| `item_field_moonpin` | 月留め針 | 150 | 夜イベント補助 |

### 2.7 配合触媒

| item_id | 名称 | 価格 | 効果 |
|---------|------|-----:|------|
| `item_catalyst_ashseed` | 灰種 | 150 | mutation率 +2% |
| `item_catalyst_bellsalt` | 鈴塩 | 190 | bird / divine 特殊配合補助 |
| `item_catalyst_namewax` | 名蝋 | 220 | 継承候補1件保護 |
| `item_catalyst_bloodchalk` | 血白墨 | 260 | material / undead 条件補助 |
| `item_catalyst_starbone` | 星骨 | 320 | plus_value 判定 +1 |
| `item_catalyst_emptyseal` | 空印 | 400 | mutation 方向指定 |

### 2.8 記録 / 解析

| item_id | 名称 | 価格 | 効果 |
|---------|------|-----:|------|
| `item_record_rubbingset` | 拓本具 | 85 | 碑文記録 |
| `item_record_tagcase` | 札筒 | 120 | 札系 clue 保持 |
| `item_record_inkpaste` | 墨膏 | 140 | 台帳照合回数追加 |
| `item_record_belltube` | 鈴筒 | 160 | 鐘音 clue 記録 |
| `item_record_namefoil` | 名箔 | 220 | レシピヒント1段階開示 |

### 2.9 貴重品

| item_id | 名称 | 用途 |
|---------|------|------|
| `item_key_borrowedtag` | 借り名札 | `W-001` |
| `item_key_ashbrand` | 灰印片 | `W-002` |
| `item_key_hostellamp` | 宿名灯 | `W-003` |
| `item_key_passpeg` | 岬通行鋲 | `W-004` |
| `item_key_gravesalt` | 墓塩 | `W-005` |
| `item_key_towerwrit` | 塔通牒 | 中盤以降 |

---

## 3. 初期ショップ

### 3.1 `SHOP-001` 故郷の村

在庫:

- `item_heal_dryherb`
- `item_mp_clearwater`
- `item_cure_saltleaf`
- `item_bait_drycrumb`
- `item_field_bonerope`

### 3.2 `SHOP-002` 塔前仮商

在庫:

- `item_heal_dryherb`
- `item_mp_clearwater`
- `item_cure_focussalt`
- `item_field_chalktag`
- `item_record_rubbingset`

### 3.3 `SHOP-W01` 名伏せの野

在庫:

- `item_heal_softmoss`
- `item_mp_bitterdew`
- `item_cure_focussalt`
- `item_bait_smokedfat`
- `item_bait_bellgrain`
- `item_field_chalktag`
- `item_catalyst_ashseed`

### 3.4 `SHOP-W02` 灰乳の谷

在庫:

- `item_heal_fatbroth`
- `item_mp_milksalt`
- `item_bait_sourmilk`
- `item_buff_hideoil`
- `item_catalyst_bellsalt`

### 3.5 `SHOP-W03` 継灯の宿場

在庫:

- `item_heal_bundleleaf`
- `item_mp_bitterdew`
- `item_cure_tangleknife`
- `item_bait_inkmeat`
- `item_record_tagcase`
- `item_record_inkpaste`

### 3.6 `SHOP-W04` 札差しの岬

在庫:

- `item_heal_bundleleaf`
- `item_mp_silentwax`
- `item_field_repelash`
- `item_buff_quicksap`
- `item_debuff_tarseed`

---

## 4. 運用ルール

- 序盤店では万能状態回復を売らない
- 勧誘アイテムは常に回復より高い
- 記録アイテムは直接戦力でなく、理解と再訪価値を買う枠
- 触媒は買えるが、成功を保証しない

---

## 5. QA Checklist

- 20枠制限下で回復と餌が競合するか
- 店棚だけで世界観が見えるか
- 触媒が強すぎて配合の発見を殺していないか
