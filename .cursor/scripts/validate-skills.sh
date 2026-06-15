#!/usr/bin/env bash
# Validates .cursor/skills/*/SKILL.md frontmatter and layout.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
skills_root="${repo_root}/.cursor/skills"
errors=0

if [[ ! -d "${skills_root}" ]]; then
  echo "ERROR: missing ${skills_root}" >&2
  exit 1
fi

while IFS= read -r -d '' skill_file; do
  skill_dir="$(dirname "${skill_file}")"
  folder_name="$(basename "${skill_dir}")"

  frontmatter="$(python3 - <<'PY' "${skill_file}"
import re
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text(encoding="utf-8")
match = re.match(r"^---\n(.*?)\n---", text, re.DOTALL)
if not match:
    sys.exit(0)
print(match.group(1), end="")
PY
)"

  if [[ -z "${frontmatter}" ]]; then
    echo "ERROR: ${skill_file} has no YAML frontmatter" >&2
    errors=$((errors + 1))
    continue
  fi

  name="$(printf '%s\n' "${frontmatter}" | awk -F': ' '/^name: / { print $2; exit }' | tr -d '\r' | sed 's/^["'\'']//; s/["'\'']$//')"
  description="$(printf '%s\n' "${frontmatter}" | awk -F': ' '/^description: / { print substr($0, index($0, ": ") + 2); exit }' | tr -d '\r' | sed 's/^["'\'']//; s/["'\'']$//')"

  if [[ -z "${name}" ]]; then
    echo "ERROR: ${skill_file} is missing required frontmatter field: name" >&2
    errors=$((errors + 1))
  elif [[ "${name}" != "${folder_name}" ]]; then
    echo "ERROR: ${skill_file} name '${name}' must match folder '${folder_name}'" >&2
    errors=$((errors + 1))
  elif ! [[ "${name}" =~ ^[a-z0-9-]+$ ]]; then
    echo "ERROR: ${skill_file} name '${name}' must be lowercase letters, numbers, and hyphens only" >&2
    errors=$((errors + 1))
  fi

  if [[ -z "${description}" ]]; then
    echo "ERROR: ${skill_file} is missing required frontmatter field: description" >&2
    errors=$((errors + 1))
  fi

  command_file="${repo_root}/.cursor/commands/${name}.md"
  if [[ ! -f "${command_file}" ]]; then
    echo "WARN: no matching slash command at ${command_file}" >&2
  fi
done < <(find "${skills_root}" -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' -print0 | sort -z)

skill_count="$(find "${skills_root}" -mindepth 2 -maxdepth 2 -type f -name 'SKILL.md' | wc -l | tr -d ' ')"
echo "Validated ${skill_count} skill(s) under ${skills_root}"

if [[ "${errors}" -gt 0 ]]; then
  echo "${errors} validation error(s)" >&2
  exit 1
fi

echo "All skills valid."
