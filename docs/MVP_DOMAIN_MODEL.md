# Modelo de Dominio do MVP

Este documento consolida a modelagem de dominio e de dados do MVP principal do
ForkScore. Ele deve servir como referencia para novas specs, contratos de API,
casos de uso, persistencia e evolucoes futuras do produto.

## Objetivo

O ForkScore permite que uma pessoa autenticada:

- mantenha um perfil basico;
- cadastre um local;
- registre avaliacoes gastronomicas sobre o local;
- informe se recomenda ou nao recomenda o local ao final.

## Entidades principais

### User

Representa a identidade autenticada da pessoa usuaria.

Atributos minimos:

- `id`
- `email`
- `password_hash`
- `is_active`
- `created_at`
- `updated_at`

### Profile

Representa os dados basicos de perfil exibidos e editados no produto.

Atributos minimos:

- `user_id`
- `name`
- `birth_date`
- `created_at`
- `updated_at`

Notas:

- `email` permanece como atributo canonico de `User`.
- A idade e derivada de `birth_date` no momento da consulta, sem persistencia
  como campo principal.

### Place

Representa um restaurante, cafeteria ou estabelecimento similar cadastrado no
aplicativo.

Atributos minimos:

- `id`
- `name`
- `street`
- `number`
- `neighborhood`
- `city`
- `created_by_user_id`
- `created_at`
- `updated_at`

### Review

Representa a avaliacao de um usuario sobre um local em um momento especifico,
incluindo historico de revisitas.

Atributos minimos:

- `id`
- `place_id`
- `author_user_id`
- `recommended`
- `cost_benefit_rating`
- `created_at`
- `updated_at`

Criticos avaliativos obrigatorios:

- `taste`
- `service`
- `options`
- `infrastructure`

Cada criterio obrigatorio deve registrar:

- `rating`
- `comment`
- `justification_if_below_3`

## Relacionamentos

- `User` 1:1 `Profile`
- `User` 1:N `Place`
- `Place` N:1 `User` como autor do cadastro
- `User` 1:N `Review`
- `Place` 1:N `Review`

Regra importante:

- o mesmo usuario pode criar multiplas `Review`s para o mesmo `Place`, pois o
  dominio aceita historico de revisitas.

## Regras de negocio

### Autenticacao e autoria

- apenas usuario autenticado pode cadastrar um local;
- todo `Place` deve registrar quem o cadastrou;
- apenas usuario autenticado pode criar uma `Review`;
- toda `Review` deve estar vinculada a um unico `User` e a um unico `Place`.

### Perfil

- `email` deve ser unico no sistema;
- `name` deve ser obrigatorio;
- `birth_date` deve ser obrigatoria;
- a idade exibida no produto deve ser calculada a partir de `birth_date`.

### Cadastro de locais

- `Place` deve exigir `name`, `street`, `number`, `neighborhood` e `city`;
- o dominio do MVP ainda nao bloqueia duplicidade de locais, mas futuras
  features podem adicionar deteccao de duplicidade por nome e endereco.

### Avaliacao gastronomica

- uma `Review` deve conter exatamente os quatro criterios qualitativos do MVP:
  `taste`, `service`, `options` e `infrastructure`;
- `options` significa exclusivamente variedade do cardapio;
- todos os ratings do MVP usam escala inteira de `1` a `5`;
- cada um dos quatro criterios qualitativos exige comentario obrigatorio;
- quando a nota de um criterio qualitativo for menor que `3`, a justificativa
  separada e obrigatoria;
- `cost_benefit_rating` e obrigatorio e usa a mesma escala de `1` a `5`;
- `cost_benefit_rating` nao possui comentario obrigatorio no MVP;
- `recommended` e obrigatorio e representa a decisao final explicita da pessoa
  usuaria;
- `recommended` nao e derivado automaticamente das notas.

## Agregados recomendados

### User

Aggregate root do contexto de identidade e perfil.

### Place

Aggregate root do contexto de cadastro de locais.

### Review

Aggregate root do contexto de avaliacao.

## Value objects sugeridos

- `Email`
- `BirthDate`
- `Address`
- `Rating`
- `Recommendation`
- `CriterionCode`
- `CriterionReview`

### Address

Compoe o endereco simplificado do local:

- `street`
- `number`
- `neighborhood`
- `city`

### Rating

Representa nota inteira valida no intervalo `1..5`.

### Recommendation

Representa a decisao final da avaliacao:

- `recommended`
- `not_recommended`

### CriterionCode

Enum fixo do MVP para criterios qualitativos:

- `taste`
- `service`
- `options`
- `infrastructure`

### CriterionReview

Value object recomendado para cada criterio qualitativo da review.

Campos sugeridos:

- `code`
- `rating`
- `comment`
- `justification`

Observacao:

- `cost_benefit_rating` deve permanecer fora de `CriterionReview`, pois possui
  comportamento diferente no MVP e nao exige comentario obrigatorio.

## Decisoes de modelagem fechadas

- `recommended` deve ser mantido como decisao final explicita;
- justificativa para nota menor que `3` deve ser separada do comentario;
- o dominio aceita multiplas avaliacoes por usuario no mesmo local;
- a idade deve ser derivada de `birth_date`;
- `options` significa apenas variedade do cardapio;
- `cost_benefit_rating` faz parte da `Review` como campo proprio.

## Uso em futuras features

Novas features devem reutilizar esta base antes de introduzir novos campos ou
novos comportamentos, especialmente em:

- contratos de API;
- modelos SQLAlchemy e migracoes;
- DTOs de entrada e saida;
- regras de validacao no dominio;
- telas e formularios do frontend;
- agregacoes futuras, como medias por local ou historico do usuario.
