import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatus {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  Stream<User?> call() {
    return repository.authStateChanges;
  }
}
