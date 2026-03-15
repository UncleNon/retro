from __future__ import annotations

import argparse
import sys

from common import GDSCRIPT_TARGETS, existing_targets, find_executable, print_missing_tool, run


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()

    executable = find_executable("gdformat")
    if executable is None:
        return print_missing_tool("gdformat", "gdtoolkit")

    targets = existing_targets(GDSCRIPT_TARGETS)
    if not targets:
        print("no GDScript targets found")
        return 0

    command = [executable]
    if args.check:
        command.append("--check")
    command.extend(targets)
    return run(command)


if __name__ == "__main__":
    sys.exit(main())
