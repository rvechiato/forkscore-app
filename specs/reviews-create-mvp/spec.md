# Spec: reviews-create-mvp

## Contexto

O ForkScore ja possui a spec-mae do fluxo principal do MVP, o dominio de
avaliacao consolidado em `docs/MVP_DOMAIN_MODEL.md` e o roadmap que recomenda
quebrar a execucao em specs pequenas. No estado atual do repositorio, os
modulos `auth`, `users` e `places` ja definem a base autenticada sobre a qual
o nucleo do produto deve avancar.

Esta spec pequena isola apenas a criacao de reviews do MVP. O objetivo e
destravar o bloco central de valor do app sem abrir agora leitura avancada,
historico, ranking, analytics, favoritos ou edicao.

## Objetivo

Definir a entrega minima de reviews do MVP para que uma pessoa usuaria
autenticada possa:

- selecionar ou cadastrar um local e, em seguida, iniciar uma avaliacao;
- registrar os quatro criterios qualitativos fixos do MVP;
- informar `cost_benefit_rating`;
- tomar a decisao final explicita de recomendacao;
- submeter a avaliacao em um fluxo simples de frontend.

## Escopo

- permitir que apenas usuario autenticado crie review para um local existente;
- criar o modulo `reviews` no backend com estrutura hexagonal;
- exigir exatamente os quatro criterios qualitativos do MVP:
  `taste`, `service`, `options` e `infrastructure`;
- exigir rating inteiro de `1` a `5` para cada criterio qualitativo;
- exigir comentario obrigatorio para cada criterio qualitativo;
- exigir justificativa obrigatoria quando a nota do criterio qualitativo for
  menor que `3`;
- exigir `cost_benefit_rating` obrigatorio com rating inteiro de `1` a `5`;
- exigir recomendacao final explicita com os valores do MVP
  `recommended` ou `not_recommended`;
- permitir multiplas reviews do mesmo usuario para o mesmo local;
- definir o endpoint minimo de criacao de review;
- definir o fluxo minimo de frontend para submissao de review a partir da area
  autenticada ja existente.

## Fora de escopo

- leitura avancada de reviews, listagem por local, historico do usuario ou
  feed de avaliacoes;
- edicao, exclusao ou rascunho de review;
- medias publicas, agregacoes, ranking, dashboard ou analytics;
- favoritos, recomendacao automatica ou derivacao da recomendacao a partir das
  notas;
- refatoracao ampla do shell autenticado do frontend;
- mudancas no escopo funcional de `auth-profile-mvp` ou `places-mvp`;
- alteracao de taxonomia de categorias e subcategorias de locais.

## Requisitos funcionais

- RF01. O sistema deve permitir que um usuario autenticado crie uma review para
  um local existente.
- RF02. A review deve conter exatamente os criterios `taste`, `service`,
  `options` e `infrastructure`, sem duplicidade e sem criterios extras.
- RF03. Cada criterio qualitativo deve exigir `rating` inteiro entre `1` e
  `5`.
- RF04. Cada criterio qualitativo deve exigir `comment` obrigatorio.
- RF05. Cada criterio qualitativo com `rating < 3` deve exigir `justification`
  obrigatoria.
- RF06. Cada criterio qualitativo com `rating >= 3` pode omitir
  `justification`.
- RF07. A review deve exigir `cost_benefit_rating` obrigatorio com valor
  inteiro entre `1` e `5`.
- RF08. A review deve exigir uma recomendacao final explicita com os valores
  `recommended` ou `not_recommended`.
- RF09. O sistema deve vincular a review ao `User` autenticado e ao `Place`
  informado.
- RF10. O backend deve aceitar multiplas reviews do mesmo usuario para o mesmo
  local em momentos diferentes.
- RF11. O frontend deve oferecer um fluxo minimo de submissao de review
  reaproveitando o contexto autenticado e a selecao de local ja existentes.

## Requisitos nao funcionais

- RNF01. O backend deve preservar a arquitetura hexagonal com separacao entre
  `domain`, `application`, `infra` e `presentation`.
- RNF02. O frontend deve preservar a organizacao por features em `lib/app`,
  `lib/features` e `lib/shared`.
- RNF03. As regras criticas de review devem ser garantidas no backend mesmo que
  o frontend replique as validacoes.
- RNF04. A feature deve permanecer compativel com SQLite no MVP, sem acoplamento
  do dominio a detalhes de persistencia.
- RNF05. As novas telas de review devem permanecer protegidas pelo guard
  autenticado central do frontend.
- RNF06. O fluxo minimo de review deve reutilizar o que ja existe em `places`
  sempre que possivel, evitando criar uma segunda jornada paralela para escolha
  de local.

## Criterios de aceite

- CA01. Um usuario autenticado consegue criar uma review completa para um local
  existente.
- CA02. O backend rejeita review sem qualquer um dos quatro criterios
  qualitativos obrigatorios.
- CA03. O backend rejeita review com rating fora do intervalo `1..5` em
  qualquer criterio qualitativo.
- CA04. O backend rejeita review sem comentario em qualquer criterio
  qualitativo.
- CA05. O backend rejeita review com `rating < 3` sem justificativa no
  criterio correspondente.
- CA06. O backend rejeita review sem `cost_benefit_rating` ou com
  `cost_benefit_rating` fora do intervalo `1..5`.
- CA07. O backend rejeita review sem recomendacao final explicita ou com valor
  fora de `recommended` e `not_recommended`.
- CA08. O backend associa a review persistida ao usuario autenticado e ao local
  informado.
- CA09. O backend nao bloqueia uma nova review valida do mesmo usuario para o
  mesmo local.
- CA10. O frontend permite sair de uma selecao de local existente e concluir a
  submissao da review sem depender de leitura avancada de reviews.

## Dependencias e restricoes

- Esta spec depende de `auth-profile-mvp` para identidade, sessao e acesso a
  rotas protegidas.
- Esta spec depende de `places-mvp` para selecao e cadastro de local antes da
  review.
- O dominio consolidado em `docs/MVP_DOMAIN_MODEL.md` continua sendo a fonte
  canonica para `Review`, `Rating`, `CriterionCode` e autoria.
- O contrato de review deve permanecer consistente com a spec-mae
  `specs/mvp-evaluation-flow/`, inclusive na representacao da recomendacao
  final.
- O fluxo minimo de frontend pode usar pagina dedicada, rota protegida ou push
  interno, desde que a submissao parta de um local selecionado e preserve a
  navegacao autenticada atual.

## Artefatos relacionados

- `docs/MVP_DOMAIN_MODEL.md`
- `docs/EXECUTION_NEXT_STEPS.md`
- `specs/mvp-evaluation-flow/spec.md`
- `specs/mvp-evaluation-flow/plan.md`
- `specs/mvp-evaluation-flow/tasks.md`
- `specs/mvp-evaluation-flow/api-contracts.md`
