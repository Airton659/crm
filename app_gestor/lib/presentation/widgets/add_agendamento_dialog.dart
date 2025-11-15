import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/agendamento.dart';

class AddAgendamentoDialog extends StatefulWidget {
  final String leadId;
  final String leadNome;

  const AddAgendamentoDialog({
    super.key,
    required this.leadId,
    required this.leadNome,
  });

  @override
  State<AddAgendamentoDialog> createState() => _AddAgendamentoDialogState();
}

class _AddAgendamentoDialogState extends State<AddAgendamentoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _localController = TextEditingController();
  final _observacoesController = TextEditingController();

  String _tipoSelecionado = 'reuniao';
  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();
  bool _isLoading = false;

  final Map<String, String> _tiposAgendamento = {
    'visita': 'Visita Técnica 🏠',
    'reuniao': 'Reunião 🤝',
    'ligacao': 'Ligação Agendada 📞',
    'apresentacao': 'Apresentação de Proposta 📊',
  };

  @override
  void dispose() {
    _localController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null && picked != _dataSelecionada) {
      setState(() => _dataSelecionada = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _horaSelecionada) {
      setState(() => _horaSelecionada = picked);
    }
  }

  Future<void> _saveAgendamento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dataHora = DateTime(
        _dataSelecionada.year,
        _dataSelecionada.month,
        _dataSelecionada.day,
        _horaSelecionada.hour,
        _horaSelecionada.minute,
      );

      final agendamento = Agendamento(
        id: '', // Firestore vai gerar
        leadId: widget.leadId,
        dataHora: dataHora,
        tipo: _tipoSelecionado,
        local: _localController.text.trim(),
        observacoes: _observacoesController.text.trim().isEmpty
            ? null
            : _observacoesController.text.trim(),
        concluido: false,
      );

      await FirebaseFirestore.instance
          .collection('agendamentos')
          .add(agendamento.toMap());

      // Atualizar próximo agendamento no lead
      await FirebaseFirestore.instance
          .collection('leads')
          .doc(widget.leadId)
          .update({
        'proximo_agendamento': Timestamp.fromDate(dataHora),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Registrar interação
      await FirebaseFirestore.instance.collection('interacoes').add({
        'lead_id': widget.leadId,
        'data_hora': Timestamp.now(),
        'tipo': 'agendamento',
        'descricao': 'Agendamento criado: ${_tiposAgendamento[_tipoSelecionado]}',
        'observacoes': 'Data/Hora: ${_formatDateTime(dataHora)}',
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento criado com sucesso!'),
            backgroundColor: AppTheme.successGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar agendamento: ${e.toString()}'),
            backgroundColor: AppTheme.dangerRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Text('📅 '),
          Expanded(
            child: Text(
              'Novo Agendamento - ${widget.leadNome}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo de agendamento
              DropdownButtonFormField<String>(
                value: _tipoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Agendamento',
                  border: OutlineInputBorder(),
                ),
                items: _tiposAgendamento.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _tipoSelecionado = value);
                        }
                      },
              ),
              const SizedBox(height: 16),

              // Data
              InkWell(
                onTap: _isLoading ? null : _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_formatDate(_dataSelecionada)),
                ),
              ),
              const SizedBox(height: 16),

              // Hora
              InkWell(
                onTap: _isLoading ? null : _selectTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Horário',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  child: Text('${_horaSelecionada.hour.toString().padLeft(2, '0')}:${_horaSelecionada.minute.toString().padLeft(2, '0')}'),
                ),
              ),
              const SizedBox(height: 16),

              // Local
              TextFormField(
                controller: _localController,
                decoration: const InputDecoration(
                  labelText: 'Local *',
                  hintText: 'Ex: Escritório, residência do cliente, online',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe o local';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Observações
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  hintText: 'Detalhes adicionais...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                enabled: !_isLoading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _saveAgendamento,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.event_available),
          label: Text(_isLoading ? 'Salvando...' : 'Agendar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
