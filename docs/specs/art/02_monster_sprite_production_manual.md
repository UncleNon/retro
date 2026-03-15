# 02. Monster Sprite Production Manual

> **Status**: Draft v1.0
> **Last Updated**: 2026-03-15
> **References**:
> - `docs/specs/art/01_style_bible.md`
> - `docs/requirements/04_monster_design.md`
> - `docs/requirements/08_art_pipeline.md`
> - `docs/specs/content/06_monster_taxonomy_and_motif_rules.md`
> - `docs/specs/content/01_vertical_slice_monsters.md`

---

## Purpose

This document is the **single definitive reference** for producing all 400 monster sprites. Every pixel-level decision — canvas size, outline treatment, color budget, silhouette composition, eye placement, animation frames, motif visualization, file naming, quality gates — is specified here in full. No external document is required to resolve an ambiguity. Any artist, any AI tool operator, any reviewer can use this manual alone to produce or evaluate a monster sprite that is consistent with every other sprite in the game.

This manual does not replace the Style Bible (`01_style_bible.md`). It extends it with exhaustive production-level detail specific to monster sprites.

---

## 1. Canvas and Output Specifications

### 1.1 Canvas Sizes

Every monster sprite exists in multiple canvas sizes depending on its usage context. The canvas size is determined by the monster's rank (for battle sprites) or is fixed (for field, menu, and codex sprites).

#### Battle Sprite Canvas

| Rank | Canvas Width (px) | Canvas Height (px) | Total Pixels |
|------|-------------------|---------------------|--------------|
| E | 24 | 24 | 576 |
| D | 32 | 32 | 1024 |
| C | 32 | 32 | 1024 |
| B | 48 | 48 | 2304 |
| A | 48 | 48 | 2304 |
| S | 56 | 56 | 3136 |

The canvas is always square. There are no rectangular battle sprite canvases.

#### Field Sprite Canvas

| Rank | Canvas Width (px) | Canvas Height (px) |
|------|-------------------|---------------------|
| E | 16 | 16 |
| D | 16 | 16 |
| C | 16 | 16 |
| B | 16 | 16 |
| A | 16 | 16 |
| S | 16 | 16 |

All ranks use 16x16 for field sprites. There are no exceptions. S-rank monsters may have special field presentation effects (screen shake, palette flash), but the sprite itself is 16x16.

#### Menu Icon Canvas

| Usage | Canvas Width (px) | Canvas Height (px) |
|-------|-------------------|---------------------|
| Party list icon | 16 | 16 |
| Breeding preview icon | 16 | 16 |
| Skill tree header icon | 16 | 16 |
| Status screen icon | 16 | 16 |
| Shop/trade preview icon | 16 | 16 |

Menu icons are always 16x16. They are typically identical to or derived from the field sprite's front-facing idle frame.

#### Codex/Gallery Canvas

| Usage | Canvas Width (px) | Canvas Height (px) |
|-------|-------------------|---------------------|
| Codex full view | 64 | 64 |
| Gallery display | 64 | 64 |

The codex canvas is 64x64. This is an enlarged rendering for detailed viewing in the monster codex and gallery screens, if implemented. The codex sprite is NOT a simple upscale of the battle sprite. It is a redrawn version at higher resolution that preserves the same silhouette, palette, and design language but allows more interior detail.

If the codex/gallery feature is not implemented in the initial release, codex sprites are deferred. Battle and field sprites are always required.

#### Canvas Fill Rules

The creature fills the canvas area. There is no fixed margin around the creature. However, the creature must not touch the absolute pixel edge of the canvas on any side. A minimum of 1 pixel of transparent space must exist between the creature's outermost pixel and the canvas edge on all four sides.

This means:
- On a 24x24 canvas, the maximum drawable area for the creature is 22x22 (pixels 1-22 on each axis, with pixels 0 and 23 being transparent border)
- On a 32x32 canvas, the maximum drawable area is 30x30
- On a 48x48 canvas, the maximum drawable area is 46x46
- On a 56x56 canvas, the maximum drawable area is 54x54
- On a 16x16 canvas, the maximum drawable area is 14x14

### 1.2 File Format

#### Source Files

- Format: `.aseprite` (Aseprite native format)
- Layers must be preserved in the source file
- Required layers (minimum):
  - `outline` — the 1px outline of the creature
  - `fill` — the interior color fills
  - `shadow` — the shadow tone fills
  - `accent` — accent color details, accessories, markings
  - `eyes` — eye details (separating eyes allows easy expression changes)
- Optional layers:
  - `highlight` — bright highlight pixels
  - `accessory` — tags, ropes, seals, stamps
  - `taboo_mark` — tower/gate/taboo visual element
- Animation frames are stored as Aseprite frames within the same file
- Tags in Aseprite must be used to label animation sequences: `idle`, `attack` (S-rank only), `field_down`, `field_up`, `field_left`, `field_right`

#### Export Files

- Format: `.png`
- Color mode: indexed color with transparency
- Transparency: alpha channel, fully transparent background
- Compression: maximum PNG compression (lossless)
- No interlacing
- No embedded color profiles
- No metadata chunks beyond essential PNG headers

#### File Naming Convention

The naming convention is:

```
mon_{id}_{slug}_{usage}_{size}.png
```

Each component:

| Component | Format | Description | Example |
|-----------|--------|-------------|---------|
| `mon` | literal | Fixed prefix for all monster sprites | `mon` |
| `{id}` | 3-digit zero-padded integer | Monster ID number from the registry | `001`, `042`, `400` |
| `{slug}` | lowercase ASCII, underscores for spaces | Romanized short name of the monster | `mokkeda`, `tagututsuki`, `shimeri_gasa` |
| `{usage}` | one of: `battle`, `field`, `menu`, `codex` | Which canvas/context this sprite is for | `battle` |
| `{size}` | integer, pixel width | Canvas width in pixels | `24`, `32`, `48`, `56`, `16`, `64` |

Full examples:

```
mon_001_mokkeda_battle_24.png
mon_001_mokkeda_field_16.png
mon_001_mokkeda_menu_16.png
mon_001_mokkeda_codex_64.png
mon_005_mayoi_kakashi_battle_32.png
mon_005_mayoi_kakashi_field_16.png
mon_010_toumorino_ko_battle_32.png
mon_010_toumorino_ko_field_16.png
mon_400_final_monster_battle_56.png
```

For animation sprite sheets (multiple frames in a single file):

```
mon_{id}_{slug}_{usage}_{size}_sheet.png
```

Example:
```
mon_001_mokkeda_battle_24_sheet.png
mon_001_mokkeda_field_16_sheet.png
```

Sprite sheet layout:
- Battle idle: 2 frames side by side horizontally (frame 1 left, frame 2 right)
- Battle attack (S-rank): 3 frames side by side horizontally
- Field: 8 frames in a 4x2 grid (4 directions across, 2 frames per direction down)
  - Row 1: down_1, left_1, right_1, up_1
  - Row 2: down_2, left_2, right_2, up_2

For individual frame exports:

```
mon_{id}_{slug}_{usage}_{size}_f{frame}.png
```

Example:
```
mon_001_mokkeda_battle_24_f1.png
mon_001_mokkeda_battle_24_f2.png
```

### 1.3 Background

Every monster sprite has a fully transparent background. There are no exceptions to this rule.

Specific prohibitions:
- No solid color background fill
- No gradient background
- No ground line drawn beneath the creature
- No shadow blob or drop shadow beneath the creature
- No environmental elements (grass, rocks, clouds, particles)
- No decorative border or frame around the creature
- No glow or aura effect extending into the background
- No partial transparency (semi-transparent pixels) in the background area — every pixel is either fully opaque (part of the creature) or fully transparent (background)

The only pixels that exist in the file are the pixels that compose the creature itself.

### 1.4 Orientation and Pose

#### Default Facing Direction

All battle sprites face LEFT by default. The creature's front/face points toward the left side of the canvas. In-game, the player's monsters appear on the left side of the battle screen facing right (sprites are flipped horizontally by the engine), and enemy monsters appear on the right side facing left (using the default sprite orientation).

Field sprites have four directional frames (down, left, right, up). The left-facing frame is the canonical direction. The right-facing frame may be created by horizontally flipping the left-facing frame, or it may be drawn separately if the creature has asymmetric features that would look wrong when flipped.

#### Default Pose Type

The default pose is an **idle standing** pose. The creature is not attacking, not running, not jumping, not sleeping, not celebrating. It is simply present — standing, hovering, or resting in its natural at-rest position.

Specific pose rules:
- The creature should appear alert but not tense
- No action lines, motion blur, or speed indicators
- No open mouths mid-roar or mid-attack
- No raised weapons or extended claws in strike position
- No dramatic wind-blown effects on fur, feathers, or cloth

#### Viewing Angle

The viewing angle is **3/4 front-facing**, slightly angled. This means:
- The creature is not in pure profile (side view)
- The creature is not in pure frontal view (facing directly at the camera)
- The creature is turned approximately 30-45 degrees from frontal, so that both the front face and one side of the body are visible
- This angle maximizes the amount of visual information visible in a small sprite: the viewer can see the face, one full side of the body, and part of the other side

#### Grounding

For grounded creatures (beasts, plants, materials, most undead, most dragons, most divine):
- The creature's feet, base, roots, or lowest contact point sits on an invisible ground line
- This ground line is located at approximately 85-90% of the canvas height from the top
- On a 24x24 canvas, the ground line is at approximately pixel row 20-22 (counting from 0 at top)
- On a 32x32 canvas, the ground line is at approximately pixel row 27-29
- On a 48x48 canvas, the ground line is at approximately pixel row 40-43
- On a 56x56 canvas, the ground line is at approximately pixel row 47-50
- On a 16x16 canvas (field), the ground line is at approximately pixel row 13-14

For flying or floating creatures (some birds, some magic, some divine):
- The creature hovers with its lowest point at approximately 60-70% of canvas height from the top
- On a 24x24 canvas, hover point is at approximately pixel row 14-17
- On a 32x32 canvas, hover point is at approximately pixel row 19-22
- On a 48x48 canvas, hover point is at approximately pixel row 29-34
- On a 56x56 canvas, hover point is at approximately pixel row 34-39
- There must be visible empty space between the creature's lowest point and the bottom of the canvas, to communicate that the creature is airborne
- No shadow blob is drawn on the ground below

For creatures that cling, crawl, or have unusual postures (some plants, some materials, serpentine shapes):
- The creature's center of mass should be in the lower half of the canvas
- The creature should still appear grounded and heavy, not floating
- If the creature wraps around or clings to an implied surface, the surface itself is not drawn — only the creature is rendered

---

## 2. Outline Rules

### 2.1 Thickness

Every outline in every monster sprite is exactly **1 pixel wide**. There are no exceptions.

This applies to:
- The outer contour of the entire creature
- Major internal division lines (head from body, limb from torso, wing from back)
- Facial feature lines (eye outlines, mouth lines, nostril dots)
- Accessory outlines (tags, ropes, seals, collars)
- Horn, spine, and tail outlines
- Claw and tooth outlines (when visible)

Prohibitions:
- No 2px outlines anywhere on any sprite at any rank
- No variable-thickness outlines (thicker at bottom, thinner at top)
- No outlines that disappear and reappear along the same edge
- No broken or dotted outlines
- No double outlines (two parallel 1px lines)

### 2.2 Outline Color

The outline color is the **darkest color in the sprite's palette**.

Default: pure black `#000000`

For most creatures, pure black is the correct choice. However, for creatures whose body palette is already very dark, pure black may not provide enough contrast. In these cases:

| Creature Type | Outline Color Alternative | When to Use |
|---------------|--------------------------|-------------|
| Shadow/void creatures | Dark purple (`#1a0a2e` range) | When the body is predominantly black or near-black |
| Deep water creatures | Dark navy (`#0a0a2e` range) | When the body is very dark blue or black |
| Charcoal/ash creatures | Dark warm grey (`#1a1a14` range) | When the body is soot-black with warm undertones |
| All other creatures | Pure black `#000000` | Default for all standard creatures |

The outline color is **consistent within a single sprite**. Every outline pixel in one sprite uses the same color. You do not mix black outlines with dark purple outlines on the same creature.

The outline color counts as one of the sprite's palette colors (included in the color budget).

### 2.3 Where Outlines Are Applied

Outlines are drawn in the following locations:

**Outer contour**: A complete, unbroken 1px outline surrounds the entire creature. Every pixel on the outermost edge of the creature is an outline pixel. There are no gaps in the outer contour.

**Head-to-body separation**: Where the head meets the body/neck, a 1px line separates them if they are visually distinct masses. If the head flows smoothly into the body with no clear boundary (as in some slime or serpentine shapes), this line may be omitted.

**Limb separation**: Where limbs (legs, arms, wings, tails) attach to the body, a 1px line defines the boundary. This helps the viewer parse the creature's anatomy at small sizes.

**Facial features**: Eyes are outlined or defined with outline-color pixels. Mouth, if visible, uses a 1px line. Nostrils, if present, are 1px dots of outline color.

**Accessories**: Tags, ropes, collars, seals, stamps, and other attached objects have their own 1px outline where they overlap the body or extend beyond it.

**Horn, spine, antler, and claw edges**: These protrusions are fully outlined on their outer edges.

**Wing edges**: The outer edge of wings (folded or extended) has a 1px outline.

### 2.4 Where Outlines Are NOT Applied

Outlines are NOT drawn in the following locations:

**Inside flat color fills**: If a region of the body is filled with a single color, no outline is drawn within that region.

**Between shading tones**: The boundary between the base color and the shadow tone of the same body part does NOT have an outline. The color change itself communicates the shading boundary.

**Texture patterns**: Fur texture, scale patterns, feather barbs, bark grain, and similar surface details are communicated through color changes, not through outline-color lines drawn on the surface. Individual fur strands are never drawn. Individual scales are never outlined (scale impression is created by alternating color blocks).

**Between closely related color zones**: If two adjacent fill colors are close in value (for example, a body base and a slightly different belly color), no outline separates them. The color difference alone communicates the zone boundary.

**Subtle anatomical details at low ranks**: On E-rank and D-rank sprites, small details like individual toes, ear canals, or nostril flares should not be outlined. They are implied through color placement.

### 2.5 Corner Treatment

All corners and edges follow strict pixel art rules:

**90-degree corners**: Sharp right-angle corners are the default. No anti-aliased softening of corners.

**Diagonal lines**: Diagonal edges use clean stairstepping. Acceptable stair patterns:
- 1:1 ratio (one pixel right, one pixel down) for 45-degree diagonals
- 2:1 ratio (two pixels right, one pixel down) for shallow diagonals
- 1:2 ratio (one pixel right, two pixels down) for steep diagonals
- Consistent ratio along a single edge — do not mix 1:1 and 2:1 on the same line segment

**Prohibited corner/edge treatments**:
- Anti-aliased pixels (semi-transparent pixels at corners to simulate smoothness)
- Rounded corners using 2x2 or 3x3 pixel clusters
- Jagged diagonals with inconsistent step ratios (e.g., 1-1-2-1-1-3-1)
- Single-pixel bumps on otherwise straight lines (orphan pixels)
- Automatic smoothing or interpolation of any kind

**Curve representation**: Curves are represented by stairstepping with gradually changing ratios. A circle on a 24x24 canvas, for example, would use a sequence like: horizontal run of 4px, step, run of 2px, step, run of 1px, step, vertical run of 3px, and mirror. The key is that each run-length in the sequence changes by at most 1 from the previous run, creating a visually smooth curve at pixel level.

---

## 3. Color and Palette Rules

### 3.1 Master Palette

The project uses a master palette defined in `tools/palette-remap/master_palette.hex`. This file contains 32 colors that represent the full color space available to the game, inspired by Game Boy Color hardware limitations.

All finished sprites MUST use only colors from this master palette.

**Workflow**: During AI generation and initial drafting, arbitrary colors may be used. After the draft is complete, the `palette_remap.py` tool normalizes all colors to their nearest master palette equivalents. After remapping, the artist reviews the result and makes manual corrections in Aseprite if the automatic mapping produced poor results (for example, if two visually distinct colors mapped to the same palette entry).

The master palette is the single source of truth for color. If a desired color does not exist in the master palette, the nearest palette color must be used. The master palette is NOT modified to accommodate individual sprites.

### 3.2 Per-Sprite Color Budget

Each sprite has a maximum number of colors it may use, determined by the monster's rank. This count includes the outline color and the transparent background does NOT count as a color.

| Rank | Minimum Colors | Maximum Colors | Typical Colors | Reasoning |
|------|---------------|----------------|----------------|-----------|
| E | 4 | 5 | 4-5 | Simple, readable at 24x24, early-game visual simplicity |
| D | 5 | 6 | 5-6 | One additional accent allowed over E, slightly more detail |
| C | 6 | 7 | 6-7 | More detail surfaces, attribute markers visible |
| B | 7 | 8 | 7-8 | Complex design, multiple material types on one creature |
| A | 8 | 9 | 8-9 | High detail, multiple visual layers, presence and authority |
| S | 9 | 10 | 9-10 | Maximum complexity, boss presence, multiple distinct zones |

Color budget is a hard cap. A sprite must not exceed the maximum for its rank. Using fewer colors than the minimum suggests the sprite may lack sufficient visual detail for its rank.

### 3.3 Color Roles

Every sprite's palette is composed of colors serving specific roles. The roles are listed here in order of priority (role 1 must always be present, role 6 is only present at higher ranks).

#### Role 1: Outline (1 color, mandatory for all ranks)

This is the darkest value in the sprite. It defines the shape, separates body parts, and draws facial features. It is typically pure black `#000000` or a near-black alternative as specified in Section 2.2.

Usage: outer contour, major internal division lines, eye outlines, accessory outlines.

#### Role 2: Body Base (1 color, mandatory for all ranks)

This is the dominant fill color. It covers the largest area of the sprite. It is the creature's "personality color" — the color a player would use to describe the creature in one word ("the brown one," "the blue one").

Usage: the primary surface of the body, the default fill for the largest mass.

Selection guidance:
- Must have clear contrast against the outline color
- Must not be so bright that it overpowers other colors
- Should suggest the creature's material (fur, scales, stone, leaf, ectoplasm)

#### Role 3: Body Shadow (1 color, mandatory for all ranks)

This is one step darker than the body base. It creates the illusion of volume through two-tone cel shading. It is always the same hue family as the body base, just darker and possibly slightly more saturated.

Usage: bottom-right areas of masses (consistent with top-left lighting), undersides of limbs, behind protruding parts (behind horns relative to the light, under the jaw, inside the ear, under the belly).

Selection guidance:
- Must be visibly darker than body base when viewed at 1x scale
- Must be the same hue family (a brown body base gets a darker brown shadow, not a grey shadow)
- Must not be so dark that it merges with the outline color

#### Role 4: Accent (1 color, mandatory for all ranks)

This is a secondary color used for specific features that distinguish the creature. It is NOT the same hue family as the body base. It provides visual interest and communicates specific identity information.

Usage: secondary material (horns, claws, beak), markings (stripes, spots, brands), attribute indicator (fire-red accent, water-blue accent), accessories (tags, ropes, seals).

Selection guidance:
- Must contrast with both body base and body shadow
- Should relate to the creature's element/attribute, motif, or world context
- Should cover 10-25% of the sprite's filled area (not dominant, not invisible)

#### Role 5: Highlight (0-1 color, optional for E rank, expected for D and above)

This is the brightest value in the sprite. It represents the point of maximum light reflection. It is used sparingly — typically just a few pixels.

Usage: eye gleam (1 pixel in the upper-left of the eye, reflecting the light source), wet surface highlight on slime or amphibian creatures, metallic sheen on horns or armor, the single brightest point on a rounded form.

Selection guidance:
- Must be the lightest color in the sprite
- Typically white or near-white, or a very light tint of the body base
- Used in quantities of 1-4 pixels per application point (not as a fill)
- E-rank sprites may omit highlights entirely if the design is simple enough

#### Role 6: Detail Colors (0-2 colors, available for C rank and above)

These are additional colors beyond the core 5 roles. They allow higher-rank sprites to have more visual complexity — different materials, multiple accent zones, or secondary body regions with their own base/shadow pair.

Usage varies by creature:
- A second accent color for a different body region (wing color different from horn color)
- A secondary body region color (belly different from back)
- A specific color for a unique feature (glowing core, ceremonial marking, gate-pattern)
- The shadow tone for an accent color region (if the accent region is large enough to warrant its own shading)

Selection guidance:
- Each additional color must serve a clear, identifiable purpose
- Do not add colors for variety alone — each color must communicate something specific
- The sprite must still read clearly at 1x scale even with additional colors

### 3.4 Shading Method

The shading method for all monster sprites is **two-tone cel shading**. This means every colored region of the sprite uses at most two values: a base color and a shadow color.

#### Light Source

The light source is at the **top-left** of the canvas. This is consistent across ALL monster sprites, ALL field sprites, ALL menu icons, and ALL codex sprites. There are no exceptions.

This means:
- The top-left areas of each body mass receive the body base color (lit)
- The bottom-right areas of each body mass receive the body shadow color (in shadow)
- The left side of the creature is generally lighter than the right side
- The top of each protruding form is lighter than its underside
- Shadows are cast downward and to the right

#### Shadow Placement

Shadow (the darker tone) is placed in the following locations:
- The bottom-right quadrant of rounded body masses
- The underside of the jaw and chin
- The underside of the belly
- The inside/underside of limbs
- Behind protruding features (the body area directly behind a horn, behind a wing attachment point, behind an ear)
- Inside concave features (inside ear cups, inside mouth if visible, inside nostril)
- The ground-contact side of the creature (the bottom of feet, base of roots)

#### Prohibited Shading Techniques

The following shading techniques are **prohibited** on all monster sprites:

**Gradient fills**: No smooth transitions between colors. Every boundary between base and shadow is a sharp pixel-level edge.

**Dithering**: No checkerboard or regular alternating patterns of two colors to simulate a third color. Every pixel is fully one color.

**Pillow shading**: No shading that follows the outline of the shape equally on all sides, creating a "pillow" or "balloon" effect. The light has a direction (top-left), so the shadow distribution is asymmetric.

**Banding**: No parallel bands of different shades running along the outline. This occurs when the shadow follows the contour of the shape at a uniform distance, creating concentric bands. Instead, the shadow boundary should be determined by the 3D form of the creature relative to the light source.

**Three-tone or more shading**: No body region uses three or more values (e.g., highlight + base + shadow + deep shadow) on a single surface. Each surface is two-tone only. The highlight color (Role 5) is used as a point accent, not as a third shading tier across surfaces.

**Ambient occlusion simulation**: No darkening at every junction and crease. Shadow placement is determined by the single top-left light source, not by proximity to other geometry.

### 3.5 Color Temperature by World Zone

Different world zones in the game have different atmospheric palettes. Creatures native to these zones should tend toward color temperatures that feel natural in their home environment, though this is a tendency, not an absolute rule.

| World Zone | Color Temperature | Dominant Tones | Accent Tendencies |
|------------|-------------------|----------------|-------------------|
| Village / pastoral areas | Warm | Brown, tan, muted green, straw yellow, warm grey, dried earth | Copper, burnt sienna, dull red |
| Tower-adjacent areas | Cool | Grey-blue, bone white, cold silver, slate grey, pale ash | Cold gold, steel blue, ice white |
| Wild / frontier areas | Mixed warm-cool | Muted forest green, mossy brown, slate, storm grey | Amber, moss yellow, faded teal |
| Deep gate / boundary areas | Cold with warm accent | Cold purple, bone grey, muted blood-red, dark teal | Pale gold, faint star-white, bitter amber |
| Astral / observatory areas | Cool-neutral | Night blue, silver, black, pale violet | Star-white, cold gold, glass-clear blue |
| Funerary / mourning areas | Muted warm | Ash grey, dust brown, wilted green, faded cloth-white | Incense amber, dried flower pink, candle yellow |

Individual creatures may deviate from their home zone's temperature if their motif demands it. A fire-element creature in a cold tower zone will still have warm reds. The zone temperature guides the "non-motif" colors — the body base, the shadow tone, the general feeling of the creature's palette.

### 3.6 Transparency and Special Effects

All pixels in a monster sprite are either **fully opaque** (alpha = 255) or **fully transparent** (alpha = 0). There are no semi-transparent pixels anywhere in any sprite.

Special visual effects that might normally use transparency are instead communicated through color and composition:

**Translucent bodies (slime, ectoplasm, jelly)**: Use a lighter shade of the body base as a "see-through" indicator. Place 1-2 pixels of a contrasting color inside the body to suggest objects visible through the translucent form. The body outline remains fully opaque.

**Glowing elements (magic cores, charged horns, ritual marks)**: Use the brightest available palette color, placed as 1-3 pixel highlights. Do not use a gradient glow. Do not use semi-transparent aura pixels. The glow is suggested by the brightness contrast between the glowing pixels and their surroundings.

**Shadow or ghost creatures**: Use a darker overall palette with ONE bright accent color (typically the eye or a core/heart). The creature's body is fully opaque in the sprite, even if it is narratively incorporeal. The ghostly feeling comes from the dark palette and the bright accent, not from actual transparency.

**Reflective surfaces (metallic horns, wet skin, ice)**: Use a single bright highlight pixel (or 2-3 pixels for larger surfaces) placed at the point of maximum light reflection (upper-left of the surface). The reflection is a sharp bright point, not a smooth specular spread.

**Fire, smoke, or particle effects**: These are NOT part of the monster sprite. If a creature is on fire or emitting smoke, the fire/smoke effect is a separate game effect layered by the engine. The monster sprite itself shows only the creature's body.

---

## 4. Silhouette and Composition Rules

### 4.1 Silhouette Readability Test

Every monster sprite must pass the silhouette readability test before approval.

**The test**: Fill every opaque pixel of the sprite with a single solid color (e.g., pure black). Display the result at 1x scale (native resolution, no zoom). Show the silhouette to a viewer who has not seen the sprite before. Ask: "What family does this creature belong to?" If the viewer cannot narrow it down to 1-2 possible families within 3 seconds, the silhouette needs redesign.

**Why this matters**: In battle, the player needs to instantly recognize what they are facing. At small sprite sizes, interior detail is secondary — the overall shape is the primary recognition cue. If two creatures from different families have similar silhouettes, at least one needs to be redesigned.

**How to apply during production**: After completing the outline layer of a new sprite, hide all other layers and evaluate the outline alone. If the outline reads as a blob without family identity, revise the outline before proceeding to fill and shading.

### 4.2 Three-Mass Rule

Every creature's visual composition is built from **three major shape masses**. This is a hard rule, not a guideline.

The three masses are:
1. **Head mass**: The head, face, and any features attached to the head (horns, antlers, ears, crests)
2. **Body mass**: The torso, the central bulk of the creature
3. **Limb/appendage mass**: The legs, tail, wings, tendrils, roots, or other extending features treated as a visual group

Every creature's design must be decomposable into these three masses. When squinting at the sprite (or viewing at 1x scale from arm's length), the three masses should be immediately apparent as distinct visual chunks.

**Additional detail sits ON TOP of these three masses**. Small features (markings, tags, spines, small accessories) are layered onto the three primary masses. They do not create additional independent masses floating in space.

**Exceptions and clarifications**:
- A serpentine creature (like a snake or eel) may have its three masses as: head + front body coil + rear body coil/tail
- A round creature (like a slime) may have its three masses as: body (dominant) + face features (eyes/mouth region) + a single appendage or surface detail group
- A floating creature may have its three masses as: head/face + body + trailing element (tail, cape, tendrils)
- No creature has fewer than 2 clearly distinct masses
- No creature has more than 4 clearly distinct masses at the silhouette level

### 4.3 Canvas Fill Percentage

The creature must fill a target percentage of the canvas area. This ensures the creature feels appropriately sized for its rank — small enough to leave breathing room, large enough to have visual presence.

| Rank | Minimum Fill % | Maximum Fill % | Target Fill % |
|------|---------------|----------------|---------------|
| E | 65% | 75% | 70% |
| D | 70% | 80% | 75% |
| C | 70% | 80% | 75% |
| B | 75% | 85% | 80% |
| A | 75% | 85% | 80% |
| S | 80% | 90% | 85% |

**How to measure**: Count the number of opaque pixels in the sprite. Divide by the total canvas pixel count. The result is the fill percentage.

Example: A 24x24 E-rank sprite has 576 total pixels. At 70% fill, the creature uses approximately 403 opaque pixels. At 65%, approximately 374 pixels. At 75%, approximately 432 pixels.

**Why this matters**: Underfilled sprites look lost on their canvas and appear weaker than intended. Overfilled sprites feel cramped and lack visual clarity. The fill percentage also creates a visual rank hierarchy — S-rank creatures dominate their canvas, while E-rank creatures sit smaller within theirs, even though E-rank canvases are physically smaller.

### 4.4 Centering and Positioning

#### Horizontal Centering

The creature is **centered horizontally** on the canvas. The visual center of mass of the creature should align with the horizontal center of the canvas (pixel column width/2).

"Visual center of mass" means: if you drew a vertical line through the point where the left half and right half of the creature have equal visual weight, that line should be at or within 1-2 pixels of the canvas center.

Slight asymmetry is acceptable (a tail extending further to one side, one wing slightly more visible than the other), but the creature should not appear offset to one side.

#### Vertical Positioning

The creature is NOT centered vertically. The creature sits in the **lower portion** of the canvas, with its base/feet at approximately 85-90% of the canvas height.

This means:
- There is more empty space above the creature than below it
- The empty space above creates a sense of headroom
- The small amount of empty space below creates a sense of grounding

Specific pixel positions for the ground line (the y-coordinate of the creature's lowest pixel):

| Canvas Size | Ground Line Y (from top, 0-indexed) | Acceptable Range |
|-------------|--------------------------------------|-----------------|
| 16x16 | 14 | 13-14 |
| 24x24 | 21 | 20-22 |
| 32x32 | 28 | 27-29 |
| 48x48 | 42 | 40-43 |
| 56x56 | 49 | 47-50 |

#### Edge Clearance

No creature touches the absolute edge of the canvas on any side. Minimum clearance:

| Canvas Size | Minimum Edge Clearance (pixels) |
|-------------|--------------------------------|
| 16x16 | 1 |
| 24x24 | 1 |
| 32x32 | 1 |
| 48x48 | 1 |
| 56x56 | 1 |

This means pixel row 0, pixel row (height-1), pixel column 0, and pixel column (width-1) must all be fully transparent.

### 4.5 Family-Specific Silhouette Guidance

Each of the 9 monster families has a characteristic silhouette language. These rules ensure that creatures within the same family share visual kinship, while creatures across families are distinguishable by shape alone.

---

#### Family: beast

**Core silhouette principle**: Four-limbed stance with visible weight on the legs. The creature looks like it belongs on the ground, has mass, and obeys gravity.

**Typical mass distribution**:
- Mass 1 (head): Smaller than the body mass. Positioned at the front-upper area of the silhouette. May include horns, ears, or a mane as part of the head mass.
- Mass 2 (body): The largest mass. Rounded or muscular, suggesting flesh and bone under the surface. Positioned centrally.
- Mass 3 (limbs + tail): Legs plant firmly on the ground line. Tail extends from the rear, acting as a visual counterbalance to the head. The tail is thick enough to read as a mass, not a thin line.

**Proportional guidelines**:
- Head is 20-30% of the total creature height
- Body is 40-50% of the total creature height
- Legs are 20-30% of the total creature height (from belly to ground line)
- Tail length is 30-60% of the body length

**Stance**:
- Weight is distributed on all four legs (or two legs for bipedal beasts)
- Legs are slightly apart, not pressed together
- The creature looks stable, not about to tip over
- Front legs may be slightly forward of center, rear legs slightly behind — not all four in a vertical line

**Required visual elements**:
- Visible legs with clear ground contact
- A body mass that suggests muscle, fat, or fur volume
- At least one feature that distinguishes it from a real-world animal (horn anomaly, material fusion, mark, size distortion)

**Forbidden**:
- Stick-thin legs that do not suggest weight-bearing
- Floating pose (feet off the ground without being a flying creature)
- Pure profile view with all four legs in a line (results in flat, lifeless silhouette)
- Exact copy of a real-world animal silhouette (must be transformed)
- Head larger than body (this reads as cute mascot, not beast)

**Key readability cue**: The stance. A beast is identified by how it stands — the weight, the groundedness, the four-point contact.

---

#### Family: bird

**Core silhouette principle**: Vertical orientation with the head/beak at the top and tail/feet at the bottom. The body reads as upright, even if the creature is perched.

**Typical mass distribution**:
- Mass 1 (head + beak): Positioned at the top. The beak is a critical identifying feature — it must be visible in silhouette. Head can be round or angular depending on the species motif.
- Mass 2 (body + wings): The central mass. Wings may be folded against the body (default idle pose) or one wing may be slightly extended for visual interest. Body is compact and dense.
- Mass 3 (tail + feet): Positioned at the bottom. Tail feathers extend behind or below. Feet grip the ground line or a perch (implied, not drawn).

**Proportional guidelines**:
- Head (including beak) is 25-35% of the total creature height
- Body (including folded wings) is 40-50% of the total creature height
- Tail and feet are 15-25% of the total creature height
- Beak length is 30-60% of the head diameter

**Stance**:
- Upright perched stance is the default
- The bird faces left, with the beak pointing left
- Weight rests on the feet at the ground line
- The body has a slight forward lean (birds lean forward on their feet)

**Wing representation**:
- Folded wings are the default for idle pose
- Folded wings appear as a shaped mass overlapping the body from behind
- One wing may be slightly raised or extended for asymmetry and visual interest (but not in a flying pose)
- Wings are never fully outstretched in idle pose — that is an action pose reserved for attack frames

**Feather texture**:
- Feathers are NOT drawn as individual lines or barbs
- Feather texture is communicated through color blocks — large flat areas of slightly different colors suggest feather groupings
- Wing tips may have 2-3 pixel "finger" points to suggest flight feathers
- Tail feathers may have 1-2 defined shapes rather than a generic triangle

**Forbidden**:
- Horizontal flying pose with wings outstretched (this is an action pose, not idle)
- Generic bat wings (leathery, pointed — bat wings belong to dragon family or specific motifs, not birds)
- Ball-shaped body with a tiny beak (reads as mascot, not bird)
- No visible beak (the beak is the defining feature — without it, the silhouette becomes ambiguous)

**Key readability cue**: The vertical proportion and the beak. A bird is identified by its upright shape and the clear beak silhouette.

---

#### Family: plant

**Core silhouette principle**: Bottom-heavy, rooted or spreading base. The creature is connected to the ground, growing from it or resting on it with organic weight.

**Typical mass distribution**:
- Mass 1 (crown/top): Leaves, petals, spore cap, mushroom head, or flowering top. This is the most visually interesting part and draws the eye.
- Mass 2 (body/stem): The central structure. May be thick and trunk-like, thin and stalk-like, or bulbous and gourd-like. It connects the crown to the base.
- Mass 3 (base/roots): The widest part. Roots spreading on the ground, a broad base, trailing vines, or a spreading mycelium network. This grounds the creature and communicates immobility.

**Proportional guidelines**:
- Crown is 30-40% of the total creature height
- Body/stem is 30-40% of the total creature height
- Base/roots are 20-30% of the total creature height
- The widest point of the creature is at the bottom third, not the middle

**Shape language**:
- Organic, irregular edges are preferred over smooth geometric curves
- Asymmetry is expected — plants are not perfectly symmetrical
- Edges may be jagged (thorny), wavy (leafy), or lumpy (fungal)
- The creature's outline suggests living growth, not manufactured smoothness

**Face/eye placement**:
- Plant creatures may have NO visible face
- If eyes are present, they may be embedded in the body (peering out from within), located on the crown (mushroom cap with eye spots), or suggested by markings (leaf vein patterns that form eye shapes)
- If eyeless, the creature must have another focal point: a central marking, a glowing spore cluster, an opening that suggests a mouth, or an asymmetric shape that draws the eye

**Forbidden**:
- "Potted plant" look: a plant sitting in a geometric pot or container (the creature IS the plant, not a plant in a vessel)
- "Single flower on a stem" look: a thin vertical line with a flower on top (too simple, not enough mass)
- Perfectly symmetrical leaf arrangements (natural plants are asymmetric)
- Human face clearly drawn on a plant surface (faces should emerge organically, not be "painted on")

**Key readability cue**: Organic irregularity and rootedness. A plant is identified by its bottom-heavy shape, irregular organic edges, and connection to the ground.

---

#### Family: material

**Core silhouette principle**: Geometric or constructed feel. The creature looks assembled from recognizable objects or materials, with hard edges mixed with organic features that suggest it has come alive.

**Typical mass distribution**:
- Mass 1 (head/face zone): A face or awareness emerging from the object. Not a separate head attached to a body, but a region of the object where sentience is concentrated. Eyes peer from cracks, a mouth forms from an opening, or a glow emanates from within.
- Mass 2 (primary object body): The recognizable object or material that forms the creature's core. A bone cage, a stone slab, a tool handle, a pottery fragment, a woven basket frame. This is the largest mass.
- Mass 3 (appendages/fragments): Limbs formed from the material (stone legs, rope arms, handle-shaped appendages), attached fragments (coins, scraps, buttons caught in the structure), or trailing elements (chains, frayed edges, cracks).

**Proportional guidelines**:
- The "object" component is 50-70% of the total creature area
- Organic or animated features (eyes, limbs, mouth) are 20-30% of the total creature area
- Fragments, accessories, and trailing elements are 10-20% of the total creature area

**Shape language**:
- Hard edges, straight lines, and angular forms for the material component
- Contrasting organic curves where life emerges from the material
- The transition from dead material to living creature should feel gradual, not sudden — cracks where eyes appear, bends where joints form
- The creature's outline mixes geometric (straight lines, right angles) with organic (curves, irregular edges)

**Key design principle**: The face/awareness EMERGES from the object. It is not a face drawn ON a object. The object's own features (cracks, holes, surface texture) should suggest the face. A bone cage whose gaps form eyes is correct. A smooth pot with cartoon eyes painted on it is incorrect.

**Forbidden**:
- Simple object with a cartoon face drawn on its surface
- Objects that are too recognizable as a specific branded product
- Perfectly clean, undamaged objects (materials should show use, wear, age, history)
- Limbs that look like they were attached externally rather than growing from the material

**Key readability cue**: Hardness and assembled-ness. A material is identified by the geometric rigidity of its primary form and the contrast between dead material and living awareness.

---

#### Family: magic

**Core silhouette principle**: Floating or light-on-feet presence with repeating geometric patterns or visual symmetry. The creature looks like it barely belongs to the physical world.

**Typical mass distribution**:
- Mass 1 (core/face): A concentrated center of awareness. May be a distinct face/head, or a glowing core, or a geometric focal point. This is the visual anchor.
- Mass 2 (body/aura): The surrounding form. May be wispy, geometric, crystalline, or amorphous. It wraps around or extends from the core. Its boundary may be ambiguous — the creature's edges fade or fracture into patterns.
- Mass 3 (trailing/extending elements): Trailing wisps, orbiting fragments, geometric extensions, or repeating pattern elements that extend from the body. These give the silhouette its distinctive complexity.

**Proportional guidelines**:
- Core is 20-30% of the total creature area
- Body/aura is 40-50% of the total creature area
- Trailing elements are 20-30% of the total creature area
- The creature may not have clearly defined proportions — the boundary between body and trailing elements may be fluid

**Shape language**:
- Geometric patterns: triangles, circles, hexagons, repeating dot patterns, star shapes
- Symmetry elements: bilateral symmetry, radial symmetry, or near-symmetry with one deliberate break
- Light, airy edges: the outline may have thin extensions, single-pixel antennae, or delicate protrusions
- The creature may appear to hover or float even without explicit flying anatomy

**Stance**:
- Floating at 60-70% canvas height is the default
- If grounded, the creature should appear to barely touch the ground
- No strong gravitational pull — the creature should feel light

**Glow effects**:
- Bright pixel placement (Role 5 highlight color) suggests magical energy
- Glow is communicated through color contrast, not transparency or blur
- A single bright pixel surrounded by darker pixels reads as "glow" at small scales
- Maximum 3-5 bright highlight pixels per magic creature (more dilutes the effect)

**Forbidden**:
- Generic ghost orb: a simple circle with two dots for eyes (too simple, no identity)
- Generic wizard hat: a triangle on top of a blob (too derivative, reads as "costume" not "creature")
- Flame or lightning bolt as the entire creature (these are effects, not creatures)
- Excessive geometric complexity that becomes noise at 1x scale

**Key readability cue**: Pattern, lightness, or intentional asymmetry. A magic creature is identified by its geometric or pattern-based visual language and its apparent weightlessness.

---

#### Family: undead

**Core silhouette principle**: Decay, missing parts, exposed internal structure. The creature is based on another family's form but damaged, corroded, or incompletely present.

**Typical mass distribution**:
- Mass 1 (head/skull): The head often shows the most damage — hollow eye sockets, cracked cranium, missing jaw sections, exposed bone beneath surface. The head is the primary indicator of undeath.
- Mass 2 (body): The body may be partially intact or significantly deteriorated. Ribs may show through, chunks may be missing, wrappings may hold things together. The body is the largest mass but may have irregular edges where material has worn away.
- Mass 3 (limbs/remnants): Limbs may be incomplete (a leg ending in a stump, an arm that fades to nothing), trailing (burial wrappings, hanging sinew), or replaced (a bone limb where a flesh limb once was).

**Proportional guidelines**:
- The original creature's proportions should be recognizable (an undead beast still has beast proportions, an undead bird still has bird proportions)
- However, the proportions are distorted — areas of decay are sunken or missing, creating irregular asymmetry
- Missing parts should be 10-20% of the original form, not 50%+ (the creature must still be recognizable as a creature)

**Shape language**:
- Irregular, broken edges where material has decayed
- Holes and gaps in the silhouette (carefully placed to not destroy readability)
- Asymmetry from damage: one horn broken, one wing skeletal while the other retains feathers
- Wrapping or binding elements: cloth strips, rope, chains that hold the form together

**Color approach**:
- Dark overall palette (greys, dark purples, ash tones, bone white)
- ONE bright accent color for the point of remaining consciousness (typically the eyes — a dim red glow, a pale blue pinpoint, a sickly green spark)
- The bright accent is what makes the creature feel "still there" rather than merely dead

**Forbidden**:
- Generic zombie green: the cliche toxic green color that screams "zombie" without any specificity
- Cute skeleton: a clean, white, smiling skeleton with no decay or damage (this is a cartoon, not an undead creature)
- Excessive gore: exposed organs, dripping blood, graphic wounds (the GBC aesthetic limits this; decay should be suggested through shape and color, not graphic detail)
- Full-body transparency (ghosts are dark and solid in their sprite, not see-through)

**Key readability cue**: What is missing or broken. An undead creature is identified by the gaps, the asymmetry of damage, and the single point of lingering awareness.

---

#### Family: dragon

**Core silhouette principle**: Strong skeletal structure visible in silhouette, with defining features of horns, tail, and/or wings. The creature communicates weight, age, and physical authority.

**Typical mass distribution**:
- Mass 1 (head + horns): The head is large and angular, with a strong jawline visible in silhouette. Horns are a defining feature — their shape and direction are unique to each dragon. The head may be 25-35% of the total creature height.
- Mass 2 (body): Heavy, dense, low-slung. The body suggests thick scales, powerful muscles, and structural bone. The body is the largest mass, positioned low and wide.
- Mass 3 (tail + wings): The tail is thick and long, sweeping from the body as a major compositional element. If wings are present, they are folded in idle pose but their shape is visible as a mass behind the body. Tail and wings together form the third mass.

**Proportional guidelines**:
- Head (including horns) is 25-35% of the total creature height
- Body is 35-45% of the total creature height
- Tail extends 40-80% of the body length from the rear
- Wings (if present, folded) add 10-20% to the body width on one side
- Legs are thick and planted, 15-25% of the total creature height

**Shape language**:
- Angular, structural forms — the skeleton should be readable through the surface
- Sharp points at horns, jaw ridges, and tail tip
- Scale texture is communicated through color blocks, NOT through individual scale outlines
- The overall impression is of something ancient, heavy, and built to endure

**Stance**:
- Planted on the ground with all four limbs (if quadruped)
- Low center of gravity — the body is close to the ground, not elevated on long legs
- The head may be held level with the body or slightly raised — not lifted high in a roar pose
- Tail rests on or near the ground, not whipping in the air

**Forbidden**:
- Western dragon cliche: large outstretched wings, mouth open breathing fire, rearing up on hind legs (this is an action pose, and also extremely derivative)
- Cute baby dragon: round body, oversized head, stubby wings (reads as mascot, not dragon)
- Wyvern-only design: just a lizard with bat wings (needs more identity than wing attachment)
- Feathered serpent used directly without transformation (too recognizable as a specific mythological entity)

**Key readability cue**: Skeletal authority and weight. A dragon is identified by the visible strength of its frame, the presence of horns/tail, and the feeling that this creature has immovable mass.

---

#### Family: divine

**Core silhouette principle**: Stillness and symmetry in pose, with ritualistic or ceremonial visual elements. The creature communicates presence through restraint, not through size or aggression.

**Typical mass distribution**:
- Mass 1 (head/face): The face is the most intense part of the design. Eyes are the focal point. The head may have ceremonial elements (crowns, patterns, crests) that expand the head mass without making it physically large.
- Mass 2 (body): The body is composed, upright, and still. It may have ritual markings, geometric patterns, or architectural elements echoing the tower/gate motifs. The body feels constructed or ordained rather than biological.
- Mass 3 (base/grounding): The lower body, feet, or pedestal-like base. The creature stands with absolute stability. It does not shift, lean, or fidget. The base may incorporate stone, carved, or geometric patterns that connect to the tower architecture.

**Proportional guidelines**:
- Head (including ceremonial elements) is 25-35% of the total creature height
- Body is 40-50% of the total creature height
- Base is 15-25% of the total creature height
- The creature is vertically oriented (taller than wide) or perfectly balanced (equal width and height)

**Shape language**:
- Bilateral symmetry is the default (the left half mirrors the right half)
- Symmetry may be broken by ONE deliberate element (one eye different, one marking added, one crack)
- Geometric patterns: repeating lines, concentric forms, architectural arches, gate-like openings
- The creature feels carved or ordained rather than born

**Eyes**:
- Eyes are the most prominent feature of divine creatures
- They are larger (relative to body) than other families' eyes
- They may glow, reflect, or appear to look through the viewer
- At least one eye should have a highlight pixel (Role 5) to create the sense of intense gaze
- Divine creatures with multiple eyes should arrange them symmetrically

**Stance**:
- Perfectly still, perfectly balanced
- No leaning, shifting, or dynamic pose
- The creature appears to have been standing in this exact position for centuries
- Weight is evenly distributed
- The creature may incorporate tower/gate/pillar visual echoes (standing like a pillar, framed by arch-like features)

**Forbidden**:
- Generic angel wings: feathered wings extending from the back in a standard "angel" arrangement
- Halos: glowing circles above the head (too directly derived from Christian iconography)
- Pure white robed figure: a humanoid in white robes with generic divine trappings
- Aggressive divine pose: a divine creature in a smiting or judging pose (divine creatures in this game are still, not active)

**Key readability cue**: Stillness and gaze intensity. A divine creature is identified by its unmoving pose, its ceremonial/geometric elements, and the intensity of its eyes.

---

#### Family: slime

**Core silhouette principle**: Round or droplet base shape with surface variation. The creature is defined by its apparent softness and volume.

**Typical mass distribution**:
- Mass 1 (body): The dominant mass. Round, oval, or droplet-shaped. Accounts for 60-80% of the creature's total area. The surface may have bumps, ripples, or embedded objects.
- Mass 2 (face/expression zone): Eyes and/or mouth area. Located in the upper portion of the body mass. The face emerges from the body — it is not a separate head.
- Mass 3 (extensions): Pseudopods, drips, tendrils, absorbed objects protruding from the surface, or a flattened base spreading on the ground. These give the silhouette variety beyond a simple circle.

**Proportional guidelines**:
- The main body is 70-80% of the total creature area
- The face zone occupies 15-25% of the front surface of the body
- Extensions are 10-20% of the total creature area
- The creature is wider than it is tall (ratio approximately 1:0.8 to 1:1.2)

**Shape language**:
- Rounded edges, no sharp points (unless the slime has absorbed a sharp object)
- The outline suggests liquid or gel — smooth curves, no hard angles
- The creature's surface has visible texture: bubbles, ripples, absorbed objects, color variation
- The base of the creature spreads slightly where it contacts the ground (flattened by gravity)

**Color approach for translucency**:
- The body base color is lighter than other families' body bases, suggesting translucency
- Darker color blocks inside the body suggest depth and internal structure
- A highlight pixel on the upper-left surface suggests a wet, reflective surface
- If objects are absorbed, they appear as small shapes (1-3px) inside the body in a contrasting color

**Forbidden**:
- DQ-style exact smile drop shape: the specific teardrop shape with two dot eyes and a wide smile that is immediately recognizable as a Dragon Quest slime
- Perfect mathematical circle: the slime must have some organic variation in its outline, not a pixel-perfect circle
- Flat coloring with no surface interest: even a simple slime needs at least a highlight and a shadow to suggest volume
- Dry-looking surface: the slime should read as wet, soft, or gelatinous through its coloring

**Key readability cue**: Roundness and apparent softness. A slime is identified by its lack of rigid structure, its curved outline, and its apparent liquid or gel quality.

---

## 5. Eye Design Rules

### 5.1 Eye Size by Rank

Eye size scales with canvas size and rank, but eyes remain small relative to the creature's total body area. Eyes in pixel art are measured in total pixels (including outline pixels around the eye).

| Rank | Canvas Size | Eye Width (px) | Eye Height (px) | Pixels per Eye (total) |
|------|-------------|----------------|-----------------|----------------------|
| E | 24x24 | 1-2 | 1-2 | 1-4 |
| D | 32x32 | 2-3 | 2-3 | 4-9 |
| C | 32x32 | 2-4 | 2-4 | 4-16 |
| B | 48x48 | 3-5 | 3-5 | 9-25 |
| A | 48x48 | 4-6 | 4-6 | 16-36 |
| S | 56x56 | 4-6 | 4-6 | 16-36 |

These are guidelines for a single eye. Creatures with two visible eyes have each eye within these ranges. Creatures with many small eyes (magic, divine) may have smaller individual eyes but the same total eye area.

### 5.2 Eye Construction

Eyes are constructed in pixel art using the following approaches, selected based on available size:

#### 1-pixel eye (E rank minimum)
- A single pixel of outline color (or accent color)
- No highlight, no pupil, no iris
- Placement and spacing of the two dots communicates the creature's awareness

#### 2-pixel eye (E-D rank typical)
- Two pixels: 1 outline-color pixel + 1 highlight pixel
- Or: 2 outline-color pixels arranged vertically (gives a slightly larger, more present eye)
- The highlight pixel goes in the upper-left position (reflecting the top-left light source)

#### 3-pixel eye (D-C rank typical)
- An L-shape, a line of 3, or a 2x2 minus one corner
- Typically: 2 outline-color pixels forming the eye shape + 1 highlight pixel in the upper-left
- Or: 3 outline-color pixels with no highlight for a darker, more intense look

#### 4-6 pixel eye (B-S rank)
- A 2x2 or 2x3 or 3x2 arrangement
- Typically: outline-color border pixels + 1-2 fill pixels (iris color) + 1 highlight pixel
- Pupils become possible at 4+ pixels: a darker dot within the iris
- The highlight pixel is always in the upper-left quadrant of the eye

#### No-eye construction (plant, material, some magic)
- Some creatures have no visible eyes
- In this case, the creature MUST have an alternative focal point that draws the viewer's attention
- Alternative focal points: a central glowing pixel, a prominent mouth/opening, a distinctive marking, an asymmetric shape that the eye naturally follows

### 5.3 Eye Color

| Eye Component | Color Source |
|---------------|-------------|
| Eye outline/dot (minimal eyes) | Outline color (Role 1) |
| Eye fill/iris | Outline color (Role 1) or accent color (Role 4) |
| Eye highlight/gleam | Highlight color (Role 5) |
| Eye pupil (if 4+px eye) | Outline color (Role 1) |

The accent color (Role 4) may be used as the eye fill color to make the eyes "pop" — this is especially effective for undead (glowing red eyes), magic (bright blue eyes), and divine (golden eyes). However, using the accent color in the eyes means it must also appear elsewhere on the body to avoid looking disconnected.

### 5.4 Eye Expression

#### Default Expression: Neutral

The default expression for all idle sprites is neutral. Neutral does not mean blank or dead — it means the creature is awake, aware, and in its natural resting state. The creature is not emoting.

Specific rules:
- No smiling: no upturned mouth corners, no happy eye squints
- No frowning: no downturned mouth corners, no angry brow ridges
- No surprise: no wide-open circular eyes
- No sadness: no drooping eyes
- No cartoonish expression of any kind

The target emotional register is: **"alive but unknowable"**. The creature has presence and awareness, but its internal state is not readable. It is not cute, not scary, not friendly, not hostile. It simply IS.

#### Permitted Deviations from Neutral

| Family | Permitted Eye Expression Deviation |
|--------|-----------------------------------|
| beast (E rank only) | Slightly soft, slightly open eyes — approachable but not mascot-cute |
| beast (D rank and above) | Neutral only |
| bird | Slightly sharp, watchful — the bird is alert, tracking |
| plant | Neutral or absent. If present, eyes are calm and slow |
| material | Neutral or eerie. Eyes may appear to look through the viewer rather than at them |
| magic | Neutral or distant. Eyes may have an unfocused, otherworldly quality |
| undead | Slight menace is acceptable. Hollow eyes with a dim glow. Not aggressive, just unsettling |
| dragon | Slight menace or authority is acceptable. The dragon knows it is powerful |
| divine | Intense. The divine creature's eyes bore into the viewer. Not angry — intent |
| slime | Neutral. Simple dot eyes with no readable expression |

### 5.5 Eye Placement

Eyes are placed in the upper portion of the head mass, in the front-facing quadrant. Given the 3/4 front-facing view:

- Both eyes are visible, but one is slightly smaller or partially hidden by the curve of the head
- The front eye (closer to the viewer) is larger/more visible
- The back eye (further from the viewer) is smaller or partially occluded
- Eyes are horizontally aligned (same height from the top of the head)
- Eye spacing: approximately 30-40% of the head width between the inner edges of the two eyes

For cyclops or single-eyed creatures:
- The single eye is centered on the head mass
- It is slightly larger than a normal eye would be at the same rank

For many-eyed creatures (magic, divine, some undead):
- Eyes are arranged in a symmetrical pattern (triangle, vertical line, arc)
- All eyes use the same color and construction
- The topmost or most central eye is the focal point and may be slightly larger

### 5.6 Eyeless Creatures

The following families may produce eyeless creatures:
- plant (commonly eyeless)
- material (sometimes eyeless)
- magic (rarely eyeless)

An eyeless creature MUST have an alternative focal point. The alternative focal point serves the same purpose as eyes: it gives the viewer a place to look, anchors the design, and communicates that the creature is alive.

Acceptable alternative focal points:
- A central marking in a contrasting color (a seal impression, a brand mark, a geometric pattern)
- A glowing core (1-3 bright pixels at the center of the creature)
- A mouth or opening (a petal fold, a crack, a gap in the material)
- An asymmetric shape that the eye naturally follows to a point (a spiraling vine tip, a leaning protrusion)
- A surface texture concentration (a cluster of spore dots, a knot in wood grain, a density of absorbed objects)

---

## 6. Mouth and Face Rules

### 6.1 General Mouth Visibility

Most creatures do **NOT** have visible mouths in their idle pose sprite. The mouth is closed, hidden behind the body contour, or simply not drawn.

Mouth visibility rules by family:

| Family | Mouth in Idle Sprite | Details |
|--------|---------------------|---------|
| beast | Usually NOT visible | Small, closed. If visible, it is a single horizontal line of 1-2 pixels at the lower front of the head. No open mouth. |
| bird | Beak defines the mouth area | The beak is closed in idle pose. The beak's shape implies the mouth. No open beak. No tongue. |
| plant | Usually NOT visible | If present, the mouth is a petal fold, root opening, or dark gap in the body. Not a human-like mouth. Often absent entirely. |
| material | Usually NOT visible | No mouth unless the material motif demands it (a skull-based material may have a jaw opening, a vessel-based material may have a rim that reads as a mouth). |
| magic | NOT visible | Magic creatures typically have no visible mouth. Their form communicates through shape and pattern, not through facial features. |
| undead | May be visible | Undead creatures may show teeth or jaw through damage — an exposed jawbone, a torn cheek revealing teeth. This is decay visibility, not expression. The mouth is not open in a roar. |
| dragon | Usually NOT visible | Closed jaw in idle. The jaw line is defined by the outline, but the mouth is shut. Fang tips (1-2 pixels) may protrude from the upper jaw line in higher-rank dragons. |
| divine | Usually NOT visible | No mouth, or a thin closed line. Divine creatures communicate through eyes, not mouth. |
| slime | Thin line or none | If present, the mouth is a thin horizontal line (1-2 pixels) in the lower half of the face area. Not a wide smile. Not a grin. A subtle, almost invisible line. |

### 6.2 Visible Teeth Rule

Teeth are **NOT shown** in idle sprites except in two specific cases:

1. **Undead with exposed jaw**: If the undead creature's decay has exposed its jawbone or teeth, teeth are visible as structural elements — part of the creature's damaged anatomy, not part of an expression. The teeth are 1-2 pixels of bone color visible through a gap in the cheek or a missing jaw covering.

2. **Dragon fang tips (B rank and above)**: High-rank dragons may show 1-2 pixels of fang tip protruding from the upper jaw line, visible even when the mouth is closed. These are small, sharp points that read as "the jaw barely contains the teeth." Maximum 2 pixels per fang, maximum 2 fangs visible.

In all other cases, teeth are not visible in idle sprites. Teeth appear in attack animation frames (for creatures that have attack frames).

### 6.3 No Visible Tongue Rule

No creature shows a tongue in its idle sprite. Tongues appear only in attack animation frames, if at all.

### 6.4 Nose and Nostril Rules

| Family | Nose/Nostril Representation |
|--------|---------------------------|
| beast | 1-2 pixels of outline color at the front of the snout, suggesting nostrils. No protruding nose shape. |
| bird | No separate nose — the beak's base/nares area is defined by a 1px color change at the beak-head junction. |
| plant | No nose. |
| material | No nose, unless the material motif includes one (skull-based material may have a nasal opening). |
| magic | No nose. |
| undead | Nasal cavity may be visible as a dark hollow (1-2 pixels of outline color in the skull face area). |
| dragon | 1-2 pixels of outline color at the tip of the snout. May include a tiny nostril dot. |
| divine | No nose, or a minimal 1px indication of a bridge. |
| slime | No nose. |

---

## 7. Appendage and Detail Rules

### 7.1 Horns, Antlers, and Spines

**Construction**:
- Horns are sharp-cornered at pixel level — no smooth rounded tips
- Base width: 1-2 pixels where the horn meets the head
- Tip: tapers to 1 pixel at the end
- Length: proportional to the head size (20-50% of head height for small horns, 50-100% for prominent horns)
- Maximum 2-3 visible horns per creature (more becomes visually noisy at small sizes)

**Color**:
- Horns use either the outline color (Role 1) or a color between the body shadow and the outline (slightly lighter than pure black)
- Metallic or bone horns may use the accent color (Role 4)
- Each horn uses at most 2 colors: base color + shadow or tip color

**Direction and shape**:
- Horns should point upward, backward, or outward — not directly forward (forward-pointing horns merge with the face in 3/4 view)
- Curved horns are represented by 2-3 straight pixel segments at different angles, not smooth curves
- Antlers (branching horns) are only feasible on 32x32 canvases and larger — on 24x24, antlers become pixel noise

**Spines (along the back or tail)**:
- Individual spines are 1-2 pixels tall
- Spines are spaced 2-3 pixels apart
- A row of spines uses the same color as the horns
- Maximum 3-5 visible spines on a creature

### 7.2 Tails

**Position and direction**:
- Tails extend from the rear of the body, on the opposite side from the head
- In the 3/4 front-facing view, the tail extends toward the right side of the canvas (behind the creature from the viewer's perspective)
- The tail curves downward toward the ground or extends horizontally

**Size**:
- Tail base width: 2-4 pixels where it meets the body (proportional to body size)
- Tail length: 30-80% of the body length
- Tail tip: 1-2 pixels wide
- The tail is thick enough to be part of the 3-mass composition — it is NOT a single-pixel line

**Boundary**:
- The tail must NOT extend beyond the canvas edge
- If the natural tail length would exceed the canvas, the tail curves or coils to stay within bounds
- The tail's end must be at least 1 pixel from the canvas edge

**Color**:
- Tails use the same body base + body shadow color as the main body
- Tail tips may use the accent color if the design calls for it (colored tail tuft, glowing tip)

### 7.3 Wings

Wings appear on bird and dragon family creatures, and occasionally on magic, divine, or undead creatures.

**Default state**: Folded in idle pose. Wings are folded against or behind the body in the idle sprite. They are visible as a shaped mass but not outstretched.

**Folded wing representation**:
- The wing appears as a triangular or curved mass behind the body, visible on one side (the side closer to the viewer in 3/4 view)
- The wing's edge extends slightly beyond the body outline
- The wing has its own outline (1px) where it extends beyond the body
- Where the wing overlaps the body, the wing's fill color appears in front of the body's fill color

**Color**:
- Wings use at most 2 color values: wing base color + wing shadow color
- Wing base is typically similar to the body base but may be a different hue (blue-grey wings on a brown body)
- Wing shadow follows the same top-left lighting rule as the body

**Prohibitions**:
- No fully outstretched wings in idle pose (this is an action pose)
- No detailed individual feather rendering (feathers are implied by color blocks)
- No membranous bat-wing rendering on bird family creatures (bat wings are for dragons or specific motifs)
- No wing larger than 40% of the total canvas area (even folded, wings should not dominate the sprite)

### 7.4 Tags, Ropes, and Accessories

These elements are **critical** for the game's world identity. They connect the creature to the pastoral, bureaucratic, funerary, and gatebound themes of the world.

#### Livestock Tags

- Size: 2-3 pixels (the tag itself is 2-3 pixels, the attachment point is 1 pixel)
- Shape: small rectangle (2x1 or 3x1 pixels)
- Placement: dangling from the ear, hanging from the neck, attached to a horn base
- Color: accent color (Role 4) — typically copper, dull red, or bone white
- Attachment: a 1px line (outline color) connects the tag to the body

#### Seals and Stamps

- Size: 2-4 pixels of colored area on the body surface
- Shape: a small geometric mark — a cross, a square, a circle, an X
- Placement: on the flank (side of the body), on the shoulder, on the forehead
- Color: accent color (Role 4) — typically faded red (vermillion), dark ink blue, or burnt brown
- The seal is ON the body surface — it does not protrude or have its own outline separate from the body

#### Ropes and Collars

- Width: always 1 pixel
- Placement: around the neck (most common), around a limb, around the base of a horn
- Color: outline color (Role 1) or accent color (Role 4)
- The rope/collar follows the contour of the body part it wraps around
- Trailing ends (loose rope, dangling cord): maximum 3-4 pixels long, 1px wide

#### Burial Cloth Strips

- Width: 1-2 pixels
- Placement: wrapped around limbs, trailing from the body, partially covering the face
- Color: body base lightened (a paler, faded version) or a dedicated cloth color (dusty white, faded yellow)
- Strips are torn and irregular, not neat wrappings

#### Other Accessories

| Accessory | Size | Placement | Color |
|-----------|------|-----------|-------|
| Straw stuck in fur | 1-2px lines | Random across body surface | Straw yellow (accent) |
| Dried mud on hooves | 2-3px cluster | Base of legs, feet | Dark brown (body shadow or darker) |
| Ink stains on claws | 1-2px marks | Claw/hand tips | Dark blue or black (outline color) |
| Flower remnant (wilted) | 2-3px cluster | Head, neck, shoulder | Faded pink or brown |
| Ash dusting | 1-2px dots | Scattered on body surface | Light grey (highlight or detail color) |
| Geometric crack pattern | 1px lines | Along spine, on shoulder | Outline color or accent color |

### 7.5 Text on Creatures

**NEVER** put readable text on a sprite. No letters, no numbers, no kanji, no runes that spell anything.

**Permitted abstract marks**:
- Registration-style marks: small geometric shapes (cross, circle, line) that suggest a stamp or brand
- Tally scratches: short parallel lines (2-4 marks) scratched into a surface
- Seal impressions: a colored geometric pattern that suggests a stamp was pressed into the surface
- These are all abstract patterns, not readable glyphs

---

## 8. Animation Frame Rules

### 8.1 Battle Idle Animation

All monsters have a battle idle animation. No monster has a static, single-frame battle sprite.

**Frame count**: 2 frames minimum, 2 frames maximum for all ranks.

**Frame content**:
- Frame 1: The default pose (as described in all sections above)
- Frame 2: A slight modification of the default pose — breathing, bobbing, ear twitch, tail sway, wing shift, eye blink, or body pulse

**Movement amount**: The difference between Frame 1 and Frame 2 is **1-2 pixels of displacement** maximum. This means:
- A body part moves 1-2 pixels in a direction (an ear tilts 1px, a tail tip shifts 2px)
- A color region shifts 1-2 pixels (a shadow boundary moves, simulating breathing)
- A small detail appears/disappears (a highlight pixel blinks, a spore pixel appears)

**What moves (choose 1-2 of these per creature)**:
- Ear twitch: one ear moves 1px up or down
- Tail sway: the tail tip shifts 1-2px left or right
- Body bob: the entire body shifts 1px up or down (simulating breathing)
- Wing shift: a folded wing edge moves 1px up or down
- Eye blink: the highlight pixel in the eye disappears and reappears
- Chest pulse: the shadow boundary on the chest shifts 1px, simulating a breath
- Horn glow shift: a highlight pixel on the horn appears/disappears
- Tendril wave: a tendril or vine tip shifts 1-2px
- Surface ripple: a shadow or color region on the body shifts 1px (for slimes, magic creatures)
- Jaw clench: the jaw line shifts 1px (for dragons with visible jaw)

**Frame timing**: 500ms per frame, for a 1-second total loop (Frame 1 for 500ms, Frame 2 for 500ms, repeat).

### 8.2 Idle Animation Constraints

**Silhouette stability**: The outer silhouette of the creature should NOT change between frames. The outline should be identical or nearly identical between Frame 1 and Frame 2. Only internal details or small extremities (ear tips, tail tips, tendril ends) should move. If you fill both frames with solid color and compare the silhouettes, they should be indistinguishable.

**Color stability**: No color values change between frames. The palette is identical in both frames. There is no flashing, no color cycling, no pulsing of brightness. The change is purely positional (pixels of the same colors move to slightly different positions).

**Anchor point stability**: The creature's center of mass does not shift between frames. If the creature bobs up 1px in Frame 2, its feet must also move up 1px (the whole creature moves as a unit). If only a body part moves, the rest of the creature stays in exactly the same position.

**No added or removed pixels**: The total number of opaque pixels should be the same (or within 1-2 pixels) between frames. Animation is achieved by shifting existing pixels, not by adding or removing them.

### 8.3 Attack Animation (S-Rank Only)

Only S-rank monsters have an attack animation in their battle sprite. All other ranks play a generic engine-provided attack effect (screen shake, flash, particle overlay) and do not have custom attack frames.

**Frame count**: 3 frames.

**Frame content**:
- Frame 1 (wind-up): The creature pulls slightly back from its idle position. The body shifts 1-2px backward (to the right, since the creature faces left). The head may lower slightly. This frame communicates "preparing to strike."
- Frame 2 (strike): The creature lunges forward. The body shifts 2-3px forward (to the left). The head extends. A claw, jaw, tail, or magical appendage extends toward the target. This is the moment of impact.
- Frame 3 (recover): The creature returns to its idle position. The body is back to its default placement. This frame may be identical to idle Frame 1.

**Frame timing**: 150ms per frame (450ms total for the full attack sequence).

**Attack animation constraints**:
- The creature does NOT leave its canvas area during the attack animation
- The maximum forward lunge is 3px from idle position
- The creature's feet/base do not move (the lunge is an upper-body movement)
- The silhouette changes slightly during the strike frame (an extending claw, an opening jaw) but returns to idle silhouette in the recover frame
- Color palette remains identical across all 3 frames

### 8.4 Field Sprite Animation

Field sprites are 16x16 for all ranks. Each field sprite has 8 animation frames organized as 2 frames per direction for 4 directions.

**Directions**: down (facing the viewer), left (facing left), right (facing right), up (facing away from the viewer).

**Frame content per direction**:
- Frame 1: left foot (or left equivalent) forward
- Frame 2: right foot (or right equivalent) forward

For the left and right directions, if the creature is horizontally symmetric, the right-facing frames can be created by flipping the left-facing frames. If the creature has asymmetric features (a tag on one ear, one eye different from the other, an asymmetric horn), separate right-facing frames must be drawn.

**Movement amount**: 1-2 pixels of leg/arm/appendage alternation between Frame 1 and Frame 2.

**Non-legged creatures**:
- Plant creatures: bobbing motion (the whole creature shifts 1px up/down) or a subtle lean (the top shifts 1px in the direction of movement)
- Slime creatures: a squash-stretch simulation (slightly wider in Frame 1, slightly taller in Frame 2, or vice versa, with 1px difference)
- Material creatures: a rocking motion (the body tilts 1px in alternating directions) or a sliding motion (the base shifts 1px but the top stays)
- Floating/magic creatures: a bobbing motion (1px up in Frame 1, 1px down in Frame 2)

**Field sprite simplification**:
- The field sprite is a simplified version of the battle sprite
- It uses the same palette and the same outline rules
- The silhouette is simplified: fewer internal details, fewer appendage distinctions
- The creature must still be recognizable as the same creature from its battle sprite
- Small features (tags, stamps, individual markings) may be omitted or reduced to 1 pixel

**Sprite sheet layout** for field animation:

```
Row 1: down_f1 | left_f1 | right_f1 | up_f1
Row 2: down_f2 | left_f2 | right_f2 | up_f2
```

Each cell is 16x16 pixels. The full sprite sheet is 64x32 pixels.

---

## 9. Motif Visualization Rules

### 9.1 Primary Motif

The primary motif is the creature's main visual identity — what the creature IS.

**Visibility standard**: The primary motif must be recognizable within 2 seconds of looking at the sprite at 1x scale. A viewer should be able to say "that's a sheep-thing" or "that's a mushroom-thing" or "that's a broken-cage-thing" without needing to read the creature's name or description.

**Visual dominance**: The primary motif takes up 40-60% of the visual identity. This means 40-60% of the creature's design decisions (shape, color, features) are driven by the primary motif.

**Expression method**: The primary motif is expressed through:
- Body shape: the overall silhouette echoes the motif source (a ram-based creature has a ram-like body shape)
- Major color choice: the body base color relates to the motif (a stone creature is stone-colored, a leaf creature is green)
- Key features: 1-3 specific features that identify the motif (a beak for a bird motif, horns for a ram motif, leaf shapes for a plant motif)

### 9.2 Secondary Motif (World Connection)

The secondary motif connects the creature to the game's world — specifically to the pastoral, bureaucratic, funerary, gatebound, household, or astral themes that make this game's monsters distinct from generic RPG monsters.

**Visibility standard**: The secondary motif must be present but subtle. It should be noticeable after the primary motif has been recognized — a second layer of meaning that enriches the design without competing with the primary identity.

**Visual dominance**: The secondary motif takes up 15-30% of the visual identity. It is expressed through accessories, markings, or texture, not through body shape.

**How to visualize each secondary motif category**:

#### pastoral

Visual elements: burnt brand marks on the hide (2-3 pixels of accent color in a geometric pattern on the flank), livestock tags (2-3px rectangle hanging from ear or neck on a 1px line), frayed rope collars (1px line around neck with 1-2px trailing end), straw stuck in fur (1-2 accent-colored pixels in the body fill), dried mud on hooves (2-3px cluster of dark color at the feet), faded registration marks on the body surface.

Where to place: on the creature's body surface (brands), at connection points (tags on ears, collars on necks), on the extremities (mud on feet, straw in fur).

How to keep subtle: use muted accent colors that are close in value to the body base. The mark should be visible but not the first thing the viewer notices.

#### funerary

Visual elements: ash dusting on the surface (scattered 1px dots of pale grey across the body), burial cloth strips (1-2px wide trails of pale fabric color wrapping around limbs or trailing behind), wilted flower remnants (2-3px cluster of faded pink or brown on the head or shoulder), hollow spaces in the body (1-2px gaps filled with dark outline color suggesting emptiness), incense-smoke colored wisps (1-2px of warm amber trailing from the body edges).

Where to place: scattered across the body surface (ash), wrapped around limbs or neck (cloth), on the head or upper body (flowers), at joints or damage points (hollow spaces).

How to keep subtle: funerary marks should feel like residue — something that settled on the creature, not something designed into it.

#### bureaucratic

Visual elements: stamp marks (2-4px geometric pattern in accent color on the flank or shoulder), scratch tally marks (2-4 parallel 1px lines scratched into a surface — horn, shell, bone), ink stains (1-2px dark blue or black marks on claws, feet, or face), paper or tag fragments (2-3px rectangle of pale color attached to the body), faded registry marks (a geometric shape — circle, square, cross — in faded accent color on the body).

Where to place: on flat body surfaces that would be accessible for marking (flanks, shoulders, forehead), on extremities that contact documents (claws, feet), attached to the body at ear, neck, or horn.

How to keep subtle: bureaucratic marks should look official but worn — faded, scratched, partially illegible. They are records of the creature's place in a system.

#### gatebound

Visual elements: stone-carved patterns (1px geometric lines on the body surface matching architectural/masonry patterns), geometric cracks along the spine or limbs (1px lines of outline color that follow geometric rather than natural fracture patterns), cold metallic accents on horns or claws (1-2px of cold silver or steel color at the tips of protrusions), moss or lichen matching tower masonry (1-2px of green on stone-like surfaces), one eye reflecting distant light while the other is normal.

Where to place: along structural lines of the body (spine, shoulder ridge, jawline), at the tips of protrusions (horns, claws), on one specific feature that is "different" from the rest.

How to keep subtle: gatebound marks should feel intrusive — like the tower's influence has seeped into the creature from outside. They should look slightly wrong on an otherwise natural creature.

#### household

Visual elements: kitchen tool fragment incorporated into the body (a ladle-shaped horn, a whisk-like tail tuft, a pot-rim collar), woven texture on a body part (basket-weave pattern on the shell or back, represented by alternating 1px color blocks), vessel shapes in the body (a gourd-like belly, a bowl-shaped back, a jug-shaped head), soot or cooking stains (1-2px dark marks on hands/paws/face), worn-down edges from use (rounded corners where sharp edges would be expected).

Where to place: integrated into body parts (horns shaped like tools, body shaped like vessels), on the surface (soot, wear patterns), in the texture (woven patterns).

How to keep subtle: household elements should feel like the creature grew around a domestic object, or that domestic life shaped the creature's evolution. Not costume pieces — structural integration.

#### astral

Visual elements: star-dot eyes (the eye highlight pixel is unusually bright, creating a star-like appearance), reflective single pixels placed at geometric intervals on the body (1 bright pixel on each shoulder, on the forehead, on the tail tip — creating a constellation-like pattern), geometric regularity in body markings (evenly spaced dots, symmetrical line patterns), glass-like or crystalline surface suggestion (the highlight color used in small regular patterns).

Where to place: at the eyes (star-dot), at regular intervals across the body (constellation pattern), on smooth surfaces (crystalline effect).

How to keep subtle: astral marks should feel like the creature carries a map of the sky on its body, or that it reflects light from a source that is not the game's sun.

### 9.3 Taboo/Tower Connection

Every creature in the game carries a subtle visual element that connects it to the tower, the gate, and the game's central mystery. This element should feel slightly wrong — a mark that does not belong on a natural creature, a pattern that suggests something artificial or otherworldly has touched the creature.

**The taboo element is a SINGLE visual feature**. Not a collection of features, not a theme — one specific thing.

**Visibility standard**: The taboo element should be noticeable only on second look. When a player first sees the creature, they see the primary motif and the creature's family identity. When they look more carefully, they notice the taboo element and feel a small moment of unease or curiosity.

**Examples of taboo elements**:
- A geometric pattern on an organic body: straight lines or regular shapes etched into flesh, fur, or bark
- A metallic sheen on one horn while the other is bone: one body part is made of a different material than expected
- One eye different from the other: different color, different size, one eye reflecting light that is not present in the scene
- A crack or seam that follows architectural rather than natural lines: a fracture in the body that looks like it was cut with precision, not broken by force
- A temperature mismatch: one small area of the body colored in cold blue when the rest is warm brown (suggesting that one spot is unnaturally cold)
- A shadow that does not match the light source: one small shadow area placed on the wrong side (top-left instead of bottom-right), suggesting something about the creature's relationship with light is anomalous
- An extra digit, spine, or eye that appears only on one side: an addition that breaks the natural symmetry in a specific, deliberate way

**What the taboo element is NOT**:
- A different creature grafted onto this one
- A visible curse effect (dark smoke, red glow, purple aura)
- A narrative label (a sign that says "cursed")
- A dramatic visual feature that dominates the design
- Something that makes the creature look "cool" — it should make the creature look "off"

---

## 10. Quality Checklist (Per Sprite)

Every sprite must pass ALL checks in ALL categories before it is considered approved for integration into the game.

### 10.1 Technical Checks

| # | Check | Pass Condition | How to Verify |
|---|-------|---------------|---------------|
| T1 | Canvas size matches rank | Canvas dimensions match the rank table in Section 1.1 exactly | Open the file; check pixel dimensions |
| T2 | Background is fully transparent | Every pixel that is not part of the creature is fully transparent (alpha = 0) | Hide all layers except background; verify empty. Or: select all non-creature pixels and verify alpha = 0 |
| T3 | Color count within rank budget | Total number of unique colors (excluding transparent) is within the min-max range for the rank in Section 3.2 | Use Aseprite's palette analysis or a script to count unique colors |
| T4 | All colors exist in master palette | Every color used in the sprite exists in `tools/palette-remap/master_palette.hex` after final cleanup | Run `palette_remap.py` and verify no unmapped colors remain |
| T5 | 1px outline consistent throughout | All outline pixels are exactly 1px wide and use the same color | Visual inspection at 4x zoom; check for 2px thick areas or color-mismatched outlines |
| T6 | No anti-aliasing artifacts | No semi-transparent pixels, no blended-color pixels at edges | Select by color; verify no unexpected intermediate colors exist |
| T7 | No stray pixels outside creature boundary | No opaque pixels floating disconnected from the main creature body | Visual inspection at 1x and 4x zoom |
| T8 | No orphan pixels | No single disconnected pixels that are not part of a deliberate design element (an orphan pixel is a single opaque pixel with no adjacent opaque neighbor on any of its 4 cardinal sides) | Visual inspection at 4x zoom |
| T9 | File named correctly | File name follows the convention in Section 1.2 exactly | Compare against naming template |
| T10 | No semi-transparent pixels | Every pixel is either alpha=0 or alpha=255 | Script check or Aseprite alpha analysis |
| T11 | Edge clearance maintained | Pixel rows/columns at all four edges of the canvas are fully transparent | Visual inspection |
| T12 | Sprite sheet layout correct (if sheet) | Frames are arranged in the correct grid layout as specified in Section 1.2 | Visual inspection |

### 10.2 Design Checks

| # | Check | Pass Condition | How to Verify |
|---|-------|---------------|---------------|
| D1 | Silhouette identifies family | Filling the sprite with solid color produces a silhouette recognizable as the correct family | Create a silhouette version; show to a reviewer without context |
| D2 | Three-mass composition holds | The sprite decomposes into exactly 3 major visual masses (head, body, appendage/tail) | Squint test at 1x; identify 3 distinct shape groups |
| D3 | Canvas fill percentage within range | Opaque pixel count / total pixel count falls within the range for the rank (Section 4.3) | Count opaque pixels; calculate percentage |
| D4 | Creature centered horizontally | The creature's visual center of mass is within 1-2px of the canvas horizontal center | Visual inspection with a center guide line |
| D5 | Creature grounded correctly | Feet/base sits at the correct ground line position (Section 4.4) | Measure the y-coordinate of the lowest opaque pixel |
| D6 | Eyes establish presence | Eyes (or alternative focal point for eyeless creatures) are the first thing the viewer notices when looking at the face area | Show the sprite to a reviewer; ask where their eye goes first |
| D7 | No visible mouth in idle | Mouth is closed or not visible, following the rules in Section 6.1 for the creature's family | Visual inspection |
| D8 | Light source consistent | Shadows are placed on the bottom-right of masses, consistent with top-left lighting | Check every shadow placement against the light direction |
| D9 | Shading is 2-tone only | Each colored region uses exactly 2 values (base + shadow), with no gradient, no dithering, no banding, no pillow shading | Visual inspection at 4x zoom |
| D10 | Eye expression is neutral | Eyes show no cartoonish emotion (no smiling, no frowning, no surprise), following the "alive but unknowable" standard | Visual inspection; check against Section 5.4 |
| D11 | Facing direction correct | Creature faces LEFT by default | Visual inspection |
| D12 | Viewing angle is 3/4 front | Creature is angled approximately 30-45 degrees from frontal, not pure profile or pure frontal | Visual inspection |

### 10.3 World Identity Checks

| # | Check | Pass Condition | How to Verify |
|---|-------|---------------|---------------|
| W1 | Primary motif readable | The primary motif is recognizable within 2 seconds at 1x scale | Show the sprite to a reviewer; ask "what is this creature based on?" within 2 seconds |
| W2 | Secondary motif present | At least one pastoral/funerary/bureaucratic/gatebound/household/astral visual element is present as an accessory or marking | Identify the specific pixels that represent the secondary motif |
| W3 | Tower/taboo element present | A single subtle visual element connects the creature to the tower/gate mystery | Identify the specific feature; verify it is noticeable only on second look |
| W4 | No existing IP resemblance | The creature does not closely resemble any monster from Dragon Quest, Pokemon, Digimon, Monster Rancher, Shin Megami Tensei, or other monster-collecting RPGs | Google Image Search the silhouette; compare against top 20 results for "pixel art monster RPG" |
| W5 | Name and appearance consistent | The creature's visual design is consistent with its Japanese name and its design intent notes | Cross-reference with the monster's registry entry |
| W6 | Color temperature fits zone | The creature's palette tendency matches its home world zone (Section 3.5) | Compare palette against zone guidance |

### 10.4 Animation Checks

| # | Check | Pass Condition | How to Verify |
|---|-------|---------------|---------------|
| A1 | 2 idle frames exist | The battle sprite has exactly 2 idle animation frames | Open the Aseprite file; count frames tagged `idle` |
| A2 | Frame difference is 1-2px only | The maximum pixel displacement between Frame 1 and Frame 2 is 1-2 pixels | Overlay Frame 1 and Frame 2 at 4x zoom; measure the maximum difference |
| A3 | Silhouette stable across frames | Filling both frames with solid color produces identical or near-identical silhouettes | Create silhouette versions of both frames; compare |
| A4 | Anchor point consistent | The creature's center of mass and base position do not shift between frames | Overlay both frames; verify the base line and center of mass align |
| A5 | Color palette identical across frames | Both frames use exactly the same set of colors | Compare palettes of both frames |
| A6 | Field sprite has 8 frames | The field sprite has 2 frames x 4 directions = 8 frames total | Open the Aseprite file; count frames |
| A7 | Attack frames exist (S-rank only) | S-rank battle sprites have 3 additional attack frames | Count frames tagged `attack` |
| A8 | Frame timing recorded | The animation timing is recorded in the Aseprite file or in the asset registry | Check Aseprite frame duration settings or registry entry |

---

## 11. IP Safety Rules

### 11.1 Prohibited Visual References

The following specific visual elements are prohibited because they are too closely associated with existing intellectual properties:

| Prohibited Element | Reason | What IP It Evokes |
|-------------------|--------|-------------------|
| Teardrop shape with a face (rounded bottom, pointed top, two dots for eyes, wide smile) | This is the iconic Dragon Quest slime shape | Dragon Quest (Square Enix) |
| Round mascot body with oversized head (head 50%+ of total body, eyes 30%+ of face, tiny limbs) | This is the typical Pokemon mascot proportion | Pokemon (Nintendo/Game Freak) |
| "Action figure" proportions on monster creatures (humanoid muscular body with monster head, sharp angular joint details) | This evokes Digimon's champion/ultimate stage designs | Digimon (Bandai) |
| Disc, CD, or spinning media motif as a creature core (a creature born from or centered around a spinning disc) | This is the core mechanic visual of Monster Rancher | Monster Rancher (Tecmo) |
| Tarot card, occult circle, or Kabbalistic tree visual language (creatures framed by or emerging from occult diagrams) | This is the visual language of Shin Megami Tensei | Shin Megami Tensei (Atlus) |
| A recognizable mythological creature rendered faithfully (a phoenix that looks like a classic phoenix, a cerberus that looks like a classic cerberus, a kirin that looks like a classic kirin) | Faithful mythological rendering is generic and unoriginal | Multiple IPs |
| Ball-shaped creature with a visible seam line around the equator | This evokes a Pokeball or capsule monster | Pokemon (Nintendo/Game Freak) |
| Metallic body with visible gear/clockwork mechanisms exposed | This evokes Clockwork or Steel-type designs common in multiple IPs | Multiple IPs |
| Creature with a zipper, opening, or unzipping body revealing a different creature inside | This evokes Banette and similar "costume" monster tropes | Pokemon (Nintendo/Game Freak) |
| Electric rodent (yellow, red cheeks, lightning bolt tail) | This is Pikachu and its derivatives | Pokemon (Nintendo/Game Freak) |
| Ice cream cone, trash bag, gear, or modern human object rendered directly as a creature with minimal transformation | This evokes controversial "object Pokemon" designs | Pokemon (Nintendo/Game Freak) |

### 11.2 IP Verification Process

For every new monster sprite, before approval:

1. **Silhouette search**: Take the creature's solid-color silhouette. Perform a Google Image reverse search. If any of the top 20 results show a recognizable character from an existing IP, the design must be revised.

2. **Keyword search**: Search Google Images for `pixel art [creature type] monster RPG` (e.g., "pixel art sheep monster RPG"). Compare the sprite against the results. If any match is recognizable within 3 seconds of side-by-side comparison, the design must be revised.

3. **Family comparison**: Compare the sprite against all existing creatures in the same family within THIS game's registry. The sprite must be distinguishable from every other sprite in the same family by silhouette alone.

4. **Reviewer blind test**: Show the sprite to a reviewer who is familiar with DQ, Pokemon, Digimon, Monster Rancher, and SMT. Ask: "Does this remind you of anything specific?" If the reviewer names a specific character from an existing IP, the design must be revised.

---

## 12. AI Generation Workflow

### 12.1 Step 1: Concept Prompt Construction

For each monster to be generated, construct a prompt using the 6-block template defined in `docs/specs/content/06_monster_taxonomy_and_motif_rules.md`:

**Block 1 — Invariant**:
```
pixel art, {battle_sprite_px}x{battle_sprite_px} battle sprite, transparent background,
1px black outline, top-left lighting, no anti-aliasing, no dithering, no gradient,
no smooth shading, gbc-inspired limited palette, readable at 1x, no text, no logo
```

Fill in `{battle_sprite_px}` with the correct canvas size for the monster's rank:
- E rank: 24
- D rank: 32
- C rank: 32
- B rank: 48
- A rank: 48
- S rank: 56

**Block 2 — Body**:
```
{specific creature description with primary motif first, physical details,
silhouette type, and idle/standing pose},
{rank-appropriate color count} color palette, dominant tones: {2-3 named color tones},
accent color: {element/attribute accent color}
```

The creature description must:
- Lead with the primary motif (what the creature IS)
- Describe the physical form (body shape, distinctive features, material/surface)
- Specify the silhouette type (round, wide, tall, serpentine, floating, tripod, massive)
- Specify idle/standing pose
- Name 2-3 dominant color tones using descriptive language (not hex codes)
- Name the accent color and what it appears on

**Block 3 — Lore Context**:
```
{1-2 short visual cues described as physical textures, marks, or wear patterns
that connect the creature to the world}
```

This block uses phrases from the Prompt Phrase Bank (Section 9.8 of the taxonomy document):
- Village/pastoral marks: "burnt ear tag", "faded brand mark on hide", "frayed rope collar", "tally notch on horn", "dried mud on hooves", "straw stuck in fur", "barn-dust patina"
- Record/seal marks: "scratched name plate hanging from neck", "ink-stained claws", "wax seal impression on shell", "faded registry stamp on flank", "carved tally marks on bone"
- Funeral/mourning marks: "wilted flower crown", "ash-dusted surface", "hollow eye sockets with dim glow", "wrapped in thin burial cloth strips", "incense-smoke colored wisps"
- Gate/tower marks: "stone-carved pattern on shoulder", "one eye reflecting distant light", "geometric cracks along spine", "moss pattern matching tower masonry", "cold metallic sheen on horns"
- Texture descriptors: "rough wool texture in flat pixel clusters", "smooth chitin in 2-tone shading", "translucent membrane with single highlight pixel", "cracked stone surface in 3 values"

**Block 4 — Pixel Constraints**:
```
{color count} color palette, fill 70-85% canvas, 3 shape masses maximum,
flat interior fills, strong silhouette read, no texture noise, no smooth shading
```

Fill in `{color count}` with the target color count for the rank:
- E rank: 5
- D rank: 6
- C rank: 7
- B rank: 8
- A rank: 9
- S rank: 10

**Block 5 — Negative**:
```
do not make it pokemon-like, dragon-quest-like, disney-like, anime mascot style,
do not use generic demon bat wings unless explicitly requested,
do not create busy background, no weapons unless the motif requires it
```

**Block 6 — Edit Notes** (used only for revision passes):
```
change only: {delta_request}. keep silhouette, palette logic, outline thickness,
lighting, and motif hierarchy unchanged.
```

Generate **4-8 candidates** per monster using the constructed prompt.

### 12.2 Step 2: Candidate Selection

From the 4-8 generated candidates, select the one that best meets the following criteria, evaluated in priority order:

1. **Silhouette strength**: Which candidate has the most readable, most distinctive silhouette? Fill each candidate with solid black and compare. The strongest silhouette wins.

2. **Family readability**: Does the silhouette immediately read as the correct family? A beast candidate must look beast-like, a bird candidate must look bird-like.

3. **Color count approximation**: Is the candidate close to the target color count for its rank? AI-generated candidates often use more colors than specified — prefer candidates that are already close to the budget.

4. **Motif clarity**: Is the primary motif recognizable? Can you identify the creature's base motif within 2 seconds?

5. **Pose correctness**: Is the creature in an idle standing pose, facing left, in 3/4 view? Reject candidates in action poses, pure profile, or pure frontal view.

6. **IP distance**: Does the candidate remind you of any existing IP character? Prefer candidates that feel original.

### 12.3 Step 3: Cleanup in Aseprite

Open the selected candidate in Aseprite and perform the following cleanup operations in order:

**Operation 1: Resize to exact canvas dimensions**
- If the AI-generated image is not the correct pixel dimensions, resize it to the exact canvas size for the rank
- Use nearest-neighbor resampling ONLY (no bilinear, no bicubic, no Lanczos)
- If the AI generated a larger image, scale down; if smaller, scale up
- After resize, every pixel should be a single solid color with no blending artifacts

**Operation 2: Apply master palette**
- Run `palette_remap.py` on the resized image
- This maps every color in the image to the nearest color in the master palette
- Review the result: verify that colors that were visually distinct before remapping are still visually distinct after remapping
- If two previously distinct colors mapped to the same palette entry, manually select the smaller region and change it to a different palette color that preserves the intended contrast

**Operation 3: Fix outline to exactly 1px**
- Zoom to 400-800% and trace the entire outline
- Identify any areas where the outline is 2px or thicker; remove the extra pixels
- Identify any areas where the outline is broken (gaps); fill the gaps
- Verify outline color consistency: every outline pixel must be the same color
- Check internal outlines (head-body separation, limb boundaries) for 1px consistency

**Operation 4: Remove anti-aliasing artifacts**
- Search for pixels that are intermediate colors between the outline and the fill (these are AA artifacts from the AI generation)
- Replace each AA artifact pixel with either the outline color or the fill color — whichever is appropriate for that position
- Check especially around curves and diagonal edges, where AA artifacts are most common

**Operation 5: Verify background transparency**
- Select all pixels that should be background
- Verify they are fully transparent (alpha = 0)
- Check for any semi-transparent pixels (alpha between 1 and 254) and make them either fully transparent or fully opaque

**Operation 6: Adjust composition**
- Verify canvas fill percentage is within the target range for the rank (Section 4.3)
- If the creature is too small, scale it up (nearest-neighbor) within the canvas
- If the creature is too large, scale it down or remove peripheral detail
- Center the creature horizontally
- Position the creature's base at the correct ground line (Section 4.4)
- Verify 1px minimum edge clearance on all sides

**Operation 7: Verify color count**
- Count the total number of unique colors in the sprite (excluding transparent)
- If over budget, merge the least important colors (combine two similar fills, simplify a gradient into two tones)
- If under the minimum, consider whether the sprite needs more detail for its rank

**Operation 8: Verify shading**
- Check that every shaded region uses exactly two tones (base + shadow)
- Verify light source direction (top-left) across all shadow placements
- Remove any pillow shading, banding, or gradient artifacts

**Operation 9: Organize layers**
- Separate the sprite into the required layers: outline, fill, shadow, accent, eyes
- Add optional layers as needed: highlight, accessory, taboo_mark
- Verify each layer contains only the pixels appropriate to its role

### 12.4 Step 4: Animation

**Battle idle animation**:
1. Duplicate the cleaned Frame 1 to create Frame 2
2. Choose 1-2 small movements from the list in Section 8.1 (ear twitch, tail sway, body bob, wing shift, eye blink, chest pulse, horn glow shift, tendril wave, surface ripple, jaw clench)
3. Apply the movement: shift the selected pixels by 1-2 pixels in the appropriate direction
4. Verify the silhouette has not changed significantly between frames
5. Set frame duration to 500ms per frame in Aseprite
6. Tag both frames as `idle`
7. Play the animation and verify it loops smoothly

**Battle attack animation (S-rank only)**:
1. Duplicate Frame 1 three times to create Frame 1, Frame 2, Frame 3
2. Frame 1 (wind-up): shift the upper body 1-2px to the right (backward)
3. Frame 2 (strike): shift the upper body 2-3px to the left (forward), extend an attack feature (jaw, claw, tail, magical extension)
4. Frame 3 (recover): return to Frame 1 position (may be identical to idle Frame 1)
5. Set frame duration to 150ms per frame
6. Tag these frames as `attack`

**Field sprite animation**:
1. Create the down-facing idle frame (16x16 simplified version of the battle sprite)
2. Duplicate to create the down-facing walking frame (shift legs/appendages by 1-2px)
3. Create the left-facing idle frame (reorient the creature to face left in 16x16)
4. Duplicate to create the left-facing walking frame
5. Create the right-facing frames (flip left-facing frames if the creature is symmetric, or draw separately if asymmetric)
6. Create the up-facing idle frame (show the creature's back)
7. Duplicate to create the up-facing walking frame
8. Arrange into sprite sheet: 4 columns (down, left, right, up) x 2 rows (frame 1, frame 2)
9. Tag frames by direction: `field_down`, `field_left`, `field_right`, `field_up`

### 12.5 Step 5: Review

Run through the complete Quality Checklist (Section 10) for every sprite:

1. Complete all Technical Checks (T1-T12). If any fail, return to Step 3 and fix.
2. Complete all Design Checks (D1-D12). If any fail, return to Step 3 and fix.
3. Complete all World Identity Checks (W1-W6). If any fail, return to Step 1 or Step 3.
4. Complete all Animation Checks (A1-A8). If any fail, return to Step 4 and fix.

After all checks pass:

5. Record the sprite in `asset_registry.csv` with the following fields:
   - monster_id
   - name_slug
   - family
   - rank
   - battle_canvas_size
   - field_canvas_size
   - color_count
   - animation_frame_count_idle
   - animation_frame_count_attack
   - field_frame_count
   - palette_colors (hex list)
   - generation_tool
   - generation_prompt_id
   - cleanup_status (draft / cleaned / approved)
   - ip_check_status (pending / passed)
   - reviewer
   - approval_date

6. Set `cleanup_status` to `approved`.

### 12.6 Step 6: Field Sprite Creation

If the field sprite was not created during Step 4, create it now:

1. Open the approved battle sprite in Aseprite
2. Create a new 16x16 canvas
3. Redraw the creature at 16x16 resolution:
   - Same palette (same colors from the master palette)
   - Same outline rules (1px, same outline color)
   - Simplified silhouette: remove small details, reduce appendage complexity
   - The creature must still be recognizable as the same creature
   - The three-mass composition should still hold at 16x16 (head + body + appendage)
4. Create 8 frames (2 per direction x 4 directions) as described in Section 8.4
5. Export as sprite sheet (64x32 pixels total, 4 columns x 2 rows)
6. Run through the Quality Checklist items relevant to field sprites (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, D1, D11, A6)

---

## 13. Reference Tables

### 13.1 Complete Rank Specification Summary

| Property | E | D | C | B | A | S |
|----------|---|---|---|---|---|---|
| Battle canvas (px) | 24x24 | 32x32 | 32x32 | 48x48 | 48x48 | 56x56 |
| Field canvas (px) | 16x16 | 16x16 | 16x16 | 16x16 | 16x16 | 16x16 |
| Menu canvas (px) | 16x16 | 16x16 | 16x16 | 16x16 | 16x16 | 16x16 |
| Codex canvas (px) | 64x64 | 64x64 | 64x64 | 64x64 | 64x64 | 64x64 |
| Color budget (min) | 4 | 5 | 6 | 7 | 8 | 9 |
| Color budget (max) | 5 | 6 | 7 | 8 | 9 | 10 |
| Canvas fill % (min) | 65% | 70% | 70% | 75% | 75% | 80% |
| Canvas fill % (max) | 75% | 80% | 80% | 85% | 85% | 90% |
| Eye size (px per eye) | 1-2 | 2-3 | 2-4 | 3-5 | 4-6 | 4-6 |
| Idle frames | 2 | 2 | 2 | 2 | 2 | 2 |
| Attack frames | 0 | 0 | 0 | 0 | 0 | 3 |
| Field frames (total) | 8 | 8 | 8 | 8 | 8 | 8 |
| Idle frame timing (ms) | 500 | 500 | 500 | 500 | 500 | 500 |
| Attack frame timing (ms) | n/a | n/a | n/a | n/a | n/a | 150 |
| Outline thickness (px) | 1 | 1 | 1 | 1 | 1 | 1 |
| Ground line (% from top) | 85-90% | 85-90% | 85-90% | 85-90% | 85-90% | 85-90% |

### 13.2 Family Silhouette Quick Reference

| Family | Primary Shape | Weight Center | Key Feature | Forbidden Shape |
|--------|--------------|---------------|-------------|-----------------|
| beast | Four-limbed stance | Low-center, grounded | Weight on legs, muscular body | Floating, stick-thin legs, head > body |
| bird | Vertical upright | Upper-center, perched | Beak, vertical proportion | Horizontal flying, bat wings, ball body |
| plant | Bottom-heavy spread | Bottom, rooted | Organic irregularity, spreading base | Potted plant, single stem, perfect symmetry |
| material | Geometric assembled | Center, constructed | Hard edges, object identity | Face painted on, too clean, limbs glued on |
| magic | Floating/light | Upper-center, hovering | Geometric pattern, weightlessness | Generic orb, wizard hat, flame-as-body |
| undead | Damaged version of another family | Uneven, off-balance | Missing parts, gaps, bright eye accent | Zombie green, cute skeleton, excessive gore |
| dragon | Heavy skeletal | Low-center, planted | Horns, tail, skeletal authority | Western cliche, cute baby, wyvern-only |
| divine | Symmetrical still | Center, perfectly balanced | Intense eyes, ceremonial elements | Angel wings, halos, white robes |
| slime | Round/droplet | Bottom-center, spreading | Roundness, softness, surface interest | DQ teardrop, perfect circle, dry surface |

### 13.3 Color Role Quick Reference

| Role # | Role Name | Count | Mandatory Rank | Usage |
|--------|-----------|-------|----------------|-------|
| 1 | Outline | 1 | All | Outer contour, internal divisions, eyes |
| 2 | Body Base | 1 | All | Primary surface fill, largest area |
| 3 | Body Shadow | 1 | All | Shading, bottom-right of masses |
| 4 | Accent | 1 | All | Secondary features, markings, accessories |
| 5 | Highlight | 0-1 | D+ | Eye gleam, wet surface, metallic sheen |
| 6 | Detail 1 | 0-1 | C+ | Additional feature, secondary region |
| 7 | Detail 2 | 0-1 | B+ | Further distinction, tertiary element |

### 13.4 Animation Movement Quick Reference

| Movement Type | Description | Pixel Displacement | Suitable Families |
|---------------|-------------|-------------------|-------------------|
| Ear twitch | One ear moves up or down | 1px | beast, bird, dragon |
| Tail sway | Tail tip shifts left or right | 1-2px | beast, dragon, magic |
| Body bob | Entire body shifts up or down | 1px | All families |
| Wing shift | Folded wing edge moves up or down | 1px | bird, dragon, divine |
| Eye blink | Highlight pixel appears/disappears | 0px displacement, 1px change | All families |
| Chest pulse | Shadow boundary on chest shifts | 1px | beast, dragon, undead |
| Horn glow shift | Highlight pixel on horn appears/disappears | 0px displacement, 1px change | beast, dragon, divine |
| Tendril wave | Tendril or vine tip shifts | 1-2px | plant, magic, slime |
| Surface ripple | Shadow or color region shifts | 1px | slime, magic, plant |
| Jaw clench | Jaw line shifts slightly | 1px | dragon, beast, undead |

---

## 14. Glossary

| Term | Definition |
|------|-----------|
| **1x scale** | Native pixel resolution. A 24x24 sprite displayed as 24x24 pixels on screen. No zoom, no scaling. |
| **3/4 view** | A viewing angle approximately 30-45 degrees from frontal, showing the creature's face and one side of its body simultaneously. |
| **Accent color** | A secondary color used for specific features that contrast with the body base. Role 4 in the color role system. |
| **Anchor point** | The center of mass or base position of a creature that remains stable across animation frames. |
| **Anti-aliasing** | Blending pixels at edges to create smoother-looking lines. Prohibited in all sprites. |
| **Aseprite** | The pixel art editor used as the primary production tool for all sprites. Source files are saved in `.aseprite` format. |
| **Banding** | A shading artifact where parallel bands of different shades follow the outline contour. Prohibited. |
| **Body base** | The dominant fill color of the creature. Role 2 in the color role system. |
| **Body shadow** | A darker version of the body base used for shading. Role 3 in the color role system. |
| **Canvas** | The total pixel area of the sprite file, including transparent background. |
| **Cel shading** | A shading technique using flat color regions with hard boundaries between light and shadow. |
| **Codex** | The in-game monster encyclopedia/gallery. |
| **Dithering** | Using alternating pixels of two colors to simulate a third color. Prohibited. |
| **Edge clearance** | The minimum transparent border between the creature and the canvas edge. Minimum 1px. |
| **Fill percentage** | The ratio of opaque pixels to total canvas pixels, expressed as a percentage. |
| **Focal point** | The visual element that draws the viewer's eye first. Usually the eyes; for eyeless creatures, an alternative focal point. |
| **Ground line** | An invisible horizontal line where grounded creatures' feet or base rests. Located at 85-90% of canvas height from top. |
| **Highlight** | The brightest color in the sprite, used sparingly for gleam, reflection, or emphasis. Role 5 in the color role system. |
| **Idle pose** | The creature's default at-rest position. Standing, hovering, or resting. Not attacking, not running. |
| **Indexed color** | A PNG color mode where each pixel references a palette index rather than storing full RGB values. |
| **Master palette** | The 32-color palette shared by all game assets, defined in `tools/palette-remap/master_palette.hex`. |
| **Nearest-neighbor** | A pixel resampling method that does not blend colors. The only resampling method allowed for sprites. |
| **Orphan pixel** | A single opaque pixel with no adjacent opaque neighbor on any cardinal side. Prohibited unless deliberate. |
| **Outline** | The 1px border defining the creature's shape. Role 1 in the color role system. |
| **palette_remap.py** | The script that maps arbitrary colors to the nearest master palette colors. |
| **Pillow shading** | A shading artifact where shadow surrounds the shape equally on all sides, ignoring light direction. Prohibited. |
| **Primary motif** | The creature's main visual identity — what it IS (a ram, a mushroom, a cage-mouse). |
| **Secondary motif** | A world-connection visual element (pastoral, funerary, bureaucratic, gatebound, household, astral). |
| **Silhouette** | The outline shape of the creature when filled with a single solid color. |
| **Sprite sheet** | A single image file containing multiple animation frames arranged in a grid. |
| **Stairstepping** | The pixel-level rendering of diagonal or curved lines using stepped horizontal or vertical runs. |
| **Taboo element** | A single subtle visual feature connecting the creature to the tower/gate mystery. |
| **Three-mass rule** | The requirement that every creature decompose into exactly 3 major visual masses. |
| **Two-tone shading** | Using exactly 2 color values (base + shadow) per body region. No gradients, no third value. |

---

## 15. Document Version History

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | 2026-03-15 | Initial comprehensive production manual |
