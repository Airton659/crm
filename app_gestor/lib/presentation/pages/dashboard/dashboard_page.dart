import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/leads/leads_bloc.dart';
import '../../bloc/leads/leads_event.dart';
import '../../bloc/leads/leads_state.dart';
import '../../bloc/statistics/statistics_bloc.dart';
import '../../bloc/statistics/statistics_event.dart';
import '../../bloc/statistics/statistics_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/agendamento.dart';
import '../../../domain/entities/lead.dart';
import '../lead_details_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _selectedStatus;
  String? _selectedQualificacao;
  String? _selectedOrigem;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<LeadsBloc>().add(LoadLeadsEvent(
      statusFilter: _selectedStatus,
      origemFilter: _selectedOrigem,
    ));
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedQualificacao = null;
      _selectedOrigem = null;
      _searchQuery = '';
      _searchController.clear();
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icons/logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.solar_power, color: Color(0xFFF59E0B));
              },
            ),
            const SizedBox(width: 8),
            const Text('Painel do Gestor'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutEvent());
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: BlocBuilder<LeadsBloc, LeadsState>(
        builder: (context, leadsState) {
          // Mostrar loading enquanto os dados iniciais estão carregando
          if (leadsState is LeadsLoading || leadsState is LeadsInitial) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando dados...'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<LeadsBloc>().add(const LoadLeadsEvent());
              context.read<StatisticsBloc>().add(LoadStatisticsEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPIs
                  BlocBuilder<StatisticsBloc, StatisticsState>(
                    builder: (context, state) {
                      if (state is StatisticsLoaded) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _KpiCard(
                                    title: 'Novos Leads (Mês)',
                                    value: state.statistics.totalLeads.toString(),
                                    color: const Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _KpiCard(
                                    title: 'Orçamentos Enviados',
                                    value: state.statistics.totalOrcamentos.toString(),
                                    color: const Color(0xFF3B82F6),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _KpiCard(
                                    title: 'Projetos Fechados',
                                    value: state.statistics.totalFechados.toString(),
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _KpiCard(
                                    title: 'Taxa de Conversão',
                                    value: '${state.statistics.taxaConversao.toStringAsFixed(1)}%',
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }

                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  const SizedBox(height: 24),

                  // Dashboard de Agendamentos
                  _buildAgendamentosDashboard(),
                  const SizedBox(height: 24),

                  // Barra de Busca
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome, email ou telefone...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Filtros
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.filter_list, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Filtros',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              if (_selectedStatus != null ||
                                  _selectedQualificacao != null ||
                                  _selectedOrigem != null)
                                TextButton.icon(
                                  onPressed: _clearFilters,
                                  icon: const Icon(Icons.clear_all, size: 18),
                                  label: const Text('Limpar'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // Filtro de Status
                              _buildFilterChip(
                                label: _selectedStatus == null
                                    ? 'Status'
                                    : AppTheme.getStatusDisplay(_selectedStatus!),
                                isSelected: _selectedStatus != null,
                                onTap: () => _showStatusFilter(),
                              ),
                              // Filtro de Qualificação
                              _buildFilterChip(
                                label: _selectedQualificacao == null
                                    ? 'Qualificação'
                                    : AppTheme.getQualificacaoDisplay(_selectedQualificacao!),
                                isSelected: _selectedQualificacao != null,
                                onTap: () => _showQualificacaoFilter(),
                              ),
                              // Filtro de Origem
                              _buildFilterChip(
                                label: _selectedOrigem == null
                                    ? 'Origem'
                                    : _formatOrigem(_selectedOrigem!),
                                isSelected: _selectedOrigem != null,
                                onTap: () => _showOrigemFilter(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lista de Leads
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Leads',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      BlocBuilder<LeadsBloc, LeadsState>(
                        builder: (context, state) {
                          if (state is LeadsLoaded) {
                            final filteredLeads = _filterLeads(state.leads);
                            return Text(
                              '${filteredLeads.length} ${filteredLeads.length == 1 ? "lead" : "leads"}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  BlocBuilder<LeadsBloc, LeadsState>(
                    builder: (context, state) {
                      if (state is LeadsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is LeadsError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (state is LeadsLoaded) {
                        final filteredLeads = _filterLeads(state.leads);

                        if (filteredLeads.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.leads.isEmpty
                                        ? 'Nenhum lead encontrado'
                                        : 'Nenhum lead corresponde aos filtros',
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredLeads.length,
                          itemBuilder: (context, index) {
                            final lead = filteredLeads[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LeadDetailsPage(lead: lead),
                                    ),
                                  );
                                },
                                title: Text(
                                  lead.nome,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('${lead.email} | ${lead.telefone}'),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Origem: ${lead.origem.displayName}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    if (lead.ultimaInteracao != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Último contato: ${_formatLastInteraction(lead.ultimaInteracao!)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF9CA3AF),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Badge de qualificação
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.getQualificacaoColor(lead.qualificacao),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        lead.qualificacaoEmoji,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.phone, size: 20),
                                      onPressed: () => _makePhoneCall(lead.telefone),
                                      tooltip: 'Ligar',
                                      color: const Color(0xFF1E3A8A),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.message, size: 20),
                                      onPressed: () => _openWhatsApp(lead.telefone, lead.nome),
                                      tooltip: 'WhatsApp',
                                      color: const Color(0xFF10B981),
                                    ),
                                    Chip(
                                      label: Text(
                                        AppTheme.getStatusDisplay(lead.status),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: AppTheme.getStatusColor(lead.status),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAgendamentosDashboard() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('agendamentos')
          .where('concluido', isEqualTo: false)
          .orderBy('data_hora', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allAgendamentos = snapshot.data!.docs
            .map((doc) => Agendamento.fromFirestore(doc))
            .toList();

        // Separar agendamentos
        final atrasados = allAgendamentos
            .where((a) => a.dataHora.isBefore(startOfDay))
            .toList();

        final hoje = allAgendamentos
            .where((a) =>
                a.dataHora.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                a.dataHora.isBefore(endOfDay.add(const Duration(seconds: 1))))
            .toList();

        final proximos = allAgendamentos
            .where((a) => a.dataHora.isAfter(endOfDay))
            .take(3)
            .toList();

        // Se não há nenhum agendamento relevante, não mostrar a seção
        if (atrasados.isEmpty && hoje.isEmpty && proximos.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    const Text(
                      'Agenda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${atrasados.length + hoje.length + proximos.length} agendamentos',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Atrasados
                if (atrasados.isNotEmpty) ...[
                  _buildAgendamentoGroup(
                    '⚠️ ATRASADOS (${atrasados.length})',
                    atrasados,
                    Colors.red,
                  ),
                  const SizedBox(height: 12),
                ],

                // Hoje
                if (hoje.isNotEmpty) ...[
                  _buildAgendamentoGroup(
                    '📍 HOJE (${hoje.length})',
                    hoje,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                ],

                // Próximos
                if (proximos.isNotEmpty) ...[
                  _buildAgendamentoGroup(
                    '📅 PRÓXIMOS (${proximos.length})',
                    proximos,
                    AppTheme.primaryBlue,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgendamentoGroup(String title, List<Agendamento> agendamentos, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...agendamentos.map((agendamento) => _buildAgendamentoItemDashboard(agendamento, color)),
      ],
    );
  }

  Widget _buildAgendamentoItemDashboard(Agendamento agendamento, Color accentColor) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('leads')
          .doc(agendamento.leadId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final Lead lead = Lead.fromFirestore(snapshot.data!);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeadDetailsPage(lead: lead),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    _getAgendamentoIcon(agendamento.tipo),
                    color: accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getAgendamentoTipoDisplay(agendamento.tipo),
                          style: TextStyle(
                            fontSize: 12,
                            color: accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (agendamento.local.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            agendamento.local,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(agendamento.dataHora),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (!agendamento.eHoje) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatDateShort(agendamento.dataHora),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getAgendamentoIcon(String tipo) {
    switch (tipo) {
      case 'visita':
        return Icons.home_work;
      case 'reuniao':
        return Icons.handshake;
      case 'ligacao':
        return Icons.phone;
      case 'apresentacao':
        return Icons.present_to_all;
      default:
        return Icons.event;
    }
  }

  String _getAgendamentoTipoDisplay(String tipo) {
    switch (tipo) {
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

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  List<dynamic> _filterLeads(List<dynamic> leads) {
    var filtered = leads;

    // Filtro de qualificação (local, já que não está no backend)
    if (_selectedQualificacao != null) {
      filtered = filtered
          .where((lead) =>
              lead.qualificacao.toLowerCase() == _selectedQualificacao!.toLowerCase())
          .toList();
    }

    // Busca textual
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((lead) {
        final nome = lead.nome.toLowerCase();
        final email = lead.email.toLowerCase();
        final telefone = lead.telefone.toLowerCase();
        return nome.contains(_searchQuery) ||
            email.contains(_searchQuery) ||
            telefone.contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : const Color(0xFFD1D5DB),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF374151),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showStatusFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtrar por Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusOption('novo', 'Novo'),
              _buildStatusOption('orcamento_enviado', 'Orçamento Enviado'),
              _buildStatusOption('em_contato', 'Em Contato'),
              _buildStatusOption('negociacao', 'Negociação'),
              _buildStatusOption('fechado', 'Fechado'),
              _buildStatusOption('perdido', 'Perdido'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _selectedStatus = null);
                _applyFilters();
                Navigator.pop(context);
              },
              child: const Text('Limpar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusOption(String value, String label) {
    final isSelected = _selectedStatus == value;
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppTheme.getStatusColor(value),
          shape: BoxShape.circle,
        ),
      ),
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryBlue) : null,
      selected: isSelected,
      onTap: () {
        setState(() => _selectedStatus = value);
        _applyFilters();
        Navigator.pop(context);
      },
    );
  }

  void _showQualificacaoFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtrar por Qualificação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQualificacaoOption('frio', 'Frio 🔵'),
              _buildQualificacaoOption('morno', 'Morno 🟡'),
              _buildQualificacaoOption('quente', 'Quente 🔴'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _selectedQualificacao = null);
                Navigator.pop(context);
              },
              child: const Text('Limpar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQualificacaoOption(String value, String label) {
    final isSelected = _selectedQualificacao == value;
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppTheme.getQualificacaoColor(value),
          shape: BoxShape.circle,
        ),
      ),
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryBlue) : null,
      selected: isSelected,
      onTap: () {
        setState(() => _selectedQualificacao = value);
        Navigator.pop(context);
      },
    );
  }

  void _showOrigemFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtrar por Origem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOrigemOption('google', 'Google'),
              _buildOrigemOption('instagram', 'Instagram'),
              _buildOrigemOption('facebook', 'Facebook'),
              _buildOrigemOption('direct', 'Acesso Direto'),
              _buildOrigemOption('referral', 'Indicação'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _selectedOrigem = null);
                _applyFilters();
                Navigator.pop(context);
              },
              child: const Text('Limpar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrigemOption(String value, String label) {
    final isSelected = _selectedOrigem == value;
    return ListTile(
      leading: const Icon(Icons.public),
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryBlue) : null,
      selected: isSelected,
      onTap: () {
        setState(() => _selectedOrigem = value);
        _applyFilters();
        Navigator.pop(context);
      },
    );
  }

  String _formatOrigem(String origem) {
    switch (origem.toLowerCase()) {
      case 'google':
        return 'Google';
      case 'instagram':
        return 'Instagram';
      case 'facebook':
        return 'Facebook';
      case 'direct':
        return 'Acesso Direto';
      case 'referral':
        return 'Indicação';
      default:
        return origem;
    }
  }

  String _formatLastInteraction(DateTime lastInteraction) {
    final now = DateTime.now();
    final difference = now.difference(lastInteraction);

    if (difference.inMinutes < 1) {
      return 'agora mesmo';
    } else if (difference.inMinutes < 60) {
      return 'há ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'há ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'há ${difference.inDays}d';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'há ${weeks}sem';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'há ${months}m';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'há ${years}a';
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber, String nome) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final message = Uri.encodeComponent(
      'Olá $nome! Vi seu interesse em energia solar através do nosso site. Como posso ajudá-lo?',
    );
    final uri = Uri.parse('https://wa.me/55$cleanPhone?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
