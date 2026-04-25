# Plan: auth-profile-mvp

## Resumo tecnico

Implementar a primeira fatia do MVP em duas frentes coordenadas:

- evoluir `auth` para concluir cadastro e login com `email`, `password`,
  `name` e `birth_date`;
- criar o fluxo de perfil autenticado para consulta e atualizacao do proprio
  usuario, sem acoplar a entrega a `places` ou `reviews`.

No backend, a identidade continua concentrada em `auth`, enquanto a leitura e
edicao de perfil ficam isoladas no modulo `users`. No frontend, a entrega cobre
somente autenticacao inicial e tela de perfil basico autenticado.

## Backend

- Modulos impactados:
  `auth` para cadastro/login e payload do usuario autenticado;
  `users` para consulta e atualizacao do proprio perfil.
- Mudancas de dominio:
  manter `email` como atributo canonico de `User`;
  introduzir `Profile` com `user_id`, `name` e `birth_date`;
  calcular `age` a partir de `birth_date` somente nas respostas de consulta;
  vincular perfil sempre ao usuario autenticado.
- Mudancas de application:
  evoluir os casos de uso de `RegisterUser` e `AuthenticateUser`;
  criar os casos de uso `GetMyProfile` e `UpdateMyProfile`;
  padronizar DTOs de entrada e saida para auth e perfil proprio.
- Mudancas de infraestrutura:
  ajustar persistencia para suportar `birth_date` e dados de perfil;
  criar repositorios/adapters necessarios para leitura e escrita do perfil;
  manter compatibilidade com SQLite e com o padrao atual de injecao de
  dependencias.
- Mudancas de presentation:
  manter `POST /auth/register` e `POST /auth/login`;
  adicionar rotas autenticadas para consultar e atualizar o proprio perfil;
  reaproveitar a dependencia de usuario autenticado nas rotas protegidas.

## Frontend

- Telas impactadas:
  criar fluxo inicial de cadastro e login;
  criar tela de perfil com visualizacao e edicao.
- Estados e navegacao:
  tratar sessao/token do usuario autenticado;
  permitir navegar do login/cadastro para a area autenticada minima;
  exibir estados de carregamento, erro e sucesso para auth e perfil.
- Integracoes com API:
  consumir os endpoints de cadastro, login, consulta do proprio perfil e
  atualizacao do proprio perfil;
  refletir no frontend os campos `name`, `birth_date`, `email` e `age`
  retornados pelo backend;
  manter a camada de servicos simples e pronta para reutilizacao nas proximas
  specs pequenas.

## Dados e contratos

- Entidades e tabelas afetadas:
  `users` com `email` e identidade autenticada;
  `profiles` com `user_id`, `name` e `birth_date`.
- Contratos esperados:
  `POST /auth/register` cria usuario autenticado com perfil basico;
  `POST /auth/login` autentica usuario existente;
  `GET /me` ou equivalente retorna o perfil do usuario autenticado;
  `PUT /me` ou equivalente atualiza o perfil do usuario autenticado.
- Regras contratuais centrais:
  `email` unico no sistema;
  `name` obrigatorio;
  `birth_date` obrigatoria;
  `age` apenas derivada, nunca persistida como atributo canonico;
  perfil sempre vinculado ao usuario autenticado da requisicao.

## Testes

- Backend unitario:
  cadastro/autenticacao;
  regras de perfil e calculo de idade;
  casos de uso de consulta e atualizacao do proprio perfil.
- Backend integracao:
  sucesso e erro de `register` e `login`;
  sucesso e erro de endpoints autenticados de perfil.
- Frontend:
  testes dos fluxos de autenticacao e perfil;
  testes de servicos/repositories para os contratos principais.

## Riscos

- Risco: misturar responsabilidade de autenticacao e perfil no mesmo modulo.
  Mitigacao: manter `auth` focado em identidade e usar `users` para perfil
  autenticado.
- Risco: persistir ou atualizar idade diretamente.
  Mitigacao: tratar `age` somente como dado derivado nas respostas.
- Risco: crescer o escopo com shell autenticado completo ou features futuras.
  Mitigacao: limitar a entrega a cadastro, login, consulta e atualizacao do
  proprio perfil.
