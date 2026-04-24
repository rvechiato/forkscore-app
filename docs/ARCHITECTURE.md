# Arquitetura Inicial

## Monólito modular

O ForkScore será mantido como um monólito com dois módulos principais:

- `backend/`: API REST com FastAPI e arquitetura hexagonal.
- `frontend/`: aplicação Flutter com suporte a web e mobile.

## Backend

Cada módulo do backend seguirá a separação:

- `domain`: entidades, regras e ports.
- `application`: casos de uso e DTOs.
- `infra`: implementações técnicas.
- `presentation`: camada HTTP.

## Módulos previstos

- `auth`: autenticação e autorização com JWT.
- `users`: perfil do usuário.
- `places`: cadastro e consulta de estabelecimentos.
- `reviews`: avaliação gastronômica e recomendação.
- `health`: observabilidade básica da API.

## Referência de domínio do MVP

As futuras features que tocarem o fluxo principal do produto devem reutilizar a
base definida em [docs/MVP_DOMAIN_MODEL.md](/Users/rvechiato/ForkScore/forkscore/docs/MVP_DOMAIN_MODEL.md).

## Banco de dados

Na primeira fase, a persistência será em SQLite. A infraestrutura deve ser
isolada para permitir migração futura para PostgreSQL sem afetar as regras de
negócio.
