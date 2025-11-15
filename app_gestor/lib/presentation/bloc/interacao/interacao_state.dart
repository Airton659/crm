import 'package:equatable/equatable.dart';

import '../../../domain/entities/interacao.dart';

abstract class InteracaoState extends Equatable {
  const InteracaoState();

  @override
  List<Object?> get props => [];
}

class InteracaoInitial extends InteracaoState {}

class InteracaoLoading extends InteracaoState {}

class InteracaoLoaded extends InteracaoState {
  final List<Interacao> interacoes;

  const InteracaoLoaded({required this.interacoes});

  @override
  List<Object?> get props => [interacoes];
}

class InteracaoError extends InteracaoState {
  final String message;

  const InteracaoError({required this.message});

  @override
  List<Object?> get props => [message];
}

class InteracaoActionSuccess extends InteracaoState {
  final String message;

  const InteracaoActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
