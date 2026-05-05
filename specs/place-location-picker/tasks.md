# Tasks: place-location-picker

## Preparacao

- [x] Revisar `spec.md` e `plan.md`.
- [x] Confirmar pacote de mapa para o MVP (`flutter_map` + OpenStreetMap).
- [x] Identificar DTOs, entidade, models SQLAlchemy e testes atuais de
      `places`.
- [x] Identificar controller/formulario atual de cadastro de local no frontend.
- [x] Identificar o container de dados do lugar na pagina dedicada de reviews.

## Backend

- [x] Adicionar `latitude` e `longitude` opcionais na entidade `Place`.
- [x] Expandir DTO de criacao de local com coordenadas opcionais.
- [x] Validar range de latitude entre `-90` e `90`.
- [x] Validar range de longitude entre `-180` e `180`.
- [x] Rejeitar payload parcial com apenas uma coordenada.
- [x] Expandir DTOs de resposta de criacao, listagem e detalhe.
- [x] Adicionar colunas nullable no model SQLAlchemy de places.
- [x] Mapear coordenadas no repositorio SQLAlchemy de places.
- [x] Garantir compatibilidade com locais existentes sem coordenadas.
- [x] Atualizar testes backend para criacao sem coordenadas.
- [x] Atualizar testes backend para criacao com coordenadas validas.
- [x] Adicionar testes backend para coordenadas fora de range.
- [x] Adicionar testes backend para payload parcial.
- [x] Adicionar testes backend para retorno em listagem e detalhe.

## Frontend

- [x] Adicionar dependencia de mapa ao `pubspec.yaml`.
- [x] Atualizar modelos `PlaceSummary` e `PlaceDetail` com coordenadas
      opcionais.
- [x] Atualizar request/model de criacao de local com coordenadas opcionais.
- [x] Atualizar repositorio API de places para enviar coordenadas quando
      definidas.
- [x] Atualizar mocks de places com coordenadas opcionais.
- [x] Criar widget `PlaceLocationPicker`.
- [x] Extrair componente compartilhado de mapa com marcador para modos
      interativo e somente leitura.
- [x] Exibir estado vazio no picker sem coordenadas marcadas.
- [x] Permitir marcar ponto por clique/toque no mapa.
- [x] Exibir marcador visual no ponto selecionado.
- [x] Permitir substituir o ponto selecionado.
- [x] Permitir limpar a localizacao marcada.
- [x] Integrar o picker ao formulario de cadastro de local.
- [x] Garantir que o formulario envie coordenadas apenas quando ambas existirem.
- [x] Exibir mapa somente leitura no container de dados da pagina de reviews
      quando o local tiver coordenadas.
- [x] Omitir mapa no container de dados da pagina de reviews quando o local nao
      tiver coordenadas.
- [x] Garantir que o mapa da pagina de reviews nao altere estado nem envie
      coordenadas ao backend.
- [x] Atualizar testes de parser dos modelos de places.
- [x] Atualizar testes de serializacao/envio do request de criacao.
- [x] Adicionar testes de widget para estado vazio, estado marcado e limpar
      localizacao.
- [x] Adicionar testes da pagina de reviews para mapa presente com coordenadas.
- [x] Adicionar testes da pagina de reviews para mapa ausente sem coordenadas.
- [x] Verificar responsividade do formulario em mobile e web.
- [x] Verificar responsividade do container de dados da pagina de reviews em
      mobile e web.

## Busca por endereco no mapa

- [x] Decidir provider MVP de geocoding sem chave obrigatoria, considerando
      Nominatim/OpenStreetMap ou Photon.
- [x] Definir se a chamada de geocoding ficara no backend como proxy/adaptador
      ou diretamente no frontend.
- [x] Se a busca ficar no backend, criar porta de aplicacao para sugestoes de
      localizacao por endereco.
- [x] Se a busca ficar no backend, criar adaptador de infraestrutura para o
      provider escolhido.
- [x] Se a busca ficar no backend, expor endpoint de sugestoes de localizacao
      sem persistencia.
- [x] Criar modelo/DTO de sugestao com `label`, `latitude` e `longitude`.
- [x] Criar repositorio/servico frontend para buscar sugestoes pelo endereco.
- [x] Montar consulta usando rua, numero, bairro e cidade do formulario.
- [x] Adicionar botao "Localizar pelo endereco" no `PlaceLocationPicker`.
- [x] Habilitar a busca apenas quando houver dados minimos de endereco.
- [x] Exibir estado de carregamento durante a busca por endereco.
- [x] Centralizar o mapa e marcar o ponto quando houver sugestao unica ou
      confiavel.
- [x] Exibir lista compacta quando houver multiplas sugestoes.
- [x] Permitir selecionar uma sugestao para posicionar o marcador.
- [x] Exibir estado sem resultados quando o endereco nao for encontrado.
- [x] Exibir estado de erro quando a busca falhar.
- [x] Manter a marcacao manual no mapa disponivel mesmo quando a busca falhar.
- [x] Permitir ajustar manualmente o marcador sugerido antes do envio.
- [x] Garantir que limpar localizacao tambem limpe sugestoes/estado da busca.
- [x] Garantir que o cadastro sem coordenadas continue funcionando.
- [x] Atualizar testes de montagem da consulta de endereco.
- [x] Atualizar testes do servico/repositorio de sugestoes.
- [x] Atualizar testes do picker para carregamento, sucesso, multiplas
      sugestoes, sem resultado e erro.
- [x] Atualizar testes do formulario para envio das coordenadas sugeridas e
      ajustadas.
- [ ] Revisar visualmente busca por endereco no cadastro em largura mobile.
- [ ] Revisar visualmente busca por endereco no cadastro em largura desktop/web.

## Documentacao

- [x] Atualizar documentacao de contrato se houver arquivo de contratos
      impactado.
- [x] Registrar a decisao de manter GPS e autocomplete continuo fora do MVP, se
      necessario.

## Validacao

- [x] Rodar `cd backend && .venv/bin/pytest -q`.
- [x] Rodar `cd frontend && flutter analyze`.
- [x] Rodar `cd frontend && flutter test`.
- [x] Revisar visualmente cadastro de local em largura mobile.
- [x] Revisar visualmente cadastro de local em largura desktop/web.
- [x] Revisar visualmente mapa no container de dados da pagina de reviews em
      largura mobile.
- [x] Revisar visualmente mapa no container de dados da pagina de reviews em
      largura desktop/web.
