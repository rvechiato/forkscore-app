# Prompts para Specs Pequenas

Este documento reúne prompts prontos para abrir novas sessões focadas nas specs
pequenas derivadas da spec-mãe do MVP.

## Referências-base para todas as sessões

Em todas as sessões, considere como fonte de verdade:

- `docs/MVP_DOMAIN_MODEL.md`
- `docs/EXECUTION_NEXT_STEPS.md`
- `specs/mvp-evaluation-flow/spec.md`
- `specs/mvp-evaluation-flow/plan.md`
- `specs/mvp-evaluation-flow/tasks.md`

## 1. Prompt: `auth-profile-mvp`

```text
Vamos iniciar a spec pequena `auth-profile-mvp` do ForkScore usando SDD.

Quero focar somente em autenticação e perfil básico do MVP, sem entrar ainda em places ou reviews.

Contexto do projeto:
- backend em FastAPI com arquitetura hexagonal
- frontend em Flutter
- fluxo SDD preparado no repositório
- já existe uma spec-mãe em `specs/mvp-evaluation-flow/`
- já existe o domínio consolidado em `docs/MVP_DOMAIN_MODEL.md`
- já existe um roadmap de execução em `docs/EXECUTION_NEXT_STEPS.md`

Quero que você use como base:
- `docs/MVP_DOMAIN_MODEL.md`
- `docs/EXECUTION_NEXT_STEPS.md`
- `specs/mvp-evaluation-flow/spec.md`
- `specs/mvp-evaluation-flow/plan.md`
- `specs/mvp-evaluation-flow/tasks.md`

Escopo desta spec pequena:
1. cadastro de usuário
2. login
3. perfil básico autenticado
4. consulta do próprio perfil
5. atualização do próprio perfil

Regras já definidas:
- autenticação com login e senha
- profile simplificado com:
  - nome
  - data de nascimento
  - email
- o email é atributo canônico do usuário
- a idade deve ser derivada de `birth_date` no momento da consulta
- o perfil deve ser vinculado ao usuário autenticado
- esta spec não deve incluir places nem reviews

Objetivo desta sessão:
Criar a estrutura da feature `specs/auth-profile-mvp/` com:
- `spec.md`
- `plan.md`
- `tasks.md`

Quero uma spec pequena, com poucas tasks, pronta para ser executada antes das demais.
```

## 2. Prompt: `places-mvp`

```text
Vamos iniciar a spec pequena `places-mvp` do ForkScore usando SDD.

Quero focar somente no cadastro e consulta de locais do MVP, sem entrar em reviews.

Contexto do projeto:
- backend em FastAPI com arquitetura hexagonal
- frontend em Flutter
- fluxo SDD preparado no repositório
- já existe uma spec-mãe em `specs/mvp-evaluation-flow/`
- já existe o domínio consolidado em `docs/MVP_DOMAIN_MODEL.md`
- já existe um roadmap de execução em `docs/EXECUTION_NEXT_STEPS.md`

Quero que você use como base:
- `docs/MVP_DOMAIN_MODEL.md`
- `docs/EXECUTION_NEXT_STEPS.md`
- `specs/mvp-evaluation-flow/spec.md`
- `specs/mvp-evaluation-flow/plan.md`
- `specs/mvp-evaluation-flow/tasks.md`

Escopo desta spec pequena:
1. cadastro de local
2. listagem de locais
3. detalhe de local
4. registro da autoria do cadastro

Regras já definidas:
- qualquer usuário autenticado pode cadastrar um local
- o local deve registrar quem cadastrou
- place deve conter:
  - nome
  - rua
  - número
  - bairro
  - cidade
- esta spec não deve incluir criação de reviews
- esta spec pode depender de usuário autenticado já existente

Objetivo desta sessão:
Criar a estrutura da feature `specs/places-mvp/` com:
- `spec.md`
- `plan.md`
- `tasks.md`

Quero uma spec pequena, com poucas tasks, pronta para ser executada após `auth-profile-mvp`.
```

## 3. Prompt: `reviews-create-mvp`

```text
Vamos iniciar a spec pequena `reviews-create-mvp` do ForkScore usando SDD.

Quero focar somente na criação de avaliações do MVP, sem detalhar ainda leitura avançada ou histórico no frontend.

Contexto do projeto:
- backend em FastAPI com arquitetura hexagonal
- frontend em Flutter
- fluxo SDD preparado no repositório
- já existe uma spec-mãe em `specs/mvp-evaluation-flow/`
- já existe o domínio consolidado em `docs/MVP_DOMAIN_MODEL.md`
- já existe um roadmap de execução em `docs/EXECUTION_NEXT_STEPS.md`

Quero que você use como base:
- `docs/MVP_DOMAIN_MODEL.md`
- `docs/EXECUTION_NEXT_STEPS.md`
- `specs/mvp-evaluation-flow/spec.md`
- `specs/mvp-evaluation-flow/plan.md`
- `specs/mvp-evaluation-flow/tasks.md`

Escopo desta spec pequena:
1. criação de review para um local
2. aplicação das regras dos critérios qualitativos
3. aplicação do `cost_benefit_rating`
4. aplicação da recomendação final

Regras já definidas:
- critérios qualitativos fixos:
  - sabor
  - atendimento
  - opções
  - infraestrutura
- cada critério qualitativo usa rating inteiro de 1 a 5
- cada critério qualitativo exige comentário obrigatório
- justificativa é obrigatória quando a nota for menor que 3
- `cost_benefit_rating` é obrigatório e usa rating inteiro de 1 a 5
- `cost_benefit_rating` não exige comentário no MVP
- `recommended` é obrigatório e é decisão final explícita
- múltiplas reviews do mesmo usuário para o mesmo local são permitidas
- esta spec depende de auth e places já definidos

Objetivo desta sessão:
Criar a estrutura da feature `specs/reviews-create-mvp/` com:
- `spec.md`
- `plan.md`
- `tasks.md`

Quero uma spec pequena, com poucas tasks, centrada no núcleo do domínio de avaliação.
```

## 4. Prompt: `authenticated-app-shell`

```text
Vamos iniciar a spec pequena `authenticated-app-shell` do ForkScore usando SDD.

Quero focar somente na estrutura do app autenticado no frontend, sem redesenhar o domínio do backend.

Contexto do projeto:
- backend em FastAPI com arquitetura hexagonal
- frontend em Flutter
- fluxo SDD preparado no repositório
- já existe uma spec-mãe em `specs/mvp-evaluation-flow/`
- já existe o domínio consolidado em `docs/MVP_DOMAIN_MODEL.md`
- já existe um roadmap de execução em `docs/EXECUTION_NEXT_STEPS.md`

Quero que você use como base:
- `docs/MVP_DOMAIN_MODEL.md`
- `docs/EXECUTION_NEXT_STEPS.md`
- `specs/mvp-evaluation-flow/spec.md`
- `specs/mvp-evaluation-flow/plan.md`
- `specs/mvp-evaluation-flow/tasks.md`

Escopo desta spec pequena:
1. shell autenticado do aplicativo
2. navegação entre perfil, locais e avaliação
3. persistência de sessão/token
4. estados de loading, erro e sucesso

Regras já definidas:
- o usuário autenticado deve conseguir navegar entre os blocos principais do MVP
- a estrutura deve respeitar:
  - `lib/app`
  - `lib/features`
  - `lib/shared`
- esta spec não deve redefinir contratos do backend, apenas consumi-los

Objetivo desta sessão:
Criar a estrutura da feature `specs/authenticated-app-shell/` com:
- `spec.md`
- `plan.md`
- `tasks.md`

Quero uma spec pequena, com poucas tasks, focada em navegação e organização do frontend autenticado.
```

## 5. Prompt: `review-read-model-mvp`

```text
Vamos iniciar a spec pequena `review-read-model-mvp` do ForkScore usando SDD.

Quero focar somente na leitura de avaliações já criadas, sem expandir o escopo para ranking, médias ou recursos sociais.

Contexto do projeto:
- backend em FastAPI com arquitetura hexagonal
- frontend em Flutter
- fluxo SDD preparado no repositório
- já existe uma spec-mãe em `specs/mvp-evaluation-flow/`
- já existe o domínio consolidado em `docs/MVP_DOMAIN_MODEL.md`
- já existe um roadmap de execução em `docs/EXECUTION_NEXT_STEPS.md`

Quero que você use como base:
- `docs/MVP_DOMAIN_MODEL.md`
- `docs/EXECUTION_NEXT_STEPS.md`
- `specs/mvp-evaluation-flow/spec.md`
- `specs/mvp-evaluation-flow/plan.md`
- `specs/mvp-evaluation-flow/tasks.md`

Escopo desta spec pequena:
1. consultar detalhe de reviews
2. listar reviews por local
3. exibir histórico básico de avaliações

Regras já definidas:
- múltiplas reviews do mesmo usuário para o mesmo local são permitidas
- a leitura deve respeitar o domínio já definido
- esta spec não deve incluir cálculo de média, ranking ou recomendação automática

Objetivo desta sessão:
Criar a estrutura da feature `specs/review-read-model-mvp/` com:
- `spec.md`
- `plan.md`
- `tasks.md`

Quero uma spec pequena, com poucas tasks, focada apenas em leitura e exibição de avaliações.
```

## 6. Prompt: `mvp-polish-and-validation`

```text
Vamos iniciar a spec pequena `mvp-polish-and-validation` do ForkScore usando SDD.

Quero focar no fechamento do primeiro ciclo do MVP, com refinamento, validação e consistência final.

Contexto do projeto:
- backend em FastAPI com arquitetura hexagonal
- frontend em Flutter
- fluxo SDD preparado no repositório
- já existe uma spec-mãe em `specs/mvp-evaluation-flow/`
- já existe o domínio consolidado em `docs/MVP_DOMAIN_MODEL.md`
- já existe um roadmap de execução em `docs/EXECUTION_NEXT_STEPS.md`

Quero que você use como base:
- `docs/MVP_DOMAIN_MODEL.md`
- `docs/EXECUTION_NEXT_STEPS.md`
- `specs/mvp-evaluation-flow/spec.md`
- `specs/mvp-evaluation-flow/plan.md`
- `specs/mvp-evaluation-flow/tasks.md`

Escopo desta spec pequena:
1. revisão de UX do MVP
2. consistência final dos contratos
3. cobertura adicional de testes
4. documentação operacional final do ciclo

Regras já definidas:
- não expandir escopo de produto
- não introduzir novas features
- focar em qualidade, consistência e validação do que já foi construído

Objetivo desta sessão:
Criar a estrutura da feature `specs/mvp-polish-and-validation/` com:
- `spec.md`
- `plan.md`
- `tasks.md`

Quero uma spec pequena, com poucas tasks, focada em consolidar e validar o MVP implementado.
```

## Ordem recomendada

1. `auth-profile-mvp`
2. `places-mvp`
3. `reviews-create-mvp`
4. `authenticated-app-shell`
5. `review-read-model-mvp`
6. `mvp-polish-and-validation`
