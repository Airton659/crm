# PWA Cliente - Grupo Solar Brasil

Progressive Web App para captura de leads de energia solar.

## 🎯 Funcionalidades

- ✅ Captura automática de parâmetros UTM da URL
- ✅ Formulário validado para simulação de sistema solar
- ✅ Envio de leads para Firebase Firestore
- ✅ Design responsivo (mobile, tablet, desktop)
- ✅ Arquitetura Clean + BLoC pattern
- ✅ Tracking de origem do lead
- ✅ SEO otimizado

## 🏗️ Arquitetura

```
lib/
├── core/
│   ├── di/              # Dependency Injection (GetIt)
│   ├── theme/           # Tema e cores do app
│   └── utils/           # UTM Parser e utilidades
├── data/
│   └── repositories/    # Implementação dos repositórios
├── domain/
│   ├── entities/        # Entidades de negócio (Lead, OrigemLead)
│   ├── repositories/    # Contratos dos repositórios
│   └── usecases/        # Casos de uso (SubmitLead)
└── presentation/
    ├── bloc/            # BLoCs (LeadFormBloc)
    ├── pages/           # Páginas (HomePage)
    └── widgets/         # Widgets reutilizáveis
```

## 🚀 Como Executar

### 1. Instalar dependências

```bash
cd pwa_cliente
flutter pub get
```

### 2. Configurar Firebase

Edite o arquivo `lib/main.dart` e adicione suas credenciais do Firebase:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "SEU_API_KEY",
    authDomain: "seu-projeto.firebaseapp.com",
    projectId: "seu-projeto",
    storageBucket: "seu-projeto.appspot.com",
    messagingSenderId: "123456789",
    appId: "1:123456789:web:abcdef123456",
    measurementId: "G-XXXXXXXXXX",
  ),
);
```

### 3. Executar em modo desenvolvimento

```bash
flutter run -d chrome
```

### 4. Build para produção

```bash
flutter build web --release
```

Os arquivos estarão em `build/web/`

## 📊 Captura de UTM

O PWA captura automaticamente os seguintes parâmetros da URL:

- `utm_source` - Fonte do tráfego (ex: google, instagram)
- `utm_medium` - Meio (ex: cpc, social)
- `utm_campaign` - Campanha
- `utm_content` - Conteúdo do anúncio
- `utm_term` - Termo de busca

**Exemplo de URL:**
```
https://seusite.com/?utm_source=google&utm_medium=cpc&utm_campaign=energia-solar-2024
```

## 🎨 Cores do Tema

| Cor | Hex | Uso |
|-----|-----|-----|
| Azul Principal | `#1E3A8A` | Headers, texto principal |
| Amarelo Secundário | `#F59E0B` | Botões, destaques |
| Cinza Fundo | `#F3F4F6` | Background |

## 📱 Deploy no Firebase Hosting

1. Instale o Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Faça login:
```bash
firebase login
```

3. Inicialize o projeto (se ainda não fez):
```bash
cd ..
firebase init hosting
# Selecione: pwa_cliente/build/web como public directory
```

4. Build e deploy:
```bash
flutter build web --release
firebase deploy --only hosting
```

## 🧪 Testes

Para testar a captura de UTM, acesse:

```
http://localhost:PORT/?utm_source=google&utm_medium=cpc&utm_campaign=teste
```

Preencha o formulário e verifique no Firestore se os dados de origem foram salvos corretamente.

## 📄 Estrutura de Dados no Firestore

Veja a documentação completa em: `../firebase/FIRESTORE_STRUCTURE.md`

## 🔐 Segurança

- Validação de formulário no cliente
- Security Rules do Firestore permitem apenas criação de leads
- Sanitização de dados antes do envio
- HTTPS obrigatório em produção
