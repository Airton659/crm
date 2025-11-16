import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/lead.dart';
import '../../domain/entities/interacao.dart';
import '../../domain/entities/agendamento.dart';
import '../bloc/leads/leads_bloc.dart';
import '../bloc/leads/leads_event.dart';
import '../bloc/leads/leads_state.dart';
import '../widgets/add_nota_dialog.dart';
import '../widgets/add_agendamento_dialog.dart';

class LeadDetailsPage extends StatefulWidget {
  final Lead lead;

  const LeadDetailsPage({
    super.key,
    required this.lead,
  });

  @override
  State<LeadDetailsPage> createState() => _LeadDetailsPageState();
}

class _LeadDetailsPageState extends State<LeadDetailsPage> {
  late String _currentStatus;
  late String _currentQualificacao;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.lead.status;
    _currentQualificacao = widget.lead.qualificacao;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeadsBloc, LeadsState>(
      listener: (context, state) {
        if (state is LeadsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.dangerRed,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.lead.nome),
          actions: [
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: () => _makePhoneCall(widget.lead.telefone),
              tooltip: 'Ligar',
            ),
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () => _openWhatsApp(widget.lead.telefone, widget.lead.nome),
              tooltip: 'WhatsApp',
            ),
            IconButton(
              icon: const Icon(Icons.email),
              onPressed: () => _sendEmail(widget.lead.email, widget.lead.nome),
              tooltip: 'Enviar e-mail',
            ),
          ],
        ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status e Qualificação - Controles
            _buildStatusQualificacaoControls(),
            const SizedBox(height: 16),

            // Informações do Lead
            _buildSection(
              title: 'Informações do Lead',
              child: Column(
                children: [
                  _buildInfoRow('Nome', widget.lead.nome),
                  _buildInfoRow('Email', widget.lead.email),
                  _buildInfoRow('Telefone', widget.lead.telefone),
                  _buildInfoRow('Consumo', '${widget.lead.consumoKwh} kWh/mês'),
                  _buildInfoRow(
                    'Investimento Estimado',
                    'R\$ ${_calcularInvestimento(widget.lead.consumoKwh).toStringAsFixed(2).replaceAll('.', ',')}',
                    highlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Origem
            _buildSection(
              title: 'Origem do Lead',
              child: Column(
                children: [
                  _buildInfoRow('Fonte', widget.lead.origem.displayName),
                  _buildInfoRow('Meio', widget.lead.origem.medium),
                  if (widget.lead.origem.campaign.isNotEmpty)
                    _buildInfoRow('Campanha', widget.lead.origem.campaign),
                  _buildInfoRow('Dispositivo', widget.lead.origem.device),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Analytics
            if (widget.lead.analytics != null) ...[
              _buildSection(
                title: 'Métricas de Engajamento',
                child: Column(
                  children: [
                    _buildAnalyticsCard(
                      'Tempo na Página',
                      _formatDuration(widget.lead.analytics!.timeOnPageSeconds),
                      Icons.access_time,
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildAnalyticsCard(
                      'Tempo no Formulário',
                      _formatDuration(widget.lead.analytics!.timeToFillFormSeconds),
                      Icons.edit,
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildAnalyticsCard(
                      'Interações no Formulário',
                      '${widget.lead.analytics!.formInteractions} vezes',
                      Icons.touch_app,
                      Colors.purple,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Horário de Submissão',
                      _formatTime(widget.lead.createdAt),
                    ),
                    _buildInfoRow(
                      'Dia da Semana',
                      _formatDayOfWeek(widget.lead.createdAt),
                    ),
                    _buildInfoRow(
                      'Data',
                      _formatDate(widget.lead.createdAt),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Status e Qualificação
            _buildSection(
              title: 'Status',
              child: Column(
                children: [
                  _buildInfoRow('Status', AppTheme.getStatusDisplay(_currentStatus)),
                  _buildInfoRow('Qualificação', _formatQualificacao(_currentQualificacao)),
                  _buildInfoRow(
                    'Criado em',
                    _formatDateTime(widget.lead.createdAt),
                  ),
                  _buildInfoRow(
                    'Atualizado em',
                    _formatDateTime(widget.lead.updatedAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Agendamentos
            _buildAgendamentosSection(),
            const SizedBox(height: 16),

            // Timeline de Interações
            _buildInteracoesTimeline(),
            const SizedBox(height: 24),

            // Ações
            _buildActionsSection(context),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                color: highlight ? Colors.green : Colors.black,
                fontSize: highlight ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusQualificacaoControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestão do Lead',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown de Status
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text(
                    'Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _currentStatus,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'novo', child: Text('Novo')),
                      DropdownMenuItem(value: 'orcamento_enviado', child: Text('Orçamento Enviado')),
                      DropdownMenuItem(value: 'em_contato', child: Text('Em Contato')),
                      DropdownMenuItem(value: 'negociacao', child: Text('Negociação')),
                      DropdownMenuItem(value: 'fechado', child: Text('Fechado')),
                      DropdownMenuItem(value: 'perdido', child: Text('Perdido')),
                    ],
                    onChanged: (newStatus) {
                      if (newStatus != null && newStatus != _currentStatus) {
                        setState(() => _currentStatus = newStatus);
                        context.read<LeadsBloc>().add(
                          UpdateLeadStatusEvent(
                            leadId: widget.lead.id,
                            newStatus: newStatus,
                          ),
                        );

                        // Feedback visual
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Status atualizado para: ${AppTheme.getStatusDisplay(newStatus)}'),
                            backgroundColor: AppTheme.successGreen,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Seletor de Qualificação
            Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text(
                    'Qualificação:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildQualificacaoChip('frio', 'Frio 🔵', AppTheme.getQualificacaoColor('frio')),
                      const SizedBox(width: 8),
                      _buildQualificacaoChip('morno', 'Morno 🟡', AppTheme.getQualificacaoColor('morno')),
                      const SizedBox(width: 8),
                      _buildQualificacaoChip('quente', 'Quente 🔴', AppTheme.getQualificacaoColor('quente')),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualificacaoChip(String value, String label, Color color) {
    final isSelected = _currentQualificacao.toLowerCase() == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            setState(() => _currentQualificacao = value);
            context.read<LeadsBloc>().add(
              UpdateLeadQualificacaoEvent(
                leadId: widget.lead.id,
                newQualificacao: value,
              ),
            );

            // Feedback visual
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Qualificação atualizada para: $label'),
                backgroundColor: AppTheme.successGreen,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteracoesTimeline() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('interacoes')
          .where('lead_id', isEqualTo: widget.lead.id)
          .orderBy('data_hora', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('❌ ERRO AO CARREGAR INTERAÇÕES: ${snapshot.error}');
          return _buildSection(
            title: 'Timeline de Interações',
            child: Center(
              child: Text('Erro: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSection(
            title: 'Timeline de Interações',
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final interacoes = snapshot.data?.docs
            .map((doc) => Interacao.fromFirestore(doc))
            .toList() ?? [];

        if (interacoes.isEmpty) {
          return _buildSection(
            title: 'Timeline de Interações',
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Nenhuma interação registrada ainda',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showAddNotaDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Nota'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryYellow,
                    foregroundColor: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          );
        }

        return _buildSection(
          title: 'Timeline de Interações (${interacoes.length})',
          child: Column(
            children: [
              ...interacoes.map((interacao) => _buildTimelineItem(interacao)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _showAddNotaDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Nota'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineItem(Interacao interacao) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getInteracaoColor(interacao.tipo).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getInteracaoColor(interacao.tipo),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                interacao.icone,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      interacao.tipoDisplayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(interacao.dataHora),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  interacao.descricao,
                  style: const TextStyle(fontSize: 13),
                ),
                if (interacao.observacoes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    interacao.observacoes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (interacao.tipo == 'status_change' &&
                    interacao.statusAnterior != null &&
                    interacao.statusNovo != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatStatus(interacao.statusAnterior!),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, size: 12),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.getStatusColor(interacao.statusNovo!)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatStatus(interacao.statusNovo!),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getInteracaoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'ligacao':
        return Colors.green;
      case 'whatsapp':
        return Colors.green;
      case 'email':
        return Colors.red;
      case 'reuniao':
      case 'visita':
        return Colors.purple;
      case 'agendamento_concluido':
        return Colors.green;
      case 'status_change':
        return Colors.orange;
      case 'nota':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}sem atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}m atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}a atrás';
    }
  }

  Future<void> _showAddNotaDialog() async {
    await showDialog<bool>(
      context: context,
      builder: (context) => AddNotaDialog(
        leadId: widget.lead.id,
        leadNome: widget.lead.nome,
      ),
    );
  }

  Future<void> _showAddAgendamentoDialog() async {
    await showDialog<bool>(
      context: context,
      builder: (context) => AddAgendamentoDialog(
        leadId: widget.lead.id,
        leadNome: widget.lead.nome,
      ),
    );
  }

  Widget _buildAgendamentosSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('agendamentos')
          .where('lead_id', isEqualTo: widget.lead.id)
          .where('concluido', isEqualTo: false)
          .orderBy('data_hora', descending: false)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('❌ ERRO AO CARREGAR AGENDAMENTOS: ${snapshot.error}');
          return _buildSection(
            title: 'Agendamentos',
            child: Center(
              child: Text('Erro: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSection(
            title: 'Agendamentos',
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final agendamentos = snapshot.data?.docs
            .map((doc) => Agendamento.fromFirestore(doc))
            .toList() ?? [];

        if (agendamentos.isEmpty) {
          return _buildSection(
            title: 'Agendamentos',
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Nenhum agendamento pendente',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showAddAgendamentoDialog(),
                  icon: const Icon(Icons.event),
                  label: const Text('Novo Agendamento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryYellow,
                    foregroundColor: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          );
        }

        return _buildSection(
          title: 'Agendamentos Pendentes (${agendamentos.length})',
          child: Column(
            children: [
              ...agendamentos.map((agendamento) => _buildAgendamentoItem(agendamento)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _showAddAgendamentoDialog(),
                icon: const Icon(Icons.event),
                label: const Text('Novo Agendamento'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAgendamentoItem(Agendamento agendamento) {
    final isAtrasado = agendamento.estaAtrasado;
    final isHoje = agendamento.eHoje;
    final isAmanha = agendamento.eAmanha;

    Color cardColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    String badge = '';

    if (isAtrasado) {
      cardColor = Colors.red[50]!;
      borderColor = AppTheme.dangerRed;
      badge = '⚠️ ATRASADO';
    } else if (isHoje) {
      cardColor = Colors.orange[50]!;
      borderColor = Colors.orange;
      badge = '📍 HOJE';
    } else if (isAmanha) {
      cardColor = Colors.blue[50]!;
      borderColor = Colors.blue;
      badge = '📌 AMANHÃ';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getAgendamentoColor(agendamento.tipo).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getAgendamentoColor(agendamento.tipo),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              _getAgendamentoIcon(agendamento.tipo),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _getAgendamentoTipoDisplay(agendamento.tipo),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (badge.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  isHoje
                      ? _formatTime(agendamento.dataHora)
                      : _formatDateTime(agendamento.dataHora),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    agendamento.local,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            if (agendamento.observacoes != null) ...[
              const SizedBox(height: 2),
              Text(
                agendamento.observacoes!,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.check_circle_outline),
          color: AppTheme.successGreen,
          tooltip: 'Marcar como concluído',
          onPressed: () => _marcarAgendamentoConcluido(agendamento),
        ),
      ),
    );
  }

  String _getAgendamentoIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'visita':
        return '🏠';
      case 'reuniao':
        return '🤝';
      case 'ligacao':
        return '📞';
      case 'apresentacao':
        return '📊';
      default:
        return '📅';
    }
  }

  String _getAgendamentoTipoDisplay(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'visita':
        return 'Visita Técnica';
      case 'reuniao':
        return 'Reunião';
      case 'ligacao':
        return 'Ligação Agendada';
      case 'apresentacao':
        return 'Apresentação de Proposta';
      default:
        return tipo;
    }
  }

  Color _getAgendamentoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'visita':
        return Colors.purple;
      case 'reuniao':
        return Colors.blue;
      case 'ligacao':
        return Colors.green;
      case 'apresentacao':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _marcarAgendamentoConcluido(Agendamento agendamento) async {
    String resultadoTexto = '';

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marcar como Concluído'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Deseja marcar "${_getAgendamentoTipoDisplay(agendamento.tipo)}" como concluído?'),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Resultado (opcional)',
                  hintText: 'Ex: Cliente interessado, enviar proposta',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                autofocus: true,
                onChanged: (value) {
                  resultadoTexto = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      final resultadoFinal = resultadoTexto.trim();

      try {
        await FirebaseFirestore.instance
            .collection('agendamentos')
            .doc(agendamento.id)
            .update({
          'concluido': true,
          'data_hora_conclusao': Timestamp.now(),
          if (resultadoFinal.isNotEmpty) 'resultado_reuniao': resultadoFinal,
        });

        // Registrar interação
        await FirebaseFirestore.instance.collection('interacoes').add({
          'lead_id': widget.lead.id,
          'data_hora': Timestamp.now(),
          'tipo': 'agendamento_concluido',
          'descricao': 'Agendamento concluído: ${_getAgendamentoTipoDisplay(agendamento.tipo)}',
          'observacoes': resultadoFinal.isEmpty ? null : resultadoFinal,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Agendamento marcado como concluído!'),
              backgroundColor: AppTheme.successGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${e.toString()}'),
              backgroundColor: AppTheme.dangerRed,
            ),
          );
        }
      }
    }
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _makePhoneCall(widget.lead.telefone),
          icon: const Icon(Icons.phone),
          label: const Text('Ligar para o Cliente'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _openWhatsApp(widget.lead.telefone, widget.lead.nome),
          icon: const Icon(Icons.message),
          label: const Text('Enviar WhatsApp'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _sendEmail(widget.lead.email, widget.lead.nome),
          icon: const Icon(Icons.email),
          label: const Text('Enviar E-mail'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  String _formatTipoTelhado(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'ceramico':
        return 'Cerâmico';
      case 'metalico':
        return 'Metálico';
      case 'laje':
        return 'Laje';
      default:
        return tipo;
    }
  }

  String _formatTipoServico(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'comercio':
        return 'Comércio';
      case 'escola':
        return 'Escola';
      case 'industria':
        return 'Indústria';
      case 'condominio':
        return 'Condomínio';
      case 'mercado_livre':
        return 'Mercado Livre';
      default:
        return tipo;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'novo':
        return 'Novo';
      case 'em_atendimento':
        return 'Em Atendimento';
      case 'proposta_enviada':
        return 'Proposta Enviada';
      case 'convertido':
        return 'Convertido';
      case 'perdido':
        return 'Perdido';
      default:
        return status;
    }
  }

  String _formatQualificacao(String qualificacao) {
    switch (qualificacao.toLowerCase()) {
      case 'frio':
        return 'Frio 🔵';
      case 'morno':
        return 'Morno 🟡';
      case 'quente':
        return 'Quente 🔴';
      default:
        return qualificacao;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String _formatDayOfWeek(DateTime dateTime) {
    const days = ['Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];
    return days[dateTime.weekday % 7];
  }

  double _calcularInvestimento(int consumoKwh) {
    // Tabela de investimentos baseada no consumo
    const Map<int, double> tabelaInvestimentos = {
      250: 11500.00,
      500: 15500.00,
      800: 19500.00,
      1000: 25500.00,
    };

    // Se o valor exato existe na tabela, retornar
    if (tabelaInvestimentos.containsKey(consumoKwh)) {
      return tabelaInvestimentos[consumoKwh]!;
    }

    // Encontrar os valores mais próximos para interpolar
    final chaves = tabelaInvestimentos.keys.toList()..sort();

    // Se for menor que o menor valor, usar o menor
    if (consumoKwh < chaves.first) {
      return tabelaInvestimentos[chaves.first]!;
    }

    // Se for maior que o maior valor, usar o maior
    if (consumoKwh > chaves.last) {
      return tabelaInvestimentos[chaves.last]!;
    }

    // Interpolar entre os valores mais próximos
    for (int i = 0; i < chaves.length - 1; i++) {
      final menor = chaves[i];
      final maior = chaves[i + 1];

      if (consumoKwh >= menor && consumoKwh <= maior) {
        final valorMenor = tabelaInvestimentos[menor]!;
        final valorMaior = tabelaInvestimentos[maior]!;

        // Interpolação linear
        final proporcao = (consumoKwh - menor) / (maior - menor);
        return valorMenor + (valorMaior - valorMenor) * proporcao;
      }
    }

    // Fallback (não deveria chegar aqui)
    return tabelaInvestimentos[500]!;
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds segundos';
    } else if (seconds < 3600) {
      final minutes = (seconds / 60).floor();
      final remainingSeconds = seconds % 60;
      return '$minutes min ${remainingSeconds}s';
    } else {
      final hours = (seconds / 3600).floor();
      final minutes = ((seconds % 3600) / 60).floor();
      return '$hours h ${minutes} min';
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Limpar telefone removendo caracteres especiais
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

      // Adicionar código do Brasil (+55) se não tiver código de país
      // Telefones brasileiros têm 11 dígitos (DDD + número)
      if (cleanPhone.length == 11 && !cleanPhone.startsWith('55')) {
        cleanPhone = '55$cleanPhone';
      }

      final uri = Uri.parse('tel:+$cleanPhone');
      debugPrint('🔍 Tentando fazer ligação para: tel:+$cleanPhone');

      // Tentar abrir o discador
      await launchUrl(uri);

      // Registrar interação automaticamente
      try {
        await FirebaseFirestore.instance.collection('interacoes').add({
          'lead_id': widget.lead.id,
          'data_hora': Timestamp.now(),
          'tipo': 'ligacao',
          'descricao': 'Ligação realizada para ${widget.lead.nome}',
          'observacoes': 'Telefone: $phoneNumber',
        });

        // Atualizar última interação
        await FirebaseFirestore.instance
            .collection('leads')
            .doc(widget.lead.id)
            .update({
          'ultima_interacao': Timestamp.now(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📞 Ligação registrada!'),
              backgroundColor: AppTheme.successGreen,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        debugPrint('Erro ao registrar ligação: $e');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível abrir o discador. Telefone: $phoneNumber'),
            backgroundColor: AppTheme.dangerRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber, String nome) async {
    try {
      // Limpar telefone removendo caracteres especiais
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

      // WhatsApp precisa do código do país sem o +
      // Adicionar código do Brasil (55) se não tiver
      if (cleanPhone.length == 11 && !cleanPhone.startsWith('55')) {
        cleanPhone = '55$cleanPhone';
      }

      final message = Uri.encodeComponent(
        'Olá $nome! Vi seu interesse em energia solar através do nosso site. Como posso ajudá-lo?',
      );
      final uri = Uri.parse('https://wa.me/$cleanPhone?text=$message');
      debugPrint('🔍 Tentando abrir WhatsApp para: https://wa.me/$cleanPhone');

      // Abrir WhatsApp em aplicativo externo
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      // Registrar interação automaticamente
      try {
        await FirebaseFirestore.instance.collection('interacoes').add({
          'lead_id': widget.lead.id,
          'data_hora': Timestamp.now(),
          'tipo': 'whatsapp',
          'descricao': 'Mensagem WhatsApp enviada para $nome',
          'observacoes': 'Telefone: $phoneNumber',
        });

        // Atualizar última interação
        await FirebaseFirestore.instance
            .collection('leads')
            .doc(widget.lead.id)
            .update({
          'ultima_interacao': Timestamp.now(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('💬 WhatsApp registrado!'),
              backgroundColor: AppTheme.successGreen,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        debugPrint('Erro ao registrar WhatsApp: $e');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível abrir WhatsApp. Tel: $phoneNumber'),
            backgroundColor: AppTheme.dangerRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _sendEmail(String email, String nome) async {
    try {
      final subject = Uri.encodeComponent('Proposta de Energia Solar - Grupo Solar');
      final body = Uri.encodeComponent(
        'Olá $nome,\n\nObrigado pelo seu interesse em energia solar!\n\nEstamos preparando uma proposta personalizada para você.\n\nAtenciosamente,\nGrupo Solar',
      );
      final uri = Uri.parse('mailto:$email?subject=$subject&body=$body');
      debugPrint('🔍 Tentando abrir cliente de e-mail para: mailto:$email');

      // Tentar abrir cliente de e-mail
      await launchUrl(uri);

      // Registrar interação automaticamente
      try {
        await FirebaseFirestore.instance.collection('interacoes').add({
          'lead_id': widget.lead.id,
          'data_hora': Timestamp.now(),
          'tipo': 'email',
          'descricao': 'E-mail enviado para $nome',
          'observacoes': 'Destinatário: $email',
        });

        // Atualizar última interação
        await FirebaseFirestore.instance
            .collection('leads')
            .doc(widget.lead.id)
            .update({
          'ultima_interacao': Timestamp.now(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📧 E-mail registrado!'),
              backgroundColor: AppTheme.successGreen,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        debugPrint('Erro ao registrar e-mail: $e');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível abrir o cliente de e-mail. Email: $email'),
            backgroundColor: AppTheme.dangerRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
