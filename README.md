# ForkScore - Project Setup Guide

## 📋 Sumário

Este é o **chassis** (estrutura base) do ForkScore — uma aplicação mobile de avaliação gastronômica seguindo a Constituição v1.0.0.

Está organizado em duas partes principais:
- **Backend**: Node.js + NestJS com Arquitetura Hexagonal
- **Frontend**: Flutter com Riverpod para state management

---

## 🏗️ Estrutura do Projeto

```
forkscore/
├── backend/
│   ├── src/
│   │   ├── modules/
│   │   │   ├── auth/              # Autenticação (completo)
│   │   │   ├── users/             # Perfil de usuários (stub)
│   │   │   ├── places/            # Cadastro de locais (stub)
│   │   │   ├── reviews/           # Sistema de avaliação (stub com tipos)
│   │   │   └── shared/            # Shared types & utils
│   │   ├── config/                # Configuração da aplicação
│   │   ├── common/                # Filters, decorators, pipes
│   │   ├── main.ts                # Entrada da aplicação
│   │   └── app.module.ts          # Módulo principal
│   ├── database/                  # Migrations, seeds
│   ├── tests/                     # Testes
│   ├── package.json               # Dependências Node.js
│   ├── tsconfig.json              # Configuração TypeScript
│   └── .env.example               # Variáveis de ambiente (exemplo)
│
├── mobile/
│   ├── lib/
│   │   ├── config/                # Configuração da app (API, constantes)
│   │   ├── features/
│   │   │   ├── auth/              # Login, signup
│   │   │   ├── profile/           # Perfil do usuário
│   │   │   ├── places/            # Busca e cadastro de locais
│   │   │   └── reviews/           # Sistema de avaliação com 4 critérios
│   │   ├── shared/
│   │   │   └── widgets/           # Componentes reutilizáveis
│   │   └── main.dart              # Entrada do app
│   ├── pubspec.yaml               # Dependências Flutter
│   └── test/                      # Testes
│
├── docs/
│   ├── ARCHITECTURE.md            # Detalhes arquiteturais
│   ├── API_CONTRACTS.md           # Endpoints e DTOs
│   └── SETUP.md                   # Setup local
│
├── .github/
│   └── copilot-instructions.md    # Instruções para Copilot
│
└── README.md                      # Este arquivo
```

---

## 🚀 Quick Start

### Backend

```bash
cd backend

# Instalar dependências
npm install

# Configurar variáveis de ambiente
cp .env.example .env

# Executar em desenvolvimento
npm run dev

# API rodará em http://localhost:3000
# Health check: GET http://localhost:3000/health
```

### Frontend

```bash
cd mobile

# Instalar dependências
flutter pub get

# Executar no emulador
flutter run

# Build release
flutter build apk  # Android
flutter build ios  # iOS
```

---

## 🏛️ Arquitetura Hexagonal (Backend)

### Fluxo de Dependências

```
Presentation (Controllers)
       ↓ (DTO → Use Case)
Application (Services)
       ↓ (Entities)
Domain (Business Rules)
       ↑ (Interfaces)
Infrastructure (Adapters, DB)
```

### Exemplo: Auth Module

```
auth/
├── domain/
│   └── auth.types.ts          # Tipos, interfaces, regras puras
├── application/
│   └── auth.service.ts        # Orquestra domínio + infra
├── infra/
│   └── strategies/jwt.strategy.ts  # Implementação técnica
└── presentation/
    └── auth.controller.ts     # Thin controller (HTTP)
```

**Princípio**: Domain NÃO depende de nada; Application depende de Domain; Infra implementa interfaces de Domain.

---

## 📊 Data Model

### User
```
id: UUID
email: string (unique)
password_hash: bcrypt hash
name: string (2-50 chars)
bio: string (optional, max 250 chars)
profile_photo_url: string (optional)
created_at: timestamp
updated_at: timestamp
```

### Place
```
id: UUID
name: string (3-100 chars)
type: enum (restaurant, cafe, bakery, etc)
address: string
lat, lng: float (optional)
phone, website: string (optional)
created_by_user_id: FK → User
created_at, updated_at: timestamp
```

### Review
```
id: UUID
user_id: FK → User
place_id: FK → Place
created_at, updated_at: timestamp
is_justification_provided: boolean
```

### ReviewCriteria (4 MANDATÓRIOS por Constituição)
```
id: UUID
review_id: FK → Review
criterion: enum (sabor, atendimento, custo, infra)
rating: integer (0-5)
comment: string (min 10 chars, max 500)
is_justified: boolean (true if rating < 3)
created_at: timestamp
```

---

## ✅ Implementação de Exemplo: Auth

### 1. Domain (auth/domain/auth.types.ts)
- Define tipos, interfaces, exceções
- **Não depende de nada** (zero imports técnicos)
- Regras puras de negócio

### 2. Application (auth/application/auth.service.ts)
- Implementa casos de uso (login, signup)
- Orquestra Domain + Infra
- Injeção de dependências

### 3. Infrastructure (auth/infra/jwt.strategy.ts)
- Implementa JWT (Passport)
- Acesso a banco via TypeORM
- Hashing com bcrypt

### 4. Presentation (auth/presentation/auth.controller.ts)
- Thin controller: validação + roteamento
- Recebe DTO, passa para Application
- Retorna HTTP responses

---

## 🧪 Testing Strategy

### Domain Tests (100% Coverage Target)
```typescript
// Testa regras puras: validação de senha, rating, comentários
describe('ReviewValidator', () => {
  it('MUST throw MissingJustificationError if rating < 3 without justification', () => {
    expect(() => ReviewValidator.validateJustification(2, false))
      .toThrow(MissingJustificationError);
  });
});
```

### Application Tests
```typescript
// Testa orquestração com mocks de repositórios
describe('AuthService', () => {
  it('MUST return access token on successful login', async () => {
    const result = await authService.login({ email, password });
    expect(result.accessToken).toBeDefined();
  });
});
```

### Integration Tests
```typescript
// Testa fluxo completo: HTTP → Controller → Service → Domain
describe('POST /auth/login', () => {
  it('MUST return 200 with token', async () => {
    const response = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email, password });
    expect(response.status).toBe(200);
  });
});
```

---

## 🔄 Evolution Roadmap

### Phase 1: MVP (Agora)
- ✅ Backend: Monólito modular + SQLite + API REST
- ✅ Frontend: Flutter simples
- ✅ Módulos: Auth, Users, Places, Reviews
- ✅ Features: Login, perfil, cadastro de local, avaliação com 4 critérios

### Phase 2: Crescimento
- [ ] Cache Redis
- [ ] Busca otimizada (índices de DB)
- [ ] Imagens de pratos
- [ ] Google Maps integration
- [ ] Notificações push

### Phase 3: Escala
- [ ] PostgreSQL
- [ ] Possível decomposição em microserviços
- [ ] ML: recomendações personalizadas
- [ ] Analytics: dashboards

---

## 📝 Sistema de Avaliação (Constitution-Compliant)

**4 Critérios Obrigatórios** (per Constituição v1.0.0):

1. **Sabor** — Qualidade e gosto da comida/bebida
2. **Atendimento** — Qualidade do serviço
3. **Custo-benefício / Opções** — Variedade e valor
4. **Infraestrutura** — Limpeza, conforto, espaço

**Regras**:
- ⭐ Rating: 0-5 stars
- 💬 Comentário: Obrigatório (min 10 chars)
- 📝 Justificativa: Obrigatória se rating < 3
- 📊 Overall: Média dos 4 critérios

---

## 🔐 Segurança

- **Senhas**: bcrypt (cost factor 10)
- **Autenticação**: JWT com refresh token
- **CORS**: Configurado para frontend URL
- **Validação**: Pipes globais (class-validator)
- **Variáveis Sensíveis**: .env (não comitar!)

---

## 🛠️ Developer Commands

### Backend
```bash
npm run dev        # Watch mode
npm run build      # Build para produção
npm test           # Executar testes
npm run lint       # Lint & fix
npm run format     # Prettier
```

### Frontend
```bash
flutter pub get    # Instalar deps
flutter run        # Executar emulador
flutter build apk  # Android release
flutter build ios  # iOS release
flutter test       # Testes widget
```

---

## 📚 Documentation

- [ARCHITECTURE.md](docs/ARCHITECTURE.md) — Detalhes de arquitetura e padrões
- [API_CONTRACTS.md](docs/API_CONTRACTS.md) — Endpoints, DTOs, exemplos
- [SETUP.md](docs/SETUP.md) — Setup detalhado (DB, envs, etc)

---

## 🎯 Próximos Passos

1. ✅ **Chassis criado** — Estrutura base pronta
2. ⏳ **Implementar módulos** — Auth é exemplo; Users, Places, Reviews seguem padrão
3. ⏳ **Testes** — TDD: escrever testes primeiro
4. ⏳ **Frontend** — Conectar app Flutter à API
5. ⏳ **Deploy** — MVP ao vivo

---

## 📞 Support

Para dúvidas sobre:
- **Arquitetura**: Consulte [ARCHITECTURE.md](docs/ARCHITECTURE.md) e Constituição
- **APIs**: Consulte [API_CONTRACTS.md](docs/API_CONTRACTS.md)
- **Setup**: Consulte [SETUP.md](docs/SETUP.md)

---

**ForkScore v0.1.0**  
Arquitetura Hexagonal | DDD | Clean Code  
Constitution v1.0.0
