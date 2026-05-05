# Tasks: postgres-migration-mvp

## Preparacao

- [x] Revisar `spec.md` e `plan.md` antes de implementar.
- [x] Confirmar os pontos que ainda assumem SQLite em configuracao, bootstrap,
      seeds e testes.

## Trilha 1: infraestrutura e configuracao

- [x] Adicionar dependencia do driver PostgreSQL no backend.
- [x] Atualizar `DATABASE_URL`, `.env.example` e settings para o fluxo principal
      com PostgreSQL.
- [x] Criar `docker-compose.yml` para PostgreSQL local de desenvolvimento e
      banco separado de testes.

## Trilha 2: compatibilidade backend

- [x] Revisar engine, session factory e inicializacao do banco para separar
      comportamento SQLite de comportamento PostgreSQL.
- [x] Decidir e documentar estrategia de migrations/bootstrap para PostgreSQL
      no MVP.
- [x] Validar modelos SQLAlchemy, FKs, indices e tipos usados por `auth`,
      `users`, `places` e `reviews`.
- [x] Garantir que bootstrap e seed da taxonomia funcionem em PostgreSQL sem
      alterar dominio ou contratos HTTP.

## Trilha 3: testes e validacao

- [x] Ajustar estrategia de fixtures para permitir testes backend com
      PostgreSQL local.
- [x] Rodar `cd backend && .venv/bin/pytest -q` no fluxo definido.
- [ ] Validar manualmente inicializacao do backend contra PostgreSQL local.

## Trilha 4: documentacao e setup

- [x] Atualizar `docs/SETUP.md` com compose, `DATABASE_URL`, inicializacao do
      backend e testes locais.
- [x] Registrar no material da feature que migracao de dados SQLite historicos
      e deploy final em nuvem ficam fora de escopo.

## Validacao final

- [x] Revisar aderencia a `docs/ARCHITECTURE.md`,
      `docs/MVP_DOMAIN_MODEL.md` e `.specify/memory/constitution.md`.
- [x] Revisar diff completo antes de commit e PR.
