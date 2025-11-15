import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/lead.dart';

class LeadDetailsPage extends StatelessWidget {
  final Lead lead;

  const LeadDetailsPage({
    super.key,
    required this.lead,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lead.nome),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _makePhoneCall(lead.telefone),
            tooltip: 'Ligar',
          ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () => _openWhatsApp(lead.telefone, lead.nome),
            tooltip: 'WhatsApp',
          ),
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: () => _sendEmail(lead.email, lead.nome),
            tooltip: 'Enviar e-mail',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações do Lead
            _buildSection(
              title: 'Informações do Lead',
              child: Column(
                children: [
                  _buildInfoRow('Nome', lead.nome),
                  _buildInfoRow('Email', lead.email),
                  _buildInfoRow('Telefone', lead.telefone),
                  _buildInfoRow('Consumo', '${lead.consumoKwh} kWh/mês'),
                  _buildInfoRow('Tipo de Telhado', _formatTipoTelhado(lead.tipoTelhado)),
                  if (lead.tipoServico != null)
                    _buildInfoRow('Tipo de Serviço', _formatTipoServico(lead.tipoServico!)),
                  if (lead.valorEstimado != null)
                    _buildInfoRow(
                      'Valor Estimado',
                      'R\$ ${lead.valorEstimado!.toStringAsFixed(2)}',
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
                  _buildInfoRow('Fonte', lead.origem.displayName),
                  _buildInfoRow('Meio', lead.origem.medium),
                  if (lead.origem.campaign.isNotEmpty)
                    _buildInfoRow('Campanha', lead.origem.campaign),
                  _buildInfoRow('Dispositivo', lead.origem.device),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Analytics
            if (lead.analytics != null) ...[
              _buildSection(
                title: 'Métricas de Engajamento',
                child: Column(
                  children: [
                    _buildAnalyticsCard(
                      'Tempo na Página',
                      _formatDuration(lead.analytics!.timeOnPageSeconds),
                      Icons.access_time,
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildAnalyticsCard(
                      'Tempo no Formulário',
                      _formatDuration(lead.analytics!.timeToFillFormSeconds),
                      Icons.edit,
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildAnalyticsCard(
                      'Profundidade de Scroll',
                      '${lead.analytics!.scrollDepthPercent}%',
                      Icons.vertical_align_bottom,
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildAnalyticsCard(
                      'Interações no Formulário',
                      '${lead.analytics!.formInteractions} vezes',
                      Icons.touch_app,
                      Colors.purple,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Horário de Submissão',
                      lead.analytics!.submissionTime,
                    ),
                    _buildInfoRow(
                      'Dia da Semana',
                      lead.analytics!.submissionDayName,
                    ),
                    _buildInfoRow(
                      'Data',
                      lead.analytics!.submissionDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Status e Prioridade
            _buildSection(
              title: 'Status',
              child: Column(
                children: [
                  _buildInfoRow('Status', _formatStatus(lead.status)),
                  _buildInfoRow('Prioridade', _formatPrioridade(lead.prioridade)),
                  _buildInfoRow(
                    'Criado em',
                    _formatDateTime(lead.createdAt),
                  ),
                  _buildInfoRow(
                    'Atualizado em',
                    _formatDateTime(lead.updatedAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Ações
            _buildActionsSection(context),
          ],
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

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _makePhoneCall(lead.telefone),
          icon: const Icon(Icons.phone),
          label: const Text('Ligar para o Cliente'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _openWhatsApp(lead.telefone, lead.nome),
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
          onPressed: () => _sendEmail(lead.email, lead.nome),
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

  String _formatPrioridade(String prioridade) {
    switch (prioridade.toLowerCase()) {
      case 'baixa':
        return 'Baixa';
      case 'media':
        return 'Média';
      case 'alta':
        return 'Alta';
      default:
        return prioridade;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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

  Future<void> _sendEmail(String email, String nome) async {
    final subject = Uri.encodeComponent('Proposta de Energia Solar - Grupo Solar');
    final body = Uri.encodeComponent(
      'Olá $nome,\n\nObrigado pelo seu interesse em energia solar!\n\nEstamos preparando uma proposta personalizada para você.\n\nAtenciosamente,\nGrupo Solar',
    );
    final uri = Uri.parse('mailto:$email?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
