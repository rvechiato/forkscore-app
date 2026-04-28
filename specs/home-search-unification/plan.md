# Plan: home-search-unification

## Resumo tecnico

A abordagem e transformar a home autenticada no container principal da
experiencia de descoberta de lugares do MVP. Em vez de manter a busca como
pagina dedicada, a implementacao deve reutilizar o que ja existe em `places`
para compor a home com saudacao, busca, lista e um placeholder de favoritos,
ajustando a navegacao para refletir essa consolidacao.

## Backend

- Nenhum modulo de backend sera alterado.
- Nenhuma regra de dominio, contrato HTTP ou persistencia sera modificada.
- A feature continua consumindo os endpoints de locais ja previstos no MVP.

## Frontend

- Modulos impactados:
  `lib/features/home/`, `lib/features/places/` e `lib/app/navigation/`.
- Home:
  reorganizar a hierarquia visual para exibir saudacao, busca, lista de lugares
  e placeholder de favoritos em uma unica experiencia autenticada.
- Places:
  extrair ou reaproveitar partes da experiencia atual de busca/lista para uso
  dentro da home, evitando duplicacao de estado e UI onde fizer sentido.
- Navegacao:
  manter `AppRoutes.home` como destino principal apos login;
  revisar o papel de `AppRoutes.places` no MVP para que a pesquisa nao dependa
  mais dele como fluxo principal;
  preservar rotas publicas (`/login`, `/register`) e rotas protegidas sob o
  guard atual.
- Cadastro de local:
  manter o acesso ao fluxo de criacao de local a partir da area autenticada,
  conectado ao contexto da home unificada.

## Dados e contratos

- Nenhuma entidade ou contrato novo sera criado.
- A home continuara consumindo a listagem e o detalhe de locais ja disponiveis
  via repositorio de `places`.
- A mudanca e apenas de composicao de fluxo, layout e navegacao no frontend.

## Testes

- Atualizar testes de widget que hoje assumem a separacao entre home e pesquisa.
- Cobrir a renderizacao da nova home com busca e lista de lugares.
- Cobrir a navegacao pos-login e garantir que logout e guard autenticado
  continuam funcionando.

## Riscos

- Risco: duplicar logica de busca e detalhe entre `home` e `places`.
  Mitigacao: extrair widgets/controladores reaproveitaveis antes de mover UI.
- Risco: manter referencias antigas a `/places` e gerar UX inconsistente.
  Mitigacao: revisar atalhos, testes e rotas nomeadas impactadas pela
  consolidacao.
- Risco: a home crescer de forma desorganizada com a nova responsabilidade.
  Mitigacao: separar blocos visuais por secao e deixar o placeholder de
  favoritos claramente delimitado para evolucao futura.
