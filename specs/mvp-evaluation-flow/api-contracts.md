# API Contracts: mvp-evaluation-flow

## Objetivo

Definir os contratos HTTP do MVP do ForkScore para os modulos `auth/profile`,
`places` e `reviews`, preservando compatibilidade com o backend FastAPI atual e
reduzindo ambiguidade para o frontend Flutter.

## Convencoes gerais

- Base path atual: sem versionamento e sem prefixo global adicional.
- Content type de request e response: `application/json`.
- Autenticacao protegida: header `Authorization: Bearer <access_token>`.
- `token_type` deve permanecer como string literal `bearer`.
- Identificadores (`id`, `place_id`, `user_id`, `review_id`) devem ser tratados
  pelo frontend como `string`.
- Datas devem ser serializadas em ISO 8601 UTC quando expostas.
- Erros de negocio e autenticacao seguem o formato atual:

```json
{
  "detail": "Mensagem de erro"
}
```

- Erros de validacao de payload seguem o padrao atual do FastAPI/Pydantic:

```json
{
  "detail": [
    {
      "loc": ["body", "field_name"],
      "msg": "Field required",
      "type": "missing"
    }
  ]
}
```

## Enumeracoes do MVP

### ReviewCriterionCode

- `taste`
- `service`
- `options`
- `infrastructure`

### RecommendationValue

- `recommended`
- `not_recommended`

## Modulo: auth/profile

### POST `/auth/register`

Cria uma conta e retorna token de acesso com o perfil simplificado.

Autenticacao: publica

#### Request

```json
{
  "name": "Rafa Vecchiato",
  "birth_date": "1997-08-14",
  "email": "rafa@example.com",
  "password": "super-secret-123"
}
```

#### Response `201 Created`

```json
{
  "access_token": "jwt-token",
  "token_type": "bearer",
  "user": {
    "id": "usr_123",
    "name": "Rafa Vecchiato",
    "birth_date": "1997-08-14",
    "age": 29,
    "email": "rafa@example.com"
  }
}
```

#### Validacoes

- `name`: obrigatorio, string, `min_length=2`, `max_length=80`, sem aceitar
  apenas espacos.
- `birth_date`: obrigatorio, data valida no passado.
- `email`: obrigatorio, formato valido de email, normalizado em lowercase para
  persistencia.
- `password`: obrigatorio, string, `min_length=8`, `max_length=128`.
- Email nao pode existir previamente.

#### HTTP esperados

- `201 Created`: cadastro realizado.
- `409 Conflict`: email ja cadastrado.
- `422 Unprocessable Entity`: payload invalido.

### POST `/auth/login`

Autentica um usuario existente.

Autenticacao: publica

#### Request

```json
{
  "email": "rafa@example.com",
  "password": "super-secret-123"
}
```

#### Response `200 OK`

```json
{
  "access_token": "jwt-token",
  "token_type": "bearer",
  "user": {
    "id": "usr_123",
    "name": "Rafa Vecchiato",
    "birth_date": "1997-08-14",
    "age": 29,
    "email": "rafa@example.com"
  }
}
```

#### Validacoes

- `email`: obrigatorio, formato valido.
- `password`: obrigatorio, string, `min_length=8`, `max_length=128`.
- Credenciais devem corresponder a um usuario existente.

#### HTTP esperados

- `200 OK`: login realizado.
- `401 Unauthorized`: credenciais invalidas.
- `422 Unprocessable Entity`: payload invalido.

### GET `/me`

Retorna o perfil simplificado do usuario autenticado.

Autenticacao: obrigatoria

#### Response `200 OK`

```json
{
  "id": "usr_123",
  "name": "Rafa Vecchiato",
  "birth_date": "1997-08-14",
  "age": 29,
  "email": "rafa@example.com"
}
```

#### Validacoes

- Token JWT obrigatorio e valido.
- Usuario do token deve existir e estar ativo no sistema.

#### HTTP esperados

- `200 OK`: perfil retornado.
- `401 Unauthorized`: token ausente, invalido ou expirado.
- `404 Not Found`: usuario referenciado no token nao encontrado.

### PUT `/me`

Atualiza integralmente o perfil simplificado do usuario autenticado.

Autenticacao: obrigatoria

#### Request

```json
{
  "name": "Rafa Vecchiato",
  "birth_date": "1996-08-14",
  "email": "rafa.new@example.com"
}
```

#### Response `200 OK`

```json
{
  "id": "usr_123",
  "name": "Rafa Vecchiato",
  "birth_date": "1996-08-14",
  "age": 30,
  "email": "rafa.new@example.com"
}
```

#### Validacoes

- `name`: obrigatorio, string, `min_length=2`, `max_length=80`, sem aceitar
  apenas espacos.
- `birth_date`: obrigatorio, data valida no passado.
- `email`: obrigatorio, formato valido.
- Email atualizado nao pode colidir com outro usuario.
- Token JWT obrigatorio e valido.

#### HTTP esperados

- `200 OK`: perfil atualizado.
- `401 Unauthorized`: token ausente, invalido ou expirado.
- `404 Not Found`: usuario autenticado nao encontrado.
- `409 Conflict`: email em uso por outro usuario.
- `422 Unprocessable Entity`: payload invalido.

## Modulo: places

### PlaceAddressPayload

```json
{
  "street": "Rua das Flores",
  "number": "123",
  "neighborhood": "Centro",
  "city": "Sao Paulo"
}
```

### PlaceSummaryResponse

```json
{
  "id": "plc_123",
  "name": "Cafe Aurora",
  "street": "Rua das Flores",
  "number": "123",
  "neighborhood": "Centro",
  "city": "Sao Paulo",
  "created_by": {
    "id": "usr_123",
    "name": "Rafa Vecchiato"
  }
}
```

### POST `/places`

Cria um local e registra autoria.

Autenticacao: obrigatoria

#### Request

```json
{
  "name": "Cafe Aurora",
  "street": "Rua das Flores",
  "number": "123",
  "neighborhood": "Centro",
  "city": "Sao Paulo"
}
```

#### Response `201 Created`

```json
{
  "id": "plc_123",
  "name": "Cafe Aurora",
  "street": "Rua das Flores",
  "number": "123",
  "neighborhood": "Centro",
  "city": "Sao Paulo",
  "created_by": {
    "id": "usr_123",
    "name": "Rafa Vecchiato"
  }
}
```

#### Validacoes

- `name`: obrigatorio, string, `min_length=2`, `max_length=120`.
- `street`: obrigatorio, string, `min_length=2`, `max_length=120`.
- `number`: obrigatorio, string, `min_length=1`, `max_length=20`.
- `neighborhood`: obrigatorio, string, `min_length=2`, `max_length=80`.
- `city`: obrigatorio, string, `min_length=2`, `max_length=80`.
- Todos os campos de texto devem ser `trim` antes da validacao.
- Token JWT obrigatorio e valido.

#### HTTP esperados

- `201 Created`: local criado.
- `401 Unauthorized`: token ausente, invalido ou expirado.
- `422 Unprocessable Entity`: payload invalido.

### GET `/places`

Lista locais para selecao e navegacao no frontend do MVP.

Autenticacao: obrigatoria

#### Response `200 OK`

```json
{
  "items": [
    {
      "id": "plc_123",
      "name": "Cafe Aurora",
      "street": "Rua das Flores",
      "number": "123",
      "neighborhood": "Centro",
      "city": "Sao Paulo",
      "created_by": {
        "id": "usr_123",
        "name": "Rafa Vecchiato"
      }
    }
  ],
  "total": 1
}
```

#### Validacoes

- Token JWT obrigatorio e valido.
- MVP nao exige filtros, ordenacao customizada nem paginacao parametrizada.
- A ordem de retorno deve ser estavel; preferencia por criacao decrescente para
  o frontend exibir os locais mais recentes primeiro.

#### HTTP esperados

- `200 OK`: lista retornada.
- `401 Unauthorized`: token ausente, invalido ou expirado.

### GET `/places/{place_id}`

Retorna o detalhe de um local.

Autenticacao: obrigatoria

#### Response `200 OK`

```json
{
  "id": "plc_123",
  "name": "Cafe Aurora",
  "street": "Rua das Flores",
  "number": "123",
  "neighborhood": "Centro",
  "city": "Sao Paulo",
  "created_by": {
    "id": "usr_123",
    "name": "Rafa Vecchiato"
  }
}
```

#### Validacoes

- `place_id`: obrigatorio, string nao vazia na rota.
- Token JWT obrigatorio e valido.
- O local precisa existir.

#### HTTP esperados

- `200 OK`: detalhe retornado.
- `401 Unauthorized`: token ausente, invalido ou expirado.
- `404 Not Found`: local nao encontrado.

## Modulo: reviews

### ReviewCriterionInput

```json
{
  "code": "taste",
  "rating": 5,
  "comment": "Pratos bem executados e sabor equilibrado.",
  "justification": null
}
```

### ReviewAuthorResponse

```json
{
  "id": "usr_123",
  "name": "Rafa Vecchiato"
}
```

### ReviewCriterionResponse

```json
{
  "code": "taste",
  "rating": 5,
  "comment": "Pratos bem executados e sabor equilibrado.",
  "justification": null
}
```

### POST `/places/{place_id}/reviews`

Cria a avaliacao gastronomica de um local.

Autenticacao: obrigatoria

#### Request

```json
{
  "recommendation": "recommended",
  "cost_benefit_rating": 4,
  "criteria": [
    {
      "code": "taste",
      "rating": 5,
      "comment": "Pratos bem executados e sabor equilibrado.",
      "justification": null
    },
    {
      "code": "service",
      "rating": 4,
      "comment": "Equipe atenciosa e agilidade adequada.",
      "justification": null
    },
    {
      "code": "options",
      "rating": 2,
      "comment": "Poucas opcoes vegetarianas no cardapio.",
      "justification": "O cardapio tem variedade limitada para restricoes alimentares."
    },
    {
      "code": "infrastructure",
      "rating": 3,
      "comment": "Ambiente confortavel e limpo.",
      "justification": null
    }
  ]
}
```

#### Response `201 Created`

```json
{
  "id": "rev_123",
  "place_id": "plc_123",
  "user": {
    "id": "usr_123",
    "name": "Rafa Vecchiato"
  },
  "recommendation": "recommended",
  "cost_benefit_rating": 4,
  "criteria": [
    {
      "code": "taste",
      "rating": 5,
      "comment": "Pratos bem executados e sabor equilibrado.",
      "justification": null
    },
    {
      "code": "service",
      "rating": 4,
      "comment": "Equipe atenciosa e agilidade adequada.",
      "justification": null
    },
    {
      "code": "options",
      "rating": 2,
      "comment": "Poucas opcoes vegetarianas no cardapio.",
      "justification": "O cardapio tem variedade limitada para restricoes alimentares."
    },
    {
      "code": "infrastructure",
      "rating": 3,
      "comment": "Ambiente confortavel e limpo.",
      "justification": null
    }
  ],
  "created_at": "2026-04-24T20:30:00Z"
}
```

#### Validacoes

- `place_id`: obrigatorio, string nao vazia na rota.
- Token JWT obrigatorio e valido.
- O local precisa existir.
- `recommendation`: obrigatorio, aceitar somente `recommended` ou
  `not_recommended`.
- `cost_benefit_rating`: obrigatorio, inteiro entre `1` e `5`.
- `criteria`: obrigatorio, array com exatamente 4 itens.
- Cada item de `criteria` deve conter:
  - `code`: obrigatorio, aceitar somente `taste`, `service`, `options`,
    `infrastructure`.
  - `rating`: obrigatorio, inteiro entre `1` e `5`.
  - `comment`: obrigatorio, string nao vazia apos `trim`, `max_length=500`.
  - `justification`: opcional quando `rating >= 3`; obrigatoria, string nao
    vazia apos `trim`, `max_length=500`, quando `rating < 3`.
- O array deve conter todos os 4 criterios do MVP exatamente uma vez, sem
  duplicidade e sem criterios extras.
- O backend nao deve bloquear nova review do mesmo usuario para o mesmo local;
  cada submissao valida representa um novo registro historico.

#### HTTP esperados

- `201 Created`: avaliacao criada.
- `401 Unauthorized`: token ausente, invalido ou expirado.
- `404 Not Found`: local nao encontrado.
- `422 Unprocessable Entity`: payload invalido ou regra de negocio violada.

## Matriz resumida de autenticacao

| Rota | Autenticacao |
|------|--------------|
| `POST /auth/register` | Publica |
| `POST /auth/login` | Publica |
| `GET /me` | Bearer JWT |
| `PUT /me` | Bearer JWT |
| `POST /places` | Bearer JWT |
| `GET /places` | Bearer JWT |
| `GET /places/{place_id}` | Bearer JWT |
| `POST /places/{place_id}/reviews` | Bearer JWT |

## Pontos de atencao para compatibilidade com o frontend

- Manter o formato de sucesso de `auth` consistente entre cadastro e login:
  `access_token`, `token_type`, `user`.
- Incluir `birth_date` e `age` no objeto `user` de `register`, `login`,
  `GET /me` e `PUT /me` para evitar modelos distintos no Flutter.
- Tratar todos os IDs como `string` no frontend; nao presumir UUID, inteiro ou
  formato interno.
- Manter nomes de campos em `snake_case` no backend e refletir isso nos mappers
  do Flutter para evitar conversoes inconsistentes.
- O frontend deve suportar dois formatos de erro no campo `detail`: string
  simples para regras de negocio e lista estruturada para erro `422` do
  FastAPI.
- O frontend nao deve inferir ordem de `criteria` pela exibicao; deve usar o
  campo `code` para mapear cada criterio.
- O backend deve responder sempre com os quatro criterios completos na mesma
  estrutura do request para simplificar desserializacao e reuso de modelos.
- `cost_benefit_rating` deve existir como campo proprio da review, fora de
  `criteria`, para refletir a modelagem de dominio do MVP.
- `justification` deve existir no payload mesmo quando nula para evitar
  condicionais desnecessarias no app.
- Evitar alterar `recommendation` para boolean no MVP; `recommended` e
  `not_recommended` sao mais estaveis e autoexplicativos para app e API.
- `GET /places` retorna `items` e `total` para deixar espaco para paginacao
  futura sem quebrar a lista do Flutter.
- `PUT /me` foi definido como atualizacao integral. Se o backend futuramente
  adotar `PATCH`, isso deve ser adicionado como nova rota, sem mudar o
  comportamento atual.
