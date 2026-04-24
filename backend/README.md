# Backend

Backend em Python com FastAPI e arquitetura hexagonal.

## Executar

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -e .[dev]
uvicorn src.main:app --reload
```

## Estrutura

```text
src/
├── app/
│   ├── api.py
│   └── settings.py
└── modules/
    ├── auth/
    └── health/
```

