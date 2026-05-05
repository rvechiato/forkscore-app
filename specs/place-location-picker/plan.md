# Plan: place-location-picker

## Resumo tecnico

A feature adiciona coordenadas opcionais ao cadastro de locais. O backend
expande o read/write model do modulo `places` para aceitar, validar, persistir e
retornar `latitude` e `longitude`. O frontend adiciona um componente de seletor
de mapa no formulario de criacao de local, mantendo a localizacao opcional e
enviando coordenadas apenas quando houver ponto definido. Para evitar que o
usuario precise procurar manualmente o lugar no mapa, o fluxo principal passa a
ser: preencher endereco, acionar "Localizar pelo endereco", conferir o marcador
sugerido, ajustar se necessario e salvar. A pagina dedicada de reviews tambem
passa a usar essas coordenadas para exibir um mapa somente leitura no container
de dados do lugar.

Para o MVP, a abordagem recomendada e usar `flutter_map` com OpenStreetMap para
o mapa e uma busca de endereco acionada por botao. O geocoding deve evitar
dependencia obrigatoria de chave paga no MVP e ficar isolado por adaptador para
permitir trocar Nominatim/OpenStreetMap, Photon ou outro provedor no futuro. GPS
e autocomplete continuo ficam fora desta entrega.

## Estado atual relevante

- O modulo `places` ja possui entidade, DTOs, repositorio SQLAlchemy e rotas de
  criacao/listagem/detalhe.
- A tela de cadastro de local ja coleta dados textuais e envia `POST /places`.
- A pagina dedicada de reviews (`PlaceReviewsPage`) exibe um container de dados
  do lugar antes do resumo e da lista de reviews.
- O frontend usa modelos e repositorios em `lib/features/places/`.
- O banco SQLite atual e inicializado diretamente pela infraestrutura do
  backend no MVP.

## Backend

- Modulo impactado: `src/modules/places/`.
- Domain:
  - adicionar `latitude` e `longitude` opcionais na entidade `Place`;
  - manter coordenadas como dados opcionais do local, sem criar regra de busca
    geografica nesta feature.
- Application:
  - expandir DTOs de criacao e resposta de locais;
  - validar ranges em DTO/use case conforme padrao atual;
  - rejeitar payload parcial com apenas uma coordenada.
- Infrastructure:
  - adicionar colunas nullable `latitude` e `longitude` no model SQLAlchemy;
  - persistir e mapear coordenadas no repositorio de places;
  - garantir compatibilidade com dados existentes sem coordenadas.
- Presentation:
  - expor os campos em `POST /places`, `GET /places` e
    `GET /places/{place_id}`;
  - se a busca por endereco for feita pelo backend, expor endpoint de sugestoes
    de localizacao sem persistencia, por exemplo
    `GET /places/location-suggestions`;
  - manter autenticao/autoria atual sem mudancas.
- Geocoding:
  - criar porta de aplicacao para buscar sugestoes de coordenadas por endereco;
  - implementar adaptador de infraestrutura para o provedor escolhido no MVP;
  - retornar sugestoes normalizadas com `label`, `latitude`, `longitude` e
    metadados opcionais de confianca quando disponiveis;
  - manter a criacao do local independente da disponibilidade do geocoding.

## Frontend

- Modulo impactado: `frontend/lib/features/places/`.
- Dependencias:
  - avaliar/adicionar `flutter_map`;
  - avaliar/adicionar pacote de coordenadas usado pelo `flutter_map`, se
    necessario.
  - avaliar se a chamada de geocoding deve usar repositorio frontend direto ou
    endpoint backend; preferir backend se houver restricao de CORS, necessidade
    de trocar provedor ou controle de rate limit.
- Modelos:
  - adicionar `latitude` e `longitude` em `PlaceSummary`, `PlaceDetail` e no
    request de criacao de local;
  - mapear valores nulos corretamente.
- UI:
  - criar `PlaceLocationPicker` ou widget equivalente dentro de
    `features/places/presentation/widgets/`;
  - criar ou extrair um componente de mapa compartilhavel para visualizacao
    somente leitura e selecao interativa;
  - exibir mapa compacto no formulario de criacao;
  - exibir botao "Localizar pelo endereco" na secao do mapa;
  - habilitar a busca quando houver dados minimos de endereco preenchidos;
  - montar texto de busca com rua, numero, bairro e cidade;
  - mostrar estado de carregamento durante a busca;
  - ao encontrar resultado, centralizar o mapa e posicionar marcador sugerido;
  - se houver multiplas sugestoes, permitir escolher uma delas em lista compacta
    antes de definir o marcador;
  - se nao houver resultado, exibir mensagem clara e manter marcacao manual;
  - permitir selecionar/substituir ponto por clique/toque;
  - exibir marcador visual quando houver ponto;
  - exibir acao para limpar localizacao;
  - exibir mapa somente leitura no container de dados da pagina de reviews
    quando `PlaceDetail` tiver coordenadas;
  - omitir o mapa da pagina de reviews quando `PlaceDetail` nao tiver
    coordenadas;
  - preservar layout responsivo web/mobile.
- Estado:
  - manter coordenadas no estado do formulario/controller;
  - manter estado de busca de endereco: parado, carregando, sucesso, sem
    resultado e erro;
  - manter sugestoes de geocoding separadas do ponto efetivamente selecionado
    ate o usuario escolher/confirmar uma sugestao;
  - enviar coordenadas apenas quando ambas existirem;
  - limpar coordenadas quando o usuario acionar limpar localizacao;
  - manter a visualizacao da pagina de reviews sem handlers de edicao.
- Navegacao:
  - nao ha nova rota;
  - a tela continua protegida e reutiliza guards/logout existentes.

## Dados e contratos

- Tabela afetada: `places`.
- Novas colunas:
  - `latitude FLOAT NULL`;
  - `longitude FLOAT NULL`.
- Endpoint afetado:
  - `POST /places`;
  - `GET /places`;
  - `GET /places/{place_id}`.
- Consumidores frontend afetados:
  - formulario de cadastro de local;
  - repositorio/servico de sugestoes de localizacao por endereco;
  - container de dados do lugar na pagina de reviews;
  - modelos de listagem/detalhe usados na descoberta e na pagina dedicada.
- Regras:
  - `latitude` e `longitude` devem ser ambas ausentes ou ambas presentes;
  - latitude valida: `-90 <= latitude <= 90`;
  - longitude valida: `-180 <= longitude <= 180`;
  - respostas retornam `null` quando coordenadas nao existem.
  - sugestoes de geocoding nao devem criar nem alterar locais por si so;
  - o usuario sempre pode ajustar manualmente o ponto sugerido antes do envio.

## Testes

- Backend:
  - criar local sem coordenadas;
  - criar local com coordenadas validas;
  - rejeitar latitude fora de range;
  - rejeitar longitude fora de range;
  - rejeitar payload parcial;
  - verificar retorno em listagem e detalhe.
- Frontend:
  - parse de `PlaceSummary` e `PlaceDetail` com e sem coordenadas;
  - serializacao do request de criacao com e sem coordenadas;
  - widget do seletor exibindo estado vazio;
  - widget do seletor exibindo marcador/estado definido;
  - widget do seletor acionando busca por endereco com os campos preenchidos;
  - estado de carregamento da busca por endereco;
  - estado de sucesso com marcador sugerido;
  - estado sem resultados/erro sem bloquear marcacao manual;
  - selecao de sugestao quando houver mais de um resultado;
  - acao de limpar localizacao;
  - formulario enviando coordenadas quando definidas;
  - pagina de reviews exibindo mapa quando o local tem coordenadas;
  - pagina de reviews omitindo mapa quando o local nao tem coordenadas.
- Validacao manual:
  - testar busca por endereco com endereco encontrado;
  - testar busca por endereco sem resultado;
  - testar ajuste manual depois de usar "Localizar pelo endereco";
  - testar selecao no mapa em largura mobile;
  - testar selecao no mapa em largura desktop/web;
  - testar visualizacao do mapa na pagina de reviews em mobile;
  - testar visualizacao do mapa na pagina de reviews em desktop/web;
  - confirmar que nao ha overflow ou sobreposicao no formulario.

## Riscos

- Risco: dependencia de tiles publicos gerar limites ou instabilidade.
  Mitigacao: usar OpenStreetMap no MVP e documentar futura troca para provedor
  dedicado se houver crescimento.
- Risco: provedor publico de geocoding ter limites, CORS ou instabilidade.
  Mitigacao: acionar busca somente por botao, isolar provider em adaptador e
  manter marcacao manual como fallback.
- Risco: geocoding retornar ponto aproximado ou incorreto.
  Mitigacao: apresentar resultado como sugestao e permitir ajuste manual antes
  de salvar.
- Risco: multiplas sugestoes aumentarem complexidade de UI.
  Mitigacao: exibir lista compacta com poucos resultados e permitir ignorar a
  lista marcando manualmente no mapa.
- Risco: testes automatizados de mapa serem frageis por dependerem de render
  externo.
  Mitigacao: isolar estado/contrato do picker em widgets testaveis e validar a
  interacao visual principal manualmente; para a pagina de reviews, testar a
  presenca/ausencia do componente e do marcador por estado.
- Risco: duplicar configuracao de mapa entre cadastro e pagina de reviews.
  Mitigacao: extrair componente compartilhado para mapa com marcador e variar
  apenas o modo interativo/somente leitura.
- Risco: coordenadas parciais criarem dados inconsistentes.
  Mitigacao: validar no backend que latitude e longitude sao enviadas juntas.
- Risco: permissao de localizacao atual aumentar complexidade.
  Mitigacao: deixar GPS fora do MVP desta spec.
- Risco: modelo atual de banco sem migracoes formais exigir cuidado ao evoluir
  SQLite local.
  Mitigacao: seguir o padrao existente de inicializacao/compatibilidade e
  cobrir com testes HTTP.

## Validacao

- Backend:
  `cd backend && .venv/bin/pytest -q`
- Frontend:
  `cd frontend && flutter analyze`
  `cd frontend && flutter test`
- Revisao visual:
  - cadastro de local em viewport mobile;
  - cadastro de local em viewport desktop/web.
  - pagina de reviews em viewport mobile;
  - pagina de reviews em viewport desktop/web.
