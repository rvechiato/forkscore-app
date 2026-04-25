# Próximos Passos do MVP

Este documento consolida o contexto do projeto até aqui e define o melhor
próximo passo antes da escrita da próxima especificação.

## Contexto consolidado

O ForkScore é um aplicativo de avaliação gastronômica para restaurantes,
cafeterias e estabelecimentos similares.

A proposta central é:

- a pessoa visita um local;
- registra sua análise gastronômica;
- informa se recomenda ou não o local para outras pessoas.

## Estado atual do projeto

Atualmente o repositório já possui:

- backend em Python com FastAPI;
- arquitetura hexagonal no backend;
- base de autenticação inicial com SQLite + JWT;
- frontend em Flutter para web e mobile;
- fluxo de CI e PR para `main`;
- estrutura SDD preparada para uso com Codex.

## Direção de produto

As features já discutidas até aqui são:

### Core da aplicação

#### Cadastro de locais

O sistema deve permitir cadastrar locais que serão avaliados no aplicativo.

#### Avaliação gastronômica

Regras desejadas para a primeira versão:

- avaliação simples;
- 4 critérios qualitativos no MVP;
- critérios definidos:
  - sabor;
  - atendimento;
  - opções;
  - infraestrutura do local;
- avaliação por estrelas, de `1` a `5`;
- custo-benefício com rating inteiro de `1` a `5`;
- comentário obrigatório para cada item avaliado;
- justificativa obrigatória quando a nota for menor que `3`;
- decisão final se recomenda ou não o local.

### Funcionalidades de suporte

- cadastro com login e senha;
- cadastro e manutenção de perfil simplificado.

## Melhor próximo passo

Antes de detalhar implementação, o melhor próximo passo é definir o recorte do
MVP de forma objetiva.

### Recomendação

Organizar o MVP em 3 blocos:

1. autenticação e perfil básico;
2. cadastro e consulta de locais;
3. avaliação gastronômica.

## Recorte sugerido para o MVP 1

Para manter o produto enxuto e validável, a recomendação é:

### Autenticação e perfil

- usuário cria conta;
- usuário faz login;
- usuário possui perfil básico com:
  - nome;
  - data de nascimento;
  - email.

### Locais

- usuário cadastra um local;
- usuário lista e consulta locais;
- usuário acessa o detalhe de um local.
- qualquer usuário autenticado pode cadastrar um local manualmente.
- o local deve registrar quem realizou o cadastro.
- o cadastro mínimo do local deve conter:
  - nome;
  - rua;
  - número;
  - bairro;
  - cidade.

### Avaliação

- avaliação com 4 critérios qualitativos no MVP;
- custo-benefício como rating adicional;
- estrelas de `1` a `5`;
- comentário obrigatório por critério;
- justificativa obrigatória para nota menor que `3`;
- resposta final:
  - recomendaria;
  - não recomendaria.

## Recomendação de critérios para o MVP

Para a primeira especificação, os critérios definidos para o MVP são:

- sabor;
- atendimento;
- opções;
- infraestrutura.

## Entidades mínimas já esperadas para a próxima spec

A próxima especificação já pode considerar pelo menos estas entidades de
domínio:

- `User`
- `Profile`
- `Place`
- `Review`
- `ReviewCriterion`

## Base de domínio consolidada

As definições de domínio e modelo de dados do MVP foram consolidadas em
[docs/MVP_DOMAIN_MODEL.md](/Users/rvechiato/ForkScore/forkscore/docs/MVP_DOMAIN_MODEL.md)
e devem ser tratadas como referência para futuras features ligadas ao fluxo
principal.

## O que a próxima especificação deve responder

A próxima spec deve deixar claro:

- quais entidades entram no MVP;
- quais critérios farão parte da primeira versão;
- como funciona o fluxo completo de avaliação;
- quais endpoints e telas serão necessários;
- quais validações são obrigatórias;
- o que fica fora do MVP.

## Resultado esperado da próxima sessão

Ao final da próxima sessão, devemos sair com uma nova spec de feature contendo:

- `spec.md`;
- `plan.md`;
- `tasks.md`.

## Nome sugerido da próxima feature

Um bom nome inicial para a próxima spec é:

`mvp-evaluation-flow`

ou, se quisermos enfatizar o domínio:

`place-and-review-mvp`
