---
name: forkscore-fastapi-hexagonal
description: Use when implementing or refactoring ForkScore backend code in Python, FastAPI, SQLAlchemy, and hexagonal architecture.
---

# ForkScore FastAPI Hexagonal

This skill guides backend work in ForkScore.

## Architecture rules

- Keep business rules in `domain/`.
- Keep orchestration in `application/`.
- Keep framework and persistence details in `infra/`.
- Keep HTTP concerns in `presentation/`.
- Do not move FastAPI or SQLAlchemy concerns into the domain.

## Module shape

```text
module/
├── domain/
├── application/
├── infra/
└── presentation/
```

## Current backend stack

- Python
- FastAPI
- SQLAlchemy
- JWT
- SQLite for MVP
- pytest for tests

## Implementation guidance

- Prefer explicit DTOs and typed functions.
- Model domain errors as explicit exceptions.
- Use repository ports from the domain.
- Keep route handlers thin.
- Add tests for success and failure paths.

## Validation

```bash
cd backend
.venv/bin/pytest -q
```

## References

- `docs/ARCHITECTURE.md`
- `backend/src/`
- `.specify/memory/constitution.md`

