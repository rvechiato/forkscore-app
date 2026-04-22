# Phase 0: Research & Technology Analysis

**Feature**: Sistema Completo de Avaliação de Locais  
**Date**: April 22, 2026  
**Status**: Research Complete

---

## 1. Flutter vs React Native (Mobile Framework Decision)

### Decision: **Flutter** ✅

### Rationale
- **Hot Reload**: Desenvolvimento mais rápido, especialmente para UX iterativa
- **Performance**: Compilado para ARM native, melhor performance que React Native
- **Widget System**: Excepcional para criar UIs customizadas e animadas (crucial para star rating ludic)
- **Single Language**: Dart é simples e evita context-switching
- **Ecosystem**: Firebase integration built-in, excelente para MVP

### Alternatives Considered
- **React Native**: Comunidade maior, mas JS fatigue em equipes. Performance inferior para animações complexas
- **Native (Swift/Kotlin)**: Máxima performance, mas 2x tempo de desenvolvimento

### Best Practices Implemented
- Clean Architecture (data/domain/presentation layers)
- State management com Provider (não Riverpod em MVP para simplificar)
- Separation of HTTP client (APIClient singleton)
- Mock repositories para testes

---

## 2. NestJS vs Spring Boot (Backend Framework Decision)

### Decision: **NestJS + Node.js** ✅

### Rationale
- **TypeScript**: Strongly typed (melhor que JavaScript puro), reduz bugs em domínio de negócio
- **Modularity**: NestJS Module system alinha perfeitamente com Clean Architecture
- **Rapid Prototyping**: Decoradores (@Module, @Injectable) reduzem boilerplate
- **Middleware/Guards**: Excelentes para implementar JWT, CORS, logging
- **Testing**: Jest pré-configurado, mocking simples com `jest.mock()`
- **Deployment**: Mais leve que Java, suporta serverless (se escalar para Fase 2)

### Alternatives Considered
- **Spring Boot**: Mais enterprise, melhor para escala massiva, mas overkill para MVP. Bootup time > 5s
- **Express.js puro**: Muito boilerplate, sem estrutura (seria reinventar roda)
- **Go (Gin)**: Excelente performance, mas curva de aprendizado maior

### Best Practices Implemented
- Arquitetura Hexagonal com Ports & Adapters
- Exception Filters centralizados
- DTOs + Validation Pipes
- Dependency Injection via NestJS providers
- TypeORM para abstração de BD

---

## 3. SQLite vs PostgreSQL (Database Decision - Phase 1)

### Decision: **SQLite para MVP, PostgreSQL path para Fase 2** ✅

### Rationale (SQLite MVP)
- **Zero Setup**: Arquivo único, sem servidor de BD necessário
- **TypeORM Support**: SQLite suportado nativamente, migrations funcionam igual
- **MVP Scope**: 100-1000 usuários, SQLite é overkill mas suficiente
- **Migration Path**: Swap adapter em infraestrutura, esquema TypeORM é agnóstico

### Rationale (PostgreSQL Fase 2)
- **Escalabilidade**: Pronto para 10k+ usuários, queries complexas
- **Indexes**: Advanced indexing strategies para buscas rápidas (locais por proximidade)
- **JSONB**: Suporte para dados semiestruturados (futura extensão de avaliações)
- **Replication**: Possível replicação para alta disponibilidade

### Alternatives Considered
- **MongoDB**: NoSQL, mas avaliações são naturalmente relacionais. Overcomplexity
- **Firebase Firestore**: SaaS, cobrado por leitura. MVPs precisam economizar inicialmente
- **SQLite apenas**: Sem escala, limited concurrency. Problema em Fase 2

### Best Practices Implemented
- TypeORM Repository pattern (abstração de BD)
- Migrations versionadas desde dia 1
- Database connection pooling (mesmo SQLite)
- Foreign keys e constraints aplicadas

---

## 4. Authentication: JWT vs Session Cookies

### Decision: **JWT (Stateless)** ✅

### Rationale
- **Stateless**: Não requer sessão em servidor. Escalável horizontalmente
- **Mobile-Friendly**: Token pode ser armazenado em shared_preferences (Flutter)
- **API-First**: Padrão para APIs REST
- **Refresh Token Pattern**: Token curta vida (15 min) + refresh token (7 dias)

### Alternatives Considered
- **Session Cookies**: Requer estado em servidor, session store (Redis). Complexidade adicionada
- **OAuth2/Google Sign-In**: Futuro (Fase 2), complexidade desnecessária para MVP

### Best Practices Implemented
- Password hashing com bcrypt (cost factor 10)
- Refresh token separado de access token
- Token expiration (15 min access, 7 dias refresh)
- Validation via NestJS guards

---

## 5. Star Rating Implementation (UX Pattern)

### Decision: **Gesture-based Star Widget com animações** ✅

### Rationale
- **Ludic**: Toque nas estrelas é intuitivo, visual feedback imediato
- **Accessibility**: Cada critério é uma seção clara, não é overwhelming
- **Performance**: Animações em 60fps possível com Flutter (GPU-rendered)
- **Familiar**: Padrão de UX usado por Uber, AirBnB, Amazon

### Alternatives Considered
- **Slider (1-5)**: Menos intuitivo que estrelas
- **Numeric Input**: Menos lúdico, não apropriado para mobile
- **Buttons (next/prev)**: Mais passos, ruim para < 1 min constraint

### Best Practices Implemented
- `star_rating_widget.dart` separado, reusável
- Animação de crescimento ao clicar (feedback visual)
- Validação: não permite submissão com critério incompleto
- Comentário obrigatório (min 10 chars) por critério

---

## 6. Comment Validation: Frontend vs Backend

### Decision: **Validação em ambos (Frontend + Backend)** ✅

### Rationale
- **Frontend**: Feedback imediato ao usuário (< 100ms)
- **Backend**: Garantia de integridade (não confiar em cliente)
- **Security**: Previne tentativa de bypassa via curl/postman

### Alternatives Considered
- **Frontend only**: Rápido, mas vulnerável a manipulação
- **Backend only**: Seguro, mas UX ruim (delay para feedback)

### Best Practices Implemented
- Flutter: `TextFormField` com validador
- NestJS: `class-validator` + `@IsMinLength(10)`
- Mensagem de erro igual em ambos

---

## 7. Justification Logic (< 3 ⭐ obriga comentário)

### Decision: **Domain Rule com validação em ambos** ✅

### Rationale
- **Business Critical**: Avaliações negativas precisam de feedback construído
- **Domain Logic**: Regra pertence ao domínio, não ao framework
- **Value Object**: `Justification` é value object que valida regra

### Best Practices Implemented
```typescript
// domain/value-objects/justification.vo.ts
class Justification {
  readonly value: string;
  readonly isRequired: boolean; // true if rating < 3
  
  constructor(text: string, rating: number) {
    if (rating < 3 && !text) {
      throw new MissingJustificationError();
    }
    if (text.length < 10) {
      throw new InvalidJustificationError();
    }
    this.value = text;
    this.isRequired = rating < 3;
  }
}
```

---

## 8. API Response Format

### Decision: **Standard REST + Consistent Error Codes** ✅

### Rationale
- **Consistency**: Frontend sabe sempre o formato de resposta
- **Error Handling**: Códigos de erro específicos (INVALID_RATING, MISSING_JUSTIFICATION)
- **Versioning**: Path-based v1, v2, etc. (opcional para MVP, crítico para Fase 2)

### Best Practices Implemented
```json
// Success (200, 201)
{
  "status": "success",
  "data": {
    "id": "rev_123",
    "userId": "user_456",
    "placeId": "place_789"
  }
}

// Error (4xx, 5xx)
{
  "status": "error",
  "code": "INVALID_RATING",
  "message": "Rating must be between 0 and 5"
}
```

---

## 9. Testing Strategy

### Decision: **Unit + Integration (Coverage > 80%)** ✅

### Rationale
- **Domain**: 100% cobertura (regras de negócio são críticas)
- **Application**: 80% cobertura (use cases com mocks)
- **Infrastructure**: 50% cobertura (mais rápido iterar sem DB real em testes)
- **Controllers**: 80% cobertura (integração HTTP)

### Best Practices Implemented
- **Backend**: Jest + `@nestjs/testing` + mockito
- **Frontend**: Flutter test + mocktail (mock HTTP)
- **E2E**: Postman collections para validar API completa

---

## 10. Security Considerations

### Decision: **HTTPS + CORS + Input Validation** ✅

### Rationale
- **HTTPS**: Obrigatório em produção, protege JWT em trânsito
- **CORS**: Restringir a domínios conhecidos (móvel: app-specific)
- **Input Validation**: Pipes NestJS validam antes de controller
- **XSS**: Não aplicável (API JSON), mas atentar em frontend web futura
- **SQL Injection**: TypeORM + Parameterized queries evitam

### Best Practices Implemented
- bcrypt para senhas (nunca armazenar plaintext)
- Rate limiting (futuro: express-rate-limit)
- Logging de ações críticas (login, avaliação)

---

## 11. Development Environment Setup

### Decision: **Docker Compose para deps locais** ✅

### Rationale
- **Consistency**: Mesmo ambiente local e produção
- **No Manual Setup**: DB já configurada automaticamente
- **Easy Reset**: `docker-compose down && up` reseta tudo

### Alternatives Considered
- **Manual DB Setup**: Propenso a erros, menos reproducível
- **Cloud Dev Environment**: Custo + latência para MVP

### Best Practices Implemented
- `docker-compose.yaml` com NestJS + SQLite
- Migrations automáticas em startup
- Seeds de dados para testes manuais

---

## 12. Version Control & Branching

### Decision: **Git Flow com feature branches** ✅

### Rationale
- **Traceability**: Cada feature tem branch próprio
- **PR Review**: Qualidade antes de merge
- **CI/CD Ready**: Integração com GitHub Actions

### Best Practices Implemented
- Feature branch: `002-mobile-rating-system`
- Commit messages: `[DOMAIN] Action (subject)` ex: `[Reviews] feat: add star rating widget`
- Rebase before merge (manter histórico linear)

---

## Summary of Decisions

| Decision | Choice | Why |
|----------|--------|-----|
| Mobile Framework | Flutter | Hot reload, performance, widget system |
| Backend Framework | NestJS | Type safety, modularity, rapid development |
| Database (MVP) | SQLite | Zero setup, migration path to PostgreSQL |
| Authentication | JWT | Stateless, mobile-friendly, scalable |
| Star Rating UX | Gesture-based widget | Ludic, intuitive, familiar pattern |
| Validation | Frontend + Backend | UX speed + security |
| Error Codes | Custom codes (INVALID_RATING) | Consistency, better error handling |
| Testing | Unit + Integration (>80%) | Confidence without over-testing |
| Security | HTTPS + bcrypt + CORS | Best practices for API |
| Development | Docker Compose | Consistency, easy reset |

All decisions are **implementation-agnostic** and align with ForkScore Constitution v1.0.0 principles (Simplicity, Clean Architecture, Scalability, Testability, User-Centric Design).
