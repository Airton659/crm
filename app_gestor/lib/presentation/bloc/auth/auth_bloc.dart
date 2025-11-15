import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/sign_in.dart';
import '../../../domain/usecases/sign_out.dart';
import '../../../domain/usecases/check_auth_status.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignOut signOut;
  final CheckAuthStatus checkAuthStatus;

  StreamSubscription? _authSubscription;

  AuthBloc({
    required this.signIn,
    required this.signOut,
    required this.checkAuthStatus,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    _authSubscription?.cancel();
    await emit.forEach<dynamic>(
      checkAuthStatus(),
      onData: (user) {
        if (user != null) {
          return AuthAuthenticated(user: user);
        } else {
          return AuthUnauthenticated();
        }
      },
    );
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final result = await signIn(event.email, event.password).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Login timeout - verifique sua conexão');
        },
      );

      result.fold(
        (error) {
          print('🔴 ERRO NO LOGIN: $error');
          emit(AuthError(message: error));
        },
        (user) {
          print('✅ LOGIN SUCESSO: ${user.email}');
          emit(AuthAuthenticated(user: user));
        },
      );
    } catch (e) {
      print('🔴 EXCEÇÃO NO LOGIN: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    await signOut();
    emit(AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
