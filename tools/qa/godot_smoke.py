from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

from common import REPO_ROOT, find_executable


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--allow-missing", action="store_true")
    args = parser.parse_args()

    executable = find_executable("godot", "godot4")
    if executable is None:
        message = "missing required tool: godot or godot4"
        if args.allow_missing:
            print(f"{message} (allowed)")
            return 0
        print(message, file=sys.stderr)
        return 1

    project_file = REPO_ROOT / "project.godot"
    if not project_file.exists():
        print(f"missing project file: {project_file}", file=sys.stderr)
        return 1

    completed = subprocess.run(
        [executable, "--headless", "--path", str(REPO_ROOT), "--quit"],
        cwd=REPO_ROOT,
    )
    return completed.returncode


if __name__ == "__main__":
    sys.exit(main())
