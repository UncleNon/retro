from __future__ import annotations

import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

from common import REPO_ROOT, find_executable

REPORT_DIR = REPO_ROOT / "export" / "ios"
REPORT_JSON = REPORT_DIR / "ios_export_smoke_report.json"
REPORT_MD = REPORT_DIR / "ios_export_smoke_report.md"
EXPORT_PRESETS = REPO_ROOT / "export_presets.cfg"


def run_capture(command: list[str]) -> tuple[int, str]:
    completed = subprocess.run(
        command,
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
    )
    output = "\n".join(
        part.strip()
        for part in [completed.stdout, completed.stderr]
        if part.strip()
    )
    return completed.returncode, output


def inspect_export_templates() -> dict[str, object]:
    candidate_dirs = [
        Path.home() / "Library" / "Application Support" / "Godot" / "export_templates",
        Path.home() / ".local" / "share" / "godot" / "export_templates",
    ]

    directories = [path for path in candidate_dirs if path.exists()]
    entries: list[str] = []
    for directory in directories:
        entries.extend(sorted(child.name for child in directory.iterdir()))

    return {
        "directories": [str(path) for path in directories],
        "entries": entries,
        "available": bool(entries),
    }


def inspect_export_presets() -> dict[str, object]:
    if not EXPORT_PRESETS.exists():
        return {
            "exists": False,
            "ios_preset_present": False,
            "path": str(EXPORT_PRESETS),
        }

    content = EXPORT_PRESETS.read_text(encoding="utf-8")
    return {
        "exists": True,
        "ios_preset_present": 'platform="iOS"' in content or 'platform="IOS"' in content,
        "path": str(EXPORT_PRESETS),
    }


def inspect_codesigning() -> dict[str, object]:
    security = find_executable("security")
    if security is None:
        return {
            "tool_found": False,
            "identity_count": 0,
            "raw_output": "security command not found",
        }

    returncode, output = run_capture([security, "find-identity", "-v", "-p", "codesigning"])
    identity_count = 0
    for line in output.splitlines():
        if '"' in line and ")" in line:
            identity_count += 1

    return {
        "tool_found": True,
        "command_exit_code": returncode,
        "identity_count": identity_count,
        "raw_output": output,
    }


def inspect_tool(name: str, *aliases: str) -> dict[str, object]:
    executable = find_executable(name, *aliases)
    if executable is None:
        return {
            "found": False,
            "path": "",
            "version_output": "",
        }

    version_args = [executable, "--version"]
    if Path(executable).name == "xcodebuild":
        version_args = [executable, "-version"]

    returncode, output = run_capture(version_args)
    return {
        "found": True,
        "path": executable,
        "version_exit_code": returncode,
        "version_output": output,
    }


def build_report() -> dict[str, object]:
    godot = inspect_tool("godot", "godot4")
    xcodebuild = inspect_tool("xcodebuild")
    export_templates = inspect_export_templates()
    export_presets = inspect_export_presets()
    codesigning = inspect_codesigning()

    blockers: list[str] = []
    warnings: list[str] = []

    if not godot["found"]:
        blockers.append("Godot editor が見つからない")
    if not xcodebuild["found"]:
        blockers.append("Xcode CLI (`xcodebuild`) が見つからない")
    if not export_templates["available"]:
        blockers.append("Godot export templates が未導入")
    if not export_presets["exists"]:
        blockers.append("`export_presets.cfg` が未作成")
    elif not export_presets["ios_preset_present"]:
        blockers.append("`export_presets.cfg` に iOS preset がない")
    if codesigning["tool_found"] and codesigning["identity_count"] == 0:
        blockers.append("codesigning identity が未設定")
    if not codesigning["tool_found"]:
        blockers.append("`security` コマンドが見つからず codesigning 状態を確認できない")

    if godot["found"] and "4.6.1" in str(godot["version_output"]):
        warnings.append("ローカル検証は Godot 4.6.1 editor 上で実施")

    status = "ready_for_signed_export" if not blockers else "blocked"
    next_steps: list[str] = []
    if not export_templates["available"]:
        next_steps.append("Godot export templates をインストールする")
    if not export_presets["exists"]:
        next_steps.append("`export_presets.cfg` を追加し、iOS preset を定義する")
    elif not export_presets["ios_preset_present"]:
        next_steps.append("`export_presets.cfg` に iOS preset を追加する")
    if not codesigning["tool_found"]:
        next_steps.append("`security` コマンドを使える macOS 環境で codesigning 状態を確認する")
    elif codesigning["identity_count"] == 0:
        next_steps.append("Apple Developer Program の署名証明書 / Provisioning Profile を用意する")
    next_steps.append("iCloud は local save loop が安定した後に別スパイクで評価する")

    return {
        "checked_at_utc": datetime.now(timezone.utc).isoformat(),
        "status": status,
        "project_root": str(REPO_ROOT),
        "project_file_present": (REPO_ROOT / "project.godot").exists(),
        "tooling": {
            "godot": godot,
            "xcodebuild": xcodebuild,
            "security": {
                "found": codesigning["tool_found"],
            },
        },
        "export_templates": export_templates,
        "export_presets": export_presets,
        "codesigning": codesigning,
        "blockers": blockers,
        "warnings": warnings,
        "next_steps": next_steps,
    }


def write_report(report: dict[str, object]) -> None:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    REPORT_JSON.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    lines = [
        "# iOS Export Smoke Report",
        "",
        f"- Checked At (UTC): `{report['checked_at_utc']}`",
        f"- Status: `{report['status']}`",
        "",
        "## Blockers",
        "",
    ]

    blockers: list[str] = report["blockers"]  # type: ignore[assignment]
    if blockers:
        lines.extend(f"- {blocker}" for blocker in blockers)
    else:
        lines.append("- なし")

    lines.extend(
        [
            "",
            "## Warnings",
            "",
        ]
    )

    warnings: list[str] = report["warnings"]  # type: ignore[assignment]
    if warnings:
        lines.extend(f"- {warning}" for warning in warnings)
    else:
        lines.append("- なし")

    lines.extend(
        [
            "",
            "## Tooling",
            "",
            f"- Godot: `{report['tooling']['godot']['version_output'] or 'missing'}`",
            f"- Xcode: `{report['tooling']['xcodebuild']['version_output'] or 'missing'}`",
            f"- Export Templates Present: `{report['export_templates']['available']}`",
            f"- export_presets.cfg Present: `{report['export_presets']['exists']}`",
            f"- iOS Preset Present: `{report['export_presets']['ios_preset_present']}`",
            f"- Codesigning Identities: `{report['codesigning']['identity_count']}`",
            "",
            "## Next Steps",
            "",
        ]
    )

    lines.extend(f"- {step}" for step in report["next_steps"])  # type: ignore[arg-type]
    REPORT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    report = build_report()
    write_report(report)
    print(f"ios export smoke: {report['status']}")
    print(f"report: {REPORT_JSON}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
