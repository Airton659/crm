import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<Either<String, void>> call() async {
    return await repository.signOut();
  }
}
