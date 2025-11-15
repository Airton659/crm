import 'package:equatable/equatable.dart';

class AnalyticsData extends Equatable {
  final int timeOnPageSeconds;
  final int timeToFillFormSeconds;
  final int scrollDepthPercent;
  final int formInteractions;
  final int submissionHour;
  final String submissionTime;
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

  Map<String, dynamic> toJson() {
    return {
      'time_on_page_seconds': timeOnPageSeconds,
      'time_to_fill_form_seconds': timeToFillFormSeconds,
      'scroll_depth_percent': scrollDepthPercent,
      'form_interactions': formInteractions,
      'submission_hour': submissionHour,
      'submission_time': submissionTime,
      'submission_day_of_week': submissionDayOfWeek,
      'submission_day_name': submissionDayName,
      'submission_date': submissionDate,
    };
  }

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      timeOnPageSeconds: json['time_on_page_seconds'] ?? 0,
      timeToFillFormSeconds: json['time_to_fill_form_seconds'] ?? 0,
      scrollDepthPercent: json['scroll_depth_percent'] ?? 0,
      formInteractions: json['form_interactions'] ?? 0,
      submissionHour: json['submission_hour'] ?? 0,
      submissionTime: json['submission_time'] ?? '00:00',
      submissionDayOfWeek: json['submission_day_of_week'] ?? 0,
      submissionDayName: json['submission_day_name'] ?? '',
      submissionDate: json['submission_date'] ?? '',
    );
  }
}

class Lead extends Equatable {
  final String? id;
  final String nome;
  final String email;
  final String telefone;
  final int consumoKwh;
  final String tipoTelhado;
  final String? tipoServico;
  final OrigemLead origem;
  final String status;
  final DateTime createdAt;
  final AnalyticsData? analytics;

  const Lead({
    this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.consumoKwh,
    required this.tipoTelhado,
    this.tipoServico,
    required this.origem,
    this.status = 'novo',
    required this.createdAt,
    this.analytics,
  });

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
        createdAt,
        analytics,
      ];
}

class OrigemLead extends Equatable {
  final String source;
  final String medium;
  final String campaign;
  final String content;
  final String term;
  final String referrer;
  final String landingPage;
  final String userAgent;
  final String device;
  final String browser;
  final String os;

  const OrigemLead({
    required this.source,
    required this.medium,
    this.campaign = '',
    this.content = '',
    this.term = '',
    this.referrer = '',
    this.landingPage = '',
    this.userAgent = '',
    this.device = '',
    this.browser = '',
    this.os = '',
  });

  @override
  List<Object?> get props => [
        source,
        medium,
        campaign,
        content,
        term,
        referrer,
        landingPage,
        userAgent,
        device,
        browser,
        os,
      ];

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'medium': medium,
      'campaign': campaign,
      'content': content,
      'term': term,
      'referrer': referrer,
      'landing_page': landingPage,
      'user_agent': userAgent,
      'device': device,
      'browser': browser,
      'os': os,
    };
  }
}
