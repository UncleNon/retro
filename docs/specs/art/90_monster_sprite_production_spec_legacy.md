# 90. Monster Sprite Production Spec Legacy

> **Status**: Legacy Draft v1.0
> **Last Updated**: 2026-03-15
> **References**:
> - `docs/specs/art/01_style_bible.md`
> - `docs/specs/content/06_monster_taxonomy_and_motif_rules.md`
> - `docs/specs/content/01_vertical_slice_monsters.md`
> - `docs/requirements/04_monster_design.md`
> - `docs/requirements/08_art_pipeline.md`

---

## 0. Purpose

This document is a **legacy draft reference** for monster sprite production. The canonical production authority is `docs/specs/art/02_monster_sprite_production_manual.md`.

If a conflict exists, this file does not win. Escalate to the canonical production manual instead.

---

## 1. Pixel Specifications

### 1.1 Canvas Sizes

Every monster requires multiple sprite types. The exact canvas sizes are:

| Sprite Type | Canvas Size | Usage |
|-------------|-------------|-------|
| Battle sprite | Rank-dependent (see 1.2) | Battle scene, party display, detail views |
| Field sprite | 16x16 px | Overworld, following party, field encounters |
| Icon (small) | 8x8 px | Inline text icons, compact lists |
| Icon (large) | 16x16 px | Party menu, bestiary grid, item thumbnails |

### 1.2 Battle Sprite Size by Rank

| Rank | Primary Canvas | Allowed Alternative | When to Use Alternative |
|------|---------------|--------------------|-----------------------|
| E | 24x24 px | 32x32 px | Only if the silhouette_type is `wide` or `tall` and cannot read at 24x24 without losing the defining shape mass. Requires art lead approval. |
| D | 32x32 px | None | Always 32x32. No exceptions. |
| C | 32x32 px | 48x48 px | Only for `massive` or `wide` silhouette_types where the motif demands extra room (e.g., a sprawling mushroom colony). Requires art lead approval. |
| B | 48x48 px | None | Always 48x48. No exceptions. |
| A | 48x48 px | 56x56 px | Only for `massive` silhouette_type. Requires art lead approval. |
| S | 56x56 px | None | Always 56x56. No exceptions. |

### 1.3 Padding Rules

| Sprite Type | Minimum Margin (all sides) | Maximum Margin (all sides) | Notes |
|-------------|---------------------------|---------------------------|-------|
| Battle 24x24 | 1 px | 3 px | The creature must touch at least one edge's margin boundary (usually bottom). |
| Battle 32x32 | 1 px | 4 px | Same touch rule. |
| Battle 48x48 | 2 px | 5 px | Same touch rule. |
| Battle 56x56 | 2 px | 6 px | Same touch rule. |
| Field 16x16 | 0 px | 1 px | Creature fills as much as possible. |
| Icon 8x8 | 0 px | 1 px | Creature fills as much as possible. |
| Icon 16x16 | 0 px | 1 px | Same as field. |

**Fill ratio**: The creature's opaque pixels must occupy **70% to 85%** of the total canvas area. Below 70% the sprite looks lost; above 85% the sprite looks cramped and the outline merges with the canvas edge.

### 1.4 Center of Gravity

- **Horizontal center**: The visual center of mass must fall within the **center 50% horizontal band** of the canvas. For a 32x32 canvas, the center of mass must be between x=8 and x=24.
- **Vertical center**: The visual center of mass should sit in the **lower 60%** of the canvas for grounded creatures (`round`, `wide`, `tripod`, `massive` silhouettes) or the **center 60%** for floating creatures (`floating` silhouette).
- **Serpentine exception**: `serpentine` silhouettes may distribute mass more freely but must still have a clear visual anchor point in the lower half.

### 1.5 Foot / Ground Line Position

The ground line is the lowest row of pixels where the creature contacts the implied ground plane.

| Canvas Size | Ground Line Row (from bottom, 0-indexed) | Notes |
|-------------|------------------------------------------|-------|
| 24x24 | Row 1 (y=22 in 0-indexed top-left origin) | 1 px of empty space below the feet. |
| 32x32 | Row 1 to Row 2 (y=29 to y=30) | 1-2 px of empty space below. |
| 48x48 | Row 2 to Row 3 (y=44 to y=45) | 2-3 px of empty space below. |
| 56x56 | Row 2 to Row 4 (y=51 to y=53) | 2-4 px of empty space below. |
| 16x16 (field) | Row 0 to Row 1 (y=14 to y=15) | 0-1 px below. Feet can touch the very bottom row. |

**Floating creatures**: No ground line. The lowest pixel of the creature must be at least **3 px above the bottom edge** for battle sprites and **2 px above** for field sprites to sell the floating read.

---

## 2. Outline Rules

### 2.1 Line Thickness

- **Always 1 px**. No exceptions for any rank, size, or sprite type.
- Interior detail lines are also 1 px.
- There is no 2 px outline anywhere in the project.

### 2.2 Outline Color

| Context | Color Rule |
|---------|-----------|
| Default | The **darkest color in that sprite's palette**. This is usually a near-black but NOT necessarily `#000000`. |
| Override | Pure `#000000` is permitted when the sprite's palette is very dark overall and the darkest palette color does not provide sufficient contrast against the primary body color. |
| Requirement | The outline must be perceptually readable as a "dark edge" at 1x scale. If the darkest palette color is lighter than `#333333`, it is too light for an outline; choose a darker color or add one to the palette (it counts toward the color budget). |

### 2.3 Corner Handling

- **No isolated diagonal pixels**. A single pixel touching only diagonally (no orthogonal neighbor in the outline) is forbidden. This creates a jagged, noisy look.
- **Minimum corner cluster**: Every corner turn in the outline must use at least a **2 px L-shape** or a **2x2 block minus one corner pixel** (stairstep). This ensures corners read as intentional direction changes, not noise.
- **Staircase rule**: When the outline traverses a diagonal, it must use a consistent staircase pattern. A 1:1 staircase (one pixel horizontal, one pixel vertical, repeating) is the standard. A 2:1 staircase (two pixels horizontal, one pixel vertical) is acceptable for gentle slopes. Mixing staircase ratios on the same contour segment is forbidden.

### 2.4 Outline Breaks

Outline breaks (intentional gaps in the outer contour) are allowed under these conditions only:

- **Location**: Only on the **top-left quadrant** of the creature, where the implied light source (top-left, 45 degrees) would create a highlight that "eats" the outline.
- **Maximum break length**: 2 px for 24x24 sprites, 3 px for 32x32 sprites, 4 px for 48x48 and 56x56 sprites.
- **Count**: Maximum **2 outline breaks** per sprite for ranks E-C. Maximum **3 breaks** for ranks B-S.
- **Never break the outline** on the bottom edge, the right edge, or any edge that faces away from the light source.
- **Field sprites (16x16)**: Outline breaks are **forbidden**. The outline must be fully closed at this size for readability.
- **Icons (8x8, 16x16)**: Outline breaks are **forbidden**.

### 2.5 Interior Lines

- Interior lines (lines separating body regions, limbs, features) use the **same outline color** as the exterior outline.
- Interior lines must connect to the exterior outline at both endpoints. Floating interior lines (not connected to any edge) are forbidden, as they read as noise at 1x.
- **Exception**: Eye dots, mouth lines, and small mark details (brand marks, tally marks) may float if they are at least **2 px in total area** and are clearly intentional features.

---

## 3. Palette Rules

### 3.1 Maximum Colors Per Rank

These counts include the outline color but **exclude** the transparent background.

| Rank | Minimum Colors | Maximum Colors | Recommended |
|------|---------------|----------------|-------------|
| E | 4 | 5 | 4 |
| D | 5 | 6 | 5 |
| C | 6 | 7 | 6 |
| B | 7 | 8 | 7 |
| A | 8 | 9 | 8 |
| S | 9 | 10 | 9 |

Going below the minimum is a **fail**. Going above the maximum is a **fail**. The recommended count is the target; deviations toward min or max require a documented reason.

### 3.2 Color Role Definitions

Every sprite's palette must map to these roles. Not all roles are required at every rank.

| Role | Definition | Required At |
|------|-----------|------------|
| **Outline** | Darkest color. Used for outer contour, interior lines, eyes, deep shadows, holes. | All ranks |
| **Primary** | The dominant body color. Defines the creature's visual identity. Occupies the largest pixel area after outline. | All ranks |
| **Shadow** | A darker value of the primary color. Used for form shadow on the side opposite the light source. Must be perceptibly darker than primary but NOT as dark as the outline. | All ranks |
| **Secondary** | A distinct hue from the primary. Used for sub-regions: belly, inner ear, wing membrane, underbelly, different material. | D and above |
| **Highlight** | A lighter value of the primary OR secondary. Placed on surfaces facing the light source. Must be perceptibly lighter than primary. | C and above |
| **Accent** | A hue with high contrast against primary and secondary. Used for element/attribute markers, eyes (if colored), small motif details (brand marks, seal stamps, glowing cracks). Limited to **no more than 8% of total opaque pixel area**. | D and above (optional at E) |
| **Anomaly** | A color that does not belong to the creature's natural palette -- cold where the palette is warm, or vice versa. Used exclusively for gate-touched marks, tower resonance, or record-bent details. Limited to **no more than 5% of total opaque pixel area**. | B and above (optional at C) |

### 3.3 Warmth and Coolness Rules

#### By World Type

| World Type | Palette Temperature | Specific Guidance |
|------------|-------------------|-------------------|
| Village / pastoral | Warm-neutral | Earth tones, soot, dried straw, clouded glass, dull green. Avoid saturated primaries. |
| Tower periphery | Cool | Grey-blue, bone white, cold metal, murky moonlight. Warm accents only for anomaly marks. |
| Otherworld nature | Mixed but muted | Desaturated vivid hues, sunken complementaries. Neither pure warm nor pure cool. |
| Deep layer / gate interior | Cold with metallic warmth | Reflective white, cold purple, tarnished gold, dark blood-red. High contrast between cool base and warm accent. |

#### By Family

| Family | Default Temperature | Notes |
|--------|-------------------|-------|
| `slime` | Cool-neutral | Milky white, dull grey, indigo-ink, salt-green. Never bright blue primary. |
| `beast` | Warm | Brown, rust, soot-grey, cream. |
| `bird` | Cool-warm split | Cool body, warm beak/feet/tags. |
| `plant` | Warm-green | Moss, wet earth, rot-brown. Never saturated lime. |
| `material` | Neutral-cool | Stone grey, bone, tarnished metal. Warm only for wood elements. |
| `magic` | Cool | Ink-dark, faded vermillion, cracked-stone grey. |
| `undead` | Cool-desaturated | Ash, dried bone, grave-water teal. No saturated purple cliche. |
| `dragon` | Warm-cool split | Warm scales, cool horns/spines/eyes. |
| `divine` | Cool with gold | Grey-blue base, pale gold accent. Never pure white glow. |

### 3.4 Transparency

- **Background**: Always fully transparent (alpha = 0). No background elements, no ground shadow, no ambient glow, no halo.
- **Semi-transparency**: Forbidden. Every pixel is either fully opaque (alpha = 255) or fully transparent (alpha = 0). No alpha blending, no partial opacity.

### 3.5 Shadow Rules

- **Drop shadow**: Forbidden. No shadow cast beneath the creature onto an implied ground plane.
- **Form shadow**: Required. Achieved using the Shadow palette role color placed on surfaces facing away from the light source (bottom-right areas, undersides, recesses).
- **Cast shadow on self**: Allowed. When one body part overlaps another (e.g., an arm in front of a torso), the occluded part uses the shadow color at the overlap boundary. This is a 1 px strip of shadow color maximum.
- **Ambient occlusion**: Forbidden as a separate pass. Any darkening in crevices must come from the single shadow color, not a separate AO color.

---

## 4. Anatomy and Silhouette Rules

### 4.1 Readable Mass Rule

At 1x (native resolution, no zoom), every battle sprite must read as **3 or fewer distinct shape masses**. A shape mass is a visually cohesive region that the eye groups together.

| Example Count | Typical Breakdown |
|--------------|-------------------|
| 1 mass | Body blob (slimes, simple E-rank creatures) |
| 2 masses | Body + head, or body + appendage cluster |
| 3 masses | Body + head + tail/wings/weapon/distinctive feature |

**Test procedure**: View the sprite at 1x on a neutral grey (`#808080`) background. Squint or defocus your eyes. Count the distinct blobs you perceive. If the answer is 4 or more, the design needs simplification.

### 4.2 Silhouette Types

Each monster is assigned one silhouette type. The silhouette constrains the overall shape envelope.

| Type | Aspect Ratio (W:H) | Shape Characteristics | Typical Families |
|------|--------------------|-----------------------|-----------------|
| `round` | ~1:1 | Roughly circular or square mass. Low center of gravity. Compact. | slime, beast (small), plant (mushroom) |
| `wide` | >1.3:1 | Horizontally extended. Sprawling, low, or multi-limbed. | plant, beast (quadruped), material (furniture) |
| `tall` | <0.7:1 | Vertically extended. Standing upright, elongated neck/ears/horns. | bird, material (scarecrow/pillar), divine |
| `serpentine` | Variable | S-curve or coiled. The longest axis is neither purely horizontal nor vertical. | magic, dragon, beast (snake-like) |
| `floating` | ~1:1 | No ground contact. Centered in canvas. Slightly elevated. | magic, divine, undead (ghost-type) |
| `tripod` | ~1:1 | Three distinct support points or an irregular base. Asymmetric feel. | material, plant, undead |
| `massive` | >1:1 | Fills canvas aggressively (80-85%). Heavy, imposing, high pixel density. | dragon (high rank), divine (high rank) |

### 4.3 Eye Placement and Style

| Rank | Eye Style | Size | Placement |
|------|----------|------|-----------|
| E | Single-pixel dot or 2px horizontal line | 1-2 px | Upper third of the head mass. Centered or slightly forward-facing. |
| D | Dot with 1px highlight OR simple 2x1 rectangle | 1-2 px | Upper third of head. |
| C | 2x2 eye with pupil/highlight distinction | 2-4 px total | Eyes may show direction. Slight personality allowed. |
| B | Shaped eye (almond, narrow, round with visible iris) | 3-6 px total | Character-specific placement. Asymmetry allowed if family is `magic`, `undead`, or `divine`. |
| A | Detailed eye with iris, pupil, and highlight. May include multiple eyes or unusual eye placement. | 4-8 px total | Design-driven. Must reinforce the motif. |
| S | Fully designed eyes that anchor the creature's personality. May glow, may be hollow, may be non-standard shapes. | 4-10 px total | Free placement. Eyes are a signature feature at this rank. |

**Universal eye rules**:
- Eyes must use the **outline color** for the darkest part (pupil or socket).
- If a highlight pixel exists in the eye, it must be the **lightest color in the palette** and placed in the **upper-left quadrant** of the eye (consistent with the top-left light source).
- `material` family creatures may have eyes that are not biological (button eyes, gem eyes, hole eyes). These still follow placement rules.
- `undead` family may use **empty socket** eyes (outline color only, no fill), but the socket must be at least 2x2 px to read as a deliberate void rather than a stray pixel.

### 4.4 Mouth and Expression Rules

- **E rank**: Mouth is optional. If present, it is a 1-2 px line or gap in the outline, on the lower portion of the head mass. No teeth detail.
- **D rank**: Simple mouth line allowed. Maximum 3 px wide. A single fang pixel is allowed if the family is `beast`, `dragon`, or `undead`.
- **C rank**: Mouth can show simple expression (open/closed). Teeth are allowed as 1-2 px details for appropriate families.
- **B rank**: Mouth is expressive. Teeth, tongue (1 px accent), open maw are all allowed. The mouth must not exceed 15% of the head mass area.
- **A-S rank**: Full expression permitted. The mouth is a design feature. Multiple rows of teeth, mandibles, beak structures, or ritual mask mouths are allowed.

**Forbidden at all ranks**:
- Anime-style open smile with visible tongue at E-D rank.
- Cute blush marks (pink pixel clusters on cheeks).
- Speech bubble or text emanating from mouth.

### 4.5 Limb Count and Proportion Guidelines

| Family | Limb Count | Proportion Rule |
|--------|-----------|----------------|
| `slime` | 0-2 pseudopods | Pseudopods should merge with the body mass, not appear as distinct appendages. At 1x they read as bumps on the silhouette, not arms. |
| `beast` | 2-4 legs + 0-1 tail | Quadrupeds: forelimbs and hindlimbs should be distinguishable by position but may overlap in the sprite. Tail counts toward the 3-mass limit only if it is large. |
| `bird` | 2 legs + 2 wings (or 0 visible wings if folded) | Wings folded: read as part of body mass. Wings extended: count as one mass (both wings together). Legs are thin, 1px wide at E-D rank. |
| `plant` | 0-4 roots/vines + 0-2 leaf arms | Roots anchor to ground line. Vines may extend above the head mass. |
| `material` | Variable (0-6) | Depends on the object motif. Arms of a scarecrow, legs of a table, handles of a tool. Must look like parts of the object, not biological limbs glued on. |
| `magic` | 0-4 tendrils/arms | May float separate from body. Tendrils can be 1 px wide. |
| `undead` | Same as original creature type, minus 0-2 | Missing limbs are a design feature. Stumps should be visible (1-2 px of shadow color). |
| `dragon` | 4 legs + 2 wings + 1 tail (classic) or reduced | At 24-32 px, simplify: show 2 visible legs + wing silhouette + tail. At 48-56 px, full limb set is viable. |
| `divine` | Variable | Often fewer visible limbs. Robes, mantles, or geometric forms may obscure limbs. Ceremonial stillness is key. |

### 4.6 "Must Keep Shape" Elements

Every monster has a `must_keep_shape` field listing 1-3 visual elements that **cannot be altered during edit passes** without art lead approval. These are the identity anchors.

Examples of must-keep elements:
- "charcoal-black horn tips" (MON-001 Mokukeda)
- "pointing-finger wing shape" (MON-008 Yubigarasu)
- "bone-cage rib arches over back" (MON-004 Kagohonezumi)

**Rule**: During any AI re-generation or manual edit pass, the prompt or edit instruction must explicitly protect these elements. The Edit Notes block (see Section 8.7) includes a `keep` clause for this purpose.

### 4.7 Asymmetry Rules

| Rank | Asymmetry Rule |
|------|---------------|
| E | **Symmetry strongly preferred**. The creature should be nearly left-right symmetric. Minor asymmetry (e.g., one ear tag on the left ear only) is allowed for motif reasons but the overall silhouette should read as symmetric. |
| D | **Mostly symmetric** with one asymmetric detail. The asymmetric detail must be a motif-driven element (a stolen name tag, a cracked horn, a missing feather). |
| C | **One major asymmetric feature** is allowed and encouraged. This is the rank where "a visual quirk" enters the silhouette. |
| B | **Asymmetry is expected**. At least one element should break symmetry in a way visible in the silhouette (not just an internal detail). |
| A | **Significant asymmetry**. The creature should feel like it has history -- wear, damage, mutation, or ritualistic modification that makes perfect symmetry impossible. |
| S | **"Unseen skeleton"** rule. The creature's asymmetry should suggest a bone structure or anatomy that does not exist in reality. One area of the body defies the logic of the rest. |

---

## 5. Animation Frame Budget

### 5.1 Battle Idle

| Property | Value |
|----------|-------|
| Frame count | 2 |
| Frame 1 | Default pose. This is the "rest" state. |
| Frame 2 | Subtle shift: 1-2 px vertical bob (breathing), or 1-2 px appendage shift (tail flick, ear twitch, pseudopod pulse). |
| Frame timing | 500 ms per frame (1000 ms total loop). |
| Loop | Yes, infinite. Ping-pong is forbidden; always loop 1-2-1-2. |
| Delta between frames | Maximum **6 pixels** may change between frame 1 and frame 2. "Change" means a pixel that is a different color or transparency state. |
| Restrictions | The silhouette may shift by no more than 1 px in any direction. The creature does not translate across the canvas. Center of mass stays within 1 px of its frame-1 position. |

### 5.2 Battle Attack

| Property | Value |
|----------|-------|
| Frame count | 2 frames for ranks E-A. 3 frames for rank S only. |
| Frame 1 (windup) | The creature coils, leans back, or gathers. Duration: 150 ms. |
| Frame 2 (strike) | The creature extends, lunges, or releases. Duration: 150 ms. |
| Frame 3 (S-rank only, follow-through) | The creature recoils or settles from the extreme pose. Duration: 150 ms. |
| Return | After the attack frames play once, the sprite returns to idle frame 1. The transition is instantaneous (no tweening). |
| Delta between frames | Maximum **30% of opaque pixels** may change between any two consecutive attack frames. This allows significant motion while keeping the creature recognizable. |
| Translation | The creature may shift up to **4 px** toward the target (rightward for player monsters, leftward for enemy monsters) during the strike frame. It must return to origin after. |

### 5.3 Battle Hit / Damage

| Property | Value |
|----------|-------|
| Frame count | 1-2 frames. |
| Method | **Flash overlay**: The sprite is rendered with a white (`#FFFFFF`) color overlay at 50% for 100 ms, then returns to normal. This is a shader effect, NOT a separate sprite frame. |
| Optional recoil frame | 1 additional frame where the creature shifts **2 px away from the attacker** (leftward for player monsters, rightward for enemy monsters). Duration: 150 ms. Then snap back to idle frame 1. |
| Sprite frame requirement | The recoil frame, if used, is a **separate drawn frame** that shows a slight lean or compression. Maximum **15% pixel delta** from idle frame 1. |

### 5.4 Battle Faint / KO

| Property | Value |
|----------|-------|
| Frame count | 0 additional frames. |
| Method | Programmatic: the idle sprite fades to 0% opacity over 300 ms while shifting 2 px downward. No custom art frame needed. |

### 5.5 Field Walk

| Property | Value |
|----------|-------|
| Frame count | 2 frames per direction x 4 directions = 8 frames total. |
| Directions | Down (toward camera), Up (away from camera), Left, Right. |
| Frame 1 per direction | Idle/stand pose facing that direction. Left foot (or equivalent) forward. |
| Frame 2 per direction | Walk pose. Right foot (or equivalent) forward. |
| Frame timing | 200 ms per frame (400 ms per full step cycle). |
| Canvas | Always 16x16 px regardless of rank. |
| Simplification | At 16x16, the creature is dramatically simplified from its battle sprite. The must-keep shape elements should still be hinted at but may lose detail. Color count may be reduced by 1-2 from the battle palette. |
| Mirror rule | Left-facing and right-facing sprites **may** be horizontal mirrors of each other ONLY if the creature has no asymmetric must-keep features visible at 16x16. If it does, both directions must be hand-drawn. |

### 5.6 Field Idle

| Property | Value |
|----------|-------|
| Frame count | 1 frame. |
| Which frame | Same as field walk frame 1 (down-facing). |
| Usage | When the creature is stationary on the overworld. |

### 5.7 Frame Timing Summary Table

| Animation | Frames | ms/Frame | Total Duration | Loops |
|-----------|--------|----------|---------------|-------|
| Battle idle | 2 | 500 | 1000 ms | Infinite |
| Battle attack (E-A) | 2 | 150 | 300 ms | Once |
| Battle attack (S) | 3 | 150 | 450 ms | Once |
| Battle hit flash | N/A | 100 | 100 ms | Once |
| Battle hit recoil | 1 | 150 | 150 ms | Once |
| Battle KO | 0 | N/A | 300 ms (programmatic) | Once |
| Field walk | 2 | 200 | 400 ms/cycle | While moving |
| Field idle | 1 | N/A | Static | While stopped |

---

## 6. Light Source

### 6.1 Direction

The light source is **always from the top-left at 45 degrees**. This applies to every monster sprite in every context (battle, field, icon) without exception. There is no per-world, per-family, or per-rank variation in light direction.

### 6.2 Highlight Placement

- Highlights (using the Highlight palette role) are placed on surfaces that face the **upper-left**: top edges, left edges, top-left curves, and any surface angled upward-and-leftward.
- On a round form, the highlight occupies approximately the **upper-left 25%** of the surface.
- On a flat top surface, the highlight runs along the **left half** of the top edge.
- **Size constraint**: Highlight area must not exceed **15% of total opaque pixel area**. Highlights that are too large make the sprite look wet or glossy, which is forbidden unless the creature is explicitly wet/slimy (family `slime` with moisture motif).
- **Slime exception**: `slime` family creatures may have a single **specular highlight pixel** (the lightest palette color, placed as a 1x1 or 1x2 dot) in the upper-left region of their body to suggest translucency. This is the only case where a single bright pixel is allowed.

### 6.3 Shadow Placement

- Form shadows (using the Shadow palette role) are placed on surfaces facing **lower-right**: bottom edges, right edges, undersides, and recesses.
- On a round form, shadow occupies approximately the **lower-right 30-40%** of the surface.
- On limbs, shadow appears on the **right side and underside** of each limb.
- **Size constraint**: Shadow area should be **20-35% of total opaque pixel area**. Too little shadow makes the creature look flat; too much makes it look muddy.

### 6.4 Forbidden Lighting Techniques

| Technique | Status | Reason |
|-----------|--------|--------|
| Subsurface scattering | Forbidden | Requires translucency gradients and too many color steps. |
| Rim lighting | Forbidden | Implies a secondary light source. |
| Backlighting | Forbidden | Contradicts the single top-left source. |
| Ambient occlusion (as separate color) | Forbidden | Use the shadow color only; no third darkness tier between shadow and outline. |
| Specular highlight > 2 px | Forbidden (except slime) | Oversized specular reads as metallic or wet. |
| Color-shifted shadows (e.g., blue shadow on red body) | Forbidden | Implies atmospheric lighting. Shadows are always a darker value of the same hue. Hue shift is limited to max 10 degrees on the color wheel. |

---

## 7. AI Prompt Construction Rules

All monster sprite prompts follow a strict 6-block architecture. Every block has defined content. Prompts are stored in the project's prompt database with the monster's `monster_id` as the key.

### 7.1 Block 1: Invariant (Mandatory, Exact Text)

This block is identical for every monster. The only variable is `{battle_sprite_px}`, which is replaced with the canvas size number (24, 32, 48, or 56).

```text
pixel art, {battle_sprite_px}x{battle_sprite_px} battle sprite, transparent background,
1px black outline, top-left lighting, no anti-aliasing, no dithering, no gradient,
no smooth shading, gbc-inspired limited palette, readable at 1x, no text, no logo
```

**Do not alter this block.** Do not add words. Do not remove words. Do not reorder. The only permitted change is the pixel size variable.

### 7.2 Block 2: Body (Template with Variables)

```text
{creature_description}, {silhouette_type_phrase}, {pose_phrase},
{color_count} color palette, dominant tones: {tone_1} and {tone_2},
accent color: {accent_description}
```

Variable definitions:

| Variable | Source | Rules |
|----------|--------|-------|
| `{creature_description}` | Monster design doc | 1-3 sentences. Start with article + adjective + noun. Describe the creature's physical form, motif integration, and most distinctive feature. Primary motif comes first in the description. Secondary motif is woven as a physical detail. |
| `{silhouette_type_phrase}` | `silhouette_type` field | Map to: "compact rounded silhouette" (round), "broad low silhouette" (wide), "narrow upright silhouette" (tall), "S-curved flowing silhouette" (serpentine), "levitating centered silhouette" (floating), "asymmetric three-point silhouette" (tripod), "imposing canvas-filling silhouette" (massive). |
| `{pose_phrase}` | Fixed per sprite type | Battle sprite: "in idle standing pose". Field sprite: "in front-facing idle pose". Always idle/standing. Never action poses in the base prompt. |
| `{color_count}` | Rank table (Section 3.1) | Use the recommended count. Express as range: "4-5" for E, "5-6" for D, "6-7" for C, "7-8" for B, "8-9" for A, "9-10" for S. |
| `{tone_1}`, `{tone_2}` | `primary_palette_keys` | Always two named color tones. Use descriptive compound names: "warm soot-grey", "cold grey-blue", "muted bone-white". Never use hex codes in this block. |
| `{accent_description}` | Design notes | What the accent color looks like and where it appears: "charcoal black on horns and brand", "dull copper on hanging tags". |

### 7.3 Block 3: Lore Context (Template)

```text
{lore_visual_1}, {lore_visual_2}
```

- Exactly **2 visual cues** described as physical textures, marks, or wear patterns.
- These connect the creature to the world. They are NOT narrative or backstory.
- Each cue is a short noun phrase (3-8 words).
- Draw from the Prompt Phrase Bank in `06_monster_taxonomy_and_motif_rules.md` Section 9.8.
- Examples: "burnt ear tag on left ear", "carved tally marks on bone ribs", "ash-dusted surface near the tail".

### 7.4 Block 4: Pixel Constraints (Mandatory, Exact Text with One Variable)

```text
{color_count} color palette, fill 70-85% canvas, 3 shape masses maximum,
flat interior fills, strong silhouette read, no texture noise, no smooth shading
```

The only variable is `{color_count}`, which is the **recommended** color count for the rank (a single integer: 4, 5, 6, 7, 8, or 9).

### 7.5 Block 5: Negative (Mandatory, Exact Text)

```text
do not make it pokemon-like, do not make it dragon-quest-like, do not make it digimon-like,
do not make it disney-like, do not make it anime mascot style, do not use cute blush marks,
do not use generic demon bat wings unless explicitly requested in the body block,
do not create busy background, do not add any background elements,
do not add ground shadow or drop shadow, do not add glow or halo effects,
do not add weapons unless the motif requires it, do not use realistic rendering,
do not use smooth gradients or soft shading, do not use anti-aliased edges,
do not use dithering patterns, do not add text or logos or watermarks,
do not use more colors than specified in the palette constraint,
do not add extra decorative elements not described in the body block,
do not make the creature overly symmetrical at ranks B and above,
do not make the interior pixels noisy with single-pixel color variation
```

**Do not alter this block.** It is comprehensive and applies to all monsters.

### 7.6 Block 6: Edit Notes (Template for Iteration)

Used only when requesting modifications to an existing generation. Not included in first-pass prompts.

```text
change only: {delta_request}. keep silhouette, palette logic, outline thickness,
lighting direction, motif hierarchy, and the following must-keep elements unchanged:
{must_keep_shape_list}. do not re-interpret the creature concept.
```

| Variable | Source | Rules |
|----------|--------|-------|
| `{delta_request}` | Art review feedback | Exactly what to change. Be specific: "darken the horn tips to charcoal black", "reduce the number of leaf details from 5 to 3", "move the eye 1px to the left". |
| `{must_keep_shape_list}` | Monster's `must_keep_shape` field | Comma-separated list of must-keep elements from the monster's design doc. |

### 7.7 Platform-Specific Prompt Adjustments

| Platform | Adjustment |
|----------|-----------|
| **niji 7 (Midjourney)** | Append `--ar 1:1 --niji 7` after the negative block. Do not use `--stylize` values above 100. |
| **GPT Image (1.5 / future)** | Prepend the word "pixel art style" at the very beginning of the prompt (before the invariant block) as additional emphasis. No special suffix. Reduce the body description length by 20% as GPT Image responds better to concise prompts. |
| **Nano Banana 2/Pro** | When requesting a sprite sheet, prepend: "3x3 grid sprite sheet, each cell {px}x{px}, consistent character across all cells,". The 9 cells should be: idle front, idle back, idle left, walk front frame 2, walk back frame 2, walk left frame 2, battle idle frame 1, battle idle frame 2, battle attack frame 1. |
| **Grok (animation)** | Provide the static sprite as a reference image. The text prompt should be: "animate this pixel art sprite with a subtle idle breathing motion, 2 frames, maintaining exact pixel art style, no anti-aliasing, no interpolation between frames". |

### 7.8 Prompt Assembly Order

When constructing the full prompt, concatenate the blocks in this order with double line breaks between them:

```
[Invariant]
{invariant block}

[Body]
{body block}

[Lore Context]
{lore context block}

[Pixel Constraints]
{pixel constraints block}

[Negative]
{negative block}

[Tool Suffix]
{platform-specific suffix}
```

The block labels (`[Invariant]`, `[Body]`, etc.) are included in the prompt. They help the AI model parse the structure. Do not remove them.

---

## 8. Quality Control

### 8.1 The 1x Readability Test

**Procedure**:
1. Open the sprite PNG at **1x zoom** (1 sprite pixel = 1 screen pixel) in any image viewer.
2. Set the background to neutral grey (`#808080`).
3. View from a distance of **50 cm** (approximately arm's length) on a standard 1080p display.
4. Answer the following questions. ALL must be "yes" to pass:
   - Can you identify the creature's family (beast/bird/plant/etc.) from silhouette alone?
   - Can you identify at least one must-keep shape element?
   - Can you distinguish the creature from a generic blob?
   - Can you tell which direction the creature is facing?
   - Are the eyes (if present) locatable?

**Fail criteria**: If any answer is "no", the sprite requires simplification or redesign. Common fixes: reduce interior detail, increase contrast between primary and shadow, enlarge must-keep features, simplify limb count.

### 8.2 Silhouette Uniqueness Check

**Procedure**:
1. Create a **solid black silhouette** version of the sprite (all opaque pixels become `#000000`).
2. Compare against all existing approved silhouettes in the same family.
3. Overlay silhouettes at the same scale. If **more than 70% of pixels overlap** with any existing monster in the same family, the design fails.
4. Additionally, compare against monsters in other families that share the same silhouette_type. The overlap threshold for cross-family comparison is **60%**.

**Tool**: Use the `silhouette_compare.py` script (to be implemented in the tools pipeline). Until the script exists, perform manual visual comparison by placing silhouettes on a shared canvas in Aseprite.

### 8.3 IP Similarity Screening

**Procedure**:
1. Perform a **Google Reverse Image Search** with the generated sprite upscaled to 256x256 (nearest-neighbor interpolation, no smoothing).
2. Perform a **text search** for the creature's motif description (e.g., "pixel art soot wool ram creature") on Google Images.
3. Review the top 20 results from each search.
4. **Fail criteria**: If any result shows a character from a published game, anime, manga, or franchise that shares **3 or more** of the following with our sprite: (a) silhouette shape, (b) color scheme, (c) motif combination, (d) distinctive feature placement, (e) expression style -- the sprite fails IP screening.
5. Document the screening result in the monster's metadata file with the search date, queries used, and outcome.

**Specific IP watchlist** (check these explicitly):
- Pokemon (all generations)
- Dragon Quest Monsters (all entries)
- Digimon (all seasons/games)
- Shin Megami Tensei / Persona demons
- Final Fantasy summons and monsters
- Ni no Kuni familiars
- Yokai Watch yokai
- Monster Rancher monsters
- Temtem species
- Coromon species
- Cassette Beasts species

### 8.4 Color Count Verification

**Procedure**:
1. Open the sprite in Aseprite or any editor that shows a palette index.
2. Count the number of **unique RGB values** in the image, excluding fully transparent pixels.
3. Compare against the allowed range for the monster's rank (Section 3.1).
4. **Fail** if the count is below the minimum or above the maximum.
5. Verify that each color maps to a defined palette role (Section 3.2). Any color that does not serve a named role is a wasted color and should be eliminated or reassigned.

**Automated check**: Run `palette_check.py {file} {rank}` (to be implemented). The script outputs PASS/FAIL and lists all colors with their role assignments.

### 8.5 Pixel Density Check (Interior Noise Detection)

**Procedure**:
1. Examine the **interior pixels** (all opaque pixels that are not part of the outline).
2. Count **isolated single-pixel color changes**: a pixel whose color differs from all 4 orthogonal neighbors (up, down, left, right).
3. **Threshold**: Isolated single-pixel interior anomalies must not exceed **5% of total interior pixel count** for ranks E-C, or **8%** for ranks B-S.
4. Above the threshold, the sprite has interior noise (common with AI generation). Fix by replacing isolated pixels with the color of their majority neighbor.

**Common AI noise patterns to watch for**:
- Random single-pixel dithering scattered across flat fill areas.
- Anti-aliased edges that create 1-pixel-wide color transitions between outline and fill.
- Gradient-like color ramps of 3+ intermediate colors within a single surface where only 2 (primary + shadow) should exist.
- Stray pixels from the background color bleeding into the interior.

### 8.6 Field Sprite Reduction Test

**Procedure**:
1. Take the approved battle sprite.
2. Manually redraw it at 16x16 px, preserving: family readability, facing direction, and as many must-keep shape elements as possible.
3. Apply the 1x readability test (Section 8.1) to the 16x16 version.
4. If the creature is **unrecognizable** at 16x16 -- i.e., you cannot tell its family or it looks like a random cluster of pixels -- the battle sprite design is too complex and must be simplified.

**Acceptable losses at 16x16**:
- Interior detail (flat fills replace any shading).
- Small motif marks (brand marks, tally marks, seal impressions) may be dropped.
- Limb count may be reduced (e.g., 4 legs become 2 visible legs).
- Color count may drop by 1-2 colors.
- Eyes may reduce to a single dot.

**Unacceptable losses at 16x16**:
- Silhouette type becoming unrecognizable.
- All must-keep shape elements disappearing.
- Creature reading as a different family.

### 8.7 Outline Integrity Check

**Procedure**:
1. Verify the outer contour is fully closed (no gaps except permitted outline breaks per Section 2.4).
2. Verify all outline pixels are exactly 1 px wide (no 2 px thick segments).
3. Verify no isolated diagonal pixels in the outline (Section 2.3).
4. Verify outline color is consistent (single color for the entire outline; no mixing of outline colors).
5. Verify interior lines connect to the outer outline at both endpoints (Section 2.5).

### 8.8 Animation Consistency Check

**Procedure**:
1. Overlay all frames of an animation sequence at 50% opacity to check registration.
2. Verify the creature does not drift across the canvas between frames (center of mass stays within 1 px tolerance for idle, 4 px for attack).
3. Verify the pixel delta between idle frames does not exceed 6 pixels.
4. Verify the outline remains closed in every frame.
5. Play the animation at the specified timing and verify it reads as the intended motion (breathing, bobbing, lunging, etc.) and does not appear to glitch or jump.

### 8.9 QC Checklist Summary

For every monster sprite to be approved, ALL of the following must pass:

- [ ] 1x readability test (Section 8.1)
- [ ] Silhouette uniqueness check (Section 8.2)
- [ ] IP similarity screening (Section 8.3)
- [ ] Color count verification (Section 8.4)
- [ ] Pixel density / noise check (Section 8.5)
- [ ] Field sprite reduction test (Section 8.6)
- [ ] Outline integrity check (Section 8.7)
- [ ] Animation consistency check (Section 8.8)
- [ ] Canvas size matches rank specification (Section 1.2)
- [ ] Padding/fill ratio within bounds (Section 1.3)
- [ ] Ground line position correct (Section 1.5)
- [ ] Light direction consistent (top-left) (Section 6.1)
- [ ] No drop shadow present (Section 3.5)
- [ ] Background fully transparent (Section 3.4)
- [ ] Palette warmth/coolness matches world and family (Section 3.3)
- [ ] Asymmetry level appropriate for rank (Section 4.7)
- [ ] Eye style appropriate for rank (Section 4.3)
- [ ] Must-keep shape elements present and intact (Section 4.6)
- [ ] Mass count is 3 or fewer (Section 4.1)

---

## 9. File Naming and Export

### 9.1 Source File Naming

Source files are Aseprite (`.aseprite`) format. One file per monster per sprite type.

**Pattern**:
```
mon_{id}_{slug}_{type}{size}.aseprite
```

| Component | Format | Example |
|-----------|--------|---------|
| `{id}` | 3-digit zero-padded monster number | `001`, `042`, `399` |
| `{slug}` | Lowercase ASCII transliteration of `name_jp`, max 16 chars, underscores for spaces | `mokukeda`, `tagutsutuki`, `shimerigas` |
| `{type}` | `btl` (battle), `fld` (field), `ico` (icon) | `btl`, `fld`, `ico` |
| `{size}` | Canvas dimension in pixels | `24`, `32`, `48`, `56`, `16`, `8` |

**Examples**:
```
mon_001_mokukeda_btl24.aseprite
mon_001_mokukeda_fld16.aseprite
mon_001_mokukeda_ico8.aseprite
mon_001_mokukeda_ico16.aseprite
mon_005_mayoikakashi_btl32.aseprite
mon_010_toumorinoko_btl32.aseprite
```

### 9.2 Export File Naming

Exported files are PNG format with transparency. Individual frames are exported as separate PNGs, and sprite sheets are exported as single PNGs.

**Individual frame pattern**:
```
mon_{id}_{slug}_{type}{size}_{anim}_{frame}.png
```

| Component | Format | Values |
|-----------|--------|--------|
| `{anim}` | Animation name | `idle`, `atk`, `hit`, `walk_d`, `walk_u`, `walk_l`, `walk_r` |
| `{frame}` | 1-indexed frame number | `1`, `2`, `3` |

**Examples**:
```
mon_001_mokukeda_btl24_idle_1.png
mon_001_mokukeda_btl24_idle_2.png
mon_001_mokukeda_btl24_atk_1.png
mon_001_mokukeda_btl24_atk_2.png
mon_001_mokukeda_btl24_hit_1.png
mon_001_mokukeda_fld16_walk_d_1.png
mon_001_mokukeda_fld16_walk_d_2.png
mon_001_mokukeda_fld16_walk_u_1.png
mon_001_mokukeda_fld16_walk_u_2.png
mon_001_mokukeda_fld16_walk_l_1.png
mon_001_mokukeda_fld16_walk_l_2.png
mon_001_mokukeda_fld16_walk_r_1.png
mon_001_mokukeda_fld16_walk_r_2.png
```

**Sprite sheet pattern**:
```
mon_{id}_{slug}_{type}{size}_sheet.png
```

### 9.3 Atlas Packing Rules

All monster sprites are packed into texture atlases for Godot's `AtlasTexture` system.

| Atlas | Contents | Max Atlas Size | Packing Order |
|-------|----------|---------------|---------------|
| `atlas_btl_24.png` | All 24x24 battle sprites (all frames) | 1024x1024 px | By monster_id ascending, then by frame order |
| `atlas_btl_32.png` | All 32x32 battle sprites (all frames) | 2048x2048 px | Same |
| `atlas_btl_48.png` | All 48x48 battle sprites (all frames) | 2048x2048 px | Same |
| `atlas_btl_56.png` | All 56x56 battle sprites (all frames) | 2048x2048 px | Same |
| `atlas_fld_16.png` | All 16x16 field sprites (all frames) | 2048x2048 px | Same |
| `atlas_ico_8.png` | All 8x8 icons | 512x512 px | Same |
| `atlas_ico_16.png` | All 16x16 icons | 1024x1024 px | Same |

**Packing constraints**:
- No padding between atlas cells. Sprites are placed edge-to-edge.
- Sprites are arranged in a grid where each cell is the sprite canvas size (e.g., 32x32 cells for the 32x32 atlas).
- Unused cells at the end of the atlas are left transparent.
- If a single atlas exceeds its max size, split into `atlas_btl_32_a.png`, `atlas_btl_32_b.png`, etc.
- Atlas regeneration is handled by the `atlas_pack.py` script (to be implemented).

### 9.4 Metadata JSON Structure

Every monster has a companion JSON metadata file that records production information.

**File path**: `assets/metadata/monsters/mon_{id}_{slug}.json`

```json
{
  "monster_id": "MON-001",
  "name_jp": "モクケダ",
  "slug": "mokukeda",
  "family": "beast",
  "rank": "E",
  "sprites": {
    "battle": {
      "canvas_px": 24,
      "color_count": 5,
      "palette_hex": ["#1a1a2e", "#6b5b4f", "#a89682", "#d4c4a8", "#3c2f1e"],
      "palette_roles": {
        "#1a1a2e": "outline",
        "#6b5b4f": "shadow",
        "#a89682": "primary",
        "#d4c4a8": "highlight",
        "#3c2f1e": "accent"
      },
      "frames": {
        "idle": 2,
        "attack": 2,
        "hit": 1
      },
      "source_file": "mon_001_mokukeda_btl24.aseprite",
      "export_files": [
        "mon_001_mokukeda_btl24_idle_1.png",
        "mon_001_mokukeda_btl24_idle_2.png",
        "mon_001_mokukeda_btl24_atk_1.png",
        "mon_001_mokukeda_btl24_atk_2.png",
        "mon_001_mokukeda_btl24_hit_1.png"
      ]
    },
    "field": {
      "canvas_px": 16,
      "color_count": 4,
      "palette_hex": ["#1a1a2e", "#6b5b4f", "#a89682", "#d4c4a8"],
      "frames": {
        "walk_d": 2,
        "walk_u": 2,
        "walk_l": 2,
        "walk_r": 2
      },
      "mirror_lr": true,
      "source_file": "mon_001_mokukeda_fld16.aseprite",
      "export_files": [
        "mon_001_mokukeda_fld16_walk_d_1.png",
        "mon_001_mokukeda_fld16_walk_d_2.png",
        "mon_001_mokukeda_fld16_walk_u_1.png",
        "mon_001_mokukeda_fld16_walk_u_2.png",
        "mon_001_mokukeda_fld16_walk_l_1.png",
        "mon_001_mokukeda_fld16_walk_l_2.png",
        "mon_001_mokukeda_fld16_walk_r_1.png",
        "mon_001_mokukeda_fld16_walk_r_2.png"
      ]
    },
    "icon_small": {
      "canvas_px": 8,
      "source_file": "mon_001_mokukeda_ico8.aseprite",
      "export_files": ["mon_001_mokukeda_ico8.png"]
    },
    "icon_large": {
      "canvas_px": 16,
      "source_file": "mon_001_mokukeda_ico16.aseprite",
      "export_files": ["mon_001_mokukeda_ico16.png"]
    }
  },
  "generation": {
    "tool": "niji7",
    "prompt_version": "v1.0",
    "prompt_hash": "sha256:abc123...",
    "generated_date": "2026-03-15",
    "edit_passes": 0,
    "edit_log": []
  },
  "qc": {
    "readability_1x": "pass",
    "silhouette_unique": "pass",
    "ip_screening": "pass",
    "ip_screening_date": "2026-03-15",
    "ip_screening_queries": ["pixel art soot wool ram creature"],
    "color_count_valid": "pass",
    "pixel_density_valid": "pass",
    "field_reduction_valid": "pass",
    "outline_integrity": "pass",
    "animation_consistency": "pass",
    "overall": "pass",
    "approved_date": "2026-03-15",
    "notes": ""
  }
}
```

### 9.5 Directory Structure

```
assets/
  sprites/
    monsters/
      MON-001/
        battle/
          mon_001_mokukeda_btl24_idle_1.png
          mon_001_mokukeda_btl24_idle_2.png
          mon_001_mokukeda_btl24_atk_1.png
          mon_001_mokukeda_btl24_atk_2.png
          mon_001_mokukeda_btl24_hit_1.png
        field/
          mon_001_mokukeda_fld16_walk_d_1.png
          mon_001_mokukeda_fld16_walk_d_2.png
          (... all 8 walk frames or 6 if L/R mirrored ...)
        icon/
          mon_001_mokukeda_ico8.png
          mon_001_mokukeda_ico16.png
      MON-002/
        (... same structure ...)
  atlases/
    atlas_btl_24.png
    atlas_btl_32.png
    atlas_btl_48.png
    atlas_btl_56.png
    atlas_fld_16.png
    atlas_ico_8.png
    atlas_ico_16.png
  metadata/
    monsters/
      mon_001_mokukeda.json
      mon_002_tagutsutuki.json
      (...)
  sources/
    monsters/
      mon_001_mokukeda_btl24.aseprite
      mon_001_mokukeda_fld16.aseprite
      mon_001_mokukeda_ico8.aseprite
      mon_001_mokukeda_ico16.aseprite
      (...)
```

---

## 10. Common Mistakes to Avoid

### 10.1 Over-Detailing Interior Pixels

**What it looks like**: The creature's body is filled with a patchwork of 1-pixel color variations creating a noisy, textured appearance. At 1x zoom, the interior looks like static rather than readable shapes.

**Example (text description)**: A 32x32 beast sprite where the fur is rendered with 8+ different shades scattered as individual pixels across the body. Each pixel is a slightly different brown. The result looks like a photograph converted to indexed color rather than intentional pixel art.

**Why it happens**: AI tools interpret "texture" prompts literally and produce pixel-level noise. The tool is trying to simulate fur/scales/bark at a resolution where such detail is invisible.

**How to fix**: Replace all interior noise with flat fills using only the Primary and Shadow colors. Interior detail comes from the boundary between these two colors (the shadow shape), not from per-pixel variation. No more than 2-3 distinct fill colors should exist within any single body region.

### 10.2 Gradient / Anti-Aliased Edges from AI

**What it looks like**: The outline is not a crisp 1-pixel line but a 2-3 pixel soft gradient from dark to medium to the background. Edges look blurred or smoothed. When placed on a different background color, a visible fringe of intermediate colors appears.

**Example (text description)**: A 24x24 bird sprite where the outline transitions from `#000000` to `#444444` to `#888888` before reaching the body color. The sprite looks fine on the AI tool's default grey background but develops a visible halo on transparent or colored backgrounds.

**Why it happens**: AI image generators default to anti-aliased rendering. Even when prompted for "pixel art" and "no anti-aliasing", many tools produce sub-pixel blending at edges.

**How to fix**: In Aseprite, use the "Replace Color" tool to snap all near-black outline pixels (`#000000` - `#333333`) to the single outline color. Then manually verify the outline is exactly 1 px wide everywhere. Use the eraser on any fringe pixels.

### 10.3 Losing Readability at 1x

**What it looks like**: The sprite is a detailed, attractive illustration when zoomed to 4x or 8x, but at 1x (native resolution on the 160x144 game screen) it is an indistinct smudge of color with no recognizable shape.

**Example (text description)**: A 24x24 plant sprite with delicate vine tendrils (1 px wide, multiple colors), small flowers (2x2 with 3-color gradients), and subtle root detail at the base. At 8x it looks like a botanical illustration. At 1x it looks like a green-brown blob.

**Why it happens**: Designing at zoom levels where individual pixels are large and detailed encourages micro-detail that disappears at actual game resolution.

**How to fix**: Always verify at 1x during design. Start with the silhouette (solid black shape), confirm it reads, then add color. If a detail is invisible at 1x, it is wasted effort and should be removed. The 3-mass rule (Section 4.1) prevents this by forcing broad, readable shapes.

### 10.4 Generic Silhouettes (Blob with Face)

**What it looks like**: The creature is a roughly circular or oval mass with two dots for eyes and a line for a mouth. There is no distinctive silhouette feature that identifies it as a specific monster. Five different monsters in the same family look identical when reduced to black silhouettes.

**Example (text description)**: Three E-rank slime-family monsters whose silhouettes are all slightly different sized circles. Without color, they are indistinguishable. The only differences are internal (eye shape, color pattern).

**Why it happens**: The prompt describes the creature's concept and color but does not specify silhouette-differentiating features. AI defaults to safe, round shapes.

**How to fix**: Every prompt's body block must include at least one **silhouette-defining physical feature** that would be visible even in a solid-black version: a spike, a droop, an asymmetric protrusion, an unusual proportion, a notch, a bulge, a tail curl, a horn angle. Refer to the `must_keep_shape` field -- these elements are specifically chosen to be silhouette-defining.

### 10.5 IP-Adjacent Designs

**What it looks like**: The creature, while not an exact copy, strongly evokes a specific well-known monster from another franchise. Viewers' first reaction is "that looks like [existing IP character]" rather than perceiving it as original.

**Example (text description)**: A blue slime with a teardrop shape, simple dot eyes, and a smile, regardless of color variation, reads as a Dragon Quest slime. A yellow rodent with red cheeks and a lightning-bolt tail reads as Pikachu regardless of other details.

**Why it happens**: AI models are trained on existing game art and naturally gravitate toward established archetypes. Prompts that use generic motif descriptions ("a slime creature", "a small electric mouse") produce the most common training-data interpretation.

**How to fix**:
1. Never use the generic motif alone. Always combine with a world-specific modifier from the secondary_motif_group (pastoral, funerary, bureaucratic, gatebound).
2. Run the IP similarity screening (Section 8.3) before investing in animation frames.
3. If a design triggers IP recognition, change the silhouette first (not just the color), then the distinguishing feature.
4. Refer to the project's forbidden archetypes list in the style bible (Section 5, silhouette rules): no generic teardrop slime, no generic bat-wing demons, no generic flower-with-face plants.

### 10.6 Inconsistent Light Direction

**What it looks like**: Highlights appear on the right side of the creature while shadows are also on the right. Or highlights are on top and shadows are on the left, suggesting a right-side light source instead of the mandated top-left.

**Why it happens**: AI tools do not consistently respect lighting prompts, especially when the creature's pose or form is complex. Manual edits sometimes introduce lighting errors when touching up specific areas without considering the global light direction.

**How to fix**: After every generation or edit, verify: highlights on upper-left surfaces, shadows on lower-right surfaces. Use a simple mental test: imagine a flashlight held above and to the left of the creature. Every surface facing that flashlight gets the highlight color; every surface facing away gets the shadow color.

### 10.7 Palette Drift During Edit Passes

**What it looks like**: After 2-3 rounds of AI re-generation or manual touchup, the sprite's palette has accumulated extra colors. What started as a 5-color E-rank sprite now has 8 subtly different shades, with near-duplicate colors that serve no distinct role.

**Why it happens**: Each AI re-generation introduces slight color variations. Manual touchups in Aseprite may accidentally introduce new color values if the palette is not locked.

**How to fix**: After every edit pass, run the color count verification (Section 8.4). In Aseprite, work with a **locked indexed palette** -- set the sprite to indexed color mode with exactly the allowed number of colors before editing. Any new pixel must be one of the existing palette entries.

### 10.8 Floating Limbs and Disconnected Parts

**What it looks like**: A limb, appendage, or motif detail is separated from the main body by 1+ pixels of transparent space. At 1x, it reads as a stray pixel cluster rather than a connected body part.

**Why it happens**: AI generation sometimes places small details (a hovering name tag, a floating tally mark, a detached wing tip) near but not touching the body. At high zoom this looks intentional; at 1x it looks like an error.

**How to fix**: All non-floating creatures must have a single connected opaque region. Flood-fill the sprite from any opaque pixel -- if the fill does not reach all opaque pixels, there are disconnected parts. Connect them with a 1-pixel bridge (using outline or body color) or remove the disconnected element.

**Exception**: `floating` silhouette creatures may have detached elements (orbiting fragments, hovering accessories) but these must each be at least **4 px in area** and positioned within 2 px of the main body to read as associated rather than accidental.

### 10.9 Overuse of Pure Black in Interior

**What it looks like**: Large areas of the creature's interior are filled with pure black (`#000000` or the outline color), making it impossible to distinguish outline from deep shadow from intended black-colored body parts.

**Why it happens**: Dark creatures (undead, dark-element, shadow-themed) are prompted with "dark" and "black" descriptors, and the AI fills large areas with the outline color.

**How to fix**: Even the darkest creature must have at least 2 non-outline colors in its interior. The darkest body color should be noticeably lighter than the outline color -- a minimum of **20% luminance difference** (e.g., if outline is `#0a0a0a`, darkest body fill should be at least `#2a2a2a`). Use dark blues, dark purples, or dark greens instead of pure black for body fills.

### 10.10 Battle Sprite Too Complex for Field Reduction

**What it looks like**: The battle sprite has so many thin appendages, small details, and distributed visual elements that when reduced to 16x16 for the field sprite, nothing recognizable survives. The field sprite is an unreadable cluster.

**Why it happens**: The battle sprite was designed at zoom level without considering the downstream 16x16 requirement. Complex poses, multiple thin limbs, and scattered small details all collapse at 16x16.

**How to fix**: Before finalizing the battle sprite, perform the field reduction test (Section 8.6) as a design checkpoint, not just a QC step. If the creature cannot survive reduction, simplify the battle sprite: merge thin appendages into the body mass, enlarge the must-keep features, reduce limb count, and consolidate small details into a single accent area.

---

## 11. Production Pipeline Per Monster

This section summarizes the complete workflow for producing one monster's full sprite set, referencing the detailed rules above.

### 11.1 Step-by-Step

| Step | Action | Output | Rules Reference |
|------|--------|--------|----------------|
| 1 | Confirm monster design doc is complete (`monster_id`, `family`, `rank`, `motif_source`, `silhouette_type`, `must_keep_shape`, `primary_palette_keys`) | Validated design doc | Sections 1.2, 3.1, 4.2, 4.6 |
| 2 | Determine canvas sizes | Battle size (24/32/48/56), field (16), icons (8, 16) | Section 1.2 |
| 3 | Assemble AI prompt using the 6-block architecture | Prompt text file | Section 7 (all) |
| 4 | Generate battle sprite concept (first tool: niji 7) | Raw PNG at target resolution | Section 7.7 |
| 5 | Run automatic palette check | PASS/FAIL + color list | Section 8.4 |
| 6 | Run automatic outline check (planned) | PASS/FAIL | Section 8.7 |
| 7 | Manual 1x readability test | PASS/FAIL | Section 8.1 |
| 8 | IP similarity screening | PASS/FAIL + documentation | Section 8.3 |
| 9 | If any FAIL: iterate using Edit Notes block (Section 7.6) | Revised PNG | Section 7.6 |
| 10 | Pixel cleanup in Aseprite: fix outline, snap palette, remove noise | Clean battle idle frame 1 | Sections 2, 3, 10 |
| 11 | Create battle idle frame 2 (subtle shift from frame 1) | Battle idle frame 2 | Section 5.1 |
| 12 | Create battle attack frames (2 or 3) | Attack frames | Section 5.2 |
| 13 | Create battle hit recoil frame (optional) | Hit frame | Section 5.3 |
| 14 | Create field sprites (16x16, 4 directions x 2 frames) | 8 field frames | Section 5.5 |
| 15 | Create icons (8x8, 16x16) | 2 icon PNGs | Section 1.1 |
| 16 | Run full QC checklist | All PASS | Section 8.9 |
| 17 | Export all frames as individual PNGs | Named PNGs | Section 9.2 |
| 18 | Save source Aseprite files | Named .aseprite files | Section 9.1 |
| 19 | Write/update metadata JSON | JSON file | Section 9.4 |
| 20 | Pack into atlas (batch, not per-monster) | Updated atlas PNGs | Section 9.3 |

### 11.2 Time Budget Per Monster

| Rank | Estimated Time (AI gen + cleanup + animation + QC) |
|------|---------------------------------------------------|
| E | 45-60 minutes |
| D | 60-90 minutes |
| C | 90-120 minutes |
| B | 120-150 minutes |
| A | 150-180 minutes |
| S | 180-240 minutes |

These estimates assume the AI generation produces a usable base on the first or second attempt. Add 30 minutes per additional iteration.

---

## 12. Appendix A: Frame Count Summary Per Monster

| Sprite Type | Animation | Frames | Total per monster |
|-------------|-----------|--------|-------------------|
| Battle | Idle | 2 | |
| Battle | Attack (E-A) | 2 | |
| Battle | Attack (S only) | 3 | |
| Battle | Hit (recoil, optional) | 1 | |
| **Battle subtotal (E-A)** | | | **5** (or 4 without hit recoil) |
| **Battle subtotal (S)** | | | **6** (or 5 without hit recoil) |
| Field | Walk down | 2 | |
| Field | Walk up | 2 | |
| Field | Walk left | 2 | |
| Field | Walk right | 2 | |
| **Field subtotal** | | | **8** (or 6 if L/R mirrored) |
| Icon (small) | Static | 1 | **1** |
| Icon (large) | Static | 1 | **1** |
| **Grand total (E-A)** | | | **15** (or 12 min) |
| **Grand total (S)** | | | **16** (or 13 min) |

For 400 monsters: approximately **5,200-6,400 individual sprite frames**.

---

## 13. Appendix B: Quick Reference Card

Print this page and pin it next to the monitor during production.

```
CANVAS SIZES
  E: 24x24 btl, 16x16 fld, 8x8 ico, 16x16 ico
  D: 32x32 btl, 16x16 fld, 8x8 ico, 16x16 ico
  C: 32x32 btl, 16x16 fld, 8x8 ico, 16x16 ico
  B: 48x48 btl, 16x16 fld, 8x8 ico, 16x16 ico
  A: 48x48 btl, 16x16 fld, 8x8 ico, 16x16 ico
  S: 56x56 btl, 16x16 fld, 8x8 ico, 16x16 ico

COLOR BUDGET (including outline, excluding transparency)
  E:4-5  D:5-6  C:6-7  B:7-8  A:8-9  S:9-10

OUTLINE
  Always 1px. Darkest palette color. No diagonal isolates.
  Breaks: top-left only, max 2px(24) / 3px(32) / 4px(48+).

LIGHT
  Top-left 45 deg. Always. Highlight upper-left. Shadow lower-right.

MASSES
  3 or fewer readable at 1x. Always.

IDLE ANIM
  2 frames, 500ms each, max 6px delta.

ATTACK ANIM
  2 frames (3 for S), 150ms each.

FIELD WALK
  2 frames x 4 dirs, 200ms each. 16x16 always.

FILL RATIO
  70-85% of canvas.

GROUND LINE (px from bottom)
  24: 1px  32: 1-2px  48: 2-3px  56: 2-4px  16(fld): 0-1px

FORBIDDEN
  Drop shadow. Gradient. Anti-alias. Dithering. Semi-transparency.
  Subsurface scattering. Rim light. Background elements.
  Existing IP references in prompts.
```

---

## 14. Appendix C: Revision History

| Version | Date | Changes |
|---------|------|---------|
| v1.0 | 2026-03-15 | Initial draft. All 14 sections. |

---

*End of Monster Sprite Production Spec.*
