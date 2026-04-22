<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan:
📋 **Current Plan**: [specs/002-rating-system-complete/plan.md](specs/002-rating-system-complete/plan.md)

**Quick References**:
- 🎯 **Specification**: [specs/002-rating-system-complete/spec.md](specs/002-rating-system-complete/spec.md) — User stories, requirements, acceptance criteria
- 🔬 **Research**: [specs/002-rating-system-complete/research.md](specs/002-rating-system-complete/research.md) — Technology decisions (Flutter, NestJS, SQLite)
- 📊 **Data Model**: [specs/002-rating-system-complete/data-model.md](specs/002-rating-system-complete/data-model.md) — Domain entities, value objects, aggregates
- 📡 **API Contracts**: [specs/002-rating-system-complete/contracts/api-endpoints.md](specs/002-rating-system-complete/contracts/api-endpoints.md) — REST API endpoints and responses
- 🚀 **Quick Start**: [specs/002-rating-system-complete/quickstart.md](specs/002-rating-system-complete/quickstart.md) — Setup and development workflow

**Architecture**: Hexagonal (Ports & Adapters) + Clean Architecture
- **Frontend**: Flutter (mobile)
- **Backend**: NestJS + Node.js (API REST)
- **Database**: SQLite (MVP) → PostgreSQL (Phase 2)
- **Organization**: Modular by domain (users, auth, places, reviews, shared)

**Key Constraints**:
- Review submission < 1 minute (ludic star rating UX)
- 4 criteria: taste, service, value, infrastructure
- Comment mandatory per criterion (min 10 chars)
- Justification mandatory if rating < 3 stars
<!-- SPECKIT END -->
