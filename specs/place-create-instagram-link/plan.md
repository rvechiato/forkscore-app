# Plan: place-create-instagram-link

## Resumo técnico

A mudanca adiciona `instagram_url` como atributo opcional de `Place`, validado no
DTO de entrada e persistido no modelo SQLAlchemy. O frontend inclui um campo
opcional no formulario de cadastro e remove a copy visual de autoria. A autoria
segue sendo preenchida exclusivamente no use case `CreatePlace` a partir do
usuario autenticado.

## Backend

- Modulo impactado: `backend/src/modules/places`.
- Domain: adicionar `instagram_url: str | None` em `Place`.
- Application: adicionar `instagram_url` em `CreatePlaceInput`,
`PlaceSummaryOutput` e `PlaceDetailOutput`.
- Application: validar URL opcional como HTTP/HTTPS e host Instagram.
- Use cases: mapear `instagram_url` em criacao, listagem e detalhe.
- Infra: adicionar coluna nullable em `PlaceModel` e mapear repository/entity.
- Bootstrap SQLite: adicionar migracao leve com `ALTER TABLE places ADD COLUMN
instagram_url VARCHAR(255) NULL` para bancos MVP existentes.

## Frontend

- Tela impactada: `frontend/lib/features/places/presentation/pages/place_create_page.dart`.
- Remover a exibicao de autoria atual no cadastro.
- Adicionar `TextEditingController` e `TextFormField` opcional para Instagram.
- Enviar `instagramUrl` via `PlacesController` e `PlacesRepository`.
- Atualizar modelos `PlaceDetail` e `PlaceSummary` com `instagramUrl` opcional.
- Atualizar `ForkScoreApiPlacesRepository` e `MockPlacesRepository`.
- Ajustar o painel legado de places para manter o contrato compilando e sem
exibir autoria no composer.

## Dados e contratos

- Tabela afetada: `places`.
- Nova coluna: `instagram_url`, nullable, tamanho maximo 255.
- `POST /places` aceita `instagram_url` opcional.
- `POST /places`, `GET /places` e `GET /places/{place_id}` retornam
`instagram_url`.
- `created_by` permanece no contrato de saida atual, mas nao e exibido no
formulario de cadastro.

## Testes

- Backend: atualizar `backend/tests/test_places.py` para cobrir persistencia,
retorno e rejeicao de URL invalida.
- Frontend data: atualizar teste do repository para parsear/listar e criar com
`instagram_url`.
- Frontend widget: garantir que a tela de cadastro abre com campo Instagram e sem
`Autoria atual`.
- Validacao: rodar `cd backend && .venv/bin/pytest -q` e `cd frontend && flutter
analyze && flutter test`.

## Riscos

- Risco: bancos SQLite locais antigos nao terem a nova coluna.
- Mitigacao: `ensure_places_schema` adiciona a coluna nullable quando necessario.

- Risco: validacao muito restritiva bloquear formatos reais de links.
- Mitigacao: aceitar `instagram.com` e `www.instagram.com` com HTTP/HTTPS, sem
validar path especifico.
