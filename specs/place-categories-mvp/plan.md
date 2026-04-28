# Plan: place-categories-mvp

## Resumo tecnico

Adicionar uma taxonomia persistida de categorias e subcategorias ao modulo de
locais, preservando a arquitetura hexagonal e evitando texto livre no cadastro
de locais. A entrega se concentra em backend e contratos; o frontend apenas
consome os endpoints de leitura e envia ids no formulario.

## Backend

- criar entidades de dominio `Category` e `Subcategory` no contexto de
  `places`;
- introduzir ports `CategoryRepository` e `SubcategoryRepository`;
- ajustar casos de uso de criacao e edicao de local para exigir
  `category_id` e `subcategory_id`;
- validar pertencimento entre categoria e subcategoria na camada de
  application;
- expor endpoints de leitura para categorias ativas e subcategorias filtradas;
- atualizar respostas de locais para incluir classificacao resolvida.

## Frontend

- ajustar formulario de local para carregar categorias ativas;
- habilitar subcategoria apenas apos categoria selecionada;
- enviar ids ao backend no cadastro/edicao;
- refletir erros de combinacao invalida ou campos obrigatorios.

## Dados e contratos

- criar tabelas `categories` e `subcategories`;
- alterar `places` com `category_id` e `subcategory_id`;
- adicionar seed inicial com a taxonomia gastronomica oficial;
- manter contratos simples com ids e objetos resolvidos de leitura.

## Testes

- testes unitarios para regras de pertencimento categoria/subcategoria;
- testes de casos de uso para criacao/edicao de local com validacoes;
- testes de integracao para endpoints `GET /categories` e
  `GET /categories/{category_id}/subcategories`;
- testes de integracao para cadastro de local com classificacao valida e
  invalida;
- testes de frontend para dropdown dependente, se a implementacao entrar na
  mesma entrega.

## Riscos

- Risco: dados legados em `places` impedirem `NOT NULL` imediato.
  Mitigacao: planejar migration em duas etapas ou backfill controlado.
- Risco: taxonomia ficar codificada em enums espalhados.
  Mitigacao: manter seed como fonte editorial e repositorios como fonte de
  leitura dinamica.
- Risco: frontend confiar apenas no filtro dependente.
  Mitigacao: validar pertencimento no backend em todos os fluxos de escrita.
