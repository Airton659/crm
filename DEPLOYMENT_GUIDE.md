# 🚀 Guia Completo de Deploy - Grupo Solar

Este guia detalha o processo completo de deploy do sistema em produção.

## 📋 Checklist Pré-Deploy

- [ ] Conta Firebase criada
- [ ] Projeto Firebase configurado
- [ ] Flutter instalado (3.2.0+)
- [ ] Firebase CLI instalado
- [ ] Domínio personalizado (opcional)
- [ ] Credenciais de produção configuradas

---

## 1️⃣ Setup Inicial do Firebase

### 1.1. Criar Projeto no Firebase

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Nome: `grupo-solar-producao`
4. Ative o Google Analytics (recomendado)
5. Selecione a conta do Analytics
6. Clique em "Criar projeto"

### 1.2. Ativar Serviços

#### Firestore Database

1. No menu lateral: **Build > Firestore Database**
2. Clique em "Criar banco de dados"
3. Selecione "Iniciar em modo de produção"
4. Escolha a localização: `southamerica-east1` (São Paulo)
5. Clique em "Ativar"

#### Authentication

1. No menu lateral: **Build > Authentication**
2. Clique em "Começar"
3. Ative o método "E-mail/senha"
4. Salvar

#### Hosting (para PWA)

1. No menu lateral: **Build > Hosting**
2. Clique em "Começar"
3. Seguir os passos do Firebase CLI (ver seção 2)

---

## 2️⃣ Deploy do Backend (Firebase)

### 2.1. Instalar Firebase CLI

```bash
npm install -g firebase-tools
```

### 2.2. Login no Firebase

```bash
firebase login
```

### 2.3. Inicializar Projeto

```bash
cd firebase
firebase init

# Selecione:
# - Firestore
# - Hosting

# Firestore:
# - firestore.rules
# - firestore.indexes.json

# Hosting:
# - Public directory: ../pwa_cliente/build/web
# - Configure as single-page app: Yes
# - Set up automatic builds: No
```

### 2.4. Deploy Firestore Rules e Indexes

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

**Verificar:**
```bash
# No Firebase Console:
# Firestore Database > Regras
# Conferir se as regras foram aplicadas
```

---

## 3️⃣ Deploy do PWA Cliente

### 3.1. Configurar Firebase no Código

1. No Firebase Console: **Project Settings > Your apps**
2. Clique no ícone Web (`</>`)
3. Registre o app: `Grupo Solar PWA`
4. Copie as configurações

5. Edite `pwa_cliente/lib/main.dart`:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "AIzaSy...",
    authDomain: "grupo-solar-xxxxx.firebaseapp.com",
    projectId: "grupo-solar-xxxxx",
    storageBucket: "grupo-solar-xxxxx.appspot.com",
    messagingSenderId: "123456789",
    appId: "1:123456789:web:abcdef",
    measurementId: "G-XXXXXXXXXX",
  ),
);
```

### 3.2. Build do PWA

```bash
cd pwa_cliente

# Build production
flutter build web --release --web-renderer html

# Verificar build
ls -la build/web/
```

### 3.3. Deploy no Firebase Hosting

```bash
cd ../firebase
firebase deploy --only hosting

# Output:
# ✔  Deploy complete!
# Hosting URL: https://grupo-solar-xxxxx.web.app
```

### 3.4. Configurar Domínio Personalizado (Opcional)

1. No Firebase Console: **Hosting > Add custom domain**
2. Digite seu domínio: `www.gruposolar.com.br`
3. Siga as instruções para adicionar registros DNS
4. Aguarde propagação (até 24h)

**Exemplo de registros DNS:**
```
Type: A
Name: @
Value: 151.101.1.195

Type: A
Name: @
Value: 151.101.65.195

Type: CNAME
Name: www
Value: grupo-solar-xxxxx.web.app
```

---

## 4️⃣ Criar Usuário Gestor

### 4.1. Via Firebase Console

1. **Authentication > Users > Add user**
2. Email: `gestor@gruposolar.com.br`
3. Password: (criar senha segura)
4. Clique em "Add user"
5. Copie o UID do usuário

### 4.2. Adicionar Dados no Firestore

1. **Firestore Database > Iniciar coleção**
2. Collection ID: `users`
3. Document ID: (colar o UID copiado)
4. Campos:

```json
{
  "nome": "Gestor Principal",
  "email": "gestor@gruposolar.com.br",
  "role": "gestor",
  "ativo": true,
  "foto_url": "",
  "created_at": (timestamp atual),
  "preferencias": {
    "notificacoes_push": true,
    "notificacoes_email": true
  }
}
```

---

## 5️⃣ Deploy do App Gestor (Mobile)

### 5.1. Configurar Firebase no App

#### Para Android:

1. No Firebase Console: **Project Settings > Your apps**
2. Clique no ícone Android
3. Android package name: `com.gruposolar.gestor`
4. App nickname: `Grupo Solar Gestor`
5. Baixe `google-services.json`
6. Coloque em: `app_gestor/android/app/google-services.json`

7. Edite `app_gestor/android/build.gradle`:

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

8. Edite `app_gestor/android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        applicationId "com.gruposolar.gestor"
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

#### Para iOS:

1. No Firebase Console: **Project Settings > Your apps**
2. Clique no ícone iOS
3. iOS bundle ID: `com.gruposolar.gestor`
4. App nickname: `Grupo Solar Gestor`
5. Baixe `GoogleService-Info.plist`
6. Abra `app_gestor/ios/Runner.xcworkspace` no Xcode
7. Arraste `GoogleService-Info.plist` para o projeto

### 5.2. Build Android (APK/AAB)

```bash
cd app_gestor

# Build APK (para testes)
flutter build apk --release

# Build App Bundle (para Google Play)
flutter build appbundle --release

# Arquivo gerado:
# build/app/outputs/bundle/release/app-release.aab
```

### 5.3. Publicar na Google Play Store

1. Acesse [Google Play Console](https://play.google.com/console)
2. Criar novo app
3. Preencher informações:
   - Nome: `Grupo Solar - Gestor`
   - Descrição curta e completa
   - Screenshots (obrigatório)
   - Ícone 512x512
4. Upload do AAB
5. Criar release em **Produção**
6. Enviar para revisão

### 5.4. Build iOS (IPA)

```bash
cd app_gestor

# Build iOS
flutter build ios --release

# Abrir no Xcode
open ios/Runner.xcworkspace
```

No Xcode:
1. Product > Archive
2. Distribute App
3. App Store Connect
4. Upload

### 5.5. Publicar na App Store

1. Acesse [App Store Connect](https://appstoreconnect.apple.com/)
2. My Apps > + > New App
3. Preencher informações
4. Aguardar processamento do build
5. Selecionar build
6. Submit for Review

---

## 6️⃣ Monitoramento e Analytics

### 6.1. Ativar Analytics

Já está ativado automaticamente se você configurou o Firebase Analytics no setup inicial.

**Verificar eventos no Console:**
```
Firebase Console > Analytics > Events
```

### 6.2. Ativar Crashlytics (Opcional)

```bash
# Adicionar dependência
flutter pub add firebase_crashlytics

# No código
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
```

### 6.3. Performance Monitoring

```bash
# Adicionar dependência
flutter pub add firebase_performance

# Web
firebase init perf
```

---

## 7️⃣ Testes Pós-Deploy

### 7.1. Testar PWA

1. Acesse a URL do Hosting
2. Teste com UTM:
   ```
   https://seu-dominio.com/?utm_source=google&utm_medium=cpc&utm_campaign=teste
   ```
3. Preencha o formulário
4. Verifique no Firestore se o lead foi criado

### 7.2. Testar App Gestor

1. Instale o app no dispositivo
2. Faça login com o usuário gestor
3. Verifique se o dashboard carrega
4. Verifique se os leads aparecem
5. Teste atualizar status de um lead

### 7.3. Testar Fluxo Completo

```
1. Cliente acessa PWA com UTM
2. Cliente preenche formulário
3. Lead é criado no Firestore
4. Gestor recebe notificação (se configurado)
5. Gestor visualiza lead no app
6. Gestor atualiza status
7. Histórico é registrado
```

---

## 8️⃣ Configurações de Produção

### 8.1. Firestore Indexes

Verifique se todos os índices foram criados:

```bash
firebase firestore:indexes
```

Se houver erros, o Firebase exibirá um link para criar os índices manualmente.

### 8.2. Backup Automático (Recomendado)

1. No Firebase Console: **Firestore Database > Backups**
2. Ativar backups automáticos
3. Definir frequência: Diária
4. Retenção: 30 dias

### 8.3. Limites e Cotas

Verifique os limites do plano:

| Serviço | Plano Spark (Gratuito) | Plano Blaze (Pago) |
|---------|------------------------|---------------------|
| Firestore Leituras | 50k/dia | Ilimitado |
| Firestore Escritas | 20k/dia | Ilimitado |
| Hosting GB | 10 GB/mês | 30 GB/mês |
| Usuários Auth | Ilimitado | Ilimitado |

**Recomendação:** Iniciar com Spark, migrar para Blaze quando escalar.

---

## 9️⃣ Manutenção

### 9.1. Atualizar PWA

```bash
cd pwa_cliente
# Fazer alterações
flutter build web --release
cd ../firebase
firebase deploy --only hosting
```

### 9.2. Atualizar App Gestor

```bash
cd app_gestor
# Fazer alterações
# Incrementar versão no pubspec.yaml
flutter build apk --release
# Upload na Google Play / App Store
```

### 9.3. Atualizar Regras do Firestore

```bash
cd firebase
# Editar firestore.rules
firebase deploy --only firestore:rules
```

---

## 🔧 Troubleshooting

### Erro: "Firebase not initialized"
- Verificar se as credenciais estão corretas
- Verificar se Firebase.initializeApp() é chamado antes de usar

### Erro: "Permission denied" no Firestore
- Verificar Security Rules
- Verificar autenticação do usuário

### PWA não carrega após deploy
- Limpar cache do navegador
- Verificar console do navegador
- Verificar se o build está na pasta correta

### App móvel não conecta ao Firestore
- Verificar google-services.json (Android)
- Verificar GoogleService-Info.plist (iOS)
- Verificar internet do dispositivo

---

## 📊 Monitoramento de Custos

Para monitorar custos do Firebase:

1. Firebase Console > **Usage and billing**
2. Configurar alertas de orçamento
3. Monitorar métricas principais:
   - Leituras/Escritas Firestore
   - Banda Hosting
   - Autenticações

---

## ✅ Checklist Final

- [ ] Firebase configurado e serviços ativados
- [ ] PWA deployed no Firebase Hosting
- [ ] App Android publicado na Play Store
- [ ] App iOS publicado na App Store
- [ ] Usuário gestor criado e testado
- [ ] Firestore rules e indexes deployed
- [ ] Domínio personalizado configurado (opcional)
- [ ] Analytics e monitoring ativos
- [ ] Backups automáticos configurados
- [ ] Testes end-to-end realizados
- [ ] Documentação entregue ao cliente

---

## 📞 Suporte

Para questões relacionadas ao deploy:

- **Firebase:** https://firebase.google.com/support
- **Flutter:** https://flutter.dev/support
- **Google Play:** https://support.google.com/googleplay
- **App Store:** https://developer.apple.com/support/

---

**🎉 Parabéns! Seu sistema está em produção!**
