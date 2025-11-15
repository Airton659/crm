import 'package:equatable/equatable.dart';

abstract class LeadFormState extends Equatable {
  const LeadFormState();

  @override
  List<Object?> get props => [];
}

class LeadFormInitial extends LeadFormState {}

class LeadFormSubmitting extends LeadFormState {}

class LeadFormSuccess extends LeadFormState {
  final String message;

  const LeadFormSuccess({
    this.message = 'Lead enviado com sucesso! Em breve entraremos em contato.',
  });

  @override
  List<Object?> get props => [message];
}

class LeadFormError extends LeadFormState {
  final String message;

  const LeadFormError({required this.message});

  @override
  List<Object?> get props => [message];
}
