# Tasks: places-mvp

## Preparacao

- [ ] Revisar `docs/MVP_DOMAIN_MODEL.md` e confirmar que a modelagem de
      `Place` desta spec permanece aderente ao dominio consolidado.
- [ ] Confirmar a dependencia de `auth-profile-mvp` para obter o usuario
      autenticado e a estrategia de exibicao minima da autoria no frontend.

## Backend

- [ ] Criar o modulo `places` no backend com entidade, ports, casos de uso,
      repositorio e rotas para `CreatePlace`, `ListPlaces` e `GetPlaceById`.
- [ ] Adicionar persistencia e testes cobrindo campos obrigatorios,
      autenticacao obrigatoria e registro de autoria do cadastro.

## Frontend

- [ ] Criar a feature de locais no frontend com tela de listagem, formulario de
      cadastro e tela de detalhe integrados ao backend real.
- [ ] Exibir a autoria do local no fluxo de detalhe e cobrir o fluxo essencial
      com testes da area alterada.

## Validacao

- [ ] Rodar `cd backend && .venv/bin/pytest -q`.
- [ ] Rodar `cd frontend && flutter analyze`.
- [ ] Rodar `cd frontend && flutter test`.
