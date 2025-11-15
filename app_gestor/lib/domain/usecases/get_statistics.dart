import 'package:dartz/dartz.dart';
import '../entities/statistics.dart';
import '../repositories/statistics_repository.dart';

class GetStatistics {
  final StatisticsRepository repository;

  GetStatistics(this.repository);

  Stream<Either<String, Statistics>> call() {
    return repository.getStatistics();
  }
}
