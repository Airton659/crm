import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<Either<String, User>> signIn(String email, String password);
  Future<Either<String, void>> signOut();
  Stream<User?> get authStateChanges;
}
