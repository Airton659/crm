import 'package:dartz/dartz.dart';
import '../entities/lead.dart';

abstract class LeadRepository {
  Stream<Either<String, List<Lead>>> getLeads({
    String? statusFilter,
    String? origemFilter,
  });

  Future<Either<String, void>> updateLeadStatus(String leadId, String newStatus);
}
