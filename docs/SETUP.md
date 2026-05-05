# Setup Inicial

## Banco local

O backend usa PostgreSQL como banco principal do MVP. Para subir um banco local:

```bash
docker compose up -d postgres
```

A URL local padrao esta em `backend/.env.example`:

```bash
DATABASE_URL=postgresql+psycopg://forkscore:forkscore@localhost:5432/forkscore
```

O compose tambem cria o banco `forkscore_test` para testes automatizados,
separado do banco de desenvolvimento.

Para recriar o volume local do banco quando precisar de um estado limpo:

```bash
docker compose down -v
docker compose up -d postgres
```

## Backend

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -e .[dev]
cp .env.example .env
uvicorn src.main:app --reload
```

O startup do backend cria o schema SQLAlchemy necessario para o MVP e executa o
seed idempotente da taxonomia de locais. Migrations versionadas ficam fora desta
etapa e devem ser avaliadas em spec propria quando o schema passar a exigir
evolucao controlada de dados existentes.

### Testes do backend

Por padrao, a suite automatizada usa SQLite em memoria para manter a validacao
rapida:

```bash
cd backend
.venv/bin/pytest -q
```

Para validar compatibilidade contra PostgreSQL local, suba o compose e informe
`TEST_DATABASE_URL`:

```bash
docker compose up -d postgres
cd backend
TEST_DATABASE_URL=postgresql+psycopg://forkscore:forkscore@localhost:5432/forkscore_test .venv/bin/pytest -q
```

## Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

O frontend usa a API real do backend por padrão. Para manter cadastro, login e
sessão coerentes com o PostgreSQL/JWT do projeto, inicie o banco e o backend
antes de abrir o app.

Se precisar rodar o frontend inteiramente em mocks para prototipação visual:

```bash
cd frontend
flutter run -d chrome --dart-define=FORKSCORE_USE_MOCKS=true
```

## Observacao sobre nuvem

Deploy final em nuvem e escolha de provedor gerenciado ficam fora deste setup.
O caminho esperado para nuvem e fornecer uma `DATABASE_URL` PostgreSQL
gerenciada no ambiente da aplicacao.
