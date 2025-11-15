# Estrutura do Firestore - Grupo Solar

## 📊 Coleções Principais

### 1. `leads` Collection

Armazena todos os leads capturados pelo PWA.

```json
{
  "id": "auto-generated-id",
  "nome": "João Silva",
  "email": "joao.silva@email.com",
  "telefone": "+5511987654321",
  "consumo_kwh": 450,
  "tipo_telhado": "ceramico", // ceramico | metalico | laje
  "tipo_servico": "comercio", // comercio | escola | industria | condominio | mercado_livre
  "origem": {
    "source": "google",
    "medium": "cpc",
    "campaign": "energia-solar-2024",
    "content": "anuncio-a",
    "term": "painel solar",
    "referrer": "https://google.com",
    "ip": "192.168.1.1",
    "user_agent": "Mozilla/5.0..."
  },
  "status": "novo", // novo | orcamento_enviado | em_contato | negociacao | fechado | perdido
  "prioridade": "media", // baixa | media | alta
  "valor_estimado": 50000.0,
  "notas": "",
  "gestor_responsavel_id": null,
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z",
  "last_contact_at": null,
  "metadata": {
    "device": "mobile",
    "browser": "Chrome",
    "os": "Android"
  }
}
```

#### Subcoleção: `leads/{leadId}/historico`

```json
{
  "id": "auto-generated-id",
  "acao": "status_alterado",
  "detalhes": "Status alterado de 'novo' para 'orcamento_enviado'",
  "status_anterior": "novo",
  "status_novo": "orcamento_enviado",
  "user_id": "gestor-user-id",
  "user_nome": "Maria Gestora",
  "timestamp": "2024-01-15T14:20:00Z"
}
```

### 2. `lead_sources` Collection

Analytics de origem de tráfego.

```json
{
  "id": "{ano}-{mes}-{source}",
  "ano": 2024,
  "mes": 1,
  "source": "google",
  "medium": "cpc",
  "total_leads": 42,
  "total_conversoes": 5,
  "taxa_conversao": 11.9,
  "ultima_atualizacao": "2024-01-31T23:59:59Z"
}
```

### 3. `users` Collection

Gestores autenticados no sistema.

```json
{
  "id": "firebase-auth-uid",
  "nome": "Maria Gestora",
  "email": "maria@gruposolar.com",
  "role": "gestor", // gestor | admin
  "foto_url": "https://...",
  "ativo": true,
  "created_at": "2024-01-01T00:00:00Z",
  "last_login": "2024-01-15T09:00:00Z",
  "preferencias": {
    "notificacoes_push": true,
    "notificacoes_email": true
  }
}
```

### 4. `configurations` Collection

Configurações do sistema (FAQ, contatos, etc).

```json
{
  "id": "faq",
  "tipo": "faq",
  "items": [
    {
      "pergunta": "Em quanto tempo tenho o retorno do investimento?",
      "resposta": "O retorno médio do investimento em energia solar é de 4 a 7 anos..."
    }
  ],
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### 5. `statistics` Collection

Estatísticas agregadas (geradas por Cloud Functions).

```json
{
  "id": "2024-01",
  "periodo": "mensal",
  "ano": 2024,
  "mes": 1,
  "total_leads": 42,
  "total_orcamentos": 18,
  "total_fechados": 5,
  "taxa_conversao": 11.9,
  "valor_total_fechado": 250000.0,
  "por_origem": {
    "google": 15,
    "instagram": 12,
    "indicacao": 10,
    "outros": 5
  },
  "por_status": {
    "novo": 10,
    "orcamento_enviado": 12,
    "em_contato": 8,
    "negociacao": 7,
    "fechado": 5
  }
}
```

## 🔍 Queries Principais

### KPI: Novos Leads do Mês Atual

```dart
final now = DateTime.now();
final startOfMonth = DateTime(now.year, now.month, 1);

final query = FirebaseFirestore.instance
    .collection('leads')
    .where('created_at', isGreaterThanOrEqualTo: startOfMonth)
    .orderBy('created_at', descending: true);
```

### Gráfico de Origem

```dart
final query = FirebaseFirestore.instance
    .collection('leads')
    .orderBy('origem.source');

// Agrupar no cliente ou usar Cloud Function
```

### Lista de Leads com Filtro

```dart
Query query = FirebaseFirestore.instance
    .collection('leads')
    .orderBy('created_at', descending: true);

// Filtro por status
if (statusFilter != null) {
  query = query.where('status', isEqualTo: statusFilter);
}

// Filtro por origem
if (origemFilter != null) {
  query = query.where('origem.source', isEqualTo: origemFilter);
}
```

### Atualizar Status do Lead

```dart
await FirebaseFirestore.instance
    .collection('leads')
    .doc(leadId)
    .update({
      'status': novoStatus,
      'updated_at': FieldValue.serverTimestamp(),
    });

// Adicionar ao histórico
await FirebaseFirestore.instance
    .collection('leads')
    .doc(leadId)
    .collection('historico')
    .add({
      'acao': 'status_alterado',
      'status_anterior': statusAntigo,
      'status_novo': novoStatus,
      'user_id': currentUser.uid,
      'user_nome': currentUser.displayName,
      'timestamp': FieldValue.serverTimestamp(),
    });
```

## 🛡️ Security Rules

As regras de segurança estão configuradas em `firestore.rules`:

- **Leads**: Criação pública (PWA), leitura/atualização apenas para gestores
- **Users**: Cada usuário só pode ler/editar seus próprios dados
- **Configurations**: Leitura pública, escrita apenas para gestores
- **Statistics**: Leitura para gestores, escrita apenas por Cloud Functions

## 📈 Indexes

Os indexes necessários estão em `firestore.indexes.json` para otimizar:

- Consultas por status + data
- Consultas por origem + data
- Ordenação combinada

## 🚀 Deploy

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Inicializar projeto
firebase init firestore

# Deploy das regras e indexes
firebase deploy --only firestore:rules,firestore:indexes
```
