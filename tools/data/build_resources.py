from __future__ import annotations

import argparse
import csv
import json
import shutil
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CSV_DIR = REPO_ROOT / "data" / "csv"
DEFAULT_OUTPUT_DIR = REPO_ROOT / "resources"
MANIFEST_PATH = REPO_ROOT / "data" / "generated" / "resource_manifest.json"
MANAGED_RESOURCE_DIRS = ("monsters", "skills", "items", "worlds", "encounters", "breeding")

FAMILIES = {"slime", "beast", "bird", "plant", "material", "magic", "undead", "dragon", "divine"}
RANKS = {"E", "D", "C", "B", "A", "S"}
SIZE_CLASSES = {"S", "M", "L"}
GROWTH_CURVES = {"EARLY", "STANDARD", "LATE", "LEGEND"}
TIME_BANDS = {"any", "day", "dusk", "night"}
WEATHER_TYPES = {"any", "clear", "rain", "fog"}
RULE_TYPES = {"family", "special", "mutation"}
MOTIF_GROUPS = {"animal", "plant", "tool", "ritual", "weather", "myth", "corporeal", "abstract"}
SECONDARY_MOTIF_GROUPS = {"household", "pastoral", "funerary", "bureaucratic", "astral", "gatebound"}
ONTOLOGY_CLASSES = {"wildborn", "gate_touched", "bred_line", "record_bent", "remnant_bearing"}
SILHOUETTE_TYPES = {"round", "wide", "tall", "serpentine", "floating", "tripod", "massive"}
BATTLE_ROLES = {"striker", "tank", "healer", "controller", "bait_specialist", "mutation_key"}


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


def ensure_unique(rows: list[dict[str, str]], key: str, label: str) -> None:
    seen: set[str] = set()
    for row in rows:
        value = row[key].strip()
        if not value:
            raise ValidationError(f"{label}: empty {key}")
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


def build_all(csv_dir: Path, output_dir: Path) -> dict[str, Any]:
    monster_rows = read_csv_rows(csv_dir / "monster_master.csv")
    resistance_rows = read_csv_rows(csv_dir / "monster_resistance.csv")
    learnset_rows = read_csv_rows(csv_dir / "monster_learnset.csv")
    skill_rows = read_csv_rows(csv_dir / "skill_master.csv")
    item_rows = read_csv_rows(csv_dir / "item_master.csv")
    world_rows = read_csv_rows(csv_dir / "world_master.csv")
    zone_rows = read_csv_rows(csv_dir / "zone_master.csv")
    encounter_rows = read_csv_rows(csv_dir / "encounter_table.csv")
    breed_rows = read_csv_rows(csv_dir / "breed_rule.csv")

    ensure_unique(monster_rows, "monster_id", "monster_master")
    ensure_unique(resistance_rows, "monster_id", "monster_resistance")
    ensure_unique(skill_rows, "skill_id", "skill_master")
    ensure_unique(item_rows, "item_id", "item_master")
    ensure_unique(world_rows, "world_id", "world_master")
    ensure_unique(zone_rows, "zone_id", "zone_master")
    ensure_unique(breed_rows, "rule_id", "breed_rule")

    monster_ids = {row["monster_id"].strip() for row in monster_rows}
    skill_ids = {row["skill_id"].strip() for row in skill_rows}
    world_ids = {row["world_id"].strip() for row in world_rows}
    zone_ids = {row["zone_id"].strip() for row in zone_rows}

    resistance_map = {row["monster_id"].strip(): row for row in resistance_rows}
    learnset_map: dict[str, list[dict[str, str]]] = {}
    for row in learnset_rows:
        monster_id = validate_reference(row["monster_id"], monster_ids, "monster_learnset.monster_id")
        validate_reference(row["skill_id"], skill_ids, "monster_learnset.skill_id")
        learnset_map.setdefault(monster_id, []).append(row)

    for row in encounter_rows:
        validate_reference(row["zone_id"], zone_ids, "encounter_table.zone_id")
        validate_reference(row["monster_id"], monster_ids, "encounter_table.monster_id")
        validate_enum(row["time_band"], TIME_BANDS, "encounter_table.time_band")
        validate_enum(row["weather"], WEATHER_TYPES, "encounter_table.weather")

    for row in zone_rows:
        validate_reference(row["world_id"], world_ids, "zone_master.world_id")
        validate_enum(row["time_band"], TIME_BANDS, "zone_master.time_band")
        validate_enum(row["weather"], WEATHER_TYPES, "zone_master.weather")

    for row in breed_rows:
        validate_enum(row["rule_type"], RULE_TYPES, "breed_rule.rule_type")
        validate_reference(row["child_monster_id"], monster_ids, "breed_rule.child_monster_id")
        for key in ("parent_a_key", "parent_b_key"):
            parent_key = row[key].strip()
            if parent_key not in monster_ids and parent_key not in FAMILIES:
                raise ValidationError(f"breed_rule.{key}: unknown parent key '{parent_key}'")

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
            "loot_table_id": row["loot_table_id"].strip(),
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

    encounter_map: dict[str, list[dict[str, Any]]] = {}
    for row in encounter_rows:
        encounter_map.setdefault(row["zone_id"].strip(), []).append(
            {
                "slot": parse_int(row["slot"]),
                "monster_id": row["monster_id"].strip(),
                "weight": parse_int(row["weight"]),
                "min_lv": parse_int(row["min_lv"]),
                "max_lv": parse_int(row["max_lv"]),
                "time_band": row["time_band"].strip(),
                "weather": row["weather"].strip(),
            }
        )

    for row in zone_rows:
        payload = {
            "zone_id": row["zone_id"].strip(),
            "world_id": row["world_id"].strip(),
            "name_jp": row["name_jp"].strip(),
            "encounter_min_steps": parse_int(row["encounter_min_steps"]),
            "encounter_max_steps": parse_int(row["encounter_max_steps"]),
            "terrain_rate": parse_float(row["terrain_rate"]),
            "time_band": row["time_band"].strip(),
            "weather": row["weather"].strip(),
            "notes": row["notes"].strip(),
            "entries": sorted(encounter_map.get(row["zone_id"].strip(), []), key=lambda entry: entry["slot"]),
        }
        file_name = f'{row["zone_id"].strip().lower().replace("-", "_")}.tres'
        write_resource(
            output_dir / "encounters" / file_name,
            "res://scripts/data/encounter_zone_data.gd",
            "EncounterZoneData",
            payload,
        )
        manifest["encounters"][row["zone_id"].strip()] = f"res://resources/encounters/{file_name}"

    for row in sorted(breed_rows, key=lambda item: (-parse_int(item["priority"]), item["rule_id"].strip())):
        payload = {
            "rule_id": row["rule_id"].strip(),
            "rule_type": row["rule_type"].strip(),
            "parent_a_key": row["parent_a_key"].strip(),
            "parent_b_key": row["parent_b_key"].strip(),
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
