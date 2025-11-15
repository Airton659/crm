import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Interacao extends Equatable {
  final String id;
  final String leadId;
  final DateTime dataHora;
  final String tipo; // 'ligacao', 'whatsapp', 'email', 'reuniao', 'status_change', 'nota'
  final String descricao;
  final String? observacoes;
  final String? statusAnterior; // Para mudanças de status
  final String? statusNovo; // Para mudanças de status

  const Interacao({
    required this.id,
    required this.leadId,
    required this.dataHora,
    required this.tipo,
    required this.descricao,
    this.observacoes,
    this.statusAnterior,
    this.statusNovo,
  });

  factory Interacao.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Interacao(
      id: doc.id,
      leadId: data['lead_id'] ?? '',
      dataHora: (data['data_hora'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tipo: data['tipo'] ?? 'nota',
      descricao: data['descricao'] ?? '',
      observacoes: data['observacoes'],
      statusAnterior: data['status_anterior'],
      statusNovo: data['status_novo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lead_id': leadId,
      'data_hora': Timestamp.fromDate(dataHora),
      'tipo': tipo,
      'descricao': descricao,
      'observacoes': observacoes,
      'status_anterior': statusAnterior,
      'status_novo': statusNovo,
    };
  }

  // Helper para ícone baseado no tipo
  String get icone {
    switch (tipo.toLowerCase()) {
      case 'ligacao':
        return '📞';
      case 'whatsapp':
        return '💬';
      case 'email':
        return '📧';
      case 'reuniao':
      case 'visita':
        return '🤝';
      case 'status_change':
        return '🔄';
      case 'nota':
        return '📝';
      default:
        return '📋';
    }
  }

  // Helper para display name do tipo
  String get tipoDisplayName {
    switch (tipo.toLowerCase()) {
      case 'ligacao':
        return 'Ligação';
      case 'whatsapp':
        return 'WhatsApp';
      case 'email':
        return 'E-mail';
      case 'reuniao':
        return 'Reunião';
      case 'visita':
        return 'Visita';
      case 'status_change':
        return 'Mudança de Status';
      case 'nota':
        return 'Nota';
      default:
        return 'Interação';
    }
  }

  @override
  List<Object?> get props => [
        id,
        leadId,
        dataHora,
        tipo,
        descricao,
        observacoes,
        statusAnterior,
        statusNovo,
      ];
}
