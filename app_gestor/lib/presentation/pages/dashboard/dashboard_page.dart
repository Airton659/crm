import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/leads/leads_bloc.dart';
import '../../bloc/leads/leads_event.dart';
import '../../bloc/leads/leads_state.dart';
import '../../bloc/statistics/statistics_bloc.dart';
import '../../bloc/statistics/statistics_event.dart';
import '../../bloc/statistics/statistics_state.dart';
import '../../../core/theme/app_theme.dart';
import '../lead_details_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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

                  // Lista de Leads
                  const Text(
                    'Leads Recentes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
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
                        if (state.leads.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('Nenhum lead encontrado'),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.leads.length,
                          itemBuilder: (context, index) {
                            final lead = state.leads[index];
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
