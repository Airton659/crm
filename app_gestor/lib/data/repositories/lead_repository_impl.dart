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
    Query query = firestore.collection('leads');

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter);
    }

    if (origemFilter != null) {
      query = query.where('origem.source', isEqualTo: origemFilter);
    }

    query = query.orderBy('created_at', descending: true);

    return query.snapshots().map<Either<String, List<Lead>>>((snapshot) {
      final leads = snapshot.docs
          .map((doc) => Lead.fromFirestore(doc))
          .toList();
      return Right(leads);
    }).handleError((error) {
      return const Left('Erro ao buscar leads');
    });
  }

  @override
  Future<Either<String, void>> updateLeadStatus(String leadId, String newStatus) async {
    try {
      await firestore.collection('leads').doc(leadId).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e) {
      return Left('Erro ao atualizar status: ${e.toString()}');
    }
  }
}
