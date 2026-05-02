#!/usr/bin/env python3
"""Static checks for the Crystal Saga tutorial series."""

from __future__ import annotations

import re
import sys
from pathlib import Path


TUTORIAL_DIR = Path(__file__).resolve().parents[1]
MODULE_PATTERN = re.compile(r"^(\d{2})_.*\.md$")
REVIEW_MODULES = {4, 8, 13, 19, 23, 27}
CONTENT_MODULES = set(range(1, 28)) - REVIEW_MODULES
BUILDING_EXCEPTIONS = {1, 26}

STALE_TERMS = (
    "tree_changed",
    "Engine.has_singleton",
    "effect_value",
    "scene_name",
    "traveler_fynn",
    "_enemy_to_battler",
    "SceneTree.scene_changed hallucination",
)

STALE_REGEXES = (
    (re.compile(r"\btarget_spawn\b"), "stale exit export name: target_spawn"),
    (re.compile(r"(?<!queue_)free\("), "use queue_free() for tutorial UI cleanup"),
    (
        re.compile(r"scene_file_path\.begins_with\(\"res://scenes/\"\)"),
        "pause menu must use pause_allowed group, not scene path prefix",
    ),
    (re.compile(r"\bcomplete JRPG\b"), "say complete tutorial JRPG vertical slice"),
)

ABILITY_ALLOWED_CONTEXT = (
    "future",
    "extension",
    "intentionally not",
    "not in this implemented",
    "disabled",
    "until",
    "belongs in a future",
)


def is_table_separator(line: str) -> bool:
    stripped = line.strip()
    if not stripped.startswith("|") or not stripped.endswith("|"):
        return False
    return bool(re.fullmatch(r"[|:\-\s]+", stripped))


def numbered_modules() -> list[Path]:
    return sorted(TUTORIAL_DIR.glob("[0-9][0-9]_*.md"))


def module_number(path: Path) -> int:
    match = MODULE_PATTERN.match(path.name)
    if not match:
        raise ValueError(f"not a module filename: {path.name}")
    return int(match.group(1))


def require(condition: bool, errors: list[str], message: str) -> None:
    if not condition:
        errors.append(message)


def check_module_inventory(modules: list[Path], errors: list[str]) -> None:
    numbers = [module_number(path) for path in modules]
    require(len(numbers) == 27, errors, f"expected 27 numbered modules, found {len(numbers)}")
    require(
        numbers == list(range(1, 28)),
        errors,
        f"expected module numbers 01-27, found {numbers}",
    )


def check_content_anatomy(path: Path, text: str, errors: list[str]) -> None:
    number = module_number(path)
    required = [
        "## What We've Learned",
        "## What You Should See",
        "## Next Module",
        "## Engineering Contract",
        "## Engine Gotcha",
    ]
    for heading in required:
        require(heading in text, errors, f"{path.name}: missing heading {heading!r}")

    if number != 1:
        require(
            re.search(r"^## What We (Have|Have So Far)$", text, re.MULTILINE) is not None,
            errors,
            f"{path.name}: missing prior-state heading",
        )

    if number not in BUILDING_EXCEPTIONS:
        require(
            "## What We're Building This Module" in text,
            errors,
            f"{path.name}: missing deliverables heading",
        )


def check_review_anatomy(path: Path, text: str, errors: list[str]) -> None:
    required = [
        "## Key Concepts",
        "## Cheat Sheet",
        "## Common Mistakes and Fixes",
        "## Official Godot Documentation",
    ]
    for heading in required:
        require(heading in text, errors, f"{path.name}: missing review heading {heading!r}")


def check_stale_terms(path: Path, text: str, errors: list[str]) -> None:
    for term in STALE_TERMS:
        if term in text:
            errors.append(f"{path.name}: stale term present: {term}")
    for pattern, message in STALE_REGEXES:
        if pattern.search(text):
            errors.append(f"{path.name}: {message}")


def check_abilitydata_context(path: Path, lines: list[str], errors: list[str]) -> None:
    for index, line in enumerate(lines, start=1):
        if "AbilityData" not in line:
            continue
        lowered = line.lower()
        if not any(marker in lowered for marker in ABILITY_ALLOWED_CONTEXT):
            errors.append(
                f"{path.name}:{index}: AbilityData appears outside a future-extension context"
            )


def check_visible_double_dash(path: Path, lines: list[str], errors: list[str]) -> None:
    in_fenced_block = False
    for index, line in enumerate(lines, start=1):
        if line.startswith("```"):
            in_fenced_block = not in_fenced_block
            continue
        if in_fenced_block:
            continue
        if is_table_separator(line):
            continue
        if "--" in line:
            errors.append(f"{path.name}:{index}: visible double-dash prose or diagram marker")


def main() -> int:
    errors: list[str] = []
    modules = numbered_modules()
    check_module_inventory(modules, errors)

    for path in modules:
        text = path.read_text(encoding="utf-8")
        lines = text.splitlines()
        number = module_number(path)
        if number in CONTENT_MODULES:
            check_content_anatomy(path, text, errors)
        else:
            check_review_anatomy(path, text, errors)

        check_stale_terms(path, text, errors)
        check_abilitydata_context(path, lines, errors)
        check_visible_double_dash(path, lines, errors)

    if errors:
        print("Tutorial checks failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print("Tutorial checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
