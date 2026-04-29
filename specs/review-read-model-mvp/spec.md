# Spec: review-read-model-mvp

## Contexto

O ForkScore ja possui a spec-mae do fluxo principal do MVP, o dominio
consolidado em `docs/MVP_DOMAIN_MODEL.md`, o roadmap que sugere uma spec pequena
de leitura de reviews e a spec `reviews-create-mvp` ja implementada. No estado
atual, uma pessoa usuaria autenticada consegue cadastrar locais, abrir o detalhe
do local e criar reviews, mas ainda nao consegue ler um resumo util das
avaliacoes existentes no proprio detalhe do local.

Esta spec pequena isola apenas a leitura basica de reviews dentro do detalhe do
local. O objetivo e enriquecer a decisao de "avaliar este local" sem abrir agora
historico completo do usuario, ranking publico, analytics, dashboard, edicao,
exclusao ou moderacao.

## Objetivo

Definir a entrega minima de leitura de reviews do MVP para que uma pessoa
usuaria autenticada consiga:

- abrir o detalhe lateral de um local e continuar vendo os dados basicos do
  local;
- visualizar um resumo simples da avaliacao media do local;
- visualizar uma lista curta de reviews recentes com comentarios
  representativos;
- entender claramente quando o local ainda nao possui reviews;
- consumir um contrato minimo de backend suficiente para essa leitura no
  frontend atual.

## Escopo

- definir um read model minimo de reviews por local no backend;
- expor um endpoint protegido de leitura basica para um local especifico;
- calcular uma media simples do local a partir das reviews ja existentes;
- retornar uma lista curta de reviews recentes para o detalhe do local;
- integrar essa leitura ao detalhe lateral ja existente no frontend;
- exibir loading, vazio e erro na area de reviews do detalhe do local;
- preservar o botao e o fluxo atual de "Avaliar este local".

## Fora de escopo

- historico completo de reviews do usuario autenticado;
- listagem paginada ou navegacao dedicada de todas as reviews do local;
- ranking publico de locais, feed social, favoritos ou curtidas;
- analytics, dashboard, score composto avancado ou insights inteligentes;
- edicao, exclusao, moderacao, denuncia ou aprovacao de reviews;
- busca complexa, filtros avancados ou ordenacao configuravel de reviews;
- mudancas no escopo funcional de criacao de review, auth/profile ou places;
- alteracao da taxonomia de categorias e subcategorias de locais.

## Requisitos funcionais

- RF01. O sistema deve permitir que um usuario autenticado consulte um resumo
  basico de reviews para um local existente.
- RF02. O backend deve retornar um read model unico para o detalhe do local com
  `place_id`, `total_reviews`, `average_rating` e uma lista curta de reviews
  recentes.
- RF03. `average_rating` deve ser calculada como media aritmetica simples da
  nota geral de cada review, em que a nota geral da review e a media dos quatro
  criterios qualitativos e de `cost_benefit_rating`.
- RF04. A lista curta deve retornar apenas um numero pequeno e fixo de reviews
  recentes do local, ordenadas da mais recente para a mais antiga.
- RF05. Cada item da lista curta deve trazer dados suficientes para o frontend
  renderizar comentario representativo sem abrir uma tela de historico
  completa, incluindo autoria basica, recomendacao final, nota geral,
  `created_at` e os comentarios dos criterios da review.
- RF06. Quando o local nao possuir reviews, o backend deve retornar
  `total_reviews = 0`, `average_rating = null` e lista vazia sem tratar isso
  como erro.
- RF07. O frontend deve carregar esse resumo ao abrir ou atualizar o detalhe de
  um local na area autenticada.
- RF08. O card lateral do local deve continuar exibindo nome, endereco,
  categoria e autoria, adicionando abaixo um bloco de resumo de reviews.
- RF09. O frontend deve exibir estado de loading, estado vazio e estado de erro
  especificamente para o bloco de reviews do detalhe do local.
- RF10. O frontend deve manter acessivel a acao de avaliar o local mesmo quando
  o resumo de reviews estiver vazio ou em erro.

## Requisitos nao funcionais

- RNF01. O backend deve preservar a arquitetura hexagonal com separacao entre
  `domain`, `application`, `infra` e `presentation`.
- RNF02. O frontend deve preservar a organizacao por features em `lib/app`,
  `lib/features` e `lib/shared`.
- RNF03. O contrato deve permanecer pequeno e orientado ao detalhe do local,
  evitando antecipar feed, pagina ou dashboard de reviews.
- RNF04. A agregacao deve reutilizar as reviews persistidas no MVP sem criar
  uma segunda fonte de verdade.
- RNF05. A leitura deve permanecer compativel com SQLite no MVP e preparada
  para evolucao futura sem contaminar o dominio com SQL especifico.
- RNF06. Nenhuma nova rota publica deve ser criada; a leitura continua
  restrita ao contexto autenticado atual.

## Criterios de aceite

- CA01. Um usuario autenticado consegue abrir o detalhe de um local com reviews
  e visualizar `average_rating`, quantidade total de reviews e uma lista curta
  de reviews recentes.
- CA02. A media exibida no detalhe do local corresponde a uma media simples das
  reviews persistidas para aquele local.
- CA03. Cada review exibida no resumo mostra autoria basica, recomendacao,
  data e comentarios suficientes para leitura rapida no card lateral.
- CA04. Um local sem reviews continua abrindo normalmente e mostra um estado
  vazio claro, sem erro tecnico.
- CA05. Se a leitura do resumo falhar, o frontend preserva os dados basicos do
  local e mostra erro restrito ao bloco de reviews.
- CA06. O fluxo de criacao de review ja implementado continua acessivel a
  partir do detalhe do local.
- CA07. O backend rejeita consulta de resumo para local inexistente com erro
  consistente de `404 Not Found`.

## Dependencias e restricoes

- Esta spec depende de `auth-profile-mvp` para acesso autenticado ao detalhe.
- Esta spec depende de `places-mvp` para listagem e detalhe de local ja
  existentes.
- Esta spec depende de `reviews-create-mvp`, pois o read model parte das
  reviews ja persistidas.
- O dominio consolidado em `docs/MVP_DOMAIN_MODEL.md` continua sendo a fonte
  canonica para criterios, recomendacao, autoria e conceito de review.
- O card lateral do local continua sendo o centro desta entrega; nao deve ser
  criada uma jornada paralela de historico completo.

## Artefatos relacionados

- `docs/MVP_DOMAIN_MODEL.md`
- `docs/EXECUTION_NEXT_STEPS.md`
- `specs/mvp-evaluation-flow/spec.md`
- `specs/mvp-evaluation-flow/plan.md`
- `specs/mvp-evaluation-flow/tasks.md`
- `specs/reviews-create-mvp/spec.md`
- `specs/reviews-create-mvp/plan.md`
- `specs/reviews-create-mvp/tasks.md`
