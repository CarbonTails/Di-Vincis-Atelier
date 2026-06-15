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

## Cursor Cloud specific instructions

- Use `npx convex dev` for Convex development (never `npx convex deploy` during development)
- Set `CONVEX_AGENT_MODE=anonymous` in cloud agent environments when working with Convex
