import 'package:dartz/dartz.dart';

import '../repositories/lead_repository.dart';

class UpdateLeadQualificacao {
  final LeadRepository repository;

  UpdateLeadQualificacao(this.repository);

  Future<Either<String, void>> call({
    required String leadId,
    required String newQualificacao,
  }) async {
    // Validação de qualificação válida
    const validQualificacoes = ['frio', 'morno', 'quente'];
    if (!validQualificacoes.contains(newQualificacao.toLowerCase())) {
      return const Left('Qualificação inválida. Use: frio, morno ou quente.');
    }

    return await repository.updateLeadQualificacao(leadId, newQualificacao);
  }
}
