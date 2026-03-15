# 06. Sound Design Production Manual

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-15
> **参照元**:
> - `docs/requirements/09_sound_design.md`
> - `docs/specs/art/01_style_bible.md`
> - `docs/specs/worlds/05_world_catalog_and_budget.md`
> - `docs/specs/story/04_main_story_beats_and_world_sequence.md`

---

## 1. Audio Style and Constraints

### 1.1 Target Style

The entire audio palette targets **8-bit chiptune faithful to the Game Boy Color PSG (Programmable Sound Generator) sound**. The goal is nostalgia-first authenticity: a listener should believe this soundtrack could have shipped on GBC cartridge hardware, while accepting modern quality-of-life improvements in mastering and dynamic range.

### 1.2 Channel Structure

| Channel | Type | Role | Notes |
|---------|------|------|-------|
| CH1 | Pulse wave (12.5% / 25% / 50% / 75% duty cycle) | Lead melody, counter-melody | Primary melodic voice |
| CH2 | Pulse wave (same duty options as CH1) | Harmony, secondary melody, arpeggiated chords | Supports CH1; never identical duty cycle simultaneously |
| CH3 | Wave memory (4-bit, 32-sample wavetable) | Bass, pad, custom waveforms | Provides warmth and body; can simulate brass, strings, organ |
| CH4 | Noise (7-bit or 15-bit LFSR) | Percussion, hi-hats, snares, cymbals, SFX textures | All rhythm lives here; pitch-shifted noise for tonal percussion |

### 1.3 Strict Emulation vs. Modern Tools

**Decision: Hybrid approach — modern tools constrained to 4-channel output.**

- Composers and AI generators are **not required** to use actual GBC tracker software (LSDJ, hUGETracker, etc.), but the final rendered output must **sound indistinguishable from 4-channel PSG audio** to a casual listener.
- Permitted: DAWs (Ableton, FL Studio, Reaper) with chiptune VSTs (Magical 8bit Plug, FamiTracker export, Plogue Chipsounds, YMCK Magical 8bit Plug 2).
- Permitted: AI generation tools (Suno, Udio) with post-processing to enforce channel discipline.
- Forbidden: layering more than 4 simultaneous voices in the final mix. If AI output has 6+ voices, it must be reduced to 4 in post.
- Forbidden: reverb, delay, chorus, or other effects not achievable on GBC hardware. The only exception is a subtle master limiter for loudness normalization.
- Permitted exception: SE files may use synthesized noise that does not strictly obey the 15-bit LFSR constraint, as long as the timbral result sounds 8-bit.

### 1.4 Export Specifications

| Parameter | BGM | SE | Jingles |
|-----------|-----|-----|---------|
| Format | OGG Vorbis | WAV (PCM) | OGG Vorbis |
| Sample rate | 44100 Hz | 44100 Hz | 44100 Hz |
| Bit depth | 16-bit (before OGG encoding) | 16-bit | 16-bit (before OGG encoding) |
| OGG quality | q6 (~192 kbps VBR) | N/A | q6 |
| Channels | Stereo (with mono-compatible mix) | Mono | Stereo |
| Reasoning | OGG streaming reduces memory; BGM files are large | WAV ensures zero-latency playback for instantaneous feedback | Short enough to stream; stereo for fanfare width |

### 1.5 Loudness Normalization

| Parameter | Value |
|-----------|-------|
| Target loudness | -16 LUFS (integrated) |
| True peak ceiling | -1.0 dBTP |
| Loudness range | ≤ 8 LU |
| Measurement tool | ffmpeg loudnorm filter or Youlean Loudness Meter |
| Application | All BGM, SE, and jingle files are normalized individually before integration |

**Why -16 LUFS**: Mobile-first target audience. -16 LUFS ensures audibility on phone speakers and earbuds without clipping, while leaving headroom for SE layering.

### 1.6 File Naming Convention

```
bgm_<context>_<variant>.ogg
se_<category>_<name>.wav
jingle_<context>.ogg
amb_<world_or_zone>.ogg
```

Examples:
- `bgm_title_main.ogg`
- `bgm_battle_normal_01.ogg`
- `bgm_world_w001_field.ogg`
- `se_menu_cursor_move.wav`
- `se_battle_hit_physical.wav`
- `jingle_victory.ogg`
- `amb_w001_field_wind.ogg`

---

## 2. BGM Complete Catalog

### 2.1 Overview

Total BGM count target: **48-58 tracks** (within the 40-60 range specified in requirements, skewing higher to cover 21 worlds plus shared themes).

Priority phases:
- **Phase 0**: Core loop tracks needed for vertical slice (title, 1 field, 1 battle, 1 village, victory jingle). ~5 tracks.
- **Phase 1**: All tracks needed for Act I-II content. ~20 tracks.
- **Phase 2**: Act III-V tracks, event tracks, breeding. ~20 tracks.
- **Phase 3**: Postgame, secret boss, credits, polish variants. ~10 tracks.

### 2.2 Track-by-Track Catalog

---

#### BGM-001: Title Screen

| Field | Value |
|-------|-------|
| **Track name** | `bgm_title_main` |
| **Usage** | Title screen, attract mode |
| **Mood / emotion** | Nostalgic wonder, quiet unease beneath warmth, invitation to adventure. The pastoral surface conceals a cold undertone — matching the game's "bucolic yet unsettling" visual identity. |
| **Tempo** | 100-110 BPM |
| **Key / mode** | C major with occasional borrowed chords from C minor (bVI, bVII). Dorian inflection on the B section. |
| **Loop** | Full loop. Intro (4 bars, non-looping) → A section (8 bars) → B section (8 bars) → loop back to A. |
| **Duration** | 45-60 seconds per loop cycle (after intro). Intro: 8-10 seconds. |
| **Priority** | Phase 0 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, title screen music for a monster-collecting RPG. Gentle and nostalgic opening with a hint of mystery. Tempo 105 BPM, key of C major with minor key moments. Pulse wave lead melody, wave channel bass, light noise percussion. Loop-friendly structure. No reverb, no modern effects."` |

---

#### BGM-002: Village / Home Theme (Protagonist's Village)

| Field | Value |
|-------|-------|
| **Track name** | `bgm_village_home` |
| **Usage** | Protagonist's starting village, safe hub, return-home moments |
| **Mood / emotion** | Safety, warmth, domesticity — but with an undercurrent of simplicity that will feel bittersweet in hindsight. The "life stain" (生活の染み) quality from the Style Bible. |
| **Tempo** | 88-96 BPM |
| **Key / mode** | F major, Lydian inflections for warmth |
| **Loop** | Seamless loop. A (8 bars) → B (8 bars) → A. |
| **Duration** | 50-65 seconds per loop |
| **Priority** | Phase 0 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, peaceful village theme for a monster RPG. Warm and cozy, like a small rural town. Tempo 92 BPM, F major. Simple pulse wave melody over wave channel bass. Gentle noise channel percussion like a soft march. Feels safe but slightly melancholic. Loop-friendly."` |

---

#### BGM-003: Tower Exterior Approach

| Field | Value |
|-------|-------|
| **Track name** | `bgm_tower_approach` |
| **Usage** | Overworld areas near the Tower, Tower exterior zones, moments when the Tower is visible in the distance |
| **Mood / emotion** | Awe, unease, the "cold foreign object" (冷たい異物) presence. Not hostile, but deeply alien. Quiet reverence mixed with dread. |
| **Tempo** | 60-70 BPM |
| **Key / mode** | A minor, Phrygian moments on the descent phrases |
| **Loop** | Seamless loop. Single section with slow evolution. |
| **Duration** | 70-90 seconds per loop |
| **Priority** | Phase 1 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, slow and ominous approach theme. A massive ancient tower looms ahead. Tempo 65 BPM, A minor with Phrygian flat-2 moments. Sparse pulse wave melody, deep wave channel drone, minimal noise percussion. Unsettling but not aggressive. Atmospheric chiptune."` |

---

#### BGM-004: Tower Interior (Layer 1 — Upper Floors)

| Field | Value |
|-------|-------|
| **Track name** | `bgm_tower_interior_upper` |
| **Usage** | Tower interior, upper/shallow floors |
| **Mood / emotion** | Contained tension, clinical coldness, architectural echo. The Tower as institution — organized, systematic, inhuman. |
| **Tempo** | 72-80 BPM |
| **Key / mode** | D minor, strict stepwise motion |
| **Loop** | Seamless loop |
| **Duration** | 60-75 seconds per loop |
| **Priority** | Phase 1 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, dungeon exploration theme for the interior of an ancient mysterious tower. Clinical and cold, not aggressive. Tempo 76 BPM, D minor. Repetitive pulse wave patterns suggesting machinery or ritual. Wave channel provides a low drone. Minimal noise percussion. Chiptune ambient."` |

---

#### BGM-005: Tower Interior (Layer 2 — Deep Floors)

| Field | Value |
|-------|-------|
| **Track name** | `bgm_tower_interior_deep` |
| **Usage** | Tower interior, deep floors. Fades in as player descends. |
| **Mood / emotion** | Oppressive, the boundary between institution and organism. Walls that might be breathing. The "quiet taboo" (静かな禁忌). |
| **Tempo** | 56-64 BPM |
| **Key / mode** | B-flat minor, tritone intervals |
| **Loop** | Seamless loop |
| **Duration** | 80-100 seconds per loop |
| **Priority** | Phase 2 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, deep dungeon theme. Extremely slow and oppressive. The walls feel alive. Tempo 60 BPM, Bb minor with tritone dissonance. Sparse pulse wave notes with long rests. Wave channel emits a low pulsing drone. Almost no noise percussion — only occasional ticks. Unsettling chiptune."` |

---

#### BGM-006: Tower Interior (Layer 3 — Deepest / Gate Proximity)

| Field | Value |
|-------|-------|
| **Track name** | `bgm_tower_interior_abyss` |
| **Usage** | Deepest Tower zones, near Gate cores. May crossfade to near-silence. |
| **Mood / emotion** | Near-void. The music itself is dissolving. Only fragments of melody remain, as if the sound is being consumed by the Gate. |
| **Tempo** | 40-50 BPM (or arrhythmic) |
| **Key / mode** | Chromatic, no stable tonal center |
| **Loop** | Seamless loop, but designed to feel like it might not loop — unpredictable phrasing |
| **Duration** | 90-120 seconds per loop |
| **Priority** | Phase 2 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, abstract and terrifying deep abyss theme. Music is barely there — just scattered notes and a low drone. Tempo under 50 BPM or no clear pulse. Chromatic, atonal. Single pulse wave plays isolated notes with long silence between them. Wave channel is a barely audible sub-bass. No percussion. The sound of disappearing."` |

---

#### BGM-007 through BGM-027: World Field Themes (W-001 through W-021)

Each of the 21 worlds requires a field BGM. Worlds within the same corridor (see Section 9) may share a base track with variations, but each world must have a distinct identity. The sharing policy is defined below.

**Sharing Policy:**

| Group | Worlds | Shared base? | Variation method |
|-------|--------|-------------|-----------------|
| COR-01 Pastoral Echo | W-001, W-002, W-008 | Yes — shared pastoral base | W-001: standard; W-002: lower register, more wave channel; W-008: aggressive pulse rhythm added |
| COR-01 (winter branch) | W-009 | Unique | Snow/winter instrumentation too distinct to share |
| COR-02 Ledger Spine | W-003, W-007, W-010, W-013, W-018 | Partial — W-003 and W-013 share a lighter base; W-007, W-010, W-018 share a heavier institutional base | Tempo and lead channel duty cycle vary |
| COR-03 Mourning Water | W-005, W-006, W-011, W-015 | Yes — shared mourning base | W-005: sparse; W-006: wet/aquatic texture; W-011: reversal motif; W-015: processional rhythm |
| COR-04 Transit Crucible | W-004, W-012, W-016, W-019 | Partial — W-004 and W-012 share a port/transit base; W-016 and W-019 are unique | Percussion intensity varies |
| COR-05 Fracture Descent | W-014, W-017, W-020, W-021 | No — each unique | These late-game worlds each need distinct unsettling identities |

This yields approximately **14 unique base compositions** for 21 worlds, with 7 being variations.

**Full per-world BGM specifications are in Section 9.**

---

#### BGM-028: Normal Battle (Act I-II)

| Field | Value |
|-------|-------|
| **Track name** | `bgm_battle_normal_01` |
| **Usage** | Standard random encounters, Acts I-II |
| **Mood / emotion** | Energetic, tense but not overwhelming. The everyday danger of the world. Must be listenable across hundreds of encounters without fatigue. |
| **Tempo** | 140-152 BPM |
| **Key / mode** | E minor, natural minor with occasional harmonic minor for tension |
| **Loop** | Seamless loop. Short intro (2 bars) → main loop. |
| **Duration** | 35-45 seconds per loop (short to reduce repetition fatigue) |
| **Priority** | Phase 0 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, battle theme for a monster RPG. Energetic and driving. Tempo 146 BPM, E minor. Fast pulse wave melody with syncopation. Wave channel pumping bass line. Active noise channel with kick and hi-hat patterns. Exciting but not exhausting. Must loop cleanly."` |

---

#### BGM-029: Normal Battle (Act III-IV)

| Field | Value |
|-------|-------|
| **Track name** | `bgm_battle_normal_02` |
| **Usage** | Standard random encounters, Acts III-IV. Replaces BGM-028 at a story trigger. |
| **Mood / emotion** | Higher stakes version. More aggressive, faster, the world is getting dangerous. |
| **Tempo** | 152-164 BPM |
| **Key / mode** | G minor, heavier use of diminished chords |
| **Loop** | Seamless loop |
| **Duration** | 35-45 seconds per loop |
| **Priority** | Phase 2 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, intense battle theme. Faster and more aggressive than a standard battle. Tempo 158 BPM, G minor. Rapid pulse wave arpeggios. Driving wave channel bass. Intense noise percussion. Urgent and dangerous. Chiptune."` |

---

#### BGM-030: Normal Battle (Act V / Endgame)

| Field | Value |
|-------|-------|
| **Track name** | `bgm_battle_normal_03` |
| **Usage** | Standard encounters in Act V, postgame standard encounters |
| **Mood / emotion** | Desperation, the world fraying. Battle music that feels like the rules are breaking. |
| **Tempo** | 160-172 BPM |
| **Key / mode** | C# minor / chromatic passages |
| **Loop** | Seamless loop |
| **Duration** | 40-50 seconds per loop |
| **Priority** | Phase 3 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, desperate high-speed battle theme. The world is falling apart. Tempo 166 BPM, C# minor with chromatic runs. Frantic pulse wave leads. Unstable wave channel bass that shifts unexpectedly. Aggressive noise percussion. Chiptune chaos."` |

---

#### BGM-031: Boss Battle (Act I-II Bosses)

| Field | Value |
|-------|-------|
| **Track name** | `bgm_battle_boss_01` |
| **Usage** | World bosses in Acts I-II, major story confrontations |
| **Mood / emotion** | Grand, imposing, the weight of an obstacle that must be overcome. Solemn intensity. |
| **Tempo** | 130-140 BPM |
| **Key / mode** | D minor, Aeolian with Phrygian dominant in the B section |
| **Loop** | Intro (4 bars, non-looping) → A → B → loop to A |
| **Duration** | 55-70 seconds per loop |
| **Priority** | Phase 1 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, boss battle theme for a monster RPG. Grand and imposing. Tempo 135 BPM, D minor. Strong pulse wave melody with dramatic leaps. Heavy wave channel bass. Powerful noise percussion with crash cymbal hits. Feels like facing a mighty opponent. Chiptune."` |

---

#### BGM-032: Boss Battle (Act III-IV Bosses)

| Field | Value |
|-------|-------|
| **Track name** | `bgm_battle_boss_02` |
| **Usage** | World bosses in Acts III-IV |
| **Mood / emotion** | Escalated threat. The institutions and powers being fought are larger and more systemic. |
| **Tempo** | 136-148 BPM |
| **Key / mode** | F minor, more dissonant harmony |
| **Loop** | Intro → A → B → loop to A |
| **Duration** | 60-75 seconds per loop |
| **Priority** | Phase 2 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, intense boss battle. Escalating threat, systemic danger. Tempo 142 BPM, F minor. Complex pulse wave counterpoint between both channels. Deep wave channel bass with chromatic movement. Heavy noise percussion. Dark and powerful chiptune."` |

---

#### BGM-033: Boss Battle (Act V / Climax Bosses)

| Field | Value |
|-------|-------|
| **Track name** | `bgm_battle_boss_03` |
| **Usage** | Act V major bosses, W-020 and W-021 bosses |
| **Mood / emotion** | Existential confrontation. Not just danger but the questioning of everything the player has built. |
| **Tempo** | 144-156 BPM |
| **Key / mode** | B-flat minor, tritone-heavy, modal mixture |
| **Loop** | Intro → A → B → C → loop to A |
| **Duration** | 70-90 seconds per loop |
| **Priority** | Phase 2 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, climactic final act boss battle. Existential weight, high stakes. Tempo 150 BPM, Bb minor with tritone intervals. Both pulse wave channels in intense counterpoint. Wave channel bass with descending chromatic lines. Relentless noise percussion. The most intense battle theme. Chiptune."` |

---

#### BGM-034: Final Boss

| Field | Value |
|-------|-------|
| **Track name** | `bgm_battle_final` |
| **Usage** | The final boss encounter of the main story |
| **Mood / emotion** | All themes converge. Quotes from the title theme appear distorted. The pastoral warmth of the village theme is buried under dissonance. Resolution through confrontation. |
| **Tempo** | 152-168 BPM, with tempo shifts between sections |
| **Key / mode** | Begins in C minor (shadow of the C major title), modulates through multiple keys, resolves ambiguously |
| **Loop** | Long-form: Intro (8 bars) → A → B → C → D → loop to B |
| **Duration** | 120-150 seconds per full loop |
| **Priority** | Phase 2 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, epic final boss music for a monster RPG. References a gentle title theme now twisted into something fierce. Tempo shifts between 155 and 165 BPM. Starts in C minor, modulates dramatically. Maximum intensity from all 4 channels. Both pulse waves in rapid counterpoint. Wave channel bass is relentless. Noise channel drives with complex rhythms. The most important battle in the game. Chiptune epic."` |

---

#### BGM-035: Postgame / Secret Boss

| Field | Value |
|-------|-------|
| **Track name** | `bgm_battle_secret` |
| **Usage** | Hidden superboss encounters, postgame ultimate challenges |
| **Mood / emotion** | Beyond the story. Something ancient and mechanical. The Tower's own rhythm. Inhuman precision. |
| **Tempo** | 170-184 BPM |
| **Key / mode** | Whole-tone scale passages, octatonic (diminished) scale, deliberately alien |
| **Loop** | A → B → loop to A |
| **Duration** | 60-80 seconds per loop |
| **Priority** | Phase 3 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, secret superboss battle theme. Inhuman speed and precision, like fighting a machine god. Tempo 176 BPM. Whole-tone and diminished scale patterns. Relentless pulse wave arpeggios in unusual intervals. Wave channel bass in mechanical ostinato. Noise channel in complex polyrhythmic patterns. Alien and terrifying. Chiptune."` |

---

#### BGM-036: Tournament / Arena (Standard Matches)

| Field | Value |
|-------|-------|
| **Track name** | `bgm_tournament_match` |
| **Usage** | Tournament standard rounds, arena battles |
| **Mood / emotion** | Competitive excitement, sportsmanship, crowd energy. Lighter than boss battle — this is sport, not survival. |
| **Tempo** | 138-148 BPM |
| **Key / mode** | A major, bright and driving |
| **Loop** | Seamless loop |
| **Duration** | 40-50 seconds per loop |
| **Priority** | Phase 2 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, tournament battle music. Exciting competition, like a sporting event. Tempo 143 BPM, A major. Bright pulse wave fanfare melody. Punchy wave channel bass. Energetic noise percussion. Fun and competitive. Chiptune."` |

---

#### BGM-037: Tournament / Arena (Finals / Championship)

| Field | Value |
|-------|-------|
| **Track name** | `bgm_tournament_finals` |
| **Usage** | Tournament final rounds, championship matches |
| **Mood / emotion** | Peak competition. The crowd is holding its breath. More intense than standard tournament but still "sport" not "war." |
| **Tempo** | 148-158 BPM |
| **Key / mode** | A minor (dark mirror of standard tournament A major) |
| **Loop** | Seamless loop |
| **Duration** | 45-55 seconds per loop |
| **Priority** | Phase 2 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, championship tournament battle. The finals. Intense competition at its peak. Tempo 153 BPM, A minor. Dramatic pulse wave melody. Heavy wave channel bass. Powerful noise percussion. Serious but still exciting. Chiptune."` |

---

#### BGM-038: Breeding / Hatching

| Field | Value |
|-------|-------|
| **Track name** | `bgm_breeding` |
| **Usage** | Breeding facility, breeding selection screen, hatching sequence |
| **Mood / emotion** | Mystical, sacred, the ritual of creating new life. Gentle but with an undercurrent of the forbidden — breeding is central to the game's ethical tension. |
| **Tempo** | 72-80 BPM |
| **Key / mode** | E-flat major, Lydian mode for otherworldly warmth |
| **Loop** | Seamless loop |
| **Duration** | 55-70 seconds per loop |
| **Priority** | Phase 1 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, mystical breeding ceremony music. Creating new life through ritual. Gentle but otherworldly. Tempo 76 BPM, Eb major Lydian mode. Soft pulse wave melody with arpeggiated harmony. Wave channel provides a warm pad-like bass. Minimal noise percussion — just soft ticks. Sacred and mysterious. Chiptune."` |

---

#### BGM-039: Ranch / Monster Storage

| Field | Value |
|-------|-------|
| **Track name** | `bgm_ranch` |
| **Usage** | Ranch facility, monster storage management, feeding and care |
| **Mood / emotion** | Peaceful, pastoral, the satisfaction of tending to creatures. The closest the game gets to pure comfort — but the Style Bible's "life stain" quality means it is never saccharine. |
| **Tempo** | 84-92 BPM |
| **Key / mode** | G major, simple diatonic harmony |
| **Loop** | Seamless loop |
| **Duration** | 50-65 seconds per loop |
| **Priority** | Phase 1 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, peaceful ranch and farm music. Taking care of monsters in a pastoral setting. Tempo 88 BPM, G major. Sweet pulse wave melody. Gentle wave channel bass. Light noise percussion like distant wind. Relaxing but not sleepy. Chiptune."` |

---

#### BGM-040: Shop

| Field | Value |
|-------|-------|
| **Track name** | `bgm_shop` |
| **Usage** | All shop interfaces — item shops, equipment shops, specialty merchants |
| **Mood / emotion** | Cheerful, transactional, a brief musical respite. The shopkeeper's welcome. |
| **Tempo** | 108-118 BPM |
| **Key / mode** | B-flat major, bouncy rhythm |
| **Loop** | Seamless loop |
| **Duration** | 30-40 seconds per loop (short — shop visits are brief) |
| **Priority** | Phase 1 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, cheerful shop music for an RPG. Buying and selling items. Tempo 113 BPM, Bb major. Bouncy pulse wave melody. Rhythmic wave channel bass. Light snappy noise percussion. Short and pleasant. Chiptune."` |

---

#### BGM-041: Codex / Encyclopedia

| Field | Value |
|-------|-------|
| **Track name** | `bgm_codex` |
| **Usage** | Monster codex browsing, encyclopedia entries, lore review |
| **Mood / emotion** | Studious, contemplative, the weight of knowledge. A library's quiet hum translated to chiptune. |
| **Tempo** | 68-76 BPM |
| **Key / mode** | D major, gentle suspensions |
| **Loop** | Seamless loop |
| **Duration** | 55-70 seconds per loop |
| **Priority** | Phase 2 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, encyclopedia browsing music. Calm and studious, like reading in a quiet library. Tempo 72 BPM, D major. Gentle pulse wave melody with sustained notes. Soft wave channel accompaniment. Almost no noise percussion. Contemplative. Chiptune."` |

---

#### BGM-042: Tension / Mystery Event

| Field | Value |
|-------|-------|
| **Track name** | `bgm_event_tension` |
| **Usage** | Story events involving suspense, revelation, conspiracy, discovery of forbidden knowledge |
| **Mood / emotion** | Dread building, something is wrong. The "quiet taboo" (静かな禁忌) made audible. |
| **Tempo** | 60-72 BPM |
| **Key / mode** | C minor, chromatic neighbor tones, unresolved suspensions |
| **Loop** | Seamless loop |
| **Duration** | 50-65 seconds per loop |
| **Priority** | Phase 1 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, tense mystery event music. Something terrible is being revealed. Tempo 66 BPM, C minor. Creeping pulse wave melody with chromatic movement. Low wave channel drone. Sparse noise ticks like a clock. Suspenseful and ominous. Chiptune."` |

---

#### BGM-043: Sad / Mourning Event

| Field | Value |
|-------|-------|
| **Track name** | `bgm_event_sad` |
| **Usage** | Character loss, mourning scenes, failure consequences, farewell moments |
| **Mood / emotion** | Grief, loss, the weight of choices. Not melodramatic — restrained sorrow, the way grief actually feels. |
| **Tempo** | 56-64 BPM |
| **Key / mode** | A-flat minor, descending melodic lines |
| **Loop** | Seamless loop |
| **Duration** | 55-70 seconds per loop |
| **Priority** | Phase 1 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, sad and mournful event music. Loss and grief, restrained and dignified. Tempo 60 BPM, Ab minor. Slow descending pulse wave melody. Gentle wave channel bass with descending lines. No noise percussion. Deeply sad but not overwrought. Chiptune."` |

---

#### BGM-044: Triumphant / Hope Event

| Field | Value |
|-------|-------|
| **Track name** | `bgm_event_triumph` |
| **Usage** | Breakthrough moments, major story victories, hope restored |
| **Mood / emotion** | Catharsis, earned hope. The title theme's warmth returning after darkness. |
| **Tempo** | 108-120 BPM |
| **Key / mode** | C major (echoing the title theme) |
| **Loop** | May not loop — plays once during event, then transitions to scene BGM |
| **Duration** | 30-45 seconds |
| **Priority** | Phase 2 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, triumphant hopeful event music. Victory after long struggle. Tempo 114 BPM, C major. Soaring pulse wave melody. Warm wave channel harmony. Light celebratory noise percussion. Uplifting and emotional. Chiptune."` |

---

#### BGM-045: Foreboding / Dark Event

| Field | Value |
|-------|-------|
| **Track name** | `bgm_event_dark` |
| **Usage** | Villain revelations, taboo exposure, Gate corruption events, institutional horror |
| **Mood / emotion** | Dread, the "distorted simplicity" (歪んだ素朴さ). What seemed normal is revealed as monstrous. |
| **Tempo** | 50-60 BPM |
| **Key / mode** | F# minor, Locrian inflections, tritone emphasis |
| **Loop** | Seamless loop |
| **Duration** | 60-80 seconds per loop |
| **Priority** | Phase 2 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, dark foreboding event music. Evil is being revealed. Tempo 55 BPM, F# minor with Locrian flat-5. Dissonant pulse wave intervals. Ominous wave channel sub-bass. Sparse unsettling noise. Deeply disturbing. Chiptune."` |

---

#### BGM-046: Gate Crossing

| Field | Value |
|-------|-------|
| **Track name** | `bgm_gate_crossing` |
| **Usage** | The moment of passing through a Gate between worlds |
| **Mood / emotion** | Liminal, suspended, between. Sound itself feels distorted. The sensation of existing nowhere. |
| **Tempo** | No fixed tempo — arrhythmic, drifting |
| **Key / mode** | Atonal, slowly shifting pitch clusters |
| **Loop** | Does not loop — plays for the duration of the crossing animation (5-10 seconds), then hard-cuts to the destination world BGM. |
| **Duration** | 8-12 seconds |
| **Priority** | Phase 1 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, short transitional music for passing through a dimensional gate. 8-10 seconds. No clear tempo or key. Swirling pulse wave tones shifting in pitch. Wave channel glissando. Rising noise wash. Sounds like reality is bending. Chiptune."` |

---

#### BGM-047: Ending Theme

| Field | Value |
|-------|-------|
| **Track name** | `bgm_ending_main` |
| **Usage** | Main story ending, final scenes before credits |
| **Mood / emotion** | Bittersweet resolution. The title theme fully realized, no longer hiding its minor-key undercurrent. Peace that was earned through understanding, not force. |
| **Tempo** | 88-100 BPM |
| **Key / mode** | C major → A minor → resolves to C major. Full harmonic journey. |
| **Loop** | Does not loop — plays once |
| **Duration** | 120-180 seconds |
| **Priority** | Phase 2 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, ending theme for a monster RPG. Bittersweet and emotional, reflecting on a long journey. Tempo 94 BPM. Starts in C major, moves through A minor, returns to C major. Full use of all 4 channels. Melodic pulse wave lead that quotes earlier themes. Rich wave channel harmony. Gentle noise percussion. 2-3 minutes long. Does not need to loop. Chiptune."` |

---

#### BGM-048: Credits / Staff Roll

| Field | Value |
|-------|-------|
| **Track name** | `bgm_credits` |
| **Usage** | Credits scroll, staff roll |
| **Mood / emotion** | Celebration and reflection. A medley quality — touching on multiple themes from the game. Gratitude. |
| **Tempo** | 100-120 BPM, varying across medley sections |
| **Key / mode** | Multiple keys — medley structure |
| **Loop** | Does not loop — long-form composition timed to credit scroll length |
| **Duration** | 180-300 seconds (3-5 minutes, matching credits length) |
| **Priority** | Phase 3 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, credits theme for a monster RPG. Celebratory medley touching on multiple earlier themes. Tempo varies 100-120 BPM. Multiple key changes. Joyful and nostalgic. All 4 channels at full expression. 3-5 minutes long. Does not loop. Chiptune."` |

---

#### BGM-049: Postgame Ending / True Credits

| Field | Value |
|-------|-------|
| **Track name** | `bgm_ending_post` |
| **Usage** | Postgame completion ending, true ending if applicable |
| **Mood / emotion** | Quiet closure. Simpler than the main ending — more personal, fewer instruments. |
| **Tempo** | 76-84 BPM |
| **Key / mode** | F major (echoing the village theme) |
| **Loop** | Does not loop |
| **Duration** | 90-120 seconds |
| **Priority** | Phase 3 |
| **AI prompt template** | `"8-bit chiptune, Game Boy Color style, quiet postgame ending music. Simple and personal, like returning home after a very long journey. Tempo 80 BPM, F major. Solo pulse wave melody for the opening, gradually adding channels. Wave channel warm bass. Minimal noise. Peaceful resolution. Chiptune."` |

---

### 2.3 Jingles

Jingles are short, non-looping musical stings that punctuate game events. They temporarily interrupt or duck the current BGM.

| Jingle ID | Name | File name | Usage | Duration | Mood | Key | Tempo | Priority | BGM behavior |
|-----------|------|-----------|-------|----------|------|-----|-------|----------|-------------|
| JGL-001 | Victory | `jingle_victory.ogg` | Battle win | 3-5 sec | Triumph, relief | C major | 140 BPM | Phase 0 | BGM stops → jingle → field BGM resumes |
| JGL-002 | Level Up | `jingle_levelup.ogg` | Level up during results | 2-3 sec | Achievement, growth | G major arpeggio | 160 BPM | Phase 0 | Plays over results screen; no BGM ducking needed |
| JGL-003 | Item Obtained | `jingle_item.ogg` | Treasure chest, key item received | 1-2 sec | Discovery | F major | 120 BPM | Phase 1 | BGM ducks -6dB during jingle |
| JGL-004 | Tournament Victory | `jingle_tournament_win.ogg` | Tournament round win | 3-5 sec | Glory, competition won | A major | 150 BPM | Phase 2 | BGM stops → jingle → result screen BGM |
| JGL-005 | Breeding Success | `jingle_breeding_success.ogg` | New monster born from breeding | 3-5 sec | Wonder, new life | Eb major | 100 BPM | Phase 1 | BGM ducks -6dB |
| JGL-006 | Mutation Birth | `jingle_mutation.ogg` | Mutation variant born | 5-7 sec | Awe, the unexpected, slight unease | Eb minor → Eb major resolution | 90 BPM | Phase 2 | BGM stops completely → jingle → breeding BGM resumes |
| JGL-007 | Game Over | `jingle_gameover.ogg` | Party wipe, defeat | 3-5 sec | Loss, finality | C minor descending | 80 BPM | Phase 0 | BGM stops → jingle → game over screen |
| JGL-008 | Recruitment Success | `jingle_recruit.ogg` | Monster successfully recruited/scouted | 2-3 sec | Welcome, companionship | D major | 130 BPM | Phase 1 | BGM ducks -6dB |
| JGL-009 | Gate Opening | `jingle_gate_open.ogg` | A Gate between worlds activates | 4-6 sec | Awe, threshold, the unknown | Atonal → resolving to destination key | No fixed tempo | Phase 1 | BGM fades out over jingle duration → silence → gate crossing BGM |
| JGL-010 | Rank Up | `jingle_rankup.ogg` | Breeder rank promotion | 3-5 sec | Accomplishment, progression | Bb major fanfare | 144 BPM | Phase 2 | BGM ducks -6dB |
| JGL-011 | Codex Entry | `jingle_codex.ogg` | New monster registered in codex | 1-2 sec | Collection, knowledge | D major, brief arpeggio | 120 BPM | Phase 2 | Plays softly over current BGM, no ducking |

**AI prompt template for jingles**: `"8-bit chiptune, Game Boy Color style, short [MOOD] jingle, [DURATION] seconds long. [KEY] key, [TEMPO] BPM. Pulse wave fanfare. Does not loop. Clear beginning and ending. Chiptune."` — Replace bracketed fields per jingle.

---

## 3. SE Complete Catalog

### 3.1 Global SE Rules

| Parameter | Value |
|-----------|-------|
| Format | WAV 16-bit 44.1kHz mono |
| Duration range | 0.05-2.0 seconds |
| Random pitch variation (default) | ±10% (pitch_scale randomized between 0.9 and 1.1 each play) |
| Simultaneous SE limit | 8 concurrent SE voices (Godot AudioServer bus limit) |
| Priority system | 3 tiers: Critical (never interrupted), Standard (can be interrupted by Critical), Low (can be interrupted by Standard or Critical) |
| Volume reference | All SE volumes specified relative to master SE bus at 100% |

### 3.2 Menu / UI Sound Effects

| SE ID | Name | File name | Trigger | Duration | Pitch var | Priority | Relative vol | Waveform description |
|-------|------|-----------|---------|----------|-----------|----------|-------------|---------------------|
| SE-001 | Cursor Move | `se_menu_cursor_move.wav` | D-pad input on any menu list | 0.05 sec | ±5% | Low | 60% | Single pulse tick, high pitch. Brief and non-intrusive. |
| SE-002 | Confirm (A) | `se_menu_confirm.wav` | A button press on valid selection | 0.08 sec | ±3% | Standard | 80% | Two-note ascending pulse chirp (e.g., C5→E5). Satisfying click. |
| SE-003 | Cancel (B) | `se_menu_cancel.wav` | B button press to back out | 0.08 sec | ±3% | Standard | 75% | Two-note descending pulse (E5→C5). Inverse of confirm. |
| SE-004 | Menu Open | `se_menu_open.wav` | Menu window appears | 0.12 sec | None | Standard | 70% | Quick ascending arpeggio, 3 notes (C4→E4→G4). Window sliding open. |
| SE-005 | Menu Close | `se_menu_close.wav` | Menu window dismissed | 0.10 sec | None | Standard | 65% | Quick descending arpeggio, 3 notes (G4→E4→C4). Inverse of open. |
| SE-006 | Page Turn | `se_menu_page.wav` | Page/tab change in multi-page menus | 0.08 sec | ±5% | Low | 55% | Noise swoosh, brief, like paper. |
| SE-007 | Error / Invalid | `se_menu_error.wav` | Attempting an invalid action | 0.15 sec | None | Critical | 90% | Harsh buzzer, low-pitch noise burst. Unmistakable "no." |
| SE-008 | Text Tick | `se_menu_text_tick.wav` | Each character appearing in text boxes (if text crawl is used) | 0.02 sec | ±15% | Low | 30% | Tiny pulse click. Very quiet, perceived as texture not sound. High pitch variation prevents machine-gun effect. |
| SE-009 | Selection Change | `se_menu_select_change.wav` | Switching between options in a horizontal selector or radio buttons | 0.06 sec | ±5% | Low | 60% | Soft pulse blip, mid-range pitch. Distinct from cursor move. |
| SE-010 | Tab Switch | `se_menu_tab.wav` | Switching between major tab categories (e.g., Items → Equipment) | 0.10 sec | ±3% | Standard | 65% | Short sliding tone, pulse wave glissando up or down depending on direction. |

---

### 3.3 Battle Sound Effects

| SE ID | Name | File name | Trigger | Duration | Pitch var | Priority | Relative vol | Waveform description |
|-------|------|-----------|---------|----------|-----------|----------|-------------|---------------------|
| SE-011 | Physical Hit (Normal) | `se_battle_hit_physical.wav` | Standard physical attack connects | 0.12 sec | ±10% | Standard | 90% | Noise burst with pulse overlay. Sharp impact. |
| SE-012 | Physical Hit (Critical) | `se_battle_hit_critical.wav` | Critical hit connects | 0.18 sec | ±5% | Critical | 100% | Layered noise burst, louder and longer than normal hit. Added high pulse ring. Screen shake accompanies this. |
| SE-013 | Miss / Whiff | `se_battle_miss.wav` | Attack misses target | 0.15 sec | ±10% | Standard | 60% | Airy noise swoosh. No impact. Feels empty. |
| SE-014 | Fire Spell | `se_battle_spell_fire.wav` | Fire-element spell cast | 0.40 sec | ±8% | Standard | 85% | Crackling noise rising in pitch, with pulse wave undertone rising. Explosive finish. |
| SE-015 | Water / Ice Spell | `se_battle_spell_water.wav` | Water/ice-element spell cast | 0.45 sec | ±8% | Standard | 85% | Cascading pulse arpeggios descending, noise hiss underneath. Watery, crystalline. |
| SE-016 | Wind Spell | `se_battle_spell_wind.wav` | Wind-element spell cast | 0.35 sec | ±10% | Standard | 80% | Noise swoosh with pitch modulation, rising and falling. Pulse wave whistle. |
| SE-017 | Earth Spell | `se_battle_spell_earth.wav` | Earth-element spell cast | 0.35 sec | ±8% | Standard | 85% | Low noise rumble with pulse wave low staccato hits. Heavy, grounded. |
| SE-018 | Thunder Spell | `se_battle_spell_thunder.wav` | Thunder-element spell cast | 0.50 sec | ±5% | Critical | 95% | Sharp noise crack followed by rolling noise decay. Pulse wave high-pitch strike. Loudest spell SE. |
| SE-019 | Light Spell | `se_battle_spell_light.wav` | Light-element spell cast | 0.40 sec | ±8% | Standard | 85% | Bright ascending pulse arpeggios, shimmering. Wave-like warm tone. Clean and pure. |
| SE-020 | Dark Spell | `se_battle_spell_dark.wav` | Dark-element spell cast | 0.45 sec | ±8% | Standard | 85% | Descending pulse wave with detuning. Low noise rumble. Unsettling wobble effect. |
| SE-021 | Heal Spell | `se_battle_spell_heal.wav` | Healing spell cast | 0.50 sec | ±5% | Standard | 80% | Gentle ascending arpeggio across pulse and wave channels. Warm, restorative. Noise-free. |
| SE-022 | Buff Applied | `se_battle_buff.wav` | Stat buff applied to a monster | 0.30 sec | ±8% | Standard | 75% | Rising pulse tone, two ascending notes with a shimmer. Positive. |
| SE-023 | Debuff Applied | `se_battle_debuff.wav` | Stat debuff applied to a target | 0.30 sec | ±8% | Standard | 75% | Descending pulse tone, two falling notes with noise decay. Negative mirror of buff. |
| SE-024 | Status: Poison | `se_battle_status_poison.wav` | Poison status inflicted | 0.25 sec | ±5% | Standard | 80% | Bubbling noise with low pulse wave warble. Sickly. |
| SE-025 | Status: Sleep | `se_battle_status_sleep.wav` | Sleep status inflicted | 0.30 sec | ±5% | Standard | 75% | Descending pulse wave lullaby fragment (3 notes down). Soft noise hiss fadeout. |
| SE-026 | Status: Paralysis | `se_battle_status_paralysis.wav` | Paralysis inflicted | 0.20 sec | ±5% | Standard | 80% | Sharp noise buzz, electric. Pulse wave staccato jitter. |
| SE-027 | Status: Confusion | `se_battle_status_confusion.wav` | Confusion inflicted | 0.30 sec | ±10% | Standard | 75% | Swirling pulse wave pitch-bend, circular motion feel. Dizzy. |
| SE-028 | Status: Seal | `se_battle_status_seal.wav` | Magic seal inflicted | 0.25 sec | ±5% | Standard | 80% | Heavy low pulse thud followed by silence. The sound of being shut off. |
| SE-029 | Status: Fear | `se_battle_status_fear.wav` | Fear inflicted | 0.30 sec | ±8% | Standard | 80% | Trembling pulse wave vibrato, shaky and unstable. Descending. |
| SE-030 | Status: Curse | `se_battle_status_curse.wav` | Curse inflicted | 0.35 sec | ±5% | Standard | 85% | Low wave channel drone with dissonant pulse overlay. The heaviest status sound. |
| SE-031 | Status Cured | `se_battle_status_cure.wav` | Any status ailment removed | 0.20 sec | ±5% | Standard | 75% | Quick ascending pulse chime, clean and clear. Universal for all status cures. |
| SE-032 | Guard / Defend | `se_battle_guard.wav` | Defend command selected | 0.15 sec | ±5% | Standard | 70% | Solid noise thud with pulse undertone. Like a shield being raised. |
| SE-033 | Escape Attempt | `se_battle_escape_try.wav` | Escape command initiated | 0.20 sec | ±10% | Standard | 70% | Quick footstep-like noise pattern. Running. |
| SE-034 | Escape Success | `se_battle_escape_success.wav` | Escape succeeds | 0.25 sec | None | Standard | 75% | Rising pulse swoosh, ascending away. Relief. |
| SE-035 | Escape Failure | `se_battle_escape_fail.wav` | Escape fails | 0.15 sec | None | Standard | 80% | Blocked noise thud. Can't get away. |
| SE-036 | Encounter Start | `se_battle_encounter.wav` | Random encounter triggered | 0.30 sec | None | Critical | 100% | Sharp pulse alarm — two quick ascending notes followed by noise crash. Startling but not annoying. |
| SE-037 | Enemy Death | `se_battle_enemy_death.wav` | Enemy monster HP reaches 0 | 0.35 sec | ±5% | Standard | 85% | Descending noise dissolve with pulse wave falling. Disintegration. |
| SE-038 | Party Member KO | `se_battle_party_ko.wav` | Allied monster HP reaches 0 | 0.40 sec | None | Critical | 90% | Low pulse wave thud followed by descending tone. Heavier and sadder than enemy death. |
| SE-039 | EXP Gain Tick | `se_battle_exp_tick.wav` | EXP counter incrementing on results screen | 0.03 sec | ±8% | Low | 40% | Tiny pulse tick, like a counting machine. Rapid-fires during EXP tally. |

**Note on status ailment SE**: Each status ailment has a unique SE rather than a shared one. This is a deliberate design choice — players learn to recognize status ailments by sound during battle, providing critical gameplay information. The 7 unique status SEs (SE-024 through SE-030) share a family resemblance (all use similar duration and volume) but have distinct timbral signatures.

---

### 3.4 Field Sound Effects

| SE ID | Name | File name | Trigger | Duration | Pitch var | Priority | Relative vol | Waveform description |
|-------|------|-----------|---------|----------|-----------|----------|-------------|---------------------|
| SE-040 | Footstep (Universal) | `se_field_footstep.wav` | Player character moves one tile | 0.06 sec | ±15% | Low | 35% | Soft noise tap. Universal for all terrain. High pitch variation prevents repetition fatigue. |
| SE-041 | Door Open | `se_field_door_open.wav` | Opening a door | 0.20 sec | ±5% | Standard | 70% | Noise creak with ascending pulse tone. |
| SE-042 | Door Close | `se_field_door_close.wav` | Door closing behind player | 0.18 sec | ±5% | Standard | 60% | Noise thud, lower pitch than open. |
| SE-043 | Chest Open | `se_field_chest_open.wav` | Opening a treasure chest | 0.25 sec | None | Standard | 80% | Ascending pulse arpeggio with noise click. Anticipation before the item jingle. |
| SE-044 | Item Pickup | `se_field_item_pickup.wav` | Picking up a dropped/visible item | 0.12 sec | ±5% | Standard | 70% | Quick pulse chirp, ascending. Lighter than chest open. |
| SE-045 | NPC Interaction | `se_field_npc_talk.wav` | Pressing A to talk to an NPC | 0.08 sec | ±5% | Standard | 65% | Soft pulse blip. Conversational start. |
| SE-046 | Sign / Object Examine | `se_field_examine.wav` | Examining a sign, bookshelf, or interactive object | 0.10 sec | ±5% | Standard | 60% | Lower-pitched pulse blip than NPC talk. Reads as "looking at" vs "talking to." |
| SE-047 | Hazard Damage | `se_field_hazard.wav` | Stepping on lava, poison swamp, spike tile | 0.15 sec | ±5% | Critical | 85% | Sharp noise buzz with low pulse hit. Pain. Must cut through ambient. |
| SE-048 | Staircase | `se_field_stairs.wav` | Using stairs between floors | 0.30 sec | None | Standard | 65% | Quick ascending or descending pulse scale (3-4 notes) depending on direction. |
| SE-049 | Save Point | `se_field_save.wav` | Approaching / interacting with save point | 0.20 sec | None | Standard | 75% | Warm pulse chime, two notes. Safety. |
| SE-050 | Warp / Teleport | `se_field_warp.wav` | Teleporting between locations (not Gate crossing — those use the jingle) | 0.40 sec | None | Standard | 80% | Swirling pulse wave pitch bend up, noise shimmer. Displacement. |

**Footstep terrain policy**: A single universal footstep SE with high pitch variation (±15%) is used rather than per-terrain footsteps. This is a deliberate constraint — GBC games did not typically have per-terrain footsteps, and the high pitch variation provides sufficient variety. If during playtesting this feels too monotonous, a second footstep variant (`se_field_footstep_02.wav`) may be added and randomly alternated, but per-terrain sets are out of scope.

---

### 3.5 Breeding Sound Effects

| SE ID | Name | File name | Trigger | Duration | Pitch var | Priority | Relative vol | Waveform description |
|-------|------|-----------|---------|----------|-----------|----------|-------------|---------------------|
| SE-051 | Parent Selected | `se_breed_parent_select.wav` | Choosing a parent monster for breeding | 0.12 sec | ±5% | Standard | 70% | Confirming pulse chime, slightly different from menu confirm — warmer, wave channel note mixed in. |
| SE-052 | Breeding Start | `se_breed_start.wav` | Breeding ritual begins | 0.50 sec | None | Critical | 85% | Low wave channel drone rising in pitch, pulse wave joins with ascending arpeggio. Ritual commencing. |
| SE-053 | Egg Appear | `se_breed_egg.wav` | Egg materializes on screen | 0.30 sec | None | Standard | 80% | Soft pulse shimmer with wave channel warmth. Something exists that didn't before. |
| SE-054 | Hatch | `se_breed_hatch.wav` | Egg cracks and hatches | 0.40 sec | None | Critical | 90% | Noise crack (shell breaking) followed by pulse wave ascending cry. New life. |
| SE-055 | Mutation Trigger | `se_breed_mutation.wav` | Mutation detected during breeding result | 0.35 sec | None | Critical | 95% | Dissonant pulse wave tremolo followed by a resolution tone. Unexpected. The sound should make the player's heart skip. |
| SE-056 | Inheritance Lock | `se_breed_inherit_lock.wav` | Skill/trait inheritance slot confirmed | 0.10 sec | ±5% | Standard | 65% | Click-lock pulse sound. Mechanical, decisive. |
| SE-057 | Birth Result Reveal | `se_breed_reveal.wav` | Final monster revealed after breeding | 0.25 sec | None | Standard | 80% | Unveiling pulse arpeggio, ascending. Precedes the breeding success jingle. |

---

### 3.6 System Sound Effects

| SE ID | Name | File name | Trigger | Duration | Pitch var | Priority | Relative vol | Waveform description |
|-------|------|-----------|---------|----------|-----------|----------|-------------|---------------------|
| SE-058 | Save Complete | `se_system_save.wav` | Save operation finished | 0.20 sec | None | Critical | 75% | Gentle descending pulse chime — settling, safe. |
| SE-059 | Load Complete | `se_system_load.wav` | Load operation finished | 0.20 sec | None | Critical | 75% | Ascending pulse chime — waking up, resuming. |
| SE-060 | Achievement / Milestone | `se_system_achievement.wav` | Achievement unlocked, milestone reached | 0.30 sec | None | Critical | 85% | Bright pulse fanfare fragment, louder than most UI SE. Celebratory. |
| SE-061 | Error / Warning | `se_system_error.wav` | System-level error (save failed, connection issue) | 0.25 sec | None | Critical | 95% | Harsh noise buzz, unmistakable alarm. Different from menu error (SE-007) — this is more serious. |

---

### 3.7 SE Summary Count

| Category | Count |
|----------|------:|
| Menu / UI | 10 |
| Battle | 29 |
| Field | 11 |
| Breeding | 7 |
| System | 4 |
| **Total** | **61** |

This falls at the high end of the 40-60 target range from requirements, which is acceptable given that the per-status-ailment decision adds 7 SEs that could have been 1.

---

## 4. Ambient Sound Rules

### 4.1 Ambient Design Philosophy

Ambient sound occupies the space between BGM and silence. It provides environmental presence without melodic content. In this game, ambient serves a critical narrative function: the **Tower's influence is felt through the degradation of ambient sound**, and **W-021 (ほどけの縁)** uses ambient-only audio as its primary soundscape.

### 4.2 Ambient Layer Rules

| Rule | Specification |
|------|--------------|
| Ambient + BGM | Ambient always plays underneath BGM. Never competes with melody. |
| Volume relationship | Ambient default: 40% of master. Ambient should be 50-60% of perceived BGM loudness. |
| Stereo width | Ambient files are stereo. They provide the spatial dimension that mono SE cannot. |
| Loop | All ambient files loop seamlessly. |
| Format | OGG Vorbis (same spec as BGM) |
| Duration | 30-60 seconds per loop (longer than SE, shorter than BGM) |
| Layering limit | Maximum 2 ambient layers simultaneously (base + detail) |

### 4.3 Ambient Categories

| Category | Description | Example |
|----------|-------------|---------|
| **Base ambient** | Continuous environmental tone. Always present in outdoor zones. | Wind, water flow, cave hum |
| **Detail ambient** | Intermittent environmental accents layered atop base. | Bird calls, insect chirps, dripping water, distant thunder |

### 4.4 Per-World Ambient Specifications

| World | Base ambient | Detail ambient | Notes |
|-------|-------------|---------------|-------|
| W-001 (名伏せの野) | Gentle wind through reeds, rustling grass | Distant livestock bells (chiptune noise pulses), occasional bird | Pastoral, safe. The "default" ambient. |
| W-002 (灰乳の谷) | Dry wind through limestone valley | Goat-like bleats (pulse wave), stone settling | Drier than W-001. More mineral. |
| W-003 (継灯の宿場) | Town ambient: distant chatter (noise texture), creaking wood | Footsteps of other travelers, lantern crackle | Busier than pastoral worlds. |
| W-004 (札差しの岬) | Ocean waves (noise wash), wind on cliffs | Seabird cries (pulse wave), distant foghorn (wave channel) | Maritime, authority. |
| W-005 (香なしの墓苑) | Still air with occasional breeze | Dripping water, stone creak, distant chanting (very faint pulse) | Deliberately sparse. Absence of incense is "heard" as absence. |
| W-006 (鈴結びの湿地) | Water bubbling, swamp ambience | Bell/chime fragments (pulse wave), insect buzz (noise) | Wet, ritualistic. Bells are important thematically. |
| W-007 (削名の階市) | City noise: crowd murmur (noise), stone echoes | Proclamation horns (pulse), coins (noise ticks) | Vertical city — echoes suggest height. |
| W-008 (獣印の放牧環) | Heavy wind on open range | Branding iron sizzle (noise), animal stamping (noise thuds) | Harsher than W-001. Ownership is audible. |
| W-009 (仮親の雪原) | Blizzard wind (loud noise wash), snow crunch base | Cracking ice, distant howl (pulse wave pitch bend) | The loudest ambient in the game. Oppressive cold. |
| W-010 (群書の塩庫) | Warehouse hum, canal water | Paper rustling (noise), salt crystal settling, cargo loading | Institutional, damp. |
| W-011 (逆誓の修院) | Stone corridor echo, quiet wind | Reversed chanting fragments (reversed pulse samples), bell toll | Unsettling reversal theme carried into ambient. |
| W-012 (骨樋の港) | Harbor water, dock creaking, cargo chains | Gulls, distant ship horn, bone-on-wood scraping | Industrial port with macabre undertone. |
| W-013 (無籍の葡萄段) | Hillside wind, rustling vines | Harvesting sounds (noise), distant singing (faint pulse melody) | Agricultural, but the singing is tinged with exhaustion. |
| W-014 (返らずの鏡森) | Deep forest: layered rustling, echo | Water dripping with unnatural echo, own footsteps played back with delay | Mirror/echo theme: ambient subtly "reflects" sounds. |
| W-015 (黒布の巡礼路) | Dry wind on pilgrimage road | Cloth flapping (noise), distant processional drums (noise rhythm) | Solemn march quality in the ambient itself. |
| W-016 (焼継の鍛土) | Forge heat hum, crackling ash | Hammer strikes (noise), kiln roar (wave channel low), cooling metal ticks | Industrial, intense heat. |
| W-017 (残名の回廊) | Hollow corridor echo, near-silence base | Name-like whispers (very faint, indistinct pulse fragments), door echoes | The ambient itself is the horror: you hear names that nobody spoke. |
| W-018 (二署の法台) | Administrative building hum, crowd murmur | Stamp thuds (noise), argument fragments (noise textures) | Bureaucratic tension made audible. |
| W-019 (閉鐘の塔都) | Muted city + Tower hum blend | Absent bell (the sound of a bell NOT ringing: a silence pulse), wind through empty bell tower | The closed bell defines this world. Its absence is the ambient. |
| W-020 (継ぎ止めの聖郭) | Massive interior echo, stone breathing | Distant choral fragments (wave channel), quill scratching (noise) | Cathedral-like scale. Oppressive holiness. |
| W-021 (ほどけの縁) | Near-silence. Sub-bass hum only. | Occasional single pulse wave tone, high and isolated. No pattern. | **No BGM in this world.** Ambient IS the soundscape. See Section 8. |

### 4.5 Tower Ambient (Special Rules)

The Tower has its own ambient system that overrides world ambient when the player is in Tower zones.

| Tower depth | Ambient description | BGM relationship |
|-------------|--------------------|-----------------|
| Exterior approach (100-50m) | World ambient fades; Tower hum fades in. Low wave-channel drone. | BGM plays but at reduced volume (-3dB). |
| Exterior approach (50-0m) | Tower hum dominates. World ambient at 20%. Pulse of the Gate becomes audible. | BGM at -6dB relative to normal. |
| Interior upper | Tower hum + mechanical ticking (noise channel rhythm). Sterile. | Tower interior BGM (BGM-004) plays at full volume. |
| Interior deep | Tower hum deepens. Ticking becomes irregular. Organic sounds emerge (pulse wave moaning). | Tower deep BGM (BGM-005) plays. Ambient at 50% normal. |
| Interior abyss | Sub-bass only. Occasional high-frequency tones like tinnitus. Near-silence. | Tower abyss BGM (BGM-006) barely audible. Ambient merges with music until distinction is lost. |

### 4.6 Ambient Transitions

| Transition type | Duration | Method |
|----------------|----------|--------|
| World → World (via Gate) | 0 sec (hard cut after Gate crossing) | Old ambient stops. Gate crossing sound plays. New ambient begins at destination. |
| Outdoor → Indoor (same world) | 0.8 sec crossfade | Base ambient swaps; detail ambient fades out first, then base. |
| Field → Tower approach | 3.0 sec gradual blend | World ambient fades; Tower hum fades in. Slow transition matches walking pace. |
| Tower floor change | 1.5 sec crossfade | Ambient morphs between Tower layers. |
| Field → Battle | Instant stop | Ambient cuts immediately when encounter SE (SE-036) plays. |
| Battle → Field | 0.5 sec fade-in | Ambient resumes after battle results, synchronized with field BGM resume. |

---

## 5. Music Transition Rules

### 5.1 Scene Transition Matrix

| From | To | Transition type | Duration | Notes |
|------|-----|----------------|----------|-------|
| Title BGM | Field BGM | Crossfade | 0.5 sec | Standard crossfade after "New Game" or "Continue" |
| Field BGM | Battle BGM | Hard cut | 0 sec | Battle encounter SE plays, then battle BGM starts immediately on next audio frame |
| Battle BGM | Victory jingle | Hard cut | 0 sec | BGM stops instantly, jingle plays |
| Victory jingle | Results silence | Natural end | Jingle duration | Results screen has no BGM — EXP ticks provide audio |
| Results screen | Field BGM | Fade in | 1.0 sec | Field BGM resumes from the **position where it was interrupted**, not from the beginning. Godot AudioStreamPlayer stores playback position before battle. |
| Field BGM | Boss BGM | Hard cut with intro | 0 sec + boss intro bars | Similar to normal battle but boss music has a non-looping intro |
| Boss BGM | Victory jingle | Hard cut | 0 sec | Same as normal battle |
| Field BGM | Shop BGM | Crossfade | 0.5 sec | Standard crossfade |
| Shop BGM | Field BGM | Crossfade | 0.5 sec | Resumes field BGM from stored position |
| Field BGM | Event BGM | Crossfade or hard cut | 0.5 sec or 0 sec | Crossfade for mood events. Hard cut for sudden dramatic events (designer-tagged per event). |
| Event BGM | Field BGM | Crossfade | 0.5 sec | Standard return |
| Any BGM | Gate jingle | Fade out | Over jingle duration (4-6 sec) | BGM fades out during Gate opening jingle |
| Gate jingle | Gate crossing BGM | Silence gap | 0.5 sec silence | Brief silence between jingle end and crossing BGM start |
| Gate crossing BGM | New world field BGM | Hard cut | 0 sec | Arrival is immediate. New world BGM starts fresh. |
| Field BGM | Breeding BGM | Crossfade | 0.5 sec | Entering breeding facility |
| Breeding BGM | Mutation jingle | Hard cut | 0 sec | All music stops for mutation reveal |
| Field BGM | Codex BGM | Crossfade | 0.5 sec | Opening codex |
| Any BGM | Game Over jingle | Hard cut | 0 sec | All music stops instantly |
| Game Over jingle | Game Over screen silence | Natural end | Jingle duration | Game Over screen is silent |

### 5.2 BGM Resume System

When battle interrupts field BGM, the system must:

1. Store current playback position of field BGM (`AudioStreamPlayer.get_playback_position()`).
2. Stop field BGM.
3. Play battle BGM from beginning.
4. After battle ends: play victory/defeat jingle.
5. After jingle: resume field BGM from stored position with 1.0 sec fade-in.

**Exception**: If the battle results in a story event (boss defeat, recruitment scene), the field BGM does NOT resume from stored position. Instead, event BGM plays, and when the event ends, field BGM restarts from the beginning.

### 5.3 Dramatic Silence Moments

Certain story moments require BGM to stop completely with no immediate replacement. These are tagged in the event script with `audio: silence`.

| Moment type | Silence duration | What follows |
|-------------|-----------------|--------------|
| Major revelation | 2-4 seconds | Event BGM (tension or dark) fades in |
| Character death | 3-5 seconds | Sad event BGM fades in |
| Gate rupture event | 5-8 seconds | Gate crossing BGM or tower abyss BGM |
| Final boss pre-battle | 3-4 seconds | Final boss BGM intro |
| Ending climax | Variable (scripted per beat) | Ending theme |

### 5.4 Layered BGM (Tower Depth System)

The Tower interior uses a **layered BGM system** rather than discrete track changes:

1. Upon entering the Tower, `bgm_tower_interior_upper` (BGM-004) begins.
2. As the player descends, the system **crossfades between Tower layers** based on floor depth:
   - Floors 1-5: BGM-004 at 100%, BGM-005 at 0%
   - Floors 6-8: BGM-004 at 60%, BGM-005 at 40%
   - Floors 9-11: BGM-004 at 20%, BGM-005 at 80%
   - Floors 12+: BGM-005 at 100%, BGM-006 begins fading in
   - Deepest floors: BGM-006 at 100%, all others at 0%
3. This crossfade is **continuous and tied to floor number**, not triggered by events.

Implementation: Three `AudioStreamPlayer` nodes, each playing one Tower BGM layer. Volume is interpolated based on `current_floor / max_floor` ratio.

---

## 6. Volume Architecture

### 6.1 Default Volume Settings

| Bus | Default level | Description |
|-----|--------------|-------------|
| Master | 100% (0 dB) | Overall game volume |
| BGM | 70% (-3.1 dB) | Background music |
| SE | 100% (0 dB) | Sound effects |
| Ambient | 40% (-8.0 dB) | Environmental ambience |
| Jingle | 90% (-0.9 dB) | Jingles and fanfares |

### 6.2 Player-Adjustable Ranges

| Bus | Min | Max | Step | UI control |
|-----|-----|-----|------|-----------|
| Master | 0% | 100% | 5% | Slider in Options → Audio |
| BGM | 0% | 100% | 5% | Slider in Options → Audio |
| SE | 0% | 100% | 5% | Slider in Options → Audio |

**Note**: Ambient and Jingle volumes are **not player-adjustable**. They are derived from BGM and SE respectively:
- Ambient volume = BGM volume × 0.57 (maintains the ~40/70 ratio)
- Jingle volume = SE volume × 0.90

This keeps the system simple (3 sliders) while preserving designed ratios.

### 6.3 Volume Ducking

| Trigger | Duck target | Duck amount | Attack | Release | Purpose |
|---------|------------|-------------|--------|---------|---------|
| Critical SE plays | BGM bus | -4 dB | 10 ms | 200 ms | Ensures critical sounds (encounter, critical hit, party KO) cut through music |
| Jingle plays (with duck tag) | BGM bus | -6 dB | 50 ms | 300 ms | Jingles that overlap BGM (item obtain, codex entry) reduce BGM to avoid masking |
| Jingle plays (with stop tag) | BGM bus | -∞ (mute) | 0 ms | N/A | Jingles that replace BGM (victory, game over) stop it entirely |
| Text box open (with voice-equivalent tick) | BGM bus | -2 dB | 100 ms | 100 ms | Subtle duck during text-heavy scenes to prioritize text tick rhythm |

### 6.4 Godot Audio Bus Layout

```
Master
├── BGM
│   └── (BGM StreamPlayers route here)
├── SE
│   └── (SE AudioStreamPlayer2D / Pool route here)
├── Ambient
│   └── (Ambient StreamPlayers route here)
└── Jingle
    └── (Jingle StreamPlayers route here)
```

Ducking is implemented via Godot's `AudioEffectCompressor` sidechain, or manual `volume_db` animation on the BGM bus when a critical SE or jingle fires.

---

## 7. AI Generation for Sound

### 7.1 Recommended Tools

| Tool | Primary use | Strengths | Weaknesses | Recommendation |
|------|------------|-----------|------------|----------------|
| **Suno v4+** | BGM generation | Good chiptune understanding; can specify BPM and mood; output length control | Sometimes adds reverb/modern effects; may exceed 4-channel feel; loop points need manual editing | **Primary BGM tool**. Generate, then clean. |
| **Udio** | BGM generation (backup) | Sometimes better at specific moods; different "flavor" of chiptune | Less consistent style adherence; tendency toward lo-fi rather than authentic 8-bit | **Secondary BGM tool**. Use when Suno output doesn't match mood. |
| **sfxr / jsfxr** | SE generation | Purpose-built for retro game SE; instant; highly controllable | Only generates single waveform SEs; no multi-layer sounds | **Primary SE tool** for simple SEs (UI, hits, ticks). |
| **ChipTone** | SE generation | More options than sfxr; envelope and filter control | Web-based; less batch-friendly | **Secondary SE tool** for complex SEs (spells, status effects). |
| **Bfxr** | SE generation | Fork of sfxr with more randomization options | Can be noisy | **Exploration tool** for discovering unusual SE timbres. |
| **FamiTracker / hUGETracker** | BGM manual composition | True hardware-accurate output; exact channel control | Requires composition skill; slow | **Polish tool** for final loop-point editing and channel cleanup. |
| **Audacity / Ocenaudio** | Post-processing | Loudness normalization, loop point editing, format conversion | Not for generation | **Mandatory post-processing step** for all audio. |

### 7.2 BGM AI Generation Prompt Template

```
Base template:
"8-bit chiptune music in the style of Game Boy Color sound hardware.
[MOOD KEYWORDS].
Tempo: [BPM] BPM.
Key: [KEY AND MODE].
Lead instrument: pulse wave (square wave).
Bass: wave memory channel (simple waveform bass).
Percussion: noise channel only (no samples).
Maximum 4 simultaneous voices.
No reverb, no delay, no modern effects.
No vocals.
Structure: [STRUCTURE DESCRIPTION].
Must loop cleanly — ending should connect smoothly back to [LOOP POINT]."
```

**Mood keyword library** (use 2-3 per prompt):

| Mood category | Keywords |
|--------------|----------|
| Peaceful | gentle, pastoral, warm, cozy, nostalgic, breezy, sleepy, lullaby |
| Adventure | heroic, marching, brave, uplifting, determined, journey |
| Battle (standard) | energetic, driving, intense, rhythmic, pumping, aggressive |
| Battle (boss) | epic, grand, imposing, menacing, powerful, orchestral-chiptune |
| Tension | suspenseful, creeping, ominous, dark, foreboding, uneasy |
| Sadness | melancholic, mournful, lonely, bittersweet, elegiac, lamenting |
| Mystery | enigmatic, ethereal, otherworldly, mystical, arcane, ancient |
| Triumph | victorious, celebratory, glorious, triumphant, resolving |
| Horror | dreadful, dissonant, unsettling, alienating, void-like, decaying |

### 7.3 SE AI Generation Prompt Template

For tools that accept text prompts (less common for SE; most SE is generated via parameter tweaking):

```
"8-bit retro game sound effect. [DESCRIPTION].
[DURATION] seconds long.
Waveform: [pulse/noise/wave].
No reverb or processing.
Sounds like it came from a Game Boy."
```

For sfxr/jsfxr/ChipTone, the "prompt" is parameter settings. Recommended starting points:

| SE type | sfxr preset | Key adjustments |
|---------|------------|-----------------|
| UI click/blip | "Pickup/Coin" | Reduce sustain, increase frequency |
| Hit/impact | "Hit/Hurt" | Adjust attack envelope, add noise |
| Spell/magic | "Powerup" or "Laser" | Adjust sweep, add frequency slide |
| Error/buzz | "Random" → filter for noise | Keep harsh, short, distinctive |
| Environmental | "Explosion" at low volume | Reduce punch, lengthen decay |

### 7.4 Loop Point Specification in AI Prompts

AI tools do not reliably create perfect loops. The strategy is:

1. **In the prompt**: Include `"Must loop cleanly — the ending should flow back to the beginning"` and `"No fade-in at the start, no fade-out at the end"`.
2. **Expect imperfection**: AI output will almost always have slight mismatches at loop boundaries.
3. **Manual fix (mandatory for all BGM)**:
   - Import into Audacity.
   - Identify the musically correct loop start point (typically beat 1 of the first full measure after any intro).
   - Identify the loop end point (last beat before the music would repeat).
   - Trim to these points.
   - Apply a 5-10ms crossfade at the loop boundary to eliminate clicks.
   - Verify loop by enabling looped playback in Audacity.
   - Export.

### 7.5 Common AI Audio Artifacts and Fixes

| Artifact | Description | Fix |
|----------|-------------|-----|
| Fade-in on first beat | AI adds a volume ramp at the start, breaking loop seamlessness | Trim the fade-in. If the first note is affected, regenerate or manually reconstruct the first 100ms. |
| Fade-out on last beat | AI assumes the track should end, adds a fade | Trim the fade. Extend the last note if needed to reach the loop point. |
| Tempo drift | BPM shifts slightly over the track, making loops inconsistent | Use a tempo detection tool. If drift is <2%, time-stretch to fix. If >2%, regenerate. |
| Extra channels | AI generates 6+ simultaneous voices instead of 4 | Listen critically. If the extra voices are subtle, the track may still sound authentic. If it sounds "too full," regenerate with stricter prompt language. |
| Reverb / echo | AI adds spacial effects despite "no reverb" instruction | Cannot be cleanly removed in post. Regenerate. |
| Clipping | Peaks exceed 0 dBFS | Apply limiter in post. Normalize to -16 LUFS. |
| Style mismatch | Output sounds like NES (triangle wave) instead of GBC (wave memory) | The difference is subtle. Accept if the overall feel is correct. Reject if it sounds like a different era entirely. |
| Unintended melody quotation | AI output accidentally resembles a copyrighted melody | Compare against known game soundtracks. If similarity is notable, regenerate. |

### 7.6 Manual Cleanup Workflow

Every AI-generated audio file must pass through this pipeline before integration:

```
1. LISTEN — Full playback, check for artifacts
2. TRIM — Remove silence, fade-ins, fade-outs
3. LOOP — Set and verify loop points (BGM only)
4. NORMALIZE — Apply loudness normalization to -16 LUFS
5. PEAK LIMIT — Ensure true peak ≤ -1.0 dBTP
6. CHANNEL CHECK — Verify mono compatibility (BGM: check that stereo collapse doesn't lose important content)
7. FORMAT — Export to target format (OGG for BGM/jingles, WAV for SE)
8. NAME — Apply file naming convention
9. TAG — Add metadata: track name, BPM, key, loop points (as OGG comments or sidecar JSON)
10. INTEGRATE — Import into Godot, assign to appropriate audio bus, test in-game
```

---

## 8. Silence as Design

### 8.1 Philosophy

Silence in this game is not the absence of design — it is the most deliberate audio choice. The Tower, the Gates, and the boundary world W-021 use silence as a thematic statement: where the institutions of naming and belonging break down, sound itself becomes unreliable.

### 8.2 Intentional Silence Zones

| Zone / Moment | Silence type | Duration | What replaces music | Narrative purpose |
|---------------|-------------|----------|--------------------|--------------------|
| Tower abyss (deepest floors) | Near-silence | Continuous while in zone | Sub-bass hum + isolated tones (BGM-006 at minimum volume, effectively ambient) | The Tower consumes identity, including the player's musical identity |
| Gate crossing | True silence | 0.5 sec between Gate jingle and crossing BGM | Nothing — absolute zero audio for 500ms | The liminal space between worlds has no sound. A breath between realities. |
| W-021 field (ほどけの縁) | Ambient-only (no BGM) | Entire world | See W-021 ambient spec in Section 4.4 | A world where definitions dissolve cannot sustain structured music |
| Post-boss-death pause | True silence | 2-3 sec | Nothing | Let the weight of the victory/defeat settle before music resumes |
| Major story revelation | True silence | 2-5 sec (designer-specified per event) | Nothing, then tension BGM fades in | Force the player to sit with the information |
| Game Over screen | Near-silence | After jingle ends, indefinitely | Faint ambient hum only | Defeat is quiet. No music to soften it. |
| Final boss pre-battle | True silence | 3-4 sec | Nothing, then final boss intro | The calm before the definitive confrontation |

### 8.3 Silence Duration Guidelines

| Duration | Effect | Use case |
|----------|--------|----------|
| 0.3-0.5 sec | Punctuation — a beat, a breath | Transition gaps, Gate crossing |
| 1-2 sec | Emphasis — something just happened | Post-hit pause, menu transition to important screen |
| 3-5 sec | Weight — the player must absorb something | Major revelation, character death, boss defeat |
| 5-8 sec | Dread — something is deeply wrong | Gate rupture, entering W-021, approaching the final gate |
| 8+ sec | Discomfort — intentional | Only in W-021 and the Tower abyss. The game is making the player uncomfortable on purpose. |

### 8.4 The Tower Rule (Audio Version)

As the player approaches the Tower from any world, audio follows this gradient:

1. **Distance > 100 tiles from Tower entrance**: Normal world BGM and ambient at full volume.
2. **100-50 tiles**: BGM volume reduces by 1% per tile approached. Ambient remains full.
3. **50-20 tiles**: BGM at 50% max. World ambient begins reducing. Tower hum (low sub-bass drone) fades in.
4. **20-5 tiles**: BGM at 20%. World ambient at 30%. Tower hum at 70%.
5. **5-0 tiles**: BGM at 5% (barely audible). World ambient at 10%. Tower hum at 100%.
6. **Tower entrance**: BGM cuts. Tower interior BGM begins. World ambient replaced by Tower ambient.

This gradient is implemented by reading the player's distance to the nearest Tower entrance node and interpolating volume parameters accordingly.

### 8.5 W-021 (ほどけの縁) — Full Audio Design

W-021 is the most radical audio zone in the game.

- **No BGM at all.** The BGM bus is muted for the entirety of W-021.
- **Ambient only**: Sub-bass hum (barely audible, felt more than heard) + isolated pulse wave tones at unpredictable intervals (every 8-20 seconds, randomized).
- **SE remain normal** — the player's actions still make sound, grounding them in the game's systems even as the world dissolves.
- **The isolated pulse tones** are high-pitched (C6-C7 range), last 0.5-1.5 seconds each, and have no musical relationship to each other. They are the remnants of melody in a world where structure has unraveled.
- **If the player stands still for 30+ seconds**: An additional low wave channel tone begins, slowly oscillating. This is the only "ambient music" in W-021 and it should feel like the world breathing.

---

## 9. Per-World Music Design Notes

### 9.1 Format

For each world: BGM mood, lead instrument emphasis, tempo, shared/unique track status, ambient layer summary.

---

### W-001 — 名伏せの野 (Nameless Fields)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Pastoral, gentle, the opening world's innocence. A folk melody that feels like it has always existed. Slight sadness under the warmth — borrowed names imply impermanence. |
| **Lead channel** | CH1 pulse (50% duty) carries the melody — warm, round, folk-song quality |
| **Support** | CH2 pulse (25% duty) plays counter-melody in thirds. CH3 wave provides root-fifth bass pattern. CH4 noise: gentle march (kick on 1, light hat on off-beats). |
| **Tempo** | 92 BPM |
| **Key** | F major, Mixolydian inflections (flat 7th gives pastoral character) |
| **Shared / unique** | Shared base with W-002 and W-008 (COR-01 pastoral group) |
| **Ambient** | Wind through reeds + distant livestock bells. See Section 4.4. |
| **Track file** | `bgm_world_w001_field.ogg` |

---

### W-002 — 灰乳の谷 (Ash-Milk Valley)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Pastoral variant — drier, more somber. The valley's maternal judgment system gives the music a heavier quality. Less playful than W-001. |
| **Lead channel** | CH3 wave carries the melody here — lower register, mournful quality. The wave channel's slightly raw timbre matches ash and bone. |
| **Support** | CH1 pulse plays sparse counter-melody. CH2 pulse holds sustained notes (implied harmony). CH4 noise: slower, heavier footsteps rhythm. |
| **Tempo** | 84 BPM (slower than W-001) |
| **Key** | D minor (darker reharmonization of the COR-01 base melody) |
| **Shared / unique** | Shared base with W-001, reharmonized and slowed. Melody transposed down to wave channel. |
| **Ambient** | Dry wind + stone settling + bleating. See Section 4.4. |
| **Track file** | `bgm_world_w002_field.ogg` |

---

### W-003 — 継灯の宿場 (Lantern-Keep Inn Town)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Bustling, warm but guarded. A waystation where names are hidden behind lanterns. The music should feel like the chatter of travelers — lively but with everyone keeping secrets. |
| **Lead channel** | CH1 pulse (25% duty) — brighter, thinner tone. Nimble melody with ornamental runs. |
| **Support** | CH2 pulse plays rhythmic arpeggiated chords. CH3 wave: walking bass line. CH4 noise: lively percussion, almost dance-like. |
| **Tempo** | 112 BPM |
| **Key** | Bb major, with brief minor-key dips in the B section |
| **Shared / unique** | Shared lighter base with W-013 (COR-02 ledger group, lighter variant) |
| **Ambient** | Town bustle + lantern crackle. See Section 4.4. |
| **Track file** | `bgm_world_w003_field.ogg` |

---

### W-004 — 札差しの岬 (Toll-Tag Cape)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Maritime authority. The checkpoint at the sea. Official, structured, with the weight of bureaucracy and salt air. A march tempered by ocean vastness. |
| **Lead channel** | CH1 pulse (50% duty) — bold, declarative melody. March-like phrases. |
| **Support** | CH2 pulse: fanfare-style interjections. CH3 wave: deep bass, evoking ocean depth. CH4 noise: marching snare pattern. |
| **Tempo** | 104 BPM |
| **Key** | Eb major, with Mixolydian flat-7 for a sea-shanty quality |
| **Shared / unique** | Shared transit base with W-012 (COR-04) |
| **Ambient** | Ocean waves + seabirds + foghorn. See Section 4.4. |
| **Track file** | `bgm_world_w004_field.ogg` |

---

### W-005 — 香なしの墓苑 (Incenseless Graveyard)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Solemn, sparse, absence. The defining quality of this world is what is NOT there — no incense, no proper mourning. The music reflects this with minimal voices and long rests. |
| **Lead channel** | CH1 pulse (12.5% duty) — thin, reedy, barely there. Plays only in the A section. |
| **Support** | CH2 pulse: silent in A section, enters in B with a ghostly counter-melody. CH3 wave: sustained low notes, the earth holding the dead. CH4 noise: only dripping water rhythm (very sparse). |
| **Tempo** | 64 BPM |
| **Key** | E minor, Aeolian, no raised 7th — no resolution |
| **Shared / unique** | Shared mourning base with W-006, W-011, W-015 (COR-03) |
| **Ambient** | Still air + dripping + faint chanting. See Section 4.4. |
| **Track file** | `bgm_world_w005_field.ogg` |

---

### W-006 — 鈴結びの湿地 (Bell-Knot Wetlands)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Wet, ritualistic, tangled. Bells and knots: the music should feel knotted — phrases that seem to tie back on themselves, repetitive in a ritual way. |
| **Lead channel** | CH2 pulse (25% duty) — bell-like staccato melody, repeating motifs that "knot" |
| **Support** | CH1 pulse: sustained pad-like tones. CH3 wave: bubbling bass pattern, imitating swamp water. CH4 noise: rain-like patter + occasional bell simulation (high-pitch noise burst). |
| **Tempo** | 72 BPM |
| **Key** | G minor, Dorian mode (natural 6th gives a slightly brighter melancholy) |
| **Shared / unique** | COR-03 mourning base with different instrumentation — the melody is rhythmically related to W-005 but in a different key and tempo. |
| **Ambient** | Water bubbling + bell fragments + insect buzz. See Section 4.4. |
| **Track file** | `bgm_world_w006_field.ogg` |

---

### W-007 — 削名の階市 (Name-Shaving Stair City)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Vertical, hierarchical, cold efficiency. A city built on stairs where your role-name determines your rank. The music is structured, regimented, impressive but impersonal. |
| **Lead channel** | CH1 pulse (50% duty) — ascending scale patterns, always climbing |
| **Support** | CH2 pulse: descending counterpoint (hierarchy goes both ways). CH3 wave: heavy stepwise bass, like marching up stone stairs. CH4 noise: regimented snare, strict tempo. |
| **Tempo** | 108 BPM |
| **Key** | C minor, with Lydian-dominant passages in the B section (bright but unstable) |
| **Shared / unique** | Shared institutional base with W-010, W-018 (COR-02 heavier variant) |
| **Ambient** | City noise + proclamation horns + coins. See Section 4.4. |
| **Track file** | `bgm_world_w007_field.ogg` |

---

### W-008 — 獣印の放牧環 (Beast-Brand Pasture Ring)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Pastoral turned harsh. The same fields as W-001 but ownership is absolute. The gentleness is there but strained — the brand iron is always heating. |
| **Lead channel** | CH1 pulse (50% duty) — W-001 melody variant, but rhythm is more aggressive (dotted rhythms, accents) |
| **Support** | CH2 pulse: adds rhythmic pulse pattern (branding rhythm). CH3 wave: same bass as W-001 but with sharper attack. CH4 noise: heavier kick, louder hats, a work rhythm. |
| **Tempo** | 96 BPM (slightly faster than W-001) |
| **Key** | F minor (minor-mode transformation of W-001's F major) |
| **Shared / unique** | COR-01 pastoral base, transformed — same melody in minor mode with aggressive rhythm |
| **Ambient** | Heavy wind + branding sizzle + animal stamping. See Section 4.4. |
| **Track file** | `bgm_world_w008_field.ogg` |

---

### W-009 — 仮親の雪原 (Foster-Parent Snowfield)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Frozen isolation, family fractured by weather and naming. Cold, vast, lonely. The winter itself is a character. Music should feel like warmth trying to survive in hostile cold. |
| **Lead channel** | CH1 pulse (12.5% duty) — thin, crystalline, high register. Fragile melody. |
| **Support** | CH2 pulse: tremolo (rapid on-off) simulating shivering. CH3 wave: deep, slow bass — the frozen earth beneath. CH4 noise: blizzard wind simulation (sustained white noise with volume modulation). |
| **Tempo** | 68 BPM |
| **Key** | F# minor, Aeolian, stark and unadorned |
| **Shared / unique** | **Unique**. Too sonically distinct to share with other COR-01 worlds. |
| **Ambient** | Blizzard wind (loud) + cracking ice + distant howl. See Section 4.4. |
| **Track file** | `bgm_world_w009_field.ogg` |

---

### W-010 — 群書の塩庫 (Salt-Archive Warehouse)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Institutional damp. Records and salt preserved together — the music should feel catalogued, methodical, but with an underlying moisture that threatens to dissolve everything. |
| **Lead channel** | CH1 pulse (25% duty) — clipped, precise melody like a clerk's handwriting |
| **Support** | CH2 pulse: rhythmic staccato, ledger-stamping rhythm. CH3 wave: low drone suggesting warehouse acoustics. CH4 noise: dripping + mechanical rhythm (cargo loading). |
| **Tempo** | 100 BPM |
| **Key** | A minor, mechanical quality |
| **Shared / unique** | COR-02 institutional base shared with W-007 and W-018. W-010 variant emphasizes wave channel drone (dampness). |
| **Ambient** | Warehouse hum + paper rustling + canal water. See Section 4.4. |
| **Track file** | `bgm_world_w010_field.ogg` |

---

### W-011 — 逆誓の修院 (Reverse-Oath Monastery)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Sacred inversion. A monastery where oaths are spoken backwards. The music should contain motifs that sound reversed or palindromic. Solemn but disorienting. |
| **Lead channel** | CH1 pulse (50% duty) — melody that reads the same forward and backward (palindrome phrases) |
| **Support** | CH2 pulse: plays the A melody in retrograde during the B section. CH3 wave: bell-tower bass, tolling on downbeats. CH4 noise: sparse, monastery silence with occasional bell-hit. |
| **Tempo** | 72 BPM |
| **Key** | C minor → C major (the reversal expressed harmonically) |
| **Shared / unique** | COR-03 mourning base, most dramatically altered — the palindrome structure is unique to W-011. |
| **Ambient** | Stone echo + reversed chanting + bell toll. See Section 4.4. |
| **Track file** | `bgm_world_w011_field.ogg` |

---

### W-012 — 骨樋の港 (Bone-Gutter Harbor)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Industrial port, bones and cargo are the same. A working harbor where death is just another commodity. Energetic but grim. |
| **Lead channel** | CH1 pulse (50% duty) — sea-shanty rhythm, modal melody |
| **Support** | CH2 pulse: call-and-response pattern with CH1. CH3 wave: heavy bass, harbor machinery. CH4 noise: complex rhythm — waves, chains, loading. |
| **Tempo** | 116 BPM |
| **Key** | G Mixolydian (shanty character, flat 7th) |
| **Shared / unique** | COR-04 transit base shared with W-004. W-012 is faster, grimmer, more rhythmically complex. |
| **Ambient** | Harbor water + gulls + bone scraping. See Section 4.4. |
| **Track file** | `bgm_world_w012_field.ogg` |

---

### W-013 — 無籍の葡萄段 (Unregistered Vineyard Terraces)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Agrarian labor, invisible workers. A Mediterranean-feeling terrace farm where the people who tend it officially do not exist. The music is warm but carries the weight of erasure. |
| **Lead channel** | CH2 pulse (25% duty) — light, dancing melody like vine tendrils |
| **Support** | CH1 pulse: sustained harmony notes, the terraces. CH3 wave: earthy bass, soil and stone. CH4 noise: harvesting rhythm, agricultural. |
| **Tempo** | 104 BPM |
| **Key** | D major, occasional borrowed minor chords |
| **Shared / unique** | COR-02 lighter base shared with W-003. W-013 is more rural, less urban. |
| **Ambient** | Hillside wind + harvesting sounds + faint singing. See Section 4.4. |
| **Track file** | `bgm_world_w013_field.ogg` |

---

### W-014 — 返らずの鏡森 (Mirror Forest of No Return)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Reflection, disorientation, beauty that traps. A forest where your reflection overwrites your identity. The music should shimmer and mirror itself — phrases reflected across a central axis. |
| **Lead channel** | CH1 pulse (25% duty) — melody in the upper register, crystalline |
| **Support** | CH2 pulse: plays the same melody delayed by one beat (canon/mirror). CH3 wave: root notes only, grounding against the disorientation. CH4 noise: minimal — forest is quiet. |
| **Tempo** | 80 BPM |
| **Key** | Ab major with sudden enharmonic shifts (Db = C# pivots) |
| **Shared / unique** | **Unique.** COR-05 worlds are each distinct. |
| **Ambient** | Deep forest + unnatural echo + delayed footsteps. See Section 4.4. |
| **Track file** | `bgm_world_w014_field.ogg` |

---

### W-015 — 黒布の巡礼路 (Black-Cloth Pilgrimage Road)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Solemn procession, veiled grief. Walking a road where faces must be covered. The music is a march — slow, dignified, funereal but with forward motion. |
| **Lead channel** | CH3 wave — low, processional melody. The wave channel's gravitas matches the solemnity. |
| **Support** | CH1 pulse: sparse, high counterpoint like distant singing. CH2 pulse: held chords. CH4 noise: processional drum — steady, relentless march beat. |
| **Tempo** | 76 BPM |
| **Key** | Bb minor, Aeolian |
| **Shared / unique** | COR-03 mourning base, most processional variant — rhythm is the dominant feature here. |
| **Ambient** | Dry wind + cloth flapping + distant drums. See Section 4.4. |
| **Track file** | `bgm_world_w015_field.ogg` |

---

### W-016 — 焼継の鍛土 (Fire-Mending Forge Soil)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Forge heat, repair as identity. A world of ceramics and bloodlines mended with the same fire. The music is rhythmic (hammering), warm (forge glow), resolute. |
| **Lead channel** | CH4 noise — percussion-forward track. The hammering rhythm IS the melody. |
| **Support** | CH1 pulse: melodic fragments between hammer strikes. CH2 pulse: heat-shimmer tremolo. CH3 wave: forge-drone bass, sustained and warm. |
| **Tempo** | 120 BPM |
| **Key** | A minor, pentatonic flavor (hammer scale) |
| **Shared / unique** | **Unique.** Percussion-led structure is unlike any other world. |
| **Ambient** | Forge hum + hammer strikes + cooling metal ticks. See Section 4.4. |
| **Track file** | `bgm_world_w016_field.ogg` |

---

### W-017 — 残名の回廊 (Lingering-Name Corridor)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Ghostly echo, names arriving before their speakers. A corridor of residual sound. The music should feel like it was played minutes ago and you are hearing its echo — everything is slightly decayed and smeared. |
| **Lead channel** | CH2 pulse (12.5% duty) — extremely thin, as if heard through walls |
| **Support** | CH1 pulse: plays fragments of other world themes (quotation of W-001, W-005 melodies, distorted). CH3 wave: resonant bass, corridor acoustics. CH4 noise: footstep echoes, door sounds. |
| **Tempo** | 60 BPM |
| **Key** | Chromatic, drifting — suggests keys without settling |
| **Shared / unique** | **Unique.** The quotation of earlier themes makes this a meta-musical world. |
| **Ambient** | Hollow echo + name-whispers + door sounds. See Section 4.4. |
| **Track file** | `bgm_world_w017_field.ogg` |

---

### W-018 — 二署の法台 (Twin-Bureau Judiciary Platform)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Bureaucratic tension, two institutions in conflict. The music should feel like two melodies arguing — overlapping, interrupting, never quite harmonizing. |
| **Lead channel** | CH1 pulse and CH2 pulse alternate carrying the melody, each "interrupting" the other mid-phrase |
| **Support** | CH3 wave: authoritative bass, gavels and stamps. CH4 noise: stamp rhythm, crowd murmur. |
| **Tempo** | 108 BPM |
| **Key** | D minor vs. D major — alternating, never settling (the two bureaus disagree on even the key) |
| **Shared / unique** | COR-02 institutional base shared with W-007, W-010 — heaviest and most conflicted variant. |
| **Ambient** | Administrative hum + stamps + argument. See Section 4.4. |
| **Track file** | `bgm_world_w018_field.ogg` |

---

### W-019 — 閉鐘の塔都 (Silent-Bell Tower City)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | A city where the bell has stopped ringing. The music has a "missing beat" — a rhythmic gap where a bell tone should fall but doesn't. Tense, anticipatory, the front line against the Tower. |
| **Lead channel** | CH1 pulse (50% duty) — urban melody, march-like but halting |
| **Support** | CH2 pulse: plays a bell pattern with rests where the bell tone should be. CH3 wave: civic bass, stone and metal. CH4 noise: military-influenced percussion with the same "missing beat" gap. |
| **Tempo** | 96 BPM |
| **Key** | Eb minor — heavy, fortified |
| **Shared / unique** | **Unique.** The missing-beat concept is specific to W-019. |
| **Ambient** | Muted city + absent bell silence + wind through empty tower. See Section 4.4. |
| **Track file** | `bgm_world_w019_field.ogg` |

---

### W-020 — 継ぎ止めの聖郭 (Mending-Halt Holy Citadel)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | Sacred corruption, institutional grandeur hiding rot. A holy citadel that has been "mending" — patching over sins with bureaucracy and doctrine. The music is grand, choral in feel, but the harmony is subtly wrong. |
| **Lead channel** | CH3 wave — organ-like sustained tones, cathedral acoustics simulated through wave channel |
| **Support** | CH1 pulse: hymn-like melody, devotional. CH2 pulse: responses to CH1, liturgical call-and-response. CH4 noise: processional percussion, grander than W-015. |
| **Tempo** | 88 BPM |
| **Key** | Db major with Neapolitan chord emphasis (bII chord prominence = unease within grandeur) |
| **Shared / unique** | **Unique.** The largest-scale world has the most unique musical identity. |
| **Ambient** | Cathedral echo + choral fragments + quill scratching. See Section 4.4. |
| **Track file** | `bgm_world_w020_field.ogg` |

---

### W-021 — ほどけの縁 (Unraveling Edge)

| Aspect | Detail |
|--------|--------|
| **BGM mood** | **No BGM.** This is a silent world. See Section 8.5 for full ambient-only audio design. |
| **Lead channel** | N/A — no music |
| **Support** | N/A |
| **Tempo** | N/A |
| **Key** | N/A |
| **Shared / unique** | **Unique** — the only world with no music at all |
| **Ambient** | Sub-bass hum + isolated pulse tones at random intervals. See Section 4.4 and Section 8.5. |
| **Track file** | No BGM file. Ambient file: `amb_w021_field.ogg` |

---

### 9.2 Summary: Track Count by Type

| Category | Unique tracks | Variants | Total files |
|----------|--------------|----------|-------------|
| World field BGM | 14 | 7 | 21 |
| Title | 1 | 0 | 1 |
| Village home | 1 | 0 | 1 |
| Tower (3 layers) | 3 | 0 | 3 |
| Tower approach | 1 | 0 | 1 |
| Normal battle (3 acts) | 3 | 0 | 3 |
| Boss battle (3 tiers) | 3 | 0 | 3 |
| Final boss | 1 | 0 | 1 |
| Secret boss | 1 | 0 | 1 |
| Tournament (2) | 2 | 0 | 2 |
| Breeding | 1 | 0 | 1 |
| Ranch | 1 | 0 | 1 |
| Shop | 1 | 0 | 1 |
| Codex | 1 | 0 | 1 |
| Event tracks (4) | 4 | 0 | 4 |
| Gate crossing | 1 | 0 | 1 |
| Ending | 1 | 0 | 1 |
| Credits | 1 | 0 | 1 |
| Postgame ending | 1 | 0 | 1 |
| **BGM Total** | **41** | **7** | **48** |
| Jingles | 11 | 0 | 11 |
| **Grand Total (music)** | **52** | **7** | **59** |

---

## 10. Quality Checklist for Audio

### 10.1 Per-File Checklist (Every Audio File)

| # | Check | Pass criteria | Tool |
|---|-------|--------------|------|
| 1 | **Format correct** | BGM/jingles: OGG q6 stereo 44.1kHz. SE: WAV 16-bit mono 44.1kHz. | File properties inspection |
| 2 | **Loudness normalized** | -16 LUFS ±1 LU, true peak ≤ -1.0 dBTP | Youlean / ffmpeg loudnorm |
| 3 | **No clipping** | Zero samples at 0 dBFS | Waveform visual inspection + peak meter |
| 4 | **No DC offset** | Mean amplitude centered at 0 | Audacity Analyze → Plot Spectrum |
| 5 | **No artifacts** | No clicks, pops, hum, or digital glitches | Full playback listening |
| 6 | **Naming convention** | Matches `bgm_`/`se_`/`jingle_`/`amb_` prefix convention | Manual review |
| 7 | **Metadata tagged** | Sidecar JSON or OGG comments include: name, BPM, key, loop start sample, loop end sample | Metadata tool |

### 10.2 BGM-Specific Checks

| # | Check | Pass criteria | Method |
|---|-------|--------------|--------|
| 8 | **Loop seamlessness** | No audible gap, click, volume bump, or rhythmic hiccup at loop boundary | Looped playback ×5 minimum, eyes closed |
| 9 | **Loop length adequate** | Loop duration ≥30 sec for battle, ≥50 sec for field/village, ≥60 sec for dungeon | Timer |
| 10 | **Repetition fatigue test** | Loop 10× continuously. Does it become grating? | Subjective listening session (minimum 2 listeners) |
| 11 | **Channel count authentic** | No more than 4 simultaneous voices at any point in the track | Spectral analysis or trained ear |
| 12 | **No forbidden effects** | No reverb, delay, chorus, flanger, or spatial effects | Spectral analysis and listening |
| 13 | **Emotional match** | Music evokes the intended mood listed in the track catalog (Section 2) | Blind listening test — play track without context, ask listener to describe the mood |
| 14 | **Retro authenticity** | Could plausibly come from GBC hardware. No sound that is impossible on PSG. | A/B comparison with actual GBC game audio |
| 15 | **Mono compatibility** | Collapsing stereo to mono does not lose critical musical content or cause phase cancellation | Mono fold-down test in DAW |

### 10.3 SE-Specific Checks

| # | Check | Pass criteria | Method |
|---|-------|--------------|--------|
| 16 | **Duration within spec** | Matches duration specified in SE catalog (Section 3) ±20% | Timer |
| 17 | **Pitch variation sounds natural** | Playing SE 10× with random pitch ±10% does not produce unpleasant outliers | Script test in Godot |
| 18 | **Audible over BGM** | SE at its specified relative volume is clearly audible when the loudest BGM track is playing | In-game test with loudest BGM |
| 19 | **Does not mask other SE** | Playing 3 simultaneous SEs does not create a muddy mess | Stress test: encounter + hit + spell at once |
| 20 | **Trigger latency** | SE plays within 1 frame (16.6ms at 60fps) of trigger event | In-game frame count |

### 10.4 Integration Checks (In-Game)

| # | Check | Pass criteria | Method |
|---|-------|--------------|--------|
| 21 | **Crossfade smooth** | 0.5 sec crossfade between scenes has no gap, no overlap artifact | Play through every scene transition |
| 22 | **BGM resume from position** | After battle, field BGM resumes from where it was interrupted | Trigger battle at various points in the BGM loop |
| 23 | **Volume ducking responsive** | Critical SE ducks BGM by -4dB with 10ms attack, returns in 200ms | Trigger critical SE during loud BGM passage |
| 24 | **Ambient blends with BGM** | Ambient is perceivable but never competes with BGM melody | Walk through all world zones with ambient + BGM |
| 25 | **Tower distance gradient** | BGM fades correctly as player approaches Tower (Section 8.4 gradient) | Walk toward Tower, measure volume at checkpoints |
| 26 | **W-021 silence** | No BGM plays in W-021, ambient-only system works as designed | Full W-021 playthrough |
| 27 | **Jingle → BGM transitions** | Victory jingle → field BGM resume is timed correctly | Win 10 battles, check each transition |
| 28 | **Simultaneous audio count** | Never more than 8 concurrent SE + 1 BGM + 2 ambient + 1 jingle at any moment | Stress test: battle with multiple effects |
| 29 | **Volume settings persist** | Player-adjusted volume survives save/load cycle | Change volumes, save, reload, verify |
| 30 | **Mute function** | Setting any volume to 0% produces true silence on that bus | Test each bus at 0% |

### 10.5 Full Playthrough Audio Audit

Before release, a complete audio audit is performed:

1. **Silent playthrough**: Play the entire game with audio muted. Note every moment where audio would be important for gameplay feedback (battle hits, status ailments, UI navigation). Verify that visual feedback is sufficient even without audio (accessibility).

2. **Audio-only playthrough**: Close eyes and listen to someone else play. Note every moment where the audio tells you what is happening. Note every moment where it does NOT — those are gaps in the SE design.

3. **Emotional arc playthrough**: Play through the main story focusing only on whether the music matches the emotional beats. Note any scene where the music undercuts or contradicts the intended mood.

4. **Repetition endurance test**: Spend 30 minutes in the same zone (grinding). Note when the BGM becomes irritating. If under 15 minutes, the loop is too short or the melody too aggressive.

5. **Headphone test**: Full playthrough on headphones. Check for stereo issues, harshness in high frequencies, and sub-bass problems that speakers mask.

6. **Speaker test**: Full playthrough on phone speakers. Check that all critical SEs are audible and BGM bass is not completely lost.

---

## Appendix A: Godot Implementation Notes

### Audio Bus Configuration

```gdscript
# AudioManager autoload handles all music transitions
# Bus layout in Godot:
# 0: Master
# 1: BGM (child of Master)
# 2: SE (child of Master)
# 3: Ambient (child of Master)
# 4: Jingle (child of Master)
```

### BGM Resume System (Pseudocode)

```gdscript
var stored_bgm_position: float = 0.0
var current_bgm_stream: AudioStream = null

func enter_battle():
    stored_bgm_position = bgm_player.get_playback_position()
    current_bgm_stream = bgm_player.stream
    bgm_player.stop()
    play_se("se_battle_encounter")
    play_bgm(battle_bgm, 0.0)  # start from beginning

func exit_battle_to_field():
    bgm_player.stop()
    play_bgm(current_bgm_stream, stored_bgm_position, 1.0)  # 1.0 sec fade-in
```

### Tower Distance Volume (Pseudocode)

```gdscript
func _process(delta):
    var dist = player.global_position.distance_to(tower_entrance.global_position)
    var bgm_factor = clamp(remap(dist, 0, 100, 0.05, 1.0), 0.05, 1.0)
    var tower_hum_factor = clamp(remap(dist, 0, 100, 1.0, 0.0), 0.0, 1.0)
    AudioServer.get_bus_volume_db(bgm_bus, linear_to_db(bgm_factor * base_bgm_volume))
    tower_ambient_player.volume_db = linear_to_db(tower_hum_factor)
```

---

## Appendix B: Asset Delivery Schedule

| Phase | Deadline | Deliverables |
|-------|----------|-------------|
| Phase 0 | Vertical slice milestone | BGM-001 (title), BGM-002 (village), BGM-028 (normal battle), BGM-007/W-001 (first world field), JGL-001 (victory), JGL-007 (game over), 10 core SE (menu + basic battle) |
| Phase 1 | Act I-II content complete | All Act I-II world BGMs, BGM-031 (boss 01), BGM-038 (breeding), BGM-039 (ranch), BGM-040 (shop), all jingles, all menu SE, all battle SE, all field SE, all breeding SE, all system SE |
| Phase 2 | Act III-V content complete | All remaining world BGMs, BGM-029/030 (normal battle 02/03), BGM-032/033 (boss 02/03), BGM-034 (final boss), event BGMs, BGM-046 (gate crossing), BGM-047 (ending), all ambient tracks |
| Phase 3 | Postgame + polish | BGM-035 (secret boss), BGM-036/037 (tournament), BGM-041 (codex), BGM-048 (credits), BGM-049 (postgame ending), ambient polish, full audio audit |

---

## Appendix C: Reference Soundtracks

For mood and style reference only — never use these as direct prompts or copy targets.

| Reference | What to take from it | What to avoid |
|-----------|---------------------|---------------|
| Dragon Quest Monsters: Terry's Wonderland (GBC) | Loop structure, battle energy, 4-channel discipline | Direct melodic quotation |
| Pokemon Gold/Silver (GBC) | Town theme warmth, route adventure feel, SE crispness | The specific "Pokemon sound" — this game should NOT sound like Pokemon |
| The Legend of Zelda: Link's Awakening (GB/GBC) | Dungeon atmosphere, emotional range within 4 channels | The heroic grandeur — this game is more muted |
| Undertale (chiptune-influenced) | Emotional range in simple sounds, silence as design tool, leitmotif usage | Undertale's specific melodic style and humor |
| Final Fantasy Legend / SaGa series (GB) | Melancholy in adventure, moral ambiguity in music | The SaGa combat system assumptions about audio pacing |

**Absolute prohibition**: No AI prompt may contain any of these titles, composer names, or character names. Reference is for the human production team's internal alignment only.
