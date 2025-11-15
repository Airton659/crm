import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/agendamento.dart';
import '../../domain/repositories/agendamento_repository.dart';

class AgendamentoRepositoryImpl implements AgendamentoRepository {
  final FirebaseFirestore firestore;

  AgendamentoRepositoryImpl(this.firestore);

  @override
  Stream<Either<String, List<Agendamento>>> getAgendamentosByLead(
    String leadId,
  ) {
    try {
      return firestore
          .collection('agendamentos')
          .where('lead_id', isEqualTo: leadId)
          .orderBy('data_hora', descending: false)
          .snapshots()
          .map((snapshot) {
        try {
          final agendamentos = snapshot.docs
              .map((doc) => Agendamento.fromFirestore(doc))
              .toList();
          return Right(agendamentos);
        } catch (e) {
          return Left('Erro ao processar agendamentos: ${e.toString()}');
        }
      });
    } catch (e) {
      return Stream.value(Left('Erro ao buscar agendamentos: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<String, List<Agendamento>>> getAgendamentosPendentes() {
    try {
      return firestore
          .collection('agendamentos')
          .where('concluido', isEqualTo: false)
          .orderBy('data_hora', descending: false)
          .snapshots()
          .map((snapshot) {
        try {
          final agendamentos = snapshot.docs
              .map((doc) => Agendamento.fromFirestore(doc))
              .toList();
          return Right(agendamentos);
        } catch (e) {
          return Left('Erro ao processar agendamentos: ${e.toString()}');
        }
      });
    } catch (e) {
      return Stream.value(Left('Erro ao buscar agendamentos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<String, void>> addAgendamento(Agendamento agendamento) async {
    try {
      await firestore.collection('agendamentos').add(agendamento.toMap());
      return const Right(null);
    } catch (e) {
      return Left('Erro ao adicionar agendamento: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateAgendamento(
    String agendamentoId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await firestore
          .collection('agendamentos')
          .doc(agendamentoId)
          .update(updates);
      return const Right(null);
    } catch (e) {
      return Left('Erro ao atualizar agendamento: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> marcarComoConcluido(
    String agendamentoId,
    String? resultado,
  ) async {
    try {
      final updates = {
        'concluido': true,
        'data_hora_conclusao': Timestamp.now(),
        if (resultado != null) 'resultado_reuniao': resultado,
      };

      await firestore
          .collection('agendamentos')
          .doc(agendamentoId)
          .update(updates);
      return const Right(null);
    } catch (e) {
      return Left('Erro ao marcar agendamento como concluído: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteAgendamento(String agendamentoId) async {
    try {
      await firestore.collection('agendamentos').doc(agendamentoId).delete();
      return const Right(null);
    } catch (e) {
      return Left('Erro ao deletar agendamento: ${e.toString()}');
    }
  }
}
