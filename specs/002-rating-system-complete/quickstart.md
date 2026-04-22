# Phase 1: Quick Start Guide

**Feature**: Sistema Completo de Avaliação de Locais  
**Date**: April 22, 2026  
**Target**: Developers starting implementation

---

## 1. Prerequisites

### Local Development

- **Node.js**: 18+ (backend)
- **Dart/Flutter**: 3.10+ (mobile)
- **Git**: Latest
- **Docker & Docker Compose**: For local database
- **VS Code or IDE**: With Flutter/Dart and TypeScript extensions

### Recommended VS Code Extensions

```json
{
  "extensions": [
    "dart-code.flutter",
    "dart-code.dart-code",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "github.copilot"
  ]
}
```

---

## 2. Project Structure Setup

```bash
# Clone repository
git clone https://github.com/yourorg/forkscore.git
cd forkscore

# You should have:
# - backend/           # NestJS API
# - mobile/            # Flutter app
# - docs/              # Documentation
# - specs/             # This feature spec
```

---

## 3. Backend Setup (NestJS)

### Install Dependencies

```bash
cd backend
npm install
```

### Start Database

```bash
# From project root
docker-compose up -d sqlite

# Or use existing SQLite file
touch backend/database/dev.db
```

### Environment Variables

Create `backend/.env`:

```env
# Database
DATABASE_URL=sqlite:./database/dev.db

# JWT
JWT_SECRET=your_super_secret_key_change_in_production
JWT_EXPIRATION=15m
REFRESH_TOKEN_EXPIRATION=7d

# CORS
CORS_ORIGIN=http://localhost:19006,http://localhost:5173

# Environment
NODE_ENV=development
PORT=3000
```

### Run Migrations

```bash
cd backend

# Create tables (TypeORM auto-migration in development)
npm run typeorm:migration:generate -- --name Initial

# Run migrations
npm run typeorm:migration:run

# Or seed with test data
npm run seed
```

### Start Backend

```bash
cd backend
npm run start:dev

# Expected output:
# [Nest] 1234   - 04/22/2026, 10:00:00 AM     LOG [NestFactory] Starting Nest application...
# [Nest] 1234   - 04/22/2026, 10:00:01 AM     LOG [InstanceLoader] AppModule dependencies initialized +5ms
# [Nest] 1234   - 04/22/2026, 10:00:01 AM     LOG [RoutesResolver] AuthController {/api/v1/auth}:
# [Nest] 1234   - 04/22/2026, 10:00:01 AM     LOG [RouterExplorer] GET /api/v1/auth/register (register)
# [Nest] 1234   - 04/22/2026, 10:00:02 AM     LOG [NestApplication] Nest application successfully started +2ms
```

Backend will be running at: **http://localhost:3000**

---

## 4. Mobile Setup (Flutter)

### Install Dependencies

```bash
cd mobile
flutter pub get

# Verify Flutter is set up
flutter doctor

# Expected: All checks marked ✓
```

### Configure API Client

Edit `mobile/lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String apiBase = 'http://localhost:3000/api/v1';  // Development
  // static const String apiBase = 'https://api.forkscore.com/api/v1';  // Production
}
```

### Start Mobile App

```bash
cd mobile

# iOS (requires macOS)
flutter run -d iPhone

# Android (requires emulator or connected device)
flutter run -d android

# Web (for testing, not MVP)
flutter run -d web
```

App will be running at: **http://localhost:19006** (web) or on device

---

## 5. Key File Locations

### Backend

```
backend/
├── src/
│   ├── modules/
│   │   ├── auth/                    # Start here for auth logic
│   │   ├── reviews/                 # Core domain: reviews
│   │   │   ├── domain/
│   │   │   │   ├── entities/review.entity.ts
│   │   │   │   └── value-objects/rating.vo.ts
│   │   │   ├── application/
│   │   │   │   └── reviews.service.ts
│   │   │   └── infra/
│   │   │       └── adapters/review.sqlite.adapter.ts
│   │   ├── places/
│   │   └── users/
│   └── main.ts
├── database/
│   └── migrations/                  # TypeORM migrations
├── jest.config.js
├── package.json
└── tsconfig.json
```

### Mobile

```
mobile/
├── lib/
│   ├── features/
│   │   ├── reviews/
│   │   │   └── presentation/
│   │   │       └── pages/review_page.dart  # Star rating UX here
│   │   ├── auth/
│   │   └── places/
│   ├── config/
│   │   └── api_config.dart          # Change API base here
│   └── main.dart
├── pubspec.yaml
└── test/
```

---

## 6. Testing

### Backend Tests

```bash
cd backend

# Unit tests
npm run test

# Watch mode (recommended for development)
npm run test:watch

# Coverage
npm run test:cov

# Integration tests
npm run test:e2e
```

### Mobile Tests

```bash
cd mobile

# Widget tests
flutter test

# Generate coverage
flutter test --coverage

# View coverage
genhtml coverage/lcov.info -o coverage/
open coverage/index.html
```

---

## 7. Common Development Workflow

### Adding a New Endpoint

Example: Create `POST /places` endpoint

1. **Define Domain Entity** (`backend/src/modules/places/domain/entities/place.entity.ts`)
   ```typescript
   class Place {
     constructor(
       public id: string,
       public name: string,
       public category: string,
       public address: string,
     ) {}
   }
   ```

2. **Create Port (Interface)** (`backend/src/modules/places/domain/ports/place.repository.ts`)
   ```typescript
   interface PlaceRepository {
     save(place: Place): Promise<void>;
   }
   ```

3. **Implement Adapter** (`backend/src/modules/places/infra/adapters/place.sqlite.adapter.ts`)
   ```typescript
   @Injectable()
   class PlaceSQLiteAdapter implements PlaceRepository {
     async save(place: Place): Promise<void> {
       // Insert into SQLite
     }
   }
   ```

4. **Create Use Case** (`backend/src/modules/places/application/use-cases/create-place.usecase.ts`)
   ```typescript
   @Injectable()
   class CreatePlaceUseCase {
     constructor(private placeRepository: PlaceRepository) {}
     
     async execute(dto: CreatePlaceDTO): Promise<Place> {
       const place = new Place(...);
       await this.placeRepository.save(place);
       return place;
     }
   }
   ```

5. **Create Controller** (`backend/src/modules/places/presentation/places.controller.ts`)
   ```typescript
   @Post()
   async create(@Body() dto: CreatePlaceDTO) {
     const place = await this.createPlaceUseCase.execute(dto);
     return { status: 'success', data: place };
   }
   ```

6. **Test Domain** (`backend/tests/unit/places/place.entity.spec.ts`)
   ```typescript
   describe('Place Entity', () => {
     it('should create place with valid data', () => {
       const place = new Place('id', 'Pizzaria', 'restaurant', 'Rua X');
       expect(place.name).toBe('Pizzaria');
     });
   });
   ```

### Adding a New Mobile Screen

Example: Add `ReviewPage` for rating

1. **Create Data Source** (`mobile/lib/features/reviews/data/datasources/review_remote.dart`)
   ```dart
   class ReviewRemoteDataSource {
     final ApiClient client;
     
     Future<Review> submitReview(ReviewDTO dto) async {
       final response = await client.post('/reviews', body: dto);
       return Review.fromJson(response);
     }
   }
   ```

2. **Create Repository** (`mobile/lib/features/reviews/data/repositories/review_repository.dart`)
   ```dart
   class ReviewRepository {
     final ReviewRemoteDataSource remoteDataSource;
     
     Future<Review> submitReview(ReviewDTO dto) => remoteDataSource.submitReview(dto);
   }
   ```

3. **Create Provider** (`mobile/lib/features/reviews/presentation/providers/review_provider.dart`)
   ```dart
   final reviewProvider = StateNotifierProvider((ref) {
     return ReviewProvider(repository);
   });
   ```

4. **Create Widget** (`mobile/lib/features/reviews/presentation/widgets/star_rating_widget.dart`)
   ```dart
   class StarRatingWidget extends StatefulWidget {
     final Function(int) onChanged;
     
     @override
     Widget build(BuildContext context) {
       return Row(
         children: List.generate(5, (index) => 
           GestureDetector(
             onTap: () => onChanged(index + 1),
             child: Icon(Icons.star),
           )
         ),
       );
     }
   }
   ```

5. **Create Page** (`mobile/lib/features/reviews/presentation/pages/review_page.dart`)
   ```dart
   class ReviewPage extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       return Scaffold(
         appBar: AppBar(title: Text('Avaliar Local')),
         body: StarRatingWidget(
           onChanged: (rating) {
             // Handle rating
           },
         ),
       );
     }
   }
   ```

---

## 8. Debugging

### Backend Debugging

#### NestJS Debugging in VS Code

1. Add to `backend/.vscode/launch.json`:
   ```json
   {
     "version": "0.2.0",
     "configurations": [
       {
         "type": "node",
         "request": "launch",
         "name": "NestJS Debug",
         "program": "${workspaceFolder}/backend/node_modules/.bin/nest",
         "args": ["start", "--debug"],
         "console": "integratedTerminal",
         "internalConsoleOptions": "neverOpen"
       }
     ]
   }
   ```

2. Press F5 to start debugging

#### Check API Responses

```bash
# Test endpoint with curl
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123!",
    "name": "Test User"
  }'

# Or use Postman/Insomnia for GUI
```

### Mobile Debugging

```bash
# Enable verbose logging
flutter run -v

# Use Dart DevTools
flutter pub global activate devtools
devtools

# Check widget tree
flutter run --observe  # Shows Observatory URL
```

---

## 9. Common Issues & Solutions

### Issue: "SQLite database locked"

**Solution**: Stop running processes
```bash
lsof -i :3000 | grep LISTEN | awk '{print $2}' | xargs kill -9
```

### Issue: "Port 3000 already in use"

**Solution**: Use different port
```bash
PORT=3001 npm run start:dev
```

### Issue: "Flutter doctor: Android SDK not found"

**Solution**: Install Android SDK
```bash
flutter doctor --android-licenses
# Accept all licenses
```

### Issue: "JWT token expired"

**Solution**: Use refresh token endpoint
```bash
POST /api/v1/auth/refresh
{
  "refreshToken": "your_refresh_token"
}
```

---

## 10. Recommended Development Order

**Phase 1 - Core (Week 1-2)**:
1. [ ] Domain entities + value objects (zero framework dependencies)
2. [ ] Repository ports + SQLite adapters
3. [ ] Auth service (registration, login, JWT)
4. [ ] User entity + endpoints
5. [ ] Unit tests for domain

**Phase 2 - Reviews (Week 2-3)**:
1. [ ] Place entity + CRUD endpoints
2. [ ] Review aggregate + all validation logic
3. [ ] ReviewCriteria value objects + validation
4. [ ] Review submission logic with justification rules
5. [ ] Endpoint tests

**Phase 3 - Mobile (Week 3-4)**:
1. [ ] API client + auth flow
2. [ ] Login/Register screens
3. [ ] Place list screen
4. [ ] **Star rating widget** (ludic UX, < 1 min complete)
5. [ ] Review submission screen
6. [ ] Integration tests

**Phase 4 - Polish (Week 4)**:
1. [ ] Error handling + messaging
2. [ ] Loading states
3. [ ] Offline support (cache)
4. [ ] Performance optimization
5. [ ] E2E testing

---

## 11. Performance Targets (MVP)

| Metric | Target | How to Measure |
|--------|--------|---|
| **Review Submission Time** | < 1 minute UI/UX | User workflow test |
| **API Response Time** | < 200ms p95 | Artillery load test |
| **Mobile App Launch** | < 3 seconds | Device benchmark |
| **Star Rating Animation** | 60 fps | Flutter DevTools Performance |
| **Database Query** | < 50ms | NestJS profiler |

Test with:
```bash
# Backend load test
npm install -g artillery
artillery quick --count 100 --num 1000 http://localhost:3000/api/v1/places

# Mobile performance
flutter run --profile
# View in DevTools
```

---

## 12. Documentation References

- **NestJS**: https://docs.nestjs.com/
- **Flutter**: https://flutter.dev/docs
- **TypeORM**: https://typeorm.io/
- **JWT**: https://jwt.io/
- **REST Best Practices**: https://restfulapi.net/

---

## 13. Getting Help

**Repository Issues**: Use feature branch `002-mobile-rating-system`

**Code Reviews**: Check Architecture compliance:
- ✅ Domain is technology-agnostic (no imports from frameworks)
- ✅ Ports are defined before adapters
- ✅ Controllers are thin (validation + routing only)
- ✅ Business logic lives in Domain or Use Cases
- ✅ Tests cover domain rules 100%

**Questions about Architecture**: Refer to [data-model.md](data-model.md) and [research.md](research.md)

---

**Ready to start? Create first issue on GitHub and link to this quickstart!** 🚀
