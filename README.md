# 🌞 Grupo Solar Brasil - Sistema Completo

Sistema completo de captura e gestão de leads para empresa de energia solar, utilizando **Flutter** (Web/Mobile) e **Firebase** como backend.

## 📁 Estrutura do Projeto

```
GS/
├── firebase/                    # Configurações do Firebase
│   ├── firestore.rules         # Regras de segurança do Firestore
│   ├── firestore.indexes.json  # Índices otimizados
│   ├── firebase.json           # Configuração do projeto
│   ├── FIRESTORE_STRUCTURE.md  # Documentação completa da estrutura de dados
│   └── functions/              # Cloud Functions (opcional)
│
├── pwa_cliente/                # PWA para captura de leads
│   ├── lib/
│   │   ├── core/              # DI, Theme, Utils
│   │   ├── data/              # Repositories
│   │   ├── domain/            # Entities, Use Cases
│   │   └── presentation/      # BLoC, Pages, Widgets
│   ├── web/                   # Arquivos web (index.html, manifest.json)
│   ├── pubspec.yaml
│   └── README.md              # Documentação do PWA
│
├── app_gestor/                # App mobile para gestores
│   ├── lib/
│   │   ├── core/              # DI, Theme
│   │   ├── data/              # Repositories
│   │   ├── domain/            # Entities, Use Cases
│   │   └── presentation/      # BLoC, Pages, Widgets
│   ├── pubspec.yaml
│   └── README.md              # Documentação do App
│
└── README.md                  # Este arquivo
```

## 🎯 Componentes do Sistema

### 1. **Firebase Backend**

**Firestore Collections:**
- `leads` - Armazena todos os leads capturados
- `lead_sources` - Analytics de origem de tráfego
- `users` - Gestores autenticados
- `configurations` - Configurações do sistema
- `statistics` - Estatísticas agregadas

**Recursos:**
- ✅ Security Rules configuradas
- ✅ Índices otimizados
- ✅ Estrutura escalável e normalizada

📄 **Documentação:** [firebase/FIRESTORE_STRUCTURE.md](firebase/FIRESTORE_STRUCTURE.md)

---

### 2. **PWA Cliente** (Flutter Web)

Progressive Web App público para captura de leads.

**Funcionalidades:**
- ✅ Captura automática de parâmetros UTM da URL
- ✅ Formulário de simulação validado
- ✅ Design responsivo (mobile/tablet/desktop)
- ✅ Tracking completo de origem do lead
- ✅ Envio direto para Firestore
- ✅ SEO otimizado

**Tecnologias:**
- Flutter Web
- Firebase (Firestore, Analytics)
- BLoC Pattern
- Arquitetura Clean

**Deploy:**
```bash
cd pwa_cliente
flutter build web --release
firebase deploy --only hosting
```

📄 **Documentação:** [pwa_cliente/README.md](pwa_cliente/README.md)

---

### 3. **App Gestor** (Flutter Mobile)

App nativo Android/iOS para gestores acompanharem e gerenciarem leads.

**Funcionalidades:**
- ✅ Dashboard com KPIs em tempo real
- ✅ Gráfico de pizza (origens dos leads)
- ✅ Lista de leads com filtros
- ✅ Atualização de status
- ✅ Detalhes completos do lead
- ✅ Notificações push (opcional)
- ✅ Autenticação Firebase

**Tecnologias:**
- Flutter (Android/iOS)
- Firebase (Auth, Firestore)
- BLoC Pattern
- FL Chart (gráficos)
- Arquitetura Clean

**Build:**
```bash
cd app_gestor
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

📄 **Documentação:** [app_gestor/README.md](app_gestor/README.md)

---

## 🚀 Setup Completo

### 1. Pré-requisitos

- [Flutter](https://flutter.dev/docs/get-started/install) (3.2.0+)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Conta no [Firebase Console](https://console.firebase.google.com/)

### 2. Configurar Firebase

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Criar projeto no Firebase Console
# https://console.firebase.google.com/

# Inicializar Firebase no projeto
cd firebase
firebase init firestore hosting

# Deploy das regras e hosting
firebase deploy
```

### 3. Configurar PWA Cliente

```bash
cd pwa_cliente

# Instalar dependências
flutter pub get

# Configurar credenciais Firebase em lib/main.dart
# (Obter no Firebase Console > Project Settings > Web App)

# Executar em desenvolvimento
flutter run -d chrome

# Build para produção
flutter build web --release

# Deploy
cd ../firebase
firebase deploy --only hosting
```

### 4. Configurar App Gestor

```bash
cd app_gestor

# Instalar dependências
flutter pub get

# Configurar credenciais Firebase em lib/main.dart
# (Obter no Firebase Console > Project Settings > Android/iOS App)

# Executar
flutter run

# Build
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

---

## 📊 Fluxo de Dados

```
┌─────────────────┐
│   Cliente Web   │
│   (PWA)         │
│                 │
│  - Preenche     │
│    formulário   │
│  - UTM params   │
│    capturados   │
└────────┬────────┘
         │
         │ Envia lead
         │
         ▼
┌─────────────────┐
│   Firebase      │
│   Firestore     │
│                 │
│  Collection:    │
│  - leads        │
│  - lead_sources │
└────────┬────────┘
         │
         │ Tempo real
         │ (snapshots)
         ▼
┌─────────────────┐
│   App Gestor    │
│   (Mobile)      │
│                 │
│  - Dashboard    │
│  - Lista leads  │
│  - Atualiza     │
│    status       │
└─────────────────┘
```

---

## 🔑 Snippets Principais

### A. Captura UTM no Flutter Web (PWA)

```dart
import 'dart:html' as html;

Map<String, String> captureUtm() {
  final uri = Uri.parse(html.window.location.href);
  return {
    'source': uri.queryParameters['utm_source'] ?? 'direto',
    'medium': uri.queryParameters['utm_medium'] ?? 'none',
    'campaign': uri.queryParameters['utm_campaign'] ?? '',
  };
}
```

### B. Salvar Lead no Firestore (PWA)

```dart
await FirebaseFirestore.instance.collection('leads').add({
  'nome': 'João Silva',
  'email': 'joao@email.com',
  'telefone': '(11) 98888-7777',
  'consumo_kwh': 500,
  'tipo_telhado': 'ceramico',
  'origem': {
    'source': 'google',
    'medium': 'cpc',
    'campaign': 'energia-solar-2024',
  },
  'status': 'novo',
  'created_at': FieldValue.serverTimestamp(),
});
```

### C. Query KPI "Novos Leads do Mês" (App Gestor)

```dart
final now = DateTime.now();
final startOfMonth = DateTime(now.year, now.month, 1);

final snapshot = await FirebaseFirestore.instance
    .collection('leads')
    .where('created_at', isGreaterThanOrEqualTo: startOfMonth)
    .get();

final totalLeads = snapshot.docs.length;
```

### D. Agrupar Leads por Origem (App Gestor)

```dart
final snapshot = await FirebaseFirestore.instance
    .collection('leads')
    .get();

final Map<String, int> origens = {};
for (var doc in snapshot.docs) {
  final origem = doc.data()['origem']['source'] ?? 'outros';
  origens[origem] = (origens[origem] ?? 0) + 1;
}

// Resultado: {'google': 15, 'instagram': 12, ...}
```

### E. StreamBuilder para Lista em Tempo Real (App Gestor)

```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('leads')
      .orderBy('created_at', descending: true)
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }

    final leads = snapshot.data!.docs
        .map((doc) => Lead.fromFirestore(doc))
        .toList();

    return ListView.builder(
      itemCount: leads.length,
      itemBuilder: (context, index) => LeadCard(leads[index]),
    );
  },
)
```

### F. Atualizar Status do Lead (App Gestor)

```dart
await FirebaseFirestore.instance
    .collection('leads')
    .doc(leadId)
    .update({
      'status': 'orcamento_enviado',
      'updated_at': FieldValue.serverTimestamp(),
    });

// Adicionar ao histórico
await FirebaseFirestore.instance
    .collection('leads')
    .doc(leadId)
    .collection('historico')
    .add({
      'acao': 'status_alterado',
      'status_anterior': 'novo',
      'status_novo': 'orcamento_enviado',
      'user_id': currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
```

---

## 🎨 Design System

### Cores Grupo Solar

| Elemento | Cor | Hex | Uso |
|----------|-----|-----|-----|
| Azul Principal | 🔵 | `#1E3A8A` | Headers, texto principal |
| Amarelo Secundário | 🟡 | `#F59E0B` | Botões, destaques, CTAs |
| Amarelo Accent | 🟨 | `#FBBF24` | Labels, badges |
| Cinza Background | ⬜ | `#F3F4F6` | Fundo da tela |
| Verde Sucesso | 🟢 | `#10B981` | Status "Fechado" |
| Vermelho Perigo | 🔴 | `#EF4444` | Status "Perdido" |

---

## 📈 Exemplo de URLs com UTM

Para testar a captura de UTM:

```
# Google Ads
https://seusite.com/?utm_source=google&utm_medium=cpc&utm_campaign=energia-solar-2024&utm_content=anuncio-a&utm_term=painel+solar

# Instagram
https://seusite.com/?utm_source=instagram&utm_medium=social&utm_campaign=energia-solar-2024&utm_content=post-carrossel

# Indicação
https://seusite.com/?utm_source=indicacao&utm_medium=referral&utm_campaign=clientes-satisfeitos
```

---

## 🔐 Segurança

### Firestore Security Rules

```javascript
// Leads: Criação pública, leitura/atualização apenas gestores
match /leads/{leadId} {
  allow create: if request.auth == null; // Público pode criar
  allow read, update: if isGestor();
  allow delete: if false; // Ninguém pode deletar
}

function isGestor() {
  return request.auth != null &&
         exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'gestor';
}
```

---

## 📱 Testes

### Testar PWA localmente:

```bash
cd pwa_cliente
flutter run -d chrome --web-port=8080
```

Acesse: `http://localhost:8080/?utm_source=google&utm_medium=cpc`

### Testar App Gestor:

1. Criar usuário gestor no Firebase Console
2. Adicionar documento na coleção `users` com `role: "gestor"`
3. Fazer login no app
4. Verificar se os leads aparecem no dashboard

---

## 🐛 Troubleshooting

### Erro: "Missing or insufficient permissions"
- Verificar Firestore Security Rules
- Garantir que o usuário está autenticado (App Gestor)

### PWA não está capturando UTM
- Verificar se a URL contém os parâmetros
- Verificar console do navegador
- Testar com URL completa

### Leads não aparecem no App Gestor
- Verificar autenticação
- Verificar se há leads no Firestore
- Verificar índices do Firestore

---

## 📚 Documentação Adicional

- [Estrutura do Firestore](firebase/FIRESTORE_STRUCTURE.md)
- [PWA Cliente - Documentação](pwa_cliente/README.md)
- [App Gestor - Documentação](app_gestor/README.md)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)

---

## 📄 Licença

Este projeto foi desenvolvido para o **Grupo Solar Brasil**.

---

## 👨‍💻 Suporte

Para dúvidas ou problemas:
1. Consulte a documentação específica de cada módulo
2. Verifique os READMEs individuais
3. Entre em contato com a equipe de desenvolvimento

---

**Desenvolvido com ❤️ usando Flutter e Firebase**
