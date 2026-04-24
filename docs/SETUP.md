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

## Próxima entrega sugerida

Fechar o módulo de autenticação com:

- entidade de usuário persistida em SQLite;
- hash de senha;
- geração e validação de JWT;
- rotas reais de registro e login.

