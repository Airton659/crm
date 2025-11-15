import 'package:equatable/equatable.dart';

abstract class LeadFormEvent extends Equatable {
  const LeadFormEvent();

  @override
  List<Object?> get props => [];
}

class SubmitLeadFormEvent extends LeadFormEvent {
  final String nome;
  final String email;
  final String telefone;
  final int consumoKwh;
  final String tipoTelhado;
  final String? tipoServico;

  const SubmitLeadFormEvent({
    required this.nome,
    required this.email,
    required this.telefone,
    required this.consumoKwh,
    required this.tipoTelhado,
    this.tipoServico,
  });

  @override
  List<Object?> get props => [
        nome,
        email,
        telefone,
        consumoKwh,
        tipoTelhado,
        tipoServico,
      ];
}
