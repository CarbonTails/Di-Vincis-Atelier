#!/usr/bin/env bash
# Generates .cursor/commands/<name>.md wrappers from .cursor/skills/*/SKILL.md.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
skills_root="${repo_root}/.cursor/skills"
commands_root="${repo_root}/.cursor/commands"

python3 - <<'PY' "${skills_root}" "${commands_root}"
import re
import sys
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


def field_block(frontmatter: str, field: str) -> Optional[str]:
    lines = frontmatter.splitlines()
    for index, line in enumerate(lines):
        if not line.startswith(f"{field}:"):
            continue

        block = [line]
        value = line.split(":", 1)[1].strip()
        if value.startswith(("|", ">")):
            for next_line in lines[index + 1 :]:
                if next_line and not next_line[0].isspace() and TOP_LEVEL_FIELD_RE.match(next_line):
                    break
                block.append(next_line)

        return "\n".join(block)

    return None


for skill_file in sorted(skills_root.glob("*/SKILL.md")):
    frontmatter = read_frontmatter(skill_file)
    name = scalar_field(frontmatter, "name")
    description = field_block(frontmatter, "description")
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
