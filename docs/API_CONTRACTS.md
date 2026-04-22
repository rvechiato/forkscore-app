# API Contracts — ForkScore

Especificação de todos os endpoints da API REST.

---

## Base URL

```
http://localhost:3000/api
```

---

## Authentication

Todos os endpoints exceto `/auth/*` requerem JWT:

```
Authorization: Bearer <access_token>
```

---

## Health Check

### GET /health

Status da aplicação.

**Response**: 200 OK
```json
{
  "status": "ok",
  "timestamp": "2026-04-22T12:00:00Z",
  "service": "ForkScore API v0.1.0",
  "environment": "development"
}
```

---

## Auth Endpoints

### POST /auth/login

Efetua login do usuário.

**Request**:
```json
{
  "email": "user@example.com",
  "password": "SecurePass123"
}
```

**Response**: 200 OK
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "name": "João Silva"
  }
}
```

**Errors**:
- `400 Bad Request`: Email ou senha inválidos
- `400 Bad Request`: Usuário não encontrado

---

### POST /auth/signup

Registra novo usuário.

**Request**:
```json
{
  "email": "newuser@example.com",
  "password": "SecurePass123",
  "name": "Maria Santos"
}
```

**Response**: 201 Created
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "email": "newuser@example.com",
    "name": "Maria Santos"
  }
}
```

**Errors**:
- `400 Bad Request`: Email já registrado
- `400 Bad Request`: Senha fraca (< 8 chars, sem maiúscula/minúscula/número)

---

## Users Endpoints

### GET /users/profile

Retorna perfil do usuário autenticado.

**Authentication**: Required ✅

**Response**: 200 OK
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "name": "João Silva",
  "bio": "Amante de comida italiana",
  "profilePhotoUrl": "https://...",
  "reviewCount": 12,
  "averageRatingGiven": 4.2,
  "createdAt": "2026-01-15T10:00:00Z"
}
```

---

### PUT /users/profile

Atualiza perfil do usuário.

**Authentication**: Required ✅

**Request**:
```json
{
  "name": "João Silva Santos",
  "bio": "Crítico gastronômico",
  "profilePhotoUrl": "data:image/jpeg;base64,..."
}
```

**Response**: 200 OK
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "name": "João Silva Santos",
  "bio": "Crítico gastronômico",
  "profilePhotoUrl": "https://...",
  "updatedAt": "2026-04-22T15:30:00Z"
}
```

---

## Places Endpoints

### GET /places?search=&type=&limit=10&offset=0

Busca locais.

**Authentication**: Optional

**Query Params**:
- `search`: Busca por nome (substring)
- `type`: Filtro por tipo (restaurant, cafe, bakery, etc)
- `limit`: Número de resultados (default 10)
- `offset`: Paginação (default 0)

**Response**: 200 OK
```json
{
  "total": 42,
  "results": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "name": "Pizzaria Italiana",
      "type": "restaurant",
      "address": "Rua das Flores, 123",
      "lat": -23.5505,
      "lng": -46.6333,
      "phone": "+55 11 3333-3333",
      "website": "https://pizzaria.com.br",
      "reviewCount": 15,
      "averageRating": 4.5,
      "criteria": {
        "sabor": 4.6,
        "atendimento": 4.3,
        "custo": 4.2,
        "infra": 4.7
      },
      "createdAt": "2026-01-20T08:00:00Z"
    }
  ]
}
```

---

### POST /places

Cadastra novo local.

**Authentication**: Required ✅

**Request**:
```json
{
  "name": "Café do João",
  "type": "cafe",
  "address": "Avenida Paulista, 1000",
  "lat": -23.5615,
  "lng": -46.6560,
  "phone": "+55 11 2222-2222",
  "website": "https://cafedojoao.com.br"
}
```

**Response**: 201 Created
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440003",
  "name": "Café do João",
  "type": "cafe",
  "address": "Avenida Paulista, 1000",
  "lat": -23.5615,
  "lng": -46.6560,
  "createdByUserId": "550e8400-e29b-41d4-a716-446655440000",
  "createdAt": "2026-04-22T14:00:00Z"
}
```

**Errors**:
- `409 Conflict`: Local com mesmo nome e endereço já existe

---

### GET /places/:placeId

Detalhes de um local com todas as reviews.

**Authentication**: Optional

**Response**: 200 OK
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440002",
  "name": "Pizzaria Italiana",
  "type": "restaurant",
  "address": "Rua das Flores, 123",
  "lat": -23.5505,
  "lng": -46.6333,
  "phone": "+55 11 3333-3333",
  "website": "https://pizzaria.com.br",
  "reviewCount": 15,
  "averageRating": 4.5,
  "criteria": {
    "sabor": 4.6,
    "atendimento": 4.3,
    "custo": 4.2,
    "infra": 4.7
  },
  "reviews": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440010",
      "userId": "550e8400-e29b-41d4-a716-446655440000",
      "userName": "João Silva",
      "criteria": [
        {
          "criterion": "sabor",
          "rating": 5,
          "comment": "Sabor excelente, massa perfeita",
          "isJustified": false
        },
        ...
      ],
      "createdAt": "2026-04-20T19:00:00Z"
    }
  ]
}
```

---

## Reviews Endpoints

### POST /reviews

Cria nova avaliação.

**Authentication**: Required ✅

**Request**:
```json
{
  "placeId": "550e8400-e29b-41d4-a716-446655440002",
  "criteria": [
    {
      "criterion": "sabor",
      "rating": 4,
      "comment": "Excelente sabor, muito saboroso",
      "isJustified": false
    },
    {
      "criterion": "atendimento",
      "rating": 3,
      "comment": "Atendimento bom, poderia ser mais rápido",
      "isJustified": false
    },
    {
      "criterion": "custo",
      "rating": 2,
      "comment": "Preço muito alto para a qualidade oferecida, bebida cara",
      "isJustified": true
    },
    {
      "criterion": "infra",
      "rating": 5,
      "comment": "Local muito limpo e confortável",
      "isJustified": false
    }
  ]
}
```

**Response**: 201 Created
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440020",
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "placeId": "550e8400-e29b-41d4-a716-446655440002",
  "criteria": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440021",
      "criterion": "sabor",
      "rating": 4,
      "comment": "Excelente sabor, muito saboroso",
      "isJustified": false
    },
    ...
  ],
  "overallRating": 3.5,
  "createdAt": "2026-04-22T20:15:00Z"
}
```

**Errors**:
- `400 Bad Request`: Critério inválido
- `400 Bad Request`: Rating fora do intervalo 0-5
- `400 Bad Request`: Comentário com menos de 10 caracteres
- `400 Bad Request`: Rating < 3 sem justificativa
- `409 Conflict`: Usuário já avaliou este local hoje

---

### PUT /reviews/:reviewId

Atualiza avaliação própria (até 24h após criação).

**Authentication**: Required ✅

**Request**:
```json
{
  "criteria": [
    {
      "criterion": "sabor",
      "rating": 5,
      "comment": "Pensando melhor, foi ainda melhor do que esperava",
      "isJustified": false
    },
    ...
  ]
}
```

**Response**: 200 OK
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440020",
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "placeId": "550e8400-e29b-41d4-a716-446655440002",
  "criteria": [...],
  "updatedAt": "2026-04-22T21:00:00Z"
}
```

**Errors**:
- `403 Forbidden`: Tentativa de atualizar review de outro usuário
- `410 Gone`: Review foi criada há mais de 24 horas

---

### DELETE /reviews/:reviewId

Deleta avaliação própria (até 24h após criação).

**Authentication**: Required ✅

**Response**: 204 No Content

**Errors**:
- `403 Forbidden`: Tentativa de deletar review de outro usuário
- `410 Gone`: Review foi criada há mais de 24 horas

---

### GET /reviews/user/:userId

Lista todas as reviews de um usuário.

**Authentication**: Optional

**Response**: 200 OK
```json
{
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "userName": "João Silva",
  "totalReviews": 12,
  "averageRatingGiven": 4.1,
  "reviews": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440020",
      "placeId": "550e8400-e29b-41d4-a716-446655440002",
      "placeName": "Pizzaria Italiana",
      "criteria": [...],
      "createdAt": "2026-04-22T20:15:00Z"
    }
  ]
}
```

---

## Error Handling

Todos os erros seguem este formato:

```json
{
  "status": "error",
  "code": "INVALID_RATING",
  "message": "Rating deve estar entre 0 e 5 estrelas",
  "timestamp": "2026-04-22T12:00:00Z"
}
```

---

**API Contracts v0.1.0**
