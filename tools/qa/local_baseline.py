from __future__ import annotations

import argparse
import subprocess
import sys

from common import REPO_ROOT

BASELINE_COMMANDS = [
    ["tools/data/build_resources.py"],
    ["tools/qa/test.py"],
    ["tools/qa/gdunit_smoke.py"],
    ["tools/qa/runtime_smokes.py"],
    ["tools/qa/godot_smoke.py"],
    ["tools/qa/ios_export_smoke.py"],
]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--allow-missing", action="store_true")
    args = parser.parse_args()

    failures: list[str] = []
    for command in BASELINE_COMMANDS:
        full_command = [sys.executable] + command
        if args.allow_missing and command[0] in {
            "tools/qa/gdunit_smoke.py",
            "tools/qa/runtime_smokes.py",
            "tools/qa/godot_smoke.py",
        }:
            full_command.append("--allow-missing")
        print("running", " ".join(full_command))
        completed = subprocess.run(full_command, cwd=REPO_ROOT)
        if completed.returncode != 0:
            failures.append(command[0])

    if failures:
        print(f"local baseline failed: {', '.join(failures)}", file=sys.stderr)
        return 1

    print("local baseline ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
