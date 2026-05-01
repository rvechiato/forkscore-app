# Tasks: place-list-review-summary-row

## Preparação

- [x] Revisar `spec.md` e `plan.md` antes de iniciar a implementacao.
- [x] Confirmar se a branch de trabalho segue o fluxo do projeto para PR em
  `main`.
- [x] Identificar todos os testes existentes que cobrem home, listagem de
  places e contrato `GET /places`.

## Backend

- [x] Adicionar DTO compacto de resumo de reviews para a listagem de places.
- [x] Expandir `PlaceSummaryOutput` com `review_summary`.
- [x] Confirmar se `overall_rating` ja esta persistido na review; se nao
  estiver, persistir esse valor na transacao de criacao da review ou definir
  read model equivalente.
- [x] Definir no port de reviews uma operacao de resumo em lote por `place_id`.
- [x] Implementar no repositorio SQLAlchemy a leitura/agregacao em lote com
  `COUNT` e `AVG(overall_rating)` agrupados por `place_id`, sem query
  individual por lugar.
- [x] Garantir indice adequado para a agregacao por `place_id`.
- [x] Evitar carregar reviews completas e criterios completos apenas para
  calcular a row da listagem.
- [x] Se houver resumo materializado por lugar, atualiza-lo atomicamente na
  mesma transacao de criacao da review. Nao foi criado resumo materializado; a
  leitura usa agregacao em banco sobre reviews commitadas.
- [x] Atualizar `ListPlaces` para buscar resumos em lote e preencher
  `review_summary` para todos os lugares.
- [x] Garantir que lugares sem reviews retornem `total_reviews = 0` e
  `average_rating = null`.
- [x] Atualizar ou adicionar testes de `GET /places` cobrindo lugar com reviews,
  lugar sem reviews e rota protegida.
- [x] Adicionar teste backend para multiplas reviews no mesmo lugar validando
  contagem e media agregada.
- [x] Adicionar teste ou verificacao de repositorio garantindo que a listagem
  nao depende de chamada individual de summary por lugar.

## Frontend

- [x] Criar model frontend para o resumo compacto de reviews da listagem.
- [x] Atualizar `PlaceSummary` para incluir o resumo compacto.
- [x] Atualizar parser de `ForkScoreApiPlacesRepository` para ler
  `review_summary`.
- [x] Atualizar `MockPlacesRepository` para retornar lugares com e sem resumo de
  reviews.
- [x] Atualizar `_PlaceSummaryTile` para exibir categoria, score e quantidade de
  reviews.
- [x] Remover a autoria da row.
- [x] Atualizar placeholder e haystack de busca se ainda mencionarem autoria.
- [x] Preservar `onTap` e navegacao para `AppRoutes.placeReviews`.
- [x] Adicionar ou ajustar testes de widget para score, contagem, estado sem
  reviews, ausencia de autoria e navegacao ao detalhe.

## Validação

- [x] Rodar `cd backend && .venv/bin/pytest -q` se o backend for alterado.
- [x] Rodar `cd frontend && flutter analyze`.
- [x] Rodar `cd frontend && flutter test`.
- [x] Revisar se a home segue sem detalhe inline e se a pagina dedicada de
  reviews continua responsavel pela leitura aprofundada.
- [x] Registrar qualquer ajuste de contrato ou comportamento que tenha ficado
  diferente desta spec.
