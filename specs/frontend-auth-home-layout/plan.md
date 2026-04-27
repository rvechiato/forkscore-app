# Plan: frontend-auth-home-layout

## Estrategia

1. Consolidar tokens visuais e branding oficial no tema e widgets compartilhados.
2. Separar o fluxo visual em shell responsivo + paginas independentes de login,
   cadastro e home.
3. Substituir a navegacao por enum local por rotas nomeadas com uma camada
   central de guard para rotas publicas e autenticadas.
4. Conectar login, cadastro, logout e placeholders internos ao
   `SessionController` usando repositório mockado para o MVP.
5. Reproduzir no Flutter a hierarquia do HTML oficial, adaptando interacoes e
   comportamento para web/mobile.
6. Validar fluxo visual e controle de acesso com testes de widget e comandos
   padrao do frontend.

## Entregas tecnicas

- tema revisado com tokens oficiais e estilos reutilizaveis;
- logo oficial incorporado ao app;
- shell visual com frame de preview para web larga;
- pagina de login alinhada ao HTML oficial;
- pagina de cadastro alinhada ao HTML oficial;
- home inicial alinhada ao HTML oficial;
- tabela central de rotas publicas/protegidas;
- route guard reutilizavel para sessao autenticada;
- placeholders protegidos para expansao de perfil, locais e avaliacoes;
- testes cobrindo renderizacao e navegacao principal.

## Riscos e mitigacoes

- Risco: divergencia entre HTML oficial e widgets Flutter existentes.
  Mitigacao: usar o HTML como fonte de hierarquia e ajustar naming/spacing no
  Flutter, em vez de manter a implementacao atual por inercia.
- Risco: layout quebrar em telas pequenas.
  Mitigacao: usar `LayoutBuilder`, areas rolaveis e limites de largura.
- Risco: excesso de codigo em uma unica pagina.
  Mitigacao: extrair widgets por responsabilidade e manter shared widgets para
  estilos recorrentes.
- Risco: logout ou acesso direto por URL manter pagina protegida montada.
  Mitigacao: aplicar o guard no roteador central e reagir a mudancas do
  `SessionController`.
