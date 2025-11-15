import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_leads.dart';
import '../../../domain/usecases/update_lead_status.dart';
import '../../../domain/usecases/update_lead_qualificacao.dart';
import 'leads_event.dart';
import 'leads_state.dart';

class LeadsBloc extends Bloc<LeadsEvent, LeadsState> {
  final GetLeads getLeads;
  final UpdateLeadStatus updateLeadStatus;
  final UpdateLeadQualificacao updateLeadQualificacao;

  StreamSubscription? _leadsSubscription;

  LeadsBloc({
    required this.getLeads,
    required this.updateLeadStatus,
    required this.updateLeadQualificacao,
  }) : super(LeadsInitial()) {
    on<LoadLeadsEvent>(_onLoadLeads);
    on<UpdateLeadStatusEvent>(_onUpdateLeadStatus);
    on<UpdateLeadQualificacaoEvent>(_onUpdateLeadQualificacao);

    // Carregar leads automaticamente após pequeno delay para garantir que o Firebase Auth está pronto
    Future.delayed(const Duration(milliseconds: 500), () {
      add(const LoadLeadsEvent());
    });
  }

  Future<void> _onLoadLeads(LoadLeadsEvent event, Emitter<LeadsState> emit) async {
    // Cancelar stream anterior
    await _leadsSubscription?.cancel();

    // Emitir loading apenas se não for o mesmo filtro
    emit(LeadsLoading());

    // Criar nova subscription
    await emit.forEach(
      getLeads(
        statusFilter: event.statusFilter,
        origemFilter: event.origemFilter,
      ),
      onData: (result) {
        return result.fold(
          (error) {
            print('❌ Erro ao carregar leads: $error');
            return LeadsError(message: error);
          },
          (leads) {
            print('✅ Leads carregados: ${leads.length} leads');
            return LeadsLoaded(leads: leads);
          },
        );
      },
      onError: (error, stack) {
        print('❌ ERRO NO STREAM: $error');
        return LeadsError(message: 'Erro ao carregar leads: ${error.toString()}');
      },
    );
  }

  Future<void> _onUpdateLeadStatus(
    UpdateLeadStatusEvent event,
    Emitter<LeadsState> emit,
  ) async {
    final result = await updateLeadStatus(event.leadId, event.newStatus);

    result.fold(
      (error) => emit(LeadsError(message: error)),
      (_) {
        // Leads serão atualizados automaticamente via stream
      },
    );
  }

  Future<void> _onUpdateLeadQualificacao(
    UpdateLeadQualificacaoEvent event,
    Emitter<LeadsState> emit,
  ) async {
    final result = await updateLeadQualificacao(
      leadId: event.leadId,
      newQualificacao: event.newQualificacao,
    );

    result.fold(
      (error) => emit(LeadsError(message: error)),
      (_) {
        // Leads serão atualizados automaticamente via stream
      },
    );
  }

  @override
  Future<void> close() {
    _leadsSubscription?.cancel();
    return super.close();
  }
}
