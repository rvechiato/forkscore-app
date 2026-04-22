# Phase 1: Data Model & Domain Entities

**Feature**: Sistema Completo de Avaliação de Locais  
**Date**: April 22, 2026  
**Architecture**: Hexagonal + Clean Architecture

---

## 1. Domain Model Overview

```
┌─────────────────────────────────────────────────────────┐
│                   DOMAIN LAYER                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌────────────┐      ┌────────────┐    ┌────────────┐ │
│  │    User    │      │   Place    │    │   Review   │ │
│  │  (Entity)  │      │  (Entity)  │    │ (Aggregate)│ │
│  └────────────┘      └────────────┘    └────────────┘ │
│                                              ↓          │
│                              ┌─────────────────────────┐│
│                              │  ReviewCriteria (VO)    ││
│                              │  Justification (VO)     ││
│                              │  Rating (VO)            ││
│                              │  Comment (VO)           ││
│                              └─────────────────────────┘│
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Core Entities

### 2.1 User Entity

**Purpose**: Representa um usuário do sistema. Responsável por autenticação e identificação.

```typescript
// domain/entities/user.entity.ts

class User {
  readonly id: string;                    // UUID
  readonly email: string;                 // Unique
  readonly passwordHash: string;          // bcrypt hash, nunca plaintext
  readonly name: string;
  readonly profilePicture?: string;       // URL optional
  readonly bio?: string;
  readonly createdAt: Date;
  readonly updatedAt: Date;
  
  // Constructor: validações básicas de negócio
  constructor(
    id: string,
    email: string,
    passwordHash: string,
    name: string,
    profilePicture?: string,
    bio?: string,
  ) {
    if (!email.includes('@')) {
      throw new InvalidEmailError();
    }
    if (name.length < 2) {
      throw new InvalidNameError();
    }
    this.id = id;
    this.email = email;
    this.passwordHash = passwordHash;
    this.name = name;
    this.profilePicture = profilePicture;
    this.bio = bio;
    this.createdAt = new Date();
    this.updatedAt = new Date();
  }
  
  // Business Methods
  updateProfile(name: string, bio: string, picture?: string): void {
    if (name.length < 2) throw new InvalidNameError();
    this.name = name;
    this.bio = bio;
    if (picture) this.profilePicture = picture;
    this.updatedAt = new Date();
  }
}
```

**Invariants** (regras que NUNCA podem ser violadas):
- Email é único (validado em repository)
- Email tem formato válido
- Nome tem mínimo 2 caracteres
- Senha é sempre hasheada (nunca plaintext em domínio)

---

### 2.2 Place Entity

**Purpose**: Representa um local a ser avaliado (restaurante, bar, café, etc).

```typescript
// domain/entities/place.entity.ts

class Place {
  readonly id: string;
  readonly name: string;
  readonly category: 'restaurant' | 'bar' | 'cafe' | 'other';
  readonly address: string;              // Endereço textual
  readonly latitude?: number;            // Opcional (futuro: GPS)
  readonly longitude?: number;
  readonly description: string;
  readonly creatorId: string;            // User ID que criou o local
  readonly createdAt: Date;
  readonly updatedAt: Date;
  
  constructor(
    id: string,
    name: string,
    category: 'restaurant' | 'bar' | 'cafe' | 'other',
    address: string,
    description: string,
    creatorId: string,
    latitude?: number,
    longitude?: number,
  ) {
    if (!name || name.length < 3) {
      throw new InvalidPlaceNameError();
    }
    if (!address || address.length < 5) {
      throw new InvalidAddressError();
    }
    
    this.id = id;
    this.name = name;
    this.category = category;
    this.address = address;
    this.description = description;
    this.creatorId = creatorId;
    this.latitude = latitude;
    this.longitude = longitude;
    this.createdAt = new Date();
    this.updatedAt = new Date();
  }
  
  // Business Methods
  updateInfo(name: string, address: string, description: string): void {
    if (!name || name.length < 3) throw new InvalidPlaceNameError();
    if (!address || address.length < 5) throw new InvalidAddressError();
    
    this.name = name;
    this.address = address;
    this.description = description;
    this.updatedAt = new Date();
  }
}
```

**Invariants**:
- Nome deve ter mínimo 3 caracteres
- Endereço deve ter mínimo 5 caracteres
- Categoria é enum limitado
- Criador deve existir

---

### 2.3 Review Aggregate

**Purpose**: Representa uma avaliação completa de um lugar por um usuário. É um AGGREGATE ROOT (entidade que agrupa múltiplos value objects).

```typescript
// domain/entities/review.entity.ts

class Review {
  readonly id: string;
  readonly userId: string;
  readonly placeId: string;
  readonly criteria: ReviewCriteria[];   // Array de value objects
  readonly status: 'draft' | 'submitted' | 'edited';
  readonly createdAt: Date;
  readonly updatedAt: Date;
  
  constructor(
    id: string,
    userId: string,
    placeId: string,
  ) {
    this.id = id;
    this.userId = userId;
    this.placeId = placeId;
    this.criteria = [];
    this.status = 'draft';
    this.createdAt = new Date();
    this.updatedAt = new Date();
  }
  
  // Business Methods
  addCriterion(criterion: ReviewCriteria): void {
    // Validar que critério não é duplicado
    const exists = this.criteria.some(c => c.type === criterion.type);
    if (exists) {
      throw new DuplicateCriterionError();
    }
    
    // Validar que tipo é válido
    const validTypes = ['taste', 'service', 'value', 'infrastructure'];
    if (!validTypes.includes(criterion.type)) {
      throw new InvalidCriterionTypeError();
    }
    
    this.criteria.push(criterion);
    this.updatedAt = new Date();
  }
  
  submit(): void {
    // Validar que TODOS 4 critérios foram preenchidos
    const requiredCriteria = ['taste', 'service', 'value', 'infrastructure'];
    const addedCriteria = this.criteria.map(c => c.type);
    
    const missing = requiredCriteria.filter(c => !addedCriteria.includes(c));
    if (missing.length > 0) {
      throw new IncompletReviewError(`Missing: ${missing.join(', ')}`);
    }
    
    // Validar que cada critério tem comentário e justificativa obrigatória se < 3
    this.criteria.forEach(c => {
      if (!c.comment.value || c.comment.value.length < 10) {
        throw new MissingCommentError(`Critério ${c.type} precisa comentário`);
      }
      if (c.rating.value < 3 && !c.justification?.value) {
        throw new MissingJustificationError(`Critério ${c.type} é negativo e precisa justificativa`);
      }
    });
    
    this.status = 'submitted';
    this.updatedAt = new Date();
  }
  
  getAverageRating(): number {
    if (this.criteria.length === 0) return 0;
    const sum = this.criteria.reduce((acc, c) => acc + c.rating.value, 0);
    return sum / this.criteria.length;
  }
}
```

**Invariants**:
- Uma review tem sempre um usuário e um local
- Uma review deve ter exatamente 4 critérios antes de ser submetida
- Cada critério tem comentário obrigatório
- Critério com rating < 3 DEVE ter justificativa
- Status passa por: draft → submitted (ou editado)

---

## 3. Value Objects

Value Objects são imutáveis e representam conceitos sem identidade própria. Encapsulam validação.

### 3.1 Rating Value Object

```typescript
// domain/value-objects/rating.vo.ts

class Rating {
  readonly value: number; // 0-5
  
  constructor(value: number) {
    if (!Number.isInteger(value) || value < 0 || value > 5) {
      throw new InvalidRatingError(`Rating must be integer between 0 and 5, got ${value}`);
    }
    this.value = value;
  }
  
  isNegative(): boolean {
    return this.value < 3;
  }
  
  equals(other: Rating): boolean {
    return this.value === other.value;
  }
}
```

**Why Value Object?**
- Rating tem regras estritas (0-5, inteiro)
- Não tem identidade própria (duas avaliações de 4 ⭐ são iguais)
- Imutável: criar novo em vez de modificar

---

### 3.2 Comment Value Object

```typescript
// domain/value-objects/comment.vo.ts

class Comment {
  readonly value: string;
  readonly characterCount: number;
  
  constructor(text: string) {
    const trimmed = text?.trim() || '';
    
    if (trimmed.length < 10) {
      throw new InvalidCommentError(`Comment must have at least 10 characters, got ${trimmed.length}`);
    }
    
    if (trimmed.length > 500) {
      throw new InvalidCommentError(`Comment must not exceed 500 characters`);
    }
    
    this.value = trimmed;
    this.characterCount = trimmed.length;
  }
  
  equals(other: Comment): boolean {
    return this.value === other.value;
  }
}
```

---

### 3.3 Justification Value Object

```typescript
// domain/value-objects/justification.vo.ts

class Justification {
  readonly value: string;           // Texto da justificativa
  readonly isRequired: boolean;      // true se rating < 3
  
  constructor(text: string | null, rating: Rating) {
    const trimmed = text?.trim() || '';
    
    // SE rating < 3, justificativa é OBRIGATÓRIA
    if (rating.isNegative() && !trimmed) {
      throw new MissingJustificationError(
        `Rating ${rating.value} stars requires justification`
      );
    }
    
    // Validação de comprimento (se fornecida)
    if (trimmed && trimmed.length < 10) {
      throw new InvalidJustificationError(
        `Justification must have at least 10 characters`
      );
    }
    
    if (trimmed && trimmed.length > 500) {
      throw new InvalidJustificationError(
        `Justification must not exceed 500 characters`
      );
    }
    
    this.value = trimmed;
    this.isRequired = rating.isNegative();
  }
  
  static optional(text: string | null): Justification | null {
    return text ? new Justification(text, new Rating(3)) : null;
  }
}
```

---

### 3.4 ReviewCriteria Value Object (Composite)

```typescript
// domain/value-objects/review-criteria.vo.ts

class ReviewCriteria {
  readonly type: 'taste' | 'service' | 'value' | 'infrastructure';
  readonly rating: Rating;
  readonly comment: Comment;
  readonly justification: Justification | null;
  
  constructor(
    type: string,
    ratingValue: number,
    commentText: string,
    justificationText?: string,
  ) {
    // Validar tipo
    const validTypes = ['taste', 'service', 'value', 'infrastructure'];
    if (!validTypes.includes(type)) {
      throw new InvalidCriterionTypeError();
    }
    
    // Criar value objects (que fazem suas próprias validações)
    const rating = new Rating(ratingValue);
    const comment = new Comment(commentText);
    const justification = new Justification(justificationText || null, rating);
    
    // Tudo validado, atribuir
    this.type = type as any;
    this.rating = rating;
    this.comment = comment;
    this.justification = justification;
  }
  
  static create(type: string, rating: number, comment: string, justification?: string): ReviewCriteria {
    return new ReviewCriteria(type, rating, comment, justification);
  }
}
```

---

## 4. Entity Relationships (ERD)

```
┌──────────────────┐         ┌──────────────────┐
│      User        │ 1    ∞  │      Review      │
│                  │◄────────►│                  │
│  - id (PK)       │ user_id  │  - id (PK)       │
│  - email (UQ)    │          │  - place_id (FK) │
│  - passwordHash  │          │  - userId (FK)   │
│  - name          │          │  - status        │
│                  │          │                  │
└──────────────────┘          └──────────────────┘
                                       │
                                       │ 1 to many
                                       ↓
                              ┌──────────────────────┐
                              │   ReviewCriteria     │
                              │   (value object)     │
                              │                      │
                              │  - type              │
                              │  - rating (0-5)      │
                              │  - comment           │
                              │  - justification     │
                              └──────────────────────┘


┌──────────────────┐
│      Place       │ 1    ∞  ┌──────────────────┐
│                  │◄────────┤      Review      │
│  - id (PK)       │ place_id│  - id (PK)       │
│  - name          │         │  - userId (FK)   │
│  - category      │         │  - placeId (FK)  │
│  - address       │         │                  │
│  - creatorId(FK) │         └──────────────────┘
│                  │
└──────────────────┘
       ↑
       │
       │ creator_id
       │
   User (1:many relationship)
```

---

## 5. Domain Exceptions

Exceções que podem ser lançadas pelo domínio. São usadas para comunicar erros de negócio.

```typescript
// domain/exceptions/

// Validation Errors
class InvalidRatingError extends DomainException {}
class InvalidCommentError extends DomainException {}
class MissingJustificationError extends DomainException {}
class InvalidEmailError extends DomainException {}
class InvalidNameError extends DomainException {}
class InvalidPlaceNameError extends DomainException {}
class InvalidAddressError extends DomainException {}
class InvalidCriterionTypeError extends DomainException {}

// State Errors
class IncompletReviewError extends DomainException {}
class DuplicateCriterionError extends DomainException {}

// User Errors
class UserNotFoundError extends DomainException {}
class EmailAlreadyExistsError extends DomainException {}
class InvalidCredentialsError extends DomainException {}

// Place Errors
class PlaceNotFoundError extends DomainException {}

// Review Errors
class ReviewNotFoundError extends DomainException {}
class ReviewAlreadyExistsError extends DomainException {}
```

---

## 6. Ports (Interfaces) - What Infrastructure Must Implement

```typescript
// domain/ports/user.repository.ts
interface UserRepository {
  save(user: User): Promise<void>;
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  update(user: User): Promise<void>;
}

// domain/ports/place.repository.ts
interface PlaceRepository {
  save(place: Place): Promise<void>;
  findById(id: string): Promise<Place | null>;
  findAll(): Promise<Place[]>;
  update(place: Place): Promise<void>;
}

// domain/ports/review.repository.ts
interface ReviewRepository {
  save(review: Review): Promise<void>;
  findById(id: string): Promise<Review | null>;
  findByUserAndPlace(userId: string, placeId: string): Promise<Review | null>;
  findByPlaceId(placeId: string): Promise<Review[]>;
  findByUserId(userId: string): Promise<Review[]>;
  update(review: Review): Promise<void>;
}

// domain/ports/password-hasher.ts
interface PasswordHasher {
  hash(plainPassword: string): Promise<string>;
  compare(plainPassword: string, hash: string): Promise<boolean>;
}

// domain/ports/id-generator.ts
interface IdGenerator {
  generate(): string; // UUID v4
}
```

---

## 7. Aggregate Relationships

### Review é o Aggregate Root

**Why?**
- Coordena múltiplos value objects (ReviewCriteria)
- Contém lógica de negócio complexa (validação de completude, justificativa)
- Transações: submeter review submete todos os critérios atomicamente

**Invariants da Review (nunca violados):**
1. Toda review tem userId e placeId válidos
2. Antes de submeter: exatamente 4 critérios
3. Todo critério tem comentário (min 10 chars)
4. Se rating < 3: justificativa obrigatória
5. Uma review por user/place (edição sobrescreve)

---

## 8. Database Schema (TypeORM Entities)

```typescript
// infra/database/entities/user.db.entity.ts
@Entity('users')
export class UserDBEntity {
  @PrimaryColumn('uuid')
  id: string;
  
  @Column('varchar', { unique: true })
  email: string;
  
  @Column('varchar')
  passwordHash: string;
  
  @Column('varchar')
  name: string;
  
  @Column('text', { nullable: true })
  profilePicture: string | null;
  
  @Column('text', { nullable: true })
  bio: string | null;
  
  @CreateDateColumn()
  createdAt: Date;
  
  @UpdateDateColumn()
  updatedAt: Date;
}

// infra/database/entities/place.db.entity.ts
@Entity('places')
export class PlaceDBEntity {
  @PrimaryColumn('uuid')
  id: string;
  
  @Column('varchar')
  name: string;
  
  @Column('varchar')
  category: string; // restaurant|bar|cafe|other
  
  @Column('text')
  address: string;
  
  @Column('float', { nullable: true })
  latitude: number | null;
  
  @Column('float', { nullable: true })
  longitude: number | null;
  
  @Column('text')
  description: string;
  
  @Column('uuid')
  creatorId: string;
  
  @ManyToOne(() => UserDBEntity)
  @JoinColumn({ name: 'creatorId' })
  creator: UserDBEntity;
  
  @CreateDateColumn()
  createdAt: Date;
  
  @UpdateDateColumn()
  updatedAt: Date;
}

// infra/database/entities/review.db.entity.ts
@Entity('reviews')
export class ReviewDBEntity {
  @PrimaryColumn('uuid')
  id: string;
  
  @Column('uuid')
  userId: string;
  
  @Column('uuid')
  placeId: string;
  
  @Column('varchar')
  status: 'draft' | 'submitted' | 'edited';
  
  @OneToMany(() => ReviewCriteriaDBEntity, rc => rc.review, { cascade: true })
  criteria: ReviewCriteriaDBEntity[];
  
  @ManyToOne(() => UserDBEntity)
  @JoinColumn({ name: 'userId' })
  user: UserDBEntity;
  
  @ManyToOne(() => PlaceDBEntity)
  @JoinColumn({ name: 'placeId' })
  place: PlaceDBEntity;
  
  @CreateDateColumn()
  createdAt: Date;
  
  @UpdateDateColumn()
  updatedAt: Date;
}

// infra/database/entities/review-criteria.db.entity.ts
@Entity('review_criteria')
export class ReviewCriteriaDBEntity {
  @PrimaryColumn('uuid')
  id: string;
  
  @Column('uuid')
  reviewId: string;
  
  @Column('varchar')
  type: 'taste' | 'service' | 'value' | 'infrastructure';
  
  @Column('integer')
  rating: number;
  
  @Column('text')
  comment: string;
  
  @Column('text', { nullable: true })
  justification: string | null;
  
  @ManyToOne(() => ReviewDBEntity, r => r.criteria)
  @JoinColumn({ name: 'reviewId' })
  review: ReviewDBEntity;
  
  @CreateDateColumn()
  createdAt: Date;
}
```

---

## Summary

| Entity | Type | Responsibility |
|--------|------|-----------------|
| **User** | Entity | Identificação, autenticação, perfil |
| **Place** | Entity | Cadastro e informação de locais |
| **Review** | Aggregate Root | Coordena critérios, validação de completude |
| **ReviewCriteria** | Value Object | Encapsula validação de rating/comment/justificativa |
| **Rating** | Value Object | 0-5, validação de range |
| **Comment** | Value Object | Min/max chars, validação |
| **Justification** | Value Object | Obrigatório se rating < 3 |

All entities and value objects are **technology-agnostic** (nenhum import de framework).
