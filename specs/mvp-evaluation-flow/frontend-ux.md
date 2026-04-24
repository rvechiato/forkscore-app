# Frontend UX: mvp-evaluation-flow

## Objetivo

Definir o fluxo de frontend e UX do MVP do ForkScore para orientar a
implementacao das features Flutter sem entrar em layout visual detalhado nesta
etapa.

O foco deste documento e garantir que autenticacao, perfil, cadastro de locais
e avaliacao gastronomica funcionem como uma jornada simples, clara e coerente
em web e mobile.

## Principios de UX do MVP

- concluir uma avaliacao com seguranca e sem ambiguidade;
- reduzir friccao para cadastrar local e avaliar logo apos a visita;
- deixar as validacoes claras antes do envio;
- priorizar legibilidade e progresso visivel em vez de densidade de informacao;
- manter navegacao curta para as acoes principais do MVP.

## 1. Mapa de telas do MVP

### Fluxo publico

- Splash de inicializacao
- Boas-vindas / entrada
- Login
- Cadastro

### Fluxo autenticado principal

- Home autenticada
- Lista de locais
- Detalhe do local
- Nova avaliacao
- Confirmacao de avaliacao enviada
- Cadastro de local
- Perfil
- Edicao de perfil

### Relacao entre telas

- `Splash` decide entre fluxo publico e autenticado.
- `Boas-vindas` leva para `Login` ou `Cadastro`.
- `Home autenticada` funciona como ponto de entrada do MVP apos login.
- `Lista de locais` e `Cadastro de local` servem como portas para iniciar uma
  avaliacao.
- `Detalhe do local` contextualiza o estabelecimento antes da avaliacao.
- `Nova avaliacao` concentra os quatro criterios e a recomendacao final.
- `Confirmacao de avaliacao enviada` fecha a jornada e devolve o usuario ao
  detalhe ou a lista de locais.
- `Perfil` e `Edicao de perfil` ficam acessiveis pela area autenticada.

## 2. Fluxo de navegacao entre telas

### Fluxo-base

1. Splash
2. Boas-vindas
3. Login ou Cadastro
4. Home autenticada

### Fluxo de avaliacao por local existente

1. Home autenticada
2. Lista de locais
3. Detalhe do local
4. Nova avaliacao
5. Confirmacao de avaliacao enviada
6. Volta para Detalhe do local ou Lista de locais

### Fluxo de avaliacao criando um novo local

1. Home autenticada
2. Cadastro de local
3. Detalhe do local recem-criado
4. Nova avaliacao
5. Confirmacao de avaliacao enviada

### Fluxo de perfil

1. Home autenticada
2. Perfil
3. Edicao de perfil
4. Perfil atualizado

### Navegacao sugerida do shell autenticado

- App bar com titulo da tela e atalho para perfil
- Navegacao principal por bottom navigation no mobile
- Navegacao principal por navigation rail ou menu lateral compacto na web
- Itens principais: `Inicio`, `Locais`, `Cadastrar local`, `Perfil`

## 3. Jornadas do usuario

### Jornada 1: entrar e entender o produto

- Usuario abre o app e entende em poucos segundos que o ForkScore serve para
  registrar avaliacoes gastronomicas e recomendacoes.
- Usuario escolhe entre entrar ou criar conta.
- Apos autenticar, chega em uma home objetiva com dois CTAs principais:
  `Avaliar um local` e `Cadastrar local`.

### Jornada 2: avaliar um local ja cadastrado

- Usuario autenticado acessa a lista de locais.
- Usuario encontra um local por rolagem simples ou lista recente.
- Usuario abre o detalhe para confirmar nome e endereco.
- Usuario inicia a avaliacao.
- Usuario preenche os quatro criterios com nota e comentario.
- Se alguma nota ficar abaixo de 3, o app exige justificativa naquele criterio.
- Usuario escolhe se recomenda ou nao o local.
- Usuario envia e recebe confirmacao clara de sucesso.

### Jornada 3: cadastrar e avaliar um novo local

- Usuario autenticado nao encontra o local desejado.
- Usuario acessa `Cadastrar local`.
- Usuario preenche os dados minimos do endereco.
- Apos salvar, o app mostra sucesso e leva direto ao detalhe do local.
- O proximo passo sugerido e `Fazer primeira avaliacao`.

### Jornada 4: revisar e editar perfil

- Usuario acessa `Perfil`.
- Usuario visualiza nome, data de nascimento, idade calculada e email.
- Usuario escolhe editar dados.
- Apos salvar, o app confirma a atualizacao e mostra os novos dados.

## 4. Campos minimos de cada tela

### Splash de inicializacao

- logo/nome do produto
- indicador de carregamento
- verificacao de sessao

### Boas-vindas / entrada

- mensagem curta de proposta de valor
- botao `Entrar`
- botao `Criar conta`

### Login

- email
- senha
- botao `Entrar`
- link para `Criar conta`
- estado de erro de credenciais

### Cadastro

- nome
- data de nascimento
- email
- senha
- confirmacao de senha
- botao `Criar conta`
- link para `Entrar`

### Home autenticada

- saudacao simples com nome do usuario
- CTA `Avaliar um local`
- CTA `Cadastrar local`
- resumo curto do que pode ser feito no app
- acesso para lista de locais e perfil

### Lista de locais

- titulo da tela
- lista de cards de locais
- nome do local
- bairro e cidade
- indicador de quem cadastrou opcional em texto secundario
- botao flutuante ou CTA principal `Cadastrar local`
- estado vazio com CTA para cadastrar o primeiro local

### Detalhe do local

- nome do local
- rua, numero, bairro e cidade
- informacao de autoria do cadastro
- botao `Avaliar este local`
- bloco opcional com status como `Ainda sem avaliacoes` no MVP

### Cadastro de local

- nome
- rua
- numero
- bairro
- cidade
- botao `Salvar local`
- feedback de sucesso e erro

### Nova avaliacao

- identificacao do local avaliado
- quatro secoes fixas: `Sabor`, `Atendimento`, `Opcoes`, `Infraestrutura`
- em cada secao: nota por estrelas de 1 a 5, comentario obrigatorio e
  justificativa obrigatoria apenas se nota < 3
- campo adicional `Custo-beneficio` com rating de 1 a 5
- campo final `Voce recomenda este local?`
- opcao `Sim, recomendaria`
- opcao `Nao recomendaria`
- botao `Enviar avaliacao`

### Confirmacao de avaliacao enviada

- mensagem de sucesso
- nome do local avaliado
- resumo da recomendacao final
- botao `Voltar ao local`
- botao `Ver outros locais`

### Perfil

- nome
- data de nascimento
- idade calculada
- email
- botao `Editar perfil`
- botao `Sair`

### Edicao de perfil

- nome
- data de nascimento
- email
- botao `Salvar alteracoes`
- opcao de cancelar/voltar

## 5. Componentes compartilhados sugeridos

- `AppShell`: estrutura base da area autenticada com navegacao e app bar
- `PrimaryButton`: CTA principal do app
- `SecondaryButton`: CTA secundario
- `ForkScoreTextField`: campo padronizado com label, ajuda e erro
- `ForkScoreFormSection`: agrupador visual para blocos de formulario
- `PlaceCard`: card resumido de local para listagens
- `AddressSummary`: resumo reutilizavel de endereco
- `EmptyStateCard`: estado vazio com icone, mensagem e CTA
- `InlineErrorMessage`: erro proximo ao campo ou secao
- `FullScreenErrorState`: erro de carregamento com acao de tentar novamente
- `LoadingOverlay` ou `PrimaryButtonLoading`: feedback durante submit
- `StarRatingInput`: seletor de 1 a 5 estrelas
- `CriterionReviewCard`: card de criterio com nota, comentario e justificativa
- `RecommendationChoice`: seletor binario para recomendacao final
- `SuccessFeedbackSheet` ou `SuccessStateCard`: feedback de sucesso apos acoes

## 6. Estados de erro, loading e sucesso

### Estados globais

- splash carregando sessao
- sessao expirada com redirecionamento para login
- indisponibilidade de rede com mensagem simples e retry

### Login e cadastro

- loading no botao principal durante autenticacao
- erro de credenciais invalidas no login
- erro de email ja cadastrado no cadastro
- erro de validacao local para campos vazios ou senha inconsistente
- sucesso com redirecionamento automatico para home autenticada

### Lista e detalhe de locais

- loading inicial com skeleton ou placeholders simples
- estado vazio quando nao houver locais cadastrados
- erro de carregamento com CTA `Tentar novamente`
- sucesso silencioso ao recarregar a lista

### Cadastro de local

- loading no submit
- erro por campos obrigatorios ausentes
- erro de falha no servidor ao salvar
- sucesso com mensagem clara e redirecionamento para detalhe do local

### Nova avaliacao

- loading no submit
- validacao inline por criterio incompleto
- erro se faltar comentario em qualquer criterio
- erro se nota < 3 sem justificativa
- erro se recomendacao final nao for selecionada
- erro de falha no envio com preservacao dos dados digitados
- sucesso com tela dedicada ou sheet de confirmacao

### Perfil

- loading ao buscar perfil
- erro ao carregar perfil com retry
- loading ao salvar alteracoes
- sucesso com toast/snackbar curto e dados atualizados

## 7. Recomendacoes de UX para o fluxo de avaliacao

### Estrutura do formulario

- manter os quatro criterios em cards independentes e sempre na mesma ordem;
- mostrar progresso visivel, por exemplo `2 de 4 criterios preenchidos`;
- evitar tela longa demais usando secoes claras e espacamento consistente;
- manter o CTA final fixo ou facilmente acessivel no mobile.

### Entrada de nota e comentario

- permitir selecionar a nota com toque direto nas estrelas;
- atualizar o rotulo da nota em tempo real, como `2 estrelas` ou `5 estrelas`;
- exibir o comentario logo abaixo da nota para reforcar a relacao entre os dois;
- revelar a justificativa apenas quando a nota ficar abaixo de 3.

### Validacoes

- validar antes do submit e tambem durante o preenchimento;
- usar mensagens especificas por criterio, evitando erro generico no topo;
- se houver erro no envio, manter o scroll na primeira secao invalida;
- nunca limpar o formulario apos falha de rede ou erro de API.

### Clareza da recomendacao final

- separar visualmente a recomendacao final dos criterios;
- apresentar a pergunta em linguagem direta: `Voce recomenda este local?`;
- impedir envio sem escolha explicita para evitar ambiguidade.

### Confianca e ritmo

- mostrar o nome do local em toda a tela de avaliacao para evitar erro de
  contexto;
- usar microcopys que reforcem honestidade e utilidade da avaliacao;
- apos sucesso, confirmar que a avaliacao foi registrada e informar qual foi a
  recomendacao escolhida;
- oferecer caminho claro para continuar: voltar ao local ou avaliar outro.

## Diretrizes de implementacao futura no Flutter

- organizar as features em `auth`, `profile`, `places` e `reviews`;
- manter o shell autenticado em `lib/app/` e os componentes reutilizaveis em
  `lib/shared/`;
- separar estados de tela de chamadas HTTP diretas para facilitar testes;
- priorizar responsividade simples para mobile e web antes de refinamentos
  visuais avancados.
