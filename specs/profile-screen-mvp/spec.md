# Spec: profile-screen-mvp

## Contexto

O ForkScore ja possui autenticacao real, sessao ativa, navegacao protegida e
backend funcional para perfil autenticado com `GET /me` e `PUT /me`. No
frontend, porem, a rota `/profile` ainda aponta para um placeholder protegido,
o que interrompe a experiencia do usuario autenticado e impede o uso real do
perfil no MVP.

A decisao de produto vigente para o MVP ja esta fechada:

- `birth_date` continua no MVP;
- `birth_date` nao aparece na tela de cadastro;
- `birth_date` nao e obrigatoria para criar conta;
- `birth_date` deve ser exibida e editavel posteriormente na tela de perfil;
- `age` continua sendo derivada de `birth_date` quando o valor existir.

Esta spec pequena cobre somente a substituicao do placeholder atual por uma
tela real de perfil autenticado, conectada ao backend existente e aderente ao
estado atual do app.

## Objetivo

Entregar a tela de perfil do usuario autenticado no frontend do ForkScore,
consumindo o backend real para consulta e atualizacao de perfil, com tratamento
coerente de sessao, estados de UI e exibicao de `age` como valor derivado.

## Escopo

- substituir o placeholder atual da rota `/profile` por uma tela real;
- consultar o perfil autenticado a partir de `GET /me`;
- permitir atualizacao do perfil autenticado via `PUT /me`;
- exibir `name`, `email`, `birth_date` e `age`;
- permitir edicao de `name`, `email` e `birth_date`;
- tratar `age` como campo somente leitura derivado do backend;
- lidar corretamente com estado vazio quando `birth_date` nao existir;
- refletir a atualizacao no estado autenticado atual do app sem perder a sessao.

## Fora de escopo

- alterar contratos ou regras do backend de perfil;
- reabrir o fluxo de cadastro para incluir `birth_date`;
- avatar, upload de imagem ou midia;
- mudanca de senha, recuperacao de senha ou exclusao de conta;
- preferencias avancadas;
- edicao de locais, reviews ou historico avancado do usuario;
- remodelar o shell autenticado alem do necessario para encaixar a tela.

## Requisitos funcionais

- RF01. O app deve manter a rota `/profile` protegida por autenticacao.
- RF02. O app deve carregar o perfil autenticado a partir do backend real ao
  entrar na tela de perfil.
- RF03. A tela deve exibir `name`, `email`, `birth_date` e `age` conforme os
  dados retornados por `GET /me`.
- RF04. A tela deve permitir editar `name`, `email` e `birth_date`.
- RF05. A tela deve permitir salvar as alteracoes via `PUT /me`.
- RF06. `birth_date` deve ser opcional na UI e no envio da atualizacao.
- RF07. `age` deve ser exibida apenas quando houver valor derivado retornado
  pelo backend.
- RF08. `age` nao deve ter edicao direta no frontend.
- RF09. Apos atualizacao bem-sucedida, o estado autenticado atual do app deve
  refletir os novos dados do usuario.
- RF10. A tela deve preservar a sessao vigente durante consulta e atualizacao,
  sem exigir novo login.

## Requisitos nao funcionais

- RNF01. A implementacao deve preservar a organizacao do frontend em
  `lib/app`, `lib/features` e `lib/shared`.
- RNF02. O fluxo principal da feature deve consumir o backend real, sem depender
  de mocks para a navegacao autenticada do MVP.
- RNF03. Estados de loading, erro e sucesso devem ser tratados sem acoplar a UI
  diretamente a chamadas HTTP fora da camada ja existente de repositorio e
  sessao.
- RNF04. A tela deve lidar bem com ausencia de `birth_date` sem quebrar layout,
  validacao ou renderizacao.
- RNF05. A entrega deve permanecer pequena e alinhada ao MVP atual, sem
  introduzir novos modulos de dominio.

## Criterios de aceite

- CA01. O acesso autenticado a `/profile` abre uma tela real de perfil em vez
  do placeholder atual.
- CA02. A tela consulta `GET /me` e exibe `name`, `email`, `birth_date` e
  `age` conforme retorno do backend.
- CA03. Quando `birth_date` estiver ausente, a tela apresenta estado vazio
  compreensivel e continua permitindo salvar o perfil.
- CA04. O usuario consegue editar `name`, `email` e `birth_date` e salvar via
  `PUT /me`.
- CA05. `age` aparece como valor somente leitura e nao possui campo editavel.
- CA06. Apos salvar com sucesso, os dados atualizados ficam refletidos no estado
  autenticado usado pelo app.
- CA07. Falhas de consulta ou atualizacao sao exibidas em UI de forma clara sem
  derrubar a sessao atual.
- CA08. A entrega nao adiciona dependencias funcionais com avatar, senha,
  preferencias, locais ou reviews.

## Dependencias e restricoes

- A feature depende dos endpoints existentes `GET /me` e `PUT /me` no backend.
- A feature deve reutilizar a sessao autenticada e o `SessionController` ja
  existentes no frontend.
- A implementacao deve respeitar a decisao de produto que mantem `birth_date`
  opcional fora do cadastro e editavel apenas na tela de perfil.
- A spec deve permanecer aderente a `docs/MVP_DOMAIN_MODEL.md`,
  `docs/EXECUTION_NEXT_STEPS.md` e `specs/auth-profile-mvp/` como base do
  fluxo de perfil no MVP.
