from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import shutil
import sys
import tempfile
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CSV_DIR = REPO_ROOT / "data" / "csv"
DEFAULT_OUTPUT_DIR = REPO_ROOT / "resources"
MANIFEST_PATH = REPO_ROOT / "data" / "generated" / "resource_manifest.json"
MANAGED_RESOURCE_DIRS = (
    "monsters",
    "skills",
    "items",
    "worlds",
    "encounters",
    "breeding",
    "npcs",
    "shops",
    "services",
    "loot_tables",
)

FAMILIES = {"slime", "beast", "bird", "plant", "material", "magic", "undead", "dragon", "divine"}
RANKS = {"E", "D", "C", "B", "A", "S"}
ARENA_RANKS = {"G", "F", "E", "D", "C", "B", "A", "S"}
SIZE_CLASSES = {"S", "M", "L"}
GROWTH_CURVES = {"EARLY", "STANDARD", "LATE", "LEGEND"}
TIME_BANDS = {"any", "day", "dusk", "night"}
WEATHER_TYPES = {"any", "clear", "rain", "fog", "snow"}
RULE_TYPES = {"family", "special", "mutation"}
GATE_TYPES = {"story_flag", "arena_rank", "key_item", "clue_count", "family_resonance", "composite"}
SCOPE_KINDS = {"village", "settlement", "tower", "world", "milestone", "story_stage"}
CLUE_TIERS = {"T1", "T2", "T3", "T4", "T5"}
CLUE_MEDIA = {"NPC", "建築", "オブジェクト", "門反応", "戦闘", "図鑑", "アイテム", "台帳", "世界イベント", "モンスター"}
STORY_STAGE_IDS = {"ACT4-CLIMAX", "FINALE", "ENDING", "ACT4_END", "STORY_END"}
LOCALIZATION_LOCALES = {"ja", "en"}
MOTIF_GROUPS = {"animal", "plant", "tool", "ritual", "weather", "myth", "corporeal", "abstract"}
SECONDARY_MOTIF_GROUPS = {"household", "pastoral", "funerary", "bureaucratic", "astral", "gatebound"}
ONTOLOGY_CLASSES = {"wildborn", "gate_touched", "bred_line", "record_bent", "remnant_bearing"}
SILHOUETTE_TYPES = {"round", "wide", "tall", "serpentine", "floating", "tripod", "massive"}
BATTLE_ROLES = {"striker", "tank", "healer", "controller", "bait_specialist", "mutation_key"}
ASSET_DOMAINS = {
    "monster_sprite",
    "ui_sprite",
    "character_sprite",
    "sound",
    "tileset",
    "effect",
    "illustration",
    "marketing",
    "other",
}
ASSET_TYPES = {"sprite", "sheet", "icon", "window", "bgm", "se", "jingle", "amb", "tileset", "effect", "other"}
PROVENANCE_CLASSES = {
    "ai_native",
    "ai_plus_manual",
    "manual_from_ai_concept",
    "manual_only",
    "licensed_external",
}
MANUAL_TOUCH_LEVELS = {
    "none",
    "cleanup",
    "paintover",
    "reconstruction",
    "composite",
    "audio_edit",
    "audio_master",
    "full_redraw",
}
LICENSE_CLEARANCES = {"clear", "needs_review", "blocked", "restricted"}
LEGAL_REVIEW_STATES = {"not_started", "needs_review", "in_review", "pass", "fail", "waived_for_manual_only"}
QA_REVIEW_STATES = {"not_started", "in_review", "pass", "fail"}
APPROVAL_STATES = {
    "planned",
    "generated",
    "needs_cleanup",
    "legal_review",
    "qa_review",
    "approved",
    "release_locked",
    "superseded",
    "rejected",
    "deprecated",
}
RELEASE_CHANNELS = {"none", "prototype", "vertical_slice", "internal", "rc", "ship"}
SHOP_TYPES = {"general", "field_vendor", "tournament_vendor", "record_vendor", "specialist"}
SHOP_RESTOCK_CLOCKS = {"none", "return_to_hub", "daily", "story_progress"}
CURRENCY_TYPES = {"gold"}
ROW_STATUSES = {"active", "deprecated", "disabled", "planned"}
STOCK_MODES = {"infinite_common", "daily_limited", "one_time_unlock", "tournament_vendor"}
SERVICE_CATEGORIES = {
    "inn_rest",
    "party_restore",
    "storage",
    "record_decode",
    "recipe_reveal",
    "tournament_entry",
    "fusion_assist",
    "clue_exchange",
}
PRICING_BASES = {"flat", "per_party", "per_level_band", "per_attempt", "per_record_page"}
LOOT_SOURCE_TYPES = {"enemy", "boss", "chest", "gather", "first_clear", "event"}
ROLL_POLICIES = {"single_pick", "weighted_multi", "guaranteed_plus_weighted", "first_clear_once"}
GRANT_TYPES = {"item", "reward_bundle"}
DROP_SLOT_TYPES = {"common", "uncommon", "rare", "relic", "guaranteed", "first_clear"}
ALIAS_ENTITY_TYPES = {"item", "shop", "loot", "service", "reward"}
ALIAS_KINDS = {"registry", "legacy_runtime", "legacy_doc", "temp_migration"}
FIELD_POINT_KINDS = {"inspect", "npc", "facility"}
FIELD_TRIGGER_KINDS = {"message", "encounter"}
FIELD_SUBJECT_KINDS = {"point", "rect"}
FIELD_FACILITY_KINDS = {"merchant", "healer"}
FIELD_FACING_NAMES = {"up", "down", "left", "right"}
FIELD_INTERACTION_CONTEXTS = {
    "always",
    "encounter_triggered",
    "battle_resolved",
    "first_gate_listening",
    "first_crossing_open",
}
ITEM_TEXT_KINDS = {"menu_strip", "shop_voice"}

FLAG_PATTERNS = (
    re.compile(r"^EVT_[A-Z0-9_]+$"),
    re.compile(r"^FLAG_[A-Z0-9_]+$"),
    re.compile(r"^main\.[a-z_]+(?:>=\d+)?$"),
    re.compile(r"^world\.W-\d{3}\.[a-z_]+(?:>=\d+)?$"),
)
ITEM_ID_PATTERN = re.compile(r"^item_[a-z0-9_]+$")
SHOP_ID_PATTERN = re.compile(r"^shop_[a-z0-9_]+$")
SERVICE_ID_PATTERN = re.compile(r"^service_[a-z0-9_]+$")
LOOT_TABLE_ID_PATTERN = re.compile(r"^loot_[a-z0-9_]+$")
GATE_ID_PATTERN = re.compile(r"^GATE-(?:W-)?\d{3}$")
SLUG_PATTERN = re.compile(r"^[a-z][a-z0-9_]*$")
RESERVED_GATE_ITEM_IDS = {
    "item_key_offering_bundle",
    "item_key_evidence_bundle",
    "item_key_record_seal",
    "item_key_blackcloth",
    "item_key_forge_proof",
}


class ValidationError(RuntimeError):
    pass


def read_csv_rows(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        raise ValidationError(f"missing required csv: {path}")
    with path.open("r", encoding="utf-8", newline="") as handle:
        rows = list(csv.DictReader(handle))
    for line_number, row in enumerate(rows, start=2):
        if None in row or any(value is None for value in row.values()):
            raise ValidationError(f"{path.name}:{line_number}: malformed csv row")
    return rows


def normalize_master_index_rows(rows: list[dict[str, str]]) -> list[dict[str, str]]:
    normalized_rows: list[dict[str, str]] = []
    for row in rows:
        normalized = dict(row)
        normalized["file_path"] = row.get("file_path", "").strip() or row.get("file_name", "").strip()
        normalized["primary_key_column"] = (
            row.get("primary_key_column", "").strip() or row.get("primary_key", "").strip()
        )
        normalized_rows.append(normalized)
    return normalized_rows


def normalize_gate_rows(rows: list[dict[str, str]]) -> list[dict[str, str]]:
    normalized_rows: list[dict[str, str]] = []
    for row in rows:
        normalized = dict(row)
        gate_id = row.get("gate_id", "").strip()
        gate_index = row.get("gate_index", "").strip()
        if not gate_index:
            match = re.search(r"(\d{3})$", gate_id)
            gate_index = match.group(1) if match else ""
        normalized["gate_index"] = gate_index
        normalized["gate_type"] = row.get("gate_type", "").strip() or row.get("condition_type", "").strip()
        normalized["required_item"] = row.get("required_item", "").strip() or row.get("required_item_id", "").strip()
        normalized["visible_surface"] = row.get("visible_surface", "").strip() or "legacy_gate_surface"
        normalized_rows.append(normalized)
    return normalized_rows


def normalize_dependency_rows(rows: list[dict[str, str]]) -> list[dict[str, str]]:
    normalized_rows: list[dict[str, str]] = []
    for row in rows:
        normalized = dict(row)
        normalized["entry_gate_id"] = row.get("entry_gate_id", "").strip() or row.get("gate_id", "").strip()
        normalized["prerequisite_scope_id"] = (
            row.get("prerequisite_scope_id", "").strip() or row.get("parent_scope_id", "").strip()
        )
        normalized_rows.append(normalized)
    return normalized_rows


def ensure_unique(rows: list[dict[str, str]], key: str, label: str) -> None:
    seen: set[str] = set()
    for row in rows:
        value = row[key].strip()
        if not value:
            raise ValidationError(f"{label}: empty {key}")
        if value in seen:
            raise ValidationError(f"{label}: duplicate {key}: {value}")
        seen.add(value)


def ensure_unique_pairs(rows: list[dict[str, str]], keys: tuple[str, str], label: str) -> None:
    seen: set[tuple[str, str]] = set()
    for row in rows:
        pair = tuple(row[key].strip() for key in keys)
        if any(not value for value in pair):
            raise ValidationError(f"{label}: empty {'/'.join(keys)}")
        if pair in seen:
            raise ValidationError(f"{label}: duplicate {'/'.join(keys)}: {pair[0]} / {pair[1]}")
        seen.add(pair)


def ensure_unique_optional(rows: list[dict[str, str]], key: str, label: str) -> None:
    seen: set[str] = set()
    for row in rows:
        value = row.get(key, "").strip()
        if not value:
            continue
        if value in seen:
            raise ValidationError(f"{label}: duplicate {key}: {value}")
        seen.add(value)


def parse_bool(value: str) -> bool:
    normalized = value.strip().lower()
    if normalized in {"true", "1", "yes"}:
        return True
    if normalized in {"false", "0", "no"}:
        return False
    raise ValidationError(f"invalid bool: {value}")


def parse_int(value: str) -> int:
    try:
        return int(value.strip())
    except ValueError as error:
        raise ValidationError(f"invalid int: {value}") from error


def parse_float(value: str) -> float:
    try:
        return float(value.strip())
    except ValueError as error:
        raise ValidationError(f"invalid float: {value}") from error


def split_pipe(value: str) -> list[str]:
    return [chunk.strip() for chunk in value.split("|") if chunk.strip()]


def split_csv_list(value: str) -> list[str]:
    return [chunk.strip() for chunk in value.split(",") if chunk.strip()]


def godot_value(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False)


def write_resource(path: Path, script_path: str, script_class: str, payload: dict[str, Any]) -> None:
    lines = [
        f'[gd_resource type="Resource" script_class="{script_class}" load_steps=2 format=3]',
        "",
        f'[ext_resource type="Script" path="{script_path}" id="1"]',
        "",
        "[resource]",
        'script = ExtResource("1")',
    ]

    for key, value in payload.items():
        lines.append(f"{key} = {godot_value(value)}")

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def validate_enum(value: str, allowed: set[str], label: str) -> str:
    normalized = value.strip()
    if normalized not in allowed:
        raise ValidationError(f"{label}: invalid value '{value}', allowed={sorted(allowed)}")
    return normalized


def validate_reference(value: str, allowed: set[str], label: str) -> str:
    normalized = value.strip()
    if normalized not in allowed:
        raise ValidationError(f"{label}: unknown reference '{value}'")
    return normalized


def validate_slug(value: str, label: str) -> str:
    normalized = value.strip()
    if not normalized:
        raise ValidationError(f"{label}: slug is required")
    if not SLUG_PATTERN.fullmatch(normalized):
        raise ValidationError(f"{label}: invalid slug '{value}'")
    return normalized


def validate_optional_enum(
    row: dict[str, str],
    key: str,
    allowed: set[str],
    label: str,
    default: str,
) -> str:
    normalized = row.get(key, "").strip()
    if not normalized:
        return default
    return validate_enum(normalized, allowed, label)


def parse_optional_bool(value: str | None, default: bool) -> bool:
    if value is None or not value.strip():
        return default
    return parse_bool(value)


def parse_optional_int(value: str) -> int:
    normalized = value.strip()
    if not normalized:
        return 0
    return parse_int(normalized)


def parse_optional_positive_int(value: str) -> int | None:
    normalized = value.strip()
    if not normalized:
        return None
    parsed = parse_int(normalized)
    if parsed <= 0:
        raise ValidationError(f"invalid positive int: {value}")
    return parsed


def parse_optional_float(value: str) -> float | None:
    normalized = value.strip()
    if not normalized:
        return None
    return parse_float(normalized)


def normalize_parent_key(value: str, monster_ids: set[str], label: str) -> str:
    normalized = value.strip()
    if not normalized:
        raise ValidationError(f"{label}: empty parent key")
    if normalized in monster_ids:
        return normalized
    if normalized.startswith("family:"):
        family = normalized.split(":", 1)[1].strip()
        validate_enum(family, FAMILIES, label)
        return f"family:{family}"
    if normalized in FAMILIES:
        return f"family:{normalized}"
    raise ValidationError(f"{label}: unknown parent key '{value}'")


def infer_uniform_enum(
    entries: list[dict[str, Any]],
    key: str,
    allowed: set[str],
    default: str,
    label: str,
) -> str:
    values = {str(entry[key]).strip() for entry in entries if str(entry[key]).strip()}
    if not values:
        return default
    if len(values) == 1:
        return validate_enum(values.pop(), allowed, label)
    return default


def resolve_project_root(csv_dir: Path) -> Path:
    return csv_dir.parent.parent


def resolve_project_path(project_root: Path, value: str, label: str) -> Path:
    normalized = value.strip()
    if not normalized:
        raise ValidationError(f"{label}: empty path")
    path = project_root / normalized
    if not path.exists():
        raise ValidationError(f"{label}: missing path '{normalized}'")
    return path


def read_header(path: Path) -> list[str]:
    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.reader(handle)
        try:
            return next(reader)
        except StopIteration as error:
            raise ValidationError(f"{path.name}: empty csv") from error


def validate_flag_expression(value: str, label: str) -> str:
    normalized = value.strip()
    if not normalized:
        raise ValidationError(f"{label}: empty flag")
    if any(pattern.fullmatch(normalized) for pattern in FLAG_PATTERNS):
        return normalized
    raise ValidationError(f"{label}: invalid flag expression '{value}'")


def validate_family_resonance(value: str, label: str) -> str:
    normalized = value.strip()
    if not normalized:
        raise ValidationError(f"{label}: empty family resonance")
    family, separator, level = normalized.partition(":")
    if not separator or not level.strip():
        raise ValidationError(f"{label}: expected '<family>:<min_level>'")
    validate_enum(family.strip(), FAMILIES, label)
    if parse_int(level) <= 0:
        raise ValidationError(f"{label}: min level must be positive")
    return f"{family.strip()}:{level.strip()}"


def validate_item_reference(value: str, item_ids: set[str], label: str) -> str:
    normalized = value.strip()
    if not normalized:
        raise ValidationError(f"{label}: empty item reference")
    if normalized in item_ids:
        return normalized
    if normalized in RESERVED_GATE_ITEM_IDS:
        return normalized
    raise ValidationError(f"{label}: invalid item reference '{value}'")


def build_alias_maps(
    alias_rows: list[dict[str, str]],
    canonical_ids_by_type: dict[str, set[str]],
    project_root: Path,
) -> dict[str, dict[str, str]]:
    active_maps: dict[str, dict[str, str]] = {entity_type: {} for entity_type in ALIAS_ENTITY_TYPES}
    canonical_index = {canonical_id for ids in canonical_ids_by_type.values() for canonical_id in ids}
    seen_aliases: set[str] = set()
    for row in alias_rows:
        alias_value = row["alias_value"].strip()
        alias_label = alias_value or "entity_alias_master.alias_value"
        entity_type = validate_enum(row["entity_type"], ALIAS_ENTITY_TYPES, f"{alias_label}.entity_type")
        canonical_id = row["canonical_id"].strip()
        validate_enum(row["alias_kind"], ALIAS_KINDS, f"{alias_label}.alias_kind")
        if not alias_value:
            raise ValidationError("entity_alias_master: empty alias_value")
        if not canonical_id:
            raise ValidationError(f"{alias_label}: canonical_id is required")
        if canonical_id not in canonical_ids_by_type.get(entity_type, set()):
            raise ValidationError(f"{alias_label}: unknown canonical_id '{canonical_id}' for {entity_type}")
        if alias_value in seen_aliases:
            raise ValidationError(f"entity_alias_master: duplicate alias_value '{alias_value}'")
        if alias_value in canonical_index:
            raise ValidationError(f"{alias_label}: alias collides with canonical id '{alias_value}'")
        source_doc = row["source_doc"].strip()
        if source_doc:
            resolve_project_path(project_root, source_doc, f"{alias_label}.source_doc")
        seen_aliases.add(alias_value)
        if parse_bool(row["active"]):
            active_maps[entity_type][alias_value] = canonical_id
    return active_maps


def resolve_canonical_reference(
    value: str,
    canonical_ids: set[str],
    alias_map: dict[str, str],
    label: str,
) -> str:
    normalized = value.strip()
    if not normalized:
        return ""
    if normalized in canonical_ids:
        return normalized
    if normalized in alias_map:
        return alias_map[normalized]
    raise ValidationError(f"{label}: unknown reference '{value}'")


def resolve_alias_or_canonical(
    value: str,
    canonical_ids: set[str],
    alias_map: dict[str, str],
    label: str,
) -> str:
    normalized = value.strip()
    if not normalized:
        raise ValidationError(f"{label}: empty reference")
    if normalized in canonical_ids:
        return normalized
    if normalized in alias_map:
        return alias_map[normalized]
    raise ValidationError(f"{label}: unknown reference '{value}'")


def load_localization_keys(path: Path) -> set[str]:
    rows = read_csv_rows(path)
    ensure_unique(rows, "key", path.name)
    keys: set[str] = set()
    for row in rows:
        key = row["key"].strip()
        text = row["text"].strip()
        if not key:
            raise ValidationError(f"{path.name}: empty key")
        if not text:
            raise ValidationError(f"{path.name}: empty text for {key}")
        keys.add(key)
    return keys


def validate_field_condition(value: str, label: str) -> str:
    normalized = value.strip()
    if not normalized:
        return "always"
    if normalized in FIELD_INTERACTION_CONTEXTS:
        return normalized
    if normalized.startswith("flag:") and normalized.split(":", 1)[1].strip():
        return normalized
    raise ValidationError(f"{label}: invalid condition '{value}'")


def validate_field_rows(
    field_scene_rows: list[dict[str, str]],
    field_rect_rows: list[dict[str, str]],
    field_point_rows: list[dict[str, str]],
    field_trigger_rows: list[dict[str, str]],
    field_interaction_rows: list[dict[str, str]],
    world_ids: set[str],
    zone_ids: set[str],
    npc_ids: set[str],
    clue_ids: set[str],
) -> None:
    ensure_unique(field_scene_rows, "field_id", "field_scene_master")
    ensure_unique(field_rect_rows, "field_rect_id", "field_rect_master")
    ensure_unique(field_point_rows, "field_point_id", "field_point_master")
    ensure_unique(field_trigger_rows, "field_trigger_id", "field_trigger_master")
    ensure_unique(field_interaction_rows, "field_interaction_id", "field_interaction_master")
    ensure_unique_pairs(field_rect_rows, ("field_id", "rect_id"), "field_rect_master")
    ensure_unique_pairs(field_point_rows, ("field_id", "point_id"), "field_point_master")
    ensure_unique_pairs(field_trigger_rows, ("field_id", "trigger_id"), "field_trigger_master")

    field_ids = {row["field_id"].strip() for row in field_scene_rows}
    rect_ids_by_field: dict[str, set[str]] = {field_id: set() for field_id in field_ids}
    point_ids_by_field: dict[str, set[str]] = {field_id: set() for field_id in field_ids}
    local_flag_keys_by_field: dict[str, set[str]] = {field_id: set() for field_id in field_ids}
    field_bounds: dict[str, tuple[int, int]] = {}

    for row in field_scene_rows:
        field_id = row["field_id"].strip()
        world_id = row.get("world_id", "").strip()
        if world_id:
            validate_reference(world_id, world_ids, f"field_scene_master.{field_id}.world_id")
        width = parse_int(row["map_width"])
        height = parse_int(row["map_height"])
        tile_size = parse_int(row["tile_size"])
        if width <= 0 or height <= 0 or tile_size <= 0:
            raise ValidationError(f"field_scene_master.{field_id}: map size and tile_size must be positive")
        parse_int(row["start_x"])
        parse_int(row["start_y"])
        parse_int(row["tower_center_x"])
        parse_int(row["tower_center_y"])
        field_bounds[field_id] = (width, height)
        encounter_zone_id = row.get("encounter_zone_id", "").strip()
        if encounter_zone_id:
            validate_reference(encounter_zone_id, zone_ids, f"field_scene_master.{field_id}.encounter_zone_id")
        first_gate_clue_id = row.get("first_gate_clue_id", "").strip()
        if first_gate_clue_id:
            validate_reference(first_gate_clue_id, clue_ids, f"field_scene_master.{field_id}.first_gate_clue_id")

    for row in field_rect_rows:
        field_id = row["field_id"].strip()
        if field_id not in field_ids:
            raise ValidationError(f"field_rect_master.{row['field_rect_id']}: unknown field_id '{field_id}'")
        rect_ids_by_field[field_id].add(row["rect_id"].strip())
        x = parse_int(row["x"])
        y = parse_int(row["y"])
        width = parse_int(row["width"])
        height = parse_int(row["height"])
        parse_int(row["draw_layer"])
        parse_bool(row["blocked"])
        if width <= 0 or height <= 0:
            raise ValidationError(f"field_rect_master.{row['field_rect_id']}: width/height must be positive")
        max_width, max_height = field_bounds[field_id]
        if x < 0 or y < 0 or x + width > max_width or y + height > max_height:
            raise ValidationError(f"field_rect_master.{row['field_rect_id']}: rect exceeds map bounds")

    for row in field_point_rows:
        field_id = row["field_id"].strip()
        if field_id not in field_ids:
            raise ValidationError(f"field_point_master.{row['field_point_id']}: unknown field_id '{field_id}'")
        point_ids_by_field[field_id].add(row["point_id"].strip())
        validate_enum(row["point_kind"], FIELD_POINT_KINDS, f"field_point_master.{row['point_id']}.point_kind")
        x = parse_int(row["x"])
        y = parse_int(row["y"])
        max_width, max_height = field_bounds[field_id]
        if x < 0 or y < 0 or x >= max_width or y >= max_height:
            raise ValidationError(f"field_point_master.{row['field_point_id']}: point exceeds map bounds")

    for row in field_trigger_rows:
        trigger_id = row["field_trigger_id"].strip()
        field_id = row["field_id"].strip()
        if field_id not in field_ids:
            raise ValidationError(f"field_trigger_master.{trigger_id}: unknown field_id '{field_id}'")
        rect_id = row["rect_id"].strip()
        if rect_id not in rect_ids_by_field[field_id]:
            raise ValidationError(f"field_trigger_master.{trigger_id}: unknown rect_id '{rect_id}'")
        validate_enum(row["trigger_kind"], FIELD_TRIGGER_KINDS, f"field_trigger_master.{trigger_id}.trigger_kind")
        once_flag_key = row.get("once_flag_key", "").strip()
        required_flag_key = row.get("required_flag_key", "").strip()
        if once_flag_key:
            local_flag_keys_by_field[field_id].add(once_flag_key)
        if required_flag_key:
            local_flag_keys_by_field[field_id].add(required_flag_key)
        if row["trigger_kind"].strip() == "encounter":
            validate_reference(row["encounter_zone_id"], zone_ids, f"field_trigger_master.{trigger_id}.encounter_zone_id")

    for row in field_interaction_rows:
        interaction_id = row["field_interaction_id"].strip()
        field_id = row["field_id"].strip()
        if field_id not in field_ids:
            raise ValidationError(f"field_interaction_master.{interaction_id}: unknown field_id '{field_id}'")
        subject_kind = validate_enum(
            row["subject_kind"], FIELD_SUBJECT_KINDS, f"field_interaction_master.{interaction_id}.subject_kind"
        )
        subject_id = row["subject_id"].strip()
        if subject_kind == "point" and subject_id not in point_ids_by_field[field_id]:
            raise ValidationError(f"field_interaction_master.{interaction_id}: unknown point '{subject_id}'")
        if subject_kind == "rect" and subject_id not in rect_ids_by_field[field_id]:
            raise ValidationError(f"field_interaction_master.{interaction_id}: unknown rect '{subject_id}'")
        parse_int(row["priority"])
        validate_field_condition(row.get("condition_key", ""), f"field_interaction_master.{interaction_id}.condition_key")
        for clue_id in split_pipe(row.get("clue_ids", "").strip()):
            validate_reference(clue_id, clue_ids, f"field_interaction_master.{interaction_id}.clue_ids")
        set_flag_key = row.get("set_flag_key", "").strip()
        if set_flag_key:
            local_flag_keys_by_field[field_id].add(set_flag_key)
        facility_npc_id = row.get("facility_npc_id", "").strip()
        facility_kind = row.get("facility_kind", "").strip()
        transition_field_id = row.get("transition_field_id", "").strip()
        transition_point_id = row.get("transition_point_id", "").strip()
        transition_facing = row.get("transition_facing", "").strip()
        if facility_npc_id and facility_npc_id not in npc_ids:
            raise ValidationError(f"field_interaction_master.{interaction_id}: unknown facility npc '{facility_npc_id}'")
        if facility_kind and not facility_npc_id:
            raise ValidationError(f"field_interaction_master.{interaction_id}: facility_kind requires facility_npc_id")
        if facility_kind:
            validate_enum(facility_kind, FIELD_FACILITY_KINDS, f"field_interaction_master.{interaction_id}.facility_kind")
            point_row = next(
                (
                    point_row
                    for point_row in field_point_rows
                    if point_row["field_id"].strip() == field_id and point_row["point_id"].strip() == subject_id
                ),
                None,
            )
            if subject_kind != "point" or point_row is None or point_row["point_kind"].strip() != "facility":
                raise ValidationError(f"field_interaction_master.{interaction_id}: facility payload requires facility point")
        transition_message = row.get("transition_message_jp", "").strip()
        if transition_field_id:
            validate_reference(
                transition_field_id,
                field_ids,
                f"field_interaction_master.{interaction_id}.transition_field_id",
            )
            if transition_point_id and transition_point_id not in point_ids_by_field[transition_field_id]:
                raise ValidationError(
                    f"field_interaction_master.{interaction_id}: unknown target point '{transition_point_id}'"
                )
            if transition_facing:
                validate_enum(
                    transition_facing,
                    FIELD_FACING_NAMES,
                    f"field_interaction_master.{interaction_id}.transition_facing",
                )
        elif transition_point_id or transition_facing or transition_message:
            raise ValidationError(
                f"field_interaction_master.{interaction_id}: transition payload requires transition_field_id"
            )
        if facility_kind and transition_field_id:
            raise ValidationError(
                f"field_interaction_master.{interaction_id}: facility and transition payloads are mutually exclusive"
            )
        if not facility_kind and not row.get("message_jp", "").strip() and not transition_field_id:
            raise ValidationError(f"field_interaction_master.{interaction_id}: empty interaction payload")


def validate_item_text_rows(
    item_text_rows: list[dict[str, str]],
    item_ids: set[str],
    scope_ids: set[str],
    shop_rows: list[dict[str, str]],
) -> None:
    ensure_unique(item_text_rows, "item_text_id", "item_text_master")

    shop_scope_by_id = {row["shop_id"].strip(): row["scope_id"].strip() for row in shop_rows}
    seen_keys: set[tuple[str, str, str, str]] = set()

    for row in item_text_rows:
        item_text_id = row["item_text_id"].strip()
        item_id = validate_reference(row["item_id"], item_ids, f"item_text_master.{item_text_id}.item_id")
        text_kind = validate_enum(row["text_kind"], ITEM_TEXT_KINDS, f"item_text_master.{item_text_id}.text_kind")
        scope_id = row.get("scope_id", "").strip()
        shop_id = row.get("shop_id", "").strip()
        text_source = row.get("text_source", "").strip()
        text_jp = row.get("text_jp", "").strip()
        priority = parse_int(row.get("priority", "0"))

        if priority < 0:
            raise ValidationError(f"item_text_master.{item_text_id}: priority must be >= 0")
        if not text_source:
            raise ValidationError(f"item_text_master.{item_text_id}: text_source is required")
        if not text_jp:
            raise ValidationError(f"item_text_master.{item_text_id}: text_jp is required")
        if scope_id:
            validate_reference(scope_id, scope_ids, f"item_text_master.{item_text_id}.scope_id")
        if shop_id:
            validate_reference(shop_id, set(shop_scope_by_id.keys()), f"item_text_master.{item_text_id}.shop_id")
            shop_scope_id = shop_scope_by_id[shop_id]
            if scope_id and scope_id != shop_scope_id:
                raise ValidationError(
                    f"item_text_master.{item_text_id}: scope_id '{scope_id}' does not match shop scope '{shop_scope_id}'"
                )
        if text_kind == "shop_voice" and not scope_id and not shop_id:
            raise ValidationError(f"item_text_master.{item_text_id}: shop_voice requires scope_id or shop_id")
        if text_kind == "menu_strip" and shop_id:
            raise ValidationError(f"item_text_master.{item_text_id}: menu_strip cannot bind directly to shop_id")
        lookup_key = (item_id, text_kind, scope_id, shop_id)
        if lookup_key in seen_keys:
            raise ValidationError(
                "item_text_master: duplicate item_id/text_kind/scope_id/shop_id: "
                f"{item_id} / {text_kind} / {scope_id or '-'} / {shop_id or '-'}"
            )
        seen_keys.add(lookup_key)


def compute_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def build_all(csv_dir: Path, output_dir: Path) -> dict[str, Any]:
    project_root = resolve_project_root(csv_dir)

    monster_rows = read_csv_rows(csv_dir / "monster_master.csv")
    resistance_rows = read_csv_rows(csv_dir / "monster_resistance.csv")
    learnset_rows = read_csv_rows(csv_dir / "monster_learnset.csv")
    skill_rows = read_csv_rows(csv_dir / "skill_master.csv")
    item_rows = read_csv_rows(csv_dir / "item_master.csv")
    npc_rows = read_csv_rows(csv_dir / "npc_master.csv")
    world_rows = read_csv_rows(csv_dir / "world_master.csv")
    zone_rows = read_csv_rows(csv_dir / "zone_master.csv")
    encounter_rows = read_csv_rows(csv_dir / "encounter_table.csv")
    breed_rows = read_csv_rows(csv_dir / "breed_rule.csv")
    master_index_rows = normalize_master_index_rows(read_csv_rows(csv_dir / "master_index.csv"))
    clue_rows = read_csv_rows(csv_dir / "clue_master.csv")
    gate_rows = normalize_gate_rows(read_csv_rows(csv_dir / "progress_gate_master.csv"))
    dependency_rows = normalize_dependency_rows(read_csv_rows(csv_dir / "world_dependency_map.csv"))
    localization_rows = read_csv_rows(csv_dir / "localization_registry.csv")
    asset_rows = read_csv_rows(csv_dir / "asset_registry.csv")
    shop_rows = read_csv_rows(csv_dir / "shop_master.csv")
    shop_inventory_rows = read_csv_rows(csv_dir / "shop_inventory_master.csv")
    service_rows = read_csv_rows(csv_dir / "service_master.csv")
    shop_service_rows = read_csv_rows(csv_dir / "shop_service_master.csv")
    loot_table_rows = read_csv_rows(csv_dir / "loot_table_master.csv")
    loot_entry_rows = read_csv_rows(csv_dir / "loot_entry_master.csv")
    alias_rows = read_csv_rows(csv_dir / "entity_alias_master.csv")
    field_scene_rows = read_csv_rows(csv_dir / "field_scene_master.csv")
    field_rect_rows = read_csv_rows(csv_dir / "field_rect_master.csv")
    field_point_rows = read_csv_rows(csv_dir / "field_point_master.csv")
    field_trigger_rows = read_csv_rows(csv_dir / "field_trigger_master.csv")
    field_interaction_rows = read_csv_rows(csv_dir / "field_interaction_master.csv")
    item_text_rows = read_csv_rows(csv_dir / "item_text_master.csv")

    ensure_unique(monster_rows, "monster_id", "monster_master")
    ensure_unique(resistance_rows, "monster_id", "monster_resistance")
    ensure_unique(skill_rows, "skill_id", "skill_master")
    ensure_unique(item_rows, "item_id", "item_master")
    ensure_unique(npc_rows, "npc_id", "npc_master")
    ensure_unique(world_rows, "world_id", "world_master")
    ensure_unique(zone_rows, "zone_id", "zone_master")
    ensure_unique(breed_rows, "rule_id", "breed_rule")
    ensure_unique(master_index_rows, "master_id", "master_index")
    ensure_unique(master_index_rows, "file_name", "master_index")
    ensure_unique(clue_rows, "clue_id", "clue_master")
    ensure_unique(gate_rows, "gate_id", "progress_gate_master")
    ensure_unique(gate_rows, "world_id", "progress_gate_master")
    ensure_unique(dependency_rows, "scope_id", "world_dependency_map")
    ensure_unique(localization_rows, "entry_id", "localization_registry")
    ensure_unique(asset_rows, "asset_id", "asset_registry")
    ensure_unique(shop_rows, "shop_id", "shop_master")
    ensure_unique(service_rows, "service_id", "service_master")
    ensure_unique(loot_table_rows, "loot_table_id", "loot_table_master")
    ensure_unique_pairs(shop_inventory_rows, ("shop_id", "slot_no"), "shop_inventory_master")
    ensure_unique_pairs(shop_service_rows, ("shop_id", "service_id"), "shop_service_master")
    ensure_unique_pairs(loot_entry_rows, ("loot_table_id", "entry_no"), "loot_entry_master")
    ensure_unique(alias_rows, "alias_value", "entity_alias_master")
    ensure_unique_optional(shop_rows, "slug", "shop_master")
    ensure_unique_optional(shop_rows, "registry_id", "shop_master")
    ensure_unique_optional(service_rows, "slug", "service_master")
    ensure_unique_optional(service_rows, "registry_id", "service_master")
    ensure_unique_optional(loot_table_rows, "slug", "loot_table_master")
    ensure_unique_optional(loot_table_rows, "registry_id", "loot_table_master")
    ensure_unique(shop_rows, "shop_id", "shop_master")
    ensure_unique_optional(shop_rows, "slug", "shop_master")
    ensure_unique_optional(shop_rows, "registry_id", "shop_master")
    ensure_unique(service_rows, "service_id", "service_master")
    ensure_unique_optional(service_rows, "slug", "service_master")
    ensure_unique_optional(service_rows, "registry_id", "service_master")
    ensure_unique(loot_table_rows, "loot_table_id", "loot_table_master")
    ensure_unique_optional(loot_table_rows, "slug", "loot_table_master")
    ensure_unique_optional(loot_table_rows, "registry_id", "loot_table_master")
    ensure_unique_pairs(shop_inventory_rows, ("shop_id", "slot_no"), "shop_inventory_master")
    ensure_unique_pairs(shop_service_rows, ("shop_id", "service_id"), "shop_service_master")
    ensure_unique_pairs(loot_entry_rows, ("loot_table_id", "entry_no"), "loot_entry_master")

    actual_csv_files = {path.name for path in csv_dir.glob("*.csv")}
    indexed_csv_files = {row["file_name"].strip() for row in master_index_rows}
    if actual_csv_files != indexed_csv_files:
        missing = sorted(indexed_csv_files - actual_csv_files)
        extra = sorted(actual_csv_files - indexed_csv_files)
        raise ValidationError(f"master_index mismatch: missing={missing} extra={extra}")
    for row in master_index_rows:
        indexed_path = csv_dir / row["file_name"].strip()
        header = read_header(indexed_path)
        primary_key = row["primary_key"].strip()
        if primary_key not in header:
            raise ValidationError(f"master_index.{indexed_path.name}: missing primary_key '{primary_key}'")

    monster_ids = {row["monster_id"].strip() for row in monster_rows}
    skill_ids = {row["skill_id"].strip() for row in skill_rows}
    item_ids = {row["item_id"].strip() for row in item_rows}
    world_ids = {row["world_id"].strip() for row in world_rows}
    zone_ids = {row["zone_id"].strip() for row in zone_rows}
    gate_ids = {row["gate_id"].strip() for row in gate_rows}
    clue_ids = {row["clue_id"].strip() for row in clue_rows}
    npc_ids = {row["npc_id"].strip() for row in npc_rows}
    shop_ids = {row["shop_id"].strip() for row in shop_rows}
    service_ids = {row["service_id"].strip() for row in service_rows}
    loot_table_ids = {row["loot_table_id"].strip() for row in loot_table_rows}
    shop_ids = {row["shop_id"].strip() for row in shop_rows}
    service_ids = {row["service_id"].strip() for row in service_rows}
    loot_table_ids = {row["loot_table_id"].strip() for row in loot_table_rows}
    validate_field_rows(
        field_scene_rows,
        field_rect_rows,
        field_point_rows,
        field_trigger_rows,
        field_interaction_rows,
        world_ids,
        zone_ids,
        npc_ids,
        clue_ids,
    )

    resistance_map = {row["monster_id"].strip(): row for row in resistance_rows}
    learnset_map: dict[str, list[dict[str, str]]] = {}
    for row in learnset_rows:
        monster_id = validate_reference(row["monster_id"], monster_ids, "monster_learnset.monster_id")
        validate_reference(row["skill_id"], skill_ids, "monster_learnset.skill_id")
        learnset_map.setdefault(monster_id, []).append(row)

    gate_indexes: set[int] = set()
    gated_worlds: set[str] = set()
    for row in gate_rows:
        gate_id = row["gate_id"].strip()
        if not GATE_ID_PATTERN.fullmatch(gate_id):
            raise ValidationError(f"progress_gate_master.gate_id: invalid gate id '{gate_id}'")
        world_id = validate_reference(row["world_id"], world_ids, "progress_gate_master.world_id")
        gated_worlds.add(world_id)
        gate_index = parse_int(gate_id.split("-")[1])
        if gate_index in gate_indexes:
            raise ValidationError(f"progress_gate_master: duplicate gate index {gate_index}")
        gate_indexes.add(gate_index)
        gate_type = validate_enum(row["condition_type"], GATE_TYPES, f"{gate_id}.condition_type")

        required_flag = row["required_flag"].strip()
        required_item = row["required_item_id"].strip()
        required_rank = row["required_rank"].strip()
        required_family_resonance = row["required_family_resonance"].strip()
        required_record_count = parse_optional_int(row["required_record_count"])
        if required_record_count < 0:
            raise ValidationError(f"{gate_id}: required_record_count cannot be negative")
        if not row["condition_summary"].strip():
            raise ValidationError(f"{gate_id}: condition_summary is required")

        requirement_count = 0
        if required_flag:
            validate_flag_expression(required_flag, f"{gate_id}.required_flag")
            requirement_count += 1
        if required_item:
            validate_item_reference(required_item, item_ids, f"{gate_id}.required_item")
            requirement_count += 1
        if required_rank:
            validate_enum(required_rank, ARENA_RANKS, f"{gate_id}.required_rank")
            requirement_count += 1
        if required_family_resonance:
            validate_family_resonance(required_family_resonance, f"{gate_id}.required_family_resonance")
            requirement_count += 1
        if required_record_count > 0:
            requirement_count += 1

        if gate_type == "story_flag" and (not required_flag or requirement_count != 1):
            raise ValidationError(f"{gate_id}: story_flag gate requires only required_flag")
        if gate_type == "arena_rank" and (not required_rank or requirement_count != 1):
            raise ValidationError(f"{gate_id}: arena_rank gate requires only required_rank")
        if gate_type == "key_item" and (not required_item or requirement_count != 1):
            raise ValidationError(f"{gate_id}: key_item gate requires only required_item_id")
        if gate_type == "clue_count" and (required_record_count <= 0 or requirement_count != 1):
            raise ValidationError(f"{gate_id}: clue_count gate requires only required_record_count")
        if gate_type == "family_resonance" and (not required_family_resonance or requirement_count != 1):
            raise ValidationError(f"{gate_id}: family_resonance gate requires only required_family_resonance")
        if gate_type == "composite" and (not required_item or required_record_count <= 0 or requirement_count != 2):
            raise ValidationError(f"{gate_id}: composite gate requires required_item_id and required_record_count")
    missing_gate_worlds = sorted(world_ids - gated_worlds)
    if missing_gate_worlds:
        raise ValidationError(f"progress_gate_master: missing gate rows for {missing_gate_worlds}")

    scope_ids = {row["scope_id"].strip() for row in dependency_rows}
    for row in dependency_rows:
        scope_id = row["scope_id"].strip()
        scope_kind = validate_enum(row["scope_kind"], SCOPE_KINDS, f"{scope_id}.scope_kind")
        world_id = row["world_id"].strip()
        if scope_kind == "world":
            validate_reference(world_id, world_ids, f"{scope_id}.world_id")
            if world_id != scope_id:
                raise ValidationError(f"{scope_id}: world scope must use matching world_id")
        elif world_id:
            raise ValidationError(f"{scope_id}: non-world scope cannot set world_id")

    validate_item_text_rows(item_text_rows, item_ids, scope_ids, shop_rows)

    for row in dependency_rows:
        scope_id = row["scope_id"].strip()
        gate_id = row["gate_id"].strip()
        if gate_id:
            validate_reference(gate_id, gate_ids, f"{scope_id}.gate_id")
        parent_scope_id = row["parent_scope_id"].strip()
        if parent_scope_id:
            validate_reference(parent_scope_id, scope_ids, f"{scope_id}.parent_scope_id")

    for row in shop_rows:
        shop_id = row["shop_id"].strip()
        if not SHOP_ID_PATTERN.fullmatch(shop_id):
            raise ValidationError(f"shop_master.shop_id: invalid shop id '{shop_id}'")
        validate_slug(row["slug"], f"{shop_id}.slug")
        if not row["name_jp"].strip() or not row["name_en"].strip():
            raise ValidationError(f"{shop_id}: shop names are required")
        validate_enum(row["shop_type"], SHOP_TYPES, f"{shop_id}.shop_type")
        validate_reference(row["scope_id"], scope_ids, f"{shop_id}.scope_id")
        if row["zone_id"].strip():
            validate_reference(row["zone_id"], zone_ids, f"{shop_id}.zone_id")
        if row["story_gate_flag"].strip():
            validate_flag_expression(row["story_gate_flag"], f"{shop_id}.story_gate_flag")
        if row["rank_gate"].strip():
            validate_enum(row["rank_gate"], ARENA_RANKS, f"{shop_id}.rank_gate")
        if not row["inventory_band"].strip():
            raise ValidationError(f"{shop_id}: inventory_band is required")
        if parse_float(row["base_price_multiplier"]) <= 0:
            raise ValidationError(f"{shop_id}: base_price_multiplier must be positive")
        validate_enum(row["restock_clock"], SHOP_RESTOCK_CLOCKS, f"{shop_id}.restock_clock")
        validate_enum(row["currency_type"], CURRENCY_TYPES, f"{shop_id}.currency_type")
        validate_enum(row["status"], ROW_STATUSES, f"{shop_id}.status")

    for row in service_rows:
        service_id = row["service_id"].strip()
        if not SERVICE_ID_PATTERN.fullmatch(service_id):
            raise ValidationError(f"service_master.service_id: invalid service id '{service_id}'")
        validate_slug(row["slug"], f"{service_id}.slug")
        if not row["name_jp"].strip() or not row["name_en"].strip():
            raise ValidationError(f"{service_id}: service names are required")
        validate_enum(row["service_category"], SERVICE_CATEGORIES, f"{service_id}.service_category")
        validate_reference(row["scope_id"], scope_ids, f"{service_id}.scope_id")
        validate_enum(row["pricing_basis"], PRICING_BASES, f"{service_id}.pricing_basis")
        if parse_int(row["base_price"]) < 0:
            raise ValidationError(f"{service_id}: base_price cannot be negative")
        if row["uses_per_reset"].strip():
            parse_optional_positive_int(row["uses_per_reset"])
        if row["story_gate_flag"].strip():
            validate_flag_expression(row["story_gate_flag"], f"{service_id}.story_gate_flag")
        if not row["effect_key"].strip():
            raise ValidationError(f"{service_id}: effect_key is required")
        validate_enum(row["status"], ROW_STATUSES, f"{service_id}.status")

    for row in loot_table_rows:
        loot_table_id = row["loot_table_id"].strip()
        if not LOOT_TABLE_ID_PATTERN.fullmatch(loot_table_id):
            raise ValidationError(f"loot_table_master.loot_table_id: invalid id '{loot_table_id}'")
        validate_slug(row["slug"], f"{loot_table_id}.slug")
        source_type = validate_enum(row["source_type"], LOOT_SOURCE_TYPES, f"{loot_table_id}.source_type")
        if source_type == "enemy":
            validate_reference(row["source_ref"], monster_ids, f"{loot_table_id}.source_ref")
        elif not row["source_ref"].strip():
            raise ValidationError(f"{loot_table_id}: source_ref is required")
        if row["world_id"].strip():
            validate_reference(row["world_id"], world_ids, f"{loot_table_id}.world_id")
        validate_enum(row["roll_policy"], ROLL_POLICIES, f"{loot_table_id}.roll_policy")
        roll_count_min = parse_int(row["roll_count_min"])
        roll_count_max = parse_int(row["roll_count_max"])
        if roll_count_min <= 0 or roll_count_max <= 0 or roll_count_min > roll_count_max:
            raise ValidationError(f"{loot_table_id}: invalid roll count range")
        validate_enum(row["status"], ROW_STATUSES, f"{loot_table_id}.status")

    shop_inventory_by_shop: dict[str, list[dict[str, str]]] = {}
    duplicate_inventory_keys: dict[str, set[tuple[str, str, str, str]]] = {}
    for row in shop_inventory_rows:
        shop_id = validate_reference(row["shop_id"], shop_ids, "shop_inventory_master.shop_id")
        slot_no = parse_int(row["slot_no"])
        if slot_no <= 0:
            raise ValidationError(f"{shop_id}: slot_no must be positive")
        validate_reference(row["item_id"], item_ids, f"{shop_id}.item_id")
        if row["unlock_flag"].strip():
            validate_flag_expression(row["unlock_flag"], f"{shop_id}.unlock_flag")
        if row["unlock_rank"].strip():
            validate_enum(row["unlock_rank"], ARENA_RANKS, f"{shop_id}.unlock_rank")
        validate_enum(row["stock_mode"], STOCK_MODES, f"{shop_id}.stock_mode")
        if row["max_stock"].strip():
            parse_optional_positive_int(row["max_stock"])
        if row["buy_limit_per_save"].strip():
            parse_optional_positive_int(row["buy_limit_per_save"])
        if row["stock_mode"].strip() == "one_time_unlock" and row["buy_limit_per_save"].strip() != "1":
            raise ValidationError(f"{shop_id}: one_time_unlock items must set buy_limit_per_save=1")
        if row["restock_rule"].strip() and row["restock_rule"].strip() not in SHOP_RESTOCK_CLOCKS:
            raise ValidationError(f"{shop_id}.restock_rule: invalid value '{row['restock_rule']}'")
        if row["price_override"].strip() and parse_int(row["price_override"]) <= 0:
            raise ValidationError(f"{shop_id}: price_override must be positive")
        if row["price_multiplier"].strip() and parse_float(row["price_multiplier"]) <= 0:
            raise ValidationError(f"{shop_id}: price_multiplier must be positive")
        if parse_int(row["display_priority"]) < 0:
            raise ValidationError(f"{shop_id}: display_priority cannot be negative")
        parse_bool(row["hidden_until_unlocked"])
        validate_enum(row["status"], ROW_STATUSES, f"{shop_id}.status")
        duplicate_key = (
            row["item_id"].strip(),
            row["unlock_flag"].strip(),
            row["unlock_rank"].strip(),
            row["price_override"].strip() or row["price_multiplier"].strip(),
        )
        seen_keys = duplicate_inventory_keys.setdefault(shop_id, set())
        if duplicate_key in seen_keys:
            raise ValidationError(f"{shop_id}: duplicate item row with identical unlock/price conditions for {row['item_id']}")
        seen_keys.add(duplicate_key)
        shop_inventory_by_shop.setdefault(shop_id, []).append(row)

    shop_services_by_shop: dict[str, list[dict[str, str]]] = {}
    for row in shop_service_rows:
        shop_id = validate_reference(row["shop_id"], shop_ids, "shop_service_master.shop_id")
        service_id = validate_reference(row["service_id"], service_ids, f"{shop_id}.service_id")
        if row["unlock_flag"].strip():
            validate_flag_expression(row["unlock_flag"], f"{shop_id}.unlock_flag")
        if row["price_override"].strip() and parse_int(row["price_override"]) <= 0:
            raise ValidationError(f"{shop_id}: service price_override must be positive")
        if row["price_multiplier"].strip() and parse_float(row["price_multiplier"]) <= 0:
            raise ValidationError(f"{shop_id}: service price_multiplier must be positive")
        if row["uses_per_reset_override"].strip():
            parse_optional_positive_int(row["uses_per_reset_override"])
        if parse_int(row["display_priority"]) < 0:
            raise ValidationError(f"{shop_id}: service display_priority cannot be negative")
        validate_enum(row["status"], ROW_STATUSES, f"{shop_id}.status")
        shop_services_by_shop.setdefault(shop_id, []).append(row)

    missing_shop_payloads = sorted(
        shop_id for shop_id in shop_ids if shop_id not in shop_inventory_by_shop and shop_id not in shop_services_by_shop
    )
    if missing_shop_payloads:
        raise ValidationError(f"shop_master: rows without inventory or service binding {missing_shop_payloads}")

    loot_entries_by_table: dict[str, list[dict[str, str]]] = {}
    for row in loot_entry_rows:
        loot_table_id = validate_reference(row["loot_table_id"], loot_table_ids, "loot_entry_master.loot_table_id")
        grant_type = validate_enum(row["grant_type"], GRANT_TYPES, f"{loot_table_id}.grant_type")
        if grant_type == "item":
            validate_reference(row["grant_id"], item_ids, f"{loot_table_id}.grant_id")
        elif not row["grant_id"].strip():
            raise ValidationError(f"{loot_table_id}: reward grant_id is required")
        validate_enum(row["drop_slot_type"], DROP_SLOT_TYPES, f"{loot_table_id}.drop_slot_type")
        drop_rate = parse_float(row["base_drop_rate"])
        if drop_rate <= 0 or drop_rate > 1:
            raise ValidationError(f"{loot_table_id}: base_drop_rate must be between 0 and 1")
        quantity_min = parse_int(row["quantity_min"])
        quantity_max = parse_int(row["quantity_max"])
        if quantity_min <= 0 or quantity_max <= 0 or quantity_min > quantity_max:
            raise ValidationError(f"{loot_table_id}: invalid quantity range")
        if row["weight"].strip():
            parse_optional_positive_int(row["weight"])
        parse_bool(row["first_clear_only"])
        parse_bool(row["unique_once"])
        if row["condition_flag"].strip():
            validate_flag_expression(row["condition_flag"], f"{loot_table_id}.condition_flag")
        validate_enum(row["status"], ROW_STATUSES, f"{loot_table_id}.status")
        loot_entries_by_table.setdefault(loot_table_id, []).append(row)
    missing_loot_entries = sorted(loot_table_ids - set(loot_entries_by_table))
    if missing_loot_entries:
        raise ValidationError(f"loot_entry_master: missing entries for {missing_loot_entries}")

    canonical_ids_by_type = {
        "item": item_ids,
        "shop": shop_ids,
        "service": service_ids,
        "loot": loot_table_ids,
        "reward": set(),
    }
    alias_maps = build_alias_maps(alias_rows, canonical_ids_by_type, project_root)
    resolved_monster_loot_ids: dict[str, str] = {}
    loot_table_source_map = {row["loot_table_id"].strip(): row["source_ref"].strip() for row in loot_table_rows}
    for row in clue_rows:
        clue_id = row["clue_id"].strip()
        validate_enum(row["tier"], CLUE_TIERS, f"{clue_id}.tier")
        origin_scope_kind = validate_enum(row["origin_scope_kind"], SCOPE_KINDS - {"story_stage"}, f"{clue_id}.origin_scope_kind")
        origin_scope_id = validate_reference(row["origin_scope_id"], scope_ids, f"{clue_id}.origin_scope_id")
        if origin_scope_kind == "world" and origin_scope_id not in world_ids:
            raise ValidationError(f"{clue_id}: world origin_scope_id must be a world_id")
        payoff_scope_id = row["payoff_scope_id"].strip()
        payoff_scope_kind = row["payoff_scope_kind"].strip()
        if payoff_scope_kind == "story_stage":
            validate_enum(payoff_scope_id, STORY_STAGE_IDS, f"{clue_id}.payoff_scope_id")
        else:
            validate_reference(payoff_scope_id, world_ids, f"{clue_id}.payoff_scope_id")
        validate_enum(row["medium"], CLUE_MEDIA, f"{clue_id}.medium")
        if not row["summary_jp"].strip():
            raise ValidationError(f"{clue_id}: summary_jp is required")

    for row in monster_rows:
        monster_id = row["monster_id"].strip()
        resolved_loot_table_id = resolve_canonical_reference(
            row["loot_table_id"],
            loot_table_ids,
            alias_maps["loot"],
            f"{monster_id}.loot_table_id",
        )
        resolved_monster_loot_ids[monster_id] = resolved_loot_table_id
        if loot_table_source_map[resolved_loot_table_id] != monster_id:
            raise ValidationError(f"{monster_id}: loot table source_ref must point back to the same monster")

    resolved_npc_refs: dict[str, dict[str, str]] = {}
    for row in npc_rows:
        npc_id = row["npc_id"].strip()
        scope_id = validate_reference(row["world_id"], scope_ids, "npc_master.world_id")
        for clue_id in split_csv_list(row["clue_ids"]):
            validate_reference(clue_id, clue_ids, f"{npc_id}.clue_ids")
        resolved_npc_refs[npc_id] = {
            "scope_id": scope_id,
            "shop_id": resolve_canonical_reference(
                row["shop_id"],
                shop_ids,
                alias_maps["shop"],
                f"{npc_id}.shop_id",
            ),
            "service_id": resolve_canonical_reference(
                row["service_id"],
                service_ids,
                alias_maps["service"],
                f"{npc_id}.service_id",
            ),
        }
        if resolved_npc_refs[npc_id]["shop_id"] and resolved_npc_refs[npc_id]["service_id"]:
            linked_services = {
                service_row["service_id"].strip()
                for service_row in shop_services_by_shop.get(resolved_npc_refs[npc_id]["shop_id"], [])
            }
            if resolved_npc_refs[npc_id]["service_id"] not in linked_services:
                raise ValidationError(f"{npc_id}: shop/service pair is not bound in shop_service_master")

    localization_file_keys: dict[Path, set[str]] = {}
    for row in localization_rows:
        registry_id = row.get("registry_id", "").strip() or row.get("entry_id", "").strip()
        validate_enum(row["locale"], LOCALIZATION_LOCALES, f"{registry_id}.locale")
        status = row.get("status", "").strip() or "seed"
        validate_enum(status, {"seed", "planned", "draft", "reviewed", "approved"}, f"{registry_id}.status")
        source_path = row.get("source_path", "").strip()
        if source_path:
            resolve_project_path(project_root, source_path, f"{registry_id}.source_path")
        backing_file = row.get("backing_file", "").strip()
        if not backing_file:
            backing_file = f"data/localization/{row['file_name'].strip()}"
        backing_path = resolve_project_path(project_root, backing_file, f"{registry_id}.backing_file")
        if backing_path not in localization_file_keys:
            localization_file_keys[backing_path] = load_localization_keys(backing_path)
        key_pattern = row.get("key_pattern", "").strip() or row.get("key", "").strip()
        if status == "seed" and key_pattern not in localization_file_keys[backing_path]:
            raise ValidationError(f"{registry_id}: missing key '{key_pattern}' in {backing_file}")

    for row in asset_rows:
        asset_id = row["asset_id"].strip()
        validate_enum(row["asset_type"], ASSET_TYPES, f"{asset_id}.asset_type")
        if not row["owner_id"].strip():
            raise ValidationError(f"{asset_id}: owner_id is required")
        if row.get("asset_domain", "").strip():
            validate_enum(row["asset_domain"], ASSET_DOMAINS, f"{asset_id}.asset_domain")
            validate_enum(row["provenance_class"], PROVENANCE_CLASSES, f"{asset_id}.provenance_class")
            validate_enum(row["manual_touch_level"], MANUAL_TOUCH_LEVELS, f"{asset_id}.manual_touch_level")
            validate_enum(row["license_clearance"], LICENSE_CLEARANCES, f"{asset_id}.license_clearance")
            validate_enum(row["legal_review_state"], LEGAL_REVIEW_STATES, f"{asset_id}.legal_review_state")
            validate_enum(row["qa_review_state"], QA_REVIEW_STATES, f"{asset_id}.qa_review_state")
            validate_enum(row["approval_state"], APPROVAL_STATES, f"{asset_id}.approval_state")
            validate_enum(row["release_channel"], RELEASE_CHANNELS, f"{asset_id}.release_channel")
            if not row["usage_context"].strip():
                raise ValidationError(f"{asset_id}: usage_context is required")
            if row["source_file"].strip():
                resolve_project_path(project_root, row["source_file"], f"{asset_id}.source_file")
            export_path = resolve_project_path(project_root, row["export_file"], f"{asset_id}.export_file")
            manifest_path = resolve_project_path(project_root, row["manifest_path"], f"{asset_id}.manifest_path")
            if not row["export_sha256"].strip():
                raise ValidationError(f"{asset_id}: export_sha256 is required")
            if compute_sha256(export_path) != row["export_sha256"].strip():
                raise ValidationError(f"{asset_id}: export_sha256 mismatch")
            if manifest_path.suffix.lower() != ".json":
                raise ValidationError(f"{asset_id}: manifest_path must point to a json file")
        parse_bool(row["edited_by_hand"])
        if row.get("approved", "").strip():
            parse_bool(row["approved"])

    registered_audio_assets = {
        row["asset_id"].strip()
        for row in asset_rows
        if row.get("asset_domain", "").strip() == "sound"
        or row.get("asset_type", "").strip() in {"bgm", "se", "amb", "jingle"}
    }
    if registered_audio_assets:
        missing_bgm_assets = {
            row["bgm_id"].strip()
            for row in zone_rows
            if row.get("bgm_id", "").strip() and row["bgm_id"].strip() not in registered_audio_assets
        }
        if missing_bgm_assets:
            raise ValidationError(f"asset_registry: missing bgm rows for {sorted(missing_bgm_assets)}")

    encounter_map: dict[str, list[dict[str, Any]]] = {}
    encounter_slots: dict[str, set[int]] = {}
    for row in encounter_rows:
        zone_id = validate_reference(row["zone_id"], zone_ids, "encounter_table.zone_id")
        monster_id = validate_reference(row["monster_id"], monster_ids, "encounter_table.monster_id")
        time_band = validate_enum(row["time_band"], TIME_BANDS, "encounter_table.time_band")
        weather = validate_enum(row["weather"], WEATHER_TYPES, "encounter_table.weather")
        slot = parse_int(row["slot"])
        weight = parse_int(row["weight"])
        min_lv = parse_int(row["min_lv"])
        max_lv = parse_int(row["max_lv"])
        if slot <= 0:
            raise ValidationError(f"{zone_id}: encounter slot must be positive")
        if weight <= 0:
            raise ValidationError(f"{zone_id}: encounter weight must be positive")
        if min_lv > max_lv:
            raise ValidationError(f"{zone_id}: encounter min_lv cannot exceed max_lv")
        zone_slots = encounter_slots.setdefault(zone_id, set())
        if slot in zone_slots:
            raise ValidationError(f"{zone_id}: duplicate encounter slot {slot}")
        zone_slots.add(slot)
        encounter_map.setdefault(zone_id, []).append(
            {
                "slot": slot,
                "monster_id": monster_id,
                "weight": weight,
                "min_lv": min_lv,
                "max_lv": max_lv,
                "time_band": time_band,
                "weather": weather,
            }
        )

    for row in zone_rows:
        zone_id = row["zone_id"].strip()
        validate_reference(row["world_id"], world_ids, "zone_master.world_id")
        min_steps = parse_int(row["encounter_min_steps"])
        max_steps = parse_int(row["encounter_max_steps"])
        terrain_rate = parse_float(row["terrain_rate"])
        if min_steps > max_steps:
            raise ValidationError(f"{zone_id}: encounter_min_steps cannot exceed encounter_max_steps")
        if terrain_rate <= 0:
            raise ValidationError(f"{zone_id}: terrain_rate must be positive")
        validate_optional_enum(row, "time_band", TIME_BANDS, f"{zone_id}.time_band", "any")
        validate_optional_enum(row, "weather", WEATHER_TYPES, f"{zone_id}.weather", "any")
        if zone_id not in encounter_map:
            raise ValidationError(f"{zone_id}: missing encounter rows")

    for row in breed_rows:
        validate_enum(row["rule_type"], RULE_TYPES, "breed_rule.rule_type")
        validate_reference(row["child_monster_id"], monster_ids, "breed_rule.child_monster_id")
        normalize_parent_key(row["parent_a_key"], monster_ids, "breed_rule.parent_a_key")
        normalize_parent_key(row["parent_b_key"], monster_ids, "breed_rule.parent_b_key")

    for row in monster_rows:
        validate_slug(row["slug"], f'{row["monster_id"].strip()}.slug')

    for row in skill_rows:
        validate_slug(row["slug"], f'{row["skill_id"].strip()}.slug')

    for row in item_rows:
        validate_slug(row["slug"], f'{row["item_id"].strip()}.slug')

    for row in world_rows:
        validate_slug(row["slug"], f'{row["world_id"].strip()}.slug')

    output_dir.mkdir(parents=True, exist_ok=True)
    for directory_name in MANAGED_RESOURCE_DIRS:
        managed_dir = output_dir / directory_name
        if managed_dir.exists():
            shutil.rmtree(managed_dir)

    manifest: dict[str, dict[str, str]] = {
        "monsters": {},
        "skills": {},
        "items": {},
        "worlds": {},
        "encounters": {},
        "breeding": {},
        "npcs": {},
        "shops": {},
        "services": {},
        "loot_tables": {},
    }

    for row in monster_rows:
        monster_id = row["monster_id"].strip()
        validate_enum(row["family"], FAMILIES, f"{monster_id}.family")
        validate_enum(row["rank"], RANKS, f"{monster_id}.rank")
        validate_enum(row["size_class"], SIZE_CLASSES, f"{monster_id}.size_class")
        validate_enum(row["motif_group"], MOTIF_GROUPS, f"{monster_id}.motif_group")
        validate_enum(row["secondary_motif_group"], SECONDARY_MOTIF_GROUPS, f"{monster_id}.secondary_motif_group")
        validate_enum(row["ontology_class"], ONTOLOGY_CLASSES, f"{monster_id}.ontology_class")
        validate_enum(row["silhouette_type"], SILHOUETTE_TYPES, f"{monster_id}.silhouette_type")
        validate_enum(row["growth_curve_id"], GROWTH_CURVES, f"{monster_id}.growth_curve_id")
        validate_enum(row["battle_role"], BATTLE_ROLES, f"{monster_id}.battle_role")
        resolved_loot_table_id = resolved_monster_loot_ids[monster_id]

        resistance_row = resistance_map.get(monster_id)
        if resistance_row is None:
            raise ValidationError(f"monster_resistance missing row for {monster_id}")

        payload = {
            "monster_id": monster_id,
            "slug": row["slug"].strip(),
            "name_jp": row["name_jp"].strip(),
            "name_en": row["name_en"].strip(),
            "family": row["family"].strip(),
            "rank": row["rank"].strip(),
            "size_class": row["size_class"].strip(),
            "motif_group": row["motif_group"].strip(),
            "secondary_motif_group": row["secondary_motif_group"].strip(),
            "motif_source": row["motif_source"].strip(),
            "ontology_class": row["ontology_class"].strip(),
            "silhouette_type": row["silhouette_type"].strip(),
            "palette_id": row["palette_id"].strip(),
            "field_sprite_px": parse_int(row["field_sprite_px"]),
            "battle_sprite_px": parse_int(row["battle_sprite_px"]),
            "base_level_cap": parse_int(row["base_level_cap"]),
            "growth_curve_id": row["growth_curve_id"].strip(),
            "base_stats": {
                "hp": parse_int(row["base_hp"]),
                "mp": parse_int(row["base_mp"]),
                "atk": parse_int(row["base_atk"]),
                "def": parse_int(row["base_def"]),
                "spd": parse_int(row["base_spd"]),
                "int": parse_int(row["base_int"]),
                "res": parse_int(row["base_res"]),
            },
            "cap_stats": {
                "hp": parse_int(row["cap_hp"]),
                "mp": parse_int(row["cap_mp"]),
                "atk": parse_int(row["cap_atk"]),
                "def": parse_int(row["cap_def"]),
                "spd": parse_int(row["cap_spd"]),
                "int": parse_int(row["cap_int"]),
                "res": parse_int(row["cap_res"]),
            },
            "base_recruit": parse_int(row["base_recruit"]),
            "scoutable": parse_bool(row["scoutable"]),
            "personality_bias": row["personality_bias"].strip(),
            "battle_role": row["battle_role"].strip(),
            "trait_1": row["trait_1"].strip(),
            "trait_2": row["trait_2"].strip(),
            "loot_table_id": resolved_loot_table_id,
            "prompt_id": row["prompt_id"].strip(),
            "notes": row["notes"].strip(),
            "resistances": {
                "fire": parse_int(resistance_row["fire"]),
                "water": parse_int(resistance_row["water"]),
                "wind": parse_int(resistance_row["wind"]),
                "earth": parse_int(resistance_row["earth"]),
                "thunder": parse_int(resistance_row["thunder"]),
                "light": parse_int(resistance_row["light"]),
                "dark": parse_int(resistance_row["dark"]),
                "poison": parse_int(resistance_row["poison"]),
                "sleep": parse_int(resistance_row["sleep"]),
                "paralysis": parse_int(resistance_row["paralysis"]),
                "confusion": parse_int(resistance_row["confusion"]),
                "seal": parse_int(resistance_row["seal"]),
                "fear": parse_int(resistance_row["fear"]),
                "instant_death": parse_int(resistance_row["instant_death"]),
                "burn": parse_int(resistance_row["burn"]),
                "freeze": parse_int(resistance_row["freeze"]),
                "curse": parse_int(resistance_row["curse"]),
                "blind": parse_int(resistance_row["blind"]),
                "charm": parse_int(resistance_row["charm"]),
                "mark": parse_int(resistance_row["mark"]),
                "hush": parse_int(resistance_row["hush"]),
            },
            "learnset": [
                {
                    "learn_type": learn_row["learn_type"].strip(),
                    "learn_value": parse_int(learn_row["learn_value"]),
                    "skill_id": learn_row["skill_id"].strip(),
                }
                for learn_row in learnset_map.get(monster_id, [])
            ],
        }
        file_name = f'{row["slug"].strip()}.tres'
        write_resource(
            output_dir / "monsters" / file_name,
            "res://scripts/data/monster_data.gd",
            "MonsterData",
            payload,
        )
        manifest["monsters"][monster_id] = f"res://resources/monsters/{file_name}"

    for row in skill_rows:
        payload = {
            "skill_id": row["skill_id"].strip(),
            "slug": row["slug"].strip(),
            "name_jp": row["name_jp"].strip(),
            "name_en": row["name_en"].strip(),
            "category": row["category"].strip(),
            "element": row["element"].strip(),
            "mp_cost": parse_int(row["mp_cost"]),
            "target_scope": row["target_scope"].strip(),
            "formula_key": row["formula_key"].strip(),
            "base_power": parse_int(row["base_power"]),
            "base_rate": parse_int(row["base_rate"]),
            "tags": split_pipe(row["tags"]),
            "battle_role": row["battle_role"].strip(),
            "effect_text": row["effect_text"].strip(),
        }
        file_name = f'{row["slug"].strip()}.tres'
        write_resource(
            output_dir / "skills" / file_name,
            "res://scripts/data/skill_data.gd",
            "SkillData",
            payload,
        )
        manifest["skills"][row["skill_id"].strip()] = f"res://resources/skills/{file_name}"

    for row in item_rows:
        payload = {
            "item_id": row["item_id"].strip(),
            "slug": row["slug"].strip(),
            "name_jp": row["name_jp"].strip(),
            "name_en": row["name_en"].strip(),
            "item_kind": row["item_kind"].strip(),
            "subtype": row["subtype"].strip(),
            "price": parse_int(row["price"]),
            "sell_price": parse_int(row["sell_price"]),
            "target_scope": row["target_scope"].strip(),
            "effect_key": row["effect_key"].strip(),
            "effect_value": row["effect_value"].strip(),
            "tags": split_pipe(row["tags"]),
            "description": row["description"].strip(),
        }
        file_name = f'{row["slug"].strip()}.tres'
        write_resource(
            output_dir / "items" / file_name,
            "res://scripts/data/item_data.gd",
            "ItemData",
            payload,
        )
        manifest["items"][row["item_id"].strip()] = f"res://resources/items/{file_name}"

    for row in world_rows:
        dominant_families = split_pipe(row["dominant_families"])
        for family in dominant_families:
            validate_enum(family, FAMILIES, f'{row["world_id"].strip()}.dominant_families')
        payload = {
            "world_id": row["world_id"].strip(),
            "slug": row["slug"].strip(),
            "name_jp": row["name_jp"].strip(),
            "name_en": row["name_en"].strip(),
            "act": row["act"].strip(),
            "size_class": row["size_class"].strip(),
            "function_class": row["function_class"].strip(),
            "level_min": parse_int(row["level_min"]),
            "level_max": parse_int(row["level_max"]),
            "taboo": row["taboo"].strip(),
            "biome": row["biome"].strip(),
            "power_structure": row["power_structure"].strip(),
            "dominant_families": dominant_families,
            "gate_condition": row["gate_condition"].strip(),
            "notes": row["notes"].strip(),
        }
        file_name = f'{row["slug"].strip()}.tres'
        write_resource(
            output_dir / "worlds" / file_name,
            "res://scripts/data/world_data.gd",
            "WorldData",
            payload,
        )
        manifest["worlds"][row["world_id"].strip()] = f"res://resources/worlds/{file_name}"

    for row in zone_rows:
        zone_id = row["zone_id"].strip()
        entries = sorted(encounter_map[zone_id], key=lambda entry: entry["slot"])
        zone_time_band = validate_optional_enum(row, "time_band", TIME_BANDS, f"{zone_id}.time_band", "")
        zone_weather = validate_optional_enum(row, "weather", WEATHER_TYPES, f"{zone_id}.weather", "")
        if not zone_time_band:
            zone_time_band = infer_uniform_enum(entries, "time_band", TIME_BANDS, "any", f"{zone_id}.entries.time_band")
        if not zone_weather:
            zone_weather = infer_uniform_enum(entries, "weather", WEATHER_TYPES, "any", f"{zone_id}.entries.weather")
        payload = {
            "zone_id": zone_id,
            "world_id": row["world_id"].strip(),
            "name_jp": row["name_jp"].strip(),
            "encounter_min_steps": parse_int(row["encounter_min_steps"]),
            "encounter_max_steps": parse_int(row["encounter_max_steps"]),
            "terrain_rate": parse_float(row["terrain_rate"]),
            "bgm_id": row.get("bgm_id", "").strip(),
            "is_dungeon": parse_optional_bool(row.get("is_dungeon"), False),
            "time_band": zone_time_band,
            "weather": zone_weather,
            "notes": row["notes"].strip(),
            "entries": entries,
        }
        file_name = f'{zone_id.lower().replace("-", "_")}.tres'
        write_resource(
            output_dir / "encounters" / file_name,
            "res://scripts/data/encounter_zone_data.gd",
            "EncounterZoneData",
            payload,
        )
        manifest["encounters"][zone_id] = f"res://resources/encounters/{file_name}"

    for row in sorted(breed_rows, key=lambda item: (-parse_int(item["priority"]), item["rule_id"].strip())):
        payload = {
            "rule_id": row["rule_id"].strip(),
            "rule_type": row["rule_type"].strip(),
            "parent_a_key": normalize_parent_key(row["parent_a_key"], monster_ids, "breed_rule.parent_a_key"),
            "parent_b_key": normalize_parent_key(row["parent_b_key"], monster_ids, "breed_rule.parent_b_key"),
            "child_monster_id": row["child_monster_id"].strip(),
            "priority": parse_int(row["priority"]),
            "special_recipe_bonus": parse_int(row["special_recipe_bonus"]),
            "lv_requirement": parse_int(row["lv_requirement"]),
            "notes": row["notes"].strip(),
        }
        file_name = f'{row["rule_id"].strip().lower().replace("-", "_")}.tres'
        write_resource(
            output_dir / "breeding" / file_name,
            "res://scripts/data/breed_rule_data.gd",
            "BreedRuleData",
            payload,
        )
        manifest["breeding"][row["rule_id"].strip()] = f"res://resources/breeding/{file_name}"

    for row in npc_rows:
        npc_id = row["npc_id"].strip()
        resolved_ref = resolved_npc_refs[npc_id]
        payload = {
            "npc_id": npc_id,
            "scope_id": resolved_ref["scope_id"],
            "name_jp": row["name_jp"].strip(),
            "name_en": row["name_en"].strip(),
            "role": row["role"].strip(),
            "dark_role": row["dark_role"].strip(),
            "x": parse_int(row["x"]),
            "y": parse_int(row["y"]),
            "facing": row["facing"].strip(),
            "npc_type": row["npc_type"].strip(),
            "phase_count": parse_int(row["phase_count"]),
            "clue_ids": split_csv_list(row["clue_ids"]),
            "shop_id": resolved_ref["shop_id"],
            "service_id": resolved_ref["service_id"],
            "personality_note": row["personality_note"].strip(),
            "initial_dialogue_jp": row["initial_dialogue_jp"].strip(),
            "notes": row["notes"].strip(),
        }
        file_name = f'{npc_id.lower().replace("-", "_")}.tres'
        write_resource(
            output_dir / "npcs" / file_name,
            "res://scripts/data/npc_data.gd",
            "NpcData",
            payload,
        )
        manifest["npcs"][npc_id] = f"res://resources/npcs/{file_name}"

    for row in service_rows:
        service_id = row["service_id"].strip()
        payload = {
            "service_id": service_id,
            "slug": row["slug"].strip(),
            "registry_id": row.get("registry_id", "").strip(),
            "name_jp": row["name_jp"].strip(),
            "name_en": row["name_en"].strip(),
            "service_category": row["service_category"].strip(),
            "scope_id": row["scope_id"].strip(),
            "pricing_basis": row["pricing_basis"].strip(),
            "base_price": parse_int(row["base_price"]),
            "effect_key": row["effect_key"].strip(),
            "effect_value": row["effect_value"].strip(),
            "uses_per_reset": parse_optional_positive_int(row.get("uses_per_reset", "")),
            "story_gate_flag": row.get("story_gate_flag", "").strip(),
            "status": row["status"].strip(),
            "tags": split_pipe(row["tags"]),
            "notes": row["notes"].strip(),
        }
        file_name = f'{row["slug"].strip()}.tres'
        write_resource(
            output_dir / "services" / file_name,
            "res://scripts/data/service_data.gd",
            "ServiceData",
            payload,
        )
        manifest["services"][service_id] = f"res://resources/services/{file_name}"

    for row in shop_rows:
        shop_id = row["shop_id"].strip()
        inventory_entries = [
            {
                "slot_no": parse_int(entry["slot_no"]),
                "item_id": entry["item_id"].strip(),
                "unlock_flag": entry.get("unlock_flag", "").strip(),
                "unlock_rank": entry.get("unlock_rank", "").strip(),
                "stock_mode": entry["stock_mode"].strip(),
                "max_stock": parse_optional_positive_int(entry.get("max_stock", "")),
                "restock_rule": entry["restock_rule"].strip(),
                "buy_limit_per_save": parse_optional_positive_int(entry.get("buy_limit_per_save", "")),
                "price_override": parse_optional_positive_int(entry.get("price_override", "")),
                "price_multiplier": parse_float(entry["price_multiplier"]) if entry.get("price_multiplier", "").strip() else 1.0,
                "display_priority": parse_int(entry["display_priority"]),
                "hidden_until_unlocked": parse_bool(entry["hidden_until_unlocked"]),
                "status": entry["status"].strip(),
                "notes": entry["notes"].strip(),
            }
            for entry in sorted(shop_inventory_by_shop.get(shop_id, []), key=lambda item: parse_int(item["slot_no"]))
        ]
        service_ids_for_shop = [
            entry["service_id"].strip()
            for entry in sorted(shop_services_by_shop.get(shop_id, []), key=lambda item: item["service_id"].strip())
        ]
        payload = {
            "shop_id": shop_id,
            "slug": row["slug"].strip(),
            "registry_id": row.get("registry_id", "").strip(),
            "name_jp": row["name_jp"].strip(),
            "name_en": row["name_en"].strip(),
            "shop_type": row["shop_type"].strip(),
            "scope_id": row["scope_id"].strip(),
            "zone_id": row.get("zone_id", "").strip(),
            "story_gate_flag": row.get("story_gate_flag", "").strip(),
            "rank_gate": row.get("rank_gate", "").strip(),
            "inventory_band": row["inventory_band"].strip(),
            "base_price_multiplier": parse_float(row["base_price_multiplier"]),
            "restock_clock": row["restock_clock"].strip(),
            "currency_type": row["currency_type"].strip(),
            "status": row["status"].strip(),
            "tags": split_pipe(row["tags"]),
            "notes": row["notes"].strip(),
            "inventory_entries": inventory_entries,
            "service_ids": service_ids_for_shop,
        }
        file_name = f'{row["slug"].strip()}.tres'
        write_resource(
            output_dir / "shops" / file_name,
            "res://scripts/data/shop_data.gd",
            "ShopData",
            payload,
        )
        manifest["shops"][shop_id] = f"res://resources/shops/{file_name}"

    for row in loot_table_rows:
        loot_table_id = row["loot_table_id"].strip()
        payload = {
            "loot_table_id": loot_table_id,
            "slug": row["slug"].strip(),
            "registry_id": row.get("registry_id", "").strip(),
            "source_type": row["source_type"].strip(),
            "source_ref": row["source_ref"].strip(),
            "world_id": row.get("world_id", "").strip(),
            "roll_policy": row["roll_policy"].strip(),
            "roll_count_min": parse_int(row["roll_count_min"]),
            "roll_count_max": parse_int(row["roll_count_max"]),
            "first_clear_reward_id": row.get("first_clear_reward_id", "").strip(),
            "status": row["status"].strip(),
            "tags": split_pipe(row["tags"]),
            "notes": row["notes"].strip(),
            "entries": [
                {
                    "entry_no": parse_int(entry["entry_no"]),
                    "grant_type": entry["grant_type"].strip(),
                    "grant_id": entry["grant_id"].strip(),
                    "drop_slot_type": entry["drop_slot_type"].strip(),
                    "base_drop_rate": parse_float(entry["base_drop_rate"]),
                    "quantity_min": parse_int(entry["quantity_min"]),
                    "quantity_max": parse_int(entry["quantity_max"]),
                    "weight": parse_optional_positive_int(entry.get("weight", "")),
                    "first_clear_only": parse_bool(entry["first_clear_only"]),
                    "unique_once": parse_bool(entry["unique_once"]),
                    "condition_flag": entry.get("condition_flag", "").strip(),
                    "status": entry["status"].strip(),
                    "notes": entry["notes"].strip(),
                }
                for entry in sorted(loot_entries_by_table.get(loot_table_id, []), key=lambda item: parse_int(item["entry_no"]))
            ],
        }
        file_name = f'{row["slug"].strip()}.tres'
        write_resource(
            output_dir / "loot_tables" / file_name,
            "res://scripts/data/loot_table_data.gd",
            "LootTableData",
            payload,
        )
        manifest["loot_tables"][loot_table_id] = f"res://resources/loot_tables/{file_name}"

    return {
        "manifest": manifest,
        "counts": {key: len(value) for key, value in manifest.items()},
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv-dir", default=str(DEFAULT_CSV_DIR))
    parser.add_argument("--output-dir", default=str(DEFAULT_OUTPUT_DIR))
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()

    csv_dir = Path(args.csv_dir).resolve()

    try:
        if args.check:
            with tempfile.TemporaryDirectory() as temp_dir:
                result = build_all(csv_dir, Path(temp_dir))
        else:
            output_dir = Path(args.output_dir).resolve()
            result = build_all(csv_dir, output_dir)
            MANIFEST_PATH.parent.mkdir(parents=True, exist_ok=True)
            MANIFEST_PATH.write_text(
                json.dumps(result["manifest"], ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
        print(json.dumps(result["counts"], ensure_ascii=False, indent=2))
        return 0
    except ValidationError as error:
        print(f"validation error: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
