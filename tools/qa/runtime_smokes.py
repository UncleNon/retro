from __future__ import annotations

import argparse
import subprocess
import sys

from common import REPO_ROOT, find_executable

SMOKE_SCRIPTS = [
    "tools/qa/save_smoke.py",
    "tools/qa/resource_registry_smoke.py",
    "tools/qa/session04_repository_runtime_smoke.py",
    "tools/qa/session07_runtime_smoke.py",
    "tools/qa/field_smoke.py",
    "tools/qa/field_transition_smoke.py",
    "tools/qa/battle_smoke.py",
    "tools/qa/app_root_facility_interaction_smoke.py",
    "tools/qa/app_root_battle_transition_smoke.py",
    "tools/qa/session08_vertical_slice_smoke.py",
]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--allow-missing", action="store_true")
    args = parser.parse_args()

    godot = find_executable("godot", "godot4")
    if godot is None:
        message = "missing required tool: godot or godot4"
        if args.allow_missing:
            print(f"{message} (allowed)")
            return 0
        print(message, file=sys.stderr)
        return 1

    failures: list[str] = []
    for script in SMOKE_SCRIPTS:
        print(f"running {script}")
        completed = subprocess.run([sys.executable, script], cwd=REPO_ROOT)
        if completed.returncode != 0:
            failures.append(script)

    if failures:
        print(f"runtime smokes failed: {', '.join(failures)}", file=sys.stderr)
        return 1

    print("runtime smokes ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
