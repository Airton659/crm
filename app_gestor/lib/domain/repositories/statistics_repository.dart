import 'package:dartz/dartz.dart';
import '../entities/statistics.dart';

abstract class StatisticsRepository {
  Stream<Either<String, Statistics>> getStatistics();
}
