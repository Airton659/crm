import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/agendamento_repository.dart';
import 'agendamento_event.dart';
import 'agendamento_state.dart';

class AgendamentoBloc extends Bloc<AgendamentoEvent, AgendamentoState> {
  final AgendamentoRepository repository;
  StreamSubscription? _agendamentosSubscription;

  AgendamentoBloc({required this.repository}) : super(AgendamentoInitial()) {
    on<LoadAgendamentosByLeadEvent>(_onLoadAgendamentosByLead);
    on<LoadAgendamentosPendentesEvent>(_onLoadAgendamentosPendentes);
    on<AddAgendamentoEvent>(_onAddAgendamento);
    on<UpdateAgendamentoEvent>(_onUpdateAgendamento);
    on<MarcarAgendamentoConcluidoEvent>(_onMarcarConcluido);
    on<DeleteAgendamentoEvent>(_onDeleteAgendamento);
  }

  Future<void> _onLoadAgendamentosByLead(
    LoadAgendamentosByLeadEvent event,
    Emitter<AgendamentoState> emit,
  ) async {
    emit(AgendamentoLoading());

    _agendamentosSubscription?.cancel();
    await emit.forEach(
      repository.getAgendamentosByLead(event.leadId),
      onData: (result) {
        return result.fold(
          (error) => AgendamentoError(message: error),
          (agendamentos) => AgendamentoLoaded(agendamentos: agendamentos),
        );
      },
    );
  }

  Future<void> _onLoadAgendamentosPendentes(
    LoadAgendamentosPendentesEvent event,
    Emitter<AgendamentoState> emit,
  ) async {
    emit(AgendamentoLoading());

    _agendamentosSubscription?.cancel();
    await emit.forEach(
      repository.getAgendamentosPendentes(),
      onData: (result) {
        return result.fold(
          (error) => AgendamentoError(message: error),
          (agendamentos) => AgendamentoLoaded(agendamentos: agendamentos),
        );
      },
    );
  }

  Future<void> _onAddAgendamento(
    AddAgendamentoEvent event,
    Emitter<AgendamentoState> emit,
  ) async {
    final result = await repository.addAgendamento(event.agendamento);

    result.fold(
      (error) => emit(AgendamentoError(message: error)),
      (_) => emit(const AgendamentoActionSuccess(message: 'Agendamento criado com sucesso')),
    );
  }

  Future<void> _onUpdateAgendamento(
    UpdateAgendamentoEvent event,
    Emitter<AgendamentoState> emit,
  ) async {
    final result = await repository.updateAgendamento(
      event.agendamentoId,
      event.updates,
    );

    result.fold(
      (error) => emit(AgendamentoError(message: error)),
      (_) => emit(const AgendamentoActionSuccess(message: 'Agendamento atualizado com sucesso')),
    );
  }

  Future<void> _onMarcarConcluido(
    MarcarAgendamentoConcluidoEvent event,
    Emitter<AgendamentoState> emit,
  ) async {
    final result = await repository.marcarComoConcluido(
      event.agendamentoId,
      event.resultado,
    );

    result.fold(
      (error) => emit(AgendamentoError(message: error)),
      (_) => emit(const AgendamentoActionSuccess(message: 'Agendamento concluído com sucesso')),
    );
  }

  Future<void> _onDeleteAgendamento(
    DeleteAgendamentoEvent event,
    Emitter<AgendamentoState> emit,
  ) async {
    final result = await repository.deleteAgendamento(event.agendamentoId);

    result.fold(
      (error) => emit(AgendamentoError(message: error)),
      (_) => emit(const AgendamentoActionSuccess(message: 'Agendamento excluído com sucesso')),
    );
  }

  @override
  Future<void> close() {
    _agendamentosSubscription?.cancel();
    return super.close();
  }
}
