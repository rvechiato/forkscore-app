# Spec: place-review-cta-above-reviews

## Contexto

A pagina dedicada de reviews do lugar ja concentra o cabecalho do
estabelecimento, o resumo das avaliacoes, a lista de reviews e o CTA para
iniciar uma nova avaliacao. No layout atual, o box com o botao
`Avaliar este local` fica depois do container de reviews em mobile e abaixo do
resumo na coluna lateral em telas largas.

Essa ordem reduz a prioridade visual da acao principal esperada para usuarios
que chegam a pagina e desejam contribuir com uma avaliacao. A experiencia deve
colocar o CTA antes do container de review do local para que a acao de avaliar
apareca mais cedo na leitura, sem alterar contratos, dados ou navegacao.

## Objetivo

Reposicionar o box com o botao `Avaliar este local` acima do container de review
do local na pagina dedicada do lugar.

## Escopo

- ajustar a composicao da pagina de reviews do lugar em
  `frontend/lib/features/places/presentation/pages/place_reviews_page.dart`;
- manter o box de CTA existente, incluindo texto, estilo e comportamento de
  navegacao para o fluxo de avaliacao;
- garantir que o CTA apareca antes do bloco de reviews/resumo em layouts mobile
  e web;
- atualizar ou adicionar teste de widget que verifique a ordem visual entre o
  CTA e o container de reviews do lugar.

## Fora de escopo

- alterar o fluxo de criacao de reviews;
- alterar backend, contratos de API, modelos ou repositorios;
- mudar o conteudo textual do CTA;
- redesenhar o cabecalho do lugar, o resumo de avaliacoes ou a lista de
  reviews;
- alterar rotas, guards autenticados ou argumentos de navegacao.

## Requisitos funcionais

- RF01. A pagina dedicada do lugar deve continuar exibindo cabecalho, CTA,
  resumo de reviews e lista de reviews.
- RF02. O box com o botao `Avaliar este local` deve ser renderizado antes do
  container de review do local na ordem visual da pagina.
- RF03. Em layout mobile, a ordem deve ser: cabecalho do lugar, CTA, container
  de reviews/resumo e lista de reviews.
- RF04. Em layout web/largo, a coluna ou area que contem o CTA e o resumo deve
  exibir o CTA acima do container de review/resumo.
- RF05. O botao `Avaliar este local` deve continuar abrindo o fluxo protegido
  de avaliacao com o lugar selecionado como contexto inicial.
- RF06. Estados de sucesso, vazio e erro de reviews devem continuar deixando o
  CTA disponivel.

## Requisitos nao funcionais

- RNF01. A mudanca deve permanecer restrita ao frontend.
- RNF02. A implementacao deve preservar a organizacao atual em
  `lib/features/places` e `lib/features/reviews`.
- RNF03. A tela deve continuar responsiva para mobile e web.
- RNF04. A alteracao deve reaproveitar widgets existentes e evitar novos
  contratos ou estados desnecessarios.
- RNF05. O teste deve validar comportamento observavel pelo usuario, evitando
  acoplamento excessivo a detalhes internos de implementacao.

## Criterios de aceite

- CA01. Ao abrir a pagina de reviews do lugar, o usuario encontra o box
  `Avaliar este local` antes do container de review do local.
- CA02. O CTA permanece funcional e navega para o fluxo de avaliacao do lugar.
- CA03. A tela continua exibindo corretamente estados com reviews, sem reviews
  e erro de reviews.
- CA04. A validacao do frontend passa com `flutter analyze` e `flutter test`.
- CA05. Nenhum arquivo de backend e alterado por esta feature.

## Dependencias e restricoes

- Esta spec depende de `specs/place-reviews-page-mvp/`, que criou a pagina
  dedicada de reviews do lugar.
- Esta spec depende dos componentes de reviews existentes em
  `frontend/lib/features/reviews/presentation/widgets/`.
- A pagina continua sendo uma rota protegida; a classificacao de rota nao muda.
