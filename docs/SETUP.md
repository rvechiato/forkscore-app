# Setup Inicial

## Backend

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -e .[dev]
uvicorn src.main:app --reload
```

## Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

O frontend usa a API real do backend por padrão. Para manter cadastro, login e
sessão coerentes com o SQLite/JWT do projeto, inicie o backend antes de abrir o
app.

Se precisar rodar o frontend inteiramente em mocks para prototipação visual:

```bash
cd frontend
flutter run -d chrome --dart-define=FORKSCORE_USE_MOCKS=true
```

## Próxima entrega sugerida

Fechar o módulo de autenticação com:

- entidade de usuário persistida em SQLite;
- hash de senha;
- geração e validação de JWT;
- rotas reais de registro e login.
