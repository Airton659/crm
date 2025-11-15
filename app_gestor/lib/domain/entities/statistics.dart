import 'package:equatable/equatable.dart';

class Statistics extends Equatable {
  final int totalLeads;
  final int totalOrcamentos;
  final int totalFechados;
  final double taxaConversao;
  final Map<String, int> porOrigem;
  final Map<String, int> porStatus;

  const Statistics({
    required this.totalLeads,
    required this.totalOrcamentos,
    required this.totalFechados,
    required this.taxaConversao,
    required this.porOrigem,
    required this.porStatus,
  });

  @override
  List<Object?> get props => [
        totalLeads,
        totalOrcamentos,
        totalFechados,
        taxaConversao,
        porOrigem,
        porStatus,
      ];
}
