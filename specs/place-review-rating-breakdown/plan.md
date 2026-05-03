# Plan: place-review-rating-breakdown

## Resumo tecnico

A entrega altera o resumo de reviews da pagina dedicada do local para priorizar
agregados por criterio e recomendacao. O frontend deve trocar a composicao atual
baseada em "Comentarios recentes" por um painel compacto de ratings. O backend
deve entregar os agregados necessarios no read model de resumo para que o
frontend nao dependa de reviews recentes limitadas para calcular medias.

## Estado atual relevante

- `PlaceReviewSummarySection` renderiza o container de reviews do local.
- O container atual exibe score geral, total de reviews e a secao
  "Comentarios recentes".
- `GET /places/{place_id}/reviews/summary` retorna `total_reviews`,
  `average_rating` e `recent_reviews`.
- Reviews persistidas possuem quatro criterios qualitativos em
  `review_criteria`, um campo proprio `cost_benefit_rating` e uma
  `recommendation`.

## Backend

- Modulos impactados: `reviews` em `application`, `domain/ports`, `infra` e
  `presentation`.
- Expandir o read model `PlaceReviewsSummaryOutput` com:
  `criteria_ratings` e `recommendation_summary`.
- Calcular medias por criterio qualitativo a partir de `review_criteria`.
- Calcular media de `cost_benefit` a partir de `reviews.cost_benefit_rating`.
- Calcular contadores e percentuais de `recommended` e `not_recommended`.
- Manter retorno vazio com sucesso para locais sem reviews.
- Preservar `recent_reviews` apenas se for necessario por compatibilidade com
  codigo existente durante a transicao.

## Frontend

- Modulos impactados: `lib/features/reviews/` e possivelmente
  `lib/features/places/` se a pagina dedicada compuser o container diretamente.
- Atualizar `PlaceReviewSummary` para mapear `criteriaRatings` e
  `recommendationSummary`.
- Criar modelos pequenos para rating por criterio e resumo de recomendacao.
- Substituir a lista de `_RecentReviewCard` dentro de
  `PlaceReviewSummarySection` por:
  - header compacto com score geral e total;
  - lista de ratings por criterio;
  - barra horizontal unica de recomendacao.
- Criar componente reutilizavel de cinco estrelas somente leitura.
- Garantir estados de loading, erro e vazio com o novo layout.
- Garantir que o CTA de avaliar o local continue fora do resumo e acessivel.

## Dados e contratos

- Endpoint afetado preferencial:
  `GET /places/{place_id}/reviews/summary`.
- Campos novos:
  `criteria_ratings` e `recommendation_summary`.
- Ordem visual obrigatoria:
  `taste`, `service`, `options`, `infrastructure`, `cost_benefit`.
- `cost_benefit` deve ser tratado como agregado exibivel no read model, sem
  alterar a entidade de dominio para transforma-lo em `CriterionReview`.
- Percentuais devem ser derivados dos contadores de recomendacao.
- Para evitar discrepancia de arredondamento:
  - backend retorna medias com ate duas casas decimais;
  - frontend decide apenas a quantidade visual de estrelas amarelas conforme a
    regra definida no refinamento;
  - frontend exibe a media numerica com uma casa decimal.

## Testes

- Backend:
  - teste do use case de resumo com reviews variadas;
  - teste de medias por cada criterio qualitativo;
  - teste de media de custo-beneficio;
  - teste de contagem e percentuais de recomendacao;
  - teste de local sem reviews;
  - teste HTTP do payload expandido.
- Frontend:
  - teste de parse dos novos campos do resumo;
  - teste de renderizacao de todas as linhas de criterios;
  - teste de estrelas amarelas e cinza para medias conhecidas;
  - teste de barra de recomendacao com percentuais;
  - teste de estado vazio;
  - teste garantindo ausencia de "Comentarios recentes" no container.

## Riscos

- Risco: divergencia entre a media geral e as medias por criterio.
  Mitigacao: documentar a formula e calcular todos os agregados a partir das
  mesmas reviews persistidas.
- Risco: tratar `cost_benefit_rating` como criterio de dominio por engano.
  Mitigacao: manter `cost_benefit` apenas como item agregado de exibicao.
- Risco: a regra visual de arredondamento das estrelas gerar expectativa
  diferente da media numerica.
  Mitigacao: confirmar no refinamento se a estrela visual usa piso,
  arredondamento comum ou meia estrela futura.
- Risco: quebrar consumidores existentes de `recent_reviews`.
  Mitigacao: manter o campo no contrato por compatibilidade enquanto a UI deixa
  de usa-lo neste container.

## Validacao

- Rodar backend se o contrato for alterado:
  `cd backend && .venv/bin/pytest -q`.
- Rodar frontend:
  `cd frontend && flutter analyze`;
  `cd frontend && flutter test`.
