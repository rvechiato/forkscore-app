# Spec: place-categories-mvp

## Contexto

O ForkScore ja possui a base de usuarios e o cadastro de locais, mas o modulo
de locais ainda nao classifica estabelecimentos por taxonomia gastronomica.
Sem esse eixo estrutural, o cadastro fica dependente de interpretacao livre,
perde consistencia para filtros futuros e aumenta o risco de dados heterogeneos
logo no MVP.

Esta spec pequena adiciona ao fluxo de locais uma classificacao obrigatoria por
`Categoria` e `Subcategoria`, com dependencia entre ambas e carga inicial via
seed. O objetivo e enriquecer o dominio de locais sem reabrir escopo de
usuarios, reviews ou moderacao.

## Objetivo

Definir a entrega minima para que todo local cadastrado no ForkScore possua:

- uma categoria gastronomica obrigatoria;
- uma subcategoria obrigatoria pertencente a categoria escolhida;
- contratos de API e persistencia preparados para novas categorias futuras sem
  alterar codigo de regra.

## Visao geral da mudanca

- criar entidade e tabela `categories`;
- criar entidade e tabela `subcategories`;
- adicionar `category_id` e `subcategory_id` em `places`;
- validar no backend que a subcategoria pertence a categoria enviada;
- expor endpoints somente leitura para listar categorias ativas e
  subcategorias por categoria;
- popular categorias e subcategorias iniciais via migration/seed;
- ajustar payloads de criacao, edicao e leitura de locais para incluir a
  classificacao.

## Escopo

- modelar `Category` e `Subcategory` no dominio de locais;
- persistir categorias e subcategorias em SQLite com status de ativo;
- incluir referencia obrigatoria a categoria e subcategoria no cadastro e
  edicao de locais;
- expor endpoints de leitura de categorias e subcategorias;
- ajustar resposta de locais para devolver a classificacao resolvida;
- criar seed inicial com a taxonomia gastronomica oficial do MVP.

## Fora de escopo

- criacao manual de categoria por usuario comum ou painel admin;
- exclusao fisica de categorias ou subcategorias;
- reorganizacao de taxonomia em runtime;
- filtros de busca por categoria no frontend;
- migracao de dados legados com heuristica automatica;
- moderacao editorial da taxonomia.

## Modelo de dominio

### Entidades de dominio

#### `Category`

Representa uma categoria gastronomica de alto nivel.

Campos:
- `id`
- `name`
- `slug`
- `is_active`
- `created_at`
- `updated_at`

Responsabilidades:
- identificar agrupamento principal de um local;
- permanecer desacoplada de detalhes de banco;
- permitir ativacao/desativacao sem alterar contratos centrais.

#### `Subcategory`

Representa uma classificacao detalhada dependente de uma categoria.

Campos:
- `id`
- `category_id`
- `name`
- `slug`
- `is_active`
- `created_at`
- `updated_at`

Responsabilidades:
- apontar exatamente para uma `Category`;
- garantir relacao obrigatoria com categoria pai;
- servir como opcao final do formulario de local.

#### Ajuste em `Place`

O agregado/entidade `Place` passa a incluir:
- `category_id`
- `subcategory_id`

No dominio, o local deve sempre nascer e permanecer consistente com ambos os
campos preenchidos.

### Portas e repositorios

No backend hexagonal, a responsabilidade deve ser separada assim:

- `CategoryRepository`
  - listar categorias ativas
  - buscar categoria ativa por id
- `SubcategoryRepository`
  - listar subcategorias ativas por categoria
  - buscar subcategoria ativa por id
  - verificar se uma subcategoria pertence a determinada categoria
- `PlaceRepository`
  - persistir `category_id` e `subcategory_id`
  - ler local com sua classificacao associada

### Casos de uso

- `ListActiveCategoriesUseCase`
- `ListActiveSubcategoriesByCategoryUseCase`
- `CreatePlaceUseCase` ajustado para validar categoria/subcategoria
- `UpdatePlaceUseCase` ajustado para validar categoria/subcategoria
- `GetPlaceDetailUseCase` e `ListPlacesUseCase` ajustados para retornar a
  classificacao resolvida

### Adaptadores de banco

Na camada `infra`, adaptadores SQLite implementam:

- `SQLiteCategoryRepository`
- `SQLiteSubcategoryRepository`
- ajuste de `SQLitePlaceRepository`

### Controllers / API

Na camada `presentation`:

- controller de leitura para categorias e subcategorias;
- controller de locais recebe `category_id` e `subcategory_id`;
- validacao de payload fica no boundary HTTP, enquanto a regra de pertencimento
  fica garantida no caso de uso.

## Modelo de banco de dados SQLite

### Tabela `categories`

Responsabilidade:
- armazenar categorias mestres do catalogo gastronomico;
- permitir ativacao/desativacao sem remoção fisica.

Colunas:
- `id` TEXT PRIMARY KEY
- `name` TEXT NOT NULL
- `slug` TEXT NOT NULL UNIQUE
- `is_active` INTEGER NOT NULL DEFAULT 1
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

### Tabela `subcategories`

Responsabilidade:
- armazenar subcategorias vinculadas a uma categoria;
- permitir filtro rapido por categoria.

Colunas:
- `id` TEXT PRIMARY KEY
- `category_id` TEXT NOT NULL
- `name` TEXT NOT NULL
- `slug` TEXT NOT NULL
- `is_active` INTEGER NOT NULL DEFAULT 1
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

Restricoes:
- foreign key para `categories(id)`
- unique composto em `(category_id, slug)`

### Alteracao em `places`

Novas colunas:
- `category_id` TEXT NOT NULL
- `subcategory_id` TEXT NOT NULL

Restricoes:
- foreign key `category_id` -> `categories(id)`
- foreign key `subcategory_id` -> `subcategories(id)`

Observacao:
- a consistencia "subcategory pertence a category" nao deve depender apenas das
  foreign keys; precisa ser validada na camada de aplicacao.

## DDL das tabelas

```sql
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE subcategories (
  id TEXT PRIMARY KEY,
  category_id TEXT NOT NULL,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  CONSTRAINT fk_subcategories_category
    FOREIGN KEY (category_id) REFERENCES categories(id),
  CONSTRAINT uq_subcategories_category_slug
    UNIQUE (category_id, slug)
);

CREATE INDEX idx_subcategories_category_id
  ON subcategories (category_id);

ALTER TABLE places
  ADD COLUMN category_id TEXT REFERENCES categories(id);

ALTER TABLE places
  ADD COLUMN subcategory_id TEXT REFERENCES subcategories(id);
```

### Estrategia de migration para `places`

Como SQLite tem limitacoes em `ALTER TABLE` para enforcement evolutivo:

1. adicionar colunas inicialmente permitindo nulo;
2. popular registros legados com categoria/subcategoria provisoria definida por
   migration assistida ou bloquear migration em bancos sem dados elegiveis;
3. recriar a tabela `places` com `NOT NULL` em `category_id` e
   `subcategory_id` quando necessario;
4. criar ou atualizar indices e foreign keys finais.

Para ambiente novo do MVP, a tabela `places` ja deve nascer com:

```sql
category_id TEXT NOT NULL,
subcategory_id TEXT NOT NULL,
FOREIGN KEY (category_id) REFERENCES categories(id),
FOREIGN KEY (subcategory_id) REFERENCES subcategories(id)
```

## Seed inicial

### Categorias e subcategorias obrigatorias

- Restaurante
  - Fine Dining
  - Casual Dining
  - Self-Service
  - Tematico
- Lanchonete
  - Fast Food
  - Hamburgueria
  - Sanduiches
  - Salgados
- Cafeteria
  - Cafeteria
  - Doceria
  - Confeitaria
  - Padaria Gourmet
- Bar
  - Bar Tradicional
  - Gastrobar
  - Pub
  - Bar com Musica
- Especializado
  - Japones
  - Italiano
  - Churrascaria
  - Vegano
  - Arabe
  - Mexicano
  - Indiano
  - Outros
- Street Food
  - Food Truck
  - Barraca
  - Feira Gastronomica
  - Mercado Gastronomico
- Experiencia
  - Sensorial
  - Chef's Table
  - Panoramico
  - Imersivo

### Script seed inicial

```sql
INSERT INTO categories (id, name, slug, is_active, created_at, updated_at) VALUES
  ('cat_restaurante', 'Restaurante', 'restaurante', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('cat_lanchonete', 'Lanchonete', 'lanchonete', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('cat_cafeteria', 'Cafeteria', 'cafeteria', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('cat_bar', 'Bar', 'bar', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('cat_especializado', 'Especializado', 'especializado', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('cat_street_food', 'Street Food', 'street-food', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('cat_experiencia', 'Experiencia', 'experiencia', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO subcategories (id, category_id, name, slug, is_active, created_at, updated_at) VALUES
  ('sub_fine_dining', 'cat_restaurante', 'Fine Dining', 'fine-dining', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_casual_dining', 'cat_restaurante', 'Casual Dining', 'casual-dining', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_self_service', 'cat_restaurante', 'Self-Service', 'self-service', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_tematico', 'cat_restaurante', 'Tematico', 'tematico', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  ('sub_fast_food', 'cat_lanchonete', 'Fast Food', 'fast-food', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_hamburgueria', 'cat_lanchonete', 'Hamburgueria', 'hamburgueria', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_sanduiches', 'cat_lanchonete', 'Sanduiches', 'sanduiches', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_salgados', 'cat_lanchonete', 'Salgados', 'salgados', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  ('sub_cafeteria', 'cat_cafeteria', 'Cafeteria', 'cafeteria', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_doceria', 'cat_cafeteria', 'Doceria', 'doceria', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_confeitaria', 'cat_cafeteria', 'Confeitaria', 'confeitaria', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_padaria_gourmet', 'cat_cafeteria', 'Padaria Gourmet', 'padaria-gourmet', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  ('sub_bar_tradicional', 'cat_bar', 'Bar Tradicional', 'bar-tradicional', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_gastrobar', 'cat_bar', 'Gastrobar', 'gastrobar', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_pub', 'cat_bar', 'Pub', 'pub', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_bar_com_musica', 'cat_bar', 'Bar com Musica', 'bar-com-musica', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  ('sub_japones', 'cat_especializado', 'Japones', 'japones', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_italiano', 'cat_especializado', 'Italiano', 'italiano', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_churrascaria', 'cat_especializado', 'Churrascaria', 'churrascaria', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_vegano', 'cat_especializado', 'Vegano', 'vegano', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_arabe', 'cat_especializado', 'Arabe', 'arabe', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_mexicano', 'cat_especializado', 'Mexicano', 'mexicano', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_indiano', 'cat_especializado', 'Indiano', 'indiano', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_outros', 'cat_especializado', 'Outros', 'outros', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  ('sub_food_truck', 'cat_street_food', 'Food Truck', 'food-truck', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_barraca', 'cat_street_food', 'Barraca', 'barraca', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_feira_gastronomica', 'cat_street_food', 'Feira Gastronomica', 'feira-gastronomica', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_mercado_gastronomico', 'cat_street_food', 'Mercado Gastronomico', 'mercado-gastronomico', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  ('sub_sensorial', 'cat_experiencia', 'Sensorial', 'sensorial', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_chefs_table', 'cat_experiencia', 'Chef''s Table', 'chefs-table', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_panoramico', 'cat_experiencia', 'Panoramico', 'panoramico', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('sub_imersivo', 'cat_experiencia', 'Imersivo', 'imersivo', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
```

## Alteracao necessaria na tabela de locais

O contrato de local passa a exigir:

- `category_id`
- `subcategory_id`

Na representacao de leitura, o backend deve retornar tanto os ids quanto os
objetos resolvidos, para evitar round-trips extras no frontend.

Exemplo de shape recomendado:

```json
{
  "id": "place_123",
  "name": "Casa Aurora",
  "category_id": "cat_restaurante",
  "subcategory_id": "sub_fine_dining",
  "category": {
    "id": "cat_restaurante",
    "name": "Restaurante",
    "slug": "restaurante"
  },
  "subcategory": {
    "id": "sub_fine_dining",
    "name": "Fine Dining",
    "slug": "fine-dining"
  }
}
```

## Regras de negocio

- RN01. Categoria e obrigatoria no cadastro de local.
- RN02. Subcategoria e obrigatoria no cadastro de local.
- RN03. Categoria nao pode ser texto livre.
- RN04. Subcategoria nao pode ser texto livre.
- RN05. A subcategoria deve pertencer a categoria selecionada.
- RN06. O sistema deve rejeitar categoria inativa.
- RN07. O sistema deve rejeitar subcategoria inativa.
- RN08. Usuario comum nao pode criar nem editar o catalogo de categorias.
- RN09. Categorias e subcategorias devem ser mantidas por migration/seed.
- RN10. A estrutura deve permitir adicionar novas categorias futuramente sem
  alteracao de regra de negocio.
- RN11. A API de listagem deve retornar apenas categorias ativas.
- RN12. A API de subcategorias deve retornar apenas subcategorias ativas da
  categoria informada.
- RN13. O backend e a fonte de verdade da consistencia entre categoria e
  subcategoria, mesmo se o frontend tentar burlar o fluxo dependente.

## Endpoints necessarios

### Leitura de catalogo

#### `GET /categories`

Responsabilidade:
- listar categorias ativas para alimentar o formulario de local.

Autorizacao:
- pode ser publico ou autenticado conforme decisao do produto; para o MVP,
  recomenda-se autenticado se o cadastro de locais ja estiver dentro da area
  protegida.

Resposta:
- lista ordenada por nome ou pela ordem editorial da seed.

#### `GET /categories/{category_id}/subcategories`

Responsabilidade:
- listar subcategorias ativas da categoria informada.

Validacoes:
- categoria deve existir;
- categoria deve estar ativa.

### Ajustes na API de locais

#### `POST /places`

Adicionar ao payload:
- `category_id`
- `subcategory_id`

#### `PUT /places/{place_id}` ou `PATCH /places/{place_id}`

Se o fluxo de edicao ja existir, ele deve exigir a mesma consistencia entre
`category_id` e `subcategory_id`.

#### `GET /places`

Retornar os campos de classificacao resolvidos em cada item ou ao menos ids +
nomes necessarios ao frontend.

#### `GET /places/{place_id}`

Retornar a classificacao completa do local.

## Exemplos de request/response

### `GET /categories`

Response `200 OK`

```json
{
  "items": [
    {
      "id": "cat_restaurante",
      "name": "Restaurante",
      "slug": "restaurante"
    },
    {
      "id": "cat_lanchonete",
      "name": "Lanchonete",
      "slug": "lanchonete"
    }
  ]
}
```

### `GET /categories/cat_restaurante/subcategories`

Response `200 OK`

```json
{
  "category": {
    "id": "cat_restaurante",
    "name": "Restaurante",
    "slug": "restaurante"
  },
  "items": [
    {
      "id": "sub_fine_dining",
      "name": "Fine Dining",
      "slug": "fine-dining"
    },
    {
      "id": "sub_casual_dining",
      "name": "Casual Dining",
      "slug": "casual-dining"
    }
  ]
}
```

### `POST /places`

Request

```json
{
  "name": "Casa Aurora",
  "street": "Rua das Flores",
  "number": "123",
  "neighborhood": "Centro",
  "city": "Sao Paulo",
  "category_id": "cat_restaurante",
  "subcategory_id": "sub_fine_dining"
}
```

Response `201 Created`

```json
{
  "id": "place_123",
  "name": "Casa Aurora",
  "street": "Rua das Flores",
  "number": "123",
  "neighborhood": "Centro",
  "city": "Sao Paulo",
  "category_id": "cat_restaurante",
  "subcategory_id": "sub_fine_dining",
  "category": {
    "id": "cat_restaurante",
    "name": "Restaurante",
    "slug": "restaurante"
  },
  "subcategory": {
    "id": "sub_fine_dining",
    "name": "Fine Dining",
    "slug": "fine-dining"
  },
  "created_by_user": {
    "id": "user_1",
    "name": "Rafa"
  }
}
```

### Erro de combinacao invalida

Request

```json
{
  "name": "Casa Aurora",
  "street": "Rua das Flores",
  "number": "123",
  "neighborhood": "Centro",
  "city": "Sao Paulo",
  "category_id": "cat_bar",
  "subcategory_id": "sub_fine_dining"
}
```

Response `422 Unprocessable Entity`

```json
{
  "detail": "A subcategoria informada nao pertence a categoria selecionada."
}
```

## Fluxo de UX no cadastro de local

1. Usuario acessa formulario de cadastro de local autenticado.
2. Frontend carrega categorias ativas.
3. Campo `Categoria` e exibido como seletor obrigatorio.
4. Enquanto nenhuma categoria estiver selecionada, `Subcategoria` permanece
   desabilitado ou vazio.
5. Ao selecionar uma categoria, frontend chama endpoint de subcategorias
   filtradas por `category_id`.
6. Campo `Subcategoria` e habilitado e preenchido com opcoes dependentes.
7. Usuario conclui o restante do formulario.
8. Ao enviar, backend valida obrigatoriedade e pertencimento.
9. Em sucesso, local retorna com categoria e subcategoria resolvidas.
10. Em erro de combinacao ou ausencia de selecao, frontend mostra mensagem
    clara sem permitir persistencia inconsistente.

## Requisitos funcionais

- RF01. O sistema deve criar e persistir a entidade `Category`.
- RF02. O sistema deve criar e persistir a entidade `Subcategory`.
- RF03. O cadastro de local deve exigir `category_id`.
- RF04. O cadastro de local deve exigir `subcategory_id`.
- RF05. O sistema deve validar que a subcategoria pertence a categoria
  selecionada.
- RF06. O sistema deve listar categorias ativas para uso no frontend.
- RF07. O sistema deve listar subcategorias ativas filtradas por categoria.
- RF08. O sistema deve ajustar leitura de locais para retornar a classificacao
  associada.
- RF09. Categorias e subcategorias iniciais devem ser carregadas via seed.
- RF10. O sistema deve impedir criacao de categorias por usuario comum.

## Requisitos nao funcionais

- RNF01. O backend deve preservar a arquitetura hexagonal entre `domain`,
  `application`, `infra` e `presentation`.
- RNF02. O catalogo de categorias nao pode depender de enums fixos em regra de
  negocio.
- RNF03. A persistencia deve continuar compativel com SQLite no MVP.
- RNF04. O contrato de API deve permanecer simples e suficiente para Flutter
  web e mobile.
- RNF05. A seed deve ser idempotente ou controlada por migration unica.
- RNF06. A validacao critica deve acontecer no backend, sem confiar apenas no
  fluxo dependente do frontend.

## Criterios de aceite

- CA01. Um usuario autenticado nao consegue cadastrar local sem categoria.
- CA02. Um usuario autenticado nao consegue cadastrar local sem subcategoria.
- CA03. O backend rejeita uma subcategoria que nao pertence a categoria
  enviada.
- CA04. O backend expõe endpoint de categorias retornando apenas categorias
  ativas.
- CA05. O backend expõe endpoint de subcategorias filtrando pelo `category_id`
  informado.
- CA06. O cadastro de local persiste `category_id` e `subcategory_id`.
- CA07. O detalhe e a listagem de local retornam a classificacao resolvida.
- CA08. A carga inicial do banco contem exatamente a taxonomia gastronomica
  definida nesta spec.
- CA09. Novas categorias podem ser adicionadas por migration/seed sem alterar
  o codigo de validacao de pertencimento.
- CA10. Usuario comum nao possui endpoint para criar ou editar categorias.

## Dependencias e restricoes

- Esta spec depende do modulo de locais ja existente.
- Esta spec reutiliza o contexto autenticado ja implementado no projeto.
- A classificacao de locais deve permanecer no modulo `places`, sem criar um
  modulo transversal desnecessario para o MVP.
- Se houver dados legados em `places`, a migration deve tratar backfill antes
  de impor `NOT NULL`.
- O frontend pode consumir os endpoints em cascata, mas a integridade nao pode
  depender do cliente.

## Artefatos relacionados

- `docs/MVP_DOMAIN_MODEL.md`
- `specs/places-mvp/spec.md`
- `specs/auth-profile-mvp/spec.md`
