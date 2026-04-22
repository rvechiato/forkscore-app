# Implementation Plan: Sistema Completo de Avaliação de Locais

**Branch**: `002-mobile-rating-system` | **Date**: April 22, 2026 | **Spec**: [spec.md](spec.md)
**Input**: Aplicativo mobile para avaliação de locais com autenticação, perfil, cadastro de lugares e sistema de avaliação com estrelas (0-5) e comentários com regras de justificativa.

## Summary

**Core Value Proposition**: Aplicativo mobile que permite usuários avaliar locais (restaurantes, bares, cafés) através de um sistema simples de 4 critérios com estrelas (0-5), comentários e justificativas obrigatórias para avaliações negativas. Diferencial: simplicidade de UX (avaliação em < 1 min) + regras de negócio rígidas (comentários obrigatórios, justificativas para < 3 ⭐).

**Technical Approach**: 
- **Architecture**: Arquitetura Hexagonal (Ports & Adapters) para máxima testabilidade e evolução tecnológica
- **Frontend**: Flutter para cross-platform mobile
- **Backend**: NestJS + Node.js em API REST stateless com JWT
- **Database**: SQLite em Fase 1, migration path para PostgreSQL
- **Organization**: Modular por domínio (users, auth, places, reviews, shared)

## Technical Context

**Language/Version**: 
- Frontend: Dart 3.x (Flutter)
- Backend: Node.js 18+ com TypeScript 5.x (NestJS 10+)

**Primary Dependencies**: 
- Frontend: Flutter, Provider/Riverpod (state management), http (API client)
- Backend: NestJS, TypeORM (ORM), bcrypt (password hashing), jsonwebtoken (JWT), sqlite3

**Storage**: SQLite (Fase 1), migration path para PostgreSQL (Fase 2+)

**Testing**: 
- Frontend: Flutter test framework, mocktail
- Backend: Jest (unitários), NestJS testing utilities (integração)

**Target Platform**: iOS 12+ e Android 8+ (Flutter)

**Project Type**: Mobile app + Backend API (monólito modular)

**Performance Goals**: 
- Frontend: 60 fps animations, avaliação completável em < 1 minuto
- Backend: resposta < 200ms p95, suportar 100 req/s em MVP

**Constraints**: 
- Avaliação deve ser intuitiva e lúdica (UI simples)
- Cada critério deve ter comentário obrigatório
- Comentário é justificativa obrigatória se rating < 3
- Sem criptografia de dados em repouso (MVP)
- Conexão à internet obrigatória (offline fora do escopo do MVP)

**Scale/Scope**: 
- MVP: 1 feature completa (avaliação de locais) com auth
- Estimado: 15-20 screens mobile, 8-10 endpoints backend
- Dados: 100s de usuários e 1000s de avaliações no MVP

## Constitution Check

**Gates determined based on constitution file**: Todos os gates passam ✅

### Verificação de Conformidade (ForkScore Constitution v1.0.0)

| Princípio | Verificação | Status |
|-----------|------------|--------|
| **I. Simplicidade Primeiro** | Foco em MVP com valor imediato: autenticação + avaliação simples | ✅ PASS |
| **II. Separação de Responsabilidades** | Arquitetura Hexagonal com camadas: Presentation → Application → Domain ← Infrastructure | ✅ PASS |
| **III. Escalabilidade Progressiva** | Monólito modular em Fase 1 com SQLite; migration path para PostgreSQL + Redis | ✅ PASS |
| **IV. Testabilidade** | Domínio sem dependências externas, repositórios mockáveis via ports | ✅ PASS |
| **V. Design User-Centric** | Avaliação < 1 min, sistema de 4 critérios com estrelas, comentários obrigatórios | ✅ PASS |
| **Padrão Arquitetural** | Hexagonal com Ports & Adapters para isolamento de domínio | ✅ PASS |
| **Frontend: Flutter** | Tecnologia conforme constituição, state management com Provider/Riverpod | ✅ PASS |
| **Backend: NestJS** | Node.js + TypeScript conforme constituição, modular por domínio | ✅ PASS |
| **Database: SQLite → PostgreSQL** | Path claro de migração via camada de infraestrutura | ✅ PASS |
| **Autenticação: JWT + bcrypt** | Conforme diretrizes de segurança | ✅ PASS |

**Result**: ✅ **GATE APPROVED** — Feature está alinhada com Constitution. Nenhuma violação.

## Project Structure

### Documentation (this feature)

```text
specs/002-rating-system-complete/
├── spec.md                    # Feature specification (✅ Done)
├── plan.md                    # This file (Phase 0-1 output)
├── research.md                # Phase 0 output (teknoloji researches, patterns, best practices)
├── data-model.md              # Phase 1 output (domain entities, value objects, aggregates)
├── contracts/                 # Phase 1 output (API contracts if applicable)
│   └── api-endpoints.md       # REST API contract definition
└── checklists/
    └── requirements.md        # Quality checklist
```

### Source Code (repository root)

**Selected Structure**: Mobile + Backend (Flutter + NestJS)

```text
/
├── backend/                           # NestJS API (Monólito Modular)
│   ├── src/
│   │   ├── app.module.ts              # Root module
│   │   ├── main.ts                    # Entry point
│   │   ├── config/                    # Configurações globais
│   │   │   ├── database.config.ts
│   │   │   └── auth.config.ts
│   │   ├── common/                    # Compartilhado globalmente
│   │   │   ├── decorators/
│   │   │   ├── filters/               # Exception filters
│   │   │   ├── guards/                # Auth guards
│   │   │   └── pipes/                 # Validation pipes
│   │   │
│   │   └── modules/                   # Módulos por Domínio (Clean Arch)
│   │       │
│   │       ├── auth/
│   │       │   ├── domain/
│   │       │   │   ├── auth.types.ts           # Domain types/enums
│   │       │   │   ├── auth.exception.ts       # Domain exceptions
│   │       │   │   └── ports/
│   │       │   │       └── auth.repository.ts  # Port (interface)
│   │       │   ├── application/
│   │       │   │   ├── auth.service.ts         # Orquestrador
│   │       │   │   └── dtos/
│   │       │   │       ├── register.dto.ts
│   │       │   │       └── login.dto.ts
│   │       │   ├── infra/
│   │       │   │   ├── adapters/
│   │       │   │   │   └── auth.sqlite.adapter.ts  # Repository implementation
│   │       │   │   ├── hash/
│   │       │   │   │   └── bcrypt.hasher.ts
│   │       │   │   └── jwt/
│   │       │   │       └── jwt.strategy.ts
│   │       │   ├── auth.module.ts
│   │       │   └── presentation/
│   │       │       ├── auth.controller.ts
│   │       │       └── auth.routes.ts
│   │       │
│   │       ├── users/
│   │       │   ├── domain/
│   │       │   │   ├── entities/
│   │       │   │   │   └── user.entity.ts         # Domain entity
│   │       │   │   ├── ports/
│   │       │   │   │   └── user.repository.ts
│   │       │   │   └── user.exception.ts
│   │       │   ├── application/
│   │       │   │   ├── users.service.ts
│   │       │   │   ├── dtos/
│   │       │   │   │   └── create-user.dto.ts
│   │       │   │   └── mappers/
│   │       │   │       └── user.mapper.ts
│   │       │   ├── infra/
│   │       │   │   ├── adapters/
│   │       │   │   │   └── user.sqlite.adapter.ts
│   │       │   │   ├── entities/
│   │       │   │   │   └── user.db.entity.ts     # DB schema
│   │       │   │   └── migrations/
│   │       │   ├── users.module.ts
│   │       │   └── presentation/
│   │       │       └── users.controller.ts
│   │       │
│   │       ├── places/
│   │       │   ├── domain/
│   │       │   │   ├── entities/
│   │       │   │   │   └── place.entity.ts
│   │       │   │   ├── ports/
│   │       │   │   │   └── place.repository.ts
│   │       │   │   └── place.exception.ts
│   │       │   ├── application/
│   │       │   │   ├── places.service.ts
│   │       │   │   └── dtos/
│   │       │   │       └── create-place.dto.ts
│   │       │   ├── infra/
│   │       │   │   ├── adapters/
│   │       │   │   │   └── place.sqlite.adapter.ts
│   │       │   │   └── entities/
│   │       │   │       └── place.db.entity.ts
│   │       │   ├── places.module.ts
│   │       │   └── presentation/
│   │       │       └── places.controller.ts
│   │       │
│   │       ├── reviews/
│   │       │   ├── domain/
│   │       │   │   ├── entities/
│   │       │   │   │   ├── review.entity.ts       # Aggregate Root
│   │       │   │   │   └── review-criteria.ts     # Value Object
│   │       │   │   ├── value-objects/
│   │       │   │   │   ├── rating.vo.ts           # 0-5 validation
│   │       │   │   │   ├── comment.vo.ts          # Min 10 chars
│   │       │   │   │   └── justification.vo.ts    # Obrigatório se < 3
│   │       │   │   ├── ports/
│   │       │   │   │   └── review.repository.ts
│   │       │   │   └── review.exception.ts
│   │       │   ├── application/
│   │       │   │   ├── reviews.service.ts         # Orquestrador
│   │       │   │   ├── use-cases/
│   │       │   │   │   ├── create-review.usecase.ts
│   │       │   │   │   └── get-review.usecase.ts
│   │       │   │   └── dtos/
│   │       │   │       └── create-review.dto.ts
│   │       │   ├── infra/
│   │       │   │   ├── adapters/
│   │       │   │   │   └── review.sqlite.adapter.ts
│   │       │   │   └── entities/
│   │       │   │       ├── review.db.entity.ts
│   │       │   │       └── review-criteria.db.entity.ts
│   │       │   ├── reviews.module.ts
│   │       │   └── presentation/
│   │       │       └── reviews.controller.ts
│   │       │
│   │       └── shared/
│   │           ├── domain/
│   │           │   ├── exceptions/
│   │           │   │   └── domain.exception.ts
│   │           │   └── value-objects/
│   │           │       └── id.vo.ts
│   │           └── infra/
│   │               ├── database/
│   │               │   ├── database.module.ts
│   │               │   └── database.service.ts
│   │               └── config/
│   │
│   ├── tests/
│   │   ├── unit/
│   │   │   └── reviews/              # Exemplo: testes unitários do domínio
│   │   │       └── review.entity.spec.ts
│   │   ├── integration/
│   │   │   └── reviews.controller.spec.ts
│   │   └── e2e/
│   │       └── reviews.e2e.spec.ts
│   │
│   ├── database/
│   │   ├── migrations/               # TypeORM migrations
│   │   │   ├── 001-create-users.ts
│   │   │   ├── 002-create-places.ts
│   │   │   ├── 003-create-reviews.ts
│   │   │   └── 004-create-review-criteria.ts
│   │   └── seeds/
│   │
│   ├── jest.config.js
│   ├── nest-cli.json
│   ├── package.json
│   ├── tsconfig.json
│   └── docker-compose.yaml
│
├── mobile/                            # Flutter App
│   ├── lib/
│   │   ├── main.dart                  # Entry point
│   │   ├── config/
│   │   │   ├── api_config.dart        # API base URL
│   │   │   └── app_constants.dart
│   │   │
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   ├── errors/
│   │   │   ├── network/
│   │   │   │   └── api_client.dart    # HTTP client
│   │   │   └── providers/
│   │   │       └── app_providers.dart # Global state
│   │   │
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   │   ├── data/
│   │   │   │   │   ├── datasources/
│   │   │   │   │   │   └── auth_remote.dart
│   │   │   │   │   ├── models/
│   │   │   │   │   │   └── auth_model.dart
│   │   │   │   │   └── repositories/
│   │   │   │   │       └── auth_repository.dart
│   │   │   │   ├── domain/
│   │   │   │   │   ├── entities/
│   │   │   │   │   ├── repositories/
│   │   │   │   │   └── usecases/
│   │   │   │   └── presentation/
│   │   │   │       ├── pages/
│   │   │   │       │   ├── login_page.dart
│   │   │   │       │   └── register_page.dart
│   │   │   │       ├── providers/
│   │   │   │       │   └── auth_provider.dart
│   │   │   │       └── widgets/
│   │   │   │
│   │   │   ├── places/
│   │   │   │   ├── data/
│   │   │   │   ├── domain/
│   │   │   │   └── presentation/
│   │   │   │       ├── pages/
│   │   │   │       │   ├── places_list_page.dart
│   │   │   │       │   └── place_detail_page.dart
│   │   │   │       ├── providers/
│   │   │   │       │   └── places_provider.dart
│   │   │   │       └── widgets/
│   │   │   │
│   │   │   ├── profile/
│   │   │   │   ├── data/
│   │   │   │   ├── domain/
│   │   │   │   └── presentation/
│   │   │   │       └── pages/
│   │   │   │           └── profile_page.dart
│   │   │   │
│   │   │   └── reviews/
│   │   │       ├── data/
│   │   │       │   ├── datasources/
│   │   │       │   ├── models/
│   │   │       │   └── repositories/
│   │   │       ├── domain/
│   │   │       │   ├── entities/
│   │   │       │   ├── repositories/
│   │   │       │   └── usecases/
│   │   │       └── presentation/
│   │   │           ├── pages/
│   │   │           │   ├── review_page.dart      # CRÍTICO: UX < 1 min
│   │   │           │   └── my_reviews_page.dart
│   │   │           ├── providers/
│   │   │           │   └── review_provider.dart
│   │   │           └── widgets/
│   │   │               ├── star_rating_widget.dart    # Ludic UX
│   │   │               └── comment_input_widget.dart
│   │   │
│   │   ├── shared/
│   │   │   ├── widgets/
│   │   │   │   ├── app_bar.dart
│   │   │   │   └── loading_widget.dart
│   │   │   ├── theme/
│   │   │   │   └── app_theme.dart
│   │   │   └── utils/
│   │   │
│   │   └── app.dart                  # Root widget
│   │
│   ├── test/
│   │   ├── features/
│   │   │   └── reviews/
│   │   │       └── review_page_test.dart
│   │   └── widget_test.dart
│   │
│   ├── pubspec.yaml
│   └── pubspec.lock
│
└── docs/
    ├── API_CONTRACTS.md           # From Phase 1
    ├── ARCHITECTURE.md            # From Phase 1
    ├── DATABASE_SCHEMA.md         # From Phase 1
    └── SETUP.md                   # From Phase 1
```

**Structure Decision**: Arquitetura em **2 projetos independentes** (Mobile + Backend monolítico) com separação clara de responsabilidades. Cada projeto segue Clean Architecture: Frontend flutter com Clean Architecture (data/domain/presentation), Backend NestJS com Hexagonal (presentation/application/domain/infrastructure). Comunicação via API REST com DTOs.

### Key Design Decisions

1. **Modularidade por Domínio**: Backend organizado em módulos independentes (users, auth, places, reviews) que podem evoluir para microserviços
2. **Hexagonal Pattern**: Domínio isolado de infraestrutura via Ports & Adapters, permitindo trocar SQLite ↔ PostgreSQL sem alterar regras de negócio
3. **TypeORM Migrations**: Versionamento de BD desde o início, path claro para PostgreSQL em Fase 2
4. **Crispy UI/UX**: Widget de estrelas dedicado (star_rating_widget.dart) com animações para tornar avaliação lúdica
5. **State Management Flutter**: Provider/Riverpod centralizado para estado de autenticação e avaliações


