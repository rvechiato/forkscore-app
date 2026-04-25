# Plan: frontend-auth-home-layout

## Estrategia

1. Consolidar tokens visuais e branding oficial no tema e widgets compartilhados.
2. Separar o fluxo visual em shell responsivo + paginas independentes de login,
   cadastro e home.
3. Reproduzir no Flutter a hierarquia do HTML oficial, adaptando interacoes e
   comportamento para web/mobile.
4. Validar o fluxo visual com testes de widget e comandos padrao do frontend.

## Entregas tecnicas

- tema revisado com tokens oficiais e estilos reutilizaveis;
- logo oficial incorporado ao app;
- shell visual com frame de preview para web larga;
- pagina de login alinhada ao HTML oficial;
- pagina de cadastro alinhada ao HTML oficial;
- home inicial alinhada ao HTML oficial;
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
