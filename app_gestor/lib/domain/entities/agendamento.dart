import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Agendamento extends Equatable {
  final String id;
  final String leadId;
  final DateTime dataHora;
  final String tipo; // 'visita', 'reuniao', 'ligacao', 'apresentacao'
  final String local;
  final String? observacoes;
  final bool concluido;
  final DateTime? dataHoraConclusao;
  final String? resultadoReuniao; // 'positivo', 'negativo', 'neutro'

  const Agendamento({
    required this.id,
    required this.leadId,
    required this.dataHora,
    required this.tipo,
    this.local = '',
    this.observacoes,
    this.concluido = false,
    this.dataHoraConclusao,
    this.resultadoReuniao,
  });

  factory Agendamento.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Agendamento(
      id: doc.id,
      leadId: data['lead_id'] ?? '',
      dataHora: (data['data_hora'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tipo: data['tipo'] ?? 'reuniao',
      local: data['local'] ?? '',
      observacoes: data['observacoes'],
      concluido: data['concluido'] ?? false,
      dataHoraConclusao: (data['data_hora_conclusao'] as Timestamp?)?.toDate(),
      resultadoReuniao: data['resultado_reuniao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lead_id': leadId,
      'data_hora': Timestamp.fromDate(dataHora),
      'tipo': tipo,
      'local': local,
      'observacoes': observacoes,
      'concluido': concluido,
      'data_hora_conclusao': dataHoraConclusao != null
          ? Timestamp.fromDate(dataHoraConclusao!)
          : null,
      'resultado_reuniao': resultadoReuniao,
    };
  }

  // Helper para ícone baseado no tipo
  String get icone {
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

  // Helper para display name do tipo
  String get tipoDisplayName {
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
        return 'Agendamento';
    }
  }

  // Helper para verificar se está atrasado
  bool get estaAtrasado {
    return !concluido && dataHora.isBefore(DateTime.now());
  }

  // Helper para verificar se é hoje
  bool get eHoje {
    final agora = DateTime.now();
    return dataHora.year == agora.year &&
           dataHora.month == agora.month &&
           dataHora.day == agora.day;
  }

  // Helper para verificar se é amanhã
  bool get eAmanha {
    final amanha = DateTime.now().add(const Duration(days: 1));
    return dataHora.year == amanha.year &&
           dataHora.month == amanha.month &&
           dataHora.day == amanha.day;
  }

  @override
  List<Object?> get props => [
        id,
        leadId,
        dataHora,
        tipo,
        local,
        observacoes,
        concluido,
        dataHoraConclusao,
        resultadoReuniao,
      ];
}
