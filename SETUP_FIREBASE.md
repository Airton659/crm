# 🔥 Setup Firebase - Passo a Passo

## Problema Atual

Você fez login mas a tela ficou branca com loading infinito. Isso acontece porque:
1. O Firebase não tem as credenciais corretas configuradas no app
2. Não consegue conectar com o Firestore

## Solução Rápida

### 1. Adicionar App Android no Firebase Console

1. Acesse: https://console.firebase.google.com/project/grupo-solar-producao
2. Clique no ícone do Android (⚙️)
3. Adicione as informações:
   - **Android package name:** `com.example.grupo_solar_gestor`
   - **App nickname:** `Grupo Solar Gestor`
   - Clique em "Register app"

4. Baixe o arquivo `google-services.json`

5. Coloque o arquivo em:
   ```
   /Users/joseairton/Downloads/GS/app_gestor/android/app/google-services.json
   ```

### 2. Adicionar App Web no Firebase Console (se ainda não tiver)

1. No Firebase Console, clique no ícone Web (`</>`)
2. Adicione as informações:
   - **App nickname:** `Grupo Solar PWA`
   - Marque "Firebase Hosting"
   - Clique em "Register app"

3. Copie as credenciais que aparecem

4. Cole no arquivo `/Users/joseairton/Downloads/GS/app_gestor/lib/main.dart`:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "Cole aqui o apiKey",
    authDomain: "grupo-solar-producao.firebaseapp.com",
    projectId: "grupo-solar-producao",
    storageBucket: "grupo-solar-producao.appspot.com",
    messagingSenderId: "Cole aqui o messagingSenderId",
    appId: "Cole aqui o appId",
  ),
);
```

### 3. Teste Rápido SEM Firebase (Temporário)

Se quiser testar agora SEM configurar o Firebase, posso criar uma versão MOCK do app que funciona com dados locais apenas para você ver o layout funcionando.

Quer que eu faça isso?

## Depois que configurar:

1. Recarregue o app com **Hot Restart** (Shift + Cmd + F5 no VS Code)
2. Faça login novamente
3. Agora vai criar o documento automaticamente e funcionar!

## Debug no VS Code

Agora você pode usar F5 no VS Code para debugar:
- Abra `/Users/joseairton/Downloads/GS/app_gestor/lib/main.dart`
- Pressione F5
- Escolha o dispositivo Android

Ou use a configuração de launch que criei:
- **Run > Start Debugging** > Escolha "App Gestor (Debug)"
