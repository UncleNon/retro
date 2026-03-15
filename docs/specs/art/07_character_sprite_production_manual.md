# 07. Character Sprite Production Manual

> **Status**: Draft v1.0
> **Last Updated**: 2026-03-15
> **References**:
> - `docs/specs/art/01_style_bible.md`
> - `docs/specs/art/02_monster_sprite_production_manual.md`
> - `docs/specs/content/03_starting_village_npcs.md`
> - `docs/requirements/03_world_and_story.md`
> - `docs/requirements/07_ui_ux.md`
> - `docs/requirements/08_art_pipeline.md`

---

## Purpose

This document is the **single definitive reference** for producing all character sprites in the game — the protagonist (male and female variants), key NPCs, minor NPCs, mob NPCs, children, and all humanoid characters that appear on the field map, in menus, or in dialogue. Every pixel-level decision — canvas size, body proportion, color budget, face construction, walk cycle animation, clothing rules, world variation, file naming, quality gates — is specified here in full. No external document is required to resolve an ambiguity. Any artist, any AI tool operator, any reviewer can use this manual alone to produce or evaluate a character sprite that is consistent with every other character sprite in the game.

This manual does not replace the Style Bible (`01_style_bible.md`). It extends it with exhaustive production-level detail specific to human and humanoid character sprites. It follows the same structural conventions as the Monster Sprite Production Manual (`02_monster_sprite_production_manual.md`) and shares the same master palette, outline rules, and file format specifications.

---

## 1. Character Sprite Fundamentals

### 1.1 Canvas Size

All character sprites use a **16x16 pixel** canvas. There are no exceptions. This applies to:

| Character Type | Canvas Width (px) | Canvas Height (px) |
|----------------|-------------------|---------------------|
| Protagonist (male) | 16 | 16 |
| Protagonist (female) | 16 | 16 |
| Key NPC | 16 | 16 |
| Minor NPC | 16 | 16 |
| Mob NPC | 16 | 16 |
| Child NPC | 16 | 16 |
| Tower management NPC | 16 | 16 |
| Ghost/remnant NPC | 16 | 16 |

Characters share the 16x16 canvas with monster field sprites. This ensures consistent visual density on the field map, where characters and monsters occupy the same tile grid (8x8 tiles, characters occupy a 2x2 tile area).

There are no larger character sprite canvases. Characters do not have battle sprites, codex sprites, or gallery sprites. If a character portrait is required for dialogue, it is a separate asset defined in the UI specification and is NOT covered by this manual.

### 1.2 Pixel Budget

A 16x16 canvas contains 256 total pixels. The character sprite uses a subset of these pixels; the remainder are fully transparent background.

| Character Type | Minimum Opaque Pixels | Maximum Opaque Pixels | Target Opaque Pixels |
|----------------|----------------------|----------------------|---------------------|
| Protagonist | 90 | 120 | 105 |
| Key NPC (adult) | 85 | 120 | 100 |
| Minor NPC (adult) | 85 | 115 | 100 |
| Mob NPC (adult) | 80 | 110 | 95 |
| Child NPC | 55 | 80 | 68 |

These counts include all outline pixels, fill pixels, and detail pixels. The transparent background does NOT count.

The pixel budget creates a fill percentage of approximately 35-47% of the canvas. This is lower than monster field sprites because the human silhouette is narrower — characters are taller than they are wide, unlike many monsters.

### 1.3 Color Budget

Colors are drawn from the project master palette (`tools/palette-remap/master_palette.hex`, 32 colors). The transparent background does NOT count as a color. The outline color counts as one of the character's colors.

| Character Type | Minimum Colors | Maximum Colors | Typical Colors |
|----------------|---------------|----------------|----------------|
| Protagonist | 5 | 7 | 6 |
| Key NPC | 5 | 6 | 5-6 |
| Minor NPC | 4 | 5 | 4-5 |
| Mob NPC | 3 | 4 | 3-4 |
| Child NPC | 4 | 5 | 4 |

Color role assignment for characters follows the same priority structure as monster sprites:

| Role | Character Usage | Mandatory? |
|------|----------------|------------|
| Role 1: Outline | Outer contour, hair outline, clothing edges, facial features | Yes, all types |
| Role 2: Body Base (Clothing) | Dominant clothing color — the largest fill area | Yes, all types |
| Role 3: Body Shadow (Clothing Shadow) | Darker value of the dominant clothing, same hue family | Yes, all types |
| Role 4: Skin Tone | Face, hands, exposed skin areas | Yes, all types |
| Role 5: Hair Color | Hair fill | Yes, all types (minimum 4 colors uses hair = outline) |
| Role 6: Accent | Secondary clothing color, accessory, belt, detail | Protagonist and Key NPCs only |
| Role 7: Additional Detail | Skin shadow, second accent, special detail | Protagonist only |

For mob NPCs at 3 colors, the minimum allocation is: outline (1) + clothing base (1) + skin tone (1). Hair is rendered using the outline color. Clothing shadow is omitted or uses the outline color for fold lines.

### 1.4 File Naming Convention

The naming convention is:

```
chr_{id}_{slug}_{direction}_{frame}.png
```

Each component:

| Component | Format | Description | Example |
|-----------|--------|-------------|---------|
| `chr` | literal | Fixed prefix for all character sprites | `chr` |
| `{id}` | category prefix + 3-digit zero-padded integer | Character ID. Prefixes: `pro` = protagonist, `key` = key NPC, `min` = minor NPC, `mob` = mob NPC | `pro001`, `key003`, `mob012` |
| `{slug}` | lowercase ASCII, underscores for spaces | Romanized short name or variant name | `male_a`, `female_b`, `natsuse`, `sae`, `villager_brown` |
| `{direction}` | one of: `down`, `left`, `right`, `up` | Facing direction | `down` |
| `{frame}` | `f1` or `f2` | Animation frame number | `f1` |

Full examples:

```
chr_pro001_male_a_down_f1.png
chr_pro001_male_a_down_f2.png
chr_pro001_male_a_left_f1.png
chr_pro001_male_a_up_f2.png
chr_key001_natsuse_down_f1.png
chr_key002_sae_left_f1.png
chr_min001_villager_a_down_f1.png
chr_mob001_villager_brown_down_f1.png
```

For sprite sheets (all frames in a single file):

```
chr_{id}_{slug}_sheet.png
```

Sprite sheet layout:

```
Row 1: down_f1 | left_f1 | right_f1 | up_f1
Row 2: down_f2 | left_f2 | right_f2 | up_f2
```

Each cell is 16x16 pixels. The full sprite sheet is 64x32 pixels.

For characters that use left-right flipping (the right-facing frames are horizontal mirrors of left-facing frames), only the left-facing frames are authored. The engine generates the right-facing frames at runtime. However, the exported sprite sheet still includes all 8 frames with the right-facing frames pre-flipped, for tools that do not support runtime flipping.

#### Aseprite Source Files

- Format: `.aseprite`
- Required layers (minimum):
  - `outline` — the 1px outline of the character
  - `fill_clothing` — clothing color fills
  - `fill_skin` — skin tone fills
  - `fill_hair` — hair color fills
  - `accent` — accessories, belt, detail marks
- Optional layers:
  - `shadow` — clothing shadow fills (may be merged into `fill_clothing`)
  - `skin_shadow` — skin shadow (protagonist only)
  - `special` — world-specific detail, ghost effect, tower mark
- Animation frames are stored as Aseprite frames within the same file
- Tags in Aseprite label animation sequences: `walk_down`, `walk_left`, `walk_right`, `walk_up`

### 1.5 Background

Every character sprite has a fully transparent background. The same rules as monster sprites apply:

- No solid color background fill
- No gradient background
- No ground line drawn beneath the character
- No shadow blob or drop shadow beneath the character
- No environmental elements
- No decorative border
- No semi-transparent pixels — every pixel is either fully opaque (alpha = 255) or fully transparent (alpha = 0)

### 1.6 Edge Clearance

No character sprite touches the absolute edge of the canvas on any side. Minimum clearance is **1 pixel** on all four sides:

- Pixel row 0 (top): fully transparent
- Pixel row 15 (bottom): fully transparent
- Pixel column 0 (left): fully transparent
- Pixel column 15 (right): fully transparent

This means the maximum drawable area for a character is 14x14 pixels (columns 1-14, rows 1-14).

---

## 2. Body Proportion Grid

### 2.1 The 2-Head-Tall Chibi Standard

All adult characters use a **2-head-tall chibi** proportion. This means the total character height is approximately twice the height of the character's head. This is a hard rule.

At 16x16 pixels, the character occupies approximately rows 1-14 vertically (14 usable pixel rows, with rows 0 and 15 as transparent edge clearance). The body proportion divides this 14-row space as follows:

```
Row 0:  [transparent edge clearance]
Row 1:  ┌── HEAD zone top (hair top)
Row 2:  │   Hair / hat
Row 3:  │   Hair / forehead
Row 4:  │   Eyes
Row 5:  │   Face lower / chin
Row 6:  │   Neck / head-body junction
Row 7:  ├── BODY zone top
Row 8:  │   Torso upper / shoulders / arm attachment
Row 9:  │   Torso mid / belt line / hands
Row 10: │   Torso lower / hip
Row 11: ├── LEG zone top
Row 12: │   Upper legs
Row 13: │   Lower legs / feet
Row 14: │   Feet / ground contact
Row 15: [transparent edge clearance]
```

### 2.2 Zone Dimensions

| Zone | Rows | Height (px) | Notes |
|------|------|-------------|-------|
| Head (hair top to chin) | 1-6 | 6 pixels | Includes hair, face, chin. May extend to row 7 if wearing a tall hat |
| Neck/junction | 6-7 | 1 pixel | Transitional — may be shared between head and body zones |
| Body (shoulders to hip) | 7-10 | 4 pixels | Includes torso, arms, belt, hands |
| Legs/feet | 11-14 | 4 pixels | Includes upper legs, lower legs, feet, ground contact |

The head zone is slightly taller than a strict 50% division because chibi proportion emphasizes the head. The head is approximately 6-7 pixels tall; the body + legs are approximately 7-8 pixels tall. This creates the characteristic chibi 2-head ratio.

### 2.3 Width Dimensions

| Body Part | Width (px) | Column Span (typical) |
|-----------|------------|----------------------|
| Head | 7-9 | Centered on canvas, columns 4-12 typical |
| Hair (widest point) | 8-10 | May extend 1px wider than face on each side |
| Shoulders | 8-10 | Same width as or slightly wider than head |
| Torso | 6-8 | Narrows slightly from shoulders |
| Hips | 6-8 | Same as or slightly wider than torso |
| Arms (each) | 1-2 | Extend from shoulder columns outward |
| Legs (each) | 2-3 | Positioned under hips |
| Feet (each) | 2-3 | Same width as or slightly wider than legs |

### 2.4 Side View Width

When the character faces left or right:

| Body Part | Depth (px) | Notes |
|-----------|-----------|-------|
| Head | 6-7 | Profile view head depth |
| Body | 5-7 | Profile view torso depth |
| Legs | 3-4 | Profile view leg depth (both legs overlap) |

Characters are narrower in side view than in front view. The front-facing (down) sprite is the widest pose.

### 2.5 Arm Attachment

Arms attach at rows 7-8 (shoulder area). In the front-facing (down) sprite:

- Arms hang at the character's sides
- Each arm is 1-2 pixels wide
- Arms extend from the shoulder column to 1-2 pixels below the belt line (row 9-10)
- Hands are suggested by a 1px skin-tone pixel at the arm's end, or by the arm terminating at the right row without an explicit hand pixel

In walk animation frames, arms swing forward and backward by 1 pixel. This is the primary walk animation indicator alongside leg movement.

### 2.6 Protagonist vs. NPC Proportions

The protagonist at 45 years old has a **slightly stockier** build than a generic young NPC:

| Measurement | Young NPC (20s) | Protagonist (45) | Elder (60-70s) | Child (8-10) |
|-------------|----------------|-------------------|----------------|-------------|
| Shoulder width | 8px | 9-10px | 8-9px | 6-7px |
| Torso width | 6px | 7-8px | 7px | 5px |
| Head height | 6px | 6px | 6px | 6px |
| Body+legs height | 8px | 8px | 7-8px (slight hunch) | 5-6px |
| Total height | 14px | 14px | 13-14px | 11-12px |

The stockiness of the protagonist is communicated through 1-2 extra pixels of shoulder and torso width, not through height changes. The protagonist is the same height as other adults but occupies slightly more horizontal space.

---

## 3. Protagonist Design

### 3.1 Core Identity

The protagonist is a **45-year-old livestock keeper** in a small village. They are not a warrior, not a scholar, not a teenager on their first adventure. They are a working adult who has spent decades tending animals and maintaining records. Everything about the sprite must communicate this identity.

Key visual signals:

| Signal | How It Reads | Pixel Implementation |
|--------|-------------|---------------------|
| Age (45) | Not young, not elderly | Slightly stocky build (9-10px shoulders), no slim teen proportions |
| Occupation (livestock keeper) | Practical, outdoor worker | Earth-toned work clothes, no armor, no robes |
| Demeanor (weary but determined) | Lived-in, not heroic | Muted color palette, no flowing cape, no bright accent |
| Gender | Male or female variant | Silhouette differences in hair and shoulders |

### 3.2 Male Protagonist

#### Front-Facing (Down) Pixel Map

The following is the definitive pixel layout for the male protagonist's front-facing idle frame (down_f1). All coordinates are 0-indexed (top-left = 0,0).

```
Row 0:  . . . . . . . . . . . . . . . .    (transparent)
Row 1:  . . . . . O O O O O O O . . . .    (hair top — outline + hair fill)
Row 2:  . . . . O H H H H H H H O . . .    (hair upper)
Row 3:  . . . . O H H H H H H H O . . .    (hair + forehead)
Row 4:  . . . . O S e S S e S H O . . .    (face: S=skin, e=eye, H=hair side)
Row 5:  . . . . O S S S S S S H O . . .    (face lower)
Row 6:  . . . . . O S S S S O . . . . .    (chin/neck)
Row 7:  . . . O O C C C C C C O O . . .    (shoulders)
Row 8:  . . . . O C C c C c C C O . . .    (torso upper, c=clothing shadow)
Row 9:  . . . . O C a a a a C C O . . .    (torso mid, a=accent/belt)
Row 10: . . . . . O C C C C C O . . . .    (hips)
Row 11: . . . . . O C c C c C O . . . .    (upper legs)
Row 12: . . . . . O C C . C C O . . . .    (mid legs, gap between legs)
Row 13: . . . . . O C C . C C O . . . .    (lower legs)
Row 14: . . . . . O O O . O O O . . . .    (feet)
Row 15: . . . . . . . . . . . . . . . .    (transparent)
```

Legend:
- `.` = transparent
- `O` = outline color (Role 1, typically #000000)
- `H` = hair color (Role 5)
- `S` = skin tone (Role 4)
- `e` = eye pixels (outline color, 1px each)
- `C` = clothing base color (Role 2)
- `c` = clothing shadow color (Role 3)
- `a` = accent color (Role 6, belt/detail)

This is an approximate reference layout. The exact placement varies by customization variant. The key constraints are:

- Head spans columns 4-12 (9px wide including outline)
- Body spans columns 3-12 (10px wide at shoulders, including outline)
- Legs span columns 5-11 (7px wide including outline)
- Eyes are on row 4, positioned symmetrically
- Hair occupies rows 1-5 on the sides and rows 1-3 on top
- Belt/accent line is on row 9

#### Male Protagonist — Key Features

**Hair**: Short, practical hair. 3 rows of hair fill on top (rows 1-3), extending down the sides to row 5. The hair color is a muted brown or dark grey. 1-2 pixels of lighter color (grey or light brown) are mixed into the hair fill to suggest greying at 45 — these lighter pixels are placed at the temples (the leftmost and rightmost hair pixels on row 3 or 4). The hair does NOT extend below the ear line (row 5). No ponytail, no long hair, no bald head (though a very short crop is acceptable).

**Face**: The face occupies a 6x3 pixel area (columns 5-10, rows 4-6) inside the head outline. Eyes are 1 pixel each, placed on row 4 at columns 5 and 10 (or 6 and 9, depending on head width). Eyes use the outline color. Between and around the eyes, skin tone fills the face. Row 5 is full skin tone (lower face — no mouth pixel at this scale). Row 6 is the chin, narrowing to 4-6 pixels of skin tone.

**Facial hair (male only)**: To suggest a 45-year-old man's stubble or short beard, 1-2 pixels of the outline color (or a dark tone between outline and skin) are placed on row 5 at the chin area (columns 7-8). This reads as a shadow or stubble line on the jawline. This is subtle — not a full drawn beard, just a tonal hint.

**Body**: Shoulders at row 7 are 10 pixels wide (including outline), making the protagonist visibly stockier than younger NPCs. The torso narrows to 8 pixels at the hips (row 10). Clothing is earth-toned: brown, dark green, or muted blue as the base color, with a darker value of the same hue for shadow. A belt or waistband at row 9 uses the accent color (a different muted tone — leather brown, dull brass, faded rope color).

**Arms**: Arms are visible at the sides, each 1-2 pixels wide, extending from row 7 to row 9-10. The outer arm pixel is clothing color; a hand pixel of skin tone may appear at the bottom of each arm (row 10). In the front-facing idle, arms are straight at the sides.

**Legs and feet**: Legs occupy rows 11-14. Each leg is 2-3 pixels wide. A 1-pixel gap between the legs is visible on rows 12-13 (transparent pixel between the legs). Feet on row 14 are 3 pixels wide each (or 2px foot + 1px outline). Leg color is the clothing base or a slightly different clothing tone (same palette, different hue if trousers differ from shirt). Feet/shoes use the clothing shadow color or a boot color.

### 3.3 Female Protagonist

The female protagonist occupies the same 16x16 canvas and uses the same body proportion grid. She is the same height (14 pixels visible) and conveys the same age (45), occupation (livestock keeper), and demeanor (practical, weathered).

#### Differences from Male Variant

| Feature | Male | Female |
|---------|------|--------|
| Shoulder width | 10px (incl. outline) | 9px (incl. outline) |
| Hair | Short, 3 rows top, sides to row 5 | Slightly longer, tied back. Sides to row 6, with 1-2px at back of head on row 6-7 suggesting a short bun or gathered hair |
| Hair greying | 1-2 light pixels at temples (row 3-4) | 1-2 light pixels at temples (row 3-4), identical treatment |
| Facial hair | 1-2 stubble pixels on row 5 | None — row 5 is full skin tone |
| Torso shape | Straight shoulder-to-hip, 10px to 8px | Slight taper: 9px shoulders to 7px waist to 8px hips |
| Clothing | Tunic or work shirt, straight cut | Tunic or work dress, may have slightly different neckline (1px difference at row 7) |
| Belt | Accent color belt at row 9 | Accent color belt or apron tie at row 9 |
| Legs | Trousers, both legs same color | Trousers or long skirt. If skirt, legs merge into a single 6px-wide skirt shape on rows 11-13 with no gap between legs |
| Feet | Boots, 3px each | Boots, 2-3px each |

The female protagonist's silhouette is distinguishable from the male at a glance primarily through:
1. Hair shape (slightly wider or longer at the back)
2. Shoulder width (1px narrower)
3. Torso taper (slight waist-hip curve vs. straight cut)

These differences are subtle (1-2 pixels each) but cumulatively create a distinct silhouette.

### 3.4 Protagonist Color Palette

The protagonist's clothing uses **earth-toned, muted, practical colors**. The following are the approved clothing base colors drawn from the master palette:

| Clothing Variant | Base Color (Role 2) | Shadow Color (Role 3) | Accent (Role 6) | Visual Impression |
|------------------|--------------------|-----------------------|-----------------|-------------------|
| Variant A (brown) | Warm medium brown | Dark brown | Dull copper/leather | Tanned leather work clothes |
| Variant B (green) | Muted olive green | Dark olive | Dark brown belt | Dyed work tunic |
| Variant C (blue) | Muted slate blue | Dark navy | Worn rope/tan | Faded indigo work shirt |
| Variant D (grey) | Warm medium grey | Dark charcoal | Dull brass | Undyed wool work clothes |

Prohibited clothing colors for the protagonist:
- Bright red, bright blue, bright green, or any saturated primary color
- White (too clean for a livestock keeper)
- Black (reads as armor or formal wear, not work clothes)
- Gold or silver (reads as ornamental)
- Any color that reads as armor, ceremonial dress, or adventurer gear

### 3.5 Protagonist Skin and Hair Color Options

#### Skin Tones

The master palette provides 3 skin tone options. Each skin tone has a base value and a shadow value (used for the protagonist only, where the 7-color budget allows a skin shadow).

| Skin Option | Base (Role 4) | Shadow (Role 7) | Description |
|-------------|--------------|-----------------|-------------|
| Skin A (light) | Light peach/cream | Warm beige | Fair complexion |
| Skin B (medium) | Warm tan | Medium brown | Sun-weathered complexion |
| Skin C (dark) | Rich brown | Deep brown | Dark complexion |

Key NPCs and minor NPCs use the base skin tone only (no shadow), because their color budget does not accommodate a skin shadow color.

#### Hair Colors

Hair color options for the protagonist:

| Hair Option | Color (Role 5) | Grey Accent | Description |
|-------------|---------------|-------------|-------------|
| Hair A (dark brown) | Dark brown (distinct from outline) | 1-2px medium brown at temples | Common, practical |
| Hair B (black) | Near-black (very dark grey, NOT pure black) | 1-2px dark grey at temples | Distinguished from outline by slight warmth |
| Hair C (auburn) | Dark reddish-brown | 1-2px warm grey at temples | Less common variant |
| Hair D (grey) | Medium grey | No accent needed (already grey) | Fully greyed variant |

Hair MUST be distinguishable from the outline color. If the hair is very dark, it must have a slight warm or cool shift away from the pure black outline. At minimum, the hair fill should be 2-3 brightness steps lighter than the outline.

The **greying effect** (1-2 lighter pixels at the temples) is mandatory for all protagonist hair options except Hair D (already grey). These lighter pixels are placed at the outermost hair columns on row 3 or 4, where the hair meets the face. This subtle detail communicates the character's age even at 16x16 scale.

### 3.6 Protagonist Customization System

The player selects a protagonist appearance at game start. The customization screen offers the following choices:

| Choice | Options | Pixel Impact |
|--------|---------|-------------|
| Gender | Male / Female | Silhouette change (see Section 3.3) |
| Clothing color | 4 variants (A-D) | Role 2 + Role 3 + Role 6 change |
| Skin tone | 3 options (A-C) | Role 4 (+ Role 7 for protagonist) change |
| Hair color | 4 options (A-D) | Role 5 change |

Total combinations: 2 × 4 × 3 × 4 = **96 visual variants**.

Each variant requires a full sprite sheet (8 frames). However, because the structure is palette-swap + silhouette-swap, the production workflow is:

1. Author 2 base sprite sheets (male silhouette, female silhouette) with placeholder colors
2. Generate all 48 color variants per silhouette via automated palette swap using `palette_remap.py`
3. Manually review all 96 variants for palette conflicts (e.g., hair and clothing merging into the same value)
4. Hand-correct any conflicts by adjusting the affected pixels in the source `.aseprite` file

Body type is NOT customizable. All male protagonists share one silhouette; all female protagonists share one silhouette. This constraint keeps the sprite count manageable and ensures consistent hitbox/interaction areas.

### 3.7 What the Protagonist Does NOT Wear

The protagonist's visual identity is defined as much by what is absent as by what is present:

- **No armor**: No metal plates, no chain mail, no leather armor. The protagonist is a civilian.
- **No weapon on sprite**: No sword at hip, no staff in hand, no bow on back. If the protagonist carries a crook or tool, it is only visible in specific event scenes, not on the walking sprite.
- **No cape or cloak**: No fabric flowing behind the character. This is a work clothes silhouette.
- **No helmet or crown**: No head covering that reads as military or royal. A plain hat is acceptable as a variant but is not included in the base customization.
- **No bright accents**: No jewels, no glowing runes, no magical particles.
- **No flowing hair**: Hair is short and practical. No anime-length hair billowing in wind.
- **No heroic silhouette**: The protagonist should NOT be the most visually striking character on screen. They should look like a person who belongs in the village — someone you might walk past without noticing, until you realize they are the one walking toward the tower.

---

## 4. NPC Design Hierarchy

### 4.1 Key NPCs (Named, Story-Relevant)

Key NPCs are characters with unique names, story functions, and personality. In the starting village, these are: Natsuse (elder), Sae (record keeper), Domon (barn master), Minawa (well woman), Yohira (child), Shizune (gravekeeper), Hisame (thread seller), Kaji (missing person's wife), Garo (fence mender), Ren (hauler), Fuu (milkmaid), Magusa (hunter).

Each world in the game has its own set of key NPCs. Total estimated key NPCs across all 21 worlds: approximately 80-120 characters.

#### Key NPC Sprite Requirements

| Requirement | Specification |
|-------------|---------------|
| Walk animation | 2 frames × 4 directions = 8 frames |
| Colors | 5-6 (outline + clothing base + clothing shadow + skin + hair + optional accent) |
| Silhouette | Must be unique — distinguishable from all other key NPCs in the same world at silhouette level |
| Face | Must suggest personality through posture and head shape, not through facial expression pixels |
| Clothing | Reflects role (elder = heavier robes, record keeper = ink-stained practical clothes, child = smaller proportions) |

#### Key NPC Uniqueness Rules

Within any single world (any single map where multiple key NPCs appear simultaneously), every key NPC must be distinguishable from every other key NPC when viewed as a solid-color silhouette.

The primary differentiation methods, in order of visual impact:

1. **Hair shape**: The single most effective way to differentiate characters at 16x16. Hair can be tall, short, wide, asymmetric, tied up, loose, covered by hat, etc. Each key NPC in a world must have a unique hair/head silhouette.
2. **Body proportion**: Elders may be slightly shorter or hunched. Children are significantly shorter. Stocky characters are wider. Thin characters are narrower.
3. **Headwear**: Hats, headscarves, hoods, and ceremonial headpieces change the silhouette dramatically at 16x16.
4. **Carried item**: A tool, broom, basket, or scroll tucked under the arm extends the silhouette.
5. **Clothing volume**: Robes are wider than tunics. Aprons add a front panel shape. Cloaks add width at the back.

Color alone is NOT sufficient to differentiate key NPCs. Two NPCs may have different clothing colors, but if their silhouettes are identical, one must be redesigned. This is because some players may be colorblind, and because tilesets with strong color temperatures can reduce the apparent difference between character palettes.

### 4.2 Minor NPCs (Named, Less Important)

Minor NPCs have names and some dialogue but are not critical to the main story. They provide flavor, side quests, or world-building. Examples: a specific shopkeeper, a named traveler who appears in two worlds, a recurring merchant.

#### Minor NPC Sprite Requirements

| Requirement | Specification |
|-------------|---------------|
| Walk animation | 2 frames × 2 directions (down + left) = 4 frames |
| Right-facing frames | Horizontal flip of left-facing frames |
| Up-facing frames | Not required. Minor NPCs that need to face up use the down-facing frame |
| Colors | 4-5 |
| Silhouette | Must be distinguishable from other minor NPCs in the same scene, but may share body templates with color/hair changes |

Minor NPCs save production cost by using only 2 authored directions. This is acceptable because minor NPCs are typically stationary or patrol short routes and rarely face directly away from the camera in critical story moments.

### 4.3 Mob NPCs (Generic, Unnamed)

Mob NPCs are unnamed background characters who populate towns and villages, providing life and bustle without individual identity. Examples: generic villagers, travelers, market-goers.

#### Mob NPC Sprite Requirements

| Requirement | Specification |
|-------------|---------------|
| Walk animation | 1 frame × 1-2 directions (down required, left optional) |
| Right-facing frames | Horizontal flip of left-facing frames (if left exists) |
| Up-facing frames | Not required |
| Colors | 3-4 |
| Silhouette | Must be distinguishable from the protagonist and key NPCs, but mob NPCs may look similar to each other |

#### Mob NPC Template System

Mob NPCs are produced using a **base body template system**. This system defines 4 base body templates, each of which can be modified with color swaps and 1-2 detail changes to produce multiple distinct mob variants.

**Base Template A: Average Adult**

- Standard 2-head-tall proportion
- 9px shoulder width
- Default posture, arms at sides
- Used for: generic male villagers, travelers, laborers

**Base Template B: Broad Adult**

- 2-head-tall proportion
- 10px shoulder width, wider torso
- Slightly heavier stance
- Used for: merchants, older workers, guards

**Base Template C: Slim Adult**

- 2-head-tall proportion
- 8px shoulder width, narrower torso
- Used for: young adults, messengers, artisans

**Base Template D: Small/Child**

- 1.5-head-tall proportion (see Section 9.1)
- 7px shoulder width
- Shorter total height (11-12px)
- Used for: children, very elderly (hunched)

For each base template, the following modifications create distinct mob variants:

| Modification | Pixel Cost | Examples |
|-------------|-----------|---------|
| Color swap (clothing) | 0 new pixels | Brown tunic → green tunic |
| Hat addition | 3-6 pixels on rows 1-2 | Straw hat, cloth cap, headscarf |
| Carried tool | 2-4 pixels extending from hand area | Hoe, broom, bucket, sack |
| Apron/vest overlay | 2-4 pixels on torso rows | Work apron, merchant vest |
| Hair shape change | 2-4 pixels on rows 1-4 | Bald, ponytail, short crop, long braid |

Each modification changes exactly 1 visual element. Combining a color swap with 1 detail modification produces a distinct mob NPC. From 4 base templates, each with 4 color swaps and 4 detail options, the system yields up to **64 mob variants** before any additional manual authoring.

---

## 5. Face Design at 16x16 Scale

### 5.1 Face Region

The face is the most information-dense region of the character sprite. Within a 16x16 canvas, the face occupies approximately a 6x3 pixel area (columns 5-10, rows 4-6), surrounded by hair and outline. Every pixel in this region carries disproportionate visual weight.

### 5.2 Eye Construction

At 16x16 character scale, each eye is **1 pixel**. There is no room for 2-pixel or larger eyes on character sprites — the face is too small.

| Eye Component | Size | Color | Position |
|---------------|------|-------|----------|
| Left eye | 1px | Outline color (Role 1) | Row 4, 2px from left edge of face |
| Right eye | 1px | Outline color (Role 1) | Row 4, 2px from right edge of face |
| Eye spacing | 2-4px of skin tone between eyes | Skin tone (Role 4) | Row 4, between eye pixels |

The eyes are the only facial features that are explicitly drawn at this scale. Everything else — nose, mouth, cheekbones, brow — is implied by the surrounding skin tone and the head shape.

Eyes are ALWAYS the outline color (black or near-black). Colored eyes are not used on character sprites because at 1 pixel, any color other than the darkest value will look like a stray skin tone pixel, not an eye.

### 5.3 Mouth

Mouths are **NOT drawn** on character sprites at 16x16 scale. The face area below the eyes (row 5) is filled entirely with skin tone. Attempting to draw a mouth at this scale (1 pixel of dark color on row 5) creates a distracting blemish that reads as a mole or skin defect, not a mouth.

Exception: if a character has a very distinctive mouth feature that defines their identity (e.g., a mask covering the lower face), that feature overrides the no-mouth rule. But for all standard characters — protagonist, NPCs, villagers — no mouth pixel.

### 5.4 Nose

Noses are **NOT drawn** on character sprites at 16x16 scale. The same reasoning as mouths: a single darker pixel on the face reads as a defect, not a nose. The bridge of the nose is implied by the way the eyes sit within the face.

Exception: an NPC with a very large or distinctive nose (a comedic or exaggerated character) may have 1px of a slightly darker skin value between or below the eyes. This is rare and reserved for characters whose nose is a defining characteristic.

### 5.5 Facial Hair

For the male protagonist (45 years old) and certain male NPCs, facial hair is suggested through **1-2 pixels of shadow on the lower face**.

Implementation:
- On row 5 (the row below the eyes), the central 2-3 pixels use a color that is darker than the skin tone but lighter than the outline color. This suggests stubble, a short beard, or shadow on the jaw.
- The facial hair color is NOT a new palette color. It uses the clothing shadow color (Role 3) or the skin shadow color (Role 7, protagonist only). This keeps the color budget intact.
- For a clean-shaven character, row 5 is entirely skin tone.
- For a heavily bearded character (e.g., the barn master Domon), the facial hair extends from row 5 down to row 6 (the chin area), replacing some skin tone pixels with darker pixels.

### 5.6 Conveying Age in 2-3 Pixels

The protagonist's 45-year-old appearance is communicated through a combination of cues, none of which relies on facial detail alone:

| Age Cue | Implementation | Where |
|---------|---------------|-------|
| Grey hair | 1-2 lighter hair pixels at temples | Rows 3-4, leftmost/rightmost hair columns |
| Stocky build | 1-2px wider shoulders and torso than young NPCs | Rows 7-8 |
| Muted clothing | No bright colors, no clean whites | Entire clothing area |
| Facial shadow (male) | 1-2px stubble/beard shadow | Row 5, chin area |
| Posture | Upright but not rigid — no heroic chest-puffed stance | Overall silhouette |

No wrinkles are drawn. No eye bags. No receding hairline (unless the character is bald). These features are impossible to communicate at 1px eye scale. The age impression is carried entirely by the hair greying, the build, and the clothing.

### 5.7 Conveying Personality Through Posture (NPCs)

Because facial expression is limited to 1px eyes, NPC personality is communicated through **body posture and silhouette**, not through face details.

| Personality | Posture Cue | Pixel Implementation |
|-------------|------------|---------------------|
| Stern / authoritative | Perfectly upright, wide stance | Legs spread 1px wider, shoulders at maximum width |
| Kind / gentle | Slight forward lean | Head pixel row shifted 1px forward (toward camera in down-facing) |
| Evasive / nervous | Slightly hunched, narrow | Shoulders 1px narrower, head pulled in |
| Elderly / frail | Shorter height, slight forward lean | Total height reduced by 1-2 rows, head forward |
| Confident / bold | Upright, one arm slightly out | One arm extends 1px further from body |
| Busy / hurried | Slight forward lean, arm carrying object | Object pixel in hand area, torso angled |
| Child / innocent | Oversized head ratio | Head zone takes 7px instead of 6px, body proportionally shorter |

---

## 6. Walk Cycle Animation

### 6.1 Directions

Every character has walk frames for 4 directions:

| Direction | Description | Camera Relationship |
|-----------|------------|---------------------|
| Down | Character faces toward the camera | Player sees front of character |
| Up | Character faces away from camera | Player sees back of character |
| Left | Character faces left | Player sees left side profile |
| Right | Character faces right | Player sees right side profile |

### 6.2 Frame Count by Character Type

| Character Type | Directions | Frames per Direction | Total Frames |
|----------------|-----------|---------------------|-------------|
| Protagonist | 4 (down, up, left, right) | 2 | 8 |
| Key NPC | 4 (down, up, left, right) | 2 | 8 |
| Minor NPC | 2 (down, left) | 2 | 4 |
| Mob NPC | 1-2 (down required, left optional) | 1 | 1-2 |

### 6.3 Left-Right Mirroring

For all character types, the **right-facing frames are created by horizontally flipping the left-facing frames**. This is a hard rule.

Characters are assumed to be symmetrical. No character has an asymmetric feature (scar on one cheek, tool on one hip) that would require separately authored right-facing frames. If a character design calls for such asymmetry, the asymmetric detail is sacrificed — it appears on both sides when flipped, or it is visible only in front/back views.

This rule halves the authored frame count for left/right directions and ensures visual consistency.

### 6.4 Walk Cycle Frame Definitions

#### Down-Facing (Toward Camera)

**Frame 1 (down_f1) — Left foot forward, idle frame:**

This is the **idle frame** — the frame displayed when the character is standing still. It is also the first frame of the walk cycle.

- Left leg is extended 1px forward (downward on canvas, row 14 or row 13+14)
- Right leg is in neutral position
- Left arm swings 1px backward (arm pixel is 1px higher/shorter than neutral)
- Right arm swings 1px forward (arm pixel is 1px lower/longer than neutral)
- Head is at its default vertical position

**Frame 2 (down_f2) — Right foot forward:**

- Right leg is extended 1px forward
- Left leg is in neutral position
- Right arm swings 1px backward
- Left arm swings 1px forward
- Head may optionally bob 1px upward from Frame 1 position (0 or 1px vertical displacement)

#### Up-Facing (Away from Camera)

**Frame 1 (up_f1) — Left foot forward:**

The back of the character is visible. No face, no eyes. Hair covers the back of the head. The back of the clothing is visible.

- Hair fills the entire head zone (no face pixels visible)
- Clothing is visible on the torso, showing the back panel
- Left leg forward 1px, right leg neutral
- Arm swing mirrors down-facing frames

**Frame 2 (up_f2) — Right foot forward:**

- Right leg forward 1px, left leg neutral
- Arm swing mirrored from Frame 1
- Optional 1px head bob

#### Left-Facing (Profile)

**Frame 1 (left_f1) — Left foot forward:**

The character is seen from the left side. Only one eye is visible (the left eye, now facing the camera). The body is narrower (profile view, 5-7px wide).

- Profile head: hair visible on the back of the head (left side of canvas), face on the right side. 1 eye pixel visible.
- Body depth: 5-7px
- Left leg extends 1px forward (leftward on canvas)
- Right leg is behind, partially hidden
- Arms overlap the body — the near arm (left arm) is in front of the torso, the far arm (right arm) is behind and partially hidden
- Near arm swings forward (leftward) 1px

**Frame 2 (left_f2) — Right foot forward:**

- Right leg extends forward 1px (replacing left leg position)
- Arms swap swing position
- Optional 1px head bob

#### Right-Facing (Profile)

Created by horizontally flipping left-facing frames. Not separately authored.

### 6.5 Exactly Which Pixels Move Between Frames

The walk cycle involves the minimum pixel change necessary to create the impression of walking. Between Frame 1 and Frame 2 of any direction, the following pixel changes occur:

**Leg alternation (mandatory, all directions):**
- The "forward foot" pixel(s) on rows 13-14 shift from one leg to the other
- This involves moving 2-4 pixels (the foot shape) from one column position to another
- The gap between legs (transparent pixel on rows 12-13) shifts by 1px

**Arm swing (mandatory, all directions):**
- Each arm pixel shifts 1px vertically (or horizontally in side views)
- Forward arm: extend 1px in the direction of movement
- Backward arm: retract 1px opposite the direction of movement
- Total arm displacement: 1px per arm, 2-4 pixels total change

**Head bob (optional):**
- The entire head zone shifts 0 or 1 pixel vertically
- If head bobs, the ENTIRE head (hair, face, outline) moves as a unit
- The body does NOT move when the head bobs — only the head
- Head bob frequency: 0px in Frame 1, 1px up in Frame 2, 0px in Frame 1 (repeat)
- Head bob is recommended for the protagonist to add life, and optional for NPCs

**Total pixel difference between frames**: Typically 6-12 pixels change position (out of ~100 opaque pixels). The vast majority of the character remains static between frames.

### 6.6 Frame Timing

| Game Speed | Frame Duration | Full Cycle (2 frames) | Walk Feel |
|-----------|---------------|----------------------|-----------|
| 1x (standard) | 250ms per frame | 500ms per cycle | Leisurely walk |
| 2x | 125ms per frame | 250ms per cycle | Brisk walk |
| 4x | 62ms per frame | 125ms per cycle | Quick jog feel |

The frame timing is controlled by the game engine, not baked into the sprite. The sprite sheet contains only the frames; the engine applies timing based on the current speed setting.

At 1x speed, the walk cycle completes every 500ms (2 steps per second). This matches the character movement speed of approximately 2 tiles per second (16 pixels per 500ms = 32 pixels per second on the 160x144 screen).

### 6.7 Standing Idle

When the character is not moving, the engine displays **Frame 1 of the down-facing direction** (down_f1). This is the universal idle frame.

If the character has a specified facing direction (e.g., an NPC that faces left when stationary), the engine displays Frame 1 of that direction.

There is no separate idle animation for characters. Unlike monster battle sprites (which have a 2-frame breathing loop), character field sprites are fully static when not walking. Adding a breathing or fidget animation to character sprites is a post-launch enhancement, not a launch requirement.

### 6.8 Walk Cycle Pixel Audit Template

For each character's walk cycle, the artist must verify:

| Check | Pass Criteria |
|-------|--------------|
| Frame 1 and Frame 2 have the same opaque pixel count (±2) | Yes/No |
| Silhouette (outer contour) is identical between frames except at feet and arms | Yes/No |
| Color palette is identical in both frames | Yes/No |
| Head position is consistent (or consistently bobbing ±1px) | Yes/No |
| Arm swing is symmetrical (left arm forward in F1 = right arm forward in F2) | Yes/No |
| Leg alternation is clear (viewer can see the step) | Yes/No |
| At 1x scale, the walk cycle reads as walking (not twitching, not sliding) | Yes/No |
| At 2x speed, the cycle still reads as walking | Yes/No |
| Down, left, right, and up views are recognizable as the same character | Yes/No |

---

## 7. Clothing and Equipment Rules

### 7.1 Protagonist Clothing

The protagonist wears **practical work clothes** appropriate for a livestock keeper in a pre-industrial pastoral village.

**Upper body**: A tunic, work shirt, or vest. The garment has no decorative elements — no embroidery, no trim, no pattern. It is a single clothing base color with shadow to suggest folds. The neckline is simple: round or V-neck, visible as 1-2 pixels of skin tone at the top of the torso (row 7).

**Belt/waist**: A belt, rope tie, or waistband at row 9. This is the accent color element — the one detail that breaks the monotony of the clothing base. It is 1 pixel tall and 4-6 pixels wide. It may suggest leather, rope, or cloth binding.

**Lower body**: Trousers or a long work skirt. Same clothing color family as the upper body, or a slightly different value. Simple cut, no decorative elements.

**Footwear**: Boots or wrapped foot coverings. Rendered in the clothing shadow color or a slightly different dark tone. Boots are 2-3 pixels wide per foot on the ground contact row.

**Accessories visible on sprite**: The protagonist may carry a belt pouch (1-2px bump at the hip, row 9-10) or have a short tool handle (crook, staff, rake) visible as a 1px vertical line extending from the hand area. This tool is OPTIONAL and is not present in the base customization — it may appear after specific story events.

### 7.2 Role-Specific NPC Clothing

Each NPC role has a clothing specification that communicates their function at a glance:

#### Elder (Natsuse, 70s)

- **Silhouette**: Slightly shorter (13px visible height), wider clothing suggesting heavy robes or layered garments
- **Clothing**: Heavier, looser. The torso area is 1-2px wider than average, suggesting thick fabric or multiple layers. Rows 7-10 use a dark, muted color (dark brown, deep grey, faded indigo)
- **Headwear**: Optional cloth head covering or distinctive high hair. Adds 1-2px to the top of the silhouette
- **Detail**: A walking stick visible as a 1px vertical line to one side (columns 2-3 or 12-13), extending from hand area to ground

#### Record Keeper (Sae, 50s)

- **Silhouette**: Standard adult proportions, slightly narrow
- **Clothing**: Practical work clothes similar to protagonist's, but with visible ink stains
- **Detail**: 1px of a dark accent color (ink blue or black) on the hands (row 9-10 hand pixels). This suggests ink-stained fingers. A scroll or book tucked under one arm: 2-3px block at the side of the torso (rows 8-9), a different color from the clothing
- **Headwear**: None. Hair is practical and short

#### Barn Master / Herder (Domon, 60s)

- **Silhouette**: Broad, stocky. 10px shoulder width
- **Clothing**: Heavy work clothes. Thick tunic, possibly a leather vest overlay (1px accent color stripe on the torso front)
- **Detail**: No tool on sprite (tools are in the barn). Facial hair (2-3px of dark shadow on lower face)
- **Headwear**: None or cloth cap (2px on top of head)

#### Merchant / Thread Seller (Hisame, 60s)

- **Silhouette**: Standard proportions with distinctive headwear
- **Clothing**: A merchant's apron or layered garment. The torso has an extra color layer (apron = accent color overlay on rows 8-10)
- **Detail**: Carrying goods: a small bundle or basket represented by 2-3px at the hip
- **Headwear**: A distinctive hat or headscarf. This is the primary silhouette differentiator — the headwear extends 2-3px above the standard hair line

#### Religious Figure / Gravekeeper (Shizune, 50s)

- **Silhouette**: Standard proportions, heavier bottom half (robes)
- **Clothing**: Long robes or ceremonial garment. The legs area (rows 11-14) does not show individual legs — instead, a single continuous garment shape covers the lower body. Color is dark and muted
- **Detail**: A broom or staff visible as a 1px line to one side
- **Headwear**: Optional ceremonial element (1-2px at top of head, different from merchant's hat)

#### Milkmaid / Worker (Fuu, 20s)

- **Silhouette**: Slim, standard young adult proportions (8px shoulders)
- **Clothing**: Simple work tunic, lighter color than the protagonist's
- **Detail**: A bucket or pail represented by 2-3px at the hip area
- **Headwear**: Hair tied back, visible as a wider shape at the back of the head

#### Hunter (Magusa, 50s)

- **Silhouette**: Standard adult, possibly slightly tall (14px, using the full allowed height)
- **Clothing**: Outdoor wear — darker, earth-toned, may have a short cloak or mantle (1-2px extra width at the shoulders extending down the back)
- **Detail**: No weapon visible on sprite (weapons are tools, not character identity in this game)
- **Headwear**: None, or a hood (adds 1px to head top and 1px at the back)

#### Child (Yohira, 8 years)

- See Section 9.1 for full child sprite specification

### 7.3 Prohibited Clothing Elements (All Characters)

The following clothing elements are prohibited on ALL character sprites:

| Prohibited Element | Reason |
|-------------------|--------|
| Metal armor (plate, chain, scale) | No character in this game is a warrior. The game's conflict is through monsters, not personal combat |
| Visible weapons (swords, axes, bows) | Same reason. Characters are civilians, farmers, artisans |
| Capes or flowing cloaks | Too heroic. Breaks the pastoral, lived-in aesthetic |
| Bright colors or saturated hues | Breaks the muted, earth-toned palette established in the Style Bible |
| Clean white garments | Too pristine for a working village. Whites should be off-white, cream, or faded |
| Ornate decoration or filigree | Impossible to render at 16x16 and breaks the practical aesthetic |
| Modern clothing (t-shirts, jeans, sneakers) | Anachronistic |
| Visible underwear or revealing clothing | Inappropriate for the game's tone |
| Glowing or magical elements on clothing | Characters are not magical beings. Only tower management NPCs may have subtle unnatural elements |

---

## 8. World-Specific NPC Variation

### 8.1 Design Principle

Each of the 21 worlds has its own cultural identity, climate, and visual atmosphere. NPCs native to a world should look like they belong to that world. This is achieved by modifying the NPC's palette, headwear, and 1 accessory detail per world, while keeping the body proportion grid, eye placement, animation structure, and outline rules consistent across all worlds.

### 8.2 What Changes Per World

#### 8.2.1 Clothing Color Palette

Each world has a dominant color temperature and associated clothing palette for its NPCs. These align with the world zone color temperatures defined in the Style Bible and Monster Sprite Production Manual:

| World Type | NPC Clothing Temperature | Typical NPC Base Colors | Typical NPC Accent Colors |
|-----------|-------------------------|------------------------|--------------------------|
| Pastoral / village | Warm | Brown, tan, straw yellow, muted green, warm grey | Copper, leather, dull red |
| Tower-adjacent / bureaucratic | Cool | Slate grey, grey-blue, faded white, bone | Cold silver, ink blue, dull gold |
| Forest / frontier | Mixed warm-cool | Moss green, bark brown, slate, storm grey | Amber, moss yellow, faded teal |
| Fire / volcanic | Warm-hot | Burnt orange, dark red, charcoal, ash grey | Ember orange, soot black |
| Ice / mountain | Cool-cold | Pale blue-grey, white-grey, dark navy | Faded blue, frost white |
| Water / coastal | Cool-mixed | Sea grey, blue-green, faded teal, sand | Shell white, rope tan, salt-faded blue |
| Urban / trade | Neutral-warm | Medium brown, varied dyes (muted), grey | Various accents reflecting trade goods |
| Religious / ceremonial | Muted warm | Deep indigo, faded red, bone white, dark brown | Gold (dull), incense amber, candle yellow |
| Underground / mining | Dark warm | Dark brown, charcoal, rust, dim amber | Lamp yellow, ore copper, soot |
| Astral / observatory | Cool-neutral | Night blue, silver-grey, pale violet, black | Star-white, cold gold, glass blue |
| Funerary / mourning | Muted warm-grey | Ash grey, dust brown, wilted green, faded cloth | Dried flower pink, candle yellow, incense amber |

The NPC's clothing base color (Role 2) and clothing shadow (Role 3) are drawn from the world's approved palette. An NPC transplanted from a warm village world to a cold tower world would have distinctly different clothing colors, immediately signaling to the player that they are in a different environment.

#### 8.2.2 Headwear Style

Each world type has a characteristic headwear style for its NPCs:

| World Type | Headwear Style | Pixel Implementation |
|-----------|---------------|---------------------|
| Pastoral / village | Straw hats, cloth caps, headscarves | 2-3px wide on rows 1-2, warm color |
| Tower-adjacent | Flat caps, brimmed hats, stiff headbands | 2-3px wide on rows 1-2, angular shape |
| Forest / frontier | Hoods, leather caps, leaf crowns | 2-3px, wrapping down to row 3 on sides |
| Fire / volcanic | Wrapped cloth turbans, ash-dusted hoods | 3-4px wide, covering rows 1-3 |
| Ice / mountain | Fur-lined hoods, thick wraps | 3-4px wide, bulky shape |
| Water / coastal | Wide-brimmed hats, bandanas | 3px wide extending 1px past head on sides |
| Urban / trade | Varies — shows trade origin | Variable |
| Religious / ceremonial | Ceremonial headpieces, veils | Distinctive shape per religion, 2-4px |
| Underground / mining | Lamp helmets, cloth wraps | 2px on row 1, with 1px accent (lamp) |
| Astral / observatory | Pointed or conical caps | 1-2px extending vertically from row 1 |

Not every NPC in a world wears headwear. The headwear is a tool for communicating world identity and differentiating NPCs, not a universal requirement.

#### 8.2.3 Build and Posture Tendency

Each world type has a subtle tendency in NPC build:

| World Type | Build Tendency | Pixel Implementation |
|-----------|---------------|---------------------|
| Pastoral / village | Stocky, grounded | 9-10px shoulders, sturdy legs |
| Tower-adjacent | Upright, rigid | Perfect vertical alignment, no lean |
| Forest / frontier | Lean, alert | 8-9px shoulders, slight forward lean |
| Fire / volcanic | Broad, heavy | 10px shoulders, wide stance |
| Ice / mountain | Bundled, wide | Extra width from layered clothing |
| Water / coastal | Wiry, agile | 8px shoulders, compact |
| Underground / mining | Hunched, compact | 1px shorter than standard, head forward |

#### 8.2.4 World-Specific Accessory

Each world has 1 characteristic accessory or garment element that appears on some (not all) of its NPCs:

| World Type | Accessory | Pixel Implementation |
|-----------|-----------|---------------------|
| Pastoral / village | Rope belt, straw tied at waist | 1px accent on row 9, warm color |
| Tower-adjacent | Ink-stained hands, ledger tucked under arm | 1-2px dark marks on hands, 2px block at side |
| Forest / frontier | Leaf or feather in hat | 1px accent color on headwear |
| Fire / volcanic | Ash dusting on shoulders | 1-2px light grey on rows 7-8 |
| Ice / mountain | Fur collar or trim | 1px of lighter color at neckline (row 7) |
| Water / coastal | Shell or knot at belt | 1px accent on belt line |
| Religious / ceremonial | Prayer beads or talisman at neck | 1px accent between head and torso |
| Underground / mining | Lamp or tool at belt | 1-2px bright accent at hip |

### 8.3 What Stays Consistent Across ALL Worlds

The following rules are immutable regardless of world:

| Element | Rule |
|---------|------|
| Body proportion grid | 2-head-tall chibi, same zone dimensions |
| Eye placement | Row 4, 1px each, outline color |
| Eye construction | 1px per eye, no colored irises |
| Animation structure | Same frame count, same walk cycle mechanics |
| Outline rules | 1px, outline color, consistent within sprite |
| Canvas size | 16x16, no exceptions |
| Edge clearance | 1px on all sides |
| Color budget | Same per character type (key, minor, mob) |
| File naming | Same convention |
| Transparency | Same rules — all opaque or all transparent, no semi-transparency |
| Shading direction | Top-left light source, two-tone cel shading |

---

## 9. Special Character Types

### 9.1 Children

Children NPCs (e.g., Yohira, age 8) are rendered on the same 16x16 canvas but with altered proportions.

#### Child Proportion Grid

Children use a modified proportion that occupies **12 pixels of height** within the 14-usable-row space (rows 2-13, with rows 1 and 14 transparent in addition to edge clearance on rows 0 and 15).

```
Row 0:  [transparent edge clearance]
Row 1:  [transparent — child is shorter]
Row 2:  ┌── HEAD zone top (hair top)
Row 3:  │   Hair
Row 4:  │   Eyes
Row 5:  │   Face lower / chin
Row 6:  │   Neck / head junction
Row 7:  │   Forehead-to-body is shorter
Row 8:  ├── BODY zone top (shoulders)
Row 9:  │   Torso / hands
Row 10: ├── LEG zone top
Row 11: │   Legs
Row 12: │   Feet / ground contact
Row 13: │   [may use if taller child]
Row 14: [transparent — child is shorter]
Row 15: [transparent edge clearance]
```

| Measurement | Child Value | Adult Value |
|-------------|-----------|-------------|
| Total visible height | 11-12px | 14px |
| Head height | 6px | 6px |
| Body height | 3px | 4px |
| Leg height | 2-3px | 4px |
| Head-to-body ratio | ~2:1 (almost same as adult due to chibi) | ~1.7:1 |
| Shoulder width | 6-7px | 8-10px |
| Head width | 7-8px | 7-9px |

The critical visual difference is: **the child's head is proportionally larger relative to their body**. The head remains 6px tall (same as an adult), but the body and legs shrink. This creates a ratio closer to 2:1 (head:rest) instead of the adult's ~1:1.3 (head:rest), making the child look younger.

Additionally:
- The child's ground contact is at row 12 or 13, not row 14. This means there are 2-3 rows of transparent space below the child's feet, compared to 1 row below an adult's feet. This height difference is visible when the child stands next to an adult on the field.
- Children's clothing colors may be slightly brighter (1 step more saturated) than adult clothing, suggesting less wear and fading.
- Children's hair shapes may be messier or more dynamic (an unruly tuft sticking up = 1px extending above the otherwise smooth hair line).

### 9.2 Animals and Livestock on Field

Animals that appear on the field map (chickens, goats, cattle, dogs) are separate from the monster sprite system. They are rendered as 16x16 field sprites using the same rules as character sprites with the following differences:

| Aspect | Livestock Field Sprite | Character Field Sprite |
|--------|----------------------|----------------------|
| Proportion | No chibi ratio. Animal-natural proportions | 2-head-tall chibi |
| Color budget | 3-4 colors | 3-7 colors depending on type |
| Animation | 2 frames × 2 directions (down + side) | Varies by character type |
| Outline | Same 1px, same outline color | Same |
| Canvas | 16x16 | 16x16 |

Livestock are NOT monsters. They do not appear in the monster registry or codex. They are environmental props with walk animation. Their visual design should be simple, recognizable, and clearly distinct from monster field sprites (livestock look like normal animals — no tags, no brands, no pastoral motif accessories that monsters carry).

### 9.3 Tower Management NPCs

Tower management NPCs are humans (or human-like entities) associated with the tower and the gate system. They are NOT normal villagers. Their appearance should subtly communicate that something is slightly off about them.

| Visual Cue | Implementation | Purpose |
|-----------|---------------|---------|
| Slightly unnatural skin tone | Skin color shifted toward the cool end — pale blue-grey instead of warm peach | Suggests they spend no time outdoors, or are not fully human |
| Rigid posture | Perfectly vertical alignment, no natural lean or asymmetry | They stand too still, too perfectly |
| Clothing color | Cold palette — slate, bone, faded silver, cold gold | Matches the tower's visual language, not any village's |
| Eye detail | Eyes may use the accent color (1px of cold blue or gold) instead of pure black | Their gaze feels different — this is the ONE exception to the "eyes are always outline color" rule for characters |
| Animation | Same walk cycle as normal NPCs — they do not move differently, which makes the visual oddness MORE unsettling, not less | Uncanny valley through appearance, not behavior |

Tower management NPCs use 5-6 colors (key NPC budget) and have full 8-frame walk cycles.

### 9.4 Ghost / Remnant NPCs

Ghost or remnant NPCs are characters who have been partially absorbed by the tower/gate system — the "echoes" of disappeared villagers. They appear in tower interiors and gate environments.

| Visual Cue | Implementation | Purpose |
|-----------|---------------|---------|
| Lighter overall palette | All clothing and skin colors are shifted 2-3 steps lighter toward white/grey. The character looks washed out | Suggests fading, incompleteness |
| Fewer colors | Maximum 4 colors (outline + 2 fill values + 1 skin/detail). The reduced palette makes them look simpler, less real | A person losing their definition |
| Outline color | NOT pure black. Use a dark grey or dark blue-grey outline. The outline is softer, less definite | Their edges are dissolving |
| No shadow colors | Clothing has only a base color, no shadow. The character looks flat, lacking volume | They have lost their physical presence |
| Animation | 2 frames × 2 directions only (down + side). Even key remnant NPCs have reduced animation | They are not fully present — their range of movement is limited |

Ghost NPCs must still be recognizable as human figures. They are NOT translucent (no semi-transparent pixels). The "ghost" effect is achieved entirely through palette lightening, color reduction, and outline softening. At a glance, the player should see a person-shaped figure that looks wrong — faded, flat, too pale — before understanding that this is not a living NPC.

---

## 10. Color Rules for Characters

### 10.1 Master Palette Compliance

All character sprites use ONLY colors from the project master palette (`tools/palette-remap/master_palette.hex`, 32 colors). The same palette governs monsters, tiles, UI, and characters. No character sprite introduces a color outside the master palette.

### 10.2 Skin Tone Palette

The master palette includes the following skin-appropriate colors:

| Skin Option | Base Value | Shadow Value | Usage |
|-------------|-----------|-------------|-------|
| Light | Light peach / cream | Warm beige | Fair-skinned characters |
| Medium | Warm tan | Medium brown | Sun-weathered characters |
| Dark | Rich brown | Deep brown | Dark-skinned characters |

The shadow value is used only for the protagonist (who has a 7-color budget). All NPCs use the base value only. This means NPC faces are flat (single color), while the protagonist's face has subtle shading. This is intentional — it gives the protagonist marginally more visual presence than individual NPCs.

For all skin tones, the base value must:
- Contrast clearly with the outline color (no skin tone should be dark enough to merge with black outlines)
- Contrast clearly with the hair color (skin and hair must be distinguishable at 1x scale)
- Contrast clearly with the clothing (skin areas — face, hands — must read as skin, not as a lighter clothing zone)

### 10.3 Hair Color Palette

| Hair Option | Value | Usage |
|-------------|-------|-------|
| Black | Very dark grey (NOT pure black, which is the outline color) | Common |
| Dark brown | Dark warm brown | Common |
| Auburn / reddish | Dark reddish-brown | Less common |
| Grey | Medium grey | Elderly characters, protagonist variant |
| Light brown | Medium warm brown | Less common, youth |
| White / silver | Light grey or off-white | Very elderly, tower NPCs |

Hair MUST be distinguishable from the outline color. The darkest hair option is very dark grey, not pure black. At 1x scale, the viewer must be able to see the boundary between the hair fill and the hair outline.

### 10.4 Outline Color

Character outlines use the same rules as monster outlines:

- Default: pure black `#000000`
- The outline is consistent within a single sprite
- The outline color is included in the color budget
- Exceptions: ghost/remnant NPCs use dark grey outlines (see Section 9.4)

### 10.5 Avoiding Tileset Clashes

Character sprites must be visually readable against any tileset they appear on. The following rules prevent palette clashes:

| Rule | Rationale |
|------|-----------|
| Character clothing must not be the same value as the predominant ground tile color | A brown-clothed character on brown dirt becomes invisible |
| The outline color must contrast with the tileset's darkest tones | If a tileset has very dark areas, the character must still have a visible outline |
| At least one character color must have high contrast against the tileset | The character must "pop" from the background at minimum through their skin tone or hair |
| Test every character palette against every world tileset before approval | A character might work on grass but fail on stone. Both must pass |

In practice, the protagonist's skin tone and the outline are the two colors most likely to provide universal contrast. Clothing colors are world-variable (see Section 8) and are chosen to complement — not match — the local tileset.

### 10.6 Shading Rules

Character sprites use **two-tone cel shading**, identical to the monster sprite shading method:

- Light source: **top-left**, consistent across all character sprites
- Shadow placement: bottom-right areas of each body mass
- Clothing: base color (lit) + shadow color (in shadow)
- Shadow boundary is a sharp pixel-level edge — no gradients, no dithering
- Skin: base color only for NPCs. Base + shadow for protagonist
- Hair: single fill color (no hair shadow — the hair area is too small)

Prohibited shading techniques (same as monster manual):
- Gradient fills
- Dithering
- Pillow shading
- Banding
- Three-tone shading on a single surface
- Ambient occlusion simulation

---

## 11. AI Generation for Character Sprites

### 11.1 AI Generation Workflow Overview

Character sprites may be initially generated using AI image generation tools and then manually cleaned up in Aseprite. The workflow is:

1. Write the AI prompt using the template below
2. Generate candidate images
3. Select the best candidate
4. Resize/crop to 16x16 if the AI output is larger
5. Remap colors to the master palette using `palette_remap.py`
6. Open in Aseprite for manual cleanup
7. Verify against the quality checklist (Section 12)

### 11.2 Prompt Template for Character Sprites

The following template produces the best results for 16x16 character sprites. Adjust the bracketed fields per character.

```
A single [male/female] [age description] character sprite in pixel art style.

Style: 16x16 pixel art, chibi proportions (2-head-tall), 1 pixel black outline,
flat cel-shaded coloring with no gradients. Game Boy Color aesthetic.
Top-left lighting. Transparent background.

Character: [role description, e.g., "a 45-year-old livestock keeper wearing
brown work clothes and a rope belt"]. Standing idle, facing [direction].
[Hair description]. [Notable features].

REQUIREMENTS:
- Exactly 16x16 pixels
- Maximum [N] colors including black outline
- No anti-aliasing
- No sub-pixel rendering
- No gradients or smooth shading
- No background elements
- No ground shadow
- Simple, readable silhouette
- Head is approximately half the total height
- Eyes are 1 pixel each, black
- No visible mouth
- Earth-toned muted color palette
```

#### Prompt Variables by Character Type

| Character | Age Description | Role Description | Hair Description | Colors |
|-----------|----------------|-----------------|-----------------|--------|
| Protagonist (M) | "middle-aged, 45 years old, slightly stocky build" | "livestock keeper wearing [color] work clothes and a [accent] belt" | "short [color] hair with grey at the temples" | 6-7 |
| Protagonist (F) | "middle-aged, 45 years old, practical build" | "livestock keeper wearing [color] work tunic" | "short [color] hair tied back, with grey at the temples" | 6-7 |
| Elder NPC | "elderly, 70s, slightly stooped" | "village elder in heavy dark robes with a walking stick" | "[color] grey hair, sparse" | 5-6 |
| Child NPC | "young child, 8 years old, small" | "village child in simple clothes" | "messy [color] hair" | 4-5 |
| Mob NPC | "[age range], generic" | "villager in [color] work clothes" | "[color] hair, [style]" | 3-4 |

### 11.3 Common AI Failures with 16x16 Characters

AI image generators frequently produce the following errors when asked for 16x16 character sprites. Each error and its fix:

| AI Failure | Description | Fix in Aseprite |
|-----------|-------------|----------------|
| **Too much detail** | AI renders individual fingers, belt buckles, shoe laces, facial features at sub-pixel level | Remove all detail below the 1px threshold. Merge small clusters into solid fills. Simplify hands to 1px skin tone |
| **Wrong proportions** | AI renders realistic proportions (5-head-tall) instead of chibi (2-head-tall) | Completely redraw. Proportion errors cannot be fixed by editing — the sprite must be re-authored to the 2-head grid |
| **Anti-aliased edges** | Soft, semi-transparent pixels along outlines and color boundaries | Replace all semi-transparent pixels with either fully opaque (nearest color) or fully transparent. Redraw outlines as clean 1px lines |
| **Gradient shading** | Smooth color transitions across surfaces instead of two-tone cel shading | Replace with flat fills: one base color, one shadow color per surface. Delete intermediate tones |
| **Too many colors** | AI uses 15-20 colors instead of the target 5-7 | Run `palette_remap.py` to reduce to master palette, then manually merge similar colors until within budget |
| **Wrong perspective** | AI renders at a direct side view, bird's-eye view, or isometric angle instead of the expected top-down RPG field view | Redraw. Perspective errors cannot be fixed by editing |
| **Background elements** | AI adds a ground plane, shadow blob, or environmental context | Delete all non-character pixels. Set background to transparent |
| **Facial features at wrong scale** | AI draws a visible nose, mouth, eyebrows, eyelashes at 16x16 | Remove all facial features except the 1px eyes. Fill the face area with skin tone |
| **Heroic pose** | AI renders the character in a dynamic action pose instead of idle standing | Redraw in idle pose, or carefully reposition limbs to neutral. Often requires full redraw |
| **Floating** | Character's feet do not contact the ground line at rows 13-14 | Move the entire character downward until feet touch row 14 |

### 11.4 Cleanup Workflow in Aseprite

After AI generation and palette remapping, the following cleanup steps are performed in Aseprite:

**Step 1: Verify canvas size**
- Canvas must be exactly 16x16. Resize if needed. Do NOT use interpolation — use nearest-neighbor scaling only.

**Step 2: Enforce edge clearance**
- Check that rows 0, 15 and columns 0, 15 are fully transparent. Delete any opaque pixels on these edges.

**Step 3: Separate into layers**
- Create the required layers: `outline`, `fill_clothing`, `fill_skin`, `fill_hair`, `accent`
- Move pixels to their correct layers. This enables per-layer editing in future steps.

**Step 4: Fix outlines**
- Verify all outlines are exactly 1px wide
- Verify outer contour is unbroken
- Verify outline color is consistent (all outline pixels are the same color)
- Fix any broken, doubled, or missing outlines

**Step 5: Fix proportions**
- Verify head height (approximately rows 1-6)
- Verify body height (approximately rows 7-10)
- Verify leg height (approximately rows 11-14)
- If proportions are wrong, redraw the affected zones

**Step 6: Fix colors**
- Count total unique colors. Ensure within budget.
- Verify all colors are from the master palette
- Verify skin tone, hair, clothing base, clothing shadow, and accent are all distinguishable at 1x scale
- Merge any colors that are too similar to justify separate palette entries

**Step 7: Fix shading**
- Verify shading direction is top-left
- Verify two-tone cel shading only (no gradients, no dithering, no three-tone)
- Fix any pillow shading or banding

**Step 8: Fix face**
- Verify eyes are 1px each, outline color, on row 4
- Verify no mouth pixel
- Verify no nose pixel
- Verify skin tone fills the face area cleanly

**Step 9: Create animation frames**
- Duplicate Frame 1 to create Frame 2
- Apply the leg alternation, arm swing, and optional head bob
- Repeat for all required directions

**Step 10: Export**
- Export as indexed-color PNG with transparency
- Verify file name matches the naming convention
- Export both individual frame PNGs and the sprite sheet PNG

### 11.5 AI Generation Prohibitions

The same prohibitions from the Style Bible apply to character sprites:

- Do NOT use existing IP names in prompts ("make it look like a Dragon Quest character")
- Do NOT use style-matching references ("pokemon style", "final fantasy style", "stardew valley style")
- Do NOT generate characters with recognizable real-world brand clothing or accessories
- Do NOT generate characters with overtly sexual features or poses
- Do NOT generate characters holding modern objects (phones, guns, etc.)
- Do NOT generate multiple characters in one image — always generate characters individually

---

## 12. Quality Checklist

### 12.1 Technical Checks

Every character sprite must pass ALL of the following technical checks before it is approved for inclusion in the game:

| # | Check | Pass Criteria | Tool |
|---|-------|--------------|------|
| T1 | Canvas size | Exactly 16x16 pixels | Aseprite info panel |
| T2 | File format | Indexed-color PNG with alpha channel | File properties |
| T3 | Background transparency | All non-character pixels are fully transparent (alpha = 0) | Visual inspection at 8x zoom |
| T4 | Edge clearance | Rows 0, 15 and columns 0, 15 are fully transparent | Visual inspection at 8x zoom |
| T5 | Color count | Within budget for character type (see Section 1.3) | Aseprite palette panel |
| T6 | Master palette compliance | All colors match entries in `master_palette.hex` | `palette_remap.py --check` mode |
| T7 | Outline width | All outlines are exactly 1px | Visual inspection at 8x zoom |
| T8 | Outline consistency | All outline pixels use the same color | Aseprite color picker |
| T9 | No semi-transparent pixels | Every pixel is alpha 255 or alpha 0 | `palette_remap.py --check` mode |
| T10 | File naming | Matches `chr_{id}_{slug}_{direction}_{frame}.png` convention | Filename check |
| T11 | Sprite sheet layout | 64x32 pixels, correct grid layout | Visual inspection |
| T12 | Frame count | Correct for character type (8, 4, or 1-2) | Frame count in Aseprite |

### 12.2 Design Checks

| # | Check | Pass Criteria |
|---|-------|--------------|
| D1 | Proportion | 2-head-tall chibi. Head ≈ 6px, body+legs ≈ 8px. Total ≈ 14px visible height |
| D2 | Silhouette readability | Character is recognizable as a human figure at 1x scale (160x144 screen) |
| D3 | Character uniqueness | Within the same world, this character's silhouette is distinct from all other key NPCs |
| D4 | World fit | Clothing colors and accessories match the assigned world's visual language |
| D5 | Role clarity | The character's role (elder, merchant, child, farmer) is suggested by silhouette and clothing |
| D6 | No prohibited elements | No armor, weapons, capes, bright colors, heroic poses, modern clothing |
| D7 | Eye construction | 1px per eye, outline color, row 4, symmetrically placed |
| D8 | No mouth / no nose | Face below eyes is pure skin tone (no facial feature pixels except stubble for specific males) |
| D9 | Shading direction | Top-left light source, consistent two-tone cel shading |
| D10 | Color contrast | Skin, hair, clothing, and outline are all distinguishable at 1x scale |
| D11 | Tileset contrast | Character is readable against the tilesets of every world they appear in |

### 12.3 Animation Checks

| # | Check | Pass Criteria |
|---|-------|--------------|
| A1 | Walk cycle readability | At 1x scale, the walk cycle reads as walking (not twitching, sliding, or jerking) |
| A2 | Frame pixel consistency | Frame 1 and Frame 2 have the same opaque pixel count (±2 pixels) |
| A3 | Silhouette stability | Outer contour is identical between frames except at feet and arm tips |
| A4 | Palette stability | Color palette is identical in both frames — no color changes between frames |
| A5 | Arm swing | Arms alternate correctly: left forward in F1 = right forward in F2 |
| A6 | Leg alternation | Legs alternate correctly: left foot forward in F1 = right foot forward in F2 |
| A7 | Head bob consistency | If head bobs, it bobs 0-1px consistently across all directions |
| A8 | Direction consistency | All 4 directions (down, up, left, right) depict the same character |
| A9 | Left-right symmetry | Right-facing frames are exact horizontal mirrors of left-facing frames |
| A10 | 2x speed test | Walk cycle still looks correct at 2x game speed |
| A11 | 4x speed test | Walk cycle still looks correct at 4x game speed (may lose some detail, but no strobing or artifacts) |

### 12.4 Uniqueness Checks

| # | Check | Pass Criteria |
|---|-------|--------------|
| U1 | Protagonist vs. NPCs | The protagonist is visually distinct from all NPCs in the starting village |
| U2 | Key NPC vs. key NPC | Every key NPC in a world has a unique silhouette (fill all characters with solid black and compare) |
| U3 | Character vs. monster | No character sprite can be confused with a monster field sprite at 1x scale |
| U4 | Mob NPC variety | In any scene with 3+ mob NPCs, at least 2 visual differences are present (color, hat, tool) |
| U5 | Cross-world consistency | The same named NPC looks identical in every world they appear in (traveling NPCs) |

### 12.5 Age and Role Checks (Protagonist-Specific)

| # | Check | Pass Criteria |
|---|-------|--------------|
| R1 | Age impression (45) | The protagonist does NOT look like a teenager or young adult. The stocky build and grey hair suggest middle age |
| R2 | Age impression (not elderly) | The protagonist does NOT look elderly. No hunched posture, no cane, no frail frame |
| R3 | Occupation impression | The protagonist looks like they work outdoors with animals. Work clothes, practical build, no luxury |
| R4 | Civilian impression | The protagonist looks like a civilian, not a warrior. No armor, no weapon, no heroic silhouette |
| R5 | Gender clarity | Male and female variants are distinguishable by silhouette (hair shape, shoulder width, body taper) |
| R6 | Customization validity | All 96 customization variants (2 × 4 × 3 × 4) pass checks D1-D11 without palette conflicts |
| R7 | Grey hair visibility | The 1-2 greying pixels at the temples are visible at 2x zoom and do not merge with surrounding colors |
| R8 | NPC Elder test | The protagonist (45) and the village elder (70s) are clearly different ages by silhouette and build |

### 12.6 Review Workflow

1. **Self-review**: The artist/AI operator runs through all applicable checks from 12.1-12.5 before submitting
2. **Peer review**: A second team member reviews the sprite at 1x, 2x, and 8x scale
3. **In-context test**: The sprite is placed on the target world's tileset at 1x resolution (160x144 screen) and evaluated for readability
4. **Batch uniqueness test**: All key NPCs for a world are displayed simultaneously at 1x scale. Each must be identifiable
5. **Walk cycle test**: The walk animation is played in the game engine (or Aseprite preview) at 1x and 2x speed
6. **Palette audit**: `palette_remap.py --check` confirms master palette compliance and reports any non-compliant pixels

---

## Appendix A: Quick Reference — Protagonist Pixel Dimensions

| Measurement | Value |
|-------------|-------|
| Canvas | 16x16 px |
| Visible height | 14 px (rows 1-14) |
| Head height | 6 px (rows 1-6) |
| Body height | 4 px (rows 7-10) |
| Leg height | 4 px (rows 11-14) |
| Shoulder width (male) | 10 px (incl. outline) |
| Shoulder width (female) | 9 px (incl. outline) |
| Head width | 9 px (incl. outline) |
| Eye position | Row 4, 1px each |
| Belt position | Row 9 |
| Ground contact | Row 14 |
| Edge clearance | 1 px all sides (rows 0, 15, cols 0, 15) |
| Opaque pixel count | ~100-110 |
| Color budget | 6-7 |
| Walk frames | 8 (2 per direction × 4 directions) |
| Idle frame | down_f1 |
| Frame timing (1x speed) | 250ms per frame |

## Appendix B: Quick Reference — NPC Tier Comparison

| Property | Key NPC | Minor NPC | Mob NPC |
|----------|---------|-----------|---------|
| Named | Yes | Yes | No |
| Story role | Major | Minor | None |
| Colors | 5-6 | 4-5 | 3-4 |
| Walk directions | 4 | 2 (down + left) | 1-2 (down, optional left) |
| Walk frames | 8 | 4 | 1-2 |
| Unique silhouette | Required | Preferred | Template-based |
| Authored frames | 6 (down×2, left×2, up×2; right = flip left) | 4 (down×2, left×2; right = flip left) | 1-2 (down×1, optional left×1) |
| World-specific variation | Full palette + headwear + accessory | Palette + headwear | Palette swap only |

## Appendix C: Quick Reference — Color Role Allocation by Type

| Role | Protagonist (7) | Key NPC (6) | Key NPC (5) | Minor NPC (5) | Minor NPC (4) | Mob NPC (4) | Mob NPC (3) |
|------|-----------------|-------------|-------------|---------------|---------------|-------------|-------------|
| 1: Outline | Black | Black | Black | Black | Black | Black | Black |
| 2: Clothing base | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| 3: Clothing shadow | Yes | Yes | Yes | Yes | Omit | Yes | Omit |
| 4: Skin tone | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| 5: Hair color | Yes | Yes | = Outline | Yes | Yes | = Outline | = Outline |
| 6: Accent | Yes | Yes | Yes | Yes | Omit | Omit | Omit |
| 7: Skin shadow | Yes | Omit | Omit | Omit | Omit | Omit | Omit |

"= Outline" means the hair is rendered using the outline color (black), saving one palette slot. This is acceptable for dark-haired characters and required for characters at the minimum color budget.

"Omit" means the role is not used. Clothing shadow is omitted at low budgets (folds are not shaded; the clothing is a single flat color). Accent is omitted when no belt, tool, or secondary clothing color is needed.

## Appendix D: Sprite Sheet Reference Diagram

```
┌────────┬────────┬────────┬────────┐
│ down   │ left   │ right  │ up     │
│ f1     │ f1     │ f1     │ f1     │
│ 16x16  │ 16x16  │ 16x16  │ 16x16  │
├────────┼────────┼────────┼────────┤
│ down   │ left   │ right  │ up     │
│ f2     │ f2     │ f2     │ f2     │
│ 16x16  │ 16x16  │ 16x16  │ 16x16  │
└────────┴────────┴────────┴────────┘
Total sheet size: 64x32 pixels
```

Frame order in sheet (left to right, top to bottom):
1. down_f1 (idle frame)
2. left_f1
3. right_f1 (horizontal flip of left_f1)
4. up_f1
5. down_f2
6. left_f2
7. right_f2 (horizontal flip of left_f2)
8. up_f2
