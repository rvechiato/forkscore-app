# Tasks: postgres-migration-mvp

## Preparacao

- [ ] Revisar `spec.md` e `plan.md` antes de implementar.
- [ ] Confirmar os pontos que ainda assumem SQLite em configuracao, bootstrap,
      seeds e testes.

## Trilha 1: infraestrutura e configuracao

- [ ] Adicionar dependencia do driver PostgreSQL no backend.
- [ ] Atualizar `DATABASE_URL`, `.env.example` e settings para o fluxo principal
      com PostgreSQL.
- [ ] Criar `docker-compose.yml` para PostgreSQL local de desenvolvimento.

## Trilha 2: compatibilidade backend

- [ ] Revisar engine, session factory e inicializacao do banco para separar
      comportamento SQLite de comportamento PostgreSQL.
- [ ] Decidir e documentar estrategia de migrations/bootstrap para PostgreSQL
      no MVP.
- [ ] Validar modelos SQLAlchemy, FKs, indices e tipos usados por `auth`,
      `users`, `places` e `reviews`.
- [ ] Garantir que bootstrap e seed da taxonomia funcionem em PostgreSQL sem
      alterar dominio ou contratos HTTP.

## Trilha 3: testes e validacao

- [ ] Ajustar estrategia de fixtures para permitir testes backend com
      PostgreSQL local.
- [ ] Rodar `cd backend && .venv/bin/pytest -q` no fluxo definido.
- [ ] Validar manualmente inicializacao do backend contra PostgreSQL local.

## Trilha 4: documentacao e setup

- [ ] Atualizar `docs/SETUP.md` com compose, `DATABASE_URL`, inicializacao do
      backend e testes locais.
- [ ] Registrar no material da feature que migracao de dados SQLite historicos
      e deploy final em nuvem ficam fora de escopo.

## Validacao final

- [ ] Revisar aderencia a `docs/ARCHITECTURE.md`,
      `docs/MVP_DOMAIN_MODEL.md` e `.specify/memory/constitution.md`.
- [ ] Revisar diff completo antes de commit e PR.
