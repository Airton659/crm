import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsData extends Equatable {
  final int timeOnPageSeconds;
  final int timeToFillFormSeconds;
  final int scrollDepthPercent;
  final int formInteractions;
  final int submissionHour;
  final String submissionTime; // Formato HH:mm (ex: "17:49")
  final int submissionDayOfWeek;
  final String submissionDayName;
  final String submissionDate;

  const AnalyticsData({
    required this.timeOnPageSeconds,
    required this.timeToFillFormSeconds,
    required this.scrollDepthPercent,
    required this.formInteractions,
    required this.submissionHour,
    required this.submissionTime,
    required this.submissionDayOfWeek,
    required this.submissionDayName,
    required this.submissionDate,
  });

  factory AnalyticsData.fromMap(Map<String, dynamic> map) {
    return AnalyticsData(
      timeOnPageSeconds: map['time_on_page_seconds'] ?? 0,
      timeToFillFormSeconds: map['time_to_fill_form_seconds'] ?? 0,
      scrollDepthPercent: map['scroll_depth_percent'] ?? 0,
      formInteractions: map['form_interactions'] ?? 0,
      submissionHour: map['submission_hour'] ?? 0,
      submissionTime: map['submission_time'] ?? '00:00',
      submissionDayOfWeek: map['submission_day_of_week'] ?? 0,
      submissionDayName: map['submission_day_name'] ?? '',
      submissionDate: map['submission_date'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
        timeOnPageSeconds,
        timeToFillFormSeconds,
        scrollDepthPercent,
        formInteractions,
        submissionHour,
        submissionTime,
        submissionDayOfWeek,
        submissionDayName,
        submissionDate,
      ];
}

class Lead extends Equatable {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final int consumoKwh;
  final String tipoTelhado;
  final String? tipoServico;
  final OrigemLead origem;
  final String status;
  final String prioridade;
  final String qualificacao; // 'frio', 'morno', 'quente'
  final DateTime? ultimaInteracao;
  final DateTime? proximoAgendamento;
  final String? observacoes;
  final double? valorEstimado;
  final double? valorProposta;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AnalyticsData? analytics;

  const Lead({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.consumoKwh,
    required this.tipoTelhado,
    this.tipoServico,
    required this.origem,
    required this.status,
    this.prioridade = 'media',
    this.qualificacao = 'morno',
    this.ultimaInteracao,
    this.proximoAgendamento,
    this.observacoes,
    this.valorEstimado,
    this.valorProposta,
    required this.createdAt,
    required this.updatedAt,
    this.analytics,
  });

  factory Lead.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Lead(
      id: doc.id,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      telefone: data['telefone'] ?? '',
      consumoKwh: data['consumo_kwh'] ?? 0,
      tipoTelhado: data['tipo_telhado'] ?? '',
      tipoServico: data['tipo_servico'],
      origem: OrigemLead.fromMap(data['origem'] ?? {}),
      status: data['status'] ?? 'novo',
      prioridade: data['prioridade'] ?? 'media',
      qualificacao: data['qualificacao'] ?? 'morno',
      ultimaInteracao: (data['ultima_interacao'] as Timestamp?)?.toDate(),
      proximoAgendamento: (data['proximo_agendamento'] as Timestamp?)?.toDate(),
      observacoes: data['observacoes'],
      valorEstimado: (data['valor_estimado'] as num?)?.toDouble(),
      valorProposta: (data['valor_proposta'] as num?)?.toDouble(),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      analytics: data['analytics'] != null
          ? AnalyticsData.fromMap(data['analytics'] as Map<String, dynamic>)
          : null,
    );
  }

  // Helper para get display name da qualificação
  String get qualificacaoDisplayName {
    switch (qualificacao.toLowerCase()) {
      case 'frio':
        return 'Frio 🔵';
      case 'morno':
        return 'Morno 🟡';
      case 'quente':
        return 'Quente 🔴';
      default:
        return 'Morno 🟡';
    }
  }

  // Helper para get emoji da qualificação
  String get qualificacaoEmoji {
    switch (qualificacao.toLowerCase()) {
      case 'frio':
        return '🔵';
      case 'morno':
        return '🟡';
      case 'quente':
        return '🔴';
      default:
        return '🟡';
    }
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        email,
        telefone,
        consumoKwh,
        tipoTelhado,
        tipoServico,
        origem,
        status,
        prioridade,
        qualificacao,
        ultimaInteracao,
        proximoAgendamento,
        observacoes,
        valorEstimado,
        valorProposta,
        createdAt,
        updatedAt,
        analytics,
      ];
}

class OrigemLead extends Equatable {
  final String source;
  final String medium;
  final String campaign;
  final String device;

  const OrigemLead({
    required this.source,
    required this.medium,
    this.campaign = '',
    this.device = '',
  });

  factory OrigemLead.fromMap(Map<String, dynamic> map) {
    return OrigemLead(
      source: map['source'] ?? 'direto',
      medium: map['medium'] ?? 'none',
      campaign: map['campaign'] ?? '',
      device: map['device'] ?? '',
    );
  }

  String get displayName {
    switch (source.toLowerCase()) {
      case 'google':
        return 'Buscas (Google)';
      case 'instagram':
      case 'ig':
        return 'Instagram';
      case 'facebook':
      case 'fb':
        return 'Facebook';
      case 'indicacao':
      case 'referral':
        return 'Indicação';
      case 'direto':
      case 'direct':
        return 'Acesso Direto';
      default:
        return 'Outros';
    }
  }

  @override
  List<Object?> get props => [source, medium, campaign, device];
}
