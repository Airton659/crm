import 'package:dartz/dartz.dart';
import '../entities/lead.dart';
import '../repositories/lead_repository.dart';

class SubmitLead {
  final LeadRepository repository;

  SubmitLead(this.repository);

  Future<Either<String, void>> call(Lead lead) async {
    return await repository.submitLead(lead);
  }
}
