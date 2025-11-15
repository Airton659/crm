import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/lead.dart';
import '../../domain/repositories/lead_repository.dart';

class LeadRepositoryImpl implements LeadRepository {
  final FirebaseFirestore firestore;

  LeadRepositoryImpl({required this.firestore});

  @override
  Stream<Either<String, List<Lead>>> getLeads({
    String? statusFilter,
    String? origemFilter,
  }) {
    try {
      Query query = firestore.collection('leads');

      if (statusFilter != null) {
        print('🔍 Aplicando filtro de status: $statusFilter');
        query = query.where('status', isEqualTo: statusFilter);
      }

      if (origemFilter != null) {
        print('🔍 Aplicando filtro de origem: $origemFilter');
        query = query.where('origem.source', isEqualTo: origemFilter);
      }

      query = query.orderBy('created_at', descending: true);

      print('📊 Query configurada, iniciando stream...');

      return query.snapshots().map<Either<String, List<Lead>>>((snapshot) {
        print('📊 Snapshot recebido: ${snapshot.docs.length} documentos');
        final leads = snapshot.docs
            .map((doc) => Lead.fromFirestore(doc))
            .toList();
        print('✅ ${leads.length} leads parseados com sucesso');
        return Right(leads);
      }).handleError((error) {
        print('❌ ERRO NO STREAM FIRESTORE: $error');
        print('❌ Tipo do erro: ${error.runtimeType}');
        return Left('Erro ao buscar leads: ${error.toString()}');
      });
    } catch (e) {
      print('❌ ERRO AO CONFIGURAR QUERY: $e');
      return Stream.value(Left('Erro ao configurar busca: ${e.toString()}'));
    }
  }

  @override
  Future<Either<String, void>> updateLeadStatus(String leadId, String newStatus) async {
    try {
      // Obter status anterior
      final leadDoc = await firestore.collection('leads').doc(leadId).get();
      final statusAnterior = leadDoc.data()?['status'] as String?;

      // Atualizar status
      await firestore.collection('leads').doc(leadId).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Registrar interação automática
      if (statusAnterior != null && statusAnterior != newStatus) {
        await firestore.collection('interacoes').add({
          'lead_id': leadId,
          'data_hora': Timestamp.now(),
          'tipo': 'status_change',
          'descricao': 'Status alterado',
          'status_anterior': statusAnterior,
          'status_novo': newStatus,
        });
      }

      return const Right(null);
    } catch (e) {
      return Left('Erro ao atualizar status: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateLeadQualificacao(String leadId, String newQualificacao) async {
    try {
      await firestore.collection('leads').doc(leadId).update({
        'qualificacao': newQualificacao,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e) {
      return Left('Erro ao atualizar qualificação: ${e.toString()}');
    }
  }
}
