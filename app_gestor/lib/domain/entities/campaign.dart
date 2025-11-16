import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  final String? id;
  final String nome;
  final String utmSource;
  final String utmMedium;
  final String utmCampaign;
  final String? utmContent;
  final String urlCompleta;
  final DateTime createdAt;
  final String createdBy;
  final bool ativo;
  final int totalLeads;

  Campaign({
    this.id,
    required this.nome,
    required this.utmSource,
    required this.utmMedium,
    required this.utmCampaign,
    this.utmContent,
    required this.urlCompleta,
    required this.createdAt,
    required this.createdBy,
    this.ativo = true,
    this.totalLeads = 0,
  });

  factory Campaign.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Campaign(
      id: doc.id,
      nome: data['nome'] as String,
      utmSource: data['utm_source'] as String,
      utmMedium: data['utm_medium'] as String,
      utmCampaign: data['utm_campaign'] as String,
      utmContent: data['utm_content'] as String?,
      urlCompleta: data['url_completa'] as String,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      createdBy: data['created_by'] as String,
      ativo: data['ativo'] as bool? ?? true,
      totalLeads: data['total_leads'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'utm_source': utmSource,
      'utm_medium': utmMedium,
      'utm_campaign': utmCampaign,
      'utm_content': utmContent,
      'url_completa': urlCompleta,
      'created_at': Timestamp.fromDate(createdAt),
      'created_by': createdBy,
      'ativo': ativo,
      'total_leads': totalLeads,
    };
  }

  Campaign copyWith({
    String? id,
    String? nome,
    String? utmSource,
    String? utmMedium,
    String? utmCampaign,
    String? utmContent,
    String? urlCompleta,
    DateTime? createdAt,
    String? createdBy,
    bool? ativo,
    int? totalLeads,
  }) {
    return Campaign(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      utmSource: utmSource ?? this.utmSource,
      utmMedium: utmMedium ?? this.utmMedium,
      utmCampaign: utmCampaign ?? this.utmCampaign,
      utmContent: utmContent ?? this.utmContent,
      urlCompleta: urlCompleta ?? this.urlCompleta,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      ativo: ativo ?? this.ativo,
      totalLeads: totalLeads ?? this.totalLeads,
    );
  }

  // Helper para gerar URL completa com UTM parameters
  static String generateUrl({
    required String baseUrl,
    required String source,
    required String medium,
    required String campaign,
    String? content,
  }) {
    final uri = Uri.parse(baseUrl);
    final params = <String, String>{
      'utm_source': source,
      'utm_medium': medium,
      'utm_campaign': campaign,
    };

    if (content != null && content.isNotEmpty) {
      params['utm_content'] = content;
    }

    final newUri = uri.replace(queryParameters: params);
    return newUri.toString();
  }

  // Validar nome de campanha (sem espaços, apenas letras minúsculas e hífens)
  static String sanitizeCampaignName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9\-]'), '')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  // Ícone baseado no source
  String get icon {
    switch (utmSource.toLowerCase()) {
      case 'instagram':
        return '📱';
      case 'facebook':
        return '👍';
      case 'google':
        return '🔍';
      case 'email':
        return '📧';
      case 'whatsapp':
        return '💬';
      case 'linkedin':
        return '💼';
      case 'youtube':
        return '📺';
      case 'tiktok':
        return '🎵';
      default:
        return '🔗';
    }
  }
}
