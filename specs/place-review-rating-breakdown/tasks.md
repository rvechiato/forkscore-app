# Tasks: place-review-rating-breakdown

## Preparacao

- [x] Revisar `spec.md` e confirmar a regra visual de arredondamento das
      estrelas para medias decimais.
- [x] Confirmar se `recent_reviews` deve permanecer no contrato por
      compatibilidade ou se pode ser removido em uma feature posterior.
- [x] Identificar testes existentes de `PlaceReviewSummarySection` e do endpoint
      `GET /places/{place_id}/reviews/summary`.

## Backend

- [x] Expandir DTOs de resumo de reviews com rating por criterio e resumo de
      recomendacao.
- [x] Calcular medias dos quatro criterios qualitativos a partir de
      `review_criteria`.
- [x] Calcular media de `cost_benefit` a partir de `cost_benefit_rating`.
- [x] Calcular contadores e percentuais de `recommended` e `not_recommended`.
- [x] Garantir payload vazio consistente para local sem reviews.
- [x] Atualizar testes de use case para medias por criterio, recomendacao e
      vazio.
- [x] Atualizar testes HTTP do endpoint de summary.

## Frontend

- [x] Criar modelos de dominio para `criteriaRatings` e
      `recommendationSummary`.
- [x] Atualizar parser de `PlaceReviewSummary`.
- [x] Criar componente de estrelas somente leitura com cinco posicoes fixas.
- [x] Criar componente de linha de rating por criterio.
- [x] Criar componente de barra unica recomendado/nao recomendado.
- [x] Substituir "Comentarios recentes" pelo novo painel no
      `PlaceReviewSummarySection`.
- [x] Preservar loading, erro e vazio do container.
- [x] Atualizar ou criar mocks de reviews para cobrir o novo layout.
- [x] Atualizar testes de widget do resumo de reviews.

## Validacao

- [x] Rodar `cd backend && .venv/bin/pytest -q` se backend for alterado.
- [x] Rodar `cd frontend && flutter analyze`.
- [x] Rodar `cd frontend && flutter test`.
- [ ] Revisar visualmente a pagina de reviews em largura mobile e web.
