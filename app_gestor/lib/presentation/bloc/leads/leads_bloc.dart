import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_leads.dart';
import '../../../domain/usecases/update_lead_status.dart';
import 'leads_event.dart';
import 'leads_state.dart';

class LeadsBloc extends Bloc<LeadsEvent, LeadsState> {
  final GetLeads getLeads;
  final UpdateLeadStatus updateLeadStatus;

  StreamSubscription? _leadsSubscription;

  LeadsBloc({
    required this.getLeads,
    required this.updateLeadStatus,
  }) : super(LeadsInitial()) {
    on<LoadLeadsEvent>(_onLoadLeads);
    on<UpdateLeadStatusEvent>(_onUpdateLeadStatus);

    // Carregar leads automaticamente após pequeno delay para garantir que o Firebase Auth está pronto
    Future.delayed(const Duration(milliseconds: 500), () {
      add(const LoadLeadsEvent());
    });
  }

  Future<void> _onLoadLeads(LoadLeadsEvent event, Emitter<LeadsState> emit) async {
    emit(LeadsLoading());

    _leadsSubscription?.cancel();
    await emit.forEach(
      getLeads(
        statusFilter: event.statusFilter,
        origemFilter: event.origemFilter,
      ),
      onData: (result) {
        return result.fold(
          (error) => LeadsError(message: error),
          (leads) => LeadsLoaded(leads: leads),
        );
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

  @override
  Future<void> close() {
    _leadsSubscription?.cancel();
    return super.close();
  }
}
