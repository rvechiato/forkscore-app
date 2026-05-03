# Plan: place-review-cta-above-reviews

## Resumo tecnico

A abordagem e alterar apenas a ordem de composicao dos widgets na pagina
dedicada de reviews do lugar. O `_ReviewCtaCard` ja existe e ja recebe o local
selecionado com o callback correto para abrir o fluxo de avaliacao; portanto, a
feature deve reposicionar esse card antes do container de review do local nos
dois layouts suportados pela pagina.

## Estado atual relevante

- `PlaceReviewsPage` monta `header`, `summary`, `reviews` e `cta`.
- No layout mobile, a ordem atual e `header`, `summary`, `reviews`, `cta`.
- No layout largo, a coluna lateral renderiza `summary` antes de `cta`.
- O botao possui a chave `start-review-button` e ja e coberto por testes de
  existencia e navegacao basica.

## Backend

- Nenhum modulo de backend sera impactado.
- Nao ha mudanca de dominio, application, infra, rotas ou persistencia.
- Nao ha alteracao de contratos de API.

## Frontend

- Arquivo principal:
  `frontend/lib/features/places/presentation/pages/place_reviews_page.dart`.
- Layout mobile:
  renderizar `cta` logo apos `header` e antes de `summary` e `reviews`.
- Layout largo:
  renderizar `cta` antes de `summary` na coluna lateral, mantendo a lista de
  reviews na coluna principal.
- Testes:
  atualizar `frontend/test/widget_test.dart` ou criar teste especifico para
  validar que o CTA aparece acima do container de review/resumo.

## Dados e contratos

- Sem mudancas em dados persistidos.
- Sem alteracoes em modelos de dominio.
- Sem novos endpoints.
- Sem alteracoes nos contratos existentes de lugar ou reviews.

## Testes

- Rodar `cd frontend && flutter analyze`.
- Rodar `cd frontend && flutter test`.
- Garantir cobertura para a ordem visual no fluxo de pagina do lugar.

## Riscos

- Risco: a mudanca corrigir apenas mobile e deixar web com a ordem antiga.
  Mitigacao: revisar os dois ramos do `LayoutBuilder`.
- Risco: teste de ordem visual ficar fragil por depender de detalhes de layout.
  Mitigacao: usar posicoes globais dos widgets principais ou uma chave estavel
  ja existente no container de resumo.
- Risco: o CTA subir demais e separar o usuario da leitura das reviews.
  Mitigacao: manter o cabecalho do lugar como primeiro bloco e mover apenas o
  CTA para antes do container de review.
