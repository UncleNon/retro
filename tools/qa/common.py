from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path
from typing import Sequence

REPO_ROOT = Path(__file__).resolve().parents[2]
GDSCRIPT_TARGETS = [
    REPO_ROOT / "scripts",
    REPO_ROOT / "scenes",
    REPO_ROOT / "addons",
]


def existing_targets(paths: Sequence[Path]) -> list[str]:
    return [str(path) for path in paths if path.exists()]


def find_executable(*names: str) -> str | None:
    user_python_bin = Path.home() / "Library" / "Python" / f"{sys.version_info.major}.{sys.version_info.minor}" / "bin"
    for name in names:
        resolved = shutil.which(name)
        if resolved:
            return resolved
        candidate = user_python_bin / name
        if candidate.exists():
            return str(candidate)
    return None


def run(command: Sequence[str]) -> int:
    completed = subprocess.run(command, cwd=REPO_ROOT)
    return completed.returncode


def print_missing_tool(tool_name: str, package_hint: str) -> int:
    print(
        f"missing required tool: {tool_name}\n"
        f"install hint: python3 -m pip install {package_hint}",
        file=sys.stderr,
    )
    return 1
