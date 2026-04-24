# ForkScore

Base inicial do ForkScore, um monólito modular para avaliação gastronômica de
restaurantes, cafeterias e similares.

## Visão do produto

Depois de visitar um local, a pessoa poderá registrar uma análise estruturada e
decidir se recomenda ou não o estabelecimento para outras pessoas.

## Constituição técnica inicial

- Backend em Python com FastAPI.
- Arquitetura hexagonal no backend.
- Banco SQLite no MVP.
- Autenticação com JWT.
- Frontend em Flutter com suporte a web e mobile.
- Organização monolítica com módulos separados em `backend/` e `frontend/`.

## Estrutura do projeto

```text
forkscore/
├── backend/
│   ├── pyproject.toml
│   ├── src/
│   │   ├── app/
│   │   └── modules/
│   │       ├── auth/
│   │       └── health/
│   └── tests/
├── frontend/
│   ├── lib/
│   │   ├── app/
│   │   ├── features/
│   │   └── shared/
│   └── test/
└── README.md
```

## Backend

Organização hexagonal por módulo:

```text
module/
├── domain/        # entidades, regras, ports
├── application/   # casos de uso e DTOs
├── infra/         # adapters e implementações técnicas
└── presentation/  # API HTTP
```

O backend já nasce com:

- ponto de entrada FastAPI;
- módulo de `health` funcional;
- esqueleto do módulo `auth`;
- `settings` centralizados;
- preparação para SQLite e JWT nas próximas etapas.

## Frontend

O módulo Flutter foi gerado para Android, iOS e Web e recebeu uma primeira tela
institucional do ForkScore para servir como base do app.

## Próximos passos sugeridos

1. Implementar persistência SQLite no backend com SQLAlchemy.
2. Fechar o fluxo de autenticação com registro e login via JWT.
3. Modelar os módulos `places` e `reviews`.
4. Criar no Flutter os fluxos de onboarding, login e cadastro de avaliação.
