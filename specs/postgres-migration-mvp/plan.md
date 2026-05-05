# Plan: postgres-migration-mvp

## Resumo tecnico

Migrar a persistencia principal do backend para PostgreSQL mantendo a troca
restrita a configuracao, infraestrutura SQLAlchemy, bootstrap/schema, testes e
documentacao. O dominio, os casos de uso, os contratos HTTP e o frontend nao
devem mudar funcionalmente.

O fluxo local deve usar `docker compose` para fornecer um PostgreSQL de
desenvolvimento, com `DATABASE_URL` documentada e reutilizavel em futuras
configuracoes de nuvem.

## Backend

- Modulos impactados:
  `auth`, `users`, `places` e `reviews` apenas pela persistencia;
  `shared/infra/database` para engine, sessao e inicializacao;
  `app/settings` para defaults e leitura de ambiente.
- Mudancas de dominio:
  nenhuma mudanca prevista.
- Mudancas de application:
  nenhuma mudanca prevista, salvo ajustes indiretos exigidos por testes.
- Mudancas de infraestrutura:
  adicionar driver PostgreSQL nas dependencias do backend;
  revisar `_engine_options` para manter opcoes SQLite apenas quando a URL for
  SQLite;
  revisar `init_database` para separar bootstrap generico de migrations
  especificas de SQLite;
  manter bootstrap controlado no MVP, sem Alembic nesta etapa;
  garantir que `seed_places_taxonomy` rode de forma idempotente em PostgreSQL;
  revisar modelos SQLAlchemy, FKs, indices, tipos `DateTime(timezone=True)`,
  `Date`, `Boolean`, `Float`, `String` e relacionamentos.
- Mudancas de presentation:
  nenhuma mudanca de rotas ou contratos.

## Frontend

- Nao ha mudanca funcional no frontend.
- O app Flutter deve continuar consumindo a mesma API.
- Qualquer ajuste frontend so deve ocorrer se a documentacao local precisar
  apontar para URL de API diferente em desenvolvimento.

## Dados e contratos

- Tabelas afetadas:
  `users`, `profiles`, `categories`, `subcategories`, `places`, `reviews` e
  `review_criteria`.
- Contratos afetados:
  nenhum contrato HTTP deve mudar.
- Estrategia de dados:
  criar schema limpo em PostgreSQL para desenvolvimento e testes locais;
  manter migracao de dados SQLite historicos fora de escopo;
  manter UUIDs como `String(36)` nesta primeira etapa, salvo decisao explicita
  na implementacao;
  tratar bootstrap SQLite legado como compatibilidade ou remover apenas quando
  houver decisao explicita na implementacao;
  preparar a configuracao para que um Postgres gerenciado use a mesma
  `DATABASE_URL`.
  Migrations versionadas ficam fora desta implementacao inicial e devem ser
  avaliadas em spec propria quando houver evolucao de schema com dados
  existentes.

## Docker compose e ambiente

- Criar ou atualizar `docker-compose.yml` com servico PostgreSQL local.
- Definir credenciais e database de desenvolvimento simples e documentadas.
- Separar banco de desenvolvimento e banco de testes no compose local.
- Atualizar `.env.example` para apontar para PostgreSQL local ou explicar a
  variavel principal esperada.
- Documentar comandos para:
  subir o banco local;
  iniciar o backend apontando para PostgreSQL;
  rodar testes backend contra PostgreSQL;
  encerrar ou recriar o banco local quando necessario.

## Testes

- Revisar `backend/tests/conftest.py`, que hoje usa SQLite em memoria.
- Definir se a suite principal deve rodar diretamente em PostgreSQL local ou se
  deve haver fixtures separadas para teste rapido e teste de compatibilidade.
- Cobrir os fluxos atuais de `auth`, `users`, `places` e `reviews` contra
  PostgreSQL.
- Validar que bootstraps e seeds sao idempotentes.
- Manter a validacao minima da area alterada:
  `cd backend && .venv/bin/pytest -q`.

## Dependencias e paralelismo

Esta spec deve ser executada com Agent Team sempre que possivel, em trilhas
curtas e coordenadas.

- Trilha 1: infraestrutura e configuracao do banco.
  Pode definir dependencia PostgreSQL, `DATABASE_URL`, `docker-compose.yml` e
  `.env.example`.
- Trilha 2: compatibilidade dos modulos backend e repositorios.
  Pode revisar modelos, repositories, queries, bootstrap e seed sem alterar
  dominio.
- Trilha 3: testes e validacao automatizada.
  Depende das decisoes da Trilha 1 e dos ajustes da Trilha 2 para fechar a
  suite contra PostgreSQL.
- Trilha 4: documentacao, setup local e fluxo de uso.
  Pode iniciar em paralelo com a Trilha 1, mas deve finalizar apos os comandos
  reais serem validados.

Dependencias praticas:

- A Trilha 1 deve estabilizar a URL e o compose antes da validacao final.
- A Trilha 2 pode avancar assim que a estrategia de conexao estiver clara.
- A Trilha 3 fecha por ultimo, pois confirma o comportamento integrado.
- A Trilha 4 deve refletir somente comandos e variaveis efetivamente usados.

## Riscos

- Risco: manter bootstrap ad hoc de SQLite misturado ao fluxo principal de
  PostgreSQL.
  Mitigacao: isolar codigo especifico por dialect ou por funcao nomeada.
- Risco: Postgres impor FKs e constraints que SQLite nao exercitava da mesma
  forma nos testes.
  Mitigacao: validar fixtures e seeds contra PostgreSQL antes da conclusao.
- Risco: a suite de testes ficar lenta ou fragil ao depender sempre de um banco
  externo.
  Mitigacao: documentar claramente o fluxo local e decidir fixtures separadas
  apenas se necessario.
- Risco: ajustes de SQLAlchemy alterarem regras de negocio por acidente.
  Mitigacao: limitar mudancas a infraestrutura e validar os fluxos HTTP ja
  existentes.
- Risco: `docker compose` virar configuracao de producao.
  Mitigacao: documentar compose como ferramenta local e manter producao baseada
  em `DATABASE_URL`.
