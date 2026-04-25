# Briefing da Próxima Sessão

Use este briefing para abrir a próxima sessão de trabalho focada em
especificação.

## Objetivo da próxima sessão

Criar a especificação do próximo passo do ForkScore, com foco no MVP de
cadastro de locais e avaliação gastronômica.

## Contexto que deve ser considerado

O ForkScore é um aplicativo cuja finalidade é permitir que a pessoa, após ir a
um restaurante, cafeteria ou local semelhante, faça uma análise gastronômica e
sugira ou não o local para outras pessoas.

O projeto já possui:

- backend em FastAPI com arquitetura hexagonal;
- autenticação inicial com SQLite + JWT;
- frontend em Flutter;
- fluxo SDD preparado para Codex;
- `main` protegida com CI e PR flow.

## Escopo candidato para a próxima spec

O foco da próxima especificação deve ser o recorte do MVP com:

1. autenticação e perfil básico;
2. cadastro de locais;
3. avaliação gastronômica com 4 critérios;
4. recomendação final do local.

## Regras de negócio que devem entrar na discussão

- avaliação por estrelas de `1` a `5`;
- custo-benefício com rating inteiro de `1` a `5`;
- comentário obrigatório para cada critério;
- justificativa obrigatória se a nota for menor que `3`;
- recomendaria ou não o local ao final;
- critérios definidos para o MVP:
  - sabor;
  - atendimento;
  - opções;
  - infraestrutura.
- profile simplificado com:
  - nome;
  - data de nascimento;
  - email.
- place com:
  - nome;
  - rua;
  - número;
  - bairro;
  - cidade.
- qualquer usuário autenticado pode cadastrar um local.
- o local deve registrar quem cadastrou.

## Saída esperada

Criar uma nova estrutura em `specs/<feature>/` com:

- `spec.md`;
- `plan.md`;
- `tasks.md`.

## Prompt sugerido para iniciar a próxima sessão

```text
Vamos criar a especificação do próximo passo do ForkScore usando SDD.

Considere o contexto atual do projeto:
- backend em FastAPI com arquitetura hexagonal
- frontend em Flutter
- autenticação inicial já existente
- fluxo SDD preparado no repositório

Quero especificar o MVP do fluxo principal da aplicação, incluindo:
1. autenticação e perfil básico
2. cadastro de locais
3. avaliação gastronômica
4. recomendação final do local

Regras importantes:
- avaliação por estrelas de 1 a 5
- custo-benefício com rating inteiro de 1 a 5
- comentário obrigatório por critério
- justificativa obrigatória quando a nota for menor que 3
- critérios definidos no MVP: sabor, atendimento, opções e infraestrutura
- profile simplificado com nome, data de nascimento e email
- place com nome, rua, número, bairro e cidade
- qualquer usuário autenticado pode cadastrar um local
- o local deve registrar quem cadastrou

Vamos criar a spec completa em specs/<feature>/ com spec.md, plan.md e tasks.md.
```
