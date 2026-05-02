# Tasks: place-review-cta-above-reviews

## Preparacao

- [x] Revisar a spec da pagina dedicada em `specs/place-reviews-page-mvp/`.
- [x] Identificar a composicao atual em `PlaceReviewsPage`.
- [x] Confirmar que a mudanca e restrita ao frontend.

## Backend

- [x] Confirmar que nao ha alteracao backend necessaria.

## Frontend

- [x] Reordenar o layout mobile para renderizar o CTA antes do container de
      review/resumo.
- [x] Reordenar o layout largo para renderizar o CTA acima do container de
      review/resumo na coluna lateral.
- [x] Adicionar ou atualizar teste de widget validando a ordem visual do CTA.
- [x] Confirmar que o CTA ainda navega para o fluxo de avaliacao do lugar.

## Validacao

- [x] Rodar `cd frontend && flutter analyze`.
- [x] Rodar `cd frontend && flutter test`.
- [x] Revisar `git diff` para garantir que nao houve alteracao fora do escopo.
