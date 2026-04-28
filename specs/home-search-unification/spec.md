# Spec: home-search-unification

## Contexto

O frontend do ForkScore ja possui uma `HomePage` autenticada e uma pagina
separada de pesquisa de lugares (`PlacesPage`). No estado atual do MVP, essa
separacao adiciona um passo de navegacao desnecessario para uma acao central:
encontrar um lugar para selecionar e, futuramente, avaliar.

Como a home continua sendo a primeira experiencia apos login, faz mais sentido
que ela concentre a saudacao, a busca e a lista inicial de lugares, reduzindo
friccao sem alterar regras de negocio, contratos de backend ou o dominio do
MVP.

## Objetivo

Unificar a experiencia de pesquisa de lugares dentro da home autenticada,
transformando a home no ponto unico de entrada para busca e selecao de locais
no MVP.

## Escopo

- incorporar a busca de lugares diretamente na home autenticada;
- exibir a lista de lugares para selecao dentro da home;
- reorganizar a hierarquia visual da home para manter saudacao, busca e lista
  no mesmo fluxo;
- preparar um espaco visual simples para futura exibicao de favoritos;
- ajustar a navegacao autenticada para remover a dependencia de uma pagina
  separada de pesquisa no MVP.

## Fora de escopo

- mudancas em regras de negocio, contratos de API ou persistencia;
- criacao da funcionalidade real de favoritos;
- alteracoes no fluxo de cadastro de local alem do necessario para a nova home;
- remocao de toda a feature `places`, caso partes dela ainda precisem ser
  reutilizadas pela home.

## Requisitos funcionais

- RF01. A home autenticada deve continuar sendo a primeira tela apos login.
- RF02. A home deve manter a saudacao e boas-vindas ao usuario autenticado.
- RF03. A home deve exibir, logo abaixo da saudacao, a area de busca de
  lugares.
- RF04. A home deve exibir a lista de lugares diretamente na propria tela,
  permitindo selecao sem navegar para outra pagina dedicada de pesquisa.
- RF05. A home deve manter acesso ao fluxo de cadastro de local disponivel no
  contexto da busca/lista.
- RF06. A navegacao autenticada deve refletir que a pesquisa de lugares faz
  parte da home no MVP.
- RF07. A home deve reservar um espaco visivel, ainda que simples, para
  evolucao futura de favoritos do usuario.

## Requisitos nao funcionais

- RNF01. A mudanca deve permanecer restrita ao frontend Flutter.
- RNF02. A organizacao do frontend deve continuar aderente a `lib/app`,
  `lib/features` e `lib/shared`.
- RNF03. A unificacao deve reaproveitar a logica existente de busca/listagem de
  lugares sempre que isso evitar duplicacao desnecessaria.
- RNF04. Rotas publicas e protegidas devem continuar centralizadas e coerentes
  com o guard autenticado atual.
- RNF05. A estrutura resultante deve permitir crescimento futuro da home sem
  exigir nova quebra de fluxo para favoritos ou atalhos relacionados.

## Criterios de aceite

- CA01. Apos login, o usuario chega na home autenticada com saudacao, busca e
  lista de lugares na mesma tela.
- CA02. O usuario consegue pesquisar e selecionar lugares sem precisar abrir
  uma pagina separada apenas para isso.
- CA03. A navegacao do frontend nao depende mais de uma experiencia principal
  de pesquisa centrada em `/places` para o MVP.
- CA04. Existe um bloco ou placeholder claro na home para futura evolucao de
  favoritos.
- CA05. O fluxo autenticado continua funcional, incluindo guard de acesso,
  redirecionamento pos-login e logout.
- CA06. A funcionalidade atual de busca e listagem de lugares e preservada apos
  a reorganizacao.

## Dependencias e restricoes

- Esta spec depende da base autenticada ja definida em
  `specs/frontend-auth-home-layout/`.
- Esta spec reutiliza a feature de locais definida em `specs/places-mvp/`, sem
  alterar seu contrato funcional com o backend.
- Como a mudanca envolve navegacao frontend, login e cadastro permanecem como
  rotas publicas, enquanto home, perfil, locais e avaliacoes continuam sob
  protecao do guard autenticado.
- A unificacao deve ser coerente com o modelo de dominio atual em
  `docs/MVP_DOMAIN_MODEL.md`, no qual `Place` continua sendo apenas o agregado
  de cadastro e consulta de locais no MVP.
