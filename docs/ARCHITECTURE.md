# Arquitetura do ForkScore — Detalhes Técnicos

## 📐 Padrão: Arquitetura Hexagonal (Ports and Adapters)

ForkScore implementa Arquitetura Hexagonal para isolar lógica de negócio de tecnologia.

```
┌─────────────────────────────────────────────┐
│     PRESENTATION LAYER                      │
│  (Controllers, HTTP Handling)               │
└────────────────┬────────────────────────────┘
                 │ DTO
                 ↓
┌─────────────────────────────────────────────┐
│     APPLICATION LAYER                       │
│  (Use Cases, Orchestration)                 │
└────────────────┬────────────────────────────┘
                 │ Entities
                 ↓
┌─────────────────────────────────────────────┐
│     DOMAIN LAYER                            │
│  (Business Rules, Entities, Value Objects)  │
│  ⚠️ ZERO external dependencies              │
└────────────────┬────────────────────────────┘
                 │ Ports (Interfaces)
                 ↓
┌─────────────────────────────────────────────┐
│     INFRASTRUCTURE LAYER                    │
│  (Adapters: DB, JWT, External APIs)        │
│  Implements Domain Ports                    │
└─────────────────────────────────────────────┘
```

---

## 🎯 Princípios Arquiteturais

### 1. **Dependency Inversion**
```
❌ Domain → Infra (PROIBIDO)
✅ Infra → Domain (via Interface)

Domain define interface: IUserRepository
Infra implementa: UserSQLiteRepository implements IUserRepository
```

### 2. **Separation of Concerns**
```
Domain:        Regras puras (validação, lógica de negócio)
Application:   Orquestração de use cases
Infra:         Detalhe técnico (BD, APIs, JWT)
Presentation:  HTTP (controllers, DTOs, respostas)
```

### 3. **Testability**
```
Domain:        100% unit tests (sem mocks)
Application:   80%+ integration tests (com mocks de repos)
Presentation:  E2E tests (stack completa)
```

---

## 📦 Módulos por Domínio

Cada módulo = "bounded context" (DDD):

```
modules/
├── auth/
│   ├── domain/
│   │   └── auth.types.ts           # Tipos, interfaces, exceções
│   ├── application/
│   │   └── auth.service.ts         # Login, signup
│   ├── infra/
│   │   └── strategies/jwt.strategy.ts  # JWT, bcrypt
│   └── presentation/
│       └── auth.controller.ts      # HTTP endpoints
│
├── users/
│   ├── domain/
│   │   └── user.types.ts
│   ├── application/
│   │   └── users.service.ts
│   ├── infra/
│   │   └── entities/user.entity.ts
│   └── presentation/
│       └── users.controller.ts
│
├── places/
│   ├── domain/
│   └── ...
│
├── reviews/
│   ├── domain/
│   │   └── review.types.ts         # 4 critérios, validação
│   ├── application/
│   │   └── reviews.service.ts
│   ├── infra/
│   │   └── entities/review.entity.ts
│   └── presentation/
│       └── reviews.controller.ts
│
└── shared/
    └── domain/                     # Value objects compartilhados
```

---

## 🔍 Exemplo Detalhado: Review Module

### Domain Layer (reviews/domain/review.types.ts)

```typescript
// Tipos puros, sem tecnologia
export enum ReviewCriterion {
  SABOR = 'sabor',
  ATENDIMENTO = 'atendimento',
  CUSTO = 'custo',
  INFRA = 'infra',
}

export interface IReviewCriteria {
  criterion: ReviewCriterion;
  rating: number;  // 0-5
  comment: string; // min 10 chars
  isJustified: boolean; // true if rating < 3
}

// Validadores de domínio
export class ReviewValidator {
  static validateRating(rating: number): void {
    if (rating < 0 || rating > 5) {
      throw new InvalidRatingError();
    }
  }

  static validateComment(comment: string): void {
    if (comment.length < 10) {
      throw new InvalidCommentError();
    }
  }

  static validateJustification(rating: number, isJustified: boolean): void {
    if (rating < 3 && !isJustified) {
      throw new MissingJustificationError();
    }
  }
}
```

### Application Layer (reviews/application/reviews.service.ts)

```typescript
@Injectable()
export class ReviewsService {
  constructor(
    private reviewsRepository: IReviewsRepository,  // Port (interface)
    private placesRepository: IPlacesRepository,
  ) {}

  async createReview(command: CreateReviewCommand): Promise<Review> {
    // Valida cada critério com domínio
    command.criteria.forEach(c => {
      ReviewValidator.validateRating(c.rating);
      ReviewValidator.validateComment(c.comment);
      ReviewValidator.validateJustification(c.rating, c.isJustified);
    });

    // Persiste via repositório (infra)
    const review = new Review(command);
    return this.reviewsRepository.save(review);
  }
}
```

### Infrastructure Layer (reviews/infra/repositories/reviews.repository.ts)

```typescript
@Injectable()
export class ReviewsSQLiteRepository implements IReviewsRepository {
  constructor(
    @InjectRepository(ReviewEntity)
    private reviewsTable: Repository<ReviewEntity>,
  ) {}

  async save(review: Review): Promise<Review> {
    // Salva em SQLite (ou PostgreSQL — transparente para Application)
    const entity = ReviewEntity.fromDomain(review);
    const saved = await this.reviewsTable.save(entity);
    return Review.toDomain(saved);
  }
}
```

### Presentation Layer (reviews/presentation/reviews.controller.ts)

```typescript
@Controller('/reviews')
export class ReviewsController {
  constructor(private reviewsService: ReviewsService) {}

  @Post('/')
  async createReview(@Body() dto: CreateReviewDto) {
    // Thin controller: apenas passa DTO para service
    return this.reviewsService.createReview(dto.toCommand());
  }
}
```

---

## 🗄️ Database Strategy (SQLite → PostgreSQL)

### Phase 1: SQLite (MVP)
```
Advantages:
- Zero setup
- File-based (simples)
- Perfeito para desenvolvimento

Disadvantages:
- Locks de escrita
- Não ideal para concorrência alta
```

### Phase 2+: PostgreSQL
```
Migration path:
1. Schema é já PostgreSQL-compatible (via TypeORM)
2. Trocar connection string
3. Rodas migrations
4. Pronto — Application/Domain não mudam
```

---

## 🧪 Testing Pyramid

```
     /\
    /  \          E2E Tests (5-10%)
   /────\         - Fluxos completos
  /      \        - HTTP → Controller → Service → DB
 /────────\       
/          \      Integration Tests (30-40%)
/────────────\    - Use Cases com mocks
              \   - Repository contracts
               \
─────────────────  Unit Tests (50-60%)
                   - Domain rules
                   - Validators
                   - Value Objects
```

### Exemplo: ReviewValidator Tests

```typescript
describe('ReviewValidator', () => {
  describe('validateRating', () => {
    it('MUST throw if rating < 0', () => {
      expect(() => ReviewValidator.validateRating(-1))
        .toThrow(InvalidRatingError);
    });

    it('MUST throw if rating > 5', () => {
      expect(() => ReviewValidator.validateRating(6))
        .toThrow(InvalidRatingError);
    });

    it('MUST accept valid ratings 0-5', () => {
      [0, 1, 2, 3, 4, 5].forEach(rating => {
        expect(() => ReviewValidator.validateRating(rating))
          .not.toThrow();
      });
    });
  });

  describe('validateJustification', () => {
    it('MUST throw if rating < 3 without justification', () => {
      expect(() => ReviewValidator.validateJustification(2, false))
        .toThrow(MissingJustificationError);
    });

    it('MUST allow if rating < 3 with justification', () => {
      expect(() => ReviewValidator.validateJustification(2, true))
        .not.toThrow();
    });

    it('MUST allow if rating >= 3 (no justification needed)', () => {
      expect(() => ReviewValidator.validateJustification(3, false))
        .not.toThrow();
    });
  });
});
```

---

## 📡 API Contracts

### Health Check
```
GET /health
Response: 200 OK
{
  "status": "ok",
  "timestamp": "2026-04-22T12:00:00Z",
  "service": "ForkScore API v0.1.0"
}
```

### Login
```
POST /auth/login
Body: { email: string, password: string }
Response: 200 OK
{
  "accessToken": "eyJhbGc...",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

### Create Review
```
POST /reviews
Header: Authorization: Bearer <token>
Body: {
  placeId: string,
  criteria: [
    {
      criterion: "sabor",
      rating: 4,
      comment: "Excelente sabor, muito saboroso",
      isJustified: false
    },
    ...
  ]
}
Response: 201 Created
{
  "id": "uuid",
  "userId": "uuid",
  "placeId": "uuid",
  "criteria": [...],
  "createdAt": "2026-04-22T12:00:00Z"
}
```

---

## 🔐 Security Patterns

### 1. Password Hashing
```typescript
// Infra layer only
const hash = await bcrypt.hash(password, 10);
// Domain NEVER sees plain password
```

### 2. JWT Tokens
```typescript
// Infra: generates & validates
const token = jwtService.sign({ userId, email });

// Presentation: uses guard
@UseGuards(JwtAuthGuard)
@Get('/profile')
getProfile() { ... }
```

### 3. Input Validation
```typescript
// Presentation: DTO validation
@Body() dto: CreateReviewDto
// NestJS ValidationPipe rejeita antes de chegar a Application
```

---

## 🚀 Performance Considerations

### Phase 1 (MVP)
- SQLite: OK para < 100k users
- No caching
- Simple indexing on frequently-queried columns

### Phase 2 (Crescimento)
- Redis cache para: user sessions, place queries
- DB indices: email (users), place_id (reviews)

### Phase 3 (Escala)
- PostgreSQL: read replicas, connection pooling
- Elasticsearch: full-text search (locais, reviews)
- CDN: static assets

---

## 📋 Checklist para Nova Feature

Quando adicionar nova feature, seguir este checklist:

### 1. Domain
- [ ] Define tipos, interfaces, exceções
- [ ] Implementa validadores
- [ ] Zero dependências externas
- [ ] 100% cobertura de testes unitários

### 2. Application
- [ ] Define use cases/services
- [ ] Orquestra Domain + Infra (via injeção)
- [ ] Injeta repositórios como interfaces
- [ ] 80%+ cobertura com mocks

### 3. Infrastructure
- [ ] Implementa interfaces de Domain
- [ ] TypeORM entities
- [ ] Repositórios
- [ ] Integração com technologies (JWT, bcrypt, BD)

### 4. Presentation
- [ ] Thin controllers (validação + routing)
- [ ] DTOs com class-validator
- [ ] Tratamento de erro centralizado
- [ ] Documentação de API

### 5. Tests
- [ ] Domain tests (100%)
- [ ] Application integration tests (80%)
- [ ] E2E tests (fluxos críticos)

---

**Arquitetura Hexagonal garante evolução sustentável sem reescrever domínio.**
