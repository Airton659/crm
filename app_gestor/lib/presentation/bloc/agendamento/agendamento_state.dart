import 'package:equatable/equatable.dart';

import '../../../domain/entities/agendamento.dart';

abstract class AgendamentoState extends Equatable {
  const AgendamentoState();

  @override
  List<Object?> get props => [];
}

class AgendamentoInitial extends AgendamentoState {}

class AgendamentoLoading extends AgendamentoState {}

class AgendamentoLoaded extends AgendamentoState {
  final List<Agendamento> agendamentos;

  const AgendamentoLoaded({required this.agendamentos});

  @override
  List<Object?> get props => [agendamentos];
}

class AgendamentoError extends AgendamentoState {
  final String message;

  const AgendamentoError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AgendamentoActionSuccess extends AgendamentoState {
  final String message;

  const AgendamentoActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
