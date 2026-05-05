# Spec: postgres-migration-mvp

## Contexto

O ForkScore usa FastAPI com arquitetura hexagonal no backend e hoje executa a
persistencia principal em SQLite. O dominio do MVP ja e relacional e gira em
torno de `users`, `profiles`, `places` e `reviews`, com SQLAlchemy isolado na
camada de infraestrutura.

A decisao arquitetural desta feature ja esta tomada: manter banco relacional e
migrar a persistencia principal do backend para PostgreSQL, preparando o
projeto para uso local mais proximo de producao e futuro deploy em nuvem com
banco persistente.

## Objetivo

Preparar o backend do ForkScore para usar PostgreSQL como banco principal do
MVP, preservando dominio, casos de uso, contratos HTTP e organizacao
hexagonal. A mudanca deve manter o fluxo local simples por meio de
`docker compose` e documentacao clara de `DATABASE_URL`.

## Escopo

- trocar a dependencia pratica de SQLite por PostgreSQL no ambiente principal
  do backend;
- revisar configuracao de conexao por `DATABASE_URL`;
- revisar engine, factories de sessao e bootstrap de banco;
- revisar se a entrega deve introduzir migrations versionadas ou manter
  bootstrap controlado no MVP com decisao documentada;
- garantir compatibilidade dos modulos `auth`, `users`, `places` e `reviews`;
- revisar modelos SQLAlchemy e queries existentes para execucao em PostgreSQL;
- incluir fluxo local com `docker compose` para subir PostgreSQL;
- definir estrategia de testes locais do backend usando PostgreSQL;
- atualizar documentacao de setup afetada.

## Fora de escopo

- migrar o frontend ou alterar persistencia local do app Flutter;
- migrar para NoSQL;
- trocar SQLAlchemy ou introduzir outro ORM;
- alterar regras de negocio, dominio ou contratos publicos de API;
- reescrever repositorios sem necessidade de compatibilidade com PostgreSQL;
- executar deploy final em nuvem;
- escolher provedor gerenciado definitivo para producao;
- implementar observabilidade avancada ou otimizacoes profundas de performance;
- migrar dados historicos de arquivos SQLite existentes, salvo decisao futura
  em spec propria.

## Requisitos funcionais

- RF01. O backend deve iniciar usando uma `DATABASE_URL` PostgreSQL valida.
- RF02. O bootstrap do banco deve criar ou preparar o schema necessario para
  `auth`, `users`, `places` e `reviews` sem alterar o dominio.
- RF03. O seed da taxonomia de locais deve funcionar em PostgreSQL.
- RF04. Os fluxos existentes de cadastro/login, perfil, locais e reviews devem
  continuar funcionando sem mudanca funcional para o usuario.
- RF05. Deve existir um fluxo simples para subir PostgreSQL localmente com
  `docker compose`.
- RF06. Deve existir um fluxo documentado para rodar testes locais do backend
  contra PostgreSQL.

## Requisitos nao funcionais

- RNF01. A arquitetura hexagonal deve ser preservada; mudancas de banco devem
  ficar na camada de infraestrutura e configuracao.
- RNF02. O dominio e os casos de uso nao devem depender de detalhes de
  PostgreSQL.
- RNF03. O ambiente local deve continuar simples para novas sessoes e novos
  colaboradores.
- RNF04. A configuracao deve preparar o caminho para banco PostgreSQL gerenciado
  em nuvem via variaveis de ambiente.
- RNF05. Os testes automatizados afetados devem deixar claro quando rodam com
  PostgreSQL e quando usam alternativa local.
- RNF06. A feature deve evitar complexidade prematura, mantendo escopo limitado
  a compatibilidade, configuracao, bootstrap, testes e documentacao.
- RNF07. A primeira etapa deve preferir compatibilidade conservadora de schema,
  incluindo manter UUIDs como `String(36)` se isso reduzir risco.

## Criterios de aceite

- CA01. `DATABASE_URL` aceita uma URL PostgreSQL documentada para ambiente
  local e futuro ambiente gerenciado.
- CA02. O backend inicializa contra PostgreSQL local sem depender de arquivos
  SQLite.
- CA03. As tabelas de `users`, `profiles`, `categories`, `subcategories`,
  `places`, `reviews` e `review_criteria` sao criadas ou preparadas de forma
  compativel com PostgreSQL.
- CA04. O seed de categorias e subcategorias continua idempotente.
- CA05. A estrategia de migrations/bootstrap fica documentada e compativel com
  PostgreSQL.
- CA06. A suite backend possui estrategia clara para validar os fluxos atuais
  contra PostgreSQL.
- CA07. O fluxo local com `docker compose` esta previsto para subir o banco e
  facilitar testes.
- CA08. `docs/SETUP.md` orienta como configurar, iniciar e testar o backend com
  PostgreSQL.
- CA09. Nenhum contrato funcional do frontend ou da API e alterado por causa da
  migracao.

## Dependencias e restricoes

- A feature depende da arquitetura atual descrita em `docs/ARCHITECTURE.md`.
- A modelagem relacional deve seguir `docs/MVP_DOMAIN_MODEL.md`.
- O backend deve continuar usando SQLAlchemy.
- `docker compose` deve ser usado apenas como apoio local de desenvolvimento e
  testes, nao como decisao de producao.
- O trabalho deve considerar os acoplamentos SQLite atuais em
  `backend/src/app/settings.py`,
  `backend/src/shared/infra/database/session.py`,
  `backend/src/modules/places/infra/database/bootstrap.py`,
  `backend/.env.example` e `backend/tests/conftest.py`.
