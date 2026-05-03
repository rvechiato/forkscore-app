# Tasks: place-create-instagram-link

## Preparação

- [x] Revisar instrucao do agente, constituicao e fluxo SDD.
- [x] Identificar tela, controller, repository e contratos backend impactados.
- [x] Criar branch `codex/place-create-instagram-link`.

## Backend

- [x] Adicionar `instagram_url` opcional aos DTOs de places.
- [x] Validar link opcional do Instagram no input de criacao.
- [x] Adicionar `instagram_url` a entidade, modelo SQLAlchemy e repository.
- [x] Mapear `instagram_url` em criacao, listagem e detalhe.
- [x] Adicionar migracao leve SQLite para coluna nullable.
- [x] Atualizar testes de places.

## Frontend

- [x] Remover autoria atual da tela de cadastro.
- [x] Adicionar campo opcional de Instagram no cadastro.
- [x] Propagar `instagramUrl` por controller, repository, modelos e mocks.
- [x] Atualizar teste do repository API.
- [x] Atualizar teste widget da tela de cadastro.

## Validação

- [x] Rodar testes do backend.
- [x] Rodar analise do frontend.
- [x] Rodar testes do frontend.
- [x] Revisar diff final e registrar observacoes.
