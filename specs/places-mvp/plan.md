# Plan: places-mvp

## Resumo tecnico

Implementar a feature de locais do MVP em uma fatia pequena, reutilizando a
autenticacao ja existente para identificar o usuario logado e adicionando um
modulo `places` no backend com cadastro, listagem e detalhe. No frontend,
criar a feature correspondente com telas de lista, formulario de cadastro e
detalhe de local.

## Backend

- Modulo impactado:
  `places`, com estrutura `domain`, `application`, `infra` e `presentation`.
- Mudancas de dominio:
  modelar `Place` como aggregate root com `id`, `name`, `street`, `number`,
  `neighborhood`, `city`, `created_by_user_id`, `created_at` e `updated_at`;
  tratar endereco simplificado como parte consistente da entidade do MVP;
  manter autoria do cadastro como atributo obrigatorio.
- Mudancas de application:
  criar casos de uso `CreatePlace`, `ListPlaces` e `GetPlaceById`;
  receber o usuario autenticado como entrada do caso de uso de criacao;
  definir DTOs simples de entrada e saida para lista e detalhe.
- Mudancas de infraestrutura:
  criar modelo SQLAlchemy e repositorio para `places`;
  persistir relacao de autoria com o usuario autenticado;
  preparar consultas simples de listagem e detalhe sem regras de busca
  avancada.
- Mudancas de presentation:
  expor rotas protegidas `POST /places`, `GET /places` e
  `GET /places/{place_id}`;
  validar formato HTTP e delegar regras de negocio ao modulo.

## Frontend

- Features impactadas:
  fluxo de locais com listagem, cadastro e detalhe.
- Estados e navegacao:
  permitir navegar da lista para cadastro e detalhe;
  tratar loading, erro e sucesso de forma consistente com o shell autenticado
  ja existente ou previsto.
- Integracoes com API:
  consumir endpoints de criacao, listagem e detalhe;
  refletir campos obrigatorios no formulario;
  exibir autoria do local em formato simples do MVP.

## Dados e contratos

- Entidade/tabela afetada:
  `places` com `name`, `street`, `number`, `neighborhood`, `city` e
  `created_by_user_id`.
- Contratos esperados:
  `POST /places` cria local autenticado;
  `GET /places` lista locais;
  `GET /places/{place_id}` detalha um local.
- Regras contratuais centrais:
  todos os campos de endereco e nome sao obrigatorios no cadastro;
  apenas usuario autenticado pode criar;
  listagem retorna dados minimos para selecao;
  detalhe retorna dados completos do local e autoria.

## Estrategia de dados

- Criar persistencia de `places` em SQLite mantendo o dominio isolado.
- Registrar autoria por chave estrangeira para o usuario autenticado.
- Nao impor bloqueio de duplicidade no MVP.
- Preparar o contrato de detalhe para suportar evolucao futura com reviews sem
  introduzir esse escopo agora.

## Testes

- Backend unitario:
  casos de uso de criacao, listagem e detalhe com foco em autoria e campos
  obrigatorios.
- Backend integracao:
  testes HTTP cobrindo sucesso e erros de autenticacao e validacao.
- Frontend:
  testes de widgets e/ou servicos para lista, cadastro e detalhe de local.

## Riscos

- Risco: ampliar a spec para incluir reviews ou agregacoes do local.
  Mitigacao: manter contratos e tasks estritamente limitados a cadastro e
  consulta.
- Risco: definir autoria apenas como id tecnico e bloquear UX futura.
  Mitigacao: expor payload simples, mas suficiente para o frontend mostrar quem
  cadastrou.
- Risco: acoplar frontend a mocks ou contratos instaveis.
  Mitigacao: definir endpoints minimos e consistentes ja nesta spec pequena.
