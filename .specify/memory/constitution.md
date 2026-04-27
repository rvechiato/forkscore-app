<!--
SYNC IMPACT REPORT - Constitution v1.1.0
==========================================
Version Change: 1.0.0 → 1.1.0
Ratification Date: 2026-04-22
Amendment Date: 2026-04-27

Created Sections:
  ✓ Core Objectives
  ✓ Fundamental Principles (5)
  ✓ Architectural Guidelines
  ✓ Code Organization
  ✓ Frontend Strategy
  ✓ Backend Strategy
  ✓ Database Strategy
  ✓ Persistence Pattern
  ✓ Evaluation System Rules
  ✓ Authentication & Security
  ✓ Evolution Roadmap
  ✓ Architectural Constraints
  ✓ Testing Discipline

Updated Sections:
  ✓ Frontend Strategy
  ✓ Authentication & Security
  ✓ Architectural Constraints

Template Updates Required:
  ⚠ specs that introduce frontend navigation must classify public/protected routes
  ⚠ plans that add new screens must document route access, redirects, and guard reuse
  ⚠ tasks that add authenticated pages must include navigation and logout validation

Dependencies: All core templates updated for Layer-based categorization (Presentation, Application, Domain, Infrastructure)
-->

# 📜 ForkScore - Aplicativo de Avaliação Gastronômica — Constitution

**Versão**: 1.1.0 | **Ratificado em**: 2026-04-22 | **Última Atualização**: 2026-04-27

---

## 1. 🎯 Objetivo

Definir os princípios arquiteturais, tecnológicos e de design que guiarão o desenvolvimento do **ForkScore** — aplicativo mobile de avaliação gastronômica para restaurantes, cafeterias e similares.

Este documento serve como **fundação imutável** para decisões técnicas futuras, garantindo:
- ✅ Consistência arquitetural
- ✅ Escalabilidade progressiva  
- ✅ Qualidade sustentável
- ✅ Facilidade de manutenção

---

## 2. 🧱 Princípios Fundamentais

### I. Simplicidade Primeiro (MVP-driven)

**Regra não-negociável:**
- Evitar overengineering em favor de entrega rápida de valor
- Preferir soluções que funcionam agora a soluções "perfeitas" para o futuro
- Cada decisão tecnológica deve ser justificada por valor imediato ao usuário
- YAGNI (You Aren't Gonna Need It): não implementar funcionalidades antecipadas

**Rationale:** O diferencial do ForkScore não é tecnologia, mas qualidade das avaliações e UX. MVP modular permite iteração rápida sem dívida técnica.

---

### II. Separação de Responsabilidades (Clean Architecture)

**Regra não-negociável:**
- Regras de negócio isoladas de frameworks e infraestrutura
- Cada camada tem responsabilidade única e bem definida
- Domain NÃO depende de nenhuma tecnologia externa
- Interfaces (ports) definem contratos, não implementações

**Estrutura de Camadas (obrigatória):**
```
[Presentation] (Controllers/API) 
       ↓ (DTO → Use Case)
[Application] (Use Cases/Services)
       ↓ (Command → Entity)
[Domain] (Entidades, Agregados, Value Objects)
       ↑ (Port → Adapter)
[Infrastructure] (BD, APIs, Frameworks)
```

**Rationale:** Permite evolução tecnológica sem reescrever lógica de negócio. Facilita testes e manutenção.

---

### III. Escalabilidade Progressiva

**Regra não-negociável:**
- Arquitetura preparada para evolução sem complexidade inicial
- Monólito modular no MVP é aceitável; decomposição para microserviços é opcional futuro
- Todas as decisões de DB/Cache devem ser transparentes via camada de infraestrutura
- Trocar SQLite → PostgreSQL → Redis não pode quebrar domínio

**Roadmap de Fases:**
- **Fase 1 (MVP):** Monólito modular + SQLite + API REST
- **Fase 2 (Crescimento):** Cache (Redis), melhorias de busca
- **Fase 3 (Escala):** PostgreSQL, possível decomposição em microserviços

**Rationale:** Começa simples, cresce conforme demanda, mantém domínio imutável.

---

### IV. Testabilidade

**Regra não-negociável:**
- Código deve ser facilmente testável, especialmente o domínio
- Testes unitários focados no domínio (regras de negócio)
- Repositórios e dependências externas são mockáveis (via interfaces)
- Nenhuma regra de negócio pode estar acoplada a banco ou framework

**Diretrizes:**
- Domínio: 100% cobertura de testes unitários
- Casos de Uso: testes com mocks de repositórios
- Controllers: testes de integração HTTP
- Infraestrutura: testes de contrato

**Rationale:** Confiabilidade nas recomendações depende de lógica bem testada.

---

### V. Design User-Centric (Avaliação Simples)

**Regra não-negociável:**
- Interface deve permitir avaliação em menos de 1 minuto
- Avaliação é ludica, com estrelas 0-5 (não complexa)
- Cada critério obriga comentário, < 3 estrelas obriga justificativa
- Experiência do usuário é diferencial competitivo, não afterthought

**Critérios de Avaliação (fixos):**
1. **Sabor**
2. **Atendimento**
3. **Custo-benefício / Opções**
4. **Infraestrutura do local**

**Rationale:** Avaliações confiáveis atraem outros usuários; UX simples aumenta volume de avaliações.

---

## 3. 🏗️ Arquitetura Geral

### 3.1 Padrão Arquitetural

**Obrigatório:** Arquitetura Hexagonal (Ports and Adapters)

```
   [Usuário] → [Mobile UI]
                     ↓
         [Controller/Presenter]
                     ↓
         [Use Case / Orquestrador]
                     ↓
         [Domain Entities / Rules]
                ↗        ↖
      [Adapter BD]    [Adapter Auth]
            ↓              ↓
        [SQLite]      [JWT / bcrypt]
```

**Por que Hexagonal?**
- Isolamento de domínio de tecnologia
- Fácil troca de implementações (SQLite ↔ PostgreSQL)
- Testabilidade máxima
- Escalabilidade sem refatoração

---

### 3.2 Responsabilidade de Cada Camada

| Camada | Responsabilidade | PERMITE | NÃO PERMITE |
|--------|-----------------|---------|-----------|
| **Presentation** | Receber requisições, validar formato | Controllers, DTOs, HTTP | Lógica de negócio, acesso direto a BD |
| **Application** | Orquestrar casos de uso | Use Cases, validações, transações | Regras de domínio, dependências externas |
| **Domain** | Regras de negócio, entidades | Entidades, Agregados, Value Objects, Interfaces (Ports) | Tecnologia externa, frameworks |
| **Infrastructure** | Implementar interfaces de domínio | Repositórios, BD, APIs externas, frameworks | Lógica de negócio, decisões de domínio |

---

## 4. 📦 Organização do Código

### Estrutura por Módulos de Domínio

```
/src
  /modules
    /users          # Gestão de usuários
      /domain
      /application
      /infra
      /presentation
    
    /auth           # Autenticação e autorização
      /domain
      /application
      /infra
      /presentation
    
    /places         # Cadastro de locais
      /domain
      /application
      /infra
      /presentation
    
    /reviews        # Sistema de avaliações
      /domain
      /application
      /infra
      /presentation
    
    /shared         # Utilitários comuns
      /domain/value-objects
      /infra/config
```

### Cada Módulo Contém

```
/domain
  /entities
  /aggregates
  /value-objects
  /ports (interfaces para infraestrutura)
  /exceptions

/application
  /use-cases
  /dtos
  /services (orquestradores)
  /mappers

/infra
  /repositories (implementações de ports)
  /external-services
  /database (drivers, migrations)
  /config

/presentation
  /controllers
  /routes
```

---

## 5. 📱 Frontend (Mobile)

### Tecnologia Preferencial

**Flutter** (por: performance, hot reload, cross-platform)  
**Alternativa:** React Native

### Diretrizes Obrigatórias

- ✅ Interface simples e responsiva
- ✅ Avaliação completável em < 1 minuto
- ✅ Estado management centralizador (Provider, Riverpod, ou similar)
- ✅ Não fazer requisições diretas a BD; sempre via API Backend
- ✅ Testes: widget + integração
- ✅ Navegação centralizada em rotas nomeadas, sem fluxo crítico escondido em estado local de tela
- ✅ Classificação explícita de rotas públicas e protegidas
- ✅ Shell autenticado reutilizável para áreas pós-login

### Governança de Rotas e Telas

**Regra não-negociável:**
- Toda nova rota deve ser declarada em um registro central do app
- Toda nova tela deve definir se é **pública** ou **protegida** antes de ser implementada
- Páginas internas do produto devem nascer como protegidas por padrão
- Login e cadastro são exceções públicas explícitas; novas exceções exigem justificativa na spec
- Nenhuma tela protegida pode depender apenas de ocultação visual ou botão desabilitado para controlar acesso

**Definições obrigatórias para futuras implementações:**

1. **Rotas públicas**
   - acessíveis sem autenticação;
   - usadas apenas para entrada no produto ou fluxos estritamente anônimos;
   - no MVP, limitadas a `login` e `cadastro`, salvo nova decisão documentada.

2. **Rotas protegidas**
   - exigem sessão autenticada válida;
   - incluem home, perfil, locais, avaliações e qualquer tela pós-login;
   - devem ser redirecionadas para login quando abertas sem sessão.

3. **Redirecionamento**
   - acesso anônimo a rota protegida deve ir para login;
   - após autenticação, o app deve priorizar retornar à rota originalmente solicitada;
   - usuário autenticado não deve permanecer em login/cadastro sem necessidade operacional real.

4. **Logout**
   - deve limpar a sessão local imediatamente;
   - deve remover acesso a qualquer rota protegida já aberta;
   - deve devolver o usuário para uma rota pública segura.

5. **Expansão futura**
   - novas telas autenticadas devem reutilizar o mesmo guard central;
   - não duplicar lógica de autorização dentro de cada página;
   - placeholders, shells e menus internos devem continuar coerentes com a tabela central de rotas.

**Checklist obrigatório em qualquer nova tela/rota:**
- A rota foi adicionada ao registro central?
- A rota foi marcada como pública ou protegida?
- O comportamento de redirecionamento foi definido?
- O logout continua bloqueando essa tela?
- Há teste cobrindo acesso permitido e acesso negado quando aplicável?

### Fluxo de UX Crítico

```
Login → Perfil → Buscar Local / Listar Avaliadas 
  → Avaliar (Sabor → Atendimento → Custo → Infra)
  → Comentários (obrigatórios por critério)
  → Justificativa (se < 3 ⭐)
  → Submeter → Sucesso
```

---

## 6. 🧠 Backend (API)

### Tecnologia Preferencial

**Node.js + NestJS** (por: produtividade, TypeScript, modular)  
**Alternativa:** Java + Spring Boot

### Diretrizes Obrigatórias

- ✅ Arquitetura Hexagonal (vide seção 3)
- ✅ API REST com rotas RESTful
- ✅ Validação de entrada em Controller (schemas)
- ✅ Tratamento de erros centralizado (exception filters)
- ✅ Logging estruturado de operações críticas
- ✅ Versionamento de API (opcional para MVP, crítico para Fase 2)

### Estrutura de Resposta HTTP

```json
// Sucesso
{ "status": "success", "data": {...} }

// Erro
{ "status": "error", "code": "INVALID_RATING", "message": "..." }
```

---

## 7. 🗄️ Banco de Dados

### Fase 1: MVP

**SQLite** (simplificidade, sem setup de servidor)

### Fase 2+: Crescimento

**PostgreSQL** (escalabilidade, features avançadas)

### Diretrizes Obrigatórias

- ✅ Modelagem deve ser compatível com PostgreSQL desde o MVP
- ✅ Não usar features SQLite-específicas (ex: tipos de dados não-standard)
- ✅ Migrations versionadas desde o início
- ✅ Troca de BD deve ser transparente (via Repositório)
- ✅ Sem queries SQL diretas fora de infraestrutura

### Schema Essencial (Conceitual)

```
[users]
  - id, email, password_hash, name, created_at

[places]
  - id, name, type, address, lat, lng, owner_id, created_at

[reviews]
  - id, user_id, place_id, rating_overall, created_at

[review_criteria]
  - id, review_id, criteria (sabor|atendimento|custo|infra), rating, comment, is_justified, created_at
```

---

## 8. 🔌 Persistência (Ports & Adapters)

### Padrão Obrigatório

1. **Domain define Interface (Port)**
   ```typescript
   // domain/ports/review.repository.ts
   interface ReviewRepository {
     save(review: Review): Promise<void>;
     findById(id: string): Promise<Review | null>;
   }
   ```

2. **Infrastructure implementa (Adapter)**
   ```typescript
   // infra/repositories/review.sqlite.adapter.ts
   class ReviewSQLiteAdapter implements ReviewRepository {
     async save(review: Review): Promise<void> { /* SQL */ }
     async findById(id: string): Promise<Review | null> { /* SQL */ }
   }
   ```

3. **Application injeta (Dependency Injection)**
   ```typescript
   // application/use-cases/create-review.usecase.ts
   constructor(private reviewRepository: ReviewRepository) {}
   ```

**Benefício:** Trocar `ReviewSQLiteAdapter` por `ReviewPostgresAdapter` sem alterar Use Case ou Domain.

---

## 9. ⭐ Sistema de Avaliação (Regras Críticas)

### Critérios Obrigatórios

| Critério | Descrição | Estrelas |
|----------|-----------|----------|
| **Sabor** | Qualidade e gosto da comida/bebida | 0-5 ⭐ |
| **Atendimento** | Qualidade do atendimento e simpatia | 0-5 ⭐ |
| **Custo-benefício / Opções** | Variedade e valor | 0-5 ⭐ |
| **Infraestrutura** | Limpeza, conforto, espaço | 0-5 ⭐ |

### Regras de Negócio (não-negociáveis)

1. **Cada critério obriga comentário** (mín. 10 caracteres)
2. **Se rating < 3 ⭐:** comentário é justificativa obrigatória
3. **Se rating ≥ 3 ⭐:** comentário é sugestão/feedback
4. **Avaliação completa** = todos 4 critérios preenchidos
5. **Agregação:** média de critérios = rating geral do local

### Implementação Domain

```typescript
// domain/entities/review-criteria.ts
class ReviewCriteria {
  criterion: 'sabor' | 'atendimento' | 'custo' | 'infra';
  rating: number; // 0-5
  comment: string; // min 10 chars
  isJustified: boolean; // true se rating < 3
  
  constructor(criterion, rating, comment) {
    if (comment.length < 10) throw new InvalidCommentError();
    if (rating < 3 && !isJustified) throw new MissingJustificationError();
  }
}
```

---

## 10. 🔐 Autenticação e Segurança

### Estratégia Obrigatória

| Aspecto | Implementação |
|--------|----------------|
| **Autenticação** | JWT (JSON Web Token) stateless |
| **Criptografia de Senha** | bcrypt (cost factor mín. 10) |
| **Refresh Token** | Implementar para revalidação |
| **HTTPS** | Obrigatório em produção |
| **CORS** | Configurado por origem |

### Fluxo de Autenticação

```
1. POST /auth/register → Hash senha, criar user, retornar JWT
2. POST /auth/login → Validar email + senha, retornar JWT + Refresh
3. GET /api/reviews → Header: "Authorization: Bearer <token>"
4. Token expirado → POST /auth/refresh → Novo token
```

### Regras de Acesso no Frontend

- O backend continua sendo a fonte de verdade para autenticação e autorização
- O frontend deve aplicar guard de navegação mesmo quando a sessão for mockada no MVP
- Guard de rota não substitui validação no backend; ele apenas evita exposição indevida da UX
- Toda tela protegida deve assumir que a sessão pode expirar e deve tratar retorno a login de forma segura
- Não criar atalhos que permitam abrir home ou áreas internas fora do fluxo autenticado

---

## 11. 🚀 Estratégia de Evolução

### Fase 1: MVP (Agora - Semanas 1-8)

**Meta:** Produto mínimo viável com todas as funcionalidades essenciais

- ✅ Auth (login/signup com JWT)
- ✅ Perfil de usuário
- ✅ Cadastro de locais
- ✅ Sistema de avaliação (4 critérios + comentários)
- ✅ Frontend Flutter simples
- ✅ Backend NestJS + SQLite
- ✅ Teste de fumaça e unitários

**Infraestrutura:** Monólito modular, Deploy local ou simples cloud (Vercel, Firebase)

---

### Fase 2: Crescimento (Semanas 9-16)

**Meta:** Melhorias de performance e experiência

- ✅ Cache Redis para queries frequentes
- ✅ Busca melhorada (locais por proximidade, filtros)
- ✅ Paginação de reviews
- ✅ Notificações push
- ✅ Imagens de pratos/ambientes
- ✅ Integração Google Maps

**Infraestrutura:** Monólito + Redis, DB migrável para PostgreSQL

---

### Fase 3: Escala (Semanas 17+)

**Meta:** Suportar crescimento exponencial

- ✅ PostgreSQL + índices otimizados
- ✅ Possível decomposição: serviço de reviews isolado
- ✅ Filas (RabbitMQ/Kafka) para notificações assíncronas
- ✅ ML: recomendações personalizadas
- ✅ Analytics: dashboards de trends

**Infraestrutura:** Possível arquitetura de microserviços, mas começar monólito

---

## 12. ⚠️ Restrições Arquiteturais (Mandatórias)

### ❌ PROIBIDO

- ❌ Microserviços no MVP (complexidade injustificada)
- ❌ Acoplar domínio a frameworks (use adapters)
- ❌ Implementar lógica de negócio em controllers
- ❌ Acessar banco diretamente fora de repositórios
- ❌ Queries SQL em use cases ou domain
- ❌ Dependências circulares entre módulos
- ❌ Compartilhar domínio entre módulos (use value objects públicos)
- ❌ Criptografia ou hashing fora de infraestrutura
- ❌ Criar rota nova fora do registro central de navegação
- ❌ Promover tela interna a pública sem decisão documentada em spec/plano
- ❌ Duplicar lógica de auth guard em múltiplas páginas
- ❌ Permitir acesso à home ou telas pós-login por navegação local sem sessão

### ✅ OBRIGATÓRIO

- ✅ Todos os módulos seguem estrutura padrão
- ✅ Domain nunca importa Application ou Infrastructure
- ✅ Application importa Domain, mas não Controllers
- ✅ Controllers são thin (validação + roteamento)
- ✅ Toda dependência externa vai para camada Infrastructure
- ✅ Interfaces (ports) definem contratos antes de implementação
- ✅ Toda tela nova explicita sua política de acesso já na spec
- ✅ Toda rota protegida reutiliza guard central e fluxo padrão de redirecionamento
- ✅ Logout é validado sempre que uma nova área autenticada for adicionada

---

## 13. 🧪 Testes

### Estratégia Obrigatória

| Nível | Cobertura | Escopo | Tecnologia |
|-------|-----------|--------|-----------|
| **Unitário** | Domain: 100% | Entidades, agregados, services | Jest / Vitest |
| **Integração** | Use Cases: 80%+ | Casos de uso com mocks de repositórios | Jest + Sinon |
| **Integração DB** | Repositórios: 80%+ | Salvar/recuperar dados | Jest + SQLite em-memória |
| **E2E** | Fluxos críticos: 60%+ | Auth, avaliação completa | Detox (Flutter), Supertest (API) |
| **Widget** | Flutter UI: 70%+ | Widgets, navegação | Flutter Widget Tests |

### Exemplo de Teste Domain

```typescript
// domain/entities/__tests__/review-criteria.spec.ts
describe('ReviewCriteria', () => {
  it('MUST throw MissingJustificationError if rating < 3 without justification', () => {
    expect(() => new ReviewCriteria('sabor', 2, 'Ruim.'))
      .toThrow(MissingJustificationError);
  });

  it('MUST allow rating < 3 with justification', () => {
    expect(() => new ReviewCriteria(
      'sabor', 
      2, 
      'Comida sem sal, muito seca, não recomendo.',
      true
    )).not.toThrow();
  });
});
```

---

## 14. 💡 Diretriz Estratégica Final

### O Diferencial do ForkScore Não É Tecnologia

O sucesso depende de:

1. **Qualidade das Avaliações** → Regras estritas (justificativas, múltiplos critérios)
2. **Experiência do Usuário** → UX simples (< 1 minuto por avaliação)
3. **Confiabilidade das Recomendações** → Dados limpos, validados, confiáveis
4. **Comunidade Ativa** → Gamification (badges, rankings), notificações

### Stack Escolhido é Meio, Não Fim

- Flutter/NestJS/SQLite são escolhas pragmáticas, não dogmáticas
- Trocar tecnologia é permitido; refatorar domínio não
- Dívida técnica em infraestrutura é aceitável; em domínio, nunca

---

## 15. 📌 Conclusão

Este projeto evolui de forma **controlada e progressiva**, mantendo:

- ✅ **Arquitetura limpa** — domínio imutável
- ✅ **Código sustentável** — testável e modular
- ✅ **Facilidade de adaptação** — trocar tecnologia sem reescrever lógica
- ✅ **Foco em valor** — simplicidade, UX, qualidade de dados

---

## Governance

### Compliance

- **Todos** os PRs/reviews devem verificar conformidade com esta constituição
- **Violações** de restrições arquitecturais (seção 12) são bloqueantes
- **Complexidade** deve ser justificada: impacto em tempo de entrega + manutenção futura
- **Amendments** requerem atualização de versão + notificação de dependências (templates, specs)

### Amendment Process

1. Propor mudança (issue ou discussion)
2. Documentar racional (impacto no roadmap, mudança de princípios)
3. Atualizar constituição + versão
4. Sincronizar templates: spec.md, plan.md, tasks.md
5. Commit + communicar mudança ao time

### Review Cadence

- **Quarterly:** Revisar efetividade de princípios
- **Per-Phase:** Adaptar a roadmap de evolução conforme progresso real

---

**Este documento é vivo e evolui com o projeto. Última atualização: 2026-04-27 v1.1.0**

**Desenvolvido para:** ForkScore - Aplicativo de Avaliação Gastronômica  
**Stack:** Flutter (Mobile) + NestJS (Backend) + SQLite → PostgreSQL  
**Paradigma:** Arquitetura Hexagonal, DDD, Clean Code
