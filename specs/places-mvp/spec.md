# Spec: places-mvp

## Contexto

O ForkScore ja possui uma spec-mae para o fluxo principal do MVP em
`specs/mvp-evaluation-flow/` e um roadmap que recomenda quebrar a execucao em
specs pequenas. Depois de `auth-profile-mvp`, o proximo bloco coerente e o
cadastro e consulta de locais.

O dominio consolidado em `docs/MVP_DOMAIN_MODEL.md` ja define `Place` como uma
entidade do MVP com endereco simplificado e autoria obrigatoria via
`created_by_user_id`. Esta spec pequena existe para isolar esse fluxo antes da
entrada em reviews.

## Objetivo

Definir a entrega minima de locais do MVP para que um usuario autenticado
possa:

- cadastrar um local;
- listar locais cadastrados;
- consultar o detalhe de um local;
- visualizar a autoria do cadastro do local.

## Escopo

- permitir que qualquer usuario autenticado cadastre um local;
- exigir no cadastro os campos `name`, `street`, `number`, `neighborhood` e
  `city`;
- registrar no local o identificador do usuario autenticado que realizou o
  cadastro;
- permitir listar locais com informacoes minimas para navegacao no frontend;
- permitir consultar o detalhe de um local com endereco completo e autoria;
- definir contratos de API e estados de tela necessarios para cadastro,
  listagem e detalhe de locais.

## Fora de escopo

- criacao, edicao, exclusao ou leitura de reviews;
- edicao e exclusao de locais;
- busca avancada, filtros, ordenacao complexa ou geolocalizacao;
- deteccao ou bloqueio de duplicidade de locais;
- upload de imagens do local;
- moderacao, aprovacao manual ou papeis administrativos.

## Requisitos funcionais

- RF01. O sistema deve permitir que qualquer usuario autenticado cadastre um
  local.
- RF02. O cadastro do local deve exigir `name`, `street`, `number`,
  `neighborhood` e `city`.
- RF03. O sistema deve registrar no local o usuario autenticado que realizou o
  cadastro.
- RF04. O sistema deve permitir listar locais cadastrados com informacoes
  minimas para selecao no frontend.
- RF05. O sistema deve permitir consultar o detalhe de um local existente com
  seus dados basicos de endereco.
- RF06. O detalhe do local deve expor a autoria do cadastro em formato
  suficiente para o MVP.
- RF07. O frontend deve oferecer fluxo de listagem, cadastro e detalhe de local
  consumindo o backend real.

## Requisitos nao funcionais

- RNF01. O backend deve preservar a arquitetura hexagonal com separacao entre
  `domain`, `application`, `infra` e `presentation`.
- RNF02. O frontend deve preservar a organizacao por features em `lib/app`,
  `lib/features` e `lib/shared`.
- RNF03. Os contratos de API devem ser simples e suficientes para web e mobile
  no MVP.
- RNF04. A regra de autoria do local deve ser garantida no backend, sem
  depender apenas do frontend.
- RNF05. A persistencia deve funcionar com SQLite no MVP sem contaminar o
  dominio com detalhes de infraestrutura.

## Criterios de aceite

- CA01. Um usuario autenticado consegue cadastrar um local informando nome,
  rua, numero, bairro e cidade.
- CA02. O local cadastrado persiste a referencia do usuario que realizou o
  cadastro.
- CA03. Um usuario autenticado consegue listar locais cadastrados sem uso de
  mocks no frontend.
- CA04. Um usuario autenticado consegue abrir o detalhe de um local existente e
  visualizar seus dados essenciais.
- CA05. O detalhe do local exibe a autoria do cadastro em formato definido para
  o MVP.
- CA06. O backend rejeita tentativa de cadastro de local sem autenticacao.
- CA07. O backend rejeita tentativa de cadastro de local sem qualquer um dos
  campos obrigatorios.

## Dependencias e restricoes

- Esta spec depende da existencia de usuario autenticado e fluxo basico de
  identidade providos por `auth-profile-mvp`.
- A feature deve reutilizar o contexto autenticado existente, sem recriar o
  modulo de autenticacao.
- O modulo previsto no backend e `places`, com responsabilidade restrita a
  cadastro e consulta de locais.
- A autoria do local deve partir do usuario autenticado atual, sem suporte a
  escolha manual de autor.
- A forma exata de exibicao da autoria no frontend pode ser simples no MVP,
  desde que o contrato permita identificar quem cadastrou o local.

## Artefatos relacionados

- `docs/MVP_DOMAIN_MODEL.md`
- `docs/EXECUTION_NEXT_STEPS.md`
- `specs/mvp-evaluation-flow/spec.md`
- `specs/mvp-evaluation-flow/plan.md`
- `specs/mvp-evaluation-flow/tasks.md`
