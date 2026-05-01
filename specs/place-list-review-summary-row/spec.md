# Spec: place-list-review-summary-row

## Contexto

A home autenticada do ForkScore funciona como area de descoberta e listagem dos
lugares cadastrados. Depois da extracao do detalhe/reviews para uma pagina
dedicada, a lista da home ficou mais objetiva, mas cada row ainda mostra dados
basicos do lugar, categoria e autoria.

O proximo ajuste deve enriquecer essa row com sinais leves de review, sem voltar
a criar detalhe inline na home. A pessoa deve conseguir comparar rapidamente os
lugares pelo score atual e pela quantidade de reviews, enquanto o clique na row
continua levando para a pagina dedicada do lugar.

## Estado atual relevante

- `HomePage` usa `PlacesDiscoverySection` com `showInlineDetail: false`.
- O clique na row da home navega para `AppRoutes.placeReviews` com o `placeId`.
- `_PlaceSummaryTile`, em
  `frontend/lib/features/places/presentation/widgets/place_discovery_section.dart`,
  exibe nome, bairro/cidade, categoria e autoria.
- `PlaceSummary` no frontend contem `createdBy`, mas nao contem score ou total
  de reviews.
- `GET /places` retorna `PlaceSummaryOutput` com dados basicos, categoria,
  subcategoria e `created_by`, mas nao retorna resumo de reviews.
- Ja existe `GET /places/{place_id}/reviews/summary` para a pagina dedicada,
  mas usa-lo uma vez por item da lista geraria chamadas N+1 no frontend.

## Objetivo

Atualizar cada row da lista de lugares cadastrados para mostrar categoria, score
atual e quantidade de reviews, removendo a autoria da row e preservando a home
como superficie de descoberta/listagem.

## Escopo

- Atualizar a row/list item de lugares cadastrados na home e nos componentes
  compartilhados de listagem de places.
- Remover a exibicao de autoria da row.
- Exibir categoria, score atual do lugar e quantidade de reviews na row.
- Definir e implementar estado claro para lugares sem reviews.
- Ajustar modelos/DTOs/contratos de listagem de places se necessario.
- Atualizar testes frontend da home/listagem.
- Atualizar testes backend se houver mudanca no contrato de `GET /places`.
- Manter o clique na row navegando para a pagina dedicada de detalhe/reviews do
  lugar.

## Fora de escopo

- Reintroduzir detalhe inline de reviews na home.
- Alterar a pagina dedicada de reviews, exceto se for necessario reaproveitar
  tipos/modelos ja existentes.
- Criar ranking global, ordenacao por score, filtros por score ou analytics.
- Alterar o fluxo de criacao de reviews.
- Alterar rotas publicas, guard autenticado, login ou logout.
- Remover autoria dos contratos de detalhe do lugar; a remocao solicitada vale
  apenas para a exibicao da row.

## Requisitos funcionais

- RF01. A lista de lugares cadastrados deve exibir a categoria de cada lugar.
- RF02. A lista deve exibir o score atual de cada lugar quando houver reviews.
- RF03. A lista deve exibir a quantidade de reviews de cada lugar.
- RF04. Lugares sem reviews devem exibir estado explicito, com score vazio ou
  `-` e contagem `0 reviews`.
- RF05. A row nao deve exibir autoria do lugar.
- RF06. Clicar em uma row deve continuar abrindo a pagina dedicada de
  detalhe/reviews do lugar.
- RF07. A home nao deve exibir lista de reviews, comentarios recentes, detalhe
  expandido ou qualquer conteudo inline equivalente a pagina dedicada.
- RF08. A busca da lista deve continuar funcionando para nome, bairro, cidade,
  categoria e subcategoria. A autoria nao deve ser promovida como informacao da
  row; se permanecer pesquisavel por compatibilidade, isso deve ser uma decisao
  explicita de implementacao.
- RF09. O frontend nao deve fazer uma chamada de summary de reviews para cada
  lugar listado.
- RF10. O contrato de listagem deve fornecer os dados necessarios para renderizar
  a row em uma unica carga da lista.

## Requisitos nao funcionais

- RNF01. A implementacao deve preservar a organizacao atual do frontend em
  `lib/app`, `lib/features` e `lib/shared`.
- RNF02. Caso o backend seja alterado, a arquitetura hexagonal deve ser
  preservada, mantendo dominio desacoplado de FastAPI, SQLAlchemy e Flutter.
- RNF03. O calculo de resumo para listagem deve evitar N+1 de chamadas HTTP no
  frontend e evitar consultas individuais por lugar no backend sempre que houver
  uma alternativa simples em lote.
- RNF04. A home deve permanecer uma area de descoberta/listagem, com sinais
  compactos e escaneaveis.
- RNF05. O estado sem reviews deve parecer parte normal do produto, nao erro de
  carregamento.
- RNF06. Rotas protegidas e navegacao autenticada devem permanecer intactas.
- RNF07. A busca da lista nao deve carregar reviews completas nem criterios de
  reviews completos apenas para calcular score; o resumo deve ser obtido por
  agregacao compacta no backend.
- RNF08. A concorrencia de criacao de reviews nao deve produzir contadores ou
  medias inconsistentes na listagem.

## Decisoes de contrato

- O contrato atual de `GET /places` nao possui `score` nem `total_reviews`.
- A feature deve expandir `GET /places` com um resumo compacto de reviews por
  lugar, preferencialmente em um campo aninhado para manter o payload claro.
- Payload recomendado para cada item da lista:

```json
{
  "id": "plc_123",
  "name": "Cafe do Centro",
  "neighborhood": "Centro",
  "city": "Curitiba",
  "category": {
    "id": "cat_cafeteria",
    "name": "Cafeteria",
    "slug": "cafeteria"
  },
  "subcategory": {
    "id": "sub_cafeteria",
    "category_id": "cat_cafeteria",
    "name": "Cafeteria",
    "slug": "cafeteria"
  },
  "created_by": {
    "id": "user_123",
    "name": "Rafa"
  },
  "review_summary": {
    "total_reviews": 2,
    "average_rating": 4.3
  }
}
```

- `review_summary.total_reviews` deve ser `0` quando nao houver reviews.
- `review_summary.average_rating` deve ser `null` quando
  `total_reviews = 0`.
- O frontend deve mapear `average_rating = null` para score visual `-`.
- O campo `created_by` pode permanecer no contrato por compatibilidade e para
  outros usos, mas nao deve aparecer na row da home.

## Performance e concorrencia

- A review completa permanece como fonte de verdade.
- O score agregavel da review deve ser persistido como `overall_rating` no
  momento da criacao da review, dentro da mesma transacao que grava a review e
  seus criterios.
- `GET /places` deve calcular `review_summary` a partir de reviews ja
  commitadas; reviews com transacao ainda aberta nao devem aparecer na media nem
  na contagem.
- A implementacao preferida para a listagem e uma agregacao em banco agrupada
  por `place_id`, equivalente a `COUNT(review.id)` e `AVG(review.overall_rating)`.
- A listagem nao deve recalcular o score percorrendo todos os criterios de todas
  as reviews a cada busca de lugares.
- Se o MVP ainda nao tiver `overall_rating` persistido, a implementacao desta
  feature deve incluir essa persistencia ou abrir uma tarefa explicita para
  adapta-la antes de usar o resumo na listagem.
- Se for criado ou adaptado um read model materializado de resumo por lugar, ele
  deve ser atualizado na mesma transacao da criacao da review, com incremento
  atomico de total e soma de ratings. Em SQLite, a serializacao de writes ajuda
  no MVP; em PostgreSQL futuro, a mesma regra deve usar update atomico, row lock
  ou upsert seguro.
- O frontend nao deve manter contador ou media otimista local para a lista; apos
  criar uma review, deve consumir novamente o resumo vindo do backend quando
  precisar refletir o novo estado.

## Critérios de aceite

- CA01. A lista de lugares mostra categoria, score atual e quantidade de reviews
  em cada row.
- CA02. A autoria nao aparece mais na row.
- CA03. Lugares sem reviews mostram `-` ou equivalente claro no score e
  `0 reviews`.
- CA04. Clicar em uma row continua abrindo a pagina dedicada do lugar.
- CA05. A home nao mostra detalhe inline de reviews.
- CA06. A implementacao planejada evita N+1 de chamadas de reviews no frontend.
- CA07. Se `GET /places` for alterado, os testes backend cobrem o resumo com e
  sem reviews.
- CA08. Os testes frontend cobrem a renderizacao de score, contagem, estado sem
  reviews, ausencia de autoria e navegacao ao detalhe.
- CA09. Rotas protegidas e navegacao autenticada permanecem intactas.
- CA10. A agregacao de `GET /places` usa consulta em lote/agrupada e nao carrega
  reviews completas por lugar para calcular a row.
- CA11. Reviews criadas concorrentemente so impactam a lista depois de
  commitadas, sem contador manual sujeito a lost update.

## Dependências e restrições

- Depende de `specs/place-reviews-page-mvp/` para a separacao da pagina dedicada
  de detalhe/reviews.
- Depende de `specs/review-read-model-mvp/` para a semantica existente de
  `average_rating` e `total_reviews`.
- Depende de `specs/places-mvp/` para o contrato base de lugares.
- A formula de score deve seguir a media ja usada no read model de reviews,
  evitando divergencia entre lista e detalhe.
- A implementacao deve confirmar se `overall_rating` ja esta persistido; se nao
  estiver, deve persistir esse valor ou definir read model equivalente antes de
  expor o resumo em `GET /places`.
- A feature deve ser validada com frontend sempre e com backend caso o contrato
  de `GET /places` seja expandido.
