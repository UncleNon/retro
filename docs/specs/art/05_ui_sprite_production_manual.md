# 05. UI & HUD Sprite Production Manual

> **Status**: Draft v1.0
> **Last Updated**: 2026-03-15
> **References**:
> - `docs/specs/art/01_style_bible.md`
> - `docs/specs/art/02_monster_sprite_production_manual.md`
> - `docs/requirements/07_ui_ux.md`
> - `docs/requirements/10_text_localization.md`
> - `docs/requirements/02_game_design_core.md`

---

## Purpose

This document is the **single definitive reference** for producing every UI and HUD sprite, icon, window frame, font glyph, cursor, and screen layout element in the game. Every pixel-level decision -- position, size, color, animation timing, text rendering rule, margin, padding, z-order -- is specified here in full. No external document is required to resolve an ambiguity about any UI element. Any artist, any engineer, any reviewer can use this manual alone to produce or evaluate a UI element that is consistent with every other UI element in the game.

This manual does not replace the Style Bible (`01_style_bible.md`). It extends it with exhaustive production-level detail specific to UI and HUD elements.

---

## 1. UI Grid and Layout Standards

### 1.1 Internal Resolution and Tile Grid

The game renders to an internal framebuffer of **160 pixels wide by 144 pixels tall**. This framebuffer is then scaled to fill the device display. All UI layout is defined in terms of this 160x144 pixel space. No UI element is positioned using device-resolution coordinates.

The framebuffer is divided into a grid of **20 columns by 18 rows** of 8x8 pixel tiles.

| Property | Value |
|----------|-------|
| Internal resolution | 160 x 144 px |
| Tile size | 8 x 8 px |
| Grid columns | 20 (160 / 8) |
| Grid rows | 18 (144 / 8) |
| Total tiles on screen | 360 |

All window edges, text baselines, icon placements, and separator lines align to this 8x8 grid unless explicitly stated otherwise. Sub-tile positioning (pixel-level offsets within a tile) is permitted only for: text glyph kerning adjustments, cursor animation offsets, damage number float positions, and status ailment icon placement within a status row.

### 1.2 Coordinate System

The origin (0, 0) is the **top-left** pixel of the 160x144 framebuffer. X increases rightward. Y increases downward.

| Corner | Pixel Coordinate |
|--------|-----------------|
| Top-left | (0, 0) |
| Top-right | (159, 0) |
| Bottom-left | (0, 143) |
| Bottom-right | (159, 143) |

Tile coordinates use the same origin. Tile (0, 0) occupies pixels (0, 0) through (7, 7). Tile (19, 17) occupies pixels (152, 136) through (159, 143).

### 1.3 Safe Areas by Screen Type

Each screen type reserves specific regions for fixed UI elements. The "content area" is the remaining space available for dynamic content. All measurements are in tile coordinates (column, row), where tile (0, 0) is top-left.

#### Field Screen

| Region | Tile Range | Pixel Range | Purpose |
|--------|-----------|-------------|---------|
| Full viewport | (0,0) to (19,17) | (0,0) to (159,143) | Map rendering area |
| Message overlay zone | (0,14) to (19,17) | (0,112) to (159,143) | Message window appears here when triggered |
| Menu overlay zone | (0,0) to (7,9) | (0,0) to (63,79) | Main menu window appears here |

On the field screen, the entire 20x18 grid is available for the map. UI elements overlay on top of the map when activated and disappear when dismissed. No permanent HUD occupies field screen space.

#### Battle Screen

| Region | Tile Range | Pixel Range | Purpose |
|--------|-----------|-------------|---------|
| Enemy display zone | (0,0) to (19,6) | (0,0) to (159,55) | Enemy monster sprites (up to 3) |
| Party status zone | (0,7) to (19,10) | (0,56) to (159,87) | 3 party member status rows |
| Command/message zone | (0,11) to (19,17) | (0,88) to (159,143) | Command menu and message text |

#### Menu Screen (Full-screen menus: Party, Items, Codex, Breeding, Settings, Save/Load)

| Region | Tile Range | Pixel Range | Purpose |
|--------|-----------|-------------|---------|
| Title bar | (0,0) to (19,1) | (0,0) to (159,15) | Screen title display |
| Content area | (0,2) to (19,15) | (0,16) to (159,127) | Main content (lists, details, previews) |
| Description strip | (0,16) to (19,17) | (0,128) to (159,143) | Item/skill/monster description text (2 lines) |

#### Breeding Screen

| Region | Tile Range | Pixel Range | Purpose |
|--------|-----------|-------------|---------|
| Title bar | (0,0) to (19,1) | (0,0) to (159,15) | "はいごう" title |
| Parent 1 zone | (0,2) to (9,8) | (0,16) to (79,71) | Left parent display |
| Parent 2 zone | (10,2) to (19,8) | (80,16) to (159,71) | Right parent display |
| Result preview zone | (0,9) to (19,13) | (0,72) to (159,111) | Offspring preview |
| Confirm/description strip | (0,14) to (19,17) | (0,112) to (159,143) | Confirmation prompt and description |

#### Codex Screen

| Region | Tile Range | Pixel Range | Purpose |
|--------|-----------|-------------|---------|
| Title bar | (0,0) to (19,1) | (0,0) to (159,15) | "ずかん" title |
| List panel | (0,2) to (9,15) | (0,16) to (79,127) | Monster list (left half) |
| Detail panel | (10,2) to (19,15) | (80,16) to (159,127) | Selected monster detail (right half) |
| Description strip | (0,16) to (19,17) | (0,128) to (159,143) | Lore text / filter info |

### 1.4 Margin and Padding Rules

All margin and padding values are in pixels.

| Context | Value | Rule |
|---------|------:|------|
| Window outer margin (from screen edge) | 0 px | Windows may touch the screen edge. No mandatory outer margin. |
| Window inner padding (border to content) | 4 px | Content starts 4 pixels inside the window border on all four sides. This means text and icons begin at the 5th pixel from the inner edge of the border. |
| List item vertical spacing | 0 px | List items are placed on consecutive 8px rows with no gap between them. The 8px line height provides sufficient visual separation. |
| Section separator | 8 px | When a window contains multiple logical sections, an 8px (1 tile) gap separates them. No drawn line is required; the empty space is sufficient. |
| Icon-to-text spacing | 2 px | When an icon appears to the left of text on the same row, 2 pixels of space separate the icon's right edge from the text's first glyph. |
| Label-to-value spacing | 4 px | When a label (e.g., "HP") appears to the left of a numeric value, 4 pixels of space separate them. |

### 1.5 Overlapping Windows (Z-Order and Opacity)

Multiple windows can appear on screen simultaneously. Their stacking order is defined by a strict z-order.

| Z-Layer | Contents |
|--------:|----------|
| 0 (back) | Map / Background |
| 1 | Primary UI window (e.g., battle status, main menu) |
| 2 | Secondary UI window (e.g., submenu, item list, command detail) |
| 3 | Tertiary UI window (e.g., confirmation dialog, tooltip) |
| 4 | Message window (always above other UI) |
| 5 | System overlay (save indicator, connection status) |
| 6 | Transition effect (fade overlay) |
| 7 | Virtual pad (always topmost) |

Rules:
- A higher z-layer always renders on top of a lower z-layer. There are no exceptions.
- Windows do NOT use partial transparency or alpha blending. Every window is fully opaque. The fill color of the window completely obscures whatever is behind it.
- When a new window opens on top of an existing window, the existing window remains fully rendered but partially hidden behind the new window.
- Maximum simultaneous windows on screen: 4 (primary + secondary + tertiary + message). If this limit is reached, the oldest non-essential window closes before a new one opens.
- The virtual pad overlay (z-layer 7) is always visible during gameplay. It is rendered by the platform layer, not by the game's UI system.
- No window casts a blurred shadow on the windows below it. If a window has a shadow (see Section 2.7), the shadow is a solid pixel element that is part of the window's sprite, not a real-time compositing effect.

---

## 2. Window Frame Design

### 2.1 9-Slice Window Construction

All windows in the game are constructed using the 9-slice method. A window frame is composed of 9 tiles:

```
TL  TC  TR
ML  MC  MR
BL  BC  BR
```

| Tile | Name | Size | Description |
|------|------|------|-------------|
| TL | Top-Left corner | 8x8 px | Fixed corner piece, never stretched |
| TC | Top-Center edge | 8x8 px | Repeats horizontally to fill top edge |
| TR | Top-Right corner | 8x8 px | Fixed corner piece, never stretched |
| ML | Middle-Left edge | 8x8 px | Repeats vertically to fill left edge |
| MC | Middle-Center fill | 8x8 px | Repeats in both directions to fill interior |
| MR | Middle-Right edge | 8x8 px | Repeats vertically to fill right edge |
| BL | Bottom-Left corner | 8x8 px | Fixed corner piece, never stretched |
| BC | Bottom-Center edge | 8x8 px | Repeats horizontally to fill bottom edge |
| BR | Bottom-Right corner | 8x8 px | Fixed corner piece, never stretched |

Windows are always sized in whole tile increments. The minimum window size is 3x3 tiles (24x24 px). There are no windows smaller than this. Windows are never sized at non-tile-multiple dimensions.

The 9-slice tiles are never scaled, rotated, or distorted. They are placed at their native 8x8 pixel size and tiled (repeated) to fill the required area.

### 2.2 Window Frame Variants

There are **6** window frame variants. Each variant has its own set of 9-slice tiles with distinct visual characteristics.

| Variant ID | Name | Usage |
|-----------|------|-------|
| `win_default` | Default | Message windows, field menus, party screens, item lists, save/load, settings, NPC dialog |
| `win_battle` | Battle | Battle command window, battle status window, battle message window |
| `win_system` | System | Confirmation dialogs, error messages, system notifications, title screen options |
| `win_breeding` | Breeding | Breeding screen windows (parent selection, preview, result, skill inheritance) |
| `win_shop` | Shop | Buy/sell windows, price display, gold display, transaction confirmation |
| `win_codex` | Codex | Monster codex list, codex detail, codex filter, lore display |

### 2.3 Pixel Construction of Corner Pieces

Each corner tile is 8x8 pixels. The following describes the exact pixel fill pattern for every corner of every variant. Coordinates within each tile are (x, y) with (0, 0) at the top-left of the tile.

#### Default Variant (`win_default`)

The default window has a 1px outer border, a 1px inner line (lighter), and interior fill.

**Top-Left corner (TL):**
```
. . . . . . . .    (row 0: all transparent)
. . . X X X X X    (row 1: pixels 3-7 are border color)
. . X B B B B B    (row 2: pixel 2 is border, pixels 3-7 are inner-line color)
. X B F F F F F    (row 3: pixel 1 border, pixel 2 inner-line, pixels 3-7 fill)
. X B F F F F F    (row 4: same as row 3)
. X B F F F F F    (row 5: same as row 3)
. X B F F F F F    (row 6: same as row 3)
. X B F F F F F    (row 7: same as row 3)
```
Legend: `.` = transparent, `X` = border color, `B` = inner-line color, `F` = fill color

The border forms a rounded corner: row 0 is entirely transparent, row 1 starts at pixel 3 (creating a 3-pixel indent), row 2 starts at pixel 2, rows 3-7 start at pixel 1. This produces a subtle rounded corner appearance that reads as "softened" at 1x without using anti-aliasing.

**Top-Right corner (TR):** Horizontal mirror of TL.

**Bottom-Left corner (BL):** Vertical mirror of TL.

**Bottom-Right corner (BR):** Both axes mirrored from TL.

**Top-Center edge (TC):**
```
. . . . . . . .    (row 0: all transparent)
X X X X X X X X    (row 1: all border color)
B B B B B B B B    (row 2: all inner-line color)
F F F F F F F F    (rows 3-7: all fill color)
F F F F F F F F
F F F F F F F F
F F F F F F F F
F F F F F F F F
```

**Middle-Left edge (ML):**
```
. X B F F F F F    (all 8 rows: identical)
. X B F F F F F
. X B F F F F F
. X B F F F F F
. X B F F F F F
. X B F F F F F
. X B F F F F F
. X B F F F F F
```

**Middle-Right edge (MR):** Horizontal mirror of ML.

**Bottom-Center edge (BC):** Vertical mirror of TC.

**Middle-Center fill (MC):**
```
F F F F F F F F    (all 8 rows: solid fill color)
F F F F F F F F
F F F F F F F F
F F F F F F F F
F F F F F F F F
F F F F F F F F
F F F F F F F F
F F F F F F F F
```

#### Battle Variant (`win_battle`)

The battle window uses a slightly thicker visual impression: 1px border, 1px gap (fill color), 1px inner rule line, then fill. This creates a double-border look evoking a DQM/DQ battle menu.

**Top-Left corner (TL):**
```
. . . . . . . .    (row 0: transparent)
. . . X X X X X    (row 1: border)
. . X F F F F F    (row 2: pixel 2 border, rest fill)
. X F B B B B B    (row 3: pixel 1 border, pixel 2 fill, pixels 3-7 inner rule)
. X F B F F F F    (row 4: pixel 1 border, pixel 2 fill, pixel 3 inner rule, rest fill)
. X F B F F F F    (row 5: same)
. X F B F F F F    (row 6: same)
. X F B F F F F    (row 7: same)
```

The 1px gap between the outer border and the inner rule creates the visual "channel" characteristic of classic JRPG battle menus.

All other edges and corners follow the same mirroring logic as the default variant.

#### System Variant (`win_system`)

The system window is visually minimal: 1px border, no inner rule, immediate fill. It is used for transient dialogs that should feel functional rather than decorative.

**Top-Left corner (TL):**
```
. . . . . . . .    (row 0: transparent)
. . X X X X X X    (row 1: border starts at pixel 2)
. X F F F F F F    (row 2: pixel 1 border, rest fill)
. X F F F F F F    (row 3-7: same)
. X F F F F F F
. X F F F F F F
. X F F F F F F
. X F F F F F F
```

The system variant has a tighter corner radius (only 1 pixel of indent on row 1, compared to 2 for default).

#### Breeding Variant (`win_breeding`)

The breeding window uses the same structure as the default variant but with a distinct color set (see Section 2.8). The corner construction is pixel-identical to `win_default`. The differentiation is purely through color.

#### Shop Variant (`win_shop`)

The shop window uses the same structure as the default variant with a distinct color set (see Section 2.8). The corner construction is pixel-identical to `win_default`.

#### Codex Variant (`win_codex`)

The codex window uses the same structure as the default variant but adds a 1px decorative dot pattern on the inner-line row. Every other pixel on the inner-line rows (TC row 2, ML column 2, MR mirrored, BC mirrored) alternates between inner-line color and fill color. This creates a subtle dotted inner border that evokes an encyclopedia or scholarly document.

**Top-Center edge (TC) for codex:**
```
. . . . . . . .    (row 0: transparent)
X X X X X X X X    (row 1: border)
B F B F B F B F    (row 2: alternating inner-line and fill)
F F F F F F F F    (rows 3-7: fill)
F F F F F F F F
F F F F F F F F
F F F F F F F F
F F F F F F F F
```

### 2.4 Border Thickness Summary

| Layer | Thickness | Description |
|-------|----------:|-------------|
| Outer border line | 1 px | The outermost visible line of the window. Always present. |
| Inner rule line | 1 px | Present in `win_default`, `win_battle`, `win_breeding`, `win_shop`, `win_codex`. Absent in `win_system`. |
| Gap between outer and inner (battle only) | 1 px | Present only in `win_battle`. Filled with fill color. |
| Inner margin (padding) | 4 px | Space between the innermost frame line and the content. |

Total border consumption from window edge to content start:

| Variant | Border + Rules (px) | Inner Margin (px) | Total (px) |
|---------|--------------------:|-------------------:|-----------:|
| `win_default` | 2 (border + inner-line) | 4 | 6 |
| `win_battle` | 3 (border + gap + inner-rule) | 4 | 7 |
| `win_system` | 1 (border only) | 4 | 5 |
| `win_breeding` | 2 | 4 | 6 |
| `win_shop` | 2 | 4 | 6 |
| `win_codex` | 2 | 4 | 6 |

### 2.5 Window Sizes for Each Usage

All sizes are in tiles (multiply by 8 for pixels).

| Window | Width (tiles) | Height (tiles) | Variant |
|--------|-------------:|---------------:|---------|
| Field message window | 20 | 4 | `win_default` |
| Field main menu | 8 | 10 | `win_default` |
| Battle status window | 20 | 4 | `win_battle` |
| Battle command window | 10 | 6 | `win_battle` |
| Battle message window | 20 | 4 | `win_battle` |
| Battle submenu (strategy) | 10 | 8 | `win_battle` |
| Battle submenu (items) | 12 | 8 | `win_battle` |
| Battle submenu (per-monster commands) | 10 | 6 | `win_battle` |
| Battle target selection | 10 | 4 | `win_battle` |
| Party list window | 20 | 14 | `win_default` |
| Monster detail window | 20 | 16 | `win_default` |
| Item list window | 20 | 14 | `win_default` |
| Item description strip | 20 | 2 | `win_default` |
| Codex list panel | 10 | 14 | `win_codex` |
| Codex detail panel | 10 | 14 | `win_codex` |
| Codex description strip | 20 | 2 | `win_codex` |
| Breeding parent select | 10 | 7 | `win_breeding` |
| Breeding preview window | 20 | 5 | `win_breeding` |
| Breeding skill select | 20 | 8 | `win_breeding` |
| Breeding confirmation | 12 | 4 | `win_breeding` |
| Shop buy/sell window | 20 | 12 | `win_shop` |
| Shop gold display | 8 | 2 | `win_shop` |
| Shop transaction confirm | 12 | 4 | `win_shop` |
| Save/load window | 20 | 16 | `win_system` |
| Settings window | 20 | 16 | `win_system` |
| Confirmation dialog | 12 | 4 | `win_system` |
| Tower/gate selection | 20 | 16 | `win_default` |
| Title screen menu | 10 | 6 | `win_system` |
| NPC name plate | 6 | 1 | `win_default` |

### 2.6 Window Shadow

Windows cast a 1-pixel shadow on their bottom and right edges. The shadow is a solid row/column of shadow-color pixels placed immediately outside the window border.

| Property | Value |
|----------|-------|
| Shadow present | Yes, on all window variants |
| Shadow direction | Bottom and right (consistent with top-left light source) |
| Shadow thickness | 1 px |
| Shadow color | `#000000` at 100% opacity (no alpha blending) |
| Shadow offset | The shadow pixels occupy the row directly below the window's bottom border and the column directly to the right of the window's right border |
| Corner pixel | The single pixel at the intersection of the bottom shadow row and the right shadow column (bottom-right of the shadow "L") IS filled with the shadow color |
| Top and left edges | No shadow pixels on the top or left edges |

The shadow is part of the window sprite's tile data. It is not a compositing effect. When calculating window placement, the shadow's 1px on bottom and right must be accounted for to avoid the shadow being clipped at the screen edge.

Exception: The virtual pad overlay has no shadow. The fade transition overlay has no shadow.

### 2.7 Window Opening and Closing Animation

Windows use a simple scale-in animation when opening and the reverse when closing.

#### Opening Animation

| Frame | Duration | Visual State |
|------:|----------|-------------|
| 1 | 2 game frames (33ms at 60fps) | Window appears at 1/4 final size, centered on final position. Only the center fill tile is visible. |
| 2 | 2 game frames (33ms) | Window expands to 1/2 final size. Corner and edge tiles visible but condensed. |
| 3 | 2 game frames (33ms) | Window expands to 3/4 final size. |
| 4 | 2 game frames (33ms) | Window at final size. Content becomes visible. |

Total opening time: **8 game frames (133ms at 60fps)**.

The window content (text, icons, cursor) does NOT appear until frame 4. During frames 1-3, only the window border and fill are visible.

#### Closing Animation

The closing animation is the opening animation played in reverse (final size to 1/4 size to gone), with the same 8-frame duration.

#### Instant Mode

If the player has set text speed to "instant" in settings, window animations are skipped. Windows appear and disappear in 1 game frame.

#### Message Window Exception

The field message window and battle message window do NOT animate open/close. They appear and disappear in 1 game frame (instant). This avoids interrupting the flow of dialog and battle messages.

### 2.8 Window Color Rules

All colors reference the master palette (`tools/palette-remap/master_palette.hex`). The hex values below are the target colors; the actual exported colors must be the nearest master palette entry.

#### Default Variant (`win_default`)

| Element | Color (hex) | Description |
|---------|-------------|-------------|
| Border | `#1a1a2e` | Very dark blue-black. Not pure black, to keep a slight warmth. |
| Inner-line | `#4a4a6e` | Muted blue-grey. Visible but not bright. |
| Fill | `#16213e` | Deep navy-blue. The classic RPG window blue, slightly muted. |
| Shadow | `#000000` | Pure black. |

#### Battle Variant (`win_battle`)

| Element | Color (hex) | Description |
|---------|-------------|-------------|
| Border | `#1a1a2e` | Same as default. |
| Inner rule | `#5a5a8e` | Slightly brighter blue-grey than default inner-line. Sharper look. |
| Fill | `#0f1a3a` | Deeper, colder blue than default. More serious tone. |
| Gap fill | Same as Fill | The 1px gap between border and inner rule uses the fill color. |
| Shadow | `#000000` | Pure black. |

#### System Variant (`win_system`)

| Element | Color (hex) | Description |
|---------|-------------|-------------|
| Border | `#2a2a2a` | Dark neutral grey. No blue tint. |
| Fill | `#1a1a1a` | Very dark grey, nearly black. Functional, stark. |
| Shadow | `#000000` | Pure black. |

#### Breeding Variant (`win_breeding`)

| Element | Color (hex) | Description |
|---------|-------------|-------------|
| Border | `#2e1a2e` | Dark purple-brown. Evokes organic, life-creation ritual. |
| Inner-line | `#6e4a5e` | Muted rose-grey. |
| Fill | `#1e1028` | Deep muted purple. Slightly organic, slightly unsettling. |
| Shadow | `#000000` | Pure black. |

#### Shop Variant (`win_shop`)

| Element | Color (hex) | Description |
|---------|-------------|-------------|
| Border | `#2e2a1a` | Dark amber-brown. Mercantile, earthy. |
| Inner-line | `#6e5a3a` | Dull gold-brown. |
| Fill | `#1e1810` | Deep warm brown. Sturdy, trustworthy. |
| Shadow | `#000000` | Pure black. |

#### Codex Variant (`win_codex`)

| Element | Color (hex) | Description |
|---------|-------------|-------------|
| Border | `#1a2e2a` | Dark teal-grey. Scholarly, archival. |
| Inner-line (dot pattern) | `#4a6e5e` | Muted teal. |
| Fill | `#101e1a` | Deep dark green-grey. Old paper in a dark room. |
| Shadow | `#000000` | Pure black. |

---

## 3. Text Rendering Rules

### 3.1 Bitmap Font Specification

The game uses a custom bitmap font. No system fonts, no TrueType fonts, no vector rendering. Every character is a pre-drawn pixel grid stored in a sprite sheet.

| Property | Value |
|----------|-------|
| Character cell size | 8 x 8 px |
| Actual glyph drawing area (Latin/numbers) | 7 x 7 px within the 8x8 cell (1px right column and 1px bottom row are spacing) |
| Actual glyph drawing area (Japanese) | 8 x 8 px (full cell, no built-in spacing; spacing is handled by the renderer) |
| Font style | Monospaced bitmap |
| Anti-aliasing | None. Every pixel is fully opaque or fully transparent. |
| Color | Single-color per glyph (color applied by the renderer; the font sheet stores shape only) |

### 3.2 Japanese Font Character Set

The Japanese font must include the following character sets:

#### Hiragana (full set, 83 characters)

```
あいうえお かきくけこ さしすせそ たちつてと なにぬねの
はひふへほ まみむめも やゆよ らりるれろ わをん
がぎぐげご ざじずぜぞ だぢづでど ばびぶべぼ ぱぴぷぺぽ
ぁぃぅぇぉ っ ゃゅょ
ー（長音）
```

#### Katakana (full set, 83 characters)

```
アイウエオ カキクケコ サシスセソ タチツテト ナニヌネノ
ハヒフヘホ マミムメモ ヤユヨ ラリルレロ ワヲン
ガギグゲゴ ザジズゼゾ ダヂヅデド バビブベボ パピプペポ
ァィゥェォ ッ ャュョ
ー（長音）
```

#### Kanji (essential gameplay set, approximately 200-250 characters)

The kanji set is limited to characters needed for gameplay UI, menus, item names, status labels, and brief in-game text. Full narrative text uses hiragana/katakana with selective kanji. The required kanji include:

**Stats and battle:**
力 守 速 賢 精 命 魔 攻 防 体 技 経 験 値 段 階 級 属 性

**Elements and types:**
火 水 風 地 雷 光 闇 無 獣 鳥 植 物 質 竜 神 霊 死

**Items and equipment:**
草 薬 実 石 骨 牙 羽 鱗 角 甲 毒 剣 盾 鎧 兜 飾

**Actions and states:**
攻 撃 回 復 逃 走 使 捨 売 買 戦 勝 負 死 眠 毒 封 混 乱 恐 呪 麻 痺

**Menu and system:**
記 録 設 定 音 量 速 度 言 語 閉 開 選 択 確 認 取 消 保 存 読 込 自 動

**World and story:**
塔 門 村 町 世 界 森 山 海 川 洞 穴 城 王 人 名 前 日 夜

**Breeding:**
配 合 親 子 継 承 変 異 種 卵 誕 生 成 長 特 殊

**Numbers as kanji (for flavor text):**
一 二 三 四 五 六 七 八 九 十 百 千 万

The full kanji list will be finalized during text finalization. The font sheet must have reserved space for up to 300 kanji characters.

#### Numbers and Symbols

```
0 1 2 3 4 5 6 7 8 9
+ - × ÷ = % / : . , ! ? 「 」 『 』 （ ） ・ … ♪ ★ ☆ ▼ ▶ ♂ ♀ ← → ↑ ↓ 〜 ♥
```

### 3.3 English Font Character Set

All printable ASCII characters (95 characters):

```
 !"#$%&'()*+,-./0123456789:;<=>?
@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_
`abcdefghijklmnopqrstuvwxyz{|}~
```

Uppercase and lowercase letters are distinct glyphs. Uppercase occupies the full 7px height of the drawing area. Lowercase x-height is 5px, with ascenders reaching 7px and descenders dropping to pixel row 7 (using the spacing row).

### 3.4 Line Height and Spacing

| Property | Value |
|----------|-------|
| Line height | 8 px (one tile row) |
| Character spacing (horizontal, Japanese) | 0 px (characters are placed edge-to-edge; the 8x8 cell provides no built-in spacing, but the glyph design ensures readability) |
| Character spacing (horizontal, English) | 1 px (the 8x8 cell has 1px built-in right spacing; no additional spacing is added) |
| Word spacing (English only) | 4 px (half a character cell) |
| Tab stops | Not used. No tab characters in game text. |
| Maximum characters per line | 18 (Japanese, at 8px per character plus 0px spacing = 144px, with 8px left padding from window edge = fits in 160px) |
| Maximum characters per line | 18 (English, at 8px per character cell = 144px, same constraint) |

### 3.5 Word Wrapping Rules

- Japanese text: Line breaks can occur between any two characters. No word-wrapping logic is needed because Japanese has no spaces between words. The renderer fills characters left to right, top to bottom, and starts a new line when the current line reaches the maximum character count.
- English text: Line breaks occur at space boundaries. If a word would exceed the line width, the entire word moves to the next line. Hyphenation is not used. If a single word is longer than the maximum line width (18 characters), it is force-broken at the line boundary (this should be avoided by keeping all English text entries under 18 characters per word).
- Mixed text (Japanese with embedded English words): Treated as Japanese rules (break anywhere).
- Manual line break: The control character `\n` in text data forces a line break at that position.

### 3.6 Text Colors

All text colors reference the master palette. The values below are targets; actual values must be the nearest master palette entry.

| Usage | Color (hex) | Description |
|-------|-------------|-------------|
| Normal text | `#e8e8e8` | Near-white. Default for all body text, menu items, dialog. |
| Highlighted text | `#f8f860` | Bright yellow. Used for currently selected menu item, important keywords in dialog. |
| Disabled text | `#606060` | Dark grey. Used for menu items that cannot currently be selected (e.g., an empty item slot, a locked option). |
| Warning text | `#e84040` | Bright red. Used for danger warnings, low HP alerts, irreversible action confirmations. |
| Damage number (normal) | `#ffffff` | Pure white. Standard damage dealt to enemies. |
| Damage number (critical) | `#f8f860` | Bright yellow. Critical hit damage. |
| Damage number (healing) | `#60e860` | Bright green. HP/MP recovery amounts. |
| Damage number (miss) | `#a0a0a0` | Light grey. "MISS" text when an attack misses. |
| MP cost text | `#80b0f8` | Light blue. Used when displaying MP cost of a skill in skill selection. |
| Gold/currency text | `#f8d848` | Gold yellow. Used for gold amounts in shop and status screens. |
| Monster name (own party) | `#e8e8e8` | Near-white. Same as normal text. |
| Monster name (enemy) | `#e8e8e8` | Near-white. Same as normal text. |
| NPC name | `#a0d8f8` | Light cyan-blue. Distinguishes speaker name from dialog text. |
| System message | `#c0c0c0` | Light grey. Slightly dimmer than normal text. Used for auto-save notification, system-level messages. |

### 3.7 Text Display Speed

Text is displayed one character at a time ("typewriter" style). The display speed is configurable in settings.

| Speed Setting | Frames per Character | Milliseconds per Character (at 60fps) | Characters per Second |
|---------------|---------------------:|---------------------------------------:|----------------------:|
| おそい (Slow) | 4 | 67 ms | 15 |
| ふつう (Normal) | 3 | 50 ms | 20 |
| はやい (Fast) | 1 | 17 ms | 60 |
| しゅんかん (Instant) | 0 | 0 ms | All at once |

Default setting: **ふつう (Normal)**.

At "Instant" speed, the entire text block appears in a single game frame. There is no typewriter animation.

### 3.8 Instant Display on Button Press

At any text speed setting (except Instant), pressing the A button while text is still being displayed causes all remaining characters in the current text block to appear immediately in the next game frame. This does not advance to the next text block; it only completes the current one.

If all text in the current block is already fully displayed, pressing A advances to the next text block or closes the message window if no further text exists.

### 3.9 Name Display Rules and Maximum Character Counts

| Name Type | Max Characters (Japanese) | Max Characters (English) | Truncation |
|-----------|:-------------------------:|:------------------------:|------------|
| Monster name | 6 | 10 | If a name exceeds the max, it is truncated and no ellipsis is shown. Names must be authored to fit. |
| Monster nickname (player-given) | 6 | 10 | Input field enforces the limit. Cannot exceed. |
| NPC name | 6 | 10 | Authored to fit. |
| Player name | 6 | 10 | Input field enforces the limit. |
| Item name | 8 | 14 | Authored to fit. |
| Skill name | 8 | 14 | Authored to fit. |
| World name | 8 | 14 | Authored to fit. |
| Menu label | 6 | 10 | Authored to fit. |

All names are authored to fit within their maximum character count. The UI does not implement ellipsis truncation, text scrolling, or font size reduction. If a name does not fit, the name itself must be shortened.

---

## 4. Cursor Design

### 4.1 Specifications

| Property | Value |
|----------|-------|
| Size | 8 x 8 px |
| Shape | Right-pointing triangle (arrowhead), solid fill |
| Color | `#f8f860` (bright yellow, same as highlighted text) |
| Outline | 1px outline in `#000000` on all edges of the triangle |
| Background | Transparent (no background fill behind the cursor) |

### 4.2 Pixel Layout

The cursor is a right-pointing triangle within an 8x8 cell:

```
. . X . . . . .    (row 0)
. . X X . . . .    (row 1)
. . X F X . . .    (row 2)
. . X F F X . .    (row 3)
. . X F F X . .    (row 4)
. . X F X . . .    (row 5)
. . X X . . . .    (row 6)
. . X . . . . .    (row 7)
```

Legend: `.` = transparent, `X` = outline color (`#000000`), `F` = fill color (`#f8f860`)

The triangle points right. It occupies columns 2-5 of the 8x8 cell, vertically centered.

### 4.3 Animation

| Property | Value |
|----------|-------|
| Frame count | 2 |
| Frame 1 | Cursor at base position |
| Frame 2 | Cursor shifted 1 pixel to the right from base position |
| Frame duration | 18 game frames (300ms at 60fps) per frame |
| Cycle | Frame 1 (300ms) -> Frame 2 (300ms) -> repeat |
| Animation type | Position oscillation, not shape change |

The cursor gently pulses left-right by 1 pixel. It does not change shape, color, or opacity between frames.

### 4.4 Movement Behavior

When the player presses up or down to move through a menu, the cursor **jumps** to the next position instantly (within 1 game frame). There is no sliding, easing, or interpolated movement between menu items.

When the cursor reaches the top of a scrollable list and the player presses up, the list scrolls and the cursor remains at the top position. When the cursor reaches the bottom and the player presses down, the list scrolls and the cursor remains at the bottom visible position.

### 4.5 Placement Relative to Menu Items

The cursor is placed to the **left** of the menu item text. The cursor's right edge is 2 pixels to the left of the first character of the menu item.

| Layout | Description |
|--------|-------------|
| Cursor position | Left-aligned within the window's inner padding area |
| Cursor X | Window content left edge (after padding) |
| Text X | Cursor X + 8px (cursor width) + 2px (gap) = Cursor X + 10px |

For menu items without a cursor (non-selectable labels, headers), text starts at the normal cursor X position (no 10px offset).

---

## 5. Message Window

### 5.1 Position and Size

| Property | Value |
|----------|-------|
| Position | Bottom of the screen |
| Tile position | (0, 14) to (19, 17) |
| Pixel position | (0, 112) to (159, 143) |
| Width | 20 tiles (160 px, full screen width) |
| Height | 4 tiles (32 px) |
| Variant | `win_default` for field/NPC dialog; `win_battle` for battle messages |

### 5.2 Text Area Within Message Window

After accounting for the window border (2px) and inner padding (4px), the available text area is:

| Property | Value |
|----------|-------|
| Text area left edge | 6 px from window left |
| Text area top edge | 6 px from window top (pixel Y = 118 on screen) |
| Text area width | 148 px (160 - 6 left - 6 right) |
| Text area height | 20 px (32 - 6 top - 6 bottom) |
| Maximum visible text lines | 2 lines (2 x 8px = 16px, with 4px remaining below) |

The message window displays a maximum of **2 lines of text** at a time. Each line holds up to 18 characters (Japanese) or 18 character cells (English).

### 5.3 Page Advance Indicator

When there is more text to display after the current 2 lines, a page advance indicator appears.

| Property | Value |
|----------|-------|
| Symbol | `▼` (downward-pointing triangle) |
| Size | 8 x 8 px (one character cell) |
| Position | Bottom-right corner of the message window text area |
| Pixel position | (146, 130) -- right-aligned within text area, on the 2nd text line's row |
| Color | Same as normal text (`#e8e8e8`) |
| Animation | 2-frame blink: visible for 20 game frames (333ms), hidden for 10 game frames (167ms), repeat |
| Trigger | Appears only after all text in the current 2-line block has finished displaying |

Pressing A when the `▼` indicator is showing advances to the next 2-line block of text.

### 5.4 Speaker Name Display

When an NPC or named character is speaking, their name appears in a small name plate above the message window.

| Property | Value |
|----------|-------|
| Name plate position | Directly above the message window, left-aligned |
| Tile position | (1, 13) -- 1 tile from left edge, 1 tile above message window |
| Pixel position | (8, 104) |
| Name plate size | Variable width: (name character count + 1) tiles wide x 1 tile tall |
| Name plate variant | `win_default` (uses border and fill colors, but compressed to 1-tile height with simplified top/bottom border: 1px border top, 6px fill, 1px border bottom) |
| Name text color | `#a0d8f8` (light cyan-blue, as specified in Section 3.6) |
| Name text position | Centered within the name plate with 4px left and right padding |

When no speaker name is needed (system messages, narration), the name plate does not appear.

### 5.5 Choice/Selection Display Within Message Window

When the player must choose between options (e.g., Yes/No, multiple dialog choices), the choices appear within the message window or in a small choice window overlaying the message window.

#### Two-Choice Selection (Yes/No)

| Property | Value |
|----------|-------|
| Display method | A small choice window appears to the right of or above the message window |
| Choice window size | 6 x 3 tiles (48 x 24 px) |
| Choice window position | Top-right area: tile (14, 11) to (19, 13), pixel (112, 88) to (159, 111) |
| Choice window variant | Same as the message window's variant |
| Options layout | Vertical list: option 1 on row 1, option 2 on row 2 |
| Cursor | Standard cursor appears to the left of the currently highlighted option |
| Default selection | First option (typically "はい" / "Yes") |

#### Multi-Choice Selection (3-4 options)

| Property | Value |
|----------|-------|
| Display method | A choice window replaces or overlays the message window |
| Choice window size | 10 x (option count + 2) tiles |
| Choice window position | Right side of screen, bottom-aligned with message window |
| Choice window variant | Same as message window's variant |
| Options layout | Vertical list, one option per 8px row |
| Cursor | Standard cursor |

---

## 6. Status Display (Battle)

### 6.1 Layout for 3 Party Members

The party status zone occupies tile rows 7-10 (pixels Y 56-87, 4 tile rows total). The first row (tile row 7) is a 1-tile visual separator or the top border of the status window. The remaining 3 tile rows each display one party member.

| Row | Tile Row | Pixel Y Range | Content |
|-----|---------|---------------|---------|
| Header/border | 7 | 56-63 | Top border of battle status window |
| Monster 1 | 8 | 64-71 | Name, HP, MP, status icons |
| Monster 2 | 9 | 72-79 | Name, HP, MP, status icons |
| Monster 3 | 10 | 80-87 | Bottom border of battle status window (overlaps with content) |

Each monster row has the following horizontal layout:

```
[Icon 8x8][Name 48px][HP label 16px][HP value 32px][MP label 16px][MP value 24px][Status 8px]
```

Breakdown:

| Element | Pixel X Start | Width (px) | Content |
|---------|-------------:|----------:|---------|
| Mini icon | 6 | 8 | Tiny monster family icon (8x8) |
| Name | 16 | 48 | Monster name (up to 6 JP chars, truncated if needed) |
| HP label | 64 | 16 | "HP" text |
| HP value | 80 | 24 | 3-digit number, right-aligned |
| Separator | 104 | 4 | Blank space |
| MP label | 108 | 16 | "MP" text |
| MP value | 124 | 24 | 3-digit number, right-aligned |
| Status icon | 150 | 8 | Status ailment icon (8x8), if any active |

### 6.2 HP Display

HP is displayed as a numeric value only. No HP bar is shown by default (an optional HP bar can be enabled in settings but is NOT part of the standard UI sprite set).

| Property | Value |
|----------|-------|
| Format | Right-aligned 3-digit number. Leading spaces, not leading zeros. Examples: `  1`, ` 45`, `999`. |
| Maximum displayable value | 999 |
| Font | Standard 8x8 bitmap font |
| Label | "HP" in normal text color, always visible |

#### HP Color Thresholds

| Condition | HP Range | Color (hex) | Description |
|-----------|----------|-------------|-------------|
| Safe | HP > 50% of max HP | `#e8e8e8` (near-white) | Normal text color |
| Caution | HP <= 50% and HP > 25% of max HP | `#f8d848` (gold yellow) | Warning color |
| Danger | HP <= 25% of max HP | `#e84040` (bright red) | Danger color |
| Dead | HP = 0 | `#606060` (dark grey) | Disabled color |

The color change is instantaneous when the threshold is crossed. There is no animation or transition between colors.

#### HP Flash on Damage

When a party member takes damage, their HP number flashes:

| Property | Value |
|----------|-------|
| Flash pattern | HP number becomes invisible for 2 game frames, visible for 2 game frames, repeat 3 times |
| Total flash duration | 12 game frames (200ms) |
| Final state | HP number visible at new value with appropriate threshold color |

### 6.3 MP Display

MP follows the same display rules as HP.

| Property | Value |
|----------|-------|
| Format | Right-aligned 3-digit number. Leading spaces, not leading zeros. |
| Maximum displayable value | 999 |
| Label | "MP" in normal text color |

#### MP Color Thresholds

| Condition | MP Range | Color (hex) | Description |
|-----------|----------|-------------|-------------|
| Safe | MP > 25% of max MP | `#80b0f8` (light blue) | MP-specific blue color |
| Low | MP <= 25% of max MP and MP > 0 | `#f8d848` (gold yellow) | Warning |
| Empty | MP = 0 | `#606060` (dark grey) | Disabled |

MP does NOT flash on expenditure. Only HP flashes on damage.

### 6.4 Name Display in Battle

| Property | Value |
|----------|-------|
| Max characters | 6 (Japanese) or 10 (English) |
| Color | Normal text color (`#e8e8e8`) |
| Dead monster | Name color changes to `#606060` (disabled) |
| Truncation | Names are authored to fit. No truncation logic in battle. |

### 6.5 Status Ailment Icons

When a monster is affected by a status ailment, a small icon appears at the right end of their status row.

| Property | Value |
|----------|-------|
| Icon size | 8 x 8 px |
| Position | Rightmost slot in the status row (pixel X 150-157) |
| Maximum simultaneous display | 1 icon visible at a time |
| Multiple ailments | If a monster has multiple ailments, the icons cycle every 40 game frames (667ms) |
| Animation | Icons are static (no per-icon animation) |

The specific ailment icons are detailed in Section 19.2.

### 6.6 Danger Indicators

Beyond HP/MP color changes, additional visual danger cues appear:

| Trigger | Visual Effect |
|---------|--------------|
| Any party member HP <= 25% | The HP number uses danger color (`#e84040`) |
| Any party member HP <= 10% | The entire status row for that member flashes: row alternates between normal display and all-danger-color display every 30 game frames (500ms) |
| All party members HP <= 25% | No additional screen-wide effect beyond individual row effects |
| Party member is dead (HP = 0) | Name and all numbers become disabled color (`#606060`). No flash, no animation. Static grey. |

---

## 7. Battle Command Menu

### 7.1 Layout

The battle command window occupies the right side of the command/message zone.

| Property | Value |
|----------|-------|
| Window size | 10 x 6 tiles (80 x 48 px) |
| Window position | Tile (10, 11) to (19, 16), Pixel (80, 88) to (159, 135) |
| Window variant | `win_battle` |
| Number of commands | 4 |

Command layout within the window (after border and padding):

| Command | Row | Text |
|---------|-----|------|
| 1 | Row 0 (top) | たたかう |
| 2 | Row 1 | さくせん |
| 3 | Row 2 | どうぐ |
| 4 | Row 3 | にげる |

Each command occupies one 8px text row. The cursor appears to the left of the currently selected command.

### 7.2 Strategy Submenu (さくせん)

When the player selects `さくせん`, a submenu appears.

| Property | Value |
|----------|-------|
| Window size | 10 x 8 tiles (80 x 64 px) |
| Window position | Tile (0, 9) to (9, 16), Pixel (0, 72) to (79, 135) -- left side, overlapping the battle message area |
| Window variant | `win_battle` |

Contents:

| Row | Text | Description |
|-----|------|-------------|
| 0 | [Monster 1 name] | Monster name header |
| 1 | 全力で攻めろ | Attack-focused AI |
| 2 | まかせた | Balanced AI |
| 3 | 命を守れ | Heal-focused AI |
| 4 | 力だけで戦え | Physical-only AI |
| 5 | 援護を頼む | Support-focused AI |
| 6 | 直接指示 | Manual control |

The player cycles through monsters with left/right input. The monster name at the top changes. The cursor selects a strategy for the currently displayed monster.

The currently active strategy for each monster is indicated with a `★` symbol to the right of the strategy name.

### 7.3 Item Submenu (どうぐ)

When the player selects `どうぐ`, an item list window appears.

| Property | Value |
|----------|-------|
| Window size | 12 x 8 tiles (96 x 64 px) |
| Window position | Tile (0, 9) to (11, 16), Pixel (0, 72) to (95, 135) |
| Window variant | `win_battle` |
| List format | Scrollable vertical list |
| Visible items | 5 rows (5 items visible at once) |
| Item row format | `[Cursor 8px][Icon 8px][Name 48px][Qty 24px]` |
| Scroll indicator | `▲` at top of list if items above, `▼` at bottom if items below |

Items that cannot be used in battle are displayed in disabled text color (`#606060`) and cannot be selected.

### 7.4 Direct Command Submenu (直接指示)

When `直接指示` is active for a monster, selecting `たたかう` opens per-monster command selection.

For each monster with `直接指示` active, a command window appears sequentially:

| Property | Value |
|----------|-------|
| Window size | 10 x 6 tiles (80 x 48 px) |
| Window position | Tile (0, 11) to (9, 16), Pixel (0, 88) to (79, 135) |
| Window variant | `win_battle` |
| Header | Monster name on the first row |
| Commands | こうげき (Attack), list of known skills, ぼうぎょ (Defend) |
| Scrollable | Yes, if the monster knows more than 3 skills |
| Visible rows | 4 (header + 3 command rows visible at once) |

When a skill is selected, a target selection window appears if the skill requires target choice:

| Property | Value |
|----------|-------|
| Window size | 10 x 4 tiles (80 x 32 px) |
| Window position | Tile (10, 13) to (19, 16), Pixel (80, 104) to (159, 135) |
| Contents | List of valid targets (enemy names or ally names) |

### 7.5 Selection Highlight Style

The currently selected command/item is indicated by:
1. The cursor (Section 4) positioned to the left of the item
2. The text color of the selected item changes to highlighted text color (`#f8f860`)

Non-selected items remain in normal text color (`#e8e8e8`).

### 7.6 Disabled Command Display

Commands that cannot currently be used (e.g., `にげる` in a boss fight, `どうぐ` when the item bag is empty) are displayed in disabled text color (`#606060`). The cursor skips over disabled commands -- they cannot be highlighted or selected.

---

## 8. Battle Damage Numbers

### 8.1 Font

| Property | Value |
|----------|-------|
| Font | Bold variant of the standard 8x8 bitmap font |
| Glyph style | Thicker strokes than normal text font, occupying more of the 8x8 cell |
| Characters needed | 0-9, "MISS", "HEAL" (no other text appears as floating damage) |
| Outline | Each damage number glyph has a 1px outline in `#000000` around every visible pixel, making the number readable against any background |

### 8.2 Position

Damage numbers appear floating above the target that received the damage.

| Property | Value |
|----------|-------|
| Starting position | Horizontally centered above the target sprite, vertically 4 pixels above the sprite's top edge |
| For enemy targets | Above the enemy sprite in the enemy display zone |
| For ally targets | Above the corresponding status row in the party status zone |

### 8.3 Colors

| Damage Type | Number Color (hex) | Outline Color (hex) |
|-------------|-------------------|---------------------|
| Normal damage | `#ffffff` (white) | `#000000` (black) |
| Critical hit damage | `#f8f860` (bright yellow) | `#000000` (black) |
| Healing | `#60e860` (bright green) | `#000000` (black) |
| Miss | `#a0a0a0` (light grey) | `#000000` (black) |

For critical hits, the text "かいしん!" (Critical!) appears on the line above the damage number in the same yellow color, using the standard (not bold) font.

### 8.4 Animation

| Phase | Duration | Visual |
|-------|----------|--------|
| Rise | 8 game frames (133ms) | Number rises 8 pixels (1 pixel per frame) from starting position |
| Hold | 12 game frames (200ms) | Number stays at peak position |
| Fade | 6 game frames (100ms) | Number remains in place but the opacity is simulated by replacing the number color with progressively darker colors: full color (2f), 66% brightness (2f), 33% brightness (2f), then disappear |

Total duration on screen: **26 game frames (433ms)**.

Multiple damage numbers on the same target stack vertically. If a second damage number appears before the first has finished, the second starts 8 pixels above the first's current position.

### 8.5 Miss Display

When an attack misses, the word "ミス" (Miss) appears instead of a number. It uses the same animation as damage numbers. The text color is `#a0a0a0` (light grey).

---

## 9. Monster List / Party Screen

### 9.1 Layout

The party screen is accessed from the main menu via `なかま`.

| Property | Value |
|----------|-------|
| Window size | 20 x 14 tiles (160 x 112 px) |
| Window position | Tile (0, 2) to (19, 15), Pixel (0, 16) to (159, 127) |
| Window variant | `win_default` |
| Title bar text | "なかま" at tile row 0-1 |
| Description strip | Tile rows 16-17 (bottom 2 rows) |

### 9.2 Party Member Rows

Each party member occupies 2 tile rows (16 px height) to accommodate the 16x16 monster icon.

| Element | Position (within content area) | Size | Description |
|---------|-------------------------------|------|-------------|
| Monster icon | Left, vertically centered | 16 x 16 px | Front-facing idle frame of the monster's field sprite |
| Monster name | Right of icon, top row | 48 px wide | Monster name in normal text color |
| Level | Right of name, top row | 32 px | "Lv" + 2-digit number |
| HP | Below name, bottom row | 64 px | "HP" + 3-digit current + "/" + 3-digit max |
| MP | Right of HP, bottom row | 64 px | "MP" + 3-digit current + "/" + 3-digit max |

For a party of 3 monsters, this uses 6 tile rows (48 px) of the content area, leaving ample space for the cursor and window borders.

### 9.3 Selection Behavior

| Input | Action |
|-------|--------|
| Up/Down | Move cursor between party members |
| A button | Select the highlighted monster (opens monster detail or enters swap mode) |
| B button | Return to main menu |

### 9.4 Swap/Reorder Interface

When a monster is selected with A and `ならびかえ` (Reorder) is chosen from the submenu:

1. The selected monster's row is highlighted with a colored background: the row's fill changes from the window fill color to a selection color (`#2a2a5e`, a slightly lighter version of the default window fill).
2. The player moves the cursor up/down to choose a swap target.
3. Pressing A on the target swaps the two monsters. The swap is instantaneous -- the icons, names, and stats of the two rows exchange in a single frame.
4. Pressing B cancels the swap and deselects the original monster.

### 9.5 Detail View Submenu

When a monster is selected with A, a small submenu appears:

| Property | Value |
|----------|-------|
| Submenu size | 8 x 5 tiles (64 x 40 px) |
| Submenu position | Right of the selected monster's row |
| Options | ステータス (Status detail), さくせん (Strategy), スキル (Skills), ならびかえ (Reorder) |

---

## 10. Item List

### 10.1 Layout

| Property | Value |
|----------|-------|
| Window size | 20 x 14 tiles (160 x 112 px) |
| Window position | Tile (0, 2) to (19, 15), Pixel (0, 16) to (159, 127) |
| Window variant | `win_default` |
| Title bar text | "もちもの" at tile row 0-1 |
| Description strip | Tile rows 16-17 |

### 10.2 Item Row Format

Each item occupies 1 tile row (8 px height).

```
[Cursor 8px][Icon 8px][Gap 2px][Item Name 64px][Gap 4px][Quantity 24px]
```

| Element | Width | Description |
|---------|------:|-------------|
| Cursor space | 8 px | Cursor appears here when item is selected |
| Item icon | 8 px | 8x8 version of the item's category icon (see Section 19.1). Not the full 16x16 icon -- a simplified 8x8 version for list display. |
| Gap | 2 px | Spacing |
| Item name | 64 px | Up to 8 Japanese characters |
| Gap | 4 px | Spacing |
| Quantity | 24 px | "x" + 2-digit number, right-aligned. Key items show no quantity. |

### 10.3 Visible Items and Scrolling

| Property | Value |
|----------|-------|
| Visible items | 10 per page (10 rows x 8px = 80px, fits within content area) |
| Scroll indicators | `▲` at top if items above, `▼` at bottom if items below |
| Scroll behavior | List scrolls 1 item at a time. Cursor stays in the visible range. |

### 10.4 Item Categories and Tabs

Items are divided into two categories, selectable via tab at the top of the list:

| Tab | Text | Contents |
|-----|------|----------|
| 1 | どうぐ | Consumable and field items (healing, MP, status cure, bait, catalyst, buff) |
| 2 | だいじなもの | Key items (non-consumable, quest-related) |

Tabs are displayed as text labels at the top of the content area. The active tab's text is highlighted color (`#f8f860`). The inactive tab's text is normal color (`#e8e8e8`). The player switches tabs with left/right input when the cursor is on the tab row.

### 10.5 Use/Toss/Details Submenu

When an item is selected with A:

| Property | Value |
|----------|-------|
| Submenu size | 6 x 4 tiles (48 x 32 px) |
| Submenu position | Right of the selected item row |
| Options | つかう (Use), すてる (Toss), くわしく (Details) |

- `つかう`: Opens target selection (which monster to use it on). If the item is a field-use item, it is used immediately.
- `すてる`: Opens quantity selection (how many to toss) followed by a confirmation dialog.
- `くわしく`: The description strip at the bottom updates to show the item's full description text. If the text exceeds 2 lines, it scrolls with `▼` indicator.

Key items show only `くわしく` (Details) in their submenu. They cannot be used directly or tossed.

### 10.6 Description Strip

| Property | Value |
|----------|-------|
| Position | Bottom 2 tile rows of the screen, tile rows 16-17 |
| Size | 20 x 2 tiles (160 x 16 px) |
| Variant | Same as the main window variant |
| Content | 2 lines of description text for the currently highlighted item |
| Behavior | Updates whenever the cursor moves to a different item |

---

## 11. Codex/Encyclopedia Screen

### 11.1 Layout Overview

The codex screen uses a two-panel layout: list on the left, detail on the right.

| Property | Value |
|----------|-------|
| Left panel (list) size | 10 x 14 tiles (80 x 112 px) |
| Left panel position | Tile (0, 2) to (9, 15) |
| Right panel (detail) size | 10 x 14 tiles (80 x 112 px) |
| Right panel position | Tile (10, 2) to (19, 15) |
| Window variant | `win_codex` |
| Title bar | "ずかん" at tile rows 0-1 |
| Description strip | Tile rows 16-17 |

### 11.2 Monster List (Left Panel)

Each entry in the codex list occupies 1 tile row (8 px):

```
[Cursor 8px][Number 24px][Name or ??? 48px]
```

| Element | Width | Description |
|---------|------:|-------------|
| Cursor space | 8 px | Cursor appears when entry is selected |
| Number | 24 px | 3-digit zero-padded monster ID ("001", "042", "400") |
| Name/placeholder | 48 px | Monster name if discovered, "？？？" if undiscovered |

Undiscovered monsters show `？？？` in disabled text color (`#606060`). Discovered monsters show their name in normal text color (`#e8e8e8`).

Visible entries: 10 per page, scrollable.

### 11.3 Monster Silhouette (Discovered vs. Undiscovered)

In the right panel, when a monster is highlighted:

| State | Display |
|-------|---------|
| Undiscovered | A solid black silhouette (all opaque pixels of the battle sprite filled with `#000000`, no internal detail) displayed centered in the right panel. The silhouette is the battle sprite rendered as a flat shape. Below the silhouette: "？？？" for name, no stats. |
| Discovered (seen in battle but not owned) | The silhouette with partial detail: the outline and major body divisions are visible, but interior colors are muted to 50% of their normal brightness (approximated by using the nearest darker master palette color). Name is visible. Basic info (family, element) is shown. Stats are hidden. |
| Discovered (owned or previously owned) | Full-color battle sprite displayed at native size, centered in the right panel. All information visible. |

### 11.4 Sort/Filter Controls

A sort/filter bar appears at the top of the left panel content area:

| Property | Value |
|----------|-------|
| Position | First row of the left panel content area |
| Controls | Left/Right to cycle sort modes, A to toggle filter |
| Sort modes | No. (ID order), なまえ (alphabetical), ランク (by rank E-S), しゅぞく (by family) |
| Filter | Press A on the sort bar to open a filter submenu: filter by family (9 options), filter by element (8 options), filter by rank (6 options), or "すべて" (show all) |

### 11.5 Detail View Layout (Right Panel)

When a fully discovered monster is selected, the right panel shows:

| Row | Content |
|-----|---------|
| Row 0-1 | Monster name (centered, normal text color) |
| Row 2-7 | Battle sprite (centered in the 80px-wide panel, at native size up to 56x56) |
| Row 8 | Family icon (8x8) + Family name | Element icon (8x8) + Element name |
| Row 9 | Rank badge (8x8) + Rank letter |
| Row 10 | HP / MP base stats |
| Row 11 | ATK / DEF |
| Row 12 | SPD / INT / SPR |

### 11.6 Lore Text Display

When the player presses A on a fully discovered monster in the codex, the description strip at the bottom expands or cycles to show the monster's lore text (from the `TXT-MON-{id}` text entry). Lore text is displayed 2 lines at a time with the `▼` page advance indicator if more text exists.

### 11.7 Stats Display Format

Stats in the codex are displayed as label-value pairs:

```
HP  999  MP  999
ATK 255  DEF 255
SPD 255  INT 255
SPR 255
```

All values are right-aligned 3-digit numbers. Labels are in normal text color. Values are in normal text color.

---

## 12. Breeding Screen

### 12.1 Parent Selection Display

The breeding screen begins with parent selection.

| Phase | Layout |
|-------|--------|
| Select Parent 1 | Full-screen monster list (same layout as Party Screen, Section 9) with the title "おや1をえらぶ" (Choose Parent 1) |
| Select Parent 2 | Same list appears again with title "おや2をえらぶ" (Choose Parent 2). Parent 1 is greyed out in the list and not selectable. |

Monsters with the "favorite lock" (お気に入りロック) active display a `♥` icon next to their name. Selecting a locked monster triggers a warning dialog:

| Property | Value |
|----------|-------|
| Warning dialog | "このなかまは おきにいり です。 はいごうに つかいますか？" |
| Dialog variant | `win_system` |
| Options | はい (Yes) / いいえ (No) |
| Default selection | いいえ (No) |

### 12.2 Preview Window

After both parents are selected, the preview screen appears.

| Region | Tile Range | Content |
|--------|-----------|---------|
| Parent 1 zone (left) | (0, 2) to (9, 8) | Parent 1 icon (16x16), name, level, key stats |
| Parent 2 zone (right) | (10, 2) to (19, 8) | Parent 2 icon (16x16), name, level, key stats |
| "+" symbol | Between the two parent zones, vertically centered | "＋" character in highlighted text color |
| "=" symbol | Between parent zone and result zone | "＝" character in highlighted text color |
| Result zone (center-bottom) | (3, 9) to (16, 13) | Result monster icon (16x16), name (or "？？？" if unknown recipe), family, element, rank, predicted stat range |

If the recipe is known (previously discovered):
- Result monster name is shown in normal text color
- Result monster icon is shown in full color
- Predicted stat ranges are shown

If the recipe is unknown:
- Result shows "？？？" for name
- Result icon is a question mark silhouette
- Family and rank hint text appears: e.g., "ビーストぞく の Cランク かも？" (Might be a Beast family, C rank?)

### 12.3 Inheritance Slot Display

After confirming the breeding pair on the preview screen, the skill inheritance selection screen appears.

| Property | Value |
|----------|-------|
| Window size | 20 x 8 tiles (160 x 64 px) |
| Window position | Tile (0, 9) to (19, 16) |
| Window variant | `win_breeding` |
| Layout | Left column: Parent 1's skill trees. Right column: Parent 2's skill trees. |
| Selectable items | Each skill tree is one row. The player selects up to 3 skill trees total. |
| Selection indicator | A filled `★` appears next to selected skill trees. Unselected show an empty `☆`. |
| Maximum selections | 3 skill trees |
| Cursor behavior | Cursor moves vertically within each column. Left/Right switches between columns. |

Each skill tree row:

```
[★/☆ 8px][Skill tree name 72px]
```

When the cursor is on a skill tree, the description strip at the bottom shows the list of skills within that tree.

### 12.4 Confirmation Screen

After skill selection, a final confirmation dialog appears.

| Property | Value |
|----------|-------|
| Window size | 12 x 4 tiles (96 x 32 px) |
| Window position | Centered on screen: tile (4, 7) to (15, 10) |
| Window variant | `win_breeding` |
| Text | "[Parent1 name] と [Parent2 name] を はいごう します。 よろしいですか？" |
| Options | はい (Yes) / いいえ (No) |
| Default | いいえ (No) |

### 12.5 Birth Animation Placeholder

When breeding is confirmed, a birth sequence plays:

| Phase | Duration | Visual |
|-------|----------|--------|
| Parents fade | 30 game frames (500ms) | Parent icons fade by replacing colors with progressively lighter colors over 3 steps, then disappear |
| Egg appears | 20 game frames (333ms) | A 16x16 egg sprite fades in at center screen using 3 brightness steps |
| Egg shakes | 40 game frames (667ms) | Egg sprite oscillates left 1px, center, right 1px, center -- 4 cycles |
| Egg cracks | 10 game frames (167ms) | Egg sprite is replaced by a cracked egg sprite (same size, crack lines added) |
| Hatch flash | 6 game frames (100ms) | Screen fills with white for 6 frames |
| Result appears | 20 game frames (333ms) | Result monster icon (16x16) fades in at center. Name and stats appear below. |

The egg sprite is a dedicated 16x16 asset:
- Oval shape, off-white fill (`#e8e8d8`), 1px outline (`#000000`), slight shadow on bottom-right
- Cracked variant adds 2-3 crack lines in outline color across the surface

Total birth sequence: approximately 126 game frames (2.1 seconds).

---

## 13. Shop Screen

### 13.1 Layout

| Property | Value |
|----------|-------|
| Title bar | "おみせ" at tile rows 0-1 |
| Main window size | 20 x 12 tiles (160 x 96 px) |
| Main window position | Tile (0, 2) to (19, 13) |
| Window variant | `win_shop` |
| Gold display | 8 x 2 tiles (64 x 16 px), positioned at tile (12, 14) to (19, 15) |
| Description strip | Tile rows 16-17 |

### 13.2 Buy/Sell Tabs

The top row of the shop window content area contains two tabs:

| Tab | Text | Description |
|-----|------|-------------|
| 1 | かう (Buy) | List of items available for purchase |
| 2 | うる (Sell) | List of items the player can sell |

Tab switching uses left/right input. Active tab text is highlighted color, inactive is normal color.

### 13.3 Item List with Prices

Each item row in the shop:

```
[Cursor 8px][Icon 8px][Gap 2px][Item Name 56px][Gap 4px][Price 40px]
```

| Element | Width | Description |
|---------|------:|-------------|
| Cursor | 8 px | Selection cursor |
| Icon | 8 px | Item category icon (8x8) |
| Gap | 2 px | Spacing |
| Name | 56 px | Item name (up to 7 JP characters) |
| Gap | 4 px | Spacing |
| Price | 40 px | Price number + "G" suffix, right-aligned. Example: "150G" |

Buy list: Price is shown in gold text color (`#f8d848`). If the player cannot afford an item, the price text and item name are shown in disabled color (`#606060`).

Sell list: Shows the player's items with their sell price (typically 50% of buy price). Format is the same.

### 13.4 Gold Display

| Property | Value |
|----------|-------|
| Window variant | `win_shop` |
| Size | 8 x 2 tiles (64 x 16 px) |
| Content | "Gold" label + current gold amount |
| Format | Right-aligned number, up to 6 digits, followed by "G" |
| Text color | `#f8d848` (gold yellow) |
| Position | Bottom-right of screen, above description strip |

### 13.5 Transaction Confirmation

When the player selects an item to buy or sell:

**Buy confirmation:**

| Property | Value |
|----------|-------|
| Quantity selection | A small window appears: "いくつ かいますか？" with a number selector (1 to max affordable/max stack). Up/Down to change quantity. |
| Quantity window size | 8 x 3 tiles (64 x 24 px) |
| Total price display | "ごうけい: [total]G" updates in real time as quantity changes |
| Confirm | A button confirms purchase |
| Cancel | B button cancels |

**Sell confirmation:**

Same as buy, but with the prompt "いくつ うりますか？" and sell price.

After transaction:
- A brief message in the description strip: "[Item name] を かいました！" (Bought!) or "[Item name] を うりました！" (Sold!)
- Gold display updates immediately
- The item list updates (quantity changes, or item removed if sold all)

---

## 14. Save/Load Screen

### 14.1 Layout

| Property | Value |
|----------|-------|
| Window size | 20 x 16 tiles (160 x 128 px) |
| Window position | Tile (0, 1) to (19, 16) |
| Window variant | `win_system` |
| Title | "きろく" (Save) or "つづきから" (Load), at tile row 0 |

### 14.2 Slot Display

There are **4 save slots**: 3 manual slots and 1 auto-save slot.

Each slot occupies 3 tile rows (24 px):

| Row | Content |
|-----|---------|
| Row 0 | Slot label: "スロット1" / "スロット2" / "スロット3" / "オートセーブ" |
| Row 1 | Chapter/location: "だい3しょう - [World name]" |
| Row 2 | Party preview: 3 monster icons (16x16 each, squeezed to 8x8 mini icons for this display) + play time "12:34:56" |

Empty slots show:

| Row | Content |
|-----|---------|
| Row 0 | Slot label |
| Row 1 | "---からっぽ---" (Empty) in disabled text color |
| Row 2 | (blank) |

The auto-save slot (slot 4) has a small `AUTO` label in system message color (`#c0c0c0`) next to the slot name.

### 14.3 Slot Timestamp

| Property | Value |
|----------|-------|
| Format | Play time in hours:minutes:seconds ("HH:MM:SS") |
| Position | Right-aligned on row 2 of each slot |
| Color | Normal text color |

Real-world date/time is NOT displayed. Only in-game play time.

### 14.4 Confirmation Dialogs

**Save confirmation:**

| Property | Value |
|----------|-------|
| Dialog | "スロット[N] に きろく します。 よろしいですか？" |
| Overwrite warning | If slot is not empty: "データが うわがき されます。 よろしいですか？" |
| Options | はい / いいえ |
| Default | はい (Yes) for save |
| After save | "きろく しました！" message for 60 game frames (1 second), then return to previous screen |

**Load confirmation:**

| Property | Value |
|----------|-------|
| Dialog | "スロット[N] の データを よみこみ ます。 よろしいですか？" |
| Options | はい / いいえ |
| Default | はい (Yes) |
| After load | Fade to black, load game state, fade in to the loaded game's field screen |

The auto-save slot is **read-only**. The player cannot manually save to the auto-save slot. It can only be loaded.

---

## 15. Settings Screen

### 15.1 Layout

| Property | Value |
|----------|-------|
| Window size | 20 x 16 tiles (160 x 128 px) |
| Window position | Tile (0, 1) to (19, 16) |
| Window variant | `win_system` |
| Title | "せってい" at tile row 0 |

### 15.2 Volume Controls

| Setting | Type | Range | Default | Display |
|---------|------|-------|---------|---------|
| BGM Volume | Discrete steps | 0, 1, 2, 3, 4, 5 (6 levels) | 4 | "BGMおんりょう" label + numeric display "■■■■□□" (filled/empty blocks) |
| SE Volume | Discrete steps | 0, 1, 2, 3, 4, 5 (6 levels) | 4 | "SEおんりょう" label + same block display |

Volume is displayed using filled block characters `■` and empty block characters `□` in a horizontal row. Left/Right input adjusts the value. Each `■` or `□` is one 8x8 character cell.

The `■` character uses normal text color. The `□` character uses disabled text color.

### 15.3 Text Speed

| Setting | Options | Default | Display |
|---------|---------|---------|---------|
| Text speed | おそい / ふつう / はやい / しゅんかん | ふつう | "テキストそくど" label + current option text |

Left/Right cycles through options. The current option is displayed in highlighted text color.

### 15.4 Game Speed

| Setting | Options | Default | Display |
|---------|---------|---------|---------|
| Game speed | 1x / 2x / 4x | 1x | "ゲームそくど" label + "×1" / "×2" / "×4" |

This affects field movement speed and battle animation speed. UI interaction speed is NOT affected.

### 15.5 Virtual Pad Configuration

| Setting | Options | Default | Display |
|---------|---------|---------|---------|
| Pad position | ひだり (Left) / みぎ (Right) | ひだり | Swaps D-pad and A/B button positions |
| Button size | ちいさい (Small) / ふつう (Normal) / おおきい (Large) | ふつう | Adjusts virtual pad button size |
| Pad opacity | うすい (Light) / ふつう (Normal) / こい (Dark) | ふつう | Adjusts virtual pad transparency |

### 15.6 Language Toggle

| Setting | Options | Default | Display |
|---------|---------|---------|---------|
| Language | にほんご / English | にほんご | "げんご" label + current language name |

Changing language triggers a confirmation dialog and restarts the UI with the new language's text data. Game state is preserved.

### 15.7 Settings Row Layout

Each setting occupies 1 tile row (8 px):

```
[Cursor 8px][Label 72px][Value 72px]
```

The cursor moves vertically between settings. Left/Right adjusts the value of the currently selected setting.

---

## 16. Virtual Pad Design

### 16.1 D-Pad

| Property | Value |
|----------|-------|
| Shape | Plus/cross shape (standard D-pad) |
| Total bounding size (Normal) | 48 x 48 px (in device pixels, NOT internal resolution -- the virtual pad is rendered in the device coordinate space overlaying the scaled game viewport) |
| Arm width | 16 device px |
| Position (default) | Bottom-left of device screen, with 16 device px margin from screen edges |
| Color | `#ffffff` at 30% opacity (Normal opacity setting) |
| Border | 1 device px outline in `#000000` at 30% opacity |

### 16.2 A/B Buttons

| Property | A Button | B Button |
|----------|----------|----------|
| Shape | Circle | Circle |
| Diameter (Normal) | 32 device px | 28 device px |
| Label | "A" centered | "B" centered |
| Label font | Device system font, not bitmap font | Device system font |
| Position (default) | Bottom-right, 16 device px from right edge, 24 device px from bottom | To the left and slightly above A button, 8 device px gap |
| Color | `#ffffff` at 30% opacity | `#ffffff` at 30% opacity |
| Border | 1 device px outline `#000000` at 30% opacity | Same |
| Active state (pressed) | Opacity doubles momentarily (60%) | Same |

### 16.3 Menu/Start Buttons

| Property | Menu Button | Start Button |
|----------|-------------|--------------|
| Shape | Rounded rectangle | Rounded rectangle |
| Size (Normal) | 32 x 16 device px | 32 x 16 device px |
| Label | "MENU" | "START" |
| Position | Top-right of device screen, 8 device px from edges | To the left of MENU button, 8 device px gap |
| Color | `#ffffff` at 20% opacity | `#ffffff` at 20% opacity |
| Border | 1 device px outline `#000000` at 20% opacity | Same |

### 16.4 Transparency Levels

| Setting | D-Pad/A/B Opacity | Menu/Start Opacity |
|---------|-------------------:|-------------------:|
| うすい (Light) | 15% | 10% |
| ふつう (Normal) | 30% | 20% |
| こい (Dark) | 50% | 35% |

### 16.5 Size Variations

| Setting | D-Pad Size | A Button Diameter | B Button Diameter | Menu/Start Size |
|---------|:----------:|:-----------------:|:-----------------:|:---------------:|
| ちいさい (Small) | 36 x 36 | 24 | 20 | 24 x 12 |
| ふつう (Normal) | 48 x 48 | 32 | 28 | 32 x 16 |
| おおきい (Large) | 64 x 64 | 44 | 38 | 40 x 20 |

### 16.6 Touch Area vs. Visual Area

The touch-sensitive area for each button is **150%** of the visual area in all directions. This ensures that slightly imprecise touches still register.

| Button | Visual Radius/Size | Touch Radius/Size |
|--------|-------------------|-------------------|
| D-Pad (Normal) | 48 x 48 | 72 x 72 |
| A button (Normal) | 32 diameter | 48 diameter |
| B button (Normal) | 28 diameter | 42 diameter |
| Menu button (Normal) | 32 x 16 | 48 x 24 |
| Start button (Normal) | 32 x 16 | 48 x 24 |

When touch areas of adjacent buttons overlap, the closest button center wins.

### 16.7 Position Customization

In the pad configuration submenu of Settings, the player can swap the left/right positioning:

| Setting | Left Side | Right Side |
|---------|-----------|------------|
| ひだり (Left, default) | D-Pad | A/B buttons |
| みぎ (Right) | A/B buttons | D-Pad |

Vertical position of buttons is NOT adjustable. Only left/right swap is available.

---

## 17. Map / World Select Screen (Tower Hub)

### 17.1 Layout

The tower hub screen is accessed from the central hub location in the game. It shows the available gates (portals to different worlds).

| Property | Value |
|----------|-------|
| Window size | 20 x 16 tiles (160 x 128 px) |
| Window position | Tile (0, 1) to (19, 16) |
| Window variant | `win_default` |
| Title | "とう" (Tower) at tile row 0 |

### 17.2 Gate Display

Gates are displayed as a vertical list, one gate per 2 tile rows (16 px), accommodating a gate icon.

Each gate row:

```
[Cursor 8px][Gate icon 16x16][Gap 2px][World name 64px][Status icon 8x8]
```

| Element | Size | Description |
|---------|------|-------------|
| Cursor | 8 px | Selection cursor |
| Gate icon | 16 x 16 px | A small pixel art icon representing the gate. Each gate has a unique icon (different shape, different color accent matching the world's palette). |
| Gap | 2 px | Spacing |
| World name | 64 px | World name in normal text color |
| Status icon | 8 x 8 px | Lock status indicator |

### 17.3 Gate States

| State | Visual |
|-------|--------|
| Locked | Gate icon is a solid dark silhouette (all pixels `#1a1a2e`). World name shows "？？？" in disabled text color. Status icon: a padlock icon (8x8). The gate row cannot be selected. |
| Unlocked (inactive) | Gate icon is rendered in full color. World name is shown in normal text color. Status icon: none (empty). Selectable. |
| Active (currently in this world) | Gate icon is rendered in full color with a pulsing brightness animation (alternate between normal and +1 brightness step every 30 game frames). World name in highlighted text color. Status icon: `★` in highlighted color. |

### 17.4 World Info Tooltip

When the cursor is on an unlocked gate, the description strip at the bottom shows:

| Row | Content |
|-----|---------|
| Line 1 | World name + recommended level range: "[World name] すいしょうLv [min]-[max]" |
| Line 2 | Brief world description (one line) |

---

## 18. Transition Effects

### 18.1 Screen Transitions

All screen transitions use simple fade effects. No wipe effects, no slide effects, no dissolve effects, no mosaic effects. Retro simplicity.

#### Fade to Black

| Property | Value |
|----------|-------|
| Method | The screen progressively darkens in 4 discrete steps |
| Step 1 | All colors shift to their nearest darker master palette equivalent (2 game frames) |
| Step 2 | All colors shift one step darker again (2 game frames) |
| Step 3 | All colors shift to near-black (2 game frames) |
| Step 4 | Screen fills with pure black `#000000` (2 game frames) |
| Total duration | 8 game frames (133ms at 60fps) |

#### Fade from Black

The reverse of fade to black. Starting from pure black, colors restore in 4 steps (2 game frames each). Total duration: 8 game frames (133ms).

### 18.2 Transition Usage

| Transition | Method |
|------------|--------|
| Entering a building/cave | Fade to black, load new map, fade from black |
| Exiting a building/cave | Fade to black, load new map, fade from black |
| Entering a gate (world transfer) | Fade to black (slow: 16 game frames total, 4 frames per step), load new world, fade from black (slow) |
| Opening a full-screen menu | Instant (no fade). Menu window draws on top of the game screen. |
| Closing a full-screen menu | Instant (no fade). Menu window is removed, revealing the game screen beneath. |
| Battle encounter (field to battle) | See Section 18.3 |
| Battle end (battle to field) | Fade to black, restore field screen, fade from black |
| Game over | Fade to black (slow: 16 game frames). Then display "ぜんめつ..." text on black screen. |
| Title screen to game | Fade to black, load game, fade from black |

### 18.3 Battle Encounter Transition

The battle encounter transition is slightly more elaborate than a simple fade, to create the classic JRPG "encounter shock."

| Phase | Duration | Visual |
|-------|----------|--------|
| Flash | 4 game frames | Screen inverts colors (each pixel swaps to its complementary color in the master palette) for 2 frames, then restores for 2 frames |
| Flash repeat | 4 game frames | Same inversion flash, repeated once |
| Fade to black | 8 game frames | Standard 4-step fade to black |
| Load battle | (loading time) | Black screen while battle data loads |
| Fade from black | 8 game frames | Standard 4-step fade from black, revealing the battle screen |

Total transition: approximately 24 game frames (400ms) plus loading time.

### 18.4 Scene Change Within Same Map

When the player triggers a cutscene or event on the same map (no map loading required), NO transition effect is used. The event simply begins. Characters move, dialog appears, etc.

---

## 19. Icon Library

### 19.1 Item Icons

Item icons appear in the inventory list, shop, and battle item selection. Two sizes exist:

| Size | Usage |
|------|-------|
| 16 x 16 px | Full-size display in item detail views, codex, and wherever space permits |
| 8 x 8 px | Compact display in scrollable lists (inventory list rows, shop rows, battle item rows) |

The 8x8 icon is a simplified version of the 16x16 icon, maintaining the same overall shape and color but with reduced detail.

#### Item Icon Categories

Each item belongs to one category. Each category has a base icon shape and color.

| Category ID | Category Name (JP) | Category Name (EN) | 16x16 Base Shape | 8x8 Base Shape | Dominant Color |
|-------------|--------------------|--------------------|-------------------|-----------------|----------------|
| `item_heal` | かいふく | Healing | Potion bottle: round body, narrow neck, cork top | Small bottle shape | Green (`#60e860`) |
| `item_mp` | まりょく | MP Recovery | Flask: angular body, flat stopper | Small flask shape | Blue (`#80b0f8`) |
| `item_status` | じょうたい | Status Cure | Herb leaf: single broad leaf with stem | Small leaf shape | Yellow-green (`#a8d848`) |
| `item_bait` | エサ | Bait | Meat chunk: irregular shape with bone | Small meat shape | Red-brown (`#c06848`) |
| `item_catalyst` | そざい | Catalyst | Crystal: hexagonal prism | Small diamond shape | Purple (`#a070d8`) |
| `item_record` | きろく | Record | Scroll: rolled parchment | Small scroll shape | Tan (`#d8c090`) |
| `item_key` | キー | Key Item | Key: ornate head, shaft, teeth | Small key shape | Gold (`#f8d848`) |
| `item_buff` | きょうか | Buff | Seed: round with sprout | Small circle with line | Orange (`#f8a848`) |
| `item_field` | フィールド | Field Use | Rope/tool: coiled or simple tool shape | Small tool shape | Grey (`#a0a0a0`) |

Each individual item within a category may have minor variations from the base shape (different color accents, added markings), but the overall silhouette and dominant color remain recognizable as belonging to that category.

All item icons follow the same pixel art rules as monster sprites: 1px outlines in `#000000`, two-tone cel shading with top-left light source, no anti-aliasing, no dithering, no gradients.

### 19.2 Status Ailment Icons

Status ailment icons appear in battle status rows and in the monster detail/party screens.

| Size | 8 x 8 px |
|------|-----------|

| Ailment ID | Ailment Name (JP) | Ailment Name (EN) | Icon Design | Dominant Color |
|------------|-------------------|--------------------|-------------|----------------|
| `ail_poison` | どく | Poison | Skull: front-facing skull with two eye dots and a jaw line | Purple (`#a050c0`) |
| `ail_sleep` | ねむり | Sleep | "Zzz": Three "Z" characters stacked diagonally (large to small, top-left to bottom-right) | Blue (`#6080d0`) |
| `ail_paralysis` | まひ | Paralysis | Lightning bolt: small zigzag bolt shape | Yellow (`#f8e040`) |
| `ail_confusion` | こんらん | Confusion | Spiral: small spiral/swirl (3 turns of a clockwise spiral) | Pink (`#e070a0`) |
| `ail_seal` | ふういん | Seal | Cross/X: A bold X mark filling the 8x8 cell | Red (`#d04040`) |
| `ail_fear` | きょうふ | Fear | Exclamation: bold "!" mark | Dark blue (`#3040a0`) |
| `ail_curse` | のろい | Curse | Eye: single stylized eye (lid, iris dot, lower lid) | Dark purple (`#4020604`) |

All ailment icons have a 1px `#000000` outline around their visible pixels to ensure readability against any window fill color.

### 19.3 Element Icons

Element icons appear in the codex, monster detail screens, and skill descriptions.

| Size | 8 x 8 px |
|------|-----------|

| Element ID | Element Name (JP) | Element Name (EN) | Icon Design | Dominant Color |
|------------|-------------------|--------------------|-------------|----------------|
| `elem_fire` | ひ | Fire | Flame: a single flame shape, pointed top, wide base | Red-orange (`#e86030`) |
| `elem_water` | みず | Water | Droplet: teardrop shape, pointed top, round bottom | Blue (`#4080d0`) |
| `elem_wind` | かぜ | Wind | Swirl: three curved lines suggesting wind motion | Light green (`#70c070`) |
| `elem_earth` | つち | Earth | Rock: angular rock/mountain shape | Brown (`#a08040`) |
| `elem_thunder` | かみなり | Thunder | Bold lightning bolt: larger and sharper than paralysis icon | Bright yellow (`#f8f040`) |
| `elem_light` | ひかり | Light | Star: 4-pointed star shape | White-yellow (`#f8f0c0`) |
| `elem_dark` | やみ | Dark | Crescent: crescent moon shape, opening to the right | Dark purple (`#5030a0`) |
| `elem_none` | なし | None | Dash: horizontal line in the center of the cell | Grey (`#808080`) |

### 19.4 Family Icons

Family icons appear in the codex, monster detail screens, and filter menus.

| Size | 8 x 8 px |
|------|-----------|

| Family ID | Family Name (JP) | Family Name (EN) | Icon Design | Dominant Color |
|-----------|-----------------|-------------------|-------------|----------------|
| `fam_beast` | ビースト | Beast | Paw print: a central pad and three toe pads | Brown (`#c08040`) |
| `fam_bird` | バード | Bird | Feather: a single feather, slightly curved | Sky blue (`#70b0e0`) |
| `fam_plant` | プラント | Plant | Leaf: a single broad leaf with center vein | Green (`#50a040`) |
| `fam_material` | マテリアル | Material | Gear: a simple gear/cog with 4 teeth | Grey (`#909090`) |
| `fam_magic` | マジック | Magic | Star spark: a 4-pointed small star with radiating dots | Violet (`#9060d0`) |
| `fam_undead` | アンデッド | Undead | Bone: a small femur bone shape (ball-shaft-ball) | Bone white (`#d0c8b0`) |
| `fam_dragon` | ドラゴン | Dragon | Horn: a curved horn/fang | Dark red (`#b03030`) |
| `fam_divine` | ディバイン | Divine | Halo: a small circle/ring (halo above implied head) | Gold (`#e8c840`) |
| `fam_slime` | スライム | Slime | Droplet blob: a rounded blob shape, like a slime silhouette | Teal (`#40a0a0`) |

### 19.5 Rank Badges

Rank badges appear in the codex, monster detail screens, breeding previews, and any context where a monster's rank is displayed as an icon.

| Size | 8 x 8 px |
|------|-----------|

Each rank badge is the rank letter rendered bold within the 8x8 cell, with a 1px outline.

| Rank | Letter | Fill Color | Outline Color | Background |
|------|--------|------------|---------------|------------|
| E | E | `#a0a0a0` (grey) | `#000000` | Transparent |
| D | D | `#70b070` (muted green) | `#000000` | Transparent |
| C | C | `#70a0d0` (muted blue) | `#000000` | Transparent |
| B | B | `#d0a040` (amber) | `#000000` | Transparent |
| A | A | `#d06040` (vermilion) | `#000000` | Transparent |
| S | S | `#e8d040` (bright gold) | `#000000` | Transparent |

The letters are designed to be maximally readable at 8x8. They are NOT standard font glyphs; they are custom-drawn icons where each letter fills as much of the cell as possible while maintaining a 1px outline.

---

## 20. Color Specifications for UI (Summary)

This section consolidates all UI color specifications from previous sections into a single reference table.

### 20.1 Window Colors

| Element | Default | Battle | System | Breeding | Shop | Codex |
|---------|---------|--------|--------|----------|------|-------|
| Border | `#1a1a2e` | `#1a1a2e` | `#2a2a2a` | `#2e1a2e` | `#2e2a1a` | `#1a2e2a` |
| Inner rule | `#4a4a6e` | `#5a5a8e` | (none) | `#6e4a5e` | `#6e5a3a` | `#4a6e5e` |
| Fill | `#16213e` | `#0f1a3a` | `#1a1a1a` | `#1e1028` | `#1e1810` | `#101e1a` |
| Shadow | `#000000` | `#000000` | `#000000` | `#000000` | `#000000` | `#000000` |

### 20.2 Text Colors

| Usage | Color (hex) |
|-------|-------------|
| Normal text | `#e8e8e8` |
| Highlighted text (selection) | `#f8f860` |
| Disabled text | `#606060` |
| Warning text | `#e84040` |
| NPC name | `#a0d8f8` |
| System message | `#c0c0c0` |
| MP cost | `#80b0f8` |
| Gold/currency | `#f8d848` |

### 20.3 HP Number Colors

| Condition | Threshold | Color (hex) |
|-----------|-----------|-------------|
| Safe | HP > 50% max | `#e8e8e8` |
| Caution | HP 26%-50% max | `#f8d848` |
| Danger | HP 1%-25% max | `#e84040` |
| Dead | HP = 0 | `#606060` |

### 20.4 MP Number Colors

| Condition | Threshold | Color (hex) |
|-----------|-----------|-------------|
| Safe | MP > 25% max | `#80b0f8` |
| Low | MP 1%-25% max | `#f8d848` |
| Empty | MP = 0 | `#606060` |

### 20.5 Damage Number Colors

| Type | Number Color | Outline Color |
|------|-------------|---------------|
| Normal damage | `#ffffff` | `#000000` |
| Critical hit | `#f8f860` | `#000000` |
| Healing | `#60e860` | `#000000` |
| Miss | `#a0a0a0` | `#000000` |

### 20.6 Cursor Color

| Element | Color (hex) |
|---------|-------------|
| Cursor fill | `#f8f860` |
| Cursor outline | `#000000` |

### 20.7 Selection Highlight (Row Highlight)

| Usage | Color (hex) | Description |
|-------|-------------|-------------|
| Selected row background (swap mode, etc.) | `#2a2a5e` | Slightly lighter than default window fill |
| Disabled selection background | (none) | Disabled items have no background change; only text color changes |

---

## 21. File Naming and Asset Organization

### 21.1 File Naming Convention

```
ui_{category}_{element}_{variant}_{size}.png
```

| Component | Format | Description | Example |
|-----------|--------|-------------|---------|
| `ui` | literal | Fixed prefix for all UI assets | `ui` |
| `{category}` | lowercase ASCII | Asset category | `window`, `cursor`, `icon`, `font` |
| `{element}` | lowercase ASCII, underscores for spaces | Specific element name | `default_tl`, `cursor_frame1`, `heal_potion` |
| `{variant}` | lowercase ASCII | Variant name (if applicable, otherwise omitted) | `battle`, `codex` |
| `{size}` | integer | Asset size in pixels (width) | `8`, `16` |

#### Examples

```
ui_window_default_tl_8.png
ui_window_default_tc_8.png
ui_window_default_tr_8.png
ui_window_default_ml_8.png
ui_window_default_mc_8.png
ui_window_default_mr_8.png
ui_window_default_bl_8.png
ui_window_default_bc_8.png
ui_window_default_br_8.png
ui_window_battle_tl_8.png
ui_cursor_frame1_8.png
ui_cursor_frame2_8.png
ui_icon_item_heal_16.png
ui_icon_item_heal_8.png
ui_icon_ail_poison_8.png
ui_icon_elem_fire_8.png
ui_icon_fam_beast_8.png
ui_icon_rank_s_8.png
ui_font_jp_sheet.png
ui_font_en_sheet.png
ui_font_damage_sheet.png
ui_egg_normal_16.png
ui_egg_cracked_16.png
```

### 21.2 Font Sprite Sheet Layout

#### Japanese Font Sheet

The Japanese font sheet arranges characters in a grid. Each cell is 8x8 pixels.

| Row Range | Content |
|-----------|---------|
| Rows 0-4 | Hiragana (83 characters, 17 columns x 5 rows) |
| Rows 5-9 | Katakana (83 characters, 17 columns x 5 rows) |
| Rows 10-28 | Kanji (up to 300 characters, 17 columns x 18 rows = 306 slots) |
| Rows 29-30 | Numbers and symbols |

Sheet width: 136 px (17 cells x 8px). Sheet height: 248 px (31 rows x 8px).

#### English Font Sheet

| Row Range | Content |
|-----------|---------|
| Row 0 | Space, !"#$%&'()*+,-./ (16 characters) |
| Row 1 | 0123456789:;<=>? (16 characters) |
| Row 2 | @ABCDEFGHIJKLMNO (16 characters) |
| Row 3 | PQRSTUVWXYZ[\]^_ (16 characters) |
| Row 4 | `abcdefghijklmno (16 characters) |
| Row 5 | pqrstuvwxyz{|}~ (15 characters + 1 empty) |

Sheet width: 128 px (16 cells x 8px). Sheet height: 48 px (6 rows x 8px).

#### Damage Number Font Sheet

| Row 0 | 0123456789 (10 characters, bold variant) |

Sheet width: 80 px (10 cells x 8px). Sheet height: 8 px.

### 21.3 Source Files

All UI assets have source files in `.aseprite` format, stored alongside the exported PNGs. Window frames store all 9 tiles in a single Aseprite file as a 3x3 grid (24x24 px).

---

## 22. Quality Checklist for UI Assets

### 22.1 Technical Checks

| Check | Pass Criteria |
|-------|---------------|
| File format | Exported as `.png`, indexed color, fully transparent background |
| Dimensions | Exact expected pixel dimensions, no extra rows/columns |
| Grid alignment | All window tiles are exactly 8x8 px, no sub-pixel offsets |
| Palette compliance | Every pixel color exists in the master palette (`master_palette.hex`) |
| Transparency | Background is fully transparent (alpha = 0). No semi-transparent pixels anywhere. |
| No metadata | No embedded color profiles, no EXIF data, no comments in PNG chunks |
| Outline consistency | All outlines are exactly 1px. No 2px outlines, no broken outlines. |
| Naming | File name matches the naming convention exactly. No spaces, no uppercase, no special characters beyond underscores. |

### 22.2 Readability Checks

| Check | Pass Criteria |
|-------|---------------|
| 1x readability (text) | Every character in the bitmap font is legible at native 160x144 resolution on a mobile device screen. No ambiguous character pairs (e.g., 1/l/I must be distinguishable, 0/O must be distinguishable). |
| 1x readability (icons) | Every 8x8 icon is identifiable at native resolution. The icon's meaning can be guessed from its shape alone without color. |
| 1x readability (windows) | Window borders are clearly visible against any expected background (field map, battle background, black). |
| Color contrast | Text color against window fill color has sufficient contrast. Disabled text is still legible (dim but not invisible). |
| Cursor visibility | The cursor is clearly visible against the window fill and does not blend with highlighted text. |
| Damage number visibility | Damage numbers with their outlines are readable against any enemy sprite and any battle background. |

### 22.3 Consistency Checks

| Check | Pass Criteria |
|-------|---------------|
| Border style consistency | All 6 window variants use the same border thickness (1px outer). The visual differences are in color and inner-rule presence only, not in structural proportions. |
| Icon style consistency | All icons (item, ailment, element, family, rank) share the same outline weight (1px), shading direction (top-left light), and pixel art quality level. No icon looks like it was made by a different artist. |
| Color temperature | Window variants for different contexts (battle vs. breeding vs. shop) have distinct but harmonious color palettes. No two variants are so similar they could be confused. |
| Text alignment | All text in all screens aligns to the same baseline grid (8px rows). Numbers right-align in their columns. Labels left-align. |
| Cursor placement | The cursor appears at the same relative position (left of text, 2px gap) in every menu, list, and selection context. |

### 22.4 Platform Checks

| Check | Pass Criteria |
|-------|---------------|
| Virtual pad clearance | No essential UI information is placed in the bottom 20% of the screen where the virtual pad overlays. The message window at tile rows 14-17 is the only content in this zone, and it is a temporary overlay, not permanently obscured. |
| Touch target size | All menu items occupy at least 1 full tile row (8px internal = a minimum touch target in the scaled view). On typical devices (scaling 3x-5x), this produces 24-40 device pixel tall touch targets, meeting minimum usability standards. |
| Landscape orientation | The game runs in landscape only. All layouts assume a wider-than-tall viewport. |
| Scaling artifacts | At integer scaling (2x, 3x, 4x, 5x), no interpolation or filtering is applied. Nearest-neighbor scaling only. Every internal pixel maps to an NxN block of device pixels. |
| Safe area (notch/island) | The virtual pad layer respects device safe area insets. Game content renders edge-to-edge but the virtual pad buttons are inset from device safe areas. |

### 22.5 Animation Checks

| Check | Pass Criteria |
|-------|---------------|
| Cursor animation | 2 frames, 300ms per frame, smooth 1px horizontal oscillation. No jitter, no missed frames. |
| Window open/close | 4 steps, 8 total game frames (133ms). Content appears only on final frame. No visual glitch during expansion. |
| Page indicator blink | 20f visible / 10f hidden cycle. Regular rhythm, no stutter. |
| Damage number float | 8f rise, 12f hold, 6f fade. Numbers never overlap the top edge of the screen. |
| HP flash | 2f invisible / 2f visible x 3 cycles = 12f total. Consistent rhythm. |
| Status row danger flash | 30f normal / 30f danger color, alternating. Does not interfere with HP flash timing. |
| Birth animation | Total ~126 frames (2.1 seconds). Each phase transitions cleanly to the next. |

---

## 23. Complete Asset Inventory

This section lists every unique UI sprite asset that must be produced.

### 23.1 Window Frame Tiles

6 variants x 9 tiles each = **54 tiles** (each 8x8 px).

```
win_default:  TL, TC, TR, ML, MC, MR, BL, BC, BR
win_battle:   TL, TC, TR, ML, MC, MR, BL, BC, BR
win_system:   TL, TC, TR, ML, MC, MR, BL, BC, BR
win_breeding: TL, TC, TR, ML, MC, MR, BL, BC, BR
win_shop:     TL, TC, TR, ML, MC, MR, BL, BC, BR
win_codex:    TL, TC, TR, ML, MC, MR, BL, BC, BR
```

### 23.2 Cursor

2 frames x 1 variant = **2 sprites** (each 8x8 px).

### 23.3 Font Glyphs

| Sheet | Approximate Glyph Count |
|-------|------------------------:|
| Japanese font | ~466 glyphs (83 hiragana + 83 katakana + ~250 kanji + ~50 symbols/numbers) |
| English font | 95 glyphs |
| Damage number font | 10 glyphs (0-9, bold) |
| Total | ~571 glyphs |

### 23.4 Item Icons

9 categories x 2 sizes (16x16 and 8x8) = **18 base icons**. Individual item variants within each category will increase this count; estimate ~60-80 total item icons at 16x16 and ~60-80 at 8x8.

For initial production, produce the **9 base category icons** in both sizes = **18 icons**.

### 23.5 Status Ailment Icons

7 ailments x 1 size (8x8) = **7 icons**.

### 23.6 Element Icons

8 elements x 1 size (8x8) = **8 icons**.

### 23.7 Family Icons

9 families x 1 size (8x8) = **9 icons**.

### 23.8 Rank Badges

6 ranks x 1 size (8x8) = **6 icons**.

### 23.9 Special UI Sprites

| Asset | Size | Count |
|-------|------|------:|
| Page advance indicator (▼) | 8x8 | 1 |
| Scroll up indicator (▲) | 8x8 | 1 |
| Favorite lock icon (♥) | 8x8 | 1 |
| Padlock icon (locked gate) | 8x8 | 1 |
| Star icon (★, active strategy) | 8x8 | 1 |
| Empty star icon (☆, skill tree unselected) | 8x8 | 1 |
| Plus symbol (＋, breeding) | 8x8 | 1 |
| Equals symbol (＝, breeding) | 8x8 | 1 |
| Question mark silhouette (unknown breeding result) | 16x16 | 1 |
| Egg sprite (normal) | 16x16 | 1 |
| Egg sprite (cracked) | 16x16 | 1 |
| Auto-save indicator | 8x8 | 1 |
| Gate icons (per world, unique) | 16x16 | ~20 (one per world) |

### 23.10 Total Asset Count (Minimum Initial Production)

| Category | Count |
|----------|------:|
| Window frame tiles | 54 |
| Cursor sprites | 2 |
| Font glyphs (all sheets) | ~571 |
| Base item icons (both sizes) | 18 |
| Status ailment icons | 7 |
| Element icons | 8 |
| Family icons | 9 |
| Rank badges | 6 |
| Special UI sprites | ~32 |
| **Grand total** | **~707 individual sprite assets** |

---

## 24. DoD (Definition of Done)

This UI Sprite Production Manual is considered v1 complete when the following are present:

- All 54 window frame tiles produced, reviewed, and passing all quality checks
- Cursor sprites (2 frames) produced and animated correctly
- Japanese and English font sheets produced with all required characters
- Damage number font sheet produced
- All 9 base item icon categories produced at both 16x16 and 8x8
- All 7 status ailment icons produced
- All 8 element icons produced
- All 9 family icons produced
- All 6 rank badge icons produced
- Egg sprites (normal and cracked) produced
- All special UI sprites produced
- Every asset passes the quality checklist (Section 22)
- Every asset uses only colors from the master palette
- Every asset follows the naming convention (Section 21)
- At least one full screen has been assembled (all tiles placed, text rendered, cursor animated) as a reference screenshot at 1x and 3x scale to verify readability and coherence
