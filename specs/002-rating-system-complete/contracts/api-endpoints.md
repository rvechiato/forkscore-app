# API Contracts: REST Endpoints

**Feature**: Sistema Completo de Avaliação de Locais  
**Date**: April 22, 2026  
**API Version**: v1  
**Base URL**: `http://localhost:3000/api/v1` (dev), `https://api.forkscore.com/api/v1` (prod)

---

## Authentication

### Register (Create Account)

**Endpoint**: `POST /auth/register`  
**Auth**: None (Public)  
**Rate Limit**: 5 requests per minute per IP

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "name": "João Silva"
}
```

**Response (201 Created)**:
```json
{
  "status": "success",
  "data": {
    "user": {
      "id": "user_uuid_here",
      "email": "user@example.com",
      "name": "João Silva"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh_token_here"
  }
}
```

**Errors**:
- `400 Bad Request`: Email invalid, password too weak
- `409 Conflict`: Email already exists

---

### Login

**Endpoint**: `POST /auth/login`  
**Auth**: None (Public)

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "user": {
      "id": "user_uuid_here",
      "email": "user@example.com",
      "name": "João Silva"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh_token_here"
  }
}
```

**Errors**:
- `401 Unauthorized`: Invalid email/password
- `400 Bad Request`: Missing fields

---

### Refresh Token

**Endpoint**: `POST /auth/refresh`  
**Auth**: None (uses refreshToken)

**Request Body**:
```json
{
  "refreshToken": "refresh_token_here"
}
```

**Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "accessToken": "new_access_token_here",
    "refreshToken": "new_refresh_token_here"
  }
}
```

**Errors**:
- `401 Unauthorized`: Invalid or expired refresh token

---

## Users

### Get Profile (Current User)

**Endpoint**: `GET /users/me`  
**Auth**: Bearer token (JWT)

**Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "id": "user_uuid_here",
    "email": "user@example.com",
    "name": "João Silva",
    "profilePicture": "https://cdn.example.com/user_uuid.jpg",
    "bio": "Apaixonado por gastronomia!",
    "createdAt": "2026-04-22T10:00:00Z",
    "updatedAt": "2026-04-22T10:00:00Z"
  }
}
```

**Errors**:
- `401 Unauthorized`: Missing or invalid token

---

### Update Profile

**Endpoint**: `PUT /users/me`  
**Auth**: Bearer token (JWT)

**Request Body**:
```json
{
  "name": "João da Silva",
  "bio": "Crítico de restaurantes profissional",
  "profilePicture": "data:image/jpeg;base64,..." // opcional
}
```

**Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "id": "user_uuid_here",
    "email": "user@example.com",
    "name": "João da Silva",
    "profilePicture": "https://cdn.example.com/user_uuid.jpg",
    "bio": "Crítico de restaurantes profissional",
    "updatedAt": "2026-04-22T11:00:00Z"
  }
}
```

**Errors**:
- `400 Bad Request`: Invalid name (< 2 chars)
- `401 Unauthorized`: Missing token

---

## Places (Locais)

### Create Place

**Endpoint**: `POST /places`  
**Auth**: Bearer token (JWT)

**Request Body**:
```json
{
  "name": "Pizzaria da Maria",
  "category": "restaurant",
  "address": "Rua das Flores, 123, São Paulo - SP",
  "description": "Ótima pizzaria com variedade de sabores",
  "latitude": -23.5505,
  "longitude": -46.6333
}
```

**Response (201 Created)**:
```json
{
  "status": "success",
  "data": {
    "id": "place_uuid_here",
    "name": "Pizzaria da Maria",
    "category": "restaurant",
    "address": "Rua das Flores, 123, São Paulo - SP",
    "description": "Ótima pizzaria com variedade de sabores",
    "latitude": -23.5505,
    "longitude": -46.6333,
    "creatorId": "user_uuid_here",
    "createdAt": "2026-04-22T10:00:00Z"
  }
}
```

**Errors**:
- `400 Bad Request`: Name < 3 chars, address < 5 chars
- `401 Unauthorized`: Missing token

---

### Get All Places

**Endpoint**: `GET /places`  
**Auth**: Bearer token (JWT) optional
**Query Params**:
- `limit`: Number (default 20, max 100)
- `offset`: Number (default 0)
- `category`: String optional (restaurant|bar|cafe|other)

**Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "places": [
      {
        "id": "place_uuid_1",
        "name": "Pizzaria da Maria",
        "category": "restaurant",
        "address": "Rua das Flores, 123, São Paulo - SP",
        "description": "Ótima pizzaria",
        "averageRating": 4.2,
        "totalReviews": 15,
        "createdAt": "2026-04-22T10:00:00Z"
      },
      {
        "id": "place_uuid_2",
        "name": "Café do João",
        "category": "cafe",
        "address": "Av. Paulista, 1000, São Paulo - SP",
        "description": "Café aconchegante",
        "averageRating": 4.7,
        "totalReviews": 8,
        "createdAt": "2026-04-20T10:00:00Z"
      }
    ],
    "pagination": {
      "total": 42,
      "limit": 20,
      "offset": 0
    }
  }
}
```

---

### Get Place Details

**Endpoint**: `GET /places/{placeId}`  
**Auth**: Bearer token (JWT) optional

**Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "id": "place_uuid_here",
    "name": "Pizzaria da Maria",
    "category": "restaurant",
    "address": "Rua das Flores, 123, São Paulo - SP",
    "description": "Ótima pizzaria com variedade de sabores",
    "latitude": -23.5505,
    "longitude": -46.6333,
    "creatorId": "user_uuid_here",
    "creator": {
      "id": "user_uuid_here",
      "name": "Admin User",
      "profilePicture": "https://cdn.example.com/user_uuid.jpg"
    },
    "averageRating": 4.3,
    "ratings": {
      "taste": 4.5,
      "service": 4.0,
      "value": 4.2,
      "infrastructure": 4.1
    },
    "totalReviews": 20,
    "createdAt": "2026-04-22T10:00:00Z"
  }
}
```

**Errors**:
- `404 Not Found`: Place not found

---

### Update Place (Creator Only)

**Endpoint**: `PUT /places/{placeId}`  
**Auth**: Bearer token (JWT)

**Request Body**:
```json
{
  "name": "Pizzaria da Maria - Matriz",
  "address": "Rua das Flores, 123, São Paulo - SP",
  "description": "Ótima pizzaria com variedade de sabores e novo delivery"
}
```

**Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "id": "place_uuid_here",
    "name": "Pizzaria da Maria - Matriz",
    "updatedAt": "2026-04-22T11:00:00Z"
  }
}
```

**Errors**:
- `403 Forbidden`: User is not creator
- `404 Not Found`: Place not found

---

## Reviews (Avaliações)

### Create/Start Review

**Endpoint**: `POST /reviews`  
**Auth**: Bearer token (JWT)  
**Note**: Cria uma review em estado "draft". Cliente pode adicionar critérios incrementalmente.

**Request Body**:
```json
{
  "placeId": "place_uuid_here"
}
```

**Response (201 Created)**:
```json
{
  "status": "success",
  "data": {
    "id": "review_uuid_here",
    "placeId": "place_uuid_here",
    "userId": "user_uuid_here",
    "status": "draft",
    "criteria": [],
    "createdAt": "2026-04-22T10:00:00Z"
  }
}
```

**Errors**:
- `409 Conflict`: User already has a draft review for this place
- `404 Not Found`: Place not found
- `401 Unauthorized`: Missing token

---

### Add Criterion to Review

**Endpoint**: `POST /reviews/{reviewId}/criteria`  
**Auth**: Bearer token (JWT)

**Request Body**:
```json
{
  "type": "taste",
  "rating": 4,
  "comment": "Pizza deliciosa, massa crocante e recheio generoso!",
  "justification": null
}
```

**Or (with justification if rating < 3)**:
```json
{
  "type": "service",
  "rating": 2,
  "comment": "Garçom demorou para atender à nossa mesa.",
  "justification": "Chegamos em horário de pico e havia poucos garçons para atender os clientes."
}
```

**Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "id": "review_uuid_here",
    "placeId": "place_uuid_here",
    "userId": "user_uuid_here",
    "status": "draft",
    "criteria": [
      {
        "type": "taste",
        "rating": 4,
        "comment": "Pizza deliciosa, massa crocante e recheio generoso!",
        "justification": null
      },
      {
        "type": "service",
        "rating": 2,
        "comment": "Garçom demorou para atender à nossa mesa.",
        "justification": "Chegamos em horário de pico e havia poucos garçons para atender os clientes."
      }
    ]
  }
}
```

**Errors**:
- `400 Bad Request`: Invalid rating (not 0-5), comment < 10 chars, missing justification if rating < 3
- `404 Not Found`: Review not found
- `409 Conflict`: Criterion type already exists

---

### Submit Review (Mark as Complete)

**Endpoint**: `POST /reviews/{reviewId}/submit`  
**Auth**: Bearer token (JWT)

**Request Body**: Empty (or `{}`)

**Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "id": "review_uuid_here",
    "placeId": "place_uuid_here",
    "userId": "user_uuid_here",
    "status": "submitted",
    "criteria": [
      {
        "type": "taste",
        "rating": 4,
        "comment": "Pizza deliciosa, massa crocante e recheio generoso!"
      },
      {
        "type": "service",
        "rating": 2,
        "comment": "Garçom demorou para atender à nossa mesa.",
        "justification": "Chegamos em horário de pico..."
      },
      {
        "type": "value",
        "rating": 3,
        "comment": "Preço um pouco alto, mas qualidade justifica."
      },
      {
        "type": "infrastructure",
        "rating": 4,
        "comment": "Ambiente limpo, bem iluminado, confortável."
      }
    ],
    "averageRating": 3.25,
    "createdAt": "2026-04-22T10:00:00Z",
    "submittedAt": "2026-04-22T10:15:00Z"
  }
}
```

**Errors**:
- `400 Bad Request`: Review incomplete (missing criteria or missing justification for < 3 ratings)
- `404 Not Found`: Review not found

---

### Get Review by ID

**Endpoint**: `GET /reviews/{reviewId}`  
**Auth**: Bearer token (JWT) optional

**Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "id": "review_uuid_here",
    "placeId": "place_uuid_here",
    "place": {
      "id": "place_uuid_here",
      "name": "Pizzaria da Maria"
    },
    "userId": "user_uuid_here",
    "user": {
      "id": "user_uuid_here",
      "name": "João Silva",
      "profilePicture": "https://cdn.example.com/user_uuid.jpg"
    },
    "status": "submitted",
    "criteria": [...],
    "averageRating": 3.25,
    "createdAt": "2026-04-22T10:00:00Z",
    "submittedAt": "2026-04-22T10:15:00Z"
  }
}
```

---

### Get Reviews by Place

**Endpoint**: `GET /places/{placeId}/reviews`  
**Auth**: Bearer token (JWT) optional  
**Query Params**:
- `limit`: Number (default 20, max 100)
- `offset`: Number (default 0)
- `sortBy`: "newest" | "rating_high" | "rating_low" (default "newest")

**Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "reviews": [
      {
        "id": "review_uuid_1",
        "userId": "user_uuid_1",
        "user": {
          "name": "João Silva",
          "profilePicture": "https://cdn.example.com/user_uuid_1.jpg"
        },
        "status": "submitted",
        "criteria": [...],
        "averageRating": 4.25,
        "submittedAt": "2026-04-22T10:15:00Z"
      },
      {
        "id": "review_uuid_2",
        "userId": "user_uuid_2",
        "user": {
          "name": "Maria Santos",
          "profilePicture": "https://cdn.example.com/user_uuid_2.jpg"
        },
        "status": "submitted",
        "criteria": [...],
        "averageRating": 3.75,
        "submittedAt": "2026-04-21T18:30:00Z"
      }
    ],
    "pagination": {
      "total": 42,
      "limit": 20,
      "offset": 0
    }
  }
}
```

---

### Get Current User's Reviews

**Endpoint**: `GET /users/me/reviews`  
**Auth**: Bearer token (JWT)  
**Query Params**:
- `limit`: Number (default 20, max 100)
- `offset`: Number (default 0)
- `status`: "draft" | "submitted" optional

**Response (200 OK)**:
```json
{
  "status": "success",
  "data": {
    "reviews": [
      {
        "id": "review_uuid_here",
        "placeId": "place_uuid_here",
        "place": {
          "id": "place_uuid_here",
          "name": "Pizzaria da Maria"
        },
        "status": "submitted",
        "criteria": [...],
        "averageRating": 3.25,
        "submittedAt": "2026-04-22T10:15:00Z"
      }
    ],
    "pagination": {
      "total": 8,
      "limit": 20,
      "offset": 0
    }
  }
}
```

---

### Edit Review (as Draft)

**Endpoint**: `PUT /reviews/{reviewId}`  
**Auth**: Bearer token (JWT)

**Request Body**:
```json
{
  "criteria": [
    {
      "type": "taste",
      "rating": 5,
      "comment": "Pizza EXCELENTE!"
    }
  ]
}
```

**Response (200 OK)**: Same as Add Criterion

---

## Error Response Format

All errors follow this format:

```json
{
  "status": "error",
  "code": "INVALID_RATING",
  "message": "Rating must be between 0 and 5"
}
```

### Common Error Codes

| Code | HTTP | Description |
|------|------|-------------|
| `INVALID_RATING` | 400 | Rating out of range (0-5) |
| `MISSING_JUSTIFICATION` | 400 | Rating < 3 without justification |
| `INVALID_COMMENT` | 400 | Comment < 10 or > 500 chars |
| `INCOMPLETE_REVIEW` | 400 | Missing criteria before submit |
| `EMAIL_ALREADY_EXISTS` | 409 | Email already registered |
| `INVALID_EMAIL` | 400 | Email format invalid |
| `INVALID_CREDENTIALS` | 401 | Wrong email or password |
| `UNAUTHORIZED` | 401 | Missing or invalid JWT token |
| `FORBIDDEN` | 403 | User lacks permission |
| `NOT_FOUND` | 404 | Resource not found |
| `DUPLICATE_CRITERION` | 409 | Criterion type already exists |
| `INVALID_PLACE_NAME` | 400 | Place name < 3 chars |
| `INVALID_ADDRESS` | 400 | Address < 5 chars |
| `INTERNAL_SERVER_ERROR` | 500 | Server error |

---

## Authentication Headers

All endpoints requiring authentication expect:

```
Authorization: Bearer <access_token>
```

Example:
```
GET /users/me HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyX3V1aWQiLCJpYXQiOjE2MTYwMDAwMDAsImV4cCI6MTYxNjAwOTAwMH0.signature
```

---

## Rate Limiting

- **Auth endpoints**: 5 requests per minute per IP
- **Other endpoints**: 100 requests per minute per user (authenticated) or IP (public)

Response headers:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1619088000
```

---

## Pagination

Endpoints that return lists support pagination:

**Query Params**:
- `limit`: Items per page (default 20, max 100)
- `offset`: Starting index (default 0)

**Response**:
```json
{
  "data": [...],
  "pagination": {
    "total": 142,
    "limit": 20,
    "offset": 0
  }
}
```

Mobile client example:
```dart
// Fetch next page
final nextOffset = currentOffset + limit;
final response = await client.get(
  '/places?limit=$limit&offset=$nextOffset'
);
```
