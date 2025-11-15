import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl({required this.auth, required this.firestore});

  @override
  Future<Either<String, User>> signIn(String email, String password) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left('Erro ao fazer login');
      }

      // Login bem-sucedido - retornar usuário
      // Nota: Removida validação de role e atualização de last_login
      // para evitar erro PERMISSION_DENIED no Firestore
      return Right(credential.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return const Left('Credenciais inválidas. Verifique seu e-mail e senha.');
      } else if (e.code == 'user-disabled') {
        return const Left('Usuário desabilitado. Entre em contato com o suporte.');
      } else if (e.code == 'too-many-requests') {
        return const Left('Muitas tentativas de login. Tente novamente mais tarde.');
      }
      return const Left('Credenciais inválidas. Verifique seu e-mail e senha.');
    } catch (e) {
      return Left('Erro ao fazer login: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> signOut() async {
    try {
      await auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left('Erro ao sair: ${e.toString()}');
    }
  }

  @override
  Stream<User?> get authStateChanges => auth.authStateChanges();
}
