# Spec: frontend-auth-home-layout

## Contexto

O frontend Flutter do ForkScore ja possui uma base visual inicial para
autenticacao e home, mas esta base precisa evoluir usando como referencia
oficial o pacote entregue pelo produto em
`/Users/rvechiato/Downloads/forkscore_pacote_completo/`.

Nesta entrega, os arquivos `spec.md`, `main.dart`, `index.html` e o logo oficial
devem orientar diretamente a implementacao Flutter, preservando identidade
visual, hierarquia das telas e o branding do ForkScore em web e mobile.

## Objetivo

Entregar a primeira versao consolidada das telas de login, cadastro e home do
ForkScore em Flutter, alinhada ao layout oficial definido no HTML de referencia
e pronta para evolucao funcional posterior.

## Escopo

- adaptar a estrutura visual de login para Flutter com base no HTML oficial;
- adaptar a estrutura visual de cadastro para Flutter com base no HTML oficial;
- adaptar a home inicial com saudacao, destaque para nova avaliacao, atalhos e
  exploracao inicial;
- incorporar o logo oficial do ForkScore ao layout;
- organizar a implementacao em componentes reutilizaveis e responsivos;
- manter navegacao local mockada entre login, cadastro e home;
- introduzir protecao de rotas para garantir que areas internas exijam sessao
  autenticada.

## Fora de escopo

- integracao real com API de autenticacao;
- persistencia de sessao;
- recuperacao de senha funcional;
- fluxo completo de avaliacao gastronomica;
- telas adicionais alem de login, cadastro e home.

## Requisitos funcionais

- RF01. O app deve abrir na tela de login.
- RF02. A tela de login deve exibir campos de email e senha, CTA principal,
  link de cadastro e placeholder de recuperacao de senha.
- RF03. A tela de cadastro deve exibir nome completo, email, data de
  nascimento, senha, confirmar senha, CTA principal e retorno ao login.
- RF04. A navegacao local deve permitir login mockado e cadastro mockado com
  redirecionamento para a home.
- RF05. A home deve exibir saudacao, destaque para nova avaliacao, atalhos
  principais e blocos de exploracao inicial.
- RF06. O logo oficial deve aparecer como parte da identidade do app nas telas.
- RF07. Login e cadastro devem ser as unicas rotas publicas do MVP.
- RF08. Home e qualquer rota interna pos-login devem exigir autenticacao.
- RF09. O app deve redirecionar para login quando houver tentativa de acesso a
  rota protegida sem sessao valida.
- RF10. O app deve impedir permanencia desnecessaria em login/cadastro quando o
  usuario ja estiver autenticado.
- RF11. Logout deve limpar a sessao local e bloquear novamente o acesso as
  rotas protegidas.

## Requisitos nao funcionais

- RNF01. A implementacao deve preservar a organizacao `lib/app`, `lib/features`
  e `lib/shared`.
- RNF02. O tema deve respeitar a identidade visual oficial:
  `#FAF6F0`, `#3E2723`, `#C05D43`, `#4A6B53` e `#5C82A6`.
- RNF03. Titulos devem usar `Playfair Display` e textos/input devem usar
  `Inter`.
- RNF04. O layout deve se adaptar com boa leitura para mobile e web, incluindo
  apresentacao em frame centralizado quando houver espaco suficiente.
- RNF05. Componentes compartilhados devem ser reutilizaveis e evitar duplicacao
  de estilos entre login, cadastro e home.
- RNF06. A estrategia de guard deve ser simples, centralizada e preparada para
  expansao de novas rotas protegidas sem duplicar regras por tela.

## Criterios de aceite

- CA01. Login, cadastro e home refletem a hierarquia visual do `index.html`
  anexado.
- CA02. O branding do ForkScore permanece consistente entre telas e usa o logo
  oficial.
- CA03. O frontend possui componentes reutilizaveis para campos, acoes e blocos
  de destaque.
- CA04. Existe cobertura minima de teste para renderizacao inicial e navegacao
  entre login, cadastro e home.
- CA05. O acesso direto a rotas protegidas sem autenticacao redireciona para
  login.
- CA06. Logout devolve o usuario ao login e remove acesso as areas protegidas.
- CA07. `flutter analyze` e `flutter test` passam apos a implementacao.

## Dependencias e restricoes

- Os arquivos em `/Users/rvechiato/Downloads/forkscore_pacote_completo/` sao a
  referencia primaria desta entrega, nao apenas inspiracao visual.
- O layout precisa permanecer compativel com a arquitetura frontend atual do
  monolito.
- Esta entrega deve continuar desacoplada da API real para permitir validacao
  isolada do frontend.
