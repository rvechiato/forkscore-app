# Spec: auth-profile-mvp

## Contexto

O ForkScore ja possui autenticacao inicial no backend e uma spec-mae para o
fluxo completo do MVP, mas ainda falta isolar a primeira entrega executavel que
destrava o restante do produto. Sem uma spec pequena para autenticacao e
perfil, backend e frontend correm o risco de evoluir com contratos
inconsistentes sobre cadastro, login e dados basicos do usuario autenticado.

Esta spec foca apenas na base de identidade do MVP, reaproveitando o modulo
`auth` existente e introduzindo o fluxo minimo de perfil autenticado antes de
qualquer trabalho com `places` ou `reviews`.

## Objetivo

Definir a primeira fatia executavel do MVP para que uma pessoa usuaria possa:

- criar conta com login e senha;
- autenticar com email e senha;
- possuir um perfil basico vinculado ao usuario autenticado;
- consultar o proprio perfil;
- atualizar o proprio perfil.

## Escopo

- evoluir o cadastro de usuario para incluir perfil basico com `name`,
  `birth_date` e `email`;
- manter `email` como atributo canonico do usuario;
- permitir login com email e senha;
- expor endpoint autenticado para consultar o proprio perfil;
- expor endpoint autenticado para atualizar o proprio perfil;
- calcular a idade a partir de `birth_date` somente no momento da consulta;
- criar o fluxo inicial de autenticacao e perfil no frontend.

## Fora de escopo

- cadastro, listagem ou detalhe de `places`;
- criacao, leitura ou edicao de `reviews`;
- recuperacao de senha, confirmacao de email ou login social;
- papeis administrativos, onboarding adicional ou preferencias avancadas;
- upload de avatar, foto de perfil ou outros dados alem de `name`,
  `birth_date` e `email`.

## Requisitos funcionais

- RF01. O sistema deve permitir cadastro de usuario com `name`, `birth_date`,
  `email` e `password`.
- RF02. O sistema deve permitir login com `email` e `password`.
- RF03. O cadastro deve vincular o perfil basico ao usuario criado.
- RF04. O sistema deve permitir que o usuario autenticado consulte o proprio
  perfil.
- RF05. O sistema deve permitir que o usuario autenticado atualize o proprio
  perfil basico.
- RF06. O sistema deve manter `email` como atributo canonico do usuario.
- RF07. O sistema deve derivar `age` a partir de `birth_date` no momento da
  consulta, sem persistir `age` como campo canonico.
- RF08. O sistema deve garantir que consulta e atualizacao de perfil atuem
  apenas sobre o usuario autenticado da requisicao.

## Requisitos nao funcionais

- RNF01. O backend deve preservar a arquitetura hexagonal com separacao entre
  `domain`, `application`, `infra` e `presentation`.
- RNF02. O frontend deve preservar a organizacao por features em `lib/app`,
  `lib/features` e `lib/shared`.
- RNF03. As validacoes criticas de autenticacao e perfil devem existir no
  backend, mesmo que o frontend replique parte delas.
- RNF04. A persistencia inicial deve continuar compativel com SQLite no MVP.
- RNF05. Os contratos desta spec devem permanecer pequenos e suficientes para
  web e mobile, sem antecipar campos de `places` ou `reviews`.

## Criterios de aceite

- CA01. Um usuario consegue se cadastrar com `name`, `birth_date`, `email` e
  `password`, recebendo token de acesso e dados basicos do usuario autenticado.
- CA02. Um usuario consegue fazer login com `email` e `password`, recebendo
  token de acesso e dados basicos do usuario autenticado.
- CA03. Um usuario autenticado consegue consultar o proprio perfil com `name`,
  `birth_date`, `age` derivada e `email`.
- CA04. Um usuario autenticado consegue atualizar o proprio perfil e receber a
  representacao atualizada em resposta consistente.
- CA05. O backend rejeita cadastro com `email` ja existente.
- CA06. O backend rejeita credenciais invalidas no login.
- CA07. O backend nao permite consultar nem atualizar perfil sem autenticacao
  valida.
- CA08. Nenhum contrato desta spec exige ou expoe dados de `places` ou
  `reviews`.

## Dependencias e restricoes

- A feature deve reutilizar o modulo `auth` existente em vez de recriar a base
  de autenticacao.
- O perfil simplificado deve seguir o dominio consolidado em
  `docs/MVP_DOMAIN_MODEL.md`.
- Esta spec deriva da spec-mae `specs/mvp-evaluation-flow/` e deve permanecer
  aderente ao roadmap em `docs/EXECUTION_NEXT_STEPS.md`.
- O endpoint autenticado pode usar a convencao final escolhida pelo projeto
  para perfil proprio, desde que permaneca consistente entre backend, frontend
  e testes.
- Esta entrega nao deve introduzir dependencias funcionais com `places` nem
  `reviews`.
