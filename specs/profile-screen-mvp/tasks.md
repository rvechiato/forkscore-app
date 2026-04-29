# Tasks: profile-screen-mvp

## Preparacao

- [ ] Revisar `specs/profile-screen-mvp/spec.md` e confirmar aderencia com
      `docs/MVP_DOMAIN_MODEL.md`, `docs/EXECUTION_NEXT_STEPS.md` e
      `specs/auth-profile-mvp/`.
- [ ] Confirmar no frontend atual quais partes da integracao com `/me` ja podem
      ser reutilizadas sem ampliar escopo.

## Trilha 1: contrato e integracao

- [ ] Validar e ajustar a adaptacao de `GET /me` e `PUT /me` no frontend para o
      uso direto da tela de perfil.
- [ ] Garantir que a resposta de atualizacao substitua corretamente o usuario da
      sessao autenticada atual.

## Trilha 2: tela e formulario

- [ ] Substituir o placeholder da rota `/profile` por uma pagina real de perfil
      autenticado.
- [ ] Implementar exibicao e edicao de `name`, `email` e `birth_date`, com
      `age` somente leitura e estado vazio bem tratado.

## Trilha 3: estados e validacao

- [ ] Implementar estados de loading, erro e sucesso para carregamento e
      salvamento do perfil sem perder a sessao.
- [ ] Adicionar testes enxutos da tela cobrindo carregamento, estado vazio de
      `birth_date` e atualizacao com reflexo na sessao.

## Validacao

- [ ] Revisar se a entrega continua pequena, sem reabrir escopo fora do perfil
      autenticado do MVP.
- [ ] Rodar `cd frontend && flutter analyze`.
- [ ] Rodar `cd frontend && flutter test`.
