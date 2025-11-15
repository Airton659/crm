import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/interacao.dart';

class AddNotaDialog extends StatefulWidget {
  final String leadId;
  final String leadNome;

  const AddNotaDialog({
    super.key,
    required this.leadId,
    required this.leadNome,
  });

  @override
  State<AddNotaDialog> createState() => _AddNotaDialogState();
}

class _AddNotaDialogState extends State<AddNotaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _observacoesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _descricaoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _saveNota() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final interacao = Interacao(
        id: '', // Firestore vai gerar
        leadId: widget.leadId,
        dataHora: DateTime.now(),
        tipo: 'nota',
        descricao: _descricaoController.text.trim(),
        observacoes: _observacoesController.text.trim().isEmpty
            ? null
            : _observacoesController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('interacoes')
          .add(interacao.toMap());

      // Atualizar última interação no lead
      await FirebaseFirestore.instance
          .collection('leads')
          .doc(widget.leadId)
          .update({
        'ultima_interacao': Timestamp.now(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nota adicionada com sucesso!'),
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
            content: Text('Erro ao salvar nota: ${e.toString()}'),
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
          const Text('📝 '),
          Expanded(
            child: Text(
              'Adicionar Nota - ${widget.leadNome}',
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
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição *',
                  hintText: 'Ex: Cliente interessado em orçamento',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  hintText: 'Detalhes adicionais...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 8),
              Text(
                'Data/Hora: ${_formatDateTime(DateTime.now())}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
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
          onPressed: _isLoading ? null : _saveNota,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(_isLoading ? 'Salvando...' : 'Salvar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
