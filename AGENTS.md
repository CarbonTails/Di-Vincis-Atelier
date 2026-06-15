# Di-Vincis-Atelier

Project instructions for AI agents working in this repository.

## Overview

Di-Vincis-Atelier is a creative workspace project. Follow existing conventions in the codebase as they emerge.

## Code style

- Write clear, self-documenting code with meaningful names
- Prefer small, focused changes over large refactors
- Match the style and patterns of surrounding files
- Add comments only for non-obvious logic

## Git workflow

- Create feature branches off `main`
- Write descriptive commit messages in complete sentences
- Keep commits focused on a single logical change

## Development

Add project-specific install, build, and test commands here as the stack is chosen.

```bash
# Example placeholders — update when tooling is added
# pnpm install
# pnpm dev
# pnpm test
```

## Cursor configuration

- `.cursor/rules/*.mdc` — project rules (structured, with frontmatter).
- `.cursor/commands/*.md` — reusable slash-command prompts (desktop fallback).
- `.cursor/skills/<name>/SKILL.md` — agent skills (source of truth; works on desktop and Cloud).
- `.cursor/scripts/validate-skills.sh` — validates skill frontmatter and folder layout.
- `.cursor/scripts/sync-skill-commands.sh` — regenerates command wrappers from skills.

## Agent skills (desktop + Cloud)

Project skills live under `.cursor/skills/<name>/SKILL.md`. Each skill has a matching
slash command at `.cursor/commands/<name>.md` that delegates to the skill file.

Invoke in Agent chat with `/` followed by the skill name, for example
`/grill-with-docs`, `/tdd`, or `/review-code`. Run
`.cursor/scripts/validate-skills.sh` to verify frontmatter and command parity.

Cloud note: cursor.com/agents loads repo skills from `.cursor/skills/`. Skills are
the source of truth on web; matching commands under `.cursor/commands/` provide a
desktop fallback. If the `/` menu is empty on a Cloud follow-up message, start a
new chat or say "use the `<name>` skill" in plain text.

After adding or changing skills, run `.cursor/scripts/sync-skill-commands.sh` and
`.cursor/scripts/validate-skills.sh`, then reload the Cursor window (desktop) or
start a new Cloud agent (web).

## Cursor Cloud specific instructions

- Use `npx convex dev` for Convex development (never `npx convex deploy` during development)
- Set `CONVEX_AGENT_MODE=anonymous` in cloud agent environments when working with Convex
