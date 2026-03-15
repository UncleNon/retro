# AI素材生成プロンプト集

## 共通プレフィックス（全プロンプトに付与）

```
Game Boy Color style pixel art, limited color palette, 1px black outline, 2-tone cel shading, no anti-aliasing, no dithering, no gradients, transparent background
```

## 1. モンスターバトルスプライト（PixelLab用）

### 小型 (24×24px) E rank
```
GBC-style pixel art monster battle sprite, 24x24 pixels, front-facing pose.
Monster: [NAME] - [DESCRIPTION]
Element: [ELEMENT]
Style: 1px black outline, 2-tone cel shading, cute/simple design
Colors: Use only from attached palette reference
Reference: [ATTACH STYLE REF IMAGE]
```

### 中型 (32×32px) D-C rank
```
GBC-style pixel art monster battle sprite, 32x32 pixels, front-facing pose.
Monster: [NAME] - [DESCRIPTION]
Element: [ELEMENT]
Style: 1px black outline, 2-tone cel shading, detailed but readable at small size
Colors: Use only from attached palette reference
Reference: [ATTACH STYLE REF IMAGE]
```

### 大型 (48×48px) B-A rank
```
GBC-style pixel art monster battle sprite, 48x48 pixels, front-facing pose, imposing presence.
Monster: [NAME] - [DESCRIPTION]
Element: [ELEMENT]
Style: 1px black outline, 2-tone cel shading, detailed and powerful looking
Colors: Use only from attached palette reference
Reference: [ATTACH STYLE REF IMAGE]
```

### ボス級 (56×56px) S rank
```
GBC-style pixel art boss monster battle sprite, 56x56 pixels, front-facing pose, divine/legendary presence.
Monster: [NAME] - [DESCRIPTION]
Element: [ELEMENT]
Style: 1px black outline, 2-tone cel shading, maximum detail, awe-inspiring design
Colors: Use only from attached palette reference
Reference: [ATTACH STYLE REF IMAGE]
Generate 2 idle frames + 3 attack frames as spritesheet
```

## 2. フィールドキャラクター（PixelLab用）

### 主人公 / NPC
```
GBC-style pixel art character sprite, 16x16 pixels, top-down RPG view, 2-head-tall chibi proportions.
Character: [NAME] - [DESCRIPTION: hair, clothes, features]
Generate 4-directional walk cycle (down, left, right, up), 2 frames each.
Output as horizontal spritesheet: 128x16px (8 frames)
Style: 1px black outline, 2-tone cel shading
Colors: Use only from attached palette reference
Reference: [ATTACH STYLE REF IMAGE]
```

## 3. タイルセット（PixelLab用）

### ダンジョンテーマ
```
Top-down RPG tileset, GBC pixel art style, 8x8px grid.
Theme: [THEME NAME] (e.g., forest dungeon, ice cave, volcano)
Required tiles:
- Floor: 3 variations (plain, cracked, decorated)
- Wall: straight (N/S/E/W), corner (4 types), T-junction (4 types)
- Door: open and closed states
- Stairs: up and down
- Decorative: [theme-specific objects, e.g., mushrooms, crystals, lava pools]
Style: 1px black outline, 2-tone cel shading, tiles must seamlessly connect
Colors: Use only from attached palette reference
Reference: [ATTACH STYLE REF IMAGE]
```

### 拠点タウン
```
Top-down RPG town tileset, GBC pixel art style, 8x8px grid.
Required tiles:
- Ground: grass, cobblestone, dirt path (3 variations each)
- Buildings: wall, roof, door, window (2x2 tile buildings)
- Decorations: trees, flowers, fence, signpost, well, barrel, crate
- Water: pond edge tiles (autotile compatible)
Style: 1px black outline, warm and welcoming color scheme
Colors: Use only from attached palette reference
Reference: [ATTACH STYLE REF IMAGE]
```

## 4. アイテムアイコンバッチ（GPT-4o用）

```
A 5x6 grid of 30 RPG item icons, 16x16 pixels each, Game Boy Color pixel art aesthetic.
Strict rules: 1px black outline, 2-tone cel shading, NO anti-aliasing, NO gradients.
Each item uses max 4 colors from this palette: [LIST HEX CODES]
Transparent background, clear separation between items.

Items (row by row):
Row 1: healing herb, antidote, moon herb, full heal potion, revival herb
Row 2: strength seed, agility seed, intelligence seed, defense seed, MP restore water
Row 3: iron sword, steel sword, flame blade, ice brand, thunder edge
Row 4: leather shield, iron shield, magic barrier, dragon shield, holy shield
Row 5: leather cap, iron helm, wizard hat, dragon helm, crown
Row 6: escape rope, warp wing, monster bait (raw meat), smoke bomb, treasure key
```

## 5. UIパーツ（PixelLab用）

```
GBC-style pixel art RPG UI elements, 8x8px base grid.
Required elements:
- Message window border: 9-slice compatible (3x3 = 9 tiles of 8x8px each)
  Corner tiles, edge tiles (horizontal/vertical), center fill tile
- Cursor arrow: 8x8px, 2 animation frames (pointing right)
- HP bar: red gradient, 4px height, segment tiles
- MP bar: blue gradient, 4px height, segment tiles
- Menu highlight: inverted color bar
- Button prompts: A button, B button icons (8x8px each)
Style: clean, readable, consistent with GBC RPG aesthetic
Colors: White, light gray, dark gray, black (UI palette)
Reference: [ATTACH STYLE REF IMAGE]
```

## 6. バトルエフェクト（手描き推奨・参考プロンプト）

```
GBC-style pixel art battle effect animation, [SIZE]x[SIZE] pixels.
Effect: [EFFECT NAME] (e.g., fire spell, ice spell, thunder strike, slash)
Frames: [NUMBER] frames as horizontal spritesheet
Style: 1px outline where applicable, bright contrasting colors for readability
Colors: Use effect-appropriate sub-palette from master palette
```

## プロンプトエンジニアリングTips

1. **必ずstyle referenceを添付する** - テキストだけでは一貫性が保てない
2. **1セッションで同カテゴリをまとめて生成** - バッチ内の一貫性が高まる
3. **サイズを明示的に指定** - "24x24 pixels" のように具体的に
4. **ネガティブ指定も有効** - "no anti-aliasing, no gradients, no smooth edges"
5. **生成後は必ずAsperiteでパレットリマップ** - これが最も重要な品質保証ステップ
