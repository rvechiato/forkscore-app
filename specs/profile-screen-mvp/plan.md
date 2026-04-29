# Plan: profile-screen-mvp

## Resumo tecnico

Implementar a tela de perfil do usuario autenticado no frontend reutilizando a
infraestrutura ja existente de autenticacao, sessao e integracao com `/me`.
Como o backend de perfil ja existe e esta coberto por testes, esta entrega deve
ficar concentrada no frontend, com foco em substituir o placeholder atual,
carregar os dados reais, editar os campos permitidos e refletir a resposta no
estado autenticado corrente.

A execucao pode seguir em tres trilhas leves:

- Trilha 1: contrato e integracao do frontend com `GET /me` e `PUT /me`;
- Trilha 2: tela de perfil, formulario e UX de campo opcional;
- Trilha 3: estados de loading/erro/sucesso e sincronizacao da sessao.

## Backend

- Modulos impactados:
  nenhum modulo novo; a entrega consome o backend existente de `auth` e
  `users`.
- Mudancas de dominio:
  nenhuma mudanca de dominio prevista nesta spec pequena.
- Mudancas de API:
  nenhuma mudanca contratual prevista; `GET /me` e `PUT /me` permanecem como
  fonte de verdade.
- Mudancas de persistencia:
  nenhuma mudanca prevista.
- Validacao de consistencia:
  confirmar que os contratos atuais permanecem alinhados a `birth_date`
  opcional e `age` derivada.

## Frontend

- Arquivos e areas impactadas:
  roteamento protegido em `lib/app/navigation/`;
  feature de autenticacao/perfil em `lib/features/auth/`;
  testes de widget e de fluxo da area autenticada.
- Mudancas de navegacao:
  substituir `ProtectedPlaceholderPage` na rota `/profile` por uma pagina real
  de perfil;
  manter a mesma protecao de rota ja existente.
- Mudancas de apresentacao:
  criar a pagina de perfil com modo de leitura/edicao simples;
  exibir `name`, `email`, `birth_date` e `age`;
  tratar `birth_date` vazio com UX clara;
  manter `age` como informacao somente leitura.
- Mudancas de estado:
  reutilizar `SessionController.refreshProfile()` para carregar dados atuais;
  reutilizar `SessionController.updateProfile()` para persistir alteracoes;
  garantir que o estado autenticado em memoria seja atualizado apos sucesso.
- Mudancas de UX:
  explicitar loading inicial, erro de carregamento, erro de salvamento e sucesso
  apos atualizacao;
  evitar telas mortas ou placeholders sem acao.

## Dados e contratos

- Fonte de dados principal:
  `AuthUser` no frontend continua representando `id`, `name`, `email`,
  `birthDate` e `age`.
- Endpoints utilizados:
  `GET /me` para consulta do perfil atual;
  `PUT /me` para atualizacao de `name`, `email` e `birth_date`.
- Regras contratuais relevantes para a UI:
  `birth_date` pode ser `null`;
  `age` pode ser `null` e deve ser exibida somente quando vier preenchida;
  `email` continua sendo canonico do usuario;
  a resposta de atualizacao deve substituir os dados em memoria da sessao.

## Dependencias e paralelismo

- Dependencia base:
  a rota real de perfil depende apenas do contrato de `/me`, que ja existe.
- Ordem recomendada:
  primeiro confirmar e ajustar a adaptacao do contrato no frontend;
  depois implementar a pagina e o formulario;
  por fim consolidar estados, testes e sincronizacao da sessao.
- Paralelismo seguro:
  Trilha 1 pode acontecer em paralelo com o esqueleto visual da Trilha 2;
  Trilha 3 depende das duas anteriores para fechar comportamento e testes.

## Testes

- Testes de widget:
  renderizacao da tela de perfil autenticado;
  estado vazio de `birth_date`;
  exibicao de `age` como leitura.
- Testes de fluxo:
  carregamento inicial do perfil;
  submissao bem-sucedida da atualizacao;
  exibicao de erro sem perda de sessao.
- Validacao manual/funcional:
  navegar da home para `/profile`, editar dados e confirmar reflexo na sessao.

## Riscos

- Risco: duplicar logica de estado fora do `SessionController`.
  Mitigacao: manter consulta e atualizacao centralizadas na camada de sessao ja
  existente.
- Risco: tratar `birth_date` como obrigatoria na UI e divergir do backend.
  Mitigacao: documentar e testar explicitamente o estado opcional.
- Risco: atualizar a tela sem refletir a resposta no usuario autenticado em
  memoria.
  Mitigacao: usar a resposta de `PUT /me` para substituir `currentUser` na
  sessao.
- Risco: escopo crescer para configuracoes de conta alem do MVP.
  Mitigacao: manter a feature limitada a dados basicos de perfil.
