# 📋 Constitution Synchronization Guide — ForkScore v1.0.0

**Generated**: 2026-04-22  
**Constitution Version**: 1.0.0 (Initial MVP)  
**Status**: ✅ Created

---

## 🔄 Synchronization Status

| Template | Status | Action Required | Details |
|----------|--------|-----------------|---------|
| **spec-template.md** | ✅ Compatible | Optional guidance | Add note on architectural compliance per constitution |
| **plan-template.md** | ⚠️ Needs attention | **Manual update** | Update "Constitution Check" section with ForkScore gates |
| **tasks-template.md** | ✅ Compatible | Optional enhancement | Add examples for layer-based task organization |

---

## 1️⃣ spec-template.md — Guidance (Optional)

**Status:** ✅ Compatible - no changes required

**Recommendation:** Add guidance comment after "Requirements" section:

```markdown
### Architectural Compliance

All requirements MUST respect ForkScore Constitution v1.0.0:
- **Domain logic** must be technology-agnostic
- **Controllers** are thin (validation + routing only)
- **Dependencies** flow toward domain (no inbound)
- **Evaluation system** uses 4 mandatory criteria + comment rules
```

---

## 2️⃣ plan-template.md — Constitution Check (⚠️ Mandatory Update)

**Status:** ⚠️ Needs revision

**Current State:**
```markdown
## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

[Gates determined based on constitution file]
```

**Update To:**
```markdown
## Constitution Check ✅ ForkScore Constitution v1.0.0

**MANDATORY GATES** (blocking if violated):

1. **Architecture** ✅
   - [ ] Design follows Hexagonal (Ports & Adapters) pattern
   - [ ] Domain layer has zero external dependencies
   - [ ] Repositories are defined as interfaces in domain
   - [ ] All external dependencies isolated in Infrastructure layer

2. **Code Organization** ✅
   - [ ] Follows module-by-domain structure (users, auth, places, reviews)
   - [ ] Each module has domain/, application/, infra/, presentation/ folders
   - [ ] No circular module dependencies
   - [ ] Shared logic uses value objects (domain/shared)

3. **Evaluation System** ✅
   - [ ] 4 criteria implemented: sabor, atendimento, custo, infra
   - [ ] Star rating: 0-5 scale
   - [ ] Comments mandatory per criterion (min 10 chars)
   - [ ] Rating < 3 requires justification
   - [ ] Aggregation: average of criteria = overall rating

4. **Technology Stack** ✅
   - [ ] Backend: Node.js + NestJS (or justified alternative)
   - [ ] Frontend: Flutter (or justified alternative)
   - [ ] Database: SQLite for MVP, PostgreSQL-compatible schema
   - [ ] Auth: JWT + bcrypt

5. **Testing Discipline** ✅
   - [ ] Domain layer: 100% unit test coverage (target)
   - [ ] Use cases: 80%+ coverage with mocked repositories
   - [ ] Controllers: integration tests
   - [ ] All tests must run in CI/CD

6. **No Violations of Restrictions** ✅
   - [ ] ❌ No microservices in MVP
   - [ ] ❌ No business logic in controllers
   - [ ] ❌ No SQL queries outside repositories
   - [ ] ❌ No circular module dependencies

**GATE RESULT:**
- [ ] ✅ PASS — Design conforms to constitution
- [ ] ⚠️ PASS WITH COMPLEXITY JUSTIFICATION — See table below
- [ ] ❌ FAIL — Design violates non-negotiable constraints

### Complexity Justification (if needed)

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., breaking layer rule] | [reason] | [why simpler approach won't work] |
```

---

## 3️⃣ tasks-template.md — Layer Organization (Optional Enhancement)

**Status:** ✅ Compatible - enhancement optional

**Recommendation:** Add section after "Path Conventions":

```markdown
## Architectural Layers Organization

Each user story task should be organized by architectural layers (implied order):

1. **Domain Tasks** (entities, aggregates, value objects, business rules)
   - Format: `[ID] [P] [US#] Domain: Create [Entity] with [business rule]`
   - Location: `src/modules/[module]/domain/[entity].ts`

2. **Application Tasks** (use cases, orchestration, validation)
   - Format: `[ID] [P] [US#] Application: Implement [UseCase] with [Service]`
   - Location: `src/modules/[module]/application/use-cases/[use-case].ts`

3. **Infrastructure Tasks** (repositories, database, external services)
   - Format: `[ID] [P] [US#] Infrastructure: Implement [Repository] adapter`
   - Location: `src/modules/[module]/infra/repositories/[adapter].ts`

4. **Presentation Tasks** (controllers, routes, request/response handling)
   - Format: `[ID] [P] [US#] Presentation: Create [Controller] for [endpoint]`
   - Location: `src/modules/[module]/presentation/controllers/[controller].ts`

5. **Integration & Tests** (cross-layer wiring, test coverage)
   - Format: `[ID] [P] [US#] Tests: [test type] for [feature]`
   - Location: `tests/[module]/[test-file].spec.ts`

### Example Task Sequence for User Story 1

```
- [ ] T-001 [P] [US1] Domain: Create Review entity with rating validation
- [ ] T-002 [P] [US1] Domain: Create ReviewCriteria value object with rules
- [ ] T-003 [US1] Application: Implement CreateReviewUseCase (depends T-001, T-002)
- [ ] T-004 [US1] Infrastructure: Implement ReviewRepository SQLite adapter
- [ ] T-005 [US1] Presentation: Create ReviewController with POST /reviews
- [ ] T-006 [P] [US1] Tests: Unit tests for Review domain entity
- [ ] T-007 [US1] Tests: Integration test for CreateReviewUseCase
```

This ensures dependencies flow naturally and each layer can be reviewed/tested in isolation.
```

---

## 📊 Dependencies Between Templates

```
constitution.md (v1.0.0)
    ↓
    ├─→ spec-template.md (guidance: architectural compliance)
    │
    ├─→ plan-template.md (gates: architecture + evaluation system)
    │
    └─→ tasks-template.md (hints: layer-based organization)
```

---

## ✅ Manual Checklist

Before proceeding to `/speckit.specify`:

- [ ] Constitution v1.0.0 created at `.specify/memory/constitution.md`
- [ ] No placeholder tokens remain in constitution (validate)
- [ ] plan-template.md updated with "Constitution Check" section (if proceeding with planning)
- [ ] team notified of new governance model
- [ ] Tech stack (Flutter, NestJS, SQLite) is approved/confirmed

---

## 📝 Next Steps

1. **Spec Creation** → Run `/speckit.specify` to generate first feature specification
2. **Planning** → Run `/speckit.plan` with reference to constitution sections 3 (Architecture) + 9 (Evaluation)
3. **Task Generation** → Run `/speckit.tasks` with guidance from this sync guide (section 3️⃣)

---

**This guide is generated with the constitution and should be reviewed with team before committing.**
