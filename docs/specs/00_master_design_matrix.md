# 00. Master Design Matrix

> **ステータス**: Draft v2.0
> **最終更新**: 2026-03-16
> **目的**: 「まだ決めることが大量にある」ことを前提に、設計面を漏れなく棚卸しする

---

## 1. 使い方

- この文書は「何を決める必要があるか」の母表
- `fixed`: 現時点で大枠を固定済み
- `next`: 早めに詳細化すべき
- `open`: まだ深掘りが必要

---

## 2. 体験の芯

| 項目 | 状態 | メモ |
|------|------|------|
| unique-my-monster を体験の核にする | fixed | ADR-0008 |
| 不可逆性と救済の同居 | fixed | 親消滅、牧場、継承 |
| 勝敗は準備で決まる | fixed | 4コマンド + 作戦AI |
| 確率は局所、長期は決定論 | fixed | 勧誘、変異のみ揺らぎ |
| 初回体験はレトロ、補助はオプション | fixed | UI / UX 基準 |
| 1セッションの理想プレイ時間 | next | 5分 / 15分 / 60分の設計深掘り |
| プレイヤー心理の報酬点 | next | 勧誘、配合、門解放、図鑑更新 |
| “ノートを取りたくなる”情報量 | next | ヒント粒度の調整 |
| 乱数の許容範囲の共通ポリシー | fixed | systems/06 で定義 |

---

## 3. 主人公 / パーティ / 役割

| 項目 | 状態 | メモ |
|------|------|------|
| 45歳、男女選択、無言主人公 | fixed | requirements 反映済み |
| 家畜番、小さな村の住人 | fixed | requirements 反映済み |
| 主人公の初期所持品 | fixed | systems/11: ひからび草×3、印粉札×2、仕事札、古い家畜札 |
| 主人公の初期所持モンスター | fixed | systems/11: モクケダLv3（半家畜、仕事仲間として合流） |
| 主人公の年齢が会話に与える差分 | fixed | systems/11: 若者=敬語、同年代=対等、長老=含み、子ども=無邪気 |
| 主人公の見た目差分数 | fixed | systems/11: 体型2、髪型4、肌色3。顔は16×16で差が出ないため固定 |
| パーティ3枠の理由付け | fixed | systems/11: 門が3つまでの所属印を同時に通す世界設定 |
| 控え / 牧場の導線 | fixed | systems/11: 牧場38体、拠点でのみ入替、フィールド直接不可 |

---

## 4. バトルシステム

| 項目 | 状態 | メモ |
|------|------|------|
| 4コマンド文法 | fixed | `たたかう / さくせん / どうぐ / にげる` |
| 作戦AI種類 | fixed | requirements 反映済み |
| 物理ダメージ式 | fixed | spec 反映済み |
| 呪文ダメージ式 | fixed | 固定威力帯寄り |
| 行動順式 | fixed | spd + ランダム幅 |
| 会心率 | fixed | systems/02: base 4%、trait / personality / skill bonus、cap 25% を定義 |
| 属性相性倍率 | fixed | systems/02: 耐性 `-2..+2` に対し `1.50 / 1.25 / 1.00 / 0.75 / 0.50` を採用 |
| 状態異常継続ターン | fixed | systems/09: 眠り1-3、麻痺2-4、封印3T など持続帯と RES 補正を定義 |
| 逃走不可条件 | fixed | systems/08: boss / ritual / gate_trial / surrounded / contract を定義 |
| 敵AIタイプ | fixed | systems/08: FERAL, PACK, TERRITORIAL, INTELLIGENT, RITUAL, AMBUSH, GATE_GUARDIAN, ELDER_BOSS |
| 複数体敵の行動連携 | fixed | systems/08: pack_role、synergy_bonus、retaliation memory まで定義 |
| フィールド効果 | fixed | systems/09 + systems/13: 雨、濃霧、gate_pressure、mirror_glare、thin_air を定義 |
| 戦闘内の位置概念 | fixed | 不採用。3v3の準備重視に位置概念を加えると入力量が増え、設計思想に合わない |
| 命中 / 回避式 | fixed | systems/08: 基本命中90%。SPD差で±10%。trait・状態で追加補正。下限70% |
| 反撃 / ガード / かばう | fixed | systems/08: trait紐付け。`反撃体質`=被物理時30%で反撃、`かばう`=trait持ち限定 |
| ボスの複数段階行動 | fixed | systems/08 で規格化 |

---

## 5. レベル / 成長 / 個体差

| 項目 | 状態 | メモ |
|------|------|------|
| global hard cap 99 | fixed | spec 反映済み |
| 種族別 `base_level_cap` | fixed | 60〜84帯 |
| `plus_value` による実効上限上昇 | fixed | `+2Lv` / point |
| growth curve 4種 | fixed | EARLY / STANDARD / LATE / LEGEND |
| stat growth formula | fixed | base + cap + curve |
| 個体差 `nature_seed` | fixed | favored / weak stat |
| 性格補正の内部値 | fixed | systems/11: 2軸×3段階=9種。成長+戦闘の両方に微補正 |
| 性格変化条件 | fixed | systems/11: 変化なし。性格変更は配合でのみ |
| 忠誠度 / なつき度の変化式 | fixed | systems/11: 勝利+1、全滅-5、bait±2等。表示は文言のみ |
| 戦闘不能の長期的ペナルティ | fixed | systems/11: 忠誠度低下のみ。長期ペナルティなし |
| 牧場預け時の変化 | fixed | systems/11: HP/MP全回復、忠誠・気質・成長は変化なし |
| 老成 / 覚醒イベント | fixed | systems/11: 設けない。配合による世代交代が主軸 |

---

## 6. 勧誘 / エンカウント / 出現

| 項目 | 状態 | メモ |
|------|------|------|
| 勧誘成功率式 | fixed | spec 反映済み |
| 勧誘はアイテム / 特技導線 | fixed | DQM寄り |
| 同種所持ペナルティ | fixed | -12 |
| Sランク勧誘不可 | fixed | 配合専用 |
| エンカウント min/max step 方式 | fixed | spec 反映済み |
| 地形別 `terrain_rate` | fixed | spec 反映済み |
| 時間帯別テーブル | fixed | schema に反映 |
| 天候別テーブル | fixed | schema に反映 |
| 出現Lvレンジ | next | zone ごとの標準値必要 |
| 先制 / 不意打ち | fixed | systems/08: SPD比較。自パーティ平均SPD > 敵平均SPD×1.3 で先制15%、逆で不意打ち10% |
| リペル / よけ鈴相当 | fixed | content/04: `item_field_repelash`（よけ灰）で低ランク遭遇抑制 |
| レア枠の保証 | fixed | systems/06: recruit pity 連続失敗5回+5、8回+10。ドロップにはpityなし |
| 塔周辺の変異出現 | next | encounter 側で持つか mutation 側で持つか |

---

## 7. 配合 / 変異 / 血統

| 項目 | 状態 | メモ |
|------|------|------|
| 家系 + 特殊 + 変異 のハイブリッド | fixed | requirements 反映済み |
| 配合可能最低Lv10 | fixed | spec 反映済み |
| 親レベルが `plus_value` に効く | fixed | spec 反映済み |
| 継承枠の増え方 | fixed | `2 or 3` |
| 同系統強化ルール | fixed | family rule |
| 特殊レシピ優先順位 | fixed | schema 反映済み |
| 未発見レシピは答えを見せすぎない | fixed | ADR-0008 |
| 変異率基本値 | fixed | systems/03 + systems/06: base 3%、通常導線は原則 12% 以下、global clamp 25% |
| 変異率補正条件 | fixed | systems/03 + systems/06: 世代、触媒、場所、月齢、塔共鳴を定義 |
| 変異種の遺伝ルール | fixed | systems/03: mutation class、aberrant 制約、genealogy_log、継承制約を定義 |
| 配合失敗 / 不完全成功 | fixed | 不採用。配合は常に成功し親は消える。不可逆性が核なので中途半端な失敗は設計思想に合わない |
| 禁じられた配合 | fixed | systems/03: forbidden class、判定順、拒否UI、story_seal / gate_key などを定義 |
| 血統履歴のUI表示量 | fixed | systems/03: 通常画面=親2体+世代数+直近mutation+出生世界、詳細画面=4世代ツリー、以降はsummary |
| 牧場枠圧迫と配合導線 | fixed | systems/11: 牧場38体。200体預かりは不可逆判断の圧を消すため不採用 |
| 図鑑と配合履歴の関係 | fixed | systems/12: 図鑑=発見/所持で開示。配合履歴=テキストログ50件。変異録=図鑑内サブページ |

---

## 8. スキル / 呪文 / 特性

| 項目 | 状態 | メモ |
|------|------|------|
| 技上限8 | fixed | requirements 反映済み |
| スキルツリー最大3 | fixed | requirements 反映済み |
| 固有特性2枠 | fixed | monster spec 反映 |
| スキルカテゴリ定義 | fixed | systems/10: PHY / MAG / HEL / SUP / DEB / PAS / FLD / REA を定義 |
| 特技進化ライン | fixed | systems/10: 物理 / 魔法 / 回復 / 状態異常の進化線を定義 |
| 範囲指定 | fixed | systems/10: SINGLE / ALL / RANDOM / LINE / FIELD などを定義 |
| 呪文MPコスト法則 | fixed | systems/10: power_factor × range_factor × category_factor × rank_factor |
| 状態異常特化ビルド | fixed | systems/10: INT / RES 差分、成功率上限、ボス補正、連続ペナルティを定義 |
| trait 発動優先順位 | fixed | systems/10 §7.2-7.3: 発動順と同時発動解決を定義 |
| 固有特性の継承可否 | fixed | systems/10 §7.5: 種族固有固定、共有 trait のみ継承、変異 trait 例外あり |
| world 固有スキル | fixed | systems/10 §9: テンプレと最初の4世界分の土着技を定義 |
| forbidden skill combos | fixed | systems/10 §8: 睡眠 / 封印 / 反射 / 世界固有技の禁止組み合わせを定義 |

---

## 9. モンスター設計

| 項目 | 状態 | メモ |
|------|------|------|
| モチーフ配分比 | fixed | spec 反映済み |
| 序盤10体の詳細 | fixed | spec 反映済み |
| 400体全体の taxonomy | fixed | content/06 で定義 |
| rank ごとの役割 | next | 素材、戦力、儀式用など |
| 系統ごとのシルエット原則 | fixed | art/01 + content/06: family ごとの一次形、禁止しがちな型、モチーフ相性を定義 |
| パレット数 / 制限 | fixed | art/01, art/02 で規格化 |
| アニメフレーム予算 | fixed | art/01, art/02 で規格化 |
| フィールドサイズ法則 | fixed | art/02 で battle / field / icon 規格化 |
| 図鑑文の長さ | fixed | content/05: 標準型28-44字（2行）。短文型18-28字（1行） |
| 生態 / 餌 / 鳴き声 | fixed | 図鑑文に生態+逸話+違和感を含む。鳴き声はSE1種/系統。餌は好物baitとして表現 |
| 神話モチーフの変形法則 | fixed | content/06: 神話は役割、姿勢、禁忌構図だけ抽出し、生活圏へ縮退させる |
| 生活圏モチーフの歪め方 | fixed | content/06: 牧畜、葬送、家印、記録、塔との交差で変形法則を定義済み |

---

## 10. 世界 / 地図 / ダンジョン

| 項目 | 状態 | メモ |
|------|------|------|
| 開始村サイズ | fixed | `96 x 64 tiles` |
| 塔前荒地の数値 | fixed | spec 反映済み |
| 世界カテゴリ | fixed | 自然 / 文明 / 異質 / 隠し |
| 拠点ランクと街道規格 | fixed | worlds/06 で定義 |
| 20+世界の配分 | fixed | worlds/05 で定義済み |
| 各世界の禁忌テンプレ | fixed | worlds/08: taboo axis と world sheet template で変奏ルールを定義済み |
| 各世界の政治体制 | fixed | worlds/05 + story/02: 21世界に個別の支配構造を定義済み |
| 各世界の経済構造 | fixed | worlds/05 + story/06: 世界ごとの生産・通商・税制を歴史と連動で定義済み |
| ダンジョン typology | fixed | worlds/04: 生活圏 / 儀式 / 生態 / 制度 / 深層 / 周回 の型を定義済み |
| ショートカット設計 | fixed | worlds/04 + worlds/06: 隠し導線、短い迂回、安全路/危険路の規格あり |
| ランダムダンジョンの深度法則 | fixed | worlds/04: 5F以降でギミック追加、10F以降で空気差分、15F以降で encounter table 差替 |
| ワープ / 一本道 / 暗闇の使用頻度 | fixed | worlds/04: 序盤=一本道+簡易ワープ+隠し通路。中盤以降=スイッチ+暗がり。終盤=記録参照謎解き |
| 門ごとの反応条件テンプレ | next | キーアイテム、ランク、系統、記録 |

---

## 11. 村 / 町 / 生活圏

| 項目 | 状態 | メモ |
|------|------|------|
| 開始村レイアウト | fixed | spec 反映済み |
| 1世界あたりの拠点数 | fixed | 1〜3 |
| 町の大きさランク | fixed | worlds/06: hamlet / village / town / city の tile・画面数を定義済み |
| 町ごとの必須施設 | fixed | worlds/06: 宿、道具、牧場、記録、儀礼、公共施設の必須度を定義済み |
| 日常感を出すオブジェクト数 | fixed | worlds/06: hamlet 12-22, village 20-36, town 34-58, city 56-96 |
| NPCの巡回パターン | fixed | content/07: 固定/巡回/朝昼夜/天候差分を20NPCで定義 |
| 生活音 / 環境音 | fixed | art/03: 14種のアンビエント + 塔深度別の段階的減衰規則 |

---

## 12. ストーリー / 伏線 / 演出

| 項目 | 状態 | メモ |
|------|------|------|
| 導入骨子 | fixed | 03_world_and_story |
| 失踪共通項 | fixed | 名前 / 所属 / 家系の揺らぎ |
| 5幕構成 | fixed | 03_world_and_story |
| 54個の伏線バンク | fixed | 03_world_and_story |
| 世界別の伏線配置表 | fixed | story/03: 54 clue を world 単位へ割当済み。world sheets で具体化を継続 |
| NPC別の伏線担務 | fixed | content/03 + content/07: linked clue と喋れない理由 / 口が緩む条件まで定義 |
| 図鑑文と伏線の接続表 | fixed | story/03 + content/08: clue media と world-by-world clue visibility を定義 |
| 塔内部の演出段階 | fixed | worlds/02: 前庭→前室→札廊→階段室→門の間の演出段階を定義 |
| 無言主人公の選択肢トーン | fixed | content/05: 態度5種、字数帯、媒体別ルールを定義 |
| 初回プレイで気づく伏線量 | fixed | 54件中、初回で seen 可能なのは約30件（56%）。resolved は20件（37%）を目標 |
| 2周目 / 裏ストーリーで見え方が変わる仕掛け | fixed | 記憶のみ（セーブ跨ぎなし）。postgame解放後に過去世界の会話差分で再読可能 |

---

## 13. 経済 / リソース

| 項目 | 状態 | メモ |
|------|------|------|
| 携行20枠 | fixed | spec 反映済み |
| 同一アイテム99個上限 | fixed | requirements 反映済み |
| 所持金上限 | fixed | 99999。6桁は表示幅を圧迫し、5桁で十分な経済圧を維持 |
| 回復アイテム価格帯 | fixed | content/04 で実表定義。最安20〜最高360 |
| 勧誘アイテム価格帯 | fixed | content/04 で実表定義。最安55〜最高460 |
| 配合触媒価格帯 | fixed | content/04 で実表定義。最安150〜最高400 |
| 宿代 / セーブ代 / 蘇生費 | fixed | 宿代=世界Lv帯×3。セーブ無料。蘇生=HP回復中級の1.5倍 |
| 売値係数 | fixed | systems/04: 通常0.45、bait 0.35、触媒0.25、記録0.20。一律ではない |
| 図鑑 / 記録 / 情報の購入 | fixed | content/04: record_item カテゴリ 85〜220。情報屋は記録品経由 |
| money sink 設計 | fixed | systems/04: 恒常sink比率定義済み。消耗品35%+bait25%+触媒20%+宿10%+情報10% |

---

## 14. UI / UX

| 項目 | 状態 | メモ |
|------|------|------|
| 20×18 / 8×8 グリッド | fixed | requirements / ADR |
| 説明帯2行 | fixed | requirements 反映済み |
| 数値中心HP/MP表示 | fixed | spec 反映済み |
| 4コマンド戦闘レイアウト | fixed | requirements 反映済み |
| テキスト速度既定値 | fixed | systems/12 で規格化 |
| フォント字幅表 | fixed | art/04 + systems/12 で規格化 |
| バーチャルパッドサイズ既定値 | fixed | art/05 + systems/12 で logical touch 規格化 |
| 片手 / 両手モード | fixed | systems/12: v1非対応。将来検討 |
| ダンジョン簡易マップ表示量 | fixed | systems/12: 設定OFF既定。探索済みのみ。右上4×4tiles |
| 図鑑フィルタ項目 | fixed | systems/12: 系統/ランク/発見状態。ソートは番号/ランク/系統 |
| 配合履歴の見せ方 | fixed | systems/12: テキストログ最新50件。系譜ツリーはendgame解放 |
| 町 / 村 UI の案内密度 | fixed | systems/12: 施設名看板+1タイルシンボル。初回のみNPC案内 |

---

## 15. アート / サウンド / テキストパイプライン

| 項目 | 状態 | メモ |
|------|------|------|
| niji → Nano Banana → Grok | fixed | requirements 反映済み |
| Aseprite で手仕上げ | fixed | requirements 反映済み |
| prompt metadata 管理 | fixed | art/02, systems/05 の registry 規格で定義 |
| style-bible の独立文書 | fixed | art/01, art/02, art/04, art/05, art/06, art/07 に分割済み |
| UIパーツ一式の style-bible | fixed | art/04 + art/05 で規格化 |
| BGMカテゴリ表 | fixed | art/03: 16カテゴリ、世界別楽器傾向、切替ルール |
| SE辞書 | fixed | art/03: メニュー8種+バトル24種+フィールド12種+システム7種+配合5種+アンビエント14種 |
| テキストトーンガイド | fixed | content/05 で定義済み |
| AI文生成レビュールール | fixed | content/05 で定義済み |

---

## 16. データ / ツール / テレメトリ

| 項目 | 状態 | メモ |
|------|------|------|
| CSV → Resource パイプライン | fixed | REQ-001 Session 03 |
| マスタースキーマ定義 | fixed | systems spec |
| encounter table schema | fixed | systems spec |
| breed rule schema | fixed | systems spec |
| テレメトリイベント | next | REQ-001 後半で詳細化 |
| コンテンツ検証器 | next | 未参照ID、重複ID、欠損画像 |
| balance sandbox | next | 数式確認用シミュレータ。実装フェーズで作成 |
| prompt registry | fixed | systems/05 + art/02: asset_registry.csv に generator/version/seed/approved を管理 |

---

## 17. QA / リスク / 運用

| 項目 | 状態 | メモ |
|------|------|------|
| REQ-001 リスク登録簿 | fixed | plans に作成済み |
| セーブ破損テスト | next | 最優先 |
| iOS export smoke | next | 最優先 |
| フォント可読性テスト | next | 最優先 |
| battle tempo 計測 | next | 1戦20〜45秒 |
| 勧誘のストレス計測 | next | 10〜15分で1体 |
| 配合の前進感テスト | next | 1回で達成感が出るか |
| AI asset provenance check | fixed | systems/05 + art/02: asset_registry.csv で全生成物を追跡 |
| legal similarity review | fixed | art/02: IP similarity screening 手順を production spec に定義 |

---

## 18. 当面の重点

### 先に詰めるべきもの

1. REQ-001 を成立させるための実装基盤
2. style-bible
3. 10体の battle / field / prompt / lore を1セットで完成させる
4. 開始村 + 塔前荒地 + 最初の越境先1マップ
5. 初期スキル30〜40種の定義

### 後から広げるもの

1. 20+世界の詳細
2. 400体の本量産
3. 裏ボス、深層ストーリー
4. 英語対応
