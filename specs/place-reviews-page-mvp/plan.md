# Plan: place-reviews-page-mvp

## Resumo tecnico

A abordagem e separar a jornada em dois niveis: a home autenticada continua
como lista de descoberta, enquanto a leitura aprofundada passa para uma rota
protegida dedicada ao lugar. No frontend, isso exige nova pagina, ajuste do
clique da lista, revisao do papel do detalhe inline atual e atualizacao de
testes. No backend, a implementacao pode inicialmente reaproveitar o detalhe de
local e o resumo de reviews ja existente; caso isso nao cubra a leitura
esperada para a pagina, a feature deve introduzir um endpoint especifico para
listar reviews do lugar no MVP.

## Estado atual relevante

- A home autenticada ja lista lugares e hoje embute a leitura do detalhe na
  propria pagina.
- O frontend ja possui fluxo de selecao de local e CTA para avaliar.
- O backend ja possui leitura de detalhe de local e resumo de reviews por
  local.
- Ainda nao existe uma rota dedicada de detalhe do lugar para leitura de
  reviews.

## Backend

- Modulos potencialmente impactados:
  `places` e `reviews`, somente se a nova pagina exigir contrato adicional.
- Cenario minimo:
  reaproveitar `GET /places/{place_id}` para dados do lugar e
  `GET /places/{place_id}/reviews/summary` para o bloco de reviews.
- Cenario de expansao do MVP:
  criar um endpoint protegido adicional, por exemplo
  `GET /places/{place_id}/reviews`, para listar todas as reviews do lugar em
  ordem decrescente de data.
- Em caso de endpoint novo:
  preservar a arquitetura hexagonal;
  concentrar agregacao e consulta em `reviews/application` e
  `reviews/infra`;
  manter verificacao de existencia do lugar consistente com `places`.

## Frontend

- Modulos impactados:
  `lib/app/navigation/`, `lib/features/home/`, `lib/features/places/` e
  `lib/features/reviews/`.
- Navegacao:
  adicionar uma nova rota protegida para a pagina do lugar;
  definir os argumentos necessarios, preferencialmente `placeId` e opcionalmente
  um snapshot inicial do local;
  garantir retorno simples para a home.
- Home:
  substituir o comportamento atual de detalhe inline ao clicar em um lugar pela
  navegacao para a nova pagina;
  simplificar a composicao visual da home para que ela permaneça mais focada em
  descoberta.
- Nova pagina:
  montar um cabecalho do lugar com informacoes principais;
  renderizar o resumo de reviews;
  renderizar a lista de reviews do MVP;
  manter o CTA para avaliar;
  exibir loading, vazio e erro com separacao clara entre dados do lugar e dados
  de reviews.

## Dados e contratos

- Contratos atuais reutilizaveis:
  `GET /places/{place_id}`;
  `GET /places/{place_id}/reviews/summary`.
- Contrato candidato, se necessario:
  `GET /places/{place_id}/reviews`.
- A decisao final deve ser tomada no kickoff tecnico da implementacao com base
  no gap entre "resumo curto" e "pagina dedicada".

### Decisao de implementacao

O resumo atual limita a leitura a `recent_reviews`, com ate 3 reviews. Como a
pagina dedicada precisa concentrar a lista de reviews do MVP, a implementacao
inclui o endpoint protegido `GET /places/{place_id}/reviews`, retornando todas
as reviews do lugar em ordem decrescente de data.

## Testes

- Frontend:
  atualizar testes de widget que hoje assumem detalhe inline na home;
  adicionar testes da nova navegacao home -> pagina do lugar;
  adicionar testes da nova pagina para loading, sucesso, vazio e CTA.
- Backend:
  se houver endpoint novo, adicionar testes HTTP e testes de repositorio/use
  case para ordenacao e estados de lista vazia.

## Riscos

- Risco: manter metade da experiencia no inline atual e metade na nova pagina.
  Mitigacao: definir claramente que a home vira lista de entrada e a leitura
  detalhada fica centralizada na nova rota.
- Risco: o endpoint de resumo atual nao cobrir o que a pagina precisa.
  Mitigacao: decidir cedo se o MVP aceita resumo expandido ou exige endpoint
  adicional de listagem.
- Risco: aumentar a complexidade de navegacao autenticada.
  Mitigacao: manter a nova pagina como rota protegida simples, com argumentos
  explicitos e back navigation padrao.
