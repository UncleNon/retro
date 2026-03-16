from __future__ import annotations

import csv
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO_ROOT / "tools" / "data"))

from build_resources import ValidationError, build_all  # noqa: E402


class BuildResourcesTest(unittest.TestCase):
    def _read_csv_rows(self, name: str) -> list[dict[str, str]]:
        path = REPO_ROOT / "data" / "csv" / name
        with path.open("r", encoding="utf-8", newline="") as handle:
            return list(csv.DictReader(handle))

    def _stage_project_fixture(self, temp_dir: str) -> Path:
        project_root = Path(temp_dir)
        shutil.copytree(REPO_ROOT / "data" / "csv", project_root / "data" / "csv")
        shutil.copytree(REPO_ROOT / "data" / "localization", project_root / "data" / "localization")
        return project_root / "data" / "csv"

    def test_build_all_creates_expected_counts(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            output_dir = Path(temp_dir) / "resources"
            result = build_all(REPO_ROOT / "data" / "csv", output_dir)
            self.assertEqual(
                result["counts"],
                {
                    "monsters": len(self._read_csv_rows("monster_master.csv")),
                    "skills": len(self._read_csv_rows("skill_master.csv")),
                    "items": len(self._read_csv_rows("item_master.csv")),
                    "worlds": len(self._read_csv_rows("world_master.csv")),
                    "encounters": len(self._read_csv_rows("zone_master.csv")),
                    "breeding": len(self._read_csv_rows("breed_rule.csv")),
                    "npcs": len(self._read_csv_rows("npc_master.csv")),
                    "shops": len(self._read_csv_rows("shop_master.csv")),
                    "services": len(self._read_csv_rows("service_master.csv")),
                    "loot_tables": len(self._read_csv_rows("loot_table_master.csv")),
                },
            )
            self.assertIn("W-001", result["manifest"]["worlds"])
            self.assertIn("W-021", result["manifest"]["worlds"])
            self.assertIn("MON-504", result["manifest"]["monsters"])
            self.assertIn("item_key_towerwrit", result["manifest"]["items"])
            self.assertIn("ZONE-W21-EDGE", result["manifest"]["encounters"])
            self.assertIn("BRD-3025", result["manifest"]["breeding"])
            self.assertIn("NPC-VIL-013", result["manifest"]["npcs"])
            self.assertIn("shop_vil_general", result["manifest"]["shops"])
            self.assertIn("service_vil_restoration", result["manifest"]["services"])
            self.assertIn("loot_monster_mokkeda", result["manifest"]["loot_tables"])

            snow_zone = (output_dir / "encounters" / "zone_w09_snow.tres").read_text(encoding="utf-8")
            self.assertIn('bgm_id = "BGM-W009-FIELD"', snow_zone)
            self.assertIn("is_dungeon = false", snow_zone)
            self.assertIn('time_band = "day"', snow_zone)
            self.assertIn('weather = "snow"', snow_zone)

            cave_zone = (output_dir / "encounters" / "zone_w09_cave.tres").read_text(encoding="utf-8")
            self.assertIn("is_dungeon = true", cave_zone)

            family_rule = (output_dir / "breeding" / "brd_0101.tres").read_text(encoding="utf-8")
            self.assertIn('parent_a_key = "family:beast"', family_rule)
            self.assertIn('parent_b_key = "family:bird"', family_rule)

            monster_resource = (output_dir / "monsters" / "mokkeda.tres").read_text(encoding="utf-8")
            self.assertIn('loot_table_id = "loot_monster_mokkeda"', monster_resource)

            npc_resource = (output_dir / "npcs" / "npc_vil_013.tres").read_text(encoding="utf-8")
            self.assertIn('scope_id = "VIL"', npc_resource)
            self.assertIn('shop_id = "shop_vil_general"', npc_resource)
            self.assertIn("x = 50", npc_resource)

            shop_resource = (output_dir / "shops" / "vil_clinic.tres").read_text(encoding="utf-8")
            self.assertIn('service_ids = ["service_vil_restoration"]', shop_resource)
            self.assertIn('inventory_entries = [', shop_resource)

            service_resource = (output_dir / "services" / "vil_restoration.tres").read_text(encoding="utf-8")
            self.assertIn('scope_id = "VIL"', service_resource)
            self.assertIn("uses_per_reset = null", service_resource)

            loot_resource = (output_dir / "loot_tables" / "monster_mokkeda.tres").read_text(encoding="utf-8")
            self.assertIn('source_ref = "MON-001"', loot_resource)
            self.assertIn('grant_id": "item_bait_bellgrain"', loot_resource)

    def test_invalid_skill_reference_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            learnset_path = csv_dir / "monster_learnset.csv"
            lines = learnset_path.read_text(encoding="utf-8").splitlines()
            lines.append("MON-001,level,20,SKL-999")
            learnset_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_build_all_preserves_unmanaged_resource_directories(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            output_dir = Path(temp_dir) / "resources"
            keep_dir = output_dir / "manual_notes"
            keep_dir.mkdir(parents=True)
            marker = keep_dir / "keep.txt"
            marker.write_text("preserve me\n", encoding="utf-8")

            build_all(REPO_ROOT / "data" / "csv", output_dir)

            self.assertTrue(marker.exists())

    def test_invalid_family_selector_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            breed_rule_path = csv_dir / "breed_rule.csv"
            lines = breed_rule_path.read_text(encoding="utf-8").splitlines()
            lines.append("BRD-9999,family,family:bogus,family:bird,MON-001,1,0,10,invalid family selector")
            breed_rule_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_invalid_npc_clue_reference_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            npc_path = csv_dir / "npc_master.csv"
            lines = npc_path.read_text(encoding="utf-8").splitlines()
            lines.append(
                'NPC-TEST-001,W-001,テスト,Test,調査員,invalid clue ref,1,1,down,key,1,CL-999,,,note,dialogue,notes'
            )
            npc_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_invalid_npc_shop_alias_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            npc_path = csv_dir / "npc_master.csv"
            npc_text = npc_path.read_text(encoding="utf-8")
            npc_text = npc_text.replace("SHP-VIL-001", "SHP-VIL-999", 1)
            npc_path.write_text(npc_text, encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_invalid_monster_loot_alias_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            monster_path = csv_dir / "monster_master.csv"
            monster_text = monster_path.read_text(encoding="utf-8")
            monster_text = monster_text.replace("LUT-001", "LUT-999", 1)
            monster_path.write_text(monster_text, encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_invalid_monster_slug_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            monster_path = csv_dir / "monster_master.csv"
            monster_text = monster_path.read_text(encoding="utf-8")
            monster_text = monster_text.replace("mokkeda", "Mokkeda", 1)
            monster_path.write_text(monster_text, encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_mismatched_npc_shop_service_pair_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            npc_path = csv_dir / "npc_master.csv"
            npc_text = npc_path.read_text(encoding="utf-8")
            npc_text = npc_text.replace("SVC-VIL-HEAL", "SVC-W07-BREED", 1)
            npc_path.write_text(npc_text, encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_invalid_alias_target_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            alias_path = csv_dir / "entity_alias_master.csv"
            alias_text = alias_path.read_text(encoding="utf-8")
            alias_text = alias_text.replace("shop_vil_general", "shop_missing", 1)
            alias_path.write_text(alias_text, encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_missing_gate_row_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            gate_path = csv_dir / "progress_gate_master.csv"
            lines = gate_path.read_text(encoding="utf-8").splitlines()
            gate_path.write_text("\n".join(lines[:-1]) + "\n", encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_invalid_gate_item_reference_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            gate_path = csv_dir / "progress_gate_master.csv"
            gate_text = gate_path.read_text(encoding="utf-8")
            for original in ("item_key_offering_bundle", "item_key_memorialoffering"):
                if original in gate_text:
                    gate_text = gate_text.replace(original, "item_key_missing", 1)
                    break
            gate_path.write_text(gate_text, encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_invalid_world_dependency_gate_reference_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            dependency_path = csv_dir / "world_dependency_map.csv"
            dependency_text = dependency_path.read_text(encoding="utf-8")
            for original, replacement in (("GATE-W-021", "GATE-W-999"), ("GATE-021", "GATE-999")):
                if original in dependency_text:
                    dependency_text = dependency_text.replace(original, replacement, 1)
                    break
            dependency_path.write_text(dependency_text, encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_invalid_field_trigger_rect_reference_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            trigger_path = csv_dir / "field_trigger_master.csv"
            trigger_text = trigger_path.read_text(encoding="utf-8")
            trigger_text = trigger_text.replace("rect_encounter", "rect_missing", 1)
            trigger_path.write_text(trigger_text, encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_invalid_field_interaction_clue_reference_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            interaction_path = csv_dir / "field_interaction_master.csv"
            interaction_text = interaction_path.read_text(encoding="utf-8")
            interaction_text = interaction_text.replace("CL-005", "CL-999", 1)
            interaction_path.write_text(interaction_text, encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_invalid_field_scene_world_reference_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            field_scene_path = csv_dir / "field_scene_master.csv"
            field_scene_text = field_scene_path.read_text(encoding="utf-8")
            field_scene_text = field_scene_text.replace("W-001", "W-999", 1)
            field_scene_path.write_text(field_scene_text, encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_invalid_item_text_item_reference_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            item_text_path = csv_dir / "item_text_master.csv"
            item_text = item_text_path.read_text(encoding="utf-8")
            item_text = item_text.replace("item_heal_dryherb", "item_missing", 1)
            item_text_path.write_text(item_text, encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_invalid_shop_voice_without_scope_or_shop_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            item_text_path = csv_dir / "item_text_master.csv"
            lines = item_text_path.read_text(encoding="utf-8").splitlines()
            lines.append(
                "ITXT-999,item_record_tagcase,shop_voice,,,ITX-TEST:voice,10,「売り文句が宙に浮く。」,invalid shop voice"
            )
            item_text_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_unregistered_master_file_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            master_index_path = csv_dir / "master_index.csv"
            lines = master_index_path.read_text(encoding="utf-8").splitlines()
            filtered_lines = [line for line in lines if "clue_master.csv" not in line]
            master_index_path.write_text("\n".join(filtered_lines) + "\n", encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")

    def test_missing_localization_key_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = self._stage_project_fixture(temp_dir)

            registry_path = csv_dir / "localization_registry.csv"
            registry_text = registry_path.read_text(encoding="utf-8")
            registry_text = registry_text.replace("scope.VIL.name", "scope.VIL.label", 1)
            registry_path.write_text(registry_text, encoding="utf-8")

            with self.assertRaises(ValidationError):
                build_all(csv_dir, Path(temp_dir) / "resources")


if __name__ == "__main__":
    unittest.main()
