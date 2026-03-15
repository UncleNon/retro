# 91. Monster Sprite Prompt And Output Spec Legacy

> **ステータス**: Legacy Draft v1.0
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/specs/art/01_style_bible.md`
> - `docs/specs/content/06_monster_taxonomy_and_motif_rules.md`
> - `docs/specs/systems/05_id_naming_validation_and_registry_rules.md`
>
> **注記**: monster sprite の canonical production authority は `docs/specs/art/02_monster_sprite_production_manual.md`。この文書は旧ドラフト比較用に残す。

---

## 1. 目的

- 400体のモンスター量産で、`prompt はあるが出力が毎回ブレる` 状態を防ぐ
- `何をどう生成し、何を手で直し、何を export して承認するか` を工程単位で固定する
- battle sprite, field sprite, icon, animation の読みやすさを別々に保証する

---

## 2. 生成対象

| 対象 | 用途 | 既定サイズ |
|------|------|-----------:|
| `battle_sprite_s` | 序盤小型 | `24x24` or `32x32` |
| `battle_sprite_m` | 標準 | `32x32` |
| `battle_sprite_l` | 大型 | `48x48` |
| `battle_sprite_xl` | ボス級 | `56x56` |
| `field_sprite` | フィールド表示 | `16x16` |
| `menu_icon` | 図鑑、一覧、ソート補助 | `16x16` |
| `face_chip` | 会話窓 / 図鑑用簡易顔 | `24x24` |
| `anim_sheet` | battle待機 / 攻撃 / hit | 可変 |

### 2.1 ランク別の基本サイズ

| rank | 既定 battle size | 例外条件 |
|------|------------------|----------|
| E | `24x24` or `32x32` | massive silhouette のみ `32x32` |
| D | `32x32` | なし |
| C | `32x32` | 長身 / 巨体で `48x48` 可 |
| B | `32x32` or `48x48` | 役割がボス寄りなら `48x48` |
| A | `48x48` | 細身の divine / magic は `32x32` 可 |
| S | `48x48` or `56x56` | 終盤主役級のみ `56x56` |

### 2.2 family 別の field 既定

| family | 既定 field 表現 |
|--------|-----------------|
| `slime` | `16x16` 内に収める |
| `beast` | `16x16`, 必要なら 2x1 風シルエット |
| `bird` | `16x16`, 翼を閉じた待機形を基本にする |
| `plant` | `16x16`, 根本と頭頂を強調 |
| `material` | `16x16`, 硬い重心を保つ |
| `magic` | `16x16`, 浮遊感は影で補助 |
| `undead` | `16x16`, 欠けを情報圧にしすぎない |
| `dragon` | `16x16` で読めない場合のみ `24x24` 特例 |
| `divine` | `16x16`, 儀式性は輪郭で出す |

---

## 3. battle sprite の構図規格

### 3.1 キャンバス占有率

| サイズ | 占有率ルール |
|--------|--------------|
| `24x24` | 本体が `70%〜82%` を占める |
| `32x32` | 本体が `68%〜84%` を占める |
| `48x48` | 本体が `62%〜82%` を占める |
| `56x56` | 本体が `58%〜78%` を占める |

### 3.2 シルエットの読み

- 第一読解は `3 shape masses` 以内に抑える
- 胴体、頭部、主部位の順で読む
- 小部品で identity を支えない
- `左右対称の美しさ` より `一瞬で読める形` を優先する

### 3.3 向き

| 対象 | 既定向き |
|------|----------|
| 通常モンスター | 3/4 view, 右向き寄り |
| boss / gatekeeper | 正面寄り 3/4 |
| bird | 首とくちばしが読める斜め向き |
| serpentine | 胴の流れが分かる S 字寄り |

### 3.4 ポーズ

- 基本は `idle / standing`
- 跳躍、噛みつき、咆哮などの誇張ポーズは attack frame で使う
- 待機絵で四肢を広げすぎない
- 画面外へ飛び出す部位を前提にしない

---

## 4. 顔、目、口の規格

### 4.1 目の原則

- 目は必須ではない
- ただし `視線の有無` は必ず決める
- 視線が必要なら、顔パーツより先に `どこを見ているか` を決める

### 4.2 目のサイズ目安

| battle size | 目の目安 |
|-------------|----------|
| `24x24` | 1〜2 px × 1〜2 箇所 |
| `32x32` | 1〜3 px × 1〜2 箇所 |
| `48x48` | 2〜4 px × 1〜2 箇所 |
| `56x56` | 2〜5 px × 1〜2 箇所 |

### 4.3 目の種類

| 種類 | 用途 |
|------|------|
| 点目 | E〜D の読解優先 |
| 細線目 | 鳥、material、divine |
| 穴目 | undead、magic、gate-touched |
| 鈴目 / 紋目 | ritual, bureaucratic の変奏 |
| 反射目 | divine, astral, boss |

### 4.4 口の原則

- 口は `記号的笑顔` を避ける
- 口を描く場合は、`機能` を先に決める
- 噛む、吸う、鳴らす、囁く、漏れる、結ぶ、縫う、裂ける

### 4.5 禁止

- 既存マスコット風の大きな丸目
- 常時笑顔
- 複雑な歯列で情報量を稼ぐ
- 瞳グラデーション

---

## 5. 線、面、陰影

### 5.1 線

- 原則 1px
- 内部線は必要最低限
- 形の分離は `色差` を優先し、内部線だらけにしない

### 5.2 面

- ベタ面を主体にする
- 中サイズ以下では材質感を texture noise に頼らない
- 斑点、煤、湿りは `配置の意味` を持たせる

### 5.3 陰影

| 項目 | ルール |
|------|--------|
| 光源 | 左上固定 |
| 明部 | 1段階までを基本 |
| 影 | 1〜2段階 |
| 反射 | divine / metal / gate 系のみ限定的に許可 |

### 5.4 禁止

- エアブラシ的な柔らかい面
- 無意味な dithering
- 頂点ごとの過剰ハイライト
- 半透明処理に頼る表現

---

## 6. 背景、透過、余白

### 6.1 battle sprite

- 既定は `transparent background`
- 影が必要な場合のみ本体の直下に 1〜2 色の小影を置く
- 背景込みで生成してから切り抜く運用を標準にしない

### 6.2 field sprite

- 透過 PNG を基本
- 接地が分かるように足元の最暗色を失わせない
- 浮遊個体は接地影 1 つで補う

### 6.3 余白

| サイズ | 四辺の最小余白 |
|--------|----------------|
| `24x24` | 1 px |
| `32x32` | 2 px |
| `48x48` | 3 px |
| `56x56` | 4 px |

---

## 7. アニメーション規格

### 7.1 最低フレーム

| 用途 | 最低 |
|------|-----:|
| 待機 | 2F |
| 攻撃 | 2F |
| hit | 2F |
| 勧誘成功時リアクション | 2F |
| 倒れる | 2F |

### 7.2 allowed motion

- 呼吸
- 微振動
- 首や札の揺れ
- 翼や蔓の軽い開閉
- 目や紋の点滅

### 7.3 forbidden motion

- 全身を大きく潰す stretch
- ぬるぬる補間
- 本体 silhouette が別物になる変形

---

## 8. Prompt の必須ブロック

### 8.1 battle sprite prompt

1. `Invariant`
2. `Canvas And Output`
3. `Silhouette`
4. `Primary Motif`
5. `Secondary Motif`
6. `Palette`
7. `Surface Details`
8. `Face / Gaze`
9. `Negative`

### 8.2 field sprite prompt

1. `Invariant`
2. `16x16 readability`
3. `What must survive from battle silhouette`
4. `Simplification rules`
5. `Negative`

### 8.3 Prompt の記述順

- 先に canvas と pixel constraints
- 次に silhouette
- その後にモチーフ
- 最後に texture / wear / minor parts

---

## 9. Prompt テンプレート

### 9.1 battle sprite

```text
pixel art, transparent background, {size}px sprite, readable at 1x scale,
1px darkest-color outline, top-left lighting, no anti-aliasing, no dithering,
no gradient, no smooth shading, idle standing pose, canvas occupancy 70-85%,
strong {silhouette_type} silhouette, family {family},
primary motif: {primary_motif},
secondary motif: {secondary_motif_as_physical_detail},
limited {color_count} color palette, dominant tones: {dominant_colors},
accent color: {accent_color},
surface details: {wear_patterns_and_materials},
gaze: {gaze_rule}, mouth rule: {mouth_rule},
dark pastoral fantasy, taboo and record-keeping atmosphere,
no text, no logo, no background scene
```

### 9.2 field sprite

```text
pixel art, transparent background, 16x16 sprite, readable at 1x scale,
1px outline, no anti-aliasing, no dithering, no gradient,
simplified version of the same creature, preserve:
{must_keep_shape_1}, {must_keep_shape_2}, {must_keep_shape_3},
remove minor texture noise, keep only the major silhouette and one identity detail
```

### 9.3 negative prompt

```text
no pokemon-like mascot proportions,
no dragon-quest-like slime face,
no glossy rendering,
no painterly texture,
no modern UI icon style,
no cinematic background,
no multiple creatures,
no oversized anime eyes,
no trademark resemblance
```

---

## 10. モデル別の出力要求

### 10.1 `niji 7`

- silhouette と mood の案出しに使う
- そのまま採用しない
- 1回で完成品を狙わず、shape discovery に限定する

### 10.2 `gpt-image`

- pixel 出力の叩き台に使う
- outline と transparent background の指定を強くする
- 生成後に Aseprite 前提で cleanup する

### 10.3 `Nano Banana`

- sprite sheet 化や variation 展開に使う
- `single character only`
- pose 一貫性が崩れやすいので battle sprite の完成品を input に使う

---

## 11. Export 規格

### 11.1 ファイル名

| 用途 | 形式 |
|------|------|
| battle source | `mon_{id}_{slug}_b{size}.aseprite` |
| battle export | `mon_{id}_{slug}_b{size}.png` |
| field source | `mon_{id}_{slug}_f16.aseprite` |
| field export | `mon_{id}_{slug}_f16.png` |
| icon export | `mon_{id}_{slug}_i16.png` |
| anim sheet | `mon_{id}_{slug}_anim_{state}.png` |

### 11.2 export ルール

- 本番登録前に不要余白を trim しすぎない
- anchor point を battle/field で揃える
- field と icon は別 export にする
- approved 前に `asset_registry.csv` へ記録する

### 11.3 承認に必要なもの

- battle sprite PNG
- field sprite PNG
- menu icon PNG
- source file
- prompt text
- negative prompt
- hand-fix memo

---

## 12. QA Checklist

### 12.1 battle

- 1x で family と rank 感が読めるか
- 3 shape masses を越えていないか
- 顔がなくても視線が成立しているか
- 背景なしで立つか

### 12.2 field

- 16x16 に縮めても identity が残るか
- 足元 / 接地感が失われていないか
- 主要 detail を 1 つに絞れているか

### 12.3 production

- prompt から再生成可能か
- model 依存の偶然に寄っていないか
- asset registry に必要情報が揃っているか
- 既存IPの silhouette 記憶を引いていないか
