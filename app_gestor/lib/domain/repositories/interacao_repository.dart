import 'package:dartz/dartz.dart';
import '../entities/interacao.dart';

abstract class InteracaoRepository {
  /// Retorna stream de interações de um lead específico
  /// Ordenadas por data (mais recentes primeiro)
  Stream<Either<String, List<Interacao>>> getInteracoesByLead(String leadId);

  /// Adiciona uma nova interação
  Future<Either<String, void>> addInteracao(Interacao interacao);

  /// Atualiza uma interação existente
  Future<Either<String, void>> updateInteracao(String interacaoId, Map<String, dynamic> updates);

  /// Deleta uma interação
  Future<Either<String, void>> deleteInteracao(String interacaoId);
}
