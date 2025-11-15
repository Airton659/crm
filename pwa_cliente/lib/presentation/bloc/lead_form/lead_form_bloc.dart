import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/analytics_tracker.dart';
import '../../../core/utils/utm_parser.dart';
import '../../../domain/entities/lead.dart';
import '../../../domain/usecases/submit_lead.dart';
import 'lead_form_event.dart';
import 'lead_form_state.dart';

class LeadFormBloc extends Bloc<LeadFormEvent, LeadFormState> {
  final SubmitLead submitLead;

  LeadFormBloc({required this.submitLead}) : super(LeadFormInitial()) {
    on<SubmitLeadFormEvent>(_onSubmitLeadForm);
  }

  Future<void> _onSubmitLeadForm(
    SubmitLeadFormEvent event,
    Emitter<LeadFormState> emit,
  ) async {
    emit(LeadFormSubmitting());

    // Capturar parâmetros UTM da URL
    final utmParams = UtmParser.captureUtmParameters();
    final deviceInfo = UtmParser.captureDeviceInfo();

    // Capturar métricas de analytics
    final analytics = AnalyticsTracker.captureMetrics();

    // Criar entidade de origem
    final origem = OrigemLead(
      source: utmParams['source'] ?? 'direto',
      medium: utmParams['medium'] ?? 'none',
      campaign: utmParams['campaign'] ?? '',
      content: utmParams['content'] ?? '',
      term: utmParams['term'] ?? '',
      referrer: utmParams['referrer'] ?? '',
      landingPage: utmParams['landing_page'] ?? '/',
      userAgent: deviceInfo['user_agent'] ?? '',
      device: deviceInfo['device'] ?? '',
      browser: deviceInfo['browser'] ?? '',
      os: deviceInfo['os'] ?? '',
    );

    // Criar lead
    final lead = Lead(
      nome: event.nome,
      email: event.email,
      telefone: event.telefone,
      consumoKwh: event.consumoKwh,
      tipoTelhado: event.tipoTelhado,
      tipoServico: event.tipoServico,
      origem: origem,
      status: 'novo',
      createdAt: DateTime.now(),
      analytics: analytics,
    );

    // Enviar lead
    final result = await submitLead(lead);

    result.fold(
      (error) => emit(LeadFormError(message: error)),
      (_) => emit(const LeadFormSuccess()),
    );
  }
}
