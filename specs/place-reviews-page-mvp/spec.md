# Spec: place-reviews-page-mvp

## Contexto

A home autenticada do ForkScore ja concentra a lista de lugares cadastrados, o
que atende bem a etapa de descoberta no MVP. Hoje, no entanto, ao clicar em um
lugar a experiencia permanece embutida na propria home, com detalhe resumido no
mesmo fluxo. Isso reduz a clareza da navegacao e limita a evolucao da leitura
de reviews, porque a area atual foi pensada como apoio rapido e nao como uma
pagina dedicada de consulta.

Para a proxima evolucao do produto, faz mais sentido que a home continue sendo
uma lista de entrada e que a leitura aprofundada de um lugar aconteca em uma
pagina propria. Essa nova pagina deve concentrar os dados do local e a leitura
das reviews, deixando a home mais objetiva e criando um espaco mais natural
para crescimento futuro da experiencia.

## Objetivo

Separar a experiencia de consulta de reviews de um lugar em uma pagina dedicada
e protegida, acessada a partir da lista de lugares da home autenticada.

## Escopo

- manter a home autenticada como ponto de entrada com lista de lugares;
- transformar o clique em um lugar da home em navegacao para uma nova pagina
  dedicada;
- criar uma pagina autenticada de detalhe do lugar com cabecalho do local e
  leitura de reviews;
- exibir nessa pagina as informacoes principais do lugar e o conjunto de
  informacoes de reviews previsto para o MVP;
- preservar o CTA para iniciar uma nova avaliacao do local a partir dessa nova
  pagina;
- ajustar rotas, argumentos de navegacao e testes do frontend impactados;
- definir se o backend atual atende a nova pagina ou se sera necessario um
  endpoint adicional para listar reviews completas do lugar no MVP.

## Fora de escopo

- alterar o fluxo de login, logout ou guard autenticado;
- transformar a home em dashboard social, feed ou pagina de analytics;
- implementar edicao, exclusao, moderacao ou denuncia de reviews;
- introduzir ranking global, favoritos, curtidas ou recomendacoes inteligentes;
- criar experiencia publica para leitura de reviews sem autenticacao;
- redesenhar o dominio principal de `places` ou `reviews` fora do necessario
  para a nova jornada.

## Requisitos funcionais

- RF01. A home autenticada deve continuar exibindo a lista de lugares como
  ponto inicial de navegacao apos login.
- RF02. Ao clicar em um lugar na home, o usuario deve ser direcionado para uma
  nova pagina dedicada ao lugar selecionado.
- RF03. A nova pagina deve ser protegida pelo guard autenticado atual.
- RF04. A nova pagina deve exibir os dados basicos do lugar, incluindo nome,
  categoria, subcategoria, endereco, cidade, bairro e autoria.
- RF05. A nova pagina deve exibir as informacoes de reviews do lugar em formato
  adequado para leitura, incluindo resumo agregado e lista de reviews do MVP.
- RF06. A nova pagina deve deixar claro quando o lugar ainda nao possui
  reviews, sem tratar esse estado como erro tecnico.
- RF07. A nova pagina deve oferecer uma acao clara para avaliar o lugar.
- RF08. O usuario deve conseguir voltar da pagina do lugar para a home sem
  perder a navegacao autenticada.
- RF09. A home nao deve mais depender de um detalhe inline para exibir as
  informacoes principais de reviews de um lugar.
- RF10. Caso o contrato atual de resumo de reviews seja insuficiente para a
  nova pagina, o sistema deve prever um contrato especifico para leitura de
  reviews completas do lugar no MVP.

## Requisitos nao funcionais

- RNF01. A feature deve respeitar a organizacao atual do frontend em
  `lib/app`, `lib/features` e `lib/shared`.
- RNF02. As rotas publicas devem permanecer `login` e `register`, enquanto a
  nova pagina do lugar deve ser classificada explicitamente como rota protegida.
- RNF03. O backend deve preservar a arquitetura hexagonal caso novos casos de
  uso ou endpoints sejam necessarios.
- RNF04. A nova pagina deve reaproveitar contratos e componentes existentes
  sempre que isso nao comprometer clareza arquitetural.
- RNF05. A experiencia deve funcionar bem em mobile e web, com hierarquia de
  leitura mais clara do que a atual home com detalhe embutido.
- RNF06. A separacao de pagina deve simplificar a home, nao adicionar mais
  ruido visual a ela.

## Criterios de aceite

- CA01. A home continua listando lugares e deixa de ser a tela principal de
  leitura detalhada de reviews.
- CA02. Clicar em um lugar na home abre uma pagina dedicada do lugar em vez de
  apenas atualizar um detalhe inline na mesma tela.
- CA03. A nova pagina mostra os dados do lugar e o bloco de reviews de forma
  completa o suficiente para o MVP.
- CA04. O estado sem reviews e exibido de forma clara e continua permitindo
  iniciar uma avaliacao.
- CA05. O fluxo autenticado continua coerente, incluindo guard, logout,
  redirecionamento pos-login e navegacao de volta.
- CA06. Se a nova pagina exigir contrato adicional de leitura, esse contrato
  fica explicitamente definido na implementacao da feature.

## Dependencias e restricoes

- Esta spec depende da base autenticada consolidada em
  `specs/auth-profile-mvp/`.
- Esta spec depende da home consolidada em
  `specs/home-search-unification/`, pois ela redefine o comportamento do clique
  na lista de lugares da home.
- Esta spec depende de `specs/places-mvp/` para os dados basicos do lugar.
- Esta spec depende de `specs/review-read-model-mvp/` como base minima de
  leitura de reviews ja existente no MVP.
- A navegacao proposta deve permanecer coerente com o guard atual e com o
  contrato centralizado em `lib/app/navigation/`.

