import 'package:dartz/dartz.dart';
import '../entities/lead.dart';

abstract class LeadRepository {
  Future<Either<String, void>> submitLead(Lead lead);
}
