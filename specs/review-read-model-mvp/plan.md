# Plan: review-read-model-mvp

## Resumo tecnico

Implementar `review-read-model-mvp` como uma fatia pequena focada apenas no
detalhe do local autenticado. O backend ganha um read model agregado para um
local especifico, e o frontend passa a compor esse resumo no card lateral ja
existente sem alterar a jornada principal de places ou a criacao de reviews.

O foco desta spec nao e abrir um historico completo; e apenas mostrar media,
quantidade total e uma lista curta de reviews recentes para apoiar a decisao de
avaliar o local.

## Estado atual relevante

- `places` ja cobre listagem e detalhe de local com autoria no backend e no
  frontend.
- `reviews-create-mvp` ja cobre criacao de reviews e persistencia dos
  comentarios por criterio.
- o detalhe lateral do local no frontend ainda mostra apenas dados do local,
  endereco e autoria.
- ainda nao existe um contrato de leitura de reviews nem um read model agregado
  para o detalhe do local.

## Decisoes tecnicas propostas

- Expor um endpoint protegido separado para nao inflar `GET /places/{place_id}`
  com campos que pertencem ao contexto de reviews:
  `GET /places/{place_id}/reviews/summary`.
- Tratar a media exibida no MVP como `average_rating` simples, calculada a
  partir da media geral de cada review:
  `(taste + service + options + infrastructure + cost_benefit_rating) / 5`.
- Limitar a lista curta a um tamanho fixo pequeno do MVP, por exemplo `3`
  reviews recentes, ordenadas por `created_at desc`.
- Reutilizar a persistencia atual de `reviews` e `review_criteria` sem criar
  tabela materializada, cache ou processo assicrono.
- No frontend, manter o detalhe do local como dono da tela e consumir o resumo
  por composicao, nao por fusao estrutural com o modulo `places`.

## Backend

- Modulos impactados:
  `reviews` para o read model e agregacao;
  `places` apenas para verificacao de existencia do local.
- Mudancas de dominio/application:
  criar DTOs de leitura para `PlaceReviewSummary`, `RecentPlaceReview` e
  `RecentReviewComment`;
  criar caso de uso `GetPlaceReviewSummary`;
  encapsular o calculo da nota geral e da media do local em codigo de
  application/read model, sem reabrir a semantica de escrita da review.
- Mudancas de infraestrutura:
  expandir o port de repositorio de reviews ou criar port de leitura dedicado
  para consultar reviews por local em ordem recente;
  reutilizar o repositorio de places para validar `place_id`;
  montar a agregacao com base nas reviews existentes e em seus criterios.
- Mudancas de presentation:
  expor `GET /places/{place_id}/reviews/summary`;
  mapear `PlaceNotFoundError` para `404`;
  retornar payload pequeno com media, total e reviews recentes.

## Frontend

- Features impactadas:
  `features/reviews` para models e repository de leitura;
  `features/places` para integrar o resumo ao detalhe lateral.
- Integracao sugerida:
  criar um model especifico de leitura, por exemplo `PlaceReviewSummary`;
  carregar o resumo quando o detalhe do local for selecionado ou recarregado;
  manter estados independentes para detalhe do local e bloco de reviews.
- Comportamento de UI:
  exibir secao de media com quantidade de reviews;
  exibir ate `3` reviews recentes com autor, data, recomendacao e comentarios;
  exibir estado vazio claro quando nao houver reviews;
  exibir erro leve e acao de tentar novamente quando a leitura falhar;
  manter o CTA de avaliar o local visivel.
- Navegacao e guard:
  nenhuma nova rota protegida e necessaria;
  a leitura acontece dentro da rota protegida de locais ja existente.

## Dados e contratos

- Endpoint principal:
  `GET /places/{place_id}/reviews/summary`
- Payload sugerido:

```json
{
  "place_id": "plc_123",
  "total_reviews": 2,
  "average_rating": 4.2,
  "recent_reviews": [
    {
      "id": "rev_123",
      "author": {
        "id": "usr_123",
        "name": "Rafa"
      },
      "recommendation": "recommended",
      "overall_rating": 4.4,
      "created_at": "2026-04-28T12:00:00Z",
      "comments": [
        {
          "code": "taste",
          "rating": 5,
          "comment": "Cafe bem equilibrado."
        }
      ]
    }
  ]
}
```

- Regras contratuais centrais:
  `average_rating` pode ser `null` apenas quando `total_reviews = 0`;
  `recent_reviews` deve ser sempre lista, inclusive vazia;
  a lista curta nao precisa de paginacao no MVP;
  `comments` representa os comentarios ja persistidos por criterio, sem criar
  campo narrativo novo na review.

## Dependencias

- Dependencia funcional:
  `places-mvp` deve permanecer como fonte do detalhe do local.
- Dependencia funcional:
  `reviews-create-mvp` deve permanecer como unica fonte de escrita das reviews.
- Dependencia de produto:
  o MVP continua pequeno; qualquer necessidade de historico completo ou ranking
  deve abrir spec separada.

## Paralelizacao com Agent Team

### Trilha 1: read model e agregacao backend

- Responsabilidade:
  caso de uso, DTOs, port de leitura e calculo de media/resumo.
- Pode iniciar:
  imediatamente apos congelar o contrato do read model.
- Entregas:
  `GetPlaceReviewSummary`, agregacao simples e testes unitarios da regra de
  media e ordenacao.

### Trilha 2: contratos e endpoint da API

- Responsabilidade:
  router, dependencies, response models, mapeamento de erros e testes HTTP.
- Pode iniciar:
  em paralelo com a Trilha 1, usando o contrato acordado.
- Entregas:
  `GET /places/{place_id}/reviews/summary` protegido e consistente.

### Trilha 3: integracao e UI do detalhe no frontend

- Responsabilidade:
  models/read repository de reviews no frontend, integracao com `places` e
  renderizacao do bloco lateral.
- Pode iniciar:
  assim que o contrato estiver estavel, sem depender da implementacao final da
  agregacao.
- Entregas:
  secao de reviews no detalhe do local com loading, vazio, erro e CTA
  preservado.

### Trilha 4: testes e validacoes

- Responsabilidade:
  testes backend, testes de widget/service no frontend e validacao final das
  areas alteradas.
- Pode iniciar:
  progressivamente junto das trilhas anteriores, consolidando no fechamento.
- Entregas:
  cobertura suficiente para contrato, calculo de media e estados do detalhe.

## Ordem sugerida

1. Fechar o contrato minimo do resumo e o tamanho fixo da lista curta.
2. Executar Trilha 1 e Trilha 2 em paralelo.
3. Executar Trilha 3 assim que o payload de leitura estiver estavel.
4. Fechar Trilha 4 com cobertura e validacao das areas alteradas.

## Riscos

- Risco: expandir a feature para historico completo, feed ou analytics.
  Mitigacao: manter um unico endpoint de resumo e uma lista curta fixa.
- Risco: criar semantica nova de comentario geral que nao existe no dominio.
  Mitigacao: reutilizar os comentarios por criterio ja persistidos.
- Risco: acoplar fortemente o detalhe de `places` ao modulo `reviews`.
  Mitigacao: manter models e repositorio de leitura em `reviews` e integrar por
  composicao no frontend.
- Risco: divergir entre a media exibida e a regra real de agregacao.
  Mitigacao: documentar explicitamente a formula e cobrir com testes.
