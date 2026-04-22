# Setup Guide — ForkScore

## Backend Setup

1. Abra o terminal e navegue para a pasta `backend`

```bash
cd backend
```

2. Instale dependências

```bash
npm install
```

3. Copie o arquivo de exemplo de variáveis de ambiente

```bash
cp .env.example .env
```

4. Ajuste as variáveis em `.env` conforme necessário

5. Execute a aplicação em modo de desenvolvimento

```bash
npm run dev
```

6. Verifique se a API está funcionando

```bash
curl http://localhost:3000/health
```

---

## Frontend Setup

1. Abra o terminal e navegue para a pasta `mobile`

```bash
cd mobile
```

2. Instale dependências Flutter

```bash
flutter pub get
```

3. Execute o app no emulador ou dispositivo conectado

```bash
flutter run
```

4. Se desejar criar build de produção

```bash
flutter build apk
flutter build ios
```

---

## Observações

- O backend usa SQLite para MVP. O arquivo do banco de dados será criado em `backend/forkscore.db` por padrão.
- O frontend ainda usa um `home` de exemplo; os flows de autenticação e avaliações serão implementados nas pastas `mobile/lib/features/*`.
- Se estiver usando VS Code, abra a raiz do projeto (`forkscore`) para ter acesso à estrutura completa.
