# Tasks: home-search-unification

## Preparacao

- [ ] Revisar `frontend-auth-home-layout`, `places-mvp` e `docs/MVP_DOMAIN_MODEL.md`
      para confirmar que a unificacao e apenas de fluxo/frontend no MVP.
- [ ] Mapear os arquivos atuais de home, places e navegacao que precisarao ser
      ajustados.

## Frontend

- [ ] Reorganizar a home autenticada para concentrar saudacao, busca, lista de
      lugares e placeholder de favoritos.
- [ ] Reaproveitar ou extrair a experiencia de pesquisa/listagem de lugares da
      feature `places` para uso direto na home, preservando a funcionalidade.
- [ ] Ajustar a navegacao autenticada para remover a dependencia de uma pagina
      separada de pesquisa como fluxo principal do MVP.
- [ ] Atualizar os testes de widget impactados pela nova experiencia.

## Validacao

- [ ] Rodar `cd frontend && flutter analyze` apos a implementacao.
- [ ] Rodar `cd frontend && flutter test` apos a implementacao.
- [ ] Revisar o fluxo autenticado final para confirmar coerencia com o MVP.
