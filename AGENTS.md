# ForkScore Agent Guide

Este repositório usa SDD para orientar o trabalho de agentes como Codex.

## Fonte de verdade

- Produto e arquitetura: `.specify/memory/constitution.md`
- Fluxo SDD do projeto: `docs/SDD.md`
- Arquitetura atual: `docs/ARCHITECTURE.md`
- Setup local: `docs/SETUP.md`
- Specs por feature: `specs/<feature>/`
- Skills do projeto: `.agents/skills/`

## Regras operacionais

- Toda feature relevante deve começar por `spec.md`, `plan.md` e `tasks.md`.
- Não implemente a partir de uma ideia solta se a mudança for maior que um ajuste pequeno.
- Preserve a arquitetura hexagonal no backend.
- Preserve a separação `backend/` e `frontend/` no monólito.
- Antes de concluir uma tarefa, rode a validação da área alterada.

## Backend

- Stack: Python, FastAPI, SQLAlchemy, JWT, SQLite no MVP.
- Estrutura esperada por módulo:
  - `domain/`
  - `application/`
  - `infra/`
  - `presentation/`
- Comandos usuais:
  - `cd backend && python3 -m venv .venv`
  - `cd backend && .venv/bin/pip install -e '.[dev]'`
  - `cd backend && .venv/bin/pytest -q`

## Frontend

- Stack: Flutter para web e mobile.
- Organização esperada:
  - `lib/app/`
  - `lib/features/`
  - `lib/shared/`
- Comandos usuais:
  - `cd frontend && flutter pub get`
  - `cd frontend && flutter analyze`
  - `cd frontend && flutter test`

## Fluxo de branch

- `main` é a branch produtiva.
- Toda mudança deve sair de uma branch própria.
- Push em branch não-`main` abre PR automático para `main`.
- PR só deve ser mergeado com checks obrigatórios passando.

## Quando usar specs

Crie ou atualize uma spec em `specs/` quando houver:

- nova feature;
- refatoração estrutural;
- mudança de arquitetura;
- alteração com impacto em backend e frontend;
- mudança com múltiplas etapas ou dependências.

## Definition of Done

- spec/plano/tasks atualizados quando aplicável;
- código implementado na arquitetura correta;
- testes/validações executados;
- documentação ajustada se o comportamento ou fluxo mudar.
