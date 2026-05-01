# Plan: place-list-review-summary-row

## Resumo tecnico

Adicionar um resumo compacto de reviews ao contrato de listagem de lugares e
renderizar esse resumo em cada row da home. A home continua sendo apenas uma
lista de descoberta: mostra categoria, score e quantidade de reviews, mas a
leitura detalhada permanece na pagina dedicada do lugar.

A decisao proposta e expandir `GET /places` com `review_summary`, porque os
dados nao estao disponiveis hoje no contrato de listagem e porque buscar
`GET /places/{place_id}/reviews/summary` para cada item criaria N+1 no
frontend.

## Estado atual relevante

- `frontend/lib/features/home/presentation/pages/home_page.dart` navega da row
  para `AppRoutes.placeReviews`.
- `frontend/lib/features/places/presentation/widgets/place_discovery_section.dart`
  renderiza a row e atualmente mostra autoria.
- `frontend/lib/features/places/domain/models/place_summary.dart` nao possui
  resumo de reviews.
- `backend/src/modules/places/application/dtos.py` define `PlaceSummaryOutput`
  sem resumo de reviews.
- `backend/src/modules/places/application/use_cases/list_places.py` monta a
  resposta de `GET /places`.
- `backend/src/modules/reviews` ja conhece a media de reviews por lugar na
  leitura dedicada.

## Decisoes tecnicas

- Expandir `GET /places` com `review_summary`, mantendo `created_by` no payload
  por compatibilidade, mas removendo sua exibicao da row.
- Criar um DTO pequeno de resumo, por exemplo `PlaceReviewSummaryBriefOutput`,
  com `total_reviews: int` e `average_rating: float | None`.
- Adicionar um modelo correspondente no frontend, por exemplo
  `PlaceReviewSummaryBrief`, usado por `PlaceSummary`.
- Calcular os resumos em lote para todos os lugares retornados por
  `ListPlaces`, evitando consultas por lugar.
- Reutilizar a formula de score do read model de reviews:
  media das `overall_rating` das reviews do lugar, arredondada de forma
  consistente com o detalhe.
- Persistir `overall_rating` na review no momento da criacao, caso esse campo
  ainda nao esteja persistido, para permitir `COUNT`/`AVG` sem recalcular todos
  os criterios na listagem.
- Ler o resumo de reviews apenas de reviews commitadas. A lista nao deve usar
  contador otimista do frontend nem estado parcial de transacoes abertas.
- Preservar a pagina dedicada como unica area de leitura aprofundada de reviews.

## Backend

- Modulos impactados:
  `places` para DTO e use case de listagem;
  `reviews` para expor agregacao compacta em lote;
  testes HTTP em `backend/tests/test_places.py`.
- Mudancas de application:
  adicionar `review_summary` em `PlaceSummaryOutput`;
  atualizar `ListPlaces` para obter resumos por `place_id` em lote.
- Mudancas de dominio/ports:
  preferir um port de leitura pequeno no modulo de reviews, por exemplo metodo
  `summaries_by_place_ids(place_ids: list[str])`, retornando total e media por
  lugar;
  manter o dominio de `places` sem conhecer detalhes de criterios ou comentarios
  de reviews;
  confirmar se a entidade/modelo de review ja possui `overall_rating`
  persistido; se nao possuir, incluir a persistencia desse valor na trilha de
  escrita de reviews ou criar um read model equivalente antes de usar a
  listagem.
- Mudancas de infraestrutura:
  implementar a agregacao no repositorio SQLAlchemy de reviews com consulta em
  lote e agrupada por `place_id`, usando `COUNT` e `AVG(overall_rating)`;
  garantir indice adequado para leitura por `place_id`;
  evitar carregar reviews completas e criterios completos apenas para montar a
  row de listagem;
  se for criado um read model materializado por lugar, atualizar total e soma de
  ratings na mesma transacao da criacao da review com operacao atomica.
- Mudancas de presentation:
  manter a rota `GET /places` protegida pelo guard atual;
  retornar `review_summary` em todos os itens;
  manter `GET /places/{place_id}/reviews/summary` sem mudancas funcionais.

## Frontend

- Arquivos impactados:
  `frontend/lib/features/places/domain/models/place_summary.dart`;
  `frontend/lib/features/places/data/forkscore_api_places_repository.dart`;
  `frontend/lib/features/places/data/mock_places_repository.dart`;
  `frontend/lib/features/places/presentation/widgets/place_discovery_section.dart`;
  `frontend/test/widget_test.dart` ou testes especificos de places.
- UI da row:
  manter nome e bairro/cidade como informacoes principais;
  manter categoria como chip;
  substituir autoria por score e quantidade de reviews;
  para `averageRating == null`, exibir score `-`;
  para `totalReviews == 0`, exibir `0 reviews`;
  manter key `place-search-result-<id>` para navegacao e testes existentes.
- Busca:
  atualizar o placeholder se ele mencionar autoria;
  manter busca por campos do lugar e categoria/subcategoria;
  remover autoria do texto pesquisavel se a intencao for alinhar totalmente a
  row com a nova experiencia.
- Navegacao:
  nao alterar `HomePage` alem do necessario;
  o callback `onPlaceSelected` deve continuar usando `AppRoutes.placeReviews`.

## Dados e contratos

- Endpoint afetado:
  `GET /places`
- Campo novo:

```json
"review_summary": {
  "total_reviews": 0,
  "average_rating": null
}
```

- Regras:
  `review_summary` deve estar presente para todos os lugares;
  `total_reviews` nunca deve ser nulo;
  `average_rating` so deve ser nulo quando nao houver reviews;
  a listagem nao deve incluir `recent_reviews`;
  `average_rating` deve ser derivado de reviews commitadas;
  a agregacao deve ser feita em lote no backend, preferencialmente no banco,
  por `place_id`.

## Concorrencia

- Criacao de review:
  persistir review, criterios e `overall_rating` na mesma transacao.
- Leitura da lista:
  `GET /places` considera somente reviews commitadas; uma review em progresso
  aparece na lista apenas apos commit.
- Sem resumo materializado:
  a agregacao `COUNT`/`AVG` sobre reviews commitadas evita lost update em
  contadores manuais.
- Com resumo materializado:
  atualizar `total_reviews` e `rating_sum` na mesma transacao da criacao da
  review. Em SQLite, writes serializados atendem o MVP; em PostgreSQL futuro,
  usar update atomico, row lock ou upsert seguro.
- Frontend:
  nao incrementar score ou quantidade localmente; recarregar/consumir o resumo
  do backend quando a lista precisar refletir uma nova review.

## Testes

- Backend:
  testar `GET /places` com lugar sem reviews retornando
  `review_summary.total_reviews = 0` e `average_rating = null`;
  testar `GET /places` com reviews retornando total e media esperados;
  testar que a media da listagem usa `overall_rating` persistido ou read model
  equivalente, sem depender de carregar comentarios/criterios completos;
  testar cenario de multiplas reviews para o mesmo lugar para proteger contagem
  e media;
  garantir que a rota permanece protegida.
- Frontend:
  testar que a home/lista renderiza categoria, score e quantidade de reviews;
  testar que autoria nao aparece na row;
  testar estado sem reviews com score `-` e `0 reviews`;
  testar que tocar/clicar na row continua abrindo a pagina dedicada;
  ajustar mocks para fornecer lugares com e sem reviews.
- Validacao prevista:

```bash
cd backend && .venv/bin/pytest -q
cd frontend && flutter analyze
cd frontend && flutter test
```

## Riscos

- Risco: duplicar regras de score entre detalhe e lista.
  Mitigacao: reutilizar a mesma formula e cobrir ambos os contratos com testes.
- Risco: introduzir N+1 no frontend ou no backend.
  Mitigacao: incluir o resumo em `GET /places` e implementar agregacao em lote.
- Risco: degradar performance carregando reviews e criterios completos na
  listagem.
  Mitigacao: persistir `overall_rating` e usar `COUNT`/`AVG` agrupado por
  `place_id`.
- Risco: concorrencia gerar contador ou media incorretos.
  Mitigacao: preferir agregacao em leitura sobre reviews commitadas; se houver
  resumo materializado, atualiza-lo atomicamente na transacao de criacao da
  review.
- Risco: inflar a home com conteudo de detalhe.
  Mitigacao: limitar a row a score, total de reviews e categoria.
- Risco: quebrar consumidores que esperam `created_by`.
  Mitigacao: manter `created_by` no contrato inicialmente e remover apenas da
  apresentacao da row.
- Risco: layout apertado em mobile/web com muitos metadados.
  Mitigacao: usar hierarquia compacta, wrapping controlado e testes de widget.
