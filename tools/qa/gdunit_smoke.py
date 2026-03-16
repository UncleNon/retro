from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

from common import REPO_ROOT, find_executable

GDSCRIPT_TEST_DIR = REPO_ROOT / "tests" / "gdunit"
PLUGIN_DIR_CANDIDATES = [
    REPO_ROOT / "addons" / "gdUnit4",
    REPO_ROOT / "addons" / "gdunit4",
]
REPORT_DIR = REPO_ROOT / "export" / "gdunit"
REPORT_JSON = REPORT_DIR / "gdunit_smoke_report.json"
REPORT_MD = REPORT_DIR / "gdunit_smoke_report.md"
SUITE_FILE_PATTERNS = ("test_*.gd", "*_test.gd")
TEST_FUNC_PATTERN = re.compile(r"^\s*func\s+test_[A-Za-z0-9_]+\s*\(", re.MULTILINE)


def find_plugin_root() -> Path | None:
    for candidate in PLUGIN_DIR_CANDIDATES:
        if candidate.exists():
            return candidate
    return None


def find_test_suites() -> list[Path]:
    suite_paths: set[Path] = set()
    for pattern in SUITE_FILE_PATTERNS:
        suite_paths.update(path for path in GDSCRIPT_TEST_DIR.glob(pattern) if path.is_file())

    valid_suites: list[Path] = []
    for path in sorted(suite_paths):
        source = path.read_text(encoding="utf-8")
        if "GdUnitTestSuite" not in source:
            continue
        if TEST_FUNC_PATTERN.search(source) is None:
            continue
        valid_suites.append(path)
    return valid_suites


def build_report(allow_missing: bool) -> dict[str, object]:
    plugin_root = find_plugin_root()
    suites = find_test_suites()
    godot = find_executable("godot", "godot4")

    blockers: list[str] = []
    warnings: list[str] = []
    next_steps: list[str] = []
    runner_result: dict[str, object] = {
        "attempted": False,
        "exit_code": None,
        "output": "",
    }

    if not suites:
        blockers.append("`tests/gdunit/` に GdUnit suite がない")
        next_steps.append("`tests/gdunit/` に canonical suite を追加する")

    runtest = plugin_root / "runtest.sh" if plugin_root is not None else None
    if plugin_root is None:
        blockers.append("`addons/gdUnit4` plugin が未導入")
        next_steps.append("local Godot version と互換のある GdUnit4 plugin を `addons/gdUnit4` に導入する")
    elif not runtest.exists():
        blockers.append(f"GdUnit4 command runner が見つからない: `{runtest}`")
        next_steps.append("GdUnit4 plugin を `runtest.sh` を含む配布物へ更新する")

    if godot is None:
        blockers.append("Godot editor が見つからない")
        next_steps.append("Godot editor をインストールする")

    if suites and plugin_root is None:
        warnings.append("canonical suite は repo に追加済みだが、plugin 未導入のため未実行")

    status = "blocked"
    if suites and plugin_root is None and godot is not None:
        status = "scaffolded_plugin_missing"
    elif not blockers and godot is not None and runtest is not None:
        env = os.environ.copy()
        env["GODOT_BIN"] = godot
        completed = subprocess.run(
            [str(runtest), "-a", "res://tests/gdunit"],
            cwd=REPO_ROOT,
            env=env,
            capture_output=True,
            text=True,
        )
        output = "\n".join(
            part.strip()
            for part in [completed.stdout, completed.stderr]
            if part.strip()
        )
        runner_result = {
            "attempted": True,
            "exit_code": completed.returncode,
            "output": output,
        }
        status = "passed" if completed.returncode == 0 else "failed"
        if completed.returncode != 0:
            blockers.append("GdUnit suite 実行が失敗した")

    if status == "passed":
        next_steps.append("GdUnit suite を CI に組み込み、runtime smoke と並行運用する")
    elif status == "scaffolded_plugin_missing":
        next_steps.append("plugin 導入後に `python3 tools/qa/gdunit_smoke.py` を再実行する")
    elif not next_steps:
        next_steps.append("blocker を解消して `python3 tools/qa/gdunit_smoke.py` を再実行する")

    suite_paths = [path.relative_to(REPO_ROOT).as_posix() for path in suites]
    return {
        "checked_at_utc": datetime.now(timezone.utc).isoformat(),
        "status": status,
        "allow_missing": allow_missing,
        "project_root": str(REPO_ROOT),
        "tests": {
            "directory": str(GDSCRIPT_TEST_DIR),
            "count": len(suite_paths),
            "paths": suite_paths,
        },
        "plugin": {
            "present": plugin_root is not None,
            "path": str(plugin_root) if plugin_root is not None else "",
            "runtest_path": str(runtest) if runtest is not None else "",
            "runtest_present": bool(runtest is not None and runtest.exists()),
        },
        "godot": {
            "found": godot is not None,
            "path": godot or "",
        },
        "runner": runner_result,
        "blockers": blockers,
        "warnings": warnings,
        "next_steps": next_steps,
    }


def write_report(report: dict[str, object]) -> None:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    REPORT_JSON.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# GdUnit Smoke Report",
        "",
        f"- Checked At (UTC): `{report['checked_at_utc']}`",
        f"- Status: `{report['status']}`",
        f"- Suites: `{report['tests']['count']}`",
        "",
        "## Blockers",
        "",
    ]

    blockers: list[str] = report["blockers"]  # type: ignore[assignment]
    if blockers:
        lines.extend(f"- {blocker}" for blocker in blockers)
    else:
        lines.append("- なし")

    lines.extend(["", "## Warnings", ""])
    warnings: list[str] = report["warnings"]  # type: ignore[assignment]
    if warnings:
        lines.extend(f"- {warning}" for warning in warnings)
    else:
        lines.append("- なし")

    lines.extend(["", "## Suites", ""])
    suite_paths: list[str] = report["tests"]["paths"]  # type: ignore[index]
    if suite_paths:
        lines.extend(f"- `{path}`" for path in suite_paths)
    else:
        lines.append("- なし")

    lines.extend(
        [
            "",
            "## Tooling",
            "",
            f"- Godot Found: `{report['godot']['found']}`",
            f"- GdUnit Plugin Present: `{report['plugin']['present']}`",
            f"- GdUnit Runner Present: `{report['plugin']['runtest_present']}`",
            f"- Runner Attempted: `{report['runner']['attempted']}`",
        ]
    )

    runner_output = str(report["runner"]["output"])
    if runner_output:
        lines.extend(["", "## Runner Output", "", "```text", runner_output, "```"])

    lines.extend(["", "## Next Steps", ""])
    lines.extend(f"- {step}" for step in report["next_steps"])  # type: ignore[arg-type]
    REPORT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def exit_code_for_report(report: dict[str, object], allow_missing: bool) -> int:
    status = str(report["status"])
    if status in ["passed", "scaffolded_plugin_missing"]:
        return 0
    if allow_missing and status == "blocked":
        return 0
    return 1


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--allow-missing", action="store_true")
    args = parser.parse_args()

    report = build_report(args.allow_missing)
    write_report(report)
    print(f"gdunit smoke: {report['status']}")
    print(f"report: {REPORT_JSON}")
    return exit_code_for_report(report, args.allow_missing)


if __name__ == "__main__":
    sys.exit(main())
