# Plan: reviews-create-mvp

## Resumo tecnico

Implementar `reviews-create-mvp` como uma fatia pequena que se apoia no fluxo
autenticado ja existente e no modulo `places` atual. O backend ganha o modulo
`reviews` para criacao e persistencia de avaliacoes. O frontend substitui o
placeholder protegido de reviews por um fluxo minimo de submissao orientado por
local ja selecionado.

O foco desta spec nao e leitura de reviews; e apenas criacao com regras fortes
de dominio e uma jornada curta para envio.

## Estado atual relevante

- `auth` e `users` ja cobrem identidade, sessao e perfil autenticado.
- `places` ja cobre cadastro, listagem e detalhe, inclusive dentro do fluxo
  autenticado do frontend.
- a rota protegida `/reviews` ja existe no frontend, mas ainda aponta para um
  placeholder.
- o frontend ja possui uma jornada reutilizavel para escolher ou cadastrar
  local antes da avaliacao.

## Backend

- Modulo impactado:
  `reviews`, com estrutura `domain`, `application`, `infra` e `presentation`.
- Mudancas de dominio:
  modelar `Review` como aggregate root com `place_id`, `author_user_id`,
  recomendacao final, `cost_benefit_rating` e colecao fechada de criterios
  qualitativos;
  modelar `CriterionReview` e `Rating` para encapsular faixa `1..5`,
  comentario obrigatorio e justificativa obrigatoria quando `rating < 3`;
  manter `cost_benefit_rating` fora da colecao de criterios qualitativos;
  permitir historico de revisitas sem unicidade por `user/place`.
- Mudancas de application:
  criar o caso de uso `CreateReview`;
  receber `place_id` da rota e usuario autenticado do contexto atual;
  validar que o local existe antes da persistencia;
  padronizar DTOs de entrada e saida para submissao e retorno da review criada.
- Mudancas de infraestrutura:
  criar modelos SQLAlchemy para `reviews` e `review_criteria`;
  implementar repositorio de `reviews` e dependencia de consulta de `places`
  para verificar existencia do local;
  manter compatibilidade com SQLite sem contaminar o dominio.
- Mudancas de presentation:
  expor rota protegida `POST /places/{place_id}/reviews`;
  mapear erros de autenticacao, local inexistente e validacao de negocio em
  respostas HTTP consistentes com o restante da API.

## Frontend

- Features impactadas:
  criar a feature `reviews` com models, repository, controller e tela minima de
  criacao;
  integrar a feature com o fluxo autenticado e com a selecao de local ja
  existente.
- Fluxo minimo sugerido:
  o usuario escolhe um local na jornada atual de `places`;
  a partir do local selecionado, abre a tela protegida de criacao de review;
  a tela mostra resumo do local, os quatro criterios fixos, o
  `cost_benefit_rating` e a recomendacao final;
  apos sucesso, o app retorna ao contexto do local com confirmacao clara.
- Reuso esperado:
  reaproveitar `SessionController`, `AppRouteGuard` e a jornada atual de
  `PlacesDiscoverySection`;
  evitar criar um segundo fluxo para achar local quando o fluxo atual ja cobre
  pesquisa, detalhe e cadastro de place.
- Validacoes locais:
  refletir comentario obrigatorio em todos os criterios;
  exigir justificativa quando a nota ficar abaixo de `3`;
  espelhar a validacao de `cost_benefit_rating` e recomendacao final antes do
  submit.

## Dados e contratos

- Entidades/tabelas afetadas:
  `reviews` com `place_id`, `author_user_id`, recomendacao final,
  `cost_benefit_rating`, `created_at` e `updated_at`;
  `review_criteria` com `review_id`, `code`, `rating`, `comment` e
  `justification`.
- Contrato principal:
  `POST /places/{place_id}/reviews`.
- Regras contratuais centrais:
  payload com exatamente os quatro criterios do MVP;
  `rating` e `cost_benefit_rating` sempre inteiros entre `1` e `5`;
  `comment` obrigatorio em todos os criterios;
  `justification` obrigatoria quando `rating < 3`;
  recomendacao final obrigatoria e consistente com a spec-mae;
  resposta de sucesso retorna a review criada com autoria e local vinculado.

## Dependencias

- Dependencia funcional:
  `auth-profile-mvp` deve estar disponivel para autenticar a criacao da review.
- Dependencia funcional:
  `places-mvp` deve estar disponivel para fornecer um local valido e o contexto
  de selecao/cadastro no frontend.
- Dependencia de alinhamento:
  a representacao exata da recomendacao final deve permanecer alinhada a
  `specs/mvp-evaluation-flow/api-contracts.md`.

## Paralelizacao com Agent Team

### Trilha 1: dominio e persistencia backend

- Responsabilidade:
  modelagem de `Review`, `CriterionReview`, `Rating`, repositorio e tabelas.
- Pode iniciar:
  imediatamente apos congelar o contrato minimo do payload.
- Entregas:
  modulo `reviews` no backend e testes unitarios de dominio.

### Trilha 2: contratos e endpoint da API

- Responsabilidade:
  DTOs, router, dependencies, mapeamento de erros e testes HTTP.
- Pode iniciar:
  em paralelo com a Trilha 1, desde que o payload e a resposta estejam
  alinhados.
- Entregas:
  `POST /places/{place_id}/reviews` funcional e documentado.

### Trilha 3: fluxo e UI minima do frontend

- Responsabilidade:
  models, repository/client, controller e tela de criacao de review.
- Pode iniciar:
  apos congelar contrato e estrategia de navegacao a partir de `places`.
- Entregas:
  rota protegida real para review e formulario integrado ao contexto do local.

### Trilha 4: testes e validacoes

- Responsabilidade:
  cobertura unitaria, integracao HTTP, widget/service tests e validacao final.
- Pode iniciar:
  em fatias junto das trilhas 1, 2 e 3, mas consolida no fim.
- Entregas:
  evidencias de que regras do dominio e fluxo minimo de submit estao cobertos.

## Ordem sugerida

1. Fechar payload/resposta e alinhamento da recomendacao final.
2. Executar Trilha 1 e Trilha 2 em paralelo.
3. Executar Trilha 3 assim que o contrato estiver estavel.
4. Fechar Trilha 4 com cobertura e validacao das areas alteradas.

## Riscos

- Risco: crescer o escopo para leitura, historico ou medias publicas.
  Mitigacao: manter a feature limitada a criacao e submit.
- Risco: duplicar no frontend o fluxo de selecao de local.
  Mitigacao: reaproveitar `places` como porta de entrada da review.
- Risco: deixar regras de comentario e justificativa apenas no frontend.
  Mitigacao: centralizar essas regras no dominio e cobrir com testes.
- Risco: divergir entre o termo de dominio `recommended` e a forma do contrato.
  Mitigacao: alinhar explicitamente com `api-contracts.md` antes da
  implementacao.
