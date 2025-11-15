import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/interacao_repository.dart';
import 'interacao_event.dart';
import 'interacao_state.dart';

class InteracaoBloc extends Bloc<InteracaoEvent, InteracaoState> {
  final InteracaoRepository repository;
  StreamSubscription? _interacoesSubscription;

  InteracaoBloc({required this.repository}) : super(InteracaoInitial()) {
    on<LoadInteracoesByLeadEvent>(_onLoadInteracoesByLead);
    on<AddInteracaoEvent>(_onAddInteracao);
    on<UpdateInteracaoEvent>(_onUpdateInteracao);
    on<DeleteInteracaoEvent>(_onDeleteInteracao);
  }

  Future<void> _onLoadInteracoesByLead(
    LoadInteracoesByLeadEvent event,
    Emitter<InteracaoState> emit,
  ) async {
    emit(InteracaoLoading());

    _interacoesSubscription?.cancel();
    await emit.forEach(
      repository.getInteracoesByLead(event.leadId),
      onData: (result) {
        return result.fold(
          (error) => InteracaoError(message: error),
          (interacoes) => InteracaoLoaded(interacoes: interacoes),
        );
      },
    );
  }

  Future<void> _onAddInteracao(
    AddInteracaoEvent event,
    Emitter<InteracaoState> emit,
  ) async {
    final result = await repository.addInteracao(event.interacao);

    result.fold(
      (error) => emit(InteracaoError(message: error)),
      (_) => emit(const InteracaoActionSuccess(message: 'Interação adicionada com sucesso')),
    );
  }

  Future<void> _onUpdateInteracao(
    UpdateInteracaoEvent event,
    Emitter<InteracaoState> emit,
  ) async {
    final result = await repository.updateInteracao(
      event.interacaoId,
      event.updates,
    );

    result.fold(
      (error) => emit(InteracaoError(message: error)),
      (_) => emit(const InteracaoActionSuccess(message: 'Interação atualizada com sucesso')),
    );
  }

  Future<void> _onDeleteInteracao(
    DeleteInteracaoEvent event,
    Emitter<InteracaoState> emit,
  ) async {
    final result = await repository.deleteInteracao(event.interacaoId);

    result.fold(
      (error) => emit(InteracaoError(message: error)),
      (_) => emit(const InteracaoActionSuccess(message: 'Interação excluída com sucesso')),
    );
  }

  @override
  Future<void> close() {
    _interacoesSubscription?.cancel();
    return super.close();
  }
}
