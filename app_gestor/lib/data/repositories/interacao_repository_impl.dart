import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/interacao.dart';
import '../../domain/repositories/interacao_repository.dart';

class InteracaoRepositoryImpl implements InteracaoRepository {
  final FirebaseFirestore firestore;

  InteracaoRepositoryImpl(this.firestore);

  @override
  Stream<Either<String, List<Interacao>>> getInteracoesByLead(String leadId) {
    try {
      return firestore
          .collection('interacoes')
          .where('lead_id', isEqualTo: leadId)
          .orderBy('data_hora', descending: true)
          .snapshots()
          .map((snapshot) {
        try {
          final interacoes = snapshot.docs
              .map((doc) => Interacao.fromFirestore(doc))
              .toList();
          return Right(interacoes);
        } catch (e) {
          return Left('Erro ao processar interações: ${e.toString()}');
        }
      });
    } catch (e) {
      return Stream.value(Left('Erro ao buscar interações: ${e.toString()}'));
    }
  }

  @override
  Future<Either<String, void>> addInteracao(Interacao interacao) async {
    try {
      await firestore.collection('interacoes').add(interacao.toMap());
      return const Right(null);
    } catch (e) {
      return Left('Erro ao adicionar interação: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateInteracao(
    String interacaoId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await firestore.collection('interacoes').doc(interacaoId).update(updates);
      return const Right(null);
    } catch (e) {
      return Left('Erro ao atualizar interação: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteInteracao(String interacaoId) async {
    try {
      await firestore.collection('interacoes').doc(interacaoId).delete();
      return const Right(null);
    } catch (e) {
      return Left('Erro ao deletar interação: ${e.toString()}');
    }
  }
}
