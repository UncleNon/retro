from __future__ import annotations

import sys

from common import GDSCRIPT_TARGETS, existing_targets, find_executable, print_missing_tool, run


def main() -> int:
    executable = find_executable("gdlint")
    if executable is None:
        return print_missing_tool("gdlint", "gdtoolkit")

    targets = existing_targets(GDSCRIPT_TARGETS)
    if not targets:
        print("no GDScript targets found")
        return 0

    return run([executable, *targets])


if __name__ == "__main__":
    sys.exit(main())
