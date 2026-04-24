# SDD no ForkScore

Este projeto usa **Specification-Driven Development** para transformar uma
necessidade de produto em implementação rastreável.

## Objetivo

Garantir que agentes e pessoas trabalhem com o mesmo fluxo:

1. entender o problema;
2. escrever a especificação;
3. planejar a implementação;
4. quebrar em tarefas;
5. implementar;
6. validar;
7. abrir PR para `main`.

## Estrutura esperada

Cada feature relevante deve ter um diretório em `specs/`:

```text
specs/
└── <feature>/
    ├── spec.md
    ├── plan.md
    └── tasks.md
```

## Papel de cada arquivo

### `spec.md`

Descreve o que será construído.

Inclua:

- problema;
- objetivo;
- escopo;
- requisitos funcionais;
- requisitos não funcionais;
- critérios de aceite;
- dependências e restrições.

### `plan.md`

Descreve como a feature será implementada.

Inclua:

- módulos impactados;
- decisões técnicas;
- mudanças em backend;
- mudanças em frontend;
- estratégia de dados;
- estratégia de testes;
- riscos.

### `tasks.md`

Quebra o plano em tarefas executáveis.

Inclua:

- tarefas pequenas;
- ordem sugerida;
- responsáveis, quando fizer sentido;
- critérios objetivos para concluir cada item.

## Quando usar SDD

Use SDD sempre que a mudança:

- criar uma nova feature;
- mudar fluxo de usuário;
- alterar contratos da API;
- introduzir novo módulo;
- exigir múltiplos commits ou PRs;
- mexer em backend e frontend ao mesmo tempo.

Para correções pequenas, ajustes pontuais ou documentação simples, a spec pode
ser dispensada.

## Fluxo recomendado no Codex

1. Ler `AGENTS.md` e a constituição em `.specify/memory/constitution.md`.
2. Procurar spec existente para a feature.
3. Se não existir, criar `spec.md`, `plan.md` e `tasks.md`.
4. Implementar uma tarefa por vez.
5. Rodar validações da área alterada.
6. Atualizar a documentação afetada.
7. Fazer push da branch e deixar o PR automático para `main`.

## Validação mínima

### Backend

```bash
cd backend
.venv/bin/pytest -q
```

### Frontend

```bash
cd frontend
flutter analyze
flutter test
```

## Convenções de nome

- Diretório da spec: `specs/<feature-em-kebab-case>/`
- Branch: usar nome curto e orientado à feature
- Commits: descrever intenção, não só arquivo alterado

## Relação com Copilot e Codex

O Copilot usa bem prompts e instruções em `.github/`.
O Codex também se beneficia disso, mas trabalha melhor quando o repositório tem:

- instruções persistentes na raiz;
- specs vivas por feature;
- skills específicas do projeto;
- documentação operacional curta.

Por isso este projeto mantém:

- `.specify/` para a base SDD;
- `.github/` para integrações e automações;
- `.agents/skills/` para especialização do Codex;
- `AGENTS.md` como guia operacional principal.
