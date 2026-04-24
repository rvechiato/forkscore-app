# Spec: mvp-evaluation-flow

## Contexto

O ForkScore ja possui a base de autenticacao inicial no backend em FastAPI com
arquitetura hexagonal, frontend em Flutter e fluxo SDD preparado no
repositorio. O proximo passo do MVP e definir o fluxo principal da aplicacao,
conectando autenticacao, perfil basico, cadastro de locais, avaliacao
gastronomica e decisao final de recomendacao.

Sem essa especificacao, backend e frontend correm o risco de evoluir com
contratos incompletos, regras inconsistentes de avaliacao e lacunas no fluxo do
usuario autenticado.

## Objetivo

Definir o MVP do fluxo principal do ForkScore para que qualquer usuario
autenticado possa:

- criar conta e manter um perfil basico;
- cadastrar um local com endereco simplificado;
- registrar uma avaliacao gastronomica com criterios fixos do MVP;
- informar se recomenda ou nao o local ao final da avaliacao;
- consultar locais e suas informacoes essenciais para continuar o fluxo.

## Escopo

- evoluir a autenticacao existente para expor o perfil simplificado com nome,
  data de nascimento e email;
- permitir consulta e atualizacao basica do perfil do usuario autenticado;
- permitir que qualquer usuario autenticado cadastre um local;
- registrar no local o usuario que realizou o cadastro;
- permitir listar e consultar locais cadastrados;
- permitir criar avaliacao para um local com os criterios fixos do MVP:
  sabor, atendimento, opcoes e infraestrutura;
- permitir multiplas avaliacoes historicas do mesmo usuario para o mesmo local;
- permitir nota por estrelas de 1 a 5 para cada criterio;
- permitir informar custo-beneficio com rating inteiro de 1 a 5;
- exigir comentario obrigatorio para cada criterio avaliado;
- exigir justificativa obrigatoria quando a nota de um criterio for menor que 3;
- permitir marcar a recomendacao final do local como recomendaria ou nao
  recomendaria;
- definir contratos de API e estados de tela necessarios para o fluxo completo
  do MVP.

## Fora de escopo

- edicao e exclusao de locais por usuarios;
- busca avancada, filtros, ordenacao complexa ou geolocalizacao;
- upload de imagens de perfil ou do local;
- curtidas, favoritos, ranking publico ou feed social;
- comentarios livres fora da estrutura dos criterios do MVP;
- calculo automatico de nota agregada, ranking ou recomendacao inteligente;
- moderacao, denuncia ou aprovacao manual de cadastros;
- suporte a papeis de administrador;
- recuperacao de senha, login social ou confirmacao de email.

## Requisitos funcionais

- RF01. O sistema deve permitir cadastro de usuario com autenticacao inicial e
  armazenamento do perfil simplificado contendo nome, data de nascimento e
  email.
- RF02. O sistema deve permitir login com as credenciais ja definidas no modulo
  de autenticacao.
- RF03. O sistema deve permitir que o usuario autenticado consulte o proprio
  perfil.
- RF04. O sistema deve permitir que o usuario autenticado atualize os dados
  basicos do proprio perfil, respeitando nome, data de nascimento e email
  validos.
- RF05. O sistema deve permitir que qualquer usuario autenticado cadastre um
  local informando nome, rua, numero, bairro e cidade.
- RF06. O cadastro do local deve registrar o identificador do usuario que
  realizou a criacao.
- RF07. O sistema deve permitir listar locais cadastrados com informacoes
  minimas para selecao no frontend.
- RF08. O sistema deve permitir consultar o detalhe de um local, incluindo seus
  dados basicos e o usuario que o cadastrou.
- RF09. O sistema deve permitir que um usuario autenticado crie uma avaliacao
  para um local existente.
- RF10. O sistema deve permitir que o mesmo usuario registre multiplas
  avaliacoes historicas para o mesmo local em momentos diferentes.
- RF11. Cada avaliacao deve conter exatamente os quatro criterios do MVP:
  sabor, atendimento, opcoes e infraestrutura.
- RF12. Cada criterio deve registrar uma nota inteira por estrelas entre 1 e 5.
- RF13. Cada criterio deve exigir comentario obrigatorio preenchido pelo
  usuario.
- RF14. Cada criterio com nota menor que 3 deve exigir justificativa
  obrigatoria.
- RF15. Cada criterio com nota maior ou igual a 3 pode omitir justificativa.
- RF16. A avaliacao deve registrar a decisao final do usuario entre
  recomendaria e nao recomendaria.
- RF17. A avaliacao deve registrar custo-beneficio com nota inteira entre 1 e
  5.
- RF18. O sistema deve vincular a avaliacao ao local avaliado e ao usuario
  autenticado que a criou.
- RF19. O frontend deve oferecer um fluxo claro de cadastro/login, consulta de
  perfil, cadastro de local, listagem/detalhe de local e envio de avaliacao.

## Requisitos nao funcionais

- RNF01. O backend deve preservar a arquitetura hexagonal, com separacao clara
  entre `domain`, `application`, `infra` e `presentation`.
- RNF02. O frontend deve preservar a organizacao por features em
  `lib/app`, `lib/features` e `lib/shared`.
- RNF03. Os contratos de API devem ser simples e suficientes para web e mobile
  no MVP, evitando sobrecarga de campos nao usados.
- RNF04. As validacoes criticas de negocio devem existir no backend mesmo que o
  frontend tambem as aplique.
- RNF05. O fluxo principal deve ser executavel com persistencia em SQLite no
  MVP, sem acoplamento de dominio a detalhes do banco.
- RNF06. O sistema deve manter rastreabilidade minima de autoria em locais e
  avaliacoes para suportar evolucao futura.
- RNF07. Os testes devem cobrir regras centrais de autenticacao, perfil,
  cadastro de local e validacao da avaliacao.

## Criterios de aceite

- CA01. Um usuario consegue se cadastrar e receber uma resposta contendo token
  de acesso e dados basicos do perfil.
- CA02. Um usuario autenticado consegue consultar o proprio perfil com nome,
  data de nascimento, idade calculada e email.
- CA03. Um usuario autenticado consegue atualizar o proprio perfil e visualizar
  os dados alterados em resposta consistente.
- CA04. Um usuario autenticado consegue cadastrar um local com nome, rua,
  numero, bairro e cidade.
- CA05. Um local cadastrado persiste a referencia do usuario que realizou o
  cadastro.
- CA06. Um usuario autenticado consegue listar locais e acessar o detalhe de um
  local existente.
- CA07. Uma avaliacao so e aceita quando os quatro criterios do MVP sao
  enviados.
- CA08. O backend aceita multiplas avaliacoes do mesmo usuario para o mesmo
  local, preservando historico.
- CA09. O backend rejeita avaliacao com nota fora do intervalo de 1 a 5.
- CA10. O backend rejeita avaliacao sem comentario em qualquer criterio.
- CA11. O backend rejeita avaliacao com nota menor que 3 sem justificativa no
  criterio correspondente.
- CA12. O backend rejeita avaliacao sem custo-beneficio ou com custo-beneficio
  fora do intervalo de 1 a 5.
- CA13. O backend aceita avaliacao completa com decisao final de recomendaria
  ou nao recomendaria.
- CA14. A avaliacao persistida fica associada ao local e ao usuario
  autenticado.
- CA15. O frontend apresenta o fluxo principal do MVP sem depender de dados
  mockados para autenticacao, locais e avaliacao.

## Dependencias e restricoes

- A feature deve reutilizar o modulo `auth` existente em vez de recriar o fluxo
  de autenticacao.
- O perfil simplificado deve partir do usuario autenticado atual e nao exigir
  novo papel ou onboarding paralelo.
- A implementacao precisa respeitar a estrutura monolitica com separacao entre
  `backend/` e `frontend/`.
- Os novos modulos previstos no backend sao `users`, `places` e `reviews`, com
  responsabilidade limitada ao MVP.
- O frontend atual ainda nao possui features de autenticacao, locais ou
  avaliacao, entao o plano deve considerar criacao incremental dessas areas.
- A persistencia inicial continua em SQLite, com mapeamentos preparados para
  evolucao futura sem contaminar o dominio.

## Artefatos relacionados

- Contratos HTTP detalhados do MVP:
  `specs/mvp-evaluation-flow/api-contracts.md`
