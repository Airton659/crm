# App Gestor - Grupo Solar Brasil

App mobile nativo (Android/iOS) para gestão de leads de energia solar.

## 🎯 Funcionalidades

- ✅ Autenticação Firebase (email/senha)
- ✅ Dashboard com KPIs em tempo real
- ✅ Gráfico de pizza (origens dos leads)
- ✅ Lista de leads com filtros
- ✅ Atualização de status dos leads
- ✅ Detalhes completos do lead
- ✅ Notificações de novos leads
- ✅ Arquitetura Clean + BLoC pattern

## 🏗️ Arquitetura

```
lib/
├── core/
│   ├── di/              # Dependency Injection (GetIt)
│   └── theme/           # Tema e cores do app
├── data/
│   └── repositories/    # Implementação dos repositórios
├── domain/
│   ├── entities/        # Entidades (Lead, Statistics)
│   ├── repositories/    # Contratos
│   └── usecases/        # Casos de uso
└── presentation/
    ├── bloc/            # BLoCs (Auth, Leads, Statistics)
    ├── pages/           # Páginas (Login, Dashboard, Lead Details)
    └── widgets/         # Widgets reutilizáveis
```

## 📊 Dashboard - KPIs

### 1. **Novos Leads (Mês)**
Query que conta leads do mês atual:

```dart
final now = DateTime.now();
final startOfMonth = DateTime(now.year, now.month, 1);

final querySnapshot = await FirebaseFirestore.instance
    .collection('leads')
    .where('created_at', isGreaterThanOrEqualTo: startOfMonth)
    .get();

final totalLeads = querySnapshot.docs.length;
```

### 2. **Orçamentos Enviados**
Query que conta leads com status "orcamento_enviado":

```dart
final querySnapshot = await FirebaseFirestore.instance
    .collection('leads')
    .where('status', isEqualTo: 'orcamento_enviado')
    .get();

final totalOrcamentos = querySnapshot.docs.length;
```

### 3. **Projetos Fechados**
Query que conta leads com status "fechado":

```dart
final querySnapshot = await FirebaseFirestore.instance
    .collection('leads')
    .where('status', isEqualTo: 'fechado')
    .get();

final totalFechados = querySnapshot.docs.length;
```

## 📈 Gráfico de Origem dos Leads

Para agrupar leads por origem, use:

```dart
// Buscar todos os leads
final querySnapshot = await FirebaseFirestore.instance
    .collection('leads')
    .get();

// Agrupar por origem
final Map<String, int> origens = {};
for (var doc in querySnapshot.docs) {
  final data = doc.data();
  final origem = data['origem']['source'] ?? 'outros';
  origens[origem] = (origens[origem] ?? 0) + 1;
}

// Resultado: {'google': 15, 'instagram': 12, 'indicacao': 10, ...}
```

**Exibição no Chart (fl_chart):**

```dart
import 'package:fl_chart/fl_chart.dart';

PieChart(
  PieChartData(
    sections: [
      PieChartSection(
        value: googleLeads.toDouble(),
        title: '35%',
        color: const Color(0xFFF59E0B), // Amarelo
        radius: 100,
      ),
      PieChartSection(
        value: instagramLeads.toDouble(),
        title: '30%',
        color: const Color(0xFF3B82F6), // Azul
        radius: 100,
      ),
      // ... outros segmentos
    ],
  ),
)
```

## 📋 Lista de Leads

### A. StreamBuilder para Tempo Real

```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('leads')
      .orderBy('created_at', descending: true)
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return Text('Erro: ${snapshot.error}');
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }

    final leads = snapshot.data!.docs
        .map((doc) => Lead.fromFirestore(doc))
        .toList();

    return ListView.builder(
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads[index];
        return LeadCard(lead: lead);
      },
    );
  },
)
```

### B. Filtros

```dart
// Filtrar por status
Query query = FirebaseFirestore.instance.collection('leads');

if (statusFilter != null) {
  query = query.where('status', isEqualTo: statusFilter);
}

if (origemFilter != null) {
  query = query.where('origem.source', isEqualTo: origemFilter);
}

query = query.orderBy('created_at', descending: true);

// Usar no StreamBuilder
stream: query.snapshots()
```

## 🔄 Atualizar Status do Lead

```dart
Future<void> updateLeadStatus(String leadId, String newStatus) async {
  final leadRef = FirebaseFirestore.instance
      .collection('leads')
      .doc(leadId);

  // Obter status anterior
  final doc = await leadRef.get();
  final oldStatus = doc.data()?['status'] ?? '';

  // Atualizar status
  await leadRef.update({
    'status': newStatus,
    'updated_at': FieldValue.serverTimestamp(),
  });

  // Adicionar ao histórico
  await leadRef.collection('historico').add({
    'acao': 'status_alterado',
    'detalhes': 'Status alterado de "$oldStatus" para "$newStatus"',
    'status_anterior': oldStatus,
    'status_novo': newStatus,
    'user_id': FirebaseAuth.instance.currentUser?.uid,
    'user_nome': FirebaseAuth.instance.currentUser?.displayName,
    'timestamp': FieldValue.serverTimestamp(),
  });
}
```

**Uso com BLoC:**

```dart
// Event
class UpdateLeadStatusEvent extends LeadsEvent {
  final String leadId;
  final String newStatus;

  const UpdateLeadStatusEvent({
    required this.leadId,
    required this.newStatus,
  });
}

// Disparar evento
context.read<LeadsBloc>().add(
  UpdateLeadStatusEvent(
    leadId: lead.id,
    newStatus: 'orcamento_enviado',
  ),
);
```

## 🚀 Como Executar

### 1. Instalar dependências

```bash
cd app_gestor
flutter pub get
```

### 2. Configurar Firebase

Edite `lib/main.dart` e adicione suas credenciais:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "SEU_API_KEY",
    authDomain: "seu-projeto.firebaseapp.com",
    projectId: "seu-projeto",
    storageBucket: "seu-projeto.appspot.com",
    messagingSenderId: "123456789",
    appId: "1:123456789:android:abcdef123456",
  ),
);
```

### 3. Executar

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Ou abrir no Android Studio / VS Code
```

## 📱 Estrutura de Telas

### 1. **Login Page**
- Campo email
- Campo senha
- Botão "Entrar"
- Validação de formulário

### 2. **Dashboard Page**
- AppBar com logo e logout
- 3 Cards de KPIs
- Gráfico de pizza (origens)
- Lista de leads recentes
- FAB para filtros

### 3. **Lead Details Page**
- Informações completas do lead
- Botões de ação rápida (ligar, WhatsApp, email)
- Dropdown para mudar status
- Timeline de histórico
- Notas do gestor

## 🎨 Cores do Tema

| Status | Cor | Hex |
|--------|-----|-----|
| Novo | Amarelo | `#FBBF24` |
| Orçamento Enviado | Azul | `#3B82F6` |
| Em Contato | Cinza | `#9CA3AF` |
| Negociação | Roxo | `#8B5CF6` |
| Fechado | Verde | `#10B981` |
| Perdido | Vermelho | `#EF4444` |

## 🔐 Autenticação

### Criar usuário gestor:

```bash
# Via Firebase Console
# Authentication > Users > Add User

# Ou via código (apenas para setup inicial)
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: 'gestor@gruposolar.com',
  password: 'senha_segura',
);

# Adicionar dados do usuário no Firestore
await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .set({
  'nome': 'Gestor Principal',
  'email': 'gestor@gruposolar.com',
  'role': 'gestor',
  'ativo': true,
  'created_at': FieldValue.serverTimestamp(),
});
```

## 📦 Dependências Principais

- **firebase_core** - Core do Firebase
- **cloud_firestore** - Database em tempo real
- **firebase_auth** - Autenticação
- **flutter_bloc** - State management
- **fl_chart** - Gráficos
- **get_it** - Dependency injection
- **dartz** - Functional programming
- **timeago** - Formatação de datas

## 🔔 Notificações (Opcional)

Para receber notificações de novos leads, adicione:

```yaml
# pubspec.yaml
dependencies:
  firebase_messaging: ^14.7.10
```

```dart
// Configurar FCM
final messaging = FirebaseMessaging.instance;
await messaging.requestPermission();
final token = await messaging.getToken();

// Salvar token no Firestore
await FirebaseFirestore.instance
    .collection('users')
    .doc(currentUser.uid)
    .update({'fcm_token': token});
```

## 📊 Estrutura Completa dos Dados

Veja a documentação completa em: `../firebase/FIRESTORE_STRUCTURE.md`

## 🐛 Debug

Para depurar problemas de conexão com Firestore:

```dart
// Ativar logs
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);

// Ver logs no console
flutter logs
```

## 📲 Build para Produção

### Android:

```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

### iOS:

```bash
flutter build ios --release
# Depois abrir no Xcode para arquivar
```
