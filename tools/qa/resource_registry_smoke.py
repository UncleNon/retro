from __future__ import annotations

import sys

from common import find_executable, run


def main() -> int:
    godot = find_executable("godot", "godot4")
    if godot is None:
        print("missing required tool: godot or godot4", file=sys.stderr)
        return 1

    return run(
        [
            godot,
            "--headless",
            "--path",
            ".",
            "--script",
            "res://tests/gdscript/resource_registry_smoke.gd",
        ]
    )


if __name__ == "__main__":
    raise SystemExit(main())
