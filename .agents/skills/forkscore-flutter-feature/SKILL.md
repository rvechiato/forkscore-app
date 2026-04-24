---
name: forkscore-flutter-feature
description: Use when building or updating ForkScore Flutter features, screens, tests, and shared UI while preserving the app structure for web and mobile.
---

# ForkScore Flutter Feature

This skill guides frontend work in ForkScore.

## Structure

Work within:

- `lib/app/`
- `lib/features/`
- `lib/shared/`

## Rules

- Keep feature code inside `lib/features/<feature>/`.
- Put reusable visual primitives in `lib/shared/`.
- Preserve compatibility with web and mobile.
- Prefer clear, purposeful UI over generic scaffold code.

## Implementation guidance

- Keep screens responsive.
- Use small widgets when layout starts to grow.
- Add or update widget tests for visible behavior.
- Keep app entry and theme centralized in `lib/app/` and `lib/shared/theme/`.

## Validation

```bash
cd frontend
flutter analyze
flutter test
```

## References

- `frontend/lib/`
- `docs/ARCHITECTURE.md`
- `.agents/skills/flutter-building-layouts/SKILL.md`
