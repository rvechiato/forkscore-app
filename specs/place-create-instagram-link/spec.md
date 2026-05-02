# Spec: place-create-instagram-link

## Contexto

A tela protegida de cadastro de estabelecimento hoje exibe a autoria atual para
o usuario antes do envio. A autoria deve continuar sendo registrada pelo backend
a partir da sessao autenticada, mas nao deve aparecer como campo ou informacao
na tela de cadastro.

Tambem existe a necessidade de registrar o link do Instagram do estabelecimento
para enriquecer o cadastro do lugar e permitir uso futuro em telas de detalhe,
descoberta ou avaliacao.

## Objetivo

Ajustar o cadastro de estabelecimento para esconder a autoria na UI e permitir
informar um link opcional do Instagram do lugar, preservando a autoria gravada
no banco de dados pelo backend.

## Escopo

- remover da tela de cadastro a exibicao de autoria atual;
- manter `created_by_user_id` sendo preenchido pelo backend com o usuario
autenticado;
- adicionar um campo opcional de link do Instagram no formulario de cadastro;
- persistir o link do Instagram no cadastro do estabelecimento;
- expor o link nos contratos de detalhe e listagem de lugares;
- atualizar mocks, modelos e testes impactados no frontend e backend.

## Fora de escopo

- login social ou integracao com API do Instagram;
- validacao de existencia real do perfil no Instagram;
- exibicao publica destacada do Instagram em todas as telas de descoberta;
- edicao de estabelecimento existente;
- migracao complexa para bancos nao SQLite neste MVP.

## Requisitos funcionais

- RF01. A tela de cadastro de estabelecimento nao deve apresentar a autoria atual.
- RF02. Ao criar um estabelecimento, o backend deve continuar registrando o autor
do cadastro a partir do token autenticado.
- RF03. O formulario deve conter um campo opcional para o link do Instagram do
estabelecimento.
- RF04. Quando informado, o link do Instagram deve ser enviado ao backend e
persistido em `places.instagram_url`.
- RF05. Quando nao informado, o cadastro deve continuar funcionando e o valor deve
ser tratado como ausente.
- RF06. O backend deve rejeitar links que nao sejam URLs HTTP/HTTPS do dominio
`instagram.com` ou `www.instagram.com`.
- RF07. Os contratos de `POST /places`, `GET /places` e `GET /places/{place_id}`
devem retornar `instagram_url`.

## Requisitos não funcionais

- RNF01. A alteracao deve preservar a arquitetura hexagonal do modulo `places`.
- RNF02. A tela continua protegida e reutiliza a navegacao/autenticacao atual.
- RNF03. O campo de Instagram deve ser opcional para nao bloquear cadastros
legados ou lugares sem perfil conhecido.
- RNF04. A validacao deve ser simples e local, sem dependencias externas.

## Critérios de aceite

- CA01. O texto `Autoria atual` nao aparece mais na tela de cadastro.
- CA02. Um estabelecimento criado sem Instagram continua retornando `201`.
- CA03. Um estabelecimento criado com `https://www.instagram.com/<perfil>` retorna
`201` e devolve o mesmo valor em `instagram_url`.
- CA04. `GET /places` e `GET /places/{place_id}` retornam `instagram_url`.
- CA05. Um link fora do dominio Instagram retorna erro de validacao.
- CA06. Os testes do backend de places e os testes/analisador do frontend cobrem
os comportamentos alterados.

## Dependências e restrições

- Depende do modulo `places` e da autenticacao JWT ja existentes.
- A autoria permanece uma regra de backend e nao deve ser derivada de input do
frontend.
- A coluna nova deve ser nullable para manter compatibilidade com dados atuais.
