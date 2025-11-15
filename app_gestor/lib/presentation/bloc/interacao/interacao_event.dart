import 'package:equatable/equatable.dart';

import '../../../domain/entities/interacao.dart';

abstract class InteracaoEvent extends Equatable {
  const InteracaoEvent();

  @override
  List<Object?> get props => [];
}

class LoadInteracoesByLeadEvent extends InteracaoEvent {
  final String leadId;

  const LoadInteracoesByLeadEvent(this.leadId);

  @override
  List<Object?> get props => [leadId];
}

class AddInteracaoEvent extends InteracaoEvent {
  final Interacao interacao;

  const AddInteracaoEvent(this.interacao);

  @override
  List<Object?> get props => [interacao];
}

class UpdateInteracaoEvent extends InteracaoEvent {
  final String interacaoId;
  final Map<String, dynamic> updates;

  const UpdateInteracaoEvent({
    required this.interacaoId,
    required this.updates,
  });

  @override
  List<Object?> get props => [interacaoId, updates];
}

class DeleteInteracaoEvent extends InteracaoEvent {
  final String interacaoId;

  const DeleteInteracaoEvent(this.interacaoId);

  @override
  List<Object?> get props => [interacaoId];
}
