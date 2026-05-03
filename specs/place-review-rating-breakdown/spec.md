# Spec: place-review-rating-breakdown

## Contexto

A pagina dedicada de reviews de um local ja concentra os dados do lugar, o
resumo de reviews e a leitura das avaliacoes. No container de "review do local",
o bloco atual ainda prioriza "Comentarios recentes", mostrando alguns itens de
review em formato textual.

Para a decisao rapida de quem esta consultando um local, esse espaco deve
entregar primeiro uma leitura agregada e escaneavel da qualidade do local. A
pessoa deve conseguir ver, de cara, como o local performa em cada criterio de
avaliacao e qual a divisao entre quem recomenda e quem nao recomenda.

## Objetivo

Substituir o box de "Comentarios recentes" no container de review do local por
um painel de rating por criterio, com estrelas no modelo convencional de
marketplaces, seguido de uma linha unica com a proporcao de recomendacoes e nao
recomendacoes.

## Escopo

- Atualizar o container de review do local na pagina dedicada do lugar.
- Remover a exibicao de "Comentarios recentes" desse container.
- Exibir uma lista com todos os criterios avaliaveis do MVP.
- Para cada criterio, exibir a media agregada e cinco estrelas.
- Pintar em amarelo as estrelas correspondentes ao score medio exibido e em
  cinza claro as estrelas restantes.
- Exibir abaixo da lista de criterios uma barra horizontal unica de
  recomendacao, com lado verde para recomendado e lado vermelho para nao
  recomendado.
- Exibir a porcentagem de recomendado e nao recomendado na mesma linha da barra
  ou imediatamente associada a ela.
- Manter estados de loading, vazio e erro do bloco de reviews.
- Ajustar contratos, modelos e testes necessarios para entregar os agregados.

## Fora de escopo

- Remover a lista completa de reviews da pagina dedicada, caso ela exista fora
  do container de resumo.
- Criar ranking global de locais.
- Criar filtros por criterio ou ordenacao por score.
- Alterar o fluxo de criacao de review.
- Alterar a escala de avaliacao do MVP.
- Alterar a taxonomia dos criterios de avaliacao.
- Criar comentarios gerais, curtidas, respostas ou moderacao de reviews.

## Requisitos funcionais

- RF01. O container de review do local deve deixar de exibir a secao
  "Comentarios recentes".
- RF02. O container deve exibir uma secao de rating por criterio antes de
  qualquer conteudo textual de reviews.
- RF03. A lista deve conter todos os criterios avaliaveis do MVP na ordem:
  `Sabor`, `Atendimento`, `Opcoes`, `Infraestrutura` e `Custo-beneficio`.
- RF04. Cada linha de criterio deve exibir o nome do criterio, a media numerica
  daquele criterio e cinco estrelas.
- RF05. Cada linha deve acender em amarelo as estrelas correspondentes ao score
  medio arredondado para exibicao e deixar as demais em cinza claro.
- RF06. Quando um criterio ainda nao tiver reviews, a linha deve exibir estado
  claro sem estrelas amarelas e media `-`.
- RF07. A secao de recomendacao deve exibir, em uma unica linha, a proporcao de
  reviews `recommended` e `not_recommended`.
- RF08. A proporcao de `recommended` deve usar verde e a proporcao de
  `not_recommended` deve usar vermelho.
- RF09. A soma visual da barra de recomendacao deve representar 100% das reviews
  existentes do local.
- RF10. Quando nao houver reviews, o container deve manter estado vazio claro e
  nao deve mostrar porcentagens artificiais.
- RF11. O score geral do local e a quantidade total de reviews podem continuar
  aparecendo no topo do container, desde que a hierarquia principal passe a ser
  a visualizacao rapida por criterio.
- RF12. A pagina deve preservar o CTA para avaliar o local.

## Requisitos nao funcionais

- RNF01. A implementacao deve preservar a organizacao atual do frontend em
  `lib/app`, `lib/features` e `lib/shared`.
- RNF02. Caso o backend seja alterado, a arquitetura hexagonal deve ser
  preservada em `domain`, `application`, `infra` e `presentation`.
- RNF03. A UI deve funcionar bem em mobile e web, mantendo leitura rapida e sem
  sobreposicao de textos, estrelas ou percentuais.
- RNF04. As estrelas devem usar semantica acessivel, com texto compreensivel
  para leitores de tela.
- RNF05. O frontend nao deve inferir medias por criterio a partir de comentarios
  recentes limitados; os agregados devem vir de um contrato de resumo ou de um
  read model adequado.
- RNF06. O contrato de leitura deve manter o estado sem reviews como resposta de
  sucesso, nao erro tecnico.
- RNF07. A agregacao deve usar as reviews persistidas como fonte de verdade e
  permanecer compativel com SQLite no MVP.

## Decisoes de contrato

O contrato atual de `GET /places/{place_id}/reviews/summary` retorna
`total_reviews`, `average_rating` e `recent_reviews`. Para a nova visualizacao,
ele deve ser expandido ou substituido por um read model equivalente com:

```json
{
  "place_id": "plc_123",
  "total_reviews": 12,
  "average_rating": 4.2,
  "criteria_ratings": [
    {
      "code": "taste",
      "label": "Sabor",
      "average_rating": 4.6,
      "total_reviews": 12
    },
    {
      "code": "service",
      "label": "Atendimento",
      "average_rating": 4.1,
      "total_reviews": 12
    },
    {
      "code": "options",
      "label": "Opcoes",
      "average_rating": 3.8,
      "total_reviews": 12
    },
    {
      "code": "infrastructure",
      "label": "Infraestrutura",
      "average_rating": 4.0,
      "total_reviews": 12
    },
    {
      "code": "cost_benefit",
      "label": "Custo-beneficio",
      "average_rating": 3.7,
      "total_reviews": 12
    }
  ],
  "recommendation_summary": {
    "recommended_count": 9,
    "not_recommended_count": 3,
    "recommended_percentage": 75,
    "not_recommended_percentage": 25
  }
}
```

- `criteria_ratings` deve sempre respeitar a ordem visual definida no RF03.
- `cost_benefit` representa o campo proprio `cost_benefit_rating` da review,
  sem transformar a modelagem de dominio em criterio qualitativo com comentario.
- `average_rating` dos criterios deve ser `null` quando `total_reviews = 0`.
- Percentuais devem ser inteiros arredondados para exibicao, garantindo que a
  soma exibida seja 100 quando houver reviews.
- O backend pode manter `recent_reviews` por compatibilidade temporaria, mas o
  frontend desta feature nao deve usa-lo no container de resumo.

## Criterios de aceite

- CA01. O container de review do local nao mostra mais o titulo
  "Comentarios recentes".
- CA02. O container mostra uma linha para cada criterio: Sabor, Atendimento,
  Opcoes, Infraestrutura e Custo-beneficio.
- CA03. Cada linha mostra cinco estrelas, com estrelas amarelas para o score
  medio e cinza claro para o restante.
- CA04. Cada criterio mostra sua media numerica quando houver reviews.
- CA05. Um local sem reviews mostra estado vazio claro, sem medias falsas nem
  porcentagens falsas.
- CA06. A barra de recomendacao aparece abaixo dos ratings por criterio quando
  houver reviews.
- CA07. A barra usa verde para recomendado e vermelho para nao recomendado.
- CA08. Os percentuais exibidos batem com os contadores de reviews recomendadas
  e nao recomendadas.
- CA09. O frontend nao calcula rating por criterio a partir de uma lista curta
  de comentarios recentes.
- CA10. Os testes frontend cobrem renderizacao de criterios, cores das estrelas,
  estado vazio e barra de recomendacao.
- CA11. Se o contrato de resumo for alterado, os testes backend cobrem medias
  por criterio, custo-beneficio e percentuais de recomendacao.

## Dependencias e restricoes

- Depende de `specs/place-reviews-page-mvp/` para a pagina dedicada do local.
- Depende de `specs/review-read-model-mvp/` para a semantica do resumo de
  reviews por local.
- Depende de `specs/reviews-create-mvp/` para a modelagem dos quatro criterios,
  `cost_benefit_rating` e recomendacao final.
- O dominio consolidado em `docs/MVP_DOMAIN_MODEL.md` continua sendo a fonte
  canonica para criterios e recomendacao.
- A feature deve ser refinada antes da implementacao para confirmar a regra
  visual exata de arredondamento das estrelas quando a media for decimal.
