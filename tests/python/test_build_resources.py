from __future__ import annotations

import shutil
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO_ROOT / "tools" / "data"))

from build_resources import ValidationError, build_all  # noqa: E402


class BuildResourcesTest(unittest.TestCase):
    def test_build_all_creates_expected_counts(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            result = build_all(REPO_ROOT / "data" / "csv", Path(temp_dir) / "resources")

        self.assertEqual(result["counts"]["monsters"], 10)
        self.assertEqual(result["counts"]["skills"], 36)
        self.assertEqual(result["counts"]["items"], 14)
        self.assertEqual(result["counts"]["worlds"], 4)
        self.assertEqual(result["counts"]["encounters"], 5)
        self.assertEqual(result["counts"]["breeding"], 8)

    def test_invalid_skill_reference_fails_validation(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            csv_dir = Path(temp_dir) / "csv"
            shutil.copytree(REPO_ROOT / "data" / "csv", csv_dir)

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


if __name__ == "__main__":
    unittest.main()
