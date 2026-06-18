#!/usr/bin/env bash
# Generates .cursor/commands/<name>.md wrappers from .cursor/skills/*/SKILL.md.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
skills_root="${repo_root}/.cursor/skills"
commands_root="${repo_root}/.cursor/commands"

python3 - <<'PY' "${skills_root}" "${commands_root}"
import re
import sys
import json
from pathlib import Path
from typing import Optional

skills_root = Path(sys.argv[1])
commands_root = Path(sys.argv[2])
commands_root.mkdir(parents=True, exist_ok=True)

FRONTMATTER_RE = re.compile(r"\A---\r?\n(.*?)\r?\n---", re.DOTALL)
TOP_LEVEL_FIELD_RE = re.compile(r"^[A-Za-z0-9_-]+:")


def read_frontmatter(skill_file: Path) -> str:
    text = skill_file.read_text(encoding="utf-8")
    match = FRONTMATTER_RE.match(text)
    if not match:
        raise SystemExit(f"ERROR: {skill_file} has no YAML frontmatter")
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


for skill_file in sorted(skills_root.glob("*/SKILL.md")):
    frontmatter = read_frontmatter(skill_file)
    name = scalar_field(frontmatter, "name")
    description = command_description_field(frontmatter)
    if not name or not description:
        raise SystemExit(f"ERROR: {skill_file} missing name or description")

    folder = skill_file.parent.name
    if name != folder:
        raise SystemExit(
            f"ERROR: {skill_file} name '{name}' must match folder '{folder}'"
        )

    command_path = commands_root / f"{name}.md"
    command_path.write_text(
        f"""---
name: {name}
{description}
---

Read and follow `.cursor/skills/{name}/SKILL.md` completely.
""",
        encoding="utf-8",
    )
    print(f"Wrote {command_path.relative_to(commands_root.parent.parent)}")

print(f"Synced {len(list(skills_root.glob('*/SKILL.md')))} command wrapper(s).")
PY
