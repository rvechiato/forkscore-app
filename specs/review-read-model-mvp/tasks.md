# Tasks: review-read-model-mvp

## Preparacao

- [ ] Confirmar no kickoff tecnico o contrato final de
      `GET /places/{place_id}/reviews/summary`, incluindo formula de
      `average_rating` e limite da lista curta.

## Trilha 1: read model e agregacao backend

- [ ] Criar DTOs, port de leitura e caso de uso `GetPlaceReviewSummary`,
      calculando `average_rating`, `total_reviews` e a lista curta de reviews
      recentes por local.
- [ ] Cobrir com testes unitarios a formula da media, o ordenamento por
      recencia e o estado sem reviews.

## Trilha 2: contratos e endpoint da API

- [ ] Expor `GET /places/{place_id}/reviews/summary` com autenticacao
      obrigatoria, verificacao de local existente, response model minimo e
      testes HTTP de sucesso, vazio e `404`.

## Trilha 3: integracao e UI do detalhe no frontend

- [ ] Criar o read model de reviews no frontend, repository/client de leitura e
      integracao com o carregamento do detalhe do local.
- [ ] Atualizar o card lateral do local para renderizar media, total de reviews
      e lista curta, cobrindo loading, vazio, erro e mantendo o CTA de avaliar.

## Trilha 4: testes e validacoes

- [ ] Cobrir o frontend com testes de repository/controller/widget para os
      estados do bloco de reviews no detalhe do local.
- [ ] Rodar `cd backend && .venv/bin/pytest -q` apos as mudancas backend.
- [ ] Rodar `cd frontend && flutter analyze` apos as mudancas frontend.
- [ ] Rodar `cd frontend && flutter test` apos as mudancas frontend.
