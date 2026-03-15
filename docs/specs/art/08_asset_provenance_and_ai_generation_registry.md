# 08. Asset Provenance And AI Generation Registry

> **Status**: Draft v1.0
> **Last Updated**: 2026-03-15
> **References**:
> - `docs/requirements/08_art_pipeline.md`
> - `docs/requirements/09_sound_design.md`
> - `docs/requirements/12_cicd_and_qa.md`
> - `docs/requirements/13_dev_process.md`
> - `docs/specs/art/01_style_bible.md`
> - `docs/specs/art/02_monster_sprite_production_manual.md`
> - `docs/specs/art/05_ui_sprite_production_manual.md`
> - `docs/specs/art/06_sound_design_production_manual.md`
> - `docs/specs/art/07_character_sprite_production_manual.md`
> - `docs/specs/systems/05_id_naming_validation_and_registry_rules.md`

---

## Purpose

This document is the **canonical provenance, prompt-lineage, and approval contract** for all AI-assisted assets in the repository. It defines what must be recorded, reviewed, reproducible, legally cleared, manually touched, and approved before an asset is allowed into a release candidate.

It does **not** replace the category-specific production manuals. Those documents remain authoritative for style, pixel rules, sound targets, naming, and output format. This document defines the cross-cutting controls that apply to every asset domain:

- monster sprites
- UI / HUD sprites
- character sprites
- sound assets (`bgm`, `se`, `jingle`, `amb`)
- future asset domains such as tilesets, effects, illustrations, marketing art, video, or voice

---

## 1. Scope And Source Of Truth

### 1.1 Authority Boundaries

| Surface | Authority |
|--------|-----------|
| Art direction, palette, silhouette language | `01_style_bible.md` |
| Monster sprite output rules | `02_monster_sprite_production_manual.md` |
| UI / HUD sprite output rules | `05_ui_sprite_production_manual.md` |
| Sound output rules | `06_sound_design_production_manual.md`, `09_sound_design.md` |
| Character sprite output rules | `07_character_sprite_production_manual.md` |
| Registry existence, ID linkage, naming | `05_id_naming_validation_and_registry_rules.md` |
| QA / merge / release gates | `12_cicd_and_qa.md`, `13_dev_process.md` |
| Provenance, legal review, prompt lineage, approval state | **this document** |

### 1.2 Core Rule

No asset may be treated as shippable merely because it “looks done.” It is only shippable when:

1. it conforms to its category production manual
2. its provenance is fully recorded
3. its legal / IP review is recorded as clear
4. its manual-touch and edit chain are traceable
5. its approval state is `approved`

---

## 2. Provenance Principles

1. **Traceability first**: every shipped asset must be traceable to its prompts, tools, inputs, edits, reviews, and final approver.
2. **Canonical write, historical retain**: the current approved export is canonical, but prior revisions must remain traceable and must not be overwritten without a new revision.
3. **Legal safety over convenience**: uncertain rights, unclear provider terms, suspicious resemblance, or missing lineage are release blockers.
4. **Reproducibility by default**: exact rerender is preferred; where a SaaS model is nondeterministic, the repo must still capture best-effort regeneration metadata and raw source artifacts.
5. **Manual edits are first-class**: hand cleanup, paintover, arrangement, palette repair, slicing, and audio mastering must be logged, not hidden behind `edited_by_hand=true`.
6. **Parent-child integrity**: derivatives must reference their source prompts and source assets. No orphaned edit chain is allowed.
7. **Release gating is registry-driven**: if provenance is incomplete, the asset is treated as unapproved regardless of visual quality.

---

## 3. Canonical Registry Surfaces

### 3.1 Required Surfaces

| Surface | Role |
|--------|------|
| `asset_registry.csv` | Compact index of all reviewable and shippable asset revisions |
| provenance sidecar manifest | Full prompt, negative prompt, tool settings, source hashes, review notes, and edit chain for one asset revision |

`05_id_naming_validation_and_registry_rules.md` already reserves `asset_registry.csv`. This document expands that registry into a full provenance system.

### 3.2 Logical Model

| Entity | Meaning |
|-------|---------|
| `asset_id` | Stable logical asset identity across revisions |
| `revision` | One immutable reviewable version of an asset |
| `prompt_id` | Stable prompt family identifier, following the `PRM-*` convention from `05` |
| `prompt_revision` | Specific version of a prompt family |
| `source_asset_revision_ids` | Parent asset revisions used as references, inpainting inputs, paintover bases, stems, or composites |

### 3.3 One Row Per Revision

`asset_registry.csv` stores **one row per asset revision**, not one row per logical asset. This is necessary for:

- release locking
- supersession history
- rollback
- exact review traceability
- differentiating “same asset, new legal status” from “same asset, new pixels or audio”

---

## 4. Asset ID And Revision Rules

### 4.1 `asset_id`

`asset_id` must be human-readable and stable. It must not change when only the revision changes.

Recommended patterns:

| Domain | Pattern | Example |
|-------|---------|---------|
| Monster sprite | `AST-MON-{owner_id}-{usage}` | `AST-MON-MON-001-battle` |
| UI sprite | `AST-UI-{scope}-{component_slug}` | `AST-UI-SYS-win_default` |
| Character sprite | `AST-CHR-{owner_id}-{usage}` | `AST-CHR-NPC-VIL-004-sheet` |
| Sound | `AST-SND-{cue_type}-{cue_slug}` | `AST-SND-BGM-bgm_title_main` |
| Future assets | `AST-{domain_code}-{scope}-{asset_slug}` | `AST-FX-SYS-gate_spark_01` |

### 4.2 `revision`

- `revision` is an integer starting at `1`
- a new export, new manual cleanup, new legal result, or new mastering pass that changes the shipped artifact requires a new revision
- approved revisions are immutable
- reusing the same filename with changed content but no new revision is forbidden

### 4.3 Supersession

Each revision may point to:

- `supersedes_revision_id`
- `lineage_root_revision_id`

This preserves the full edit chain even when filenames remain stable at export time.

---

## 5. Registry Schema

### 5.1 Required Columns In `asset_registry.csv`

| Column | Type | Required | Meaning |
|-------|------|----------|---------|
| `asset_id` | string | yes | Stable logical asset ID |
| `revision` | int | yes | Immutable revision number |
| `asset_domain` | enum | yes | `monster_sprite`, `ui_sprite`, `character_sprite`, `sound`, `tileset`, `effect`, `illustration`, `marketing`, `other` |
| `asset_type` | enum | yes | `sprite`, `sheet`, `icon`, `window`, `bgm`, `se`, `jingle`, `amb`, `tileset`, `effect`, `other` |
| `owner_id` | string | yes | `MON-*`, `NPC-*`, `W-*`, `SYS`, screen ID, or cue scope |
| `usage_context` | string | yes | battle, field, menu, codex, title, battle_normal_01, etc. |
| `source_file` | path | conditional | Authoring source such as `.aseprite`, DAW session, tracker file, prompt pack, or raw generation bundle |
| `export_file` | path | yes | Final exported runtime asset for this revision |
| `prompt_id` | string | conditional | Prompt family ID; mandatory for AI-assisted assets |
| `prompt_revision` | int | conditional | Prompt version used for this revision |
| `generator` | string | conditional | `niji`, `gpt-image`, `nanobanana`, `grok`, `suno`, `udio`, etc. |
| `generator_version` | string | conditional | Provider model version or dated tool snapshot |
| `seed_or_settings` | string | conditional | Seed or normalized settings key |
| `provenance_class` | enum | yes | `ai_native`, `ai_plus_manual`, `manual_from_ai_concept`, `manual_only`, `licensed_external` |
| `source_asset_revision_ids` | string list | no | `|`-delimited parent revisions |
| `manual_touch_level` | enum | yes | `none`, `cleanup`, `paintover`, `reconstruction`, `composite`, `audio_edit`, `audio_master`, `full_redraw` |
| `manual_touch_summary` | string | conditional | Short human summary of what changed |
| `edited_by_hand` | bool | yes | Flat compatibility flag from `05` |
| `license_clearance` | enum | yes | `clear`, `needs_review`, `blocked`, `restricted` |
| `legal_review_state` | enum | yes | `not_started`, `needs_review`, `in_review`, `pass`, `fail`, `waived_for_manual_only` |
| `qa_review_state` | enum | yes | `not_started`, `in_review`, `pass`, `fail` |
| `approval_state` | enum | yes | see Section 9 |
| `approved_by` | string | conditional | Final human approver |
| `approved_at_utc` | datetime | conditional | Approval timestamp |
| `provider_terms_snapshot` | string | conditional | Provider plan / terms version relied upon |
| `export_sha256` | string | yes | Hash of shipped file |
| `manifest_path` | path | yes | Sidecar provenance manifest path |
| `release_channel` | enum | yes | `none`, `prototype`, `vertical_slice`, `internal`, `rc`, `ship` |
| `release_blocked_reason` | string | no | Why the asset cannot ship yet |

### 5.2 CSV Compatibility Rule

If a field is too large for CSV sanity, the CSV row stores the canonical pointer and the sidecar manifest stores the full payload. Long free-text values must live in the sidecar manifest, not in ad hoc spreadsheets or chat logs.

---

## 6. Provenance Sidecar Manifest

Each revision must have a detailed sidecar manifest. The sidecar is the long-form evidence package for the CSV row.

### 6.1 Required Manifest Sections

| Section | Required For | Contents |
|--------|---------------|----------|
| `identity` | all | `asset_id`, `revision`, `asset_domain`, `owner_id`, `export_file` |
| `prompt_lineage` | AI-assisted assets | full positive prompt, negative prompt, prompt notes, prompt parentage |
| `generation_run` | AI-assisted assets | tool, model, version, seed, aspect ratio, duration, sampler/settings, generation date |
| `source_inputs` | derivatives | input files, parent revisions, external references, hashes |
| `manual_edits` | edited assets | editor, tool, summary, changed regions, rationale |
| `legal_review` | all | rights basis, provider terms snapshot, red flags, reviewer decision |
| `qa_review` | all | category-specific pass/fail notes |
| `release_history` | approved assets | release lock, supersession, deprecation notes |

### 6.2 Reproducibility Grade

Every manifest must declare one of:

| Grade | Meaning |
|------|---------|
| `exact` | Same tool/model/settings/seed can reproduce the raw output |
| `close` | Tool is nondeterministic, but prompt/settings/input bundle allow close regeneration |
| `provenance_only` | Exact or close regeneration is not realistic; lineage is still complete |

`provenance_only` is allowed only when the tool genuinely prevents reproducibility. It is not a shortcut for poor record keeping.

---

## 7. Required Metadata By Asset Domain

### 7.1 Monster Sprites

Must additionally record:

- `owner_id = MON-*`
- sprite usage: `battle`, `field`, `menu`, `codex`, `sheet`, `frame`
- canvas size and orientation rules from `02`
- palette normalization pass and palette tool version
- whether the export is a raw generation, palette-remapped output, or hand-corrected final
- silhouette review result and same-family similarity notes

### 7.2 UI / HUD Sprites

Must additionally record:

- target screen or system scope
- component family such as `window`, `cursor`, `icon`, `font`, `marker`
- variant ID such as `win_default`, `win_battle`
- grid or tile assumptions from `05`
- text / symbol safety check for accidental glyph, logo, or watermark leakage

### 7.3 Character Sprites

Must additionally record:

- `owner_id` such as protagonist ID or `NPC-*`
- usage such as `sheet`, `down_f1`, `left_f2`
- whether left-right flip was authored or derived
- likeness review notes for human / humanoid outputs
- world / culture consistency check against story and NPC specs

### 7.4 Sound Assets

Must additionally record:

- cue type: `bgm`, `se`, `jingle`, `amb`
- intended scene or cue ID
- duration, loop status, loop points, loudness target, master format
- generation tool, model version, stems or source bundle path
- mastering chain and manual edit chain
- melody / motif similarity review
- voice / lyric presence flag

For this repo, shipped sound assets are expected to be instrumental unless a future dedicated vocal spec explicitly permits otherwise.

### 7.5 Future Asset Domains

Until a dedicated production manual exists, new asset domains must:

1. use the full registry and sidecar requirements in this document
2. declare a temporary `asset_domain`
3. define domain-specific QA notes in the sidecar
4. remain blocked from `ship` unless their safety and style checks are explicitly documented

---

## 8. Prompt Lineage And Negative Prompt Policy

### 8.1 Prompt Lineage Rules

- `prompt_id` follows the `PRM-*` convention from `05`
- `prompt_revision` increments whenever wording changes in a way that could materially change output
- derived prompts must record `parent_prompt_id` or equivalent in the sidecar
- if one final asset blends multiple prompt explorations, all contributing prompt IDs must be listed in lineage notes

### 8.2 Prompt Capture Requirements

For every AI-assisted revision, the manifest must capture:

- full positive prompt
- full negative prompt, or equivalent banned-influence list if the tool lacks a negative prompt field
- model/provider name
- exact model version or dated snapshot
- seed, sampler, CFG-like settings, aspect ratio, duration, resolution, or other generator-specific controls
- uploaded input references and their hashes
- operator notes explaining why this prompt version was chosen

### 8.3 Negative Prompt Policy

The following are forbidden as positive prompts and must be explicitly blocked in negative prompts or safety constraints where the tool supports it:

- direct franchise names
- named living artists, bands, composers, performers, or voice actors
- “in the style of” requests tied to living creators
- `pokemon-like`, `dragon quest style`, or equivalent imitation requests
- logos, brand marks, signatures, watermarks, UI from other games
- photorealistic rendering for pixel-art deliverables
- smooth shading, gradients, anti-aliasing, or 3D rendering for pixel-art deliverables
- vocals, celebrity likeness, or spoken imitation for sound unless a future approved spec explicitly permits it

### 8.4 Domain-Specific Negative Constraints

| Domain | Mandatory Constraints |
|-------|------------------------|
| Monster sprite | no existing monster IP names, no mascot imitation, no text/logo, no realistic anatomy drift |
| UI sprite | no modern glossy UI, no app-store icon tropes, no hidden text/watermark, no franchise HUD imitation |
| Character sprite | no celebrity likeness, no anime-character copy, no text/logo on clothing unless authored intentionally |
| Sound | no named-composer imitation, no franchise OST references, no vocal mimicry, no uncleared samples |

---

## 9. Legal / IP Safety Review

### 9.1 Mandatory Review Questions

Every revision must answer:

1. Do the provider terms allow the intended commercial use?
2. Are the prompt and source inputs free of direct IP imitation requests?
3. Does the output visually or musically resemble a known work too closely?
4. Does the output contain hidden signatures, watermarks, logos, or unintended text?
5. Are all external inputs owned, licensed, or created in-repo?
6. For human characters or voices, is there likeness or impersonation risk?

### 9.2 Legal Review Outcomes

| State | Meaning |
|------|---------|
| `pass` | Safe to proceed to approval if QA also passes |
| `fail` | Must not ship; regenerate or redraw |
| `needs_review` | Insufficient evidence; release-blocking |
| `waived_for_manual_only` | Allowed only for fully manual assets with no third-party generator input |

### 9.3 Automatic Red Flags

Any of the following makes a revision non-shippable until cleared:

- direct resemblance to a known franchise character, icon, UI, melody, or sound motif
- recognizable logo, watermark, signature, stock watermark, or model artifact text
- unclear provider plan or terms snapshot
- missing prompt lineage for an AI-assisted asset
- missing parent reference for inpainting, img2img, paintover, composite, or audio stem derivation
- unresolved rights on uploaded reference images, audio clips, or sample packs
- attempts to hide imitation through euphemistic prompt wording

---

## 10. Manual-Touch Tracking And Edit-Chain Rules

### 10.1 Manual Touch Is Not Binary

`edited_by_hand` remains for compatibility with `05`, but approval requires the richer fields:

- `manual_touch_level`
- `manual_touch_summary`
- `manual_editor`
- `manual_tool_chain`
- `source_asset_revision_ids`

### 10.2 Edit-Chain Rules

1. A hand cleanup of an AI output is a new revision, not a silent overwrite.
2. A redraw based on an AI concept must still reference the concept revision as a parent.
3. A palette-remapped sprite, frame-sliced sheet, audio master, loop-fixed mix, or stem recombination is a new derivative revision.
4. Composite assets must list every contributing parent revision.
5. If an approved asset is retouched after approval, the old revision becomes historical and the new one must be re-reviewed.

### 10.3 Minimum Manual Edit Detail

The sidecar manifest must state what changed, for example:

- outline cleanup
- palette remap and cluster repair
- silhouette repair
- animation frame redraw
- watermark / artifact removal
- loop-point correction
- noise reduction
- arrangement / mastering pass

“Touched up” is not sufficient detail.

---

## 11. Approval Workflow

### 11.1 Approval States

| State | Meaning |
|------|---------|
| `planned` | Asset exists only as a request or brief |
| `generated` | Raw AI output or first authored pass exists |
| `needs_cleanup` | Promising but not review-ready |
| `legal_review` | Awaiting IP / rights clearance |
| `qa_review` | Awaiting category-specific quality review |
| `approved` | Cleared for integration and release candidates |
| `release_locked` | Approved revision frozen for an RC or shipped build |
| `superseded` | Replaced by a newer approved revision |
| `rejected` | Must not be integrated or shipped |
| `deprecated` | Formerly approved but intentionally retired |

### 11.2 Required Path To `approved`

1. asset brief exists
2. generation or authoring recorded
3. provenance manifest complete
4. manual-touch chain recorded
5. legal review passes
6. QA review passes against the category production manual
7. final approver signs off

Per `13_dev_process.md`, final judgment remains with the project owner unless explicitly delegated.

### 11.3 Rejection Rules

An asset must be marked `rejected` when:

- provenance is materially incomplete and cannot be reconstructed
- IP safety review fails
- the asset violates the category style or pixel / audio constraints
- raw quality is good but the lineage is too risky to ship

Rejected assets may remain as historical experiments, but they may not feed a later approved revision unless the unsafe parts are fully replaced and the new lineage is clear.

---

## 12. Versioning And Regeneration Discipline

### 12.1 What Requires A New Revision

- visible or audible content change
- prompt change that changes final output
- model change
- seed/settings change when regenerating
- manual cleanup that changes final export
- new legal or QA decision on a changed artifact
- new release-locked export

### 12.2 Provider Drift

AI providers change quickly. Therefore:

- `generator_version` must be as precise as the provider allows
- `provider_terms_snapshot` must be recorded at generation time
- if the tool cannot guarantee stable replay, raw generation outputs and sidecar metadata become mandatory

### 12.3 Regeneration Priority

When an approved asset needs variation or repair, prefer:

1. regenerate from the same prompt family and tool settings if safe
2. manually repair the approved revision with a new revision record
3. rebrief and create a new lineage root if the old lineage is legally or aesthetically compromised

---

## 13. Release Gating

### 13.1 Merge / Release Preconditions

An asset is release-blocking if any of the following is false:

- registry row exists
- manifest exists
- `export_sha256` matches the committed export
- `license_clearance = clear`
- `legal_review_state = pass` or `waived_for_manual_only`
- `qa_review_state = pass`
- `approval_state = approved` or `release_locked`
- source file and parent lineage are resolvable

### 13.2 Hard Fail Conditions

The asset validation layer should hard fail on:

- missing registry entry for a referenced shipped asset
- duplicate `asset_id + revision`
- missing `prompt_id` for AI-assisted assets
- missing manifest path
- missing hash
- `approved` asset with `license_clearance != clear`
- release candidate containing `generated`, `needs_cleanup`, `legal_review`, or `qa_review` assets

### 13.3 RC Lock Rule

Once a revision is used in a release candidate, it should move to `release_locked`. Any further edit requires a new revision and a repeat of the review flow.

---

## 14. Review Checklist

- Is the asset linked to the correct production manual and owner ID?
- Is the prompt lineage complete and specific?
- Does the negative prompt or safety constraint block imitation and watermark risk?
- Are source inputs, seeds, settings, and tool versions recorded?
- Is the manual-touch chain specific enough to reproduce the final result?
- Does the asset pass style and technical QA for its domain?
- Is there any resemblance, logo, signature, lyric, sample, or motif risk?
- Is the asset approved by the final human reviewer?

---

## 15. Minimal Implementation Guidance

When `asset_registry.csv` is materialized in the repo, its implementation must be consistent with this document and with `05_id_naming_validation_and_registry_rules.md`. Until tooling exists, this document is the canonical schema and workflow contract.

If future tooling introduces stricter machine-readable fields, it may extend this schema but must not weaken:

- provenance completeness
- legal / IP review traceability
- edit-chain integrity
- release gating
