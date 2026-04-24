# Tasks: mvp-evaluation-flow

## Preparacao

- [ ] Revisar `specs/mvp-evaluation-flow/spec.md` e alinhar eventuais ajustes de
      escopo antes de implementar.
- [ ] Mapear os contratos atuais de `auth` no backend e identificar a evolucao
      necessaria para incluir `birth_date` e idade calculada no perfil
      simplificado.
- [ ] Confirmar a estrutura inicial do frontend para receber fluxo autenticado e
      novas features sem quebrar a home existente.

## Backend

- [ ] Evoluir o modelo de usuario existente para suportar perfil simplificado
      com nome, `birth_date` e email.
- [ ] Criar o modulo `users` com `domain`, `application`, `infra` e
      `presentation` para consulta e atualizacao do perfil do usuario
      autenticado.
- [ ] Criar o modulo `places` com entidade, ports, casos de uso, repositorios e
      rotas para cadastro, listagem e detalhe de locais.
- [ ] Garantir que `Place` registre `created_by_user_id` e exponha autoria nos
      contratos necessarios do MVP.
- [ ] Criar o modulo `reviews` com entidades e regras para criterios fixos,
      faixa de notas, `cost_benefit_rating`, comentario obrigatorio e
      justificativa obrigatoria quando nota < 3.
- [ ] Implementar o caso de uso de criacao de avaliacao vinculado a usuario
      autenticado, local existente e historico de revisitas.
- [ ] Adicionar modelos SQLAlchemy e ajustes de persistencia para usuarios,
      locais, avaliacoes e criterios de avaliacao.
- [ ] Registrar dependencias e rotas na aplicacao FastAPI, mantendo consistencia
      com o padrao atual do projeto.
- [ ] Escrever testes unitarios de dominio e casos de uso para perfil, locais e
      reviews.
- [ ] Escrever testes de integracao HTTP cobrindo sucesso e validacoes de erro
      do fluxo principal.

## Frontend

- [x] Consolidar o documento `specs/mvp-evaluation-flow/frontend-ux.md` com mapa
      de telas, navegacao, jornadas, campos minimos, componentes compartilhados
      e estados de UX do MVP.
- [ ] Criar a feature de autenticacao inicial consumindo cadastro e login do
      backend.
- [ ] Criar a feature de perfil com visualizacao e edicao do perfil simplificado
      do usuario autenticado.
- [ ] Criar a feature de locais com listagem, cadastro e detalhe de local.
- [ ] Criar a feature de avaliacao com formulario dos quatro criterios fixos e
      escolha final de recomendacao.
- [ ] Aplicar validacoes locais de comentario obrigatorio e justificativa para
      nota < 3 antes do envio ao backend.
- [ ] Organizar navegacao e estado do fluxo autenticado do MVP em estrutura
      coerente com `lib/app`, `lib/features` e `lib/shared`.
- [ ] Adicionar testes de widgets e de integracao dos servicos essenciais do
      frontend.

## Documentacao e validacao

- [ ] Atualizar documentacao operacional se os contratos ou o fluxo do MVP
      exigirem novos passos de setup ou uso.
- [ ] Rodar `cd backend && .venv/bin/pytest -q`.
- [ ] Rodar `cd frontend && flutter analyze`.
- [ ] Rodar `cd frontend && flutter test`.
- [ ] Revisar se a implementacao final continua aderente a `docs/ARCHITECTURE.md`
      e `.specify/memory/constitution.md`.
