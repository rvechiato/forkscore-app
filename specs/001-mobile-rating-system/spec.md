# Feature Specification: Mobile Gastronomic Review Application — Core Features

**Feature Branch**: `001-mobile-rating-system`  
**Created**: 2026-04-22  
**Status**: Draft  
**Input**: User description: "Aplicativo mobile de avaliação gastronômica com cadastro, perfil, avaliação de locais e sistema de ratings com comentários obrigatórios"

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - User Registration & Authentication (Priority: P1) 🔑

A new user wants to join ForkScore to start rating restaurants and sharing recommendations.

**Why this priority**: Authentication is the foundational feature. Without it, no user data can be safely managed or attributed. This is the gateway to the entire system.

**Independent Test**: Can be fully tested by: signing up with email/password, verifying account activation (if applicable), logging in successfully, and accessing the authenticated user dashboard. This alone delivers value: a registered user with persistent credentials.

**Acceptance Scenarios**:

1. **Given** a new user visits the app, **When** they tap "Sign Up", **Then** they see a registration form requesting email, password, and password confirmation
2. **Given** a user enters a valid email and strong password (8+ chars, with mixed case), **When** they tap "Register", **Then** their account is created and they are automatically logged in
3. **Given** a user enters a weak password (< 8 chars), **When** they tap "Register", **Then** an error message appears: "Password must be at least 8 characters"
4. **Given** a user enters an email already registered, **When** they tap "Register", **Then** an error appears: "Email already in use. Try login or password reset"
5. **Given** a registered user taps "Login", **When** they enter correct email and password, **Then** they are authenticated and see the home screen
6. **Given** a registered user enters incorrect password, **When** they tap "Login", **Then** an error appears: "Invalid credentials"
7. **Given** a logged-in user, **When** they tap "Logout", **Then** they are logged out and returned to login screen
8. **Given** a user forgets their password, **When** they tap "Forgot Password" and enter their email, **Then** a password reset link/code is sent (or OTP-based flow initiated)

---

### User Story 2 - User Profile Setup (Priority: P1) 👤

After registering, a user wants to create a profile with their name and optional photo to personalize their presence on the platform.

**Why this priority**: Profile is essential context for all reviews. Reviewers' identities (even partial) increase trust and accountability in the system. Without profiles, there's no way to attribute ratings or build reputation.

**Independent Test**: Can be fully tested by: filling in profile form, uploading/selecting a photo (or skipping), saving, and viewing the saved profile. Delivers value: a personalized user identity tied to their reviews.

**Acceptance Scenarios**:

1. **Given** a newly registered user, **When** they access the app, **Then** they are prompted to "Complete Your Profile" or see a profile wizard
2. **Given** the profile form is displayed, **When** the user enters their name (required) and bio (optional), **Then** the fields are validated (name: 2-50 chars, bio: max 250 chars)
3. **Given** the user taps "Add Photo", **When** they select/take a photo, **Then** it is uploaded and previewed in the profile
4. **Given** a user skips the photo step, **When** they tap "Continue", **Then** they proceed with a default avatar
5. **Given** profile data is entered, **When** the user taps "Save Profile", **Then** the profile is saved and they see a success message
6. **Given** a user who already has a profile, **When** they access "Edit Profile", **Then** they can update name, bio, and photo
7. **Given** a user views their own profile, **When** they look at it, **Then** they see their name, photo, bio, and a summary of their reviews (count, average rating given)

---

### User Story 3 - Place Registration (Priority: P2) 📍

A user discovers a new restaurant/cafe and wants to add it to ForkScore so they can rate it.

**Why this priority**: Places are the core objects being evaluated. While other users might have already added a place, new users will encounter unmapped locations (especially local gems). This enables organic growth of the place database.

**Independent Test**: Can be fully tested by: searching for a place, not finding it, adding a new place with required info (name, type, address), and verifying it appears in the app. Delivers value: the app's place database grows through community contributions.

**Acceptance Scenarios**:

1. **Given** a user is on the home/discovery screen, **When** they tap "Add New Place" or "+ Place", **Then** they see a form to enter place details
2. **Given** the place registration form is displayed, **When** the user enters: name (required), type (required: restaurant/cafe/bakery/etc), address (required), and optional details like phone/website, **Then** fields are validated for format and length
3. **Given** the user taps "Use GPS Location" or "Current Location", **When** the app requests location permissions, **Then** GPS coordinates (lat/lng) are populated
4. **Given** a user can't/won't use GPS, **When** they tap "Enter Address Manually", **Then** they can type/search for an address and select from a suggested list (e.g., via geocoding API)
5. **Given** all required fields are filled, **When** the user taps "Create Place", **Then** the place is added to the database and they see a confirmation: "Place added! You can now rate it"
6. **Given** a place already exists in the database, **When** a user searches and finds it, **Then** they see a message: "This place already exists" with an option to "View & Rate" instead of re-creating
7. **Given** a user is rating/evaluating a place, **When** they start the review, **Then** they can see the place's full details (name, type, location, photo if available, other users' reviews count)

---

### User Story 4 - Simple Evaluation System (Priority: P1) ⭐

A user visits a restaurant and wants to quickly rate it across 4 key dimensions, using a fun star-based interface, with mandatory comments and justifications.

**Why this priority**: This is the core value proposition of ForkScore. Everything else (auth, profiles, places) exists to support this. Without high-quality, detailed reviews, the app has no value.

**Independent Test**: Can be fully tested by: selecting a place, rating all 4 criteria (sabor, atendimento, custo, infra) with 0-5 stars, adding comments per criterion, justifying ratings < 3, and submitting. Delivers value: a detailed, trusted review that helps other users make decisions.

**Acceptance Scenarios**:

#### 4.1 — Criterion 1: Sabor (Taste/Flavor)

1. **Given** a user starts rating a place, **When** they reach the "Sabor" (Taste) criterion, **Then** they see: a question "Como foi o sabor?" with a 0-5 star selector and a comment field below
2. **Given** the user taps on a star (0-5), **When** they select a rating, **Then** the stars are highlighted (visual feedback) and the selection is stored
3. **Given** the user has selected a Sabor rating, **When** they tap/focus the comment field, **Then** a text input appears with placeholder "Conte-nos mais sobre o sabor... (mín. 10 caracteres)"
4. **Given** the user types a comment < 10 characters, **When** they try to proceed, **Then** an error shows: "Comentário muito curto. Mínimo 10 caracteres"
5. **Given** the user types a valid comment (≥ 10 chars), **When** they tap "Next" or proceed, **Then** the comment is saved and they move to Criterion 2 (Atendimento)
6. **Given** the user selected Sabor rating < 3 (poor), **When** they attempt to proceed without a justification note, **Then** they see: "Ratings below 3 stars require justification. Please explain your rating" with an expanded comment field
7. **Given** the user provides a detailed justification for a < 3 rating, **When** they confirm, **Then** the system marks this review criterion as "justified" and allows progression

#### 4.2 — Criterion 2: Atendimento (Service)

8. **Given** the user has completed Sabor, **When** they reach Atendimento, **Then** the same UX repeats: question, 0-5 stars, comment field (min 10 chars), optional justification if < 3
9. **Given** the user has rated Atendimento, **When** they proceed, **Then** they move to Criterion 3 (Custo-benefício / Opções)

#### 4.3 — Criterion 3: Custo-benefício / Opções (Value & Variety)

10. **Given** the user reaches Criterion 3 (Custo), **When** they see the question "Qual o custo-benefício e variedade de opções?", **Then** the same star + comment flow applies
11. **Given** all criteria questions use the same validation (0-5 stars, min 10 char comment, justification if < 3), **Then** the UX is consistent and learnable

#### 4.4 — Criterion 4: Infraestrutura (Infrastructure)

12. **Given** the user has rated all previous criteria, **When** they reach Infraestrutura (last criterion), **Then** they rate this final dimension with the same UX
13. **Given** the user has completed all 4 criteria with valid ratings and comments, **When** they tap "Submit Review", **Then** the review is saved with a timestamp and they see a success screen: "Avaliação enviada com sucesso! Obrigado por ajudar outros usuários."

#### 4.5 — Review Aggregation & Overall Rating

14. **Given** a place has received one or more reviews, **When** the app calculates the place's overall rating, **Then** the overall rating = (Sabor avg + Atendimento avg + Custo avg + Infra avg) / 4
15. **Given** a place with multiple reviews, **When** a user views it, **Then** they see: overall star rating, average rating per criterion, and a list of individual reviews sorted by recency (newest first)

---

### Edge Cases

- What happens when a user loses internet connection mid-review? **System MUST save draft locally and sync when connection is restored**
- How does the system handle GPS failures or inaccurate location data? **Fall back to manual address entry; allow user to correct location after review**
- What if a user tries to submit a review without completing all 4 criteria? **System MUST block submission and highlight incomplete criteria**
- What happens if a user tries to rate the same place twice? **System MUST allow multiple reviews per place per user (user can review same place multiple times over time)**
- How does system handle extremely long comments (e.g., pasted text > 500 chars)? **Accept and store, but warn user via tooltip or truncate in UI display to 200 chars with "...read more"**
- What if user's location is far from the place they're rating? **Allow it (review from home is valid), but optionally show a warning: "Are you sure? You're X km away from this location"**
- What if a registered user tries to sign up again with the same email? **Show message: "Email already registered. Try login or password reset"**

---

## Requirements *(mandatory)*

### Functional Requirements

#### Authentication & Security
- **FR-001**: System MUST allow users to create accounts with email and password
- **FR-002**: System MUST validate passwords (minimum 8 characters, at least one uppercase, one lowercase, one number)
- **FR-003**: System MUST hash and securely store passwords (bcrypt)
- **FR-004**: System MUST authenticate users via JWT tokens with token refresh mechanism
- **FR-005**: System MUST support logout functionality that invalidates tokens on both client and server
- **FR-006**: System MUST provide password reset via email (with token-based reset link or OTP)

#### User Profile Management
- **FR-007**: System MUST allow authenticated users to create a profile with name (required), bio (optional), and photo (optional)
- **FR-008**: System MUST validate profile name (2-50 characters, not empty)
- **FR-009**: System MUST allow users to edit their profile (name, bio, photo)
- **FR-010**: System MUST support profile photo upload from device gallery or camera
- **FR-011**: System MUST display user profile with name, photo, bio, review count, and average rating given

#### Place Management
- **FR-012**: System MUST allow users to search for existing places by name or address
- **FR-013**: System MUST allow users to register new places with: name (required), type (required: restaurant/cafe/bakery/etc), address (required), optional phone/website, GPS coordinates
- **FR-014**: System MUST validate place name (3-100 chars), address (valid format), type (predefined list)
- **FR-015**: System MUST support GPS location capture for place registration (with fallback to manual address entry)
- **FR-016**: System MUST prevent duplicate place registrations (check by name + address proximity)
- **FR-017**: System MUST display place details: name, type, address, location map, reviews count, average rating per criterion, list of individual reviews

#### Evaluation System (4 Criteria - MANDATORY per Constitution)
- **FR-018**: System MUST support evaluation of exactly 4 criteria: Sabor (Taste), Atendimento (Service), Custo-benefício/Opções (Value/Variety), Infraestrutura (Infrastructure)
- **FR-019**: System MUST allow rating each criterion from 0 to 5 stars (integer or half-star increments)
- **FR-020**: System MUST require a comment for EACH criterion (minimum 10 characters)
- **FR-021**: System MUST require additional justification (text) if any criterion is rated < 3 stars
- **FR-022**: System MUST calculate overall place rating as: (Criterion1 avg + Criterion2 avg + Criterion3 avg + Criterion4 avg) / 4
- **FR-023**: System MUST persist reviews with timestamp, user ID, place ID, all criterion ratings, comments, and justifications
- **FR-024**: System MUST allow users to edit/delete their own reviews within 24 hours of creation
- **FR-025**: System MUST prevent duplicate reviews: one review per user per place per day (allow re-review after 24 hours or on different day)

#### Data Persistence
- **FR-026**: System MUST persist all user data (credentials, profile, reviews, places) to a database (SQLite for MVP)
- **FR-027**: System MUST enforce data consistency: no orphaned reviews (review must reference valid user and place)
- **FR-028**: System MUST support data export or backup mechanisms (for future compliance)

#### Offline Support (MVP: Optional, Phase 2: Consider)
- **FR-029**: System SHOULD support offline review drafts: if user is offline, allow draft save and sync when connection restored [OPTIONAL for MVP]

#### API Contract
- **FR-030**: System MUST expose RESTful API endpoints for all operations: auth, profiles, places, reviews (detailed in contracts/ folder)

### Key Entities *(include if feature involves data)*

- **User**: Represents an authenticated user. Attributes: id (UUID), email (string, unique), password_hash (bcrypt), name (string, 2-50 chars), bio (string, optional, max 250 chars), profile_photo_url (URL, optional), created_at (timestamp), updated_at (timestamp). Relationships: has many Reviews, has many Places (created by).

- **Place**: Represents a restaurant, cafe, bakery, or similar establishment. Attributes: id (UUID), name (string, 3-100 chars), type (enum: restaurant/cafe/bakery/foodtruck/bar/etc.), address (string), lat (float, optional for later mapping), lng (float, optional), phone (string, optional), website (URL, optional), created_by_user_id (FK to User), created_at (timestamp), updated_at (timestamp). Relationships: has many Reviews.

- **Review**: Represents a user's complete evaluation of a place across 4 criteria. Attributes: id (UUID), user_id (FK to User), place_id (FK to Place), created_at (timestamp), updated_at (timestamp), is_justification_provided (boolean, true if any criterion < 3). Relationships: has many ReviewCriteria.

- **ReviewCriteria**: Represents the rating and comment for ONE criterion within a review. Attributes: id (UUID), review_id (FK to Review), criterion (enum: sabor/atendimento/custo/infra), rating (integer, 0-5), comment (string, min 10 chars, max 500 chars), is_justified (boolean, true if rating < 3 and justification was provided), created_at (timestamp). Relationships: belongs to Review.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete registration, profile setup, and first review within 3 minutes from app launch (UX simplicity target)
- **SC-002**: 95% of reviews submitted by new users contain all 4 criteria with comments (data quality indicator)
- **SC-003**: System successfully persists and retrieves all user data, reviews, and places without data loss (reliability)
- **SC-004**: Average review submission time is under 2 minutes per place (UX efficiency, measured via analytics)
- **SC-005**: 90% of users with rating < 3 provide justification as required (system enforces rule effectively)
- **SC-006**: Place database grows organically: at least 10 places registered by MVP launch (community adoption)
- **SC-007**: Zero critical security vulnerabilities in auth system (passwords hashed, JWTs validated, no SQL injection)
- **SC-008**: App loads and responds to user actions in under 2 seconds (performance baseline)
- **SC-009**: 85% of users complete at least one full review in their first session (engagement metric)
- **SC-010**: Overall star ratings for places are calculated and displayed consistently across the app (data integrity)

---

## Assumptions

- **Target Users**: Users aged 18+ with smartphones (iOS/Android) and stable internet connectivity for MVP. Feature: offline draft support deferred to Phase 2.
- **Scope Boundaries**: MVP focuses on core features (auth, profile, places, reviews). Advanced features OUT of scope for v1: user recommendations, social features (follow, comments on reviews), image uploads for reviews, maps integration, admin moderation, spam detection.
- **Data & Environment**: Existing third-party auth (OAuth) is OUT of scope for MVP; email/password only. Email verification is optional for MVP (can be manual or skip). Password reset can be simplified (OTP or link-based, not fully specified yet).
- **Place Database**: Initial place seeding is NOT included in MVP. Users must manually add places. Bulk import, geocoding services (Google Maps API), or initial seed data are Phase 2+ features.
- **Review Retention**: No data retention policies specified in requirements; assume indefinite retention for MVP. Compliance (GDPR data deletion) is deferred to Phase 2.
- **Localization**: MVP assumes English/Portuguese interface. Multi-language support deferred to Phase 2.
- **Analytics**: Basic logging of user actions (sign-up, review submit) is optional for MVP. Detailed analytics deferred to Phase 2.
- **Backup & Recovery**: No backup strategy specified for MVP; SQLite file is the backup. Production backup strategy deferred to Phase 2.
- **Architecture Compliance**: All development must follow ForkScore Constitution v1.0.0: Hexagonal architecture, Domain-driven design, 4-criteria evaluation system, modular code organization by domain.
