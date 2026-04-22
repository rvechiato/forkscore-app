# Feature Specification: Sistema Completo de Avaliação de Locais

**Feature Branch**: `002-rating-system-complete`  
**Created**: April 22, 2026  
**Status**: Draft  
**Input**: Aplicativo mobile para avaliação de locais com autenticação, perfil de usuário, cadastro de locais e sistema de avaliação com estrelas (0-5) e comentários obrigatórios para avaliações negativas.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Criar Conta e Fazer Login (Priority: P1)

Um novo usuário precisa se registrar no aplicativo com email e senha, e depois fazer login para acessar todas as funcionalidades. Este é o primeiro ponto de contato com o sistema.

**Why this priority**: Sem autenticação, o sistema não funciona. Este é o requisito fundamental para garantir que cada usuário tenha seu próprio perfil e histórico de avaliações.

**Independent Test**: Pode ser testado completamente criando uma conta nova, fazendo logout, e reacessando com as mesmas credenciais. Entrega valor ao permitir ao usuário acessar o aplicativo.

**Acceptance Scenarios**:

1. **Given** usuário não tem conta, **When** preenche formulário com email e senha, **Then** conta é criada e usuário é automaticamente logado
2. **Given** usuário já tem conta, **When** insere email e senha corretos, **Then** é redirecionado para a tela inicial
3. **Given** usuário insere credenciais incorretas, **When** tenta fazer login, **Then** recebe mensagem de erro clara

---

### User Story 2 - Completar Perfil (Priority: P1)

Após criar a conta, o usuário deve poder completar seu perfil com informações básicas (nome, foto, preferências). Essas informações contextualizam as avaliações do usuário.

**Why this priority**: Perfil completo melhora a experiência e permite que outros usuários conheçam quem está avaliando. Essencial para construir comunidade.

**Independent Test**: Pode ser testado criando conta, preenchendo perfil, e verificando que dados persistem ao retornar ao perfil. Entrega valor ao personalizar a experiência do usuário.

**Acceptance Scenarios**:

1. **Given** usuário novo logado, **When** acessa tela de perfil, **Then** vê formulário para preencher informações pessoais
2. **Given** formulário preenchido, **When** salva alterações, **Then** dados são persistidos
3. **Given** usuário com perfil completo, **When** volta à tela de perfil, **Then** vê suas informações salvas

---

### User Story 3 - Cadastrar Locais para Avaliação (Priority: P1)

O usuário precisa poder adicionar novos locais (restaurantes, bares, serviços) que deseja avaliar. Este é o pré-requisito para o sistema de avaliação.

**Why this priority**: Sem locais registrados, o usuário não pode fazer avaliações. Este é um requisito crítico para o MVP.

**Independent Test**: Pode ser testado adicionando um novo local, vendo-o na lista, e encontrando-o disponível para avaliação. Entrega valor ao permitir começar a avaliar.

**Acceptance Scenarios**:

1. **Given** usuário logado, **When** clica em "Adicionar Local", **Then** formulário de cadastro é exibido
2. **Given** formulário completo com nome e localização, **When** salva, **Then** local é criado e adicionado à lista
3. **Given** local cadastrado, **When** usuário retorna à tela de locais, **Then** novo local é visível na lista

---

### User Story 4 - Avaliar Local com Sistema de Estrelas (Priority: P1)

O usuário deve poder avaliar um local usando um sistema intuitivo de estrelas (0-5) para 2-3 critérios específicos (sabor, atendimento, opções, infraestrutura), de forma lúdica e visual.

**Why this priority**: Este é o valor central do aplicativo. Permite que usuários compartilhem opiniões estruturadas sobre locais.

**Independent Test**: Pode ser testado clicando nas estrelas para cada critério e salvando a avaliação. Avaliação fica visível no perfil do local. Entrega valor ao criar histórico avaliativo do local.

**Acceptance Scenarios**:

1. **Given** usuário selecionou um local, **When** toca na opção "Avaliar", **Then** tela de avaliação com critérios e estrelas é exibida
2. **Given** tela de avaliação aberta, **When** usuário clica nas estrelas para cada critério, **Then** valor (0-5) é registrado visualmente
3. **Given** avaliação incompleta, **When** usuário tenta salvar, **Then** mensagem pede para completar todos os critérios
4. **Given** avaliação completa, **When** clica em salvar, **Then** avaliação é persistida e usuário volta à tela anterior

---

### User Story 5 - Adicionar Comentários em Cada Critério (Priority: P1)

Para cada aspecto avaliado (sabor, atendimento, etc.), o usuário pode adicionar um comentário explicando sua pontuação.

**Why this priority**: Comentários fornecem contexto às avaliações de estrelas, ajudando outros usuários a entender melhor o local.

**Independent Test**: Pode ser testado adicionando comentários em um critério, salvando a avaliação, e vendo o comentário aparecer no perfil do local.

**Acceptance Scenarios**:

1. **Given** usuário na tela de avaliação, **When** clica no campo de comentário de um critério, **Then** teclado aparece para entrada de texto
2. **Given** comentário digitado, **When** usuário salva avaliação, **Then** comentário é armazenado junto com as estrelas
3. **Given** avaliação com comentários, **When** outro usuário visualiza o local, **Then** comentários aparecem junto com as estrelas

---

### User Story 6 - Justificar Avaliações Negativas (Priority: P1)

Se a avaliação for menor que 3 estrelas em qualquer critério, o sistema deve solicitar uma justificativa obrigatória. Isso melhora a qualidade feedback negativo.

**Why this priority**: Evita avaliações negativas superficiais e fornece feedback construtivo aos donos dos locais e outros usuários.

**Independent Test**: Pode ser testado dando 2 estrelas em um critério e verificando que o sistema não permite salvar sem comentário de justificativa.

**Acceptance Scenarios**:

1. **Given** usuário avalia um critério com 0-2 estrelas, **When** tenta salvar, **Then** sistema exige comentário de justificativa
2. **Given** justificativa digitada, **When** usuário salva, **Then** avaliação é registrada com comentário obrigatório
3. **Given** critério com 3+ estrelas, **When** usuário clica salvar, **Then** comentário é opcional

---

### Edge Cases

- O que acontece quando o usuário tenta avaliar um local que foi removido?
- Como o sistema lida com avaliações duplicadas do mesmo usuário para o mesmo local?
- O que ocorre se a conexão cair durante a gravação de uma avaliação?
- Como o sistema garante que comentários vazios não sejam salvos?
- O que acontece quando um usuário tenta acessar o app sem conexão de internet?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Sistema DEVE permitir que novos usuários se registrem com email e senha única
- **FR-002**: Sistema DEVE autenticar usuários com email e senha
- **FR-003**: Sistema DEVE permitir que usuários ressetem senha via email
- **FR-004**: Sistema DEVE permitir que usuários preencham e editem perfil (nome, foto, bio)
- **FR-005**: Usuários DEVEM poder adicionar novos locais com nome, categoria, localização e descrição
- **FR-006**: Sistema DEVE exibir lista de todos os locais cadastrados
- **FR-007**: Usuários DEVEM poder avaliar locais usando sistema de estrelas (0-5 pontos)
- **FR-008**: Sistema DEVE avaliar 2-3 critérios: Sabor/Comida, Atendimento, Opções/Variedade (e opcionalmente Infraestrutura)
- **FR-009**: Para cada critério, DEVE haver campo para comentário opcional
- **FR-010**: Se avaliação em qualquer critério for menor que 3 estrelas, comentário de justificativa DEVE ser obrigatório
- **FR-011**: Sistema DEVE permitir que usuários visualizem todas as suas avaliações anteriores
- **FR-012**: Sistema DEVE exibir todas as avaliações de um local (de todos os usuários)
- **FR-013**: Sistema DEVE calcular e exibir pontuação média de cada local
- **FR-014**: Avaliações DEVEM ser persistidas e recuperáveis após fechamento do app
- **FR-015**: Sistema DEVE validar que campos obrigatórios foram preenchidos antes de salvar

### Key Entities

- **Usuário (User)**: Representa uma pessoa usando o aplicativo. Atributos: ID, email, senha (hasheada), nome, foto, bio, data de criação, data última login
- **Perfil (Profile)**: Dados complementares do usuário. Atributos: ID do usuário, nome completo, foto, biografía, preferências
- **Local (Place)**: Um estabelecimento a ser avaliado. Atributos: ID, nome, categoria, localização/endereço, descrição, data de criação, usuário criador
- **Avaliação (Rating)**: Avaliação de um local por um usuário. Atributos: ID, ID do usuário, ID do local, data, status de conclusão
- **Critério de Avaliação (RatingCriterion)**: Um aspecto de avaliação específico. Atributos: tipo (sabor, atendimento, opções, infraestrutura), pontuação (0-5), comentário
- **Comentário (Comment)**: Feedback textual para um critério. Atributos: texto, comprimento, data de criação

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Usuários conseguem criar conta e fazer login em menos de 2 minutos
- **SC-002**: Usuários conseguem completar primeira avaliação em menos de 3 minutos após login
- **SC-003**: Sistema persiste dados corretamente (99% de taxa de sucesso ao salvar avaliações)
- **SC-004**: Aplicativo funciona em modo offline com sincronização quando reconectar (quando aplicável)
- **SC-005**: 95% de avaliações negativas (< 3 estrelas) incluem comentário de justificativa
- **SC-006**: Página de detalhes de local carrega em menos de 1 segundo
- **SC-007**: Usuários completam perfil em menos de 1 minuto
- **SC-008**: 90% de usuários conseguem fazer primeira avaliação sem precisar de ajuda
- **SC-009**: Aplicativo suporta navegação entre 5+ locais simultaneamente sem performance degradada

## Assumptions

- Usuários têm conexão estável à internet para sincronizar dados (ao menos inicialmente)
- Email será o identificador único para cada usuário (baseado em email e senha)
- Localização de lugares será inserida manualmente por texto de endereço (não via GPS nesta versão)
- Foto de perfil será opcional, com suporte a upload de galeria do telefone
- Máximo de caracteres em comentários é razoável (ex: 500 caracteres)
- Sistema começará suportando apenas português
- Dados de usuário serão armazenados apenas no backend (não localmente no dispositivo) por questões de segurança
- Avaliações não poderão ser deletadas (apenas possível edição)
- Um usuário só pode ter uma avaliação ativa por local (edição sobrescreve anterior)
