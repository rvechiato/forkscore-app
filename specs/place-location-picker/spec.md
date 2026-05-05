# Spec: place-location-picker

## Contexto

O cadastro de locais hoje permite registrar dados textuais do estabelecimento,
categoria, subcategoria e link opcional do Instagram. Para descoberta,
confianca no cadastro e evolucoes futuras de busca por proximidade, tambem e
necessario registrar onde o local fica.

Informar latitude e longitude manualmente nao e uma experiencia adequada para
usuarios comuns. Tambem nao e uma boa experiencia obrigar o usuario a navegar
manualmente no mapa ate encontrar o estabelecimento. O fluxo deve partir dos
campos de endereco ja preenchidos, oferecer uma acao clara para localizar esse
endereco no mapa e permitir que o usuario apenas confirme ou ajuste o marcador
antes de salvar.

## Objetivo

Adicionar ao cadastro de locais a possibilidade de marcar a localizacao do
estabelecimento em um mapa com ajuda de busca por endereco, persistindo
coordenadas opcionais de latitude e longitude no backend, e exibir essa
localizacao no container de dados do lugar na pagina dedicada de reviews.

## Escopo

- adicionar um seletor de localizacao por mapa no formulario de cadastro de
  local;
- adicionar uma acao "Localizar pelo endereco" no seletor de localizacao;
- montar a busca de localizacao a partir dos campos de endereco do formulario:
  rua, numero, bairro e cidade;
- centralizar o mapa e sugerir um marcador quando o endereco for encontrado;
- permitir que o usuario confirme, ajuste ou limpe o ponto sugerido antes de
  enviar o formulario;
- exibir estado de carregamento, erro e "nao encontrado" para a busca por
  endereco;
- permitir clicar ou tocar no mapa para definir o ponto do estabelecimento;
- permitir ajustar o ponto marcado antes do envio;
- permitir limpar a localizacao marcada;
- enviar `latitude` e `longitude` opcionais no contrato de criacao de local;
- persistir as coordenadas no modulo `places`;
- retornar as coordenadas nos contratos de criacao, listagem e detalhe de
  locais;
- exibir um mapa somente leitura com a localizacao no container de dados do
  lugar na pagina de reviews;
- validar os ranges geograficos de latitude e longitude no backend;
- atualizar mocks, modelos e testes impactados no frontend e backend.

## Fora de escopo

- busca por locais proximos;
- ordenacao por distancia;
- autocomplete de endereco enquanto o usuario digita;
- rotas, navegacao GPS ou calculo de trajetos;
- verificacao externa da existencia real do ponto marcado;
- obrigatoriedade de marcar localizacao para criar um local;
- edicao de local existente;
- interacao de edicao da localizacao a partir da pagina de reviews;
- integracao com Google Maps ou dependencia obrigatoria de chave paga no MVP.

## Requisitos funcionais

- RF01. A tela protegida de cadastro de local deve exibir uma secao para marcar
  localizacao no mapa.
- RF02. O usuario deve conseguir definir a localizacao clicando ou tocando em um
  ponto do mapa.
- RF03. Quando houver ponto marcado, a UI deve exibir um marcador visual no mapa
  e indicar que a localizacao foi definida.
- RF04. O usuario deve conseguir substituir o ponto marcado selecionando outro
  ponto no mapa.
- RF05. O usuario deve conseguir limpar a localizacao marcada antes de enviar o
  formulario.
- RF06. O cadastro deve continuar funcionando quando nenhuma localizacao for
  marcada.
- RF07. Quando marcada, a localizacao deve ser enviada ao backend como
  `latitude` e `longitude`.
- RF08. O backend deve persistir `latitude` e `longitude` associados ao local.
- RF09. O backend deve retornar `latitude` e `longitude` em `POST /places`,
  `GET /places` e `GET /places/{place_id}`.
- RF10. O backend deve rejeitar latitude fora do intervalo `-90..90`.
- RF11. O backend deve rejeitar longitude fora do intervalo `-180..180`.
- RF12. O backend deve rejeitar payloads parciais em que apenas uma das
  coordenadas seja enviada.
- RF13. A pagina dedicada de reviews do local deve exibir, no container de dados
  do lugar, um mapa somente leitura quando o local tiver latitude e longitude.
- RF14. O mapa de leitura deve exibir um marcador na localizacao persistida do
  local.
- RF15. Quando o local nao tiver coordenadas, o container de dados do lugar nao
  deve exibir mapa vazio ou percentuais artificiais de localizacao.
- RF16. O mapa de leitura nao deve permitir alterar a localizacao do lugar.
- RF17. A secao de localizacao do cadastro deve exibir uma acao para localizar
  o ponto pelo endereco preenchido.
- RF18. A busca por endereco deve usar rua, numero, bairro e cidade do
  formulario quando esses campos estiverem preenchidos.
- RF19. Quando a busca encontrar um resultado, o mapa deve centralizar no ponto
  retornado e exibir o marcador nessa localizacao.
- RF20. Quando a busca encontrar mais de uma possibilidade, a UI deve permitir
  escolher entre sugestoes simples antes de definir o marcador, ou usar o
  primeiro resultado apenas quando a confianca do provedor for suficiente.
- RF21. Quando a busca nao encontrar resultado, a UI deve informar que o ponto
  nao foi encontrado e manter a possibilidade de marcar manualmente no mapa.
- RF22. Durante a busca por endereco, a UI deve mostrar estado de carregamento e
  impedir chamadas duplicadas pelo mesmo acionamento.
- RF23. O usuario deve conseguir ajustar manualmente o marcador sugerido pela
  busca antes de salvar.
- RF24. A busca por endereco nao deve tornar coordenadas obrigatorias; se a
  busca falhar, o cadastro sem localizacao continua permitido.

## Requisitos nao funcionais

- RNF01. A alteracao deve preservar a arquitetura hexagonal do modulo `places`.
- RNF02. A implementacao frontend deve preservar a organizacao em
  `lib/app`, `lib/features` e `lib/shared`.
- RNF03. O mapa deve funcionar em Flutter web e mobile.
- RNF04. A localizacao deve ser opcional no MVP para nao bloquear cadastros sem
  coordenadas conhecidas.
- RNF05. A solucao do MVP deve evitar dependencia obrigatoria de provedores
  pagos ou chaves secretas de mapa.
- RNF06. A UI deve ser responsiva, sem sobreposicao entre mapa, marcador,
  botoes e campos do formulario.
- RNF07. O mapa deve ter texto/estado acessivel para indicar se ha localizacao
  marcada e quais coordenadas foram selecionadas.
- RNF08. Testes automatizados devem cobrir validacao de contrato e estado do
  formulario, mesmo que a interacao visual completa do mapa seja validada
  manualmente.
- RNF09. O componente de mapa deve ser reaproveitavel ou compartilhado entre o
  picker de cadastro e a visualizacao somente leitura para evitar duplicacao de
  configuracao de tiles, zoom inicial e marcador.
- RNF10. A pagina de reviews deve preservar a hierarquia atual: dados do lugar,
  resumo de reviews e lista de reviews devem continuar escaneaveis em mobile e
  web.
- RNF11. A busca por endereco deve ser acionada por botao, nao por chamadas a
  cada tecla digitada, para reduzir trafego e respeitar limites do provedor de
  geocoding no MVP.
- RNF12. A integracao com provedor de geocoding deve ficar isolada por uma
  interface/adaptador, evitando acoplamento direto da UI a um provedor
  especifico.
- RNF13. A UI deve deixar claro que a localizacao sugerida precisa ser
  conferida pelo usuario antes de salvar.

## Decisoes de produto

- A localizacao sera opcional no MVP.
- O ponto marcado representara a localizacao aproximada do estabelecimento.
- O usuario pode corrigir a localizacao substituindo o ponto antes do envio.
- O fluxo principal sera: preencher endereco, clicar em "Localizar pelo
  endereco", conferir o marcador no mapa e ajustar se necessario.
- A busca por endereco sera manual por botao no MVP, nao autocomplete continuo.
- A localizacao atual do dispositivo pode ser considerada melhoria futura; esta
  spec nao exige permissao de GPS.
- A pagina de reviews usara a localizacao apenas para visualizacao do ponto do
  estabelecimento, sem permitir edicao nesse contexto.
- O resultado de geocoding e uma sugestao para facilitar o cadastro, nao uma
  verificacao oficial de existencia do estabelecimento.

## Decisoes de contrato

O contrato de criacao de local deve aceitar coordenadas opcionais:

```json
{
  "name": "Cafe Exemplo",
  "category_id": "cat_123",
  "subcategory_id": "sub_456",
  "instagram_url": "https://www.instagram.com/cafeexemplo",
  "latitude": -23.55052,
  "longitude": -46.63331
}
```

Os contratos de resposta devem devolver as mesmas coordenadas quando existirem:

```json
{
  "id": "place_123",
  "name": "Cafe Exemplo",
  "latitude": -23.55052,
  "longitude": -46.63331
}
```

- `latitude` e `longitude` devem ser `null` quando nao houver localizacao.
- Se uma coordenada for informada, a outra tambem deve ser obrigatoria.
- O backend e a fonte de verdade para validacao dos ranges.

## Criterios de aceite

- CA01. A tela de cadastro exibe uma secao de mapa para marcar localizacao.
- CA02. Ao selecionar um ponto, a tela mostra marcador e estado de localizacao
  definida.
- CA03. Ao selecionar outro ponto, a localizacao anterior e substituida.
- CA04. Ao limpar a localizacao, o formulario volta ao estado sem coordenadas.
- CA05. Criar local sem coordenadas continua retornando sucesso.
- CA06. Criar local com latitude e longitude validas retorna sucesso e devolve
  as coordenadas.
- CA07. Criar local com latitude invalida retorna erro de validacao.
- CA08. Criar local com longitude invalida retorna erro de validacao.
- CA09. Criar local com apenas latitude ou apenas longitude retorna erro de
  validacao.
- CA10. `GET /places` e `GET /places/{place_id}` retornam `latitude` e
  `longitude`.
- CA11. A pagina de reviews exibe um mapa no container de dados do lugar quando
  o detalhe do local tiver coordenadas.
- CA12. O mapa da pagina de reviews exibe um marcador no ponto persistido.
- CA13. A pagina de reviews nao exibe mapa quando o local nao tiver
  coordenadas.
- CA14. O mapa da pagina de reviews e somente leitura e nao altera o estado do
  formulario de cadastro nem dispara envio ao backend.
- CA15. Os testes backend cobrem coordenadas validas, ausentes, parciais e fora
  de range.
- CA16. Os testes frontend cobrem modelos, envio do payload, estados visiveis do
  seletor de localizacao e visualizacao do mapa no container de dados da pagina
  de reviews.
- CA17. Ao preencher endereco e acionar "Localizar pelo endereco", a UI busca
  sugestoes de coordenadas e posiciona o marcador quando ha resultado.
- CA18. A busca por endereco exibe carregamento enquanto esta em andamento.
- CA19. Quando a busca nao encontra resultado, a UI exibe mensagem clara e
  permite marcar manualmente no mapa.
- CA20. Quando houver multiplas sugestoes, o usuario consegue escolher uma
  sugestao ou ajustar manualmente o marcador depois da selecao.
- CA21. O usuario consegue mover/substituir o marcador sugerido pela busca antes
  de salvar.
- CA22. O formulario continua permitindo salvar sem coordenadas quando a busca
  nao for usada ou falhar.
- CA23. Os testes cobrem a montagem da consulta a partir dos campos de endereco,
  o estado de sucesso da busca, o estado sem resultados e o envio das
  coordenadas ajustadas.

## Dependencias e restricoes

- Depende do modulo `places` e da autenticacao JWT existentes.
- Depende da tela protegida de cadastro de local existente.
- A persistencia deve permanecer compativel com SQLite no MVP.
- A solucao recomendada para o mapa no MVP e `flutter_map` com tiles
  OpenStreetMap.
- A solucao de geocoding do MVP deve evitar dependencia obrigatoria de chave
  paga. Candidatos tecnicos: Nominatim/OpenStreetMap ou Photon, respeitando
  politicas de uso e limites do provedor.
- Se houver restricao de CORS, limites ou necessidade de trocar provedor, a
  busca por endereco deve passar por um adaptador/proxy no backend em vez de
  ficar acoplada diretamente ao Flutter.
- O uso de tiles publicos deve respeitar limites e politicas do provedor; caso
  o app cresca, deve ser avaliado um provedor dedicado de tiles.
