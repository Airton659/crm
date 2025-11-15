import 'package:dartz/dartz.dart';
import '../repositories/lead_repository.dart';

class UpdateLeadStatus {
  final LeadRepository repository;

  UpdateLeadStatus(this.repository);

  Future<Either<String, void>> call(String leadId, String newStatus) async {
    return await repository.updateLeadStatus(leadId, newStatus);
  }
}
