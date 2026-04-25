# Tasks: auth-profile-mvp

## Preparacao

- [ ] Revisar `specs/auth-profile-mvp/spec.md` e alinhar o contrato final de
      perfil proprio com base na estrutura atual de `auth`.
- [ ] Mapear a evolucao necessaria do backend atual para suportar `birth_date`
      e perfil separado do usuario autenticado.

## Backend

- [ ] Evoluir `auth` para concluir cadastro e login com `name`, `birth_date`,
      `email` e `password`, mantendo `email` como atributo canonico.
- [ ] Criar o modulo `users` com casos de uso, repositorios e rotas para
      consultar e atualizar o proprio perfil autenticado.
- [ ] Ajustar persistencia, dependencias e testes do backend para cobrir
      cadastro, login, consulta de perfil, atualizacao de perfil e calculo de
      `age`.

## Frontend

- [ ] Criar a feature de autenticacao inicial consumindo cadastro e login do
      backend.
- [ ] Criar a feature de perfil autenticado com consulta e atualizacao do
      proprio perfil.

## Validacao

- [ ] Rodar `cd backend && .venv/bin/pytest -q`.
- [ ] Rodar `cd frontend && flutter analyze`.
- [ ] Rodar `cd frontend && flutter test`.
- [ ] Revisar se a entrega continua aderente a `docs/MVP_DOMAIN_MODEL.md`,
      `docs/ARCHITECTURE.md` e `.specify/memory/constitution.md`.
