# Plan: mvp-evaluation-flow

## Resumo tecnico

Implementar o fluxo principal do MVP em tres frentes coordenadas:

- evoluir `auth` para expor o perfil simplificado e criar um modulo `users`
  para consulta/atualizacao do perfil autenticado;
- adicionar o modulo `places` para cadastro, listagem e detalhe de locais com
  autoria;
- adicionar o modulo `reviews` para registrar a avaliacao gastronomica com os
  quatro criterios fixos, custo-beneficio e a recomendacao final.

No frontend, criar o fluxo inicial autenticado com navegacao basica para
perfil, locais e avaliacao, consumindo os novos endpoints do backend.

## Backend

- Modulos impactados:
  `auth` para enriquecer o payload do usuario autenticado e garantir
  compatibilidade com perfil basico;
  `users` para consulta e atualizacao do perfil do usuario logado;
  `places` para cadastro e consulta de locais;
  `reviews` para criacao de avaliacoes e regras do dominio.
- Mudancas de dominio:
  introduzir entidades e value objects para `Profile`, `Place`, `Review` e
  `ReviewCriterion`;
  tratar criterios do MVP como conjunto fixo controlado pelo dominio;
  encapsular a regra de obrigatoriedade de comentario e justificativa por
  criterio;
  calcular idade a partir de `birth_date` sem persistir idade como atributo
  canonico;
  modelar `cost_benefit_rating` como atributo proprio de `Review`;
  permitir historico de revisitas sem restricao de unicidade entre
  `author_user_id` e `place_id`;
  manter autoria em local e avaliacao como parte da modelagem.
- Mudancas de application:
  criar casos de uso para `GetMyProfile`, `UpdateMyProfile`, `CreatePlace`,
  `ListPlaces`, `GetPlaceById` e `CreateReview`;
  reutilizar autenticacao atual para obter o usuario logado nas rotas
  protegidas;
  padronizar DTOs de entrada e saida para o fluxo do MVP.
- Mudancas de infraestrutura:
  criar modelos SQLAlchemy, repositorios e migracao da base atual para suportar
  usuarios com perfil baseado em `birth_date`, locais e avaliacoes;
  registrar dependencias de cada novo modulo;
  garantir que adaptadores persistam relacionamentos entre usuario, local e
  avaliacao.
- Mudancas de presentation:
  expor rotas protegidas para perfil, locais e avaliacoes;
  manter respostas e erros consistentes com o modulo `auth`;
  validar formato HTTP sem transferir regra de negocio para a camada de API.

## Frontend

- Telas impactadas:
  criar fluxo de autenticacao inicial;
  criar tela de perfil basico com visualizacao e edicao;
  criar fluxo de locais com listagem, cadastro e detalhe;
  criar fluxo de avaliacao para um local com formulario por criterio e decisao
  final.
- Estados e navegacao:
  adicionar um shell simples para area autenticada;
  persistir sessao/token em camada apropriada para o MVP;
  tratar estados de carregamento, sucesso e erro sem acoplar widgets a chamadas
  HTTP diretas.
- UX e arquitetura de fluxo:
  usar `specs/mvp-evaluation-flow/frontend-ux.md` como referencia para mapa de
  telas, jornadas, campos minimos, componentes compartilhados e estados de UX;
  manter `Home autenticada`, `Lista de locais`, `Cadastro de local`,
  `Detalhe do local`, `Nova avaliacao`, `Perfil` e `Edicao de perfil` como
  estrutura base do MVP;
  tratar a avaliacao como formulario guiado com validacoes inline por criterio
  e recomendacao final obrigatoria.
- Integracoes com API:
  consumir endpoints de login/cadastro existentes e novos endpoints de perfil,
  locais e avaliacao;
  refletir no frontend as validacoes obrigatorias de comentario e justificativa
  para reduzir erros de submissao;
  manter modelos e servicos simples, preparados para evolucao posterior.

## Dados e contratos

- Entidades/tabelas afetadas:
  `users` com email e identidade autenticada;
  `profiles` com nome e `birth_date`;
  `places` com nome, rua, numero, bairro, cidade e `created_by_user_id`;
  `reviews` com `place_id`, `user_id`, `recommended`,
  `cost_benefit_rating` e metadados basicos;
  `review_criteria` com criterio, nota, comentario e justificativa.
- Contratos esperados:
  `POST /auth/register` retorna token e perfil simplificado;
  `POST /auth/login` retorna token e perfil simplificado;
  `GET /me` retorna perfil do usuario autenticado;
  `PUT /me` atualiza perfil do usuario autenticado;
  `POST /places` cria local autenticado;
  `GET /places` lista locais;
  `GET /places/{place_id}` detalha um local;
  `POST /places/{place_id}/reviews` cria avaliacao do local.
- Regras contratuais centrais:
  nota inteira entre 1 e 5;
  custo-beneficio inteiro entre 1 e 5;
  comentario obrigatorio para todos os criterios;
  justificativa obrigatoria para nota menor que 3;
  multiplas reviews por usuario no mesmo local sao permitidas;
  criterios fixos do MVP sempre presentes no payload.

## Estrategia de dados

- Evoluir o schema atual do SQLite sem quebrar autenticacao existente.
- Representar os criterios do MVP de forma explicita para evitar avaliacoes
  parciais ou com nomes livres.
- Tratar `cost_benefit_rating` como campo proprio da review, fora da colecao de
  criterios qualitativos.
- Nao impor restricao de unicidade entre usuario e local na tabela de reviews
  do MVP, para preservar historico de revisitas.
- Manter autoria por chave estrangeira em locais e avaliacoes.
- Preparar mapeamentos e repositorios para futura migracao de SQLite para
  PostgreSQL sem alterar casos de uso.

## Testes

- Backend unitario:
  regras de dominio para criterios obrigatorios, faixa de nota e justificativa
  quando nota < 3;
  casos de uso de perfil, local e avaliacao com repositorios em memoria ou
  mocks.
- Backend integracao:
  testes HTTP para rotas autenticadas de perfil, locais e reviews;
  cobertura dos cenarios de erro esperados de validacao.
- Frontend:
  testes de widgets e/ou de fluxo para autenticacao, cadastro de local e
  formulario de avaliacao;
  testes de servicos/repositories para adaptacao dos contratos.

## Riscos

- Risco: acoplar regras de avaliacao apenas ao frontend e deixar o backend
  permissivo.
  Mitigacao: centralizar validacoes obrigatorias no dominio/casos de uso e
  cobrir com testes.
- Risco: expandir demais o escopo com consultas, ranking ou agregacoes.
  Mitigacao: manter o foco em cadastro, detalhe e submissao da avaliacao.
- Risco: crescer o modulo `auth` alem do necessario ao misturar autenticacao e
  perfil.
  Mitigacao: isolar consulta/edicao de perfil em `users`, preservando `auth`
  para login e cadastro.
- Risco: frontend ficar bloqueado por contratos indefinidos.
  Mitigacao: definir payloads minimos e consistentes ja nesta spec.
