---
name: forkscore-sdd-executor
description: Use when working on a ForkScore feature that should follow Specification-Driven Development with specs, plan, tasks, validation, and PR flow to main.
---

# ForkScore SDD Executor

Use this skill when the task is larger than a tiny fix and should follow the
project SDD flow.

## Core workflow

1. Read `AGENTS.md`.
2. Read `.specify/memory/constitution.md` for architectural constraints.
3. Check whether a spec already exists in `specs/<feature>/`.
4. If it does not exist, create:
   - `spec.md`
   - `plan.md`
   - `tasks.md`
5. Implement one coherent slice at a time.
6. Run validation for the touched area.
7. Leave the branch ready for PR into `main`.

## When specs are required

Create or update specs when the change:

- adds a feature;
- changes API behavior;
- impacts backend and frontend together;
- changes architecture or workflow;
- requires multiple implementation steps.

## Validation

For backend work:

```bash
cd backend
.venv/bin/pytest -q
```

For frontend work:

```bash
cd frontend
flutter analyze
flutter test
```

## References

- `AGENTS.md`
- `docs/SDD.md`
- `specs/_template/`

