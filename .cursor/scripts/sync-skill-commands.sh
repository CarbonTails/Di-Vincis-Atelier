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

skills_root = Path(sys.argv[1])
commands_root = Path(sys.argv[2])
commands_root.mkdir(parents=True, exist_ok=True)

for skill_file in sorted(skills_root.glob("*/SKILL.md")):
    text = skill_file.read_text(encoding="utf-8")
    match = re.match(r"^---\n(.*?)\n---", text, re.DOTALL)
    if not match:
        raise SystemExit(f"ERROR: {skill_file} has no YAML frontmatter")

    fm = match.group(1)
    name_m = re.search(r"^name:\s*(.+)$", fm, re.M)
    desc_m = re.search(r"^description:\s*(.+)$", fm, re.M)
    if not name_m or not desc_m:
        raise SystemExit(f"ERROR: {skill_file} missing name or description")

    name = name_m.group(1).strip().strip("\"'")
    description = desc_m.group(1).strip().strip("\"'")
    folder = skill_file.parent.name
    if name != folder:
        raise SystemExit(
            f"ERROR: {skill_file} name '{name}' must match folder '{folder}'"
        )

    command_path = commands_root / f"{name}.md"
    command_path.write_text(
        f"""---
name: {name}
description: {description}
---

Read and follow `.cursor/skills/{name}/SKILL.md` completely.
""",
        encoding="utf-8",
    )
    print(f"Wrote {command_path.relative_to(commands_root.parent.parent)}")

print(f"Synced {len(list(skills_root.glob('*/SKILL.md')))} command wrapper(s).")
PY
