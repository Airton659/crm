import 'package:dartz/dartz.dart';
import '../entities/agendamento.dart';

abstract class AgendamentoRepository {
  /// Retorna stream de agendamentos de um lead específico
  /// Ordenados por data (mais próximos primeiro)
  Stream<Either<String, List<Agendamento>>> getAgendamentosByLead(String leadId);

  /// Retorna stream de todos os agendamentos pendentes
  /// Útil para ver agenda do dia/semana
  Stream<Either<String, List<Agendamento>>> getAgendamentosPendentes();

  /// Adiciona um novo agendamento
  Future<Either<String, void>> addAgendamento(Agendamento agendamento);

  /// Atualiza um agendamento existente
  Future<Either<String, void>> updateAgendamento(
    String agendamentoId,
    Map<String, dynamic> updates,
  );

  /// Marca agendamento como concluído
  Future<Either<String, void>> marcarComoConcluido(
    String agendamentoId,
    String? resultado,
  );

  /// Deleta um agendamento
  Future<Either<String, void>> deleteAgendamento(String agendamentoId);
}
