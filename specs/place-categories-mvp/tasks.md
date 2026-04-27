# Tasks: place-categories-mvp

## Preparacao

- [ ] revisar spec e plano da taxonomia de locais
- [ ] identificar migrations, modulo `places` e contratos impactados

## Backend

- [ ] criar entidades de dominio `Category` e `Subcategory`
- [ ] criar ports e DTOs de leitura de categorias e subcategorias
- [ ] ajustar casos de uso de criacao/edicao de locais
- [ ] implementar repositorios SQLite e queries de catalogo
- [ ] criar migration das tabelas e alteracao de `places`
- [ ] adicionar seed inicial da taxonomia gastronomica
- [ ] expor endpoints de leitura e ajustar endpoints de locais
- [ ] adicionar testes unitarios e de integracao

## Frontend

- [ ] ajustar formulario de local para categoria obrigatoria
- [ ] ajustar formulario de local para subcategoria dependente obrigatoria
- [ ] integrar consumo de categorias e subcategorias
- [ ] tratar erros de validacao retornados pela API

## Validacao

- [ ] rodar testes do backend
- [ ] rodar analise e testes do frontend se houver ajuste de UI
- [ ] revisar documentacao e contratos da feature
