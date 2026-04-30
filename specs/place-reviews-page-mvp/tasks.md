# Tasks: place-reviews-page-mvp

## Preparacao

- [x] Revisar `home-search-unification`, `places-mvp` e
      `review-read-model-mvp` para confirmar o que ja pode ser reaproveitado.
- [x] Definir no kickoff tecnico se a nova pagina sera atendida apenas pelo
      resumo atual ou se exigira endpoint adicional para listagem de reviews.
- [x] Mapear os arquivos de navegacao, home, places e reviews impactados.

## Backend

- [x] Reaproveitar os contratos atuais de detalhe de lugar e resumo de reviews
      ou implementar o endpoint adicional de leitura de reviews do lugar, se
      aprovado no kickoff.
- [x] Adicionar testes backend apenas se houver mudancas de contrato, caso de
      uso ou repositorio.

## Frontend

- [x] Criar a nova rota protegida da pagina de reviews do lugar.
- [x] Criar a nova pagina dedicada com cabecalho do lugar, bloco de reviews e
      CTA para avaliar.
- [x] Alterar o clique da lista de lugares da home para navegar para a nova
      pagina.
- [x] Remover da home a dependencia do detalhe inline como fluxo principal de
      leitura.
- [x] Atualizar ou criar testes de widget cobrindo navegacao, renderizacao da
      nova pagina e retorno para a home.

## Validacao

- [x] Rodar `cd backend && .venv/bin/pytest -q` se houver mudancas no backend.
- [x] Rodar `cd frontend && flutter analyze`.
- [x] Rodar `cd frontend && flutter test`.
- [ ] Revisar manualmente a jornada autenticada: login -> home -> pagina do
      lugar -> CTA de avaliar -> voltar.
