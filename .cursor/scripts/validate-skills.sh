#!/usr/bin/env bash
# Validates .cursor/skills/*/SKILL.md frontmatter, layout, and command wrappers.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
skills_root="${repo_root}/.cursor/skills"
commands_root="${repo_root}/.cursor/commands"

if [[ ! -d "${skills_root}" ]]; then
  echo "ERROR: missing ${skills_root}" >&2
  exit 1
fi

python3 - <<'PY' "${skills_root}" "${commands_root}"
import re
import sys
import json
from pathlib import Path
from typing import Optional

skills_root = Path(sys.argv[1])
commands_root = Path(sys.argv[2])
errors = 0

FRONTMATTER_RE = re.compile(r"\A---\r?\n(.*?)\r?\n---", re.DOTALL)
TOP_LEVEL_FIELD_RE = re.compile(r"^[A-Za-z0-9_-]+:")
VALID_NAME_RE = re.compile(r"^[a-z0-9-]+$")


def error(message: str) -> None:
    global errors
    errors += 1
    print(f"ERROR: {message}", file=sys.stderr)


def read_frontmatter(skill_file: Path) -> Optional[str]:
    text = skill_file.read_text(encoding="utf-8")
    match = FRONTMATTER_RE.match(text)
    if not match:
        return None
    return match.group(1)


def scalar_field(frontmatter: str, field: str) -> Optional[str]:
    match = re.search(rf"^{re.escape(field)}:\s*(.+)$", frontmatter, re.M)
    if not match:
        return None
    return match.group(1).strip().strip("\"'")


def description_text(frontmatter: str) -> Optional[str]:
    lines = frontmatter.splitlines()
    for index, line in enumerate(lines):
        if not line.startswith("description:"):
            continue

        value = line.split(":", 1)[1].strip()
        if value.startswith(("|", ">")):
            block_lines = []
            for next_line in lines[index + 1 :]:
                if next_line and not next_line[0].isspace() and TOP_LEVEL_FIELD_RE.match(next_line):
                    break
                stripped_line = next_line.strip()
                if stripped_line:
                    block_lines.append(stripped_line)

            return " ".join(block_lines)

        if value.startswith(('"', "'")):
            import yaml

            return yaml.safe_load(value)

        return value

    return None


def command_description_field(frontmatter: str) -> Optional[str]:
    description = description_text(frontmatter)
    if description is None:
        return None
    return f"description: {json.dumps(description, ensure_ascii=False)}"


def expected_command(name: str, description: str) -> str:
    return f"""---
name: {name}
{description}
---

Read and follow `.cursor/skills/{name}/SKILL.md` completely.
"""


skill_files = sorted(skills_root.glob("*/SKILL.md"))
for skill_file in skill_files:
    frontmatter = read_frontmatter(skill_file)
    if frontmatter is None:
        error(f"{skill_file} has no YAML frontmatter")
        continue

    name = scalar_field(frontmatter, "name")
    description = command_description_field(frontmatter)
    folder_name = skill_file.parent.name

    if not name:
        error(f"{skill_file} is missing required frontmatter field: name")
        continue

    if name != folder_name:
        error(f"{skill_file} name '{name}' must match folder '{folder_name}'")

    if not VALID_NAME_RE.match(name):
        error(f"{skill_file} name '{name}' must be lowercase letters, numbers, and hyphens only")

    if not description:
        error(f"{skill_file} is missing required frontmatter field: description")
        continue

    command_file = commands_root / f"{name}.md"
    if not command_file.exists():
        error(f"no matching slash command at {command_file}")
        continue

    actual_command = command_file.read_text(encoding="utf-8")
    wanted_command = expected_command(name, description)
    if actual_command != wanted_command:
        error(f"{command_file} is out of sync with {skill_file}; run .cursor/scripts/sync-skill-commands.sh")

print(f"Validated {len(skill_files)} skill(s) under {skills_root}")

if errors:
    print(f"{errors} validation error(s)", file=sys.stderr)
    raise SystemExit(1)

print("All skills valid.")
PY
