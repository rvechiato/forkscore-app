# Roadmap de Execução do MVP

Este documento organiza a sequência recomendada para iniciar o desenvolvimento
do ForkScore a partir da spec-mãe já existente em:

- `specs/mvp-evaluation-flow/spec.md`
- `specs/mvp-evaluation-flow/plan.md`
- `specs/mvp-evaluation-flow/tasks.md`

O objetivo aqui é transformar o MVP principal em especificações menores, com
poucas tasks, para facilitar execução em sessões curtas e paralelas quando
possível.

## Situação atual

O projeto já possui:

- arquitetura definida;
- fluxo SDD configurado;
- CI e proteção de `main`;
- base de autenticação inicial;
- domínio do MVP consolidado em `docs/MVP_DOMAIN_MODEL.md`;
- spec principal do fluxo do MVP em `specs/mvp-evaluation-flow/`.

## Análise de pendências para iniciar

## Pendências críticas

No momento, **não há pendência crítica bloqueando o início do desenvolvimento**.

O domínio do MVP já está suficientemente definido para começar a implementação
em fatias pequenas.

## Pendências não bloqueantes

Estas decisões podem ser resolvidas dentro das próximas specs pequenas, sem
impedir o início do trabalho:

- nome final dos endpoints de perfil autenticado, por exemplo `GET /me` versus
  `GET /users/me`;
- se a primeira entrega de reviews inclui apenas criação ou também leitura
  detalhada/listagem por local;
- detalhes de UX do formulário de avaliação, desde que respeitem as regras do
  domínio;
- forma exata de exibição da autoria do local no frontend.

## Estratégia recomendada

Usar a spec `mvp-evaluation-flow` como **spec-mãe** e criar pequenas specs de
execução derivadas dela.

Cada pequena spec deve:

- focar em um único bloco coerente;
- ter poucas tasks;
- ter fronteira técnica clara;
- ser validável isoladamente.

## Ordem sugerida dos próximos passos

### 1. Spec pequena: `auth-profile-mvp`

Escopo:

- finalizar cadastro e login do usuário;
- expor perfil básico;
- consultar perfil autenticado;
- atualizar perfil autenticado.

Motivo da ordem:

- autenticação é a base do restante do sistema;
- locais e avaliações dependem de usuário autenticado.

Saída esperada:

- spec pequena;
- tarefas pequenas de backend;
- tarefas pequenas de frontend para login e perfil.

### 2. Spec pequena: `places-mvp`

Escopo:

- cadastrar local;
- listar locais;
- consultar detalhe de local;
- registrar autoria do cadastro.

Motivo da ordem:

- reviews dependem de locais existentes;
- frontend já pode começar a navegar no catálogo básico.

Saída esperada:

- backend de `places`;
- contratos de API de locais;
- telas de listagem, cadastro e detalhe.

### 3. Spec pequena: `reviews-create-mvp`

Escopo:

- criar avaliação;
- aplicar regras dos critérios qualitativos;
- aplicar `cost_benefit_rating`;
- aplicar recomendação final;
- validar comentário obrigatório;
- validar justificativa quando nota < 3.

Motivo da ordem:

- este é o núcleo do produto;
- depende de `auth` e `places`, mas pode ser bem isolado em uma spec própria.

Saída esperada:

- domínio de `reviews`;
- rota de criação de avaliação;
- formulário de avaliação no frontend.

### 4. Spec pequena: `authenticated-app-shell`

Escopo:

- organizar shell autenticado do frontend;
- navegação entre perfil, locais e avaliação;
- persistência de sessão/token;
- estados de loading, erro e sucesso.

Motivo da ordem:

- pode avançar em paralelo parcial com `places` e `reviews`;
- melhora integração do fluxo completo.

Saída esperada:

- estrutura de navegação coerente;
- base do app autenticado pronta para crescer.

### 5. Spec pequena: `review-read-model-mvp`

Escopo:

- consultar detalhe de avaliações;
- listar avaliações por local;
- exibir histórico básico de reviews.

Motivo da ordem:

- não é estritamente necessário para começar o core;
- entra logo depois que a criação de reviews estiver estável.

Saída esperada:

- endpoints de leitura;
- telas de exibição associadas ao local.

### 6. Spec pequena: `mvp-polish-and-validation`

Escopo:

- revisão de UX;
- consistência de contratos;
- testes adicionais;
- documentação final do MVP implementado.

Motivo da ordem:

- fecha o primeiro ciclo com menor risco;
- evita refino prematuro.

## Ordem resumida

1. `auth-profile-mvp`
2. `places-mvp`
3. `reviews-create-mvp`
4. `authenticated-app-shell`
5. `review-read-model-mvp`
6. `mvp-polish-and-validation`

## O que pode rodar em paralelo

Depois da spec de `auth-profile-mvp` estar clara:

- frontend de login/perfil;
- modelagem de `places`;
- definição do shell autenticado.

Depois da spec de `places-mvp` estar clara:

- frontend de locais;
- backend de criação de review;
- UX detalhada do formulário de avaliação.

## Recomendação prática para não se perder

Abra uma sessão por spec pequena e mantenha sempre o mesmo ritual:

1. revisar `docs/MVP_DOMAIN_MODEL.md`;
2. revisar a spec-mãe `specs/mvp-evaluation-flow/`;
3. criar a nova spec pequena;
4. escrever poucas tasks;
5. implementar somente aquele bloco;
6. validar e subir PR.

## Próximo passo imediato recomendado

Se a intenção é iniciar o desenvolvimento agora, o melhor próximo passo é:

### Criar a spec pequena `auth-profile-mvp`

Ela deve conter:

- spec;
- plan;
- tasks;
- critérios de aceite limitados a autenticação e perfil.

Isso prepara a base para todas as demais entregas do MVP.
