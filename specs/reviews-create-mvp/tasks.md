# Tasks: reviews-create-mvp

## Preparacao

- [ ] Confirmar em `docs/MVP_DOMAIN_MODEL.md` e
      `specs/mvp-evaluation-flow/api-contracts.md` o payload final da review,
      especialmente a representacao da recomendacao final.

## Trilha 1: dominio e persistencia backend

- [ ] Criar o modulo `reviews` no backend com entidade, value objects, ports,
      caso de uso `CreateReview`, persistencia e testes unitarios para regras de
      rating, comentario obrigatorio, justificativa para nota abaixo de `3` e
      historico de revisitas.

## Trilha 2: contratos e endpoint da API

- [ ] Expor `POST /places/{place_id}/reviews` com autenticacao obrigatoria,
      verificacao de local existente, mapeamento de erros e testes de
      integracao HTTP.

## Trilha 3: fluxo e UI minima do frontend

- [ ] Substituir o placeholder protegido de `reviews` por um fluxo minimo de
      criacao que reutilize a selecao de local ja existente e permita enviar a
      avaliacao completa.
- [ ] Criar models, repository/client, controller e validacoes locais da
      feature `reviews`, espelhando o contrato do backend para submit.

## Trilha 4: testes e validacoes

- [ ] Cobrir o fluxo essencial do frontend com testes da feature `reviews` e
      validar os estados de loading, erro e sucesso do submit.
- [ ] Rodar `cd backend && .venv/bin/pytest -q` apos a implementacao backend.
- [ ] Rodar `cd frontend && flutter analyze` apos a implementacao frontend.
- [ ] Rodar `cd frontend && flutter test` apos a implementacao frontend.
