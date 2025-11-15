import 'package:equatable/equatable.dart';

abstract class LeadsEvent extends Equatable {
  const LeadsEvent();

  @override
  List<Object?> get props => [];
}

class LoadLeadsEvent extends LeadsEvent {
  final String? statusFilter;
  final String? origemFilter;

  const LoadLeadsEvent({this.statusFilter, this.origemFilter});

  @override
  List<Object?> get props => [statusFilter, origemFilter];
}

class UpdateLeadStatusEvent extends LeadsEvent {
  final String leadId;
  final String newStatus;

  const UpdateLeadStatusEvent({
    required this.leadId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [leadId, newStatus];
}
