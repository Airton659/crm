import 'package:equatable/equatable.dart';

import '../../../domain/entities/agendamento.dart';

abstract class AgendamentoEvent extends Equatable {
  const AgendamentoEvent();

  @override
  List<Object?> get props => [];
}

class LoadAgendamentosByLeadEvent extends AgendamentoEvent {
  final String leadId;

  const LoadAgendamentosByLeadEvent(this.leadId);

  @override
  List<Object?> get props => [leadId];
}

class LoadAgendamentosPendentesEvent extends AgendamentoEvent {
  const LoadAgendamentosPendentesEvent();
}

class AddAgendamentoEvent extends AgendamentoEvent {
  final Agendamento agendamento;

  const AddAgendamentoEvent(this.agendamento);

  @override
  List<Object?> get props => [agendamento];
}

class UpdateAgendamentoEvent extends AgendamentoEvent {
  final String agendamentoId;
  final Map<String, dynamic> updates;

  const UpdateAgendamentoEvent({
    required this.agendamentoId,
    required this.updates,
  });

  @override
  List<Object?> get props => [agendamentoId, updates];
}

class MarcarAgendamentoConcluidoEvent extends AgendamentoEvent {
  final String agendamentoId;
  final String? resultado;

  const MarcarAgendamentoConcluidoEvent({
    required this.agendamentoId,
    this.resultado,
  });

  @override
  List<Object?> get props => [agendamentoId, resultado];
}

class DeleteAgendamentoEvent extends AgendamentoEvent {
  final String agendamentoId;

  const DeleteAgendamentoEvent(this.agendamentoId);

  @override
  List<Object?> get props => [agendamentoId];
}
