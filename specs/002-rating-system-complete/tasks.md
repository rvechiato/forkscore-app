# Tasks: Sistema Completo de Avaliação de Locais

**Input**: Design documents from `/specs/002-rating-system-complete/`  
**Prerequisites**: ✅ plan.md, ✅ spec.md, ✅ research.md, ✅ data-model.md, ✅ contracts/api-endpoints.md

**Organization**: Tasks grouped by user story to enable independent implementation and testing.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization, dependencies, basic structure

- [ ] T001 Create NestJS project structure in `backend/` with modules (auth, users, places, reviews, shared)
- [ ] T002 Create Flutter project structure in `mobile/` with features (auth, places, profile, reviews)
- [ ] T003 [P] Setup backend dependencies: `npm install nestjs typeorm sqlite3 bcryptjs jsonwebtoken class-validator class-transformer`
- [ ] T004 [P] Setup mobile dependencies: `flutter pub add provider http cached_network_image`
- [ ] T005 [P] Setup ESLint + Prettier in `backend/` (NestJS default config)
- [ ] T006 [P] Setup dartfmt + dart analyzer in `mobile/`
- [ ] T007 Configure Git ignore files for both projects
- [ ] T008 Create `backend/.env.example` with JWT_SECRET, DATABASE_URL, CORS_ORIGIN
- [ ] T009 Create `mobile/lib/config/api_config.dart` with API base URL constant
- [ ] T010 Setup Docker Compose with SQLite service in `docker-compose.yaml`
- [ ] T011 Create TypeORM configuration in `backend/src/config/database.config.ts`
- [ ] T012 Create NestJS exception filter for centralized error handling in `backend/src/common/filters/http-exception.filter.ts`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story implementation

**⚠️ CRITICAL**: All tasks in this phase MUST be completed before any user story work begins.

### Database & ORM Setup

- [ ] T013 Create TypeORM migration structure with `npm run typeorm:migration:generate`
- [ ] T014 Create base database entities template in `backend/src/common/database/`
- [ ] T015 Create database service in `backend/src/modules/shared/infra/database/database.service.ts` for connection management

### Authentication Infrastructure (Shared)

- [ ] T016 Create JWT strategy in `backend/src/modules/auth/infra/strategies/jwt.strategy.ts` (reads JWT token)
- [ ] T017 Create JWT guard in `backend/src/common/guards/jwt.guard.ts` for protecting routes
- [ ] T018 Create bcrypt hasher adapter in `backend/src/modules/auth/infra/hash/bcrypt.hasher.ts` (hash/compare passwords)
- [ ] T019 Create auth configuration in `backend/src/config/auth.config.ts` (JWT_SECRET, expiration)
- [ ] T020 Create ID generator in `backend/src/modules/shared/infra/id.generator.ts` (UUID v4)

### API Response Format & Error Codes

- [ ] T021 Create standardized response DTO in `backend/src/common/dtos/response.dto.ts` (status, data, error)
- [ ] T022 Create exception classes hierarchy in `backend/src/common/exceptions/` (DomainException, ValidationException)
- [ ] T023 Create exception filter transformer in `backend/src/common/filters/` to map domain exceptions to HTTP responses

### Validation & Pipes

- [ ] T024 Create custom validation pipe in `backend/src/common/pipes/validation.pipe.ts` using class-validator
- [ ] T025 [P] Create validation DTOs base class in `backend/src/common/dtos/base.dto.ts`

### Mobile API Client Infrastructure

- [ ] T026 Create HTTP client service in `mobile/lib/core/network/api_client.dart` with interceptors for JWT
- [ ] T027 Create base models in `mobile/lib/shared/models/` for API responses
- [ ] T028 Create app providers/state in `mobile/lib/core/providers/app_providers.dart` for global state

### Testing Infrastructure (Optional but Recommended)

- [ ] T029 [P] Setup Jest configuration in `backend/jest.config.js`
- [ ] T030 [P] Create test utilities in `backend/tests/fixtures/` for mocking repositories
- [ ] T031 [P] Setup Flutter test configuration and test helpers in `mobile/test/helpers/`

**Checkpoint**: All foundational infrastructure is ready. User story implementation can now begin in parallel.

---

## Phase 3: User Story 1 - Criar Conta e Fazer Login (Priority: P1) 🎯

**Goal**: Enable users to register with email/password and login to access the application.

**Independent Test**: Create new account → logout → login with same credentials → access app successfully

### Domain Layer (US1)

- [ ] T032 [P] [US1] Create User domain entity in `backend/src/modules/users/domain/entities/user.entity.ts`
  - Properties: id, email, password_hash, name, profile_picture, bio, created_at, updated_at
  - Methods: updateProfile(), getPublicProfile()
  - Invariants: email is valid format, password never stored plaintext
  
- [ ] T033 [P] [US1] Create user exceptions in `backend/src/modules/users/domain/exceptions/`
  - InvalidEmailError, InvalidPasswordError, InvalidNameError, UserNotFoundError, EmailAlreadyExistsError

- [ ] T034 [US1] Create user repository port in `backend/src/modules/users/domain/ports/user.repository.ts`
  - Methods: save(user), findById(id), findByEmail(email), update(user)

### Application Layer (US1)

- [ ] T035 [US1] Create register use case in `backend/src/modules/auth/application/use-cases/register.usecase.ts`
  - Validates email, password strength, hashes password, creates user, returns JWT token
  
- [ ] T036 [US1] Create login use case in `backend/src/modules/auth/application/use-cases/login.usecase.ts`
  - Validates email/password, generates JWT + refresh token
  
- [ ] T037 [US1] Create refresh token use case in `backend/src/modules/auth/application/use-cases/refresh-token.usecase.ts`
  - Validates refresh token, issues new access token

- [ ] T038 [P] [US1] Create auth DTOs in `backend/src/modules/auth/application/dtos/`
  - RegisterDto, LoginDto, RefreshTokenDto, AuthResponseDto

- [ ] T039 [US1] Create auth service in `backend/src/modules/auth/application/auth.service.ts` (orchestrator for use cases)

### Infrastructure Layer (US1)

- [ ] T040 [P] [US1] Create User database entity in `backend/src/modules/users/infra/entities/user.db.entity.ts`
  
- [ ] T041 [P] [US1] Create TypeORM migration for users table: `backend/database/migrations/001-create-users.ts`
  - Columns: id (UUID PK), email (VARCHAR UQ), password_hash (VARCHAR), name (VARCHAR), profile_picture (TEXT nullable), bio (TEXT nullable), created_at, updated_at

- [ ] T042 [US1] Create user repository adapter in `backend/src/modules/users/infra/adapters/user.sqlite.adapter.ts` (implements UserRepository port)

### Presentation Layer (US1)

- [ ] T043 [US1] Create auth controller in `backend/src/modules/auth/presentation/auth.controller.ts`
  - Endpoints: POST /auth/register, POST /auth/login, POST /auth/refresh (from contracts/api-endpoints.md)

- [ ] T044 [P] [US1] Create auth routes in `backend/src/modules/auth/auth.module.ts` (NestJS module registration)

### Tests for US1 (Optional but Recommended)

- [ ] T045 [P] [US1] Create unit tests for User entity in `backend/tests/unit/users/user.entity.spec.ts`
  - Test: user creation, invariant validation, password hashing

- [ ] T046 [P] [US1] Create unit tests for register use case in `backend/tests/unit/auth/register.usecase.spec.ts`
  - Test: valid registration, duplicate email error, weak password error

- [ ] T047 [P] [US1] Create unit tests for login use case in `backend/tests/unit/auth/login.usecase.spec.ts`
  - Test: valid login, invalid credentials, JWT token generation

- [ ] T048 [US1] Create integration tests for auth endpoints in `backend/tests/integration/auth.controller.spec.ts`
  - Test: POST /auth/register (201), POST /auth/login (200), invalid credentials (401)

### Mobile Frontend for US1

- [ ] T049 [P] [US1] Create auth data source in `mobile/lib/features/auth/data/datasources/auth_remote.dart`
  - Methods: register(email, password, name), login(email, password), refreshToken()

- [ ] T050 [P] [US1] Create auth models in `mobile/lib/features/auth/data/models/`
  - AuthModel, UserModel (map from API JSON)

- [ ] T051 [US1] Create auth repository in `mobile/lib/features/auth/data/repositories/auth_repository.dart`
  - Delegates to data source, handles caching if needed

- [ ] T052 [US1] Create auth provider in `mobile/lib/features/auth/presentation/providers/auth_provider.dart`
  - State: isAuthenticated, currentUser, loading, error
  - Methods: register(), login(), logout()

- [ ] T053 [P] [US1] Create login page UI in `mobile/lib/features/auth/presentation/pages/login_page.dart`
  - Email/password TextFields, login button, link to register

- [ ] T054 [P] [US1] Create register page UI in `mobile/lib/features/auth/presentation/pages/register_page.dart`
  - Email/password/name TextFields, register button, validation messages

- [ ] T055 [US1] Create app navigation logic in `mobile/lib/main.dart` / router to conditionally show login or home based on auth state

**Checkpoint**: User Story 1 complete. Users can register and login. Test independently before moving to US2.

---

## Phase 4: User Story 2 - Completar Perfil (Priority: P1)

**Goal**: Allow authenticated users to view and update their profile (name, bio, profile picture).

**Independent Test**: Login → access profile page → update name/bio → verify persistence

### Domain Layer (US2)

- [ ] T056 [P] [US2] Extend User domain entity with profile update method in `backend/src/modules/users/domain/entities/user.entity.ts`
  - Method: updateProfile(name, bio, profilePicture)
  - Invariants: name min 2 chars, bio optional, picture is URL

- [ ] T057 [P] [US2] Create profile value object in `backend/src/modules/users/domain/value-objects/profile.vo.ts` (optional if keeping in entity)

### Application Layer (US2)

- [ ] T058 [US2] Create update profile use case in `backend/src/modules/auth/application/use-cases/update-profile.usecase.ts`
  - Validates input, updates user, saves to repository

- [ ] T059 [P] [US2] Create profile DTOs in `backend/src/modules/auth/application/dtos/update-profile.dto.ts`

### Presentation Layer (US2)

- [ ] T060 [US2] Create GET /users/me endpoint in `backend/src/modules/users/presentation/users.controller.ts`
  - Returns current authenticated user profile

- [ ] T061 [US2] Create PUT /users/me endpoint in `backend/src/modules/users/presentation/users.controller.ts`
  - Updates profile, returns updated user (from contracts/api-endpoints.md)

### Tests for US2 (Optional)

- [ ] T062 [P] [US2] Unit tests for profile update in `backend/tests/unit/users/update-profile.spec.ts`

- [ ] T063 [US2] Integration tests for profile endpoints in `backend/tests/integration/users.controller.spec.ts`

### Mobile Frontend for US2

- [ ] T064 [P] [US2] Create user data source in `mobile/lib/features/profile/data/datasources/user_remote.dart`
  - Methods: getProfile(), updateProfile(dto)

- [ ] T065 [P] [US2] Create user models in `mobile/lib/features/profile/data/models/user_model.dart`

- [ ] T066 [US2] Create user repository in `mobile/lib/features/profile/data/repositories/user_repository.dart`

- [ ] T067 [US2] Create profile provider in `mobile/lib/features/profile/presentation/providers/profile_provider.dart`
  - State: user, loading, error
  - Methods: loadProfile(), updateProfile(name, bio, picture)

- [ ] T068 [P] [US2] Create profile page UI in `mobile/lib/features/profile/presentation/pages/profile_page.dart`
  - Display: profile picture, name, bio (editable)
  - Buttons: edit, save, logout

- [ ] T069 [P] [US2] Create edit profile form widget in `mobile/lib/features/profile/presentation/widgets/edit_profile_form.dart`
  - TextFields for name, bio
  - Image picker for profile picture

**Checkpoint**: User Story 2 complete. Profile management works independently.

---

## Phase 5: User Story 3 - Cadastrar Locais para Avaliação (Priority: P1)

**Goal**: Allow authenticated users to add new places (restaurants, bars, cafes) to the system.

**Independent Test**: Login → add place with name/address → verify in places list

### Domain Layer (US3)

- [ ] T070 [P] [US3] Create Place domain entity in `backend/src/modules/places/domain/entities/place.entity.ts`
  - Properties: id, name, category, address, latitude, longitude, description, creator_id, created_at, updated_at
  - Methods: updateInfo(name, address, description)
  - Invariants: name min 3 chars, address min 5 chars, category enum

- [ ] T071 [P] [US3] Create place exceptions in `backend/src/modules/places/domain/exceptions/`
  - InvalidPlaceNameError, InvalidAddressError, PlaceNotFoundError

- [ ] T072 [US3] Create place repository port in `backend/src/modules/places/domain/ports/place.repository.ts`
  - Methods: save(place), findById(id), findAll(limit, offset), findByCategory(category), update(place)

### Application Layer (US3)

- [ ] T073 [US3] Create create place use case in `backend/src/modules/places/application/use-cases/create-place.usecase.ts`
  - Validates input, creates place, generates ID, saves

- [ ] T074 [P] [US3] Create place DTOs in `backend/src/modules/places/application/dtos/create-place.dto.ts`, `place.dto.ts`

- [ ] T075 [US3] Create places service in `backend/src/modules/places/application/places.service.ts` (orchestrator)

### Infrastructure Layer (US3)

- [ ] T076 [P] [US3] Create Place database entity in `backend/src/modules/places/infra/entities/place.db.entity.ts`

- [ ] T077 [P] [US3] Create TypeORM migration for places table: `backend/database/migrations/002-create-places.ts`
  - Columns: id, name, category, address, latitude, longitude, description, creator_id (FK users), created_at, updated_at

- [ ] T078 [US3] Create place repository adapter in `backend/src/modules/places/infra/adapters/place.sqlite.adapter.ts`

### Presentation Layer (US3)

- [ ] T079 [US3] Create places controller in `backend/src/modules/places/presentation/places.controller.ts`
  - Endpoints: POST /places, GET /places, GET /places/:id, PUT /places/:id (from contracts)

- [ ] T080 [P] [US3] Create places routes in `backend/src/modules/places/places.module.ts`

### Tests for US3 (Optional)

- [ ] T081 [P] [US3] Unit tests for Place entity in `backend/tests/unit/places/place.entity.spec.ts`

- [ ] T082 [US3] Integration tests for places endpoints in `backend/tests/integration/places.controller.spec.ts`

### Mobile Frontend for US3

- [ ] T083 [P] [US3] Create places data source in `mobile/lib/features/places/data/datasources/places_remote.dart`
  - Methods: getPlaces(limit, offset), getPlaceDetail(id), createPlace(dto)

- [ ] T084 [P] [US3] Create places models in `mobile/lib/features/places/data/models/place_model.dart`

- [ ] T085 [US3] Create places repository in `mobile/lib/features/places/data/repositories/places_repository.dart`

- [ ] T086 [US3] Create places provider in `mobile/lib/features/places/presentation/providers/places_provider.dart`
  - State: places, loading, error, selectedPlace
  - Methods: loadPlaces(), createPlace(dto), loadPlaceDetail(id)

- [ ] T087 [P] [US3] Create places list page in `mobile/lib/features/places/presentation/pages/places_list_page.dart`
  - ListView of places with name, category, address
  - Button to add new place
  - Tap to view detail / evaluate

- [ ] T088 [P] [US3] Create place detail page in `mobile/lib/features/places/presentation/pages/place_detail_page.dart`
  - Show place info, average rating, button to evaluate

- [ ] T089 [P] [US3] Create add place form widget in `mobile/lib/features/places/presentation/widgets/create_place_form.dart`
  - TextFields: name, category, address, description
  - Location picker (optional - text for MVP)

**Checkpoint**: User Story 3 complete. Places CRUD works independently.

---

## Phase 6: User Story 4 - Avaliar Local com Sistema de Estrelas (Priority: P1) ⭐

**Goal**: Enable users to rate places using a ludic star system (0-5) for 4 criteria: taste, service, value, infrastructure.

**Independent Test**: Login → select place → open rating → click stars for each criterion → save → verify rating saved

### Domain Layer (US4)

- [ ] T090 [P] [US4] Create Review aggregate root in `backend/src/modules/reviews/domain/entities/review.entity.ts`
  - Properties: id, user_id, place_id, criteria[], status (draft|submitted|edited), created_at, updated_at
  - Methods: addCriterion(criterion), submit(), getAverageRating()
  - Invariants: exactly 4 criteria before submit, all criteria must have comment

- [ ] T091 [P] [US4] Create ReviewCriteria value object in `backend/src/modules/reviews/domain/value-objects/review-criteria.vo.ts`
  - Properties: type (taste|service|value|infrastructure), rating (Rating VO), comment (Comment VO), justification (Justification VO nullable)

- [ ] T092 [P] [US4] Create Rating value object in `backend/src/modules/reviews/domain/value-objects/rating.vo.ts`
  - Properties: value (0-5 integer)
  - Invariants: integer between 0 and 5 inclusive
  - Methods: isNegative() → value < 3

- [ ] T093 [P] [US4] Create review exceptions in `backend/src/modules/reviews/domain/exceptions/`
  - InvalidRatingError, IncompleteReviewError, DuplicateCriterionError

- [ ] T094 [US4] Create review repository port in `backend/src/modules/reviews/domain/ports/review.repository.ts`
  - Methods: save(review), findById(id), findByUserAndPlace(userId, placeId), findByPlaceId(placeId), findByUserId(userId), update(review)

### Application Layer (US4)

- [ ] T095 [US4] Create create review use case in `backend/src/modules/reviews/application/use-cases/create-review.usecase.ts`
  - Creates draft review for user/place

- [ ] T096 [US4] Create add criterion use case in `backend/src/modules/reviews/application/use-cases/add-criterion.usecase.ts`
  - Validates rating (0-5), comment (min 10 chars), adds to review

- [ ] T097 [US4] Create submit review use case in `backend/src/modules/reviews/application/use-cases/submit-review.usecase.ts`
  - Validates 4 criteria present, submits review

- [ ] T098 [P] [US4] Create review DTOs in `backend/src/modules/reviews/application/dtos/`
  - CreateReviewDto, AddCriterionDto, ReviewResponseDto

- [ ] T099 [US4] Create reviews service in `backend/src/modules/reviews/application/reviews.service.ts` (orchestrator)

### Infrastructure Layer (US4)

- [ ] T100 [P] [US4] Create Review database entity in `backend/src/modules/reviews/infra/entities/review.db.entity.ts`

- [ ] T101 [P] [US4] Create ReviewCriteria database entity in `backend/src/modules/reviews/infra/entities/review-criteria.db.entity.ts`

- [ ] T102 [P] [US4] Create TypeORM migrations:
  - `backend/database/migrations/003-create-reviews.ts` (reviews table)
  - `backend/database/migrations/004-create-review-criteria.ts` (review_criteria table with FK to reviews)

- [ ] T103 [US4] Create review repository adapter in `backend/src/modules/reviews/infra/adapters/review.sqlite.adapter.ts`
  - Handles Review aggregate persistence with criteria

### Presentation Layer (US4)

- [ ] T104 [US4] Create reviews controller in `backend/src/modules/reviews/presentation/reviews.controller.ts`
  - Endpoints: POST /reviews, POST /reviews/:id/criteria, POST /reviews/:id/submit, GET /reviews/:id, GET /places/:placeId/reviews, GET /users/me/reviews

- [ ] T105 [P] [US4] Create reviews routes in `backend/src/modules/reviews/reviews.module.ts`

### Tests for US4 (Optional)

- [ ] T106 [P] [US4] Unit tests for Review entity in `backend/tests/unit/reviews/review.entity.spec.ts`
  - Test: add criterion, submit with 4 criteria, incomplete submit error

- [ ] T107 [P] [US4] Unit tests for Rating VO in `backend/tests/unit/reviews/rating.vo.spec.ts`
  - Test: valid range (0-5), invalid values, isNegative()

- [ ] T108 [US4] Integration tests for review endpoints in `backend/tests/integration/reviews.controller.spec.ts`

### Mobile Frontend for US4

- [ ] T109 [P] [US4] Create reviews data source in `mobile/lib/features/reviews/data/datasources/reviews_remote.dart`
  - Methods: createReview(placeId), addCriterion(reviewId, criterion), submitReview(reviewId)

- [ ] T110 [P] [US4] Create review models in `mobile/lib/features/reviews/data/models/review_model.dart`

- [ ] T111 [US4] Create reviews repository in `mobile/lib/features/reviews/data/repositories/reviews_repository.dart`

- [ ] T112 [US4] Create reviews provider in `mobile/lib/features/reviews/presentation/providers/review_provider.dart`
  - State: currentReview, criteria[], loading, error
  - Methods: startReview(placeId), addCriterion(type, rating, comment), submitReview()

- [ ] T113 [P] [US4] Create **star rating widget** in `mobile/lib/features/reviews/presentation/widgets/star_rating_widget.dart`
  - **CRITICAL**: Ludic UX with animations, 60 fps
  - Display 5 stars, tap to select rating (0-5)
  - Visual feedback on tap (grow, color change)
  - Read-only mode for displaying ratings

- [ ] T114 [P] [US4] Create review criteria selection widget in `mobile/lib/features/reviews/presentation/widgets/criteria_selector.dart`
  - Show: Taste, Service, Value, Infrastructure
  - Navigate through criteria

- [ ] T115 [US4] Create review page (UX < 1 minute) in `mobile/lib/features/reviews/presentation/pages/review_page.dart`
  - Step 1: Show place info
  - Step 2: Choose criterion (taste, service, value, infrastructure)
  - Step 3: Rate with star widget (T113)
  - Step 4: Comment field (required, min 10 chars) - via US5
  - Step 5: Justification if < 3 stars - via US6
  - Button: Next criterion / Submit when all 4 done

- [ ] T116 [P] [US4] Create my reviews page in `mobile/lib/features/reviews/presentation/pages/my_reviews_page.dart`
  - ListView of user's submitted reviews

**Checkpoint**: User Story 4 complete. Star rating system works independently. 🌟

---

## Phase 7: User Story 5 - Adicionar Comentários em Cada Critério (Priority: P1)

**Goal**: Allow users to add comments (min 10 chars) for each rating criterion, providing context for their ratings.

**Independent Test**: Rate with stars → add comment → verify comment displayed alongside rating

### Domain Layer (US5)

- [ ] T117 [P] [US5] Create Comment value object in `backend/src/modules/reviews/domain/value-objects/comment.vo.ts`
  - Properties: value (string), characterCount
  - Invariants: min 10 chars, max 500 chars
  - Methods: equals()

- [ ] T118 [P] [US5] Create comment exceptions in `backend/src/modules/reviews/domain/exceptions/invalid-comment.error.ts`

### Application Layer (US5)

- [ ] T119 [P] [US5] Extend AddCriterionDto to include comment field in `backend/src/modules/reviews/application/dtos/add-criterion.dto.ts`
  - Field: comment (string, required, min 10 chars)

### Infrastructure Layer (US5)

- [ ] T120 [P] [US5] Extend ReviewCriteria DB entity to persist comment field

### Mobile Frontend for US5

- [ ] T121 [P] [US5] Create comment input widget in `mobile/lib/features/reviews/presentation/widgets/comment_input_widget.dart`
  - TextField with min/max char counter
  - Real-time validation (min 10 chars)
  - Error message if < 10 chars

- [ ] T122 [US5] Integrate comment widget into review page (T115)
  - After star rating selection
  - Display comment input, validate before next step

- [ ] T123 [P] [US5] Create comment model in `mobile/lib/features/reviews/data/models/comment_model.dart`

### Tests for US5 (Optional)

- [ ] T124 [P] [US5] Unit tests for Comment VO in `backend/tests/unit/reviews/comment.vo.spec.ts`
  - Test: valid comment (10-500 chars), too short error, too long error

**Checkpoint**: User Story 5 complete. Comments work independently.

---

## Phase 8: User Story 6 - Justificar Avaliações Negativas (Priority: P1)

**Goal**: Require justification for ratings < 3 stars, ensuring constructive feedback even when negative.

**Independent Test**: Rate < 3 stars → system requires justification → cannot submit without it → verify justification saved

### Domain Layer (US6)

- [ ] T125 [P] [US6] Create Justification value object in `backend/src/modules/reviews/domain/value-objects/justification.vo.ts`
  - Properties: value (string), isRequired (boolean)
  - Invariants: if rating < 3, justification is mandatory (min 10 chars)
  - Logic: if rating >= 3, justification is optional

- [ ] T126 [P] [US6] Create justification exceptions in `backend/src/modules/reviews/domain/exceptions/`
  - MissingJustificationError

- [ ] T127 [US6] Update ReviewCriteria VO to include Justification in constructor
  - Logic: validate that if rating < 3, justification is provided and non-empty

### Application Layer (US6)

- [ ] T128 [P] [US6] Extend AddCriterionDto to include optional justification field
  - Field: justification (string, optional but required if rating < 3)

### Infrastructure Layer (US6)

- [ ] T129 [P] [US6] Extend ReviewCriteria DB entity to persist justification field (nullable)

### Presentation Layer (US6)

- [ ] T130 [P] [US6] Extend reviews controller validation to enforce justification rule (backend validation)
  - Pipe should check: if rating < 3 and no justification, return 400 error

### Mobile Frontend for US6

- [ ] T131 [P] [US6] Create justification input widget in `mobile/lib/features/reviews/presentation/widgets/justification_input_widget.dart`
  - TextField with conditional visibility (only if rating < 3)
  - Similar validation to comment (min 10 chars)
  - Label: "Why the low rating?" (PT: "Por que a avaliação baixa?")

- [ ] T132 [US6] Integrate justification widget into review page (T115)
  - Show after star rating IF rating < 3
  - Validate before proceeding to next criterion
  - For rating >= 3, justification is optional (hidden)

- [ ] T133 [P] [US6] Create conditional validator in review page
  - If rating < 3: require both comment + justification
  - If rating >= 3: require comment, justification optional
  - Disable submit button until all validations pass

### Tests for US6 (Optional)

- [ ] T134 [P] [US6] Unit tests for Justification VO in `backend/tests/unit/reviews/justification.vo.spec.ts`
  - Test: negative rating (< 3) without justification → error
  - Test: negative rating with justification → success
  - Test: positive rating (>= 3) without justification → success

- [ ] T135 [US6] Integration tests for justification enforcement in `backend/tests/integration/reviews.controller.spec.ts`
  - Test: POST /reviews/:id/criteria with rating < 3 and no justification → 400
  - Test: POST /reviews/:id/criteria with rating < 3 and justification → 200

**Checkpoint**: User Story 6 complete. Justification enforcement works independently. ✅

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements affecting multiple stories, documentation, and final validation

### Error Handling & User Feedback

- [ ] T136 [P] Create error message mapper in `mobile/lib/core/errors/error_messages.dart`
  - Map API error codes to user-friendly PT messages

- [ ] T137 [P] Create global error dialog widget in `mobile/lib/shared/widgets/error_dialog.dart`

- [ ] T138 Create loading state management in `mobile/lib/shared/widgets/loading_indicator.dart`

### Documentation & Testing

- [ ] T139 [P] Run through [quickstart.md](../quickstart.md) validation
  - Backend starts: `npm run start:dev`
  - Mobile starts: `flutter run`
  - Can register, login, add place, rate

- [ ] T140 [P] Create/Update API documentation in `docs/API_CONTRACTS.md` with examples

- [ ] T141 [P] Update architecture documentation in `docs/ARCHITECTURE.md` with implementation notes

- [ ] T142 Create setup instructions in `docs/SETUP.md` with environment variables

### Performance Optimization

- [ ] T143 [P] [Backend] Add database indexes for common queries in migrations
  - Index on users(email), reviews(user_id, place_id), places(category)

- [ ] T144 [P] [Mobile] Implement image caching for place/user images using `cached_network_image`

- [ ] T145 [Mobile] Add pagination to places list (lazy loading)

### Mobile UX Polish

- [ ] T146 [P] [Mobile] Add loading indicators to all async operations

- [ ] T147 [P] [Mobile] Implement form validation with real-time feedback

- [ ] T148 [Mobile] Add navigation breadcrumbs / back buttons to all pages

- [ ] T149 [P] [Mobile] Create app theme in `mobile/lib/shared/theme/app_theme.dart`
  - Colors (primary, secondary, error), typography, spacing

### Backend Polish

- [ ] T150 [P] Add logging to critical operations (auth, reviews submission)

- [ ] T151 [P] Add health check endpoint in `backend/src/health-check.controller.ts`

- [ ] T152 Create request/response logging middleware in `backend/src/common/middleware/`

### Security Hardening

- [ ] T153 [P] Add CORS configuration in `backend/src/app.module.ts` (restrict to app domain)

- [ ] T154 [P] Add rate limiting to auth endpoints in `backend/src/modules/auth/` (express-rate-limit)

- [ ] T155 [P] Validate all user inputs with class-validator decorators

- [ ] T156 [P] Add input sanitization for string fields (trim, escape)

### Testing Completion

- [ ] T157 [P] Run all backend unit tests: `npm run test`

- [ ] T158 [P] Run all backend integration tests: `npm run test:e2e`

- [ ] T159 [P] Run all mobile tests: `flutter test`

- [ ] T160 [Mobile] Test review submission end-to-end (< 1 min workflow)

### Database & Deployment Prep

- [ ] T161 [P] Generate all TypeORM migrations

- [ ] T162 [P] Seed database with test data in `backend/database/seeds/` (5 users, 10 places, 20 reviews)

- [ ] T163 [P] Test database reset: `docker-compose down && docker-compose up` should recreate schema

- [ ] T164 [P] Create production `.env.production` with secure JWT secret and DB config

### Final Validation

- [ ] T165 Verify all 6 user stories work independently:
  - [ ] US1 (Auth): Can register, login
  - [ ] US2 (Profile): Can view/update profile
  - [ ] US3 (Places): Can add/list/view places
  - [ ] US4 (Star Rating): Can rate with stars
  - [ ] US5 (Comments): Can add comments
  - [ ] US6 (Justification): Can justify < 3 stars

- [ ] T166 Verify success criteria from spec.md:
  - [ ] Review submission < 1 minute
  - [ ] API response < 200ms p95
  - [ ] All persistence working (99%+ success)

- [ ] T167 Commit all code to feature branch `002-mobile-rating-system`

- [ ] T168 Create PR with completed work for review

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies ✅ Start immediately
- **Foundational (Phase 2)**: Depends on Setup ✅ BLOCKS all user stories
- **User Stories (Phase 3-8)**: All depend on Foundational ✅ Can run in PARALLEL
- **Polish (Phase 9)**: Depends on all desired user stories ✅ Final cleanup

### Within User Stories (Example: US1)

1. **Domain** (T032-T034) → Define business rules
2. **Ports** (T034) → Define contracts
3. **Application** (T035-T039) → Implement use cases
4. **Infrastructure** (T040-T042) → Implement persistence
5. **Presentation** (T043-T044) → API endpoints
6. **Tests** (T045-T048) → Validate implementation
7. **Mobile** (T049-T055) → UI + integration

### Parallel Opportunities Within Setup Phase

```
T001 (backend structure)
T002 (mobile structure)      ← Can start in parallel with T001
T003-T006 (dependencies)     ← Can start in parallel
T007-T012 (config)           ← Can start in parallel
```

### Parallel Opportunities Once Foundational is Complete

```
Developer A: Phase 3 (US1 - Auth)
Developer B: Phase 4 (US2 - Profile)      ← Can run in parallel with Phase 3
Developer C: Phase 5 (US3 - Places)       ← Can run in parallel with Phase 3 & 4
Developer D: Phase 6 (US4 - Star Rating)  ← Can run in parallel with all above
```

Then Phase 7 (US5 - Comments) depends on Phase 6 (needs ReviewCriteria structure)
Then Phase 8 (US6 - Justification) depends on Phase 6-7

---

## MVP Scope (Phase 1-6)

Complete these phases for MVP launch:

1. ✅ Setup
2. ✅ Foundational
3. ✅ US1: Auth (login/register)
4. ✅ US2: Profile (view/update)
5. ✅ US3: Places (create/list)
6. ✅ US4: Star Rating (ludic UX < 1 min)
7. ✅ US5: Comments (required per criterion)
8. ✅ US6: Justification (required if < 3 stars)
9. ⚠️ Polish (as time allows)

**MVP Validation**: All 6 user stories working independently + Polish improvements = READY FOR BETA

---

## Notes

- [P] = Can parallelize (different files/modules, no cross-dependencies)
- [US#] = Belongs to User Story # (for traceability)
- Tests are **optional** but recommended, especially for domain logic
- Commit after logical group or each task
- Use feature branch `002-mobile-rating-system` for all work
- Refer to [data-model.md](../data-model.md) for entity details
- Refer to [contracts/api-endpoints.md](../contracts/api-endpoints.md) for API specs
- Refer to [quickstart.md](../quickstart.md) for local dev setup


