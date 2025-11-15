import 'package:dartz/dartz.dart';
import '../entities/lead.dart';
import '../repositories/lead_repository.dart';

class GetLeads {
  final LeadRepository repository;

  GetLeads(this.repository);

  Stream<Either<String, List<Lead>>> call({
    String? statusFilter,
    String? origemFilter,
  }) {
    return repository.getLeads(
      statusFilter: statusFilter,
      origemFilter: origemFilter,
    );
  }
}
