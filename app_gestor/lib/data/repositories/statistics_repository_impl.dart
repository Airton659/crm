import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/statistics.dart';
import '../../domain/repositories/statistics_repository.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final FirebaseFirestore firestore;

  StatisticsRepositoryImpl({required this.firestore});

  @override
  Stream<Either<String, Statistics>> getStatistics() {
    return firestore.collection('leads').snapshots().map<Either<String, Statistics>>((snapshot) {
      final leads = snapshot.docs;

      // Calcular estatísticas
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      int totalLeads = 0;
      int totalOrcamentos = 0;
      int totalFechados = 0;
      Map<String, int> porOrigem = {};
      Map<String, int> porStatus = {};

      for (var doc in leads) {
        final data = doc.data();
        final createdAt = (data['created_at'] as Timestamp?)?.toDate();

        if (createdAt != null && createdAt.isAfter(startOfMonth)) {
          totalLeads++;
        }

        final status = data['status'] ?? '';
        porStatus[status] = (porStatus[status] ?? 0) + 1;

        if (status == 'orcamento_enviado') totalOrcamentos++;
        if (status == 'fechado') totalFechados++;

        final origem = data['origem']?['source'] ?? 'outros';
        porOrigem[origem] = (porOrigem[origem] ?? 0) + 1;
      }

      final taxaConversao = totalLeads > 0
          ? (totalFechados / totalLeads * 100)
          : 0.0;

      return Right(Statistics(
        totalLeads: totalLeads,
        totalOrcamentos: totalOrcamentos,
        totalFechados: totalFechados,
        taxaConversao: taxaConversao,
        porOrigem: porOrigem,
        porStatus: porStatus,
      ));
    }).handleError((error) {
      return const Left('Erro ao buscar estatísticas');
    });
  }
}
