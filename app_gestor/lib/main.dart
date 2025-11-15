import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/dashboard/dashboard_page.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/bloc/leads/leads_bloc.dart';
import 'presentation/bloc/statistics/statistics_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase (usa google-services.json no Android)
  await Firebase.initializeApp();

  // Configurar Dependency Injection
  await di.init();

  runApp(const GrupoSolarGestorApp());
}

class GrupoSolarGestorApp extends StatelessWidget {
  const GrupoSolarGestorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent())),
        BlocProvider(create: (_) => di.sl<LeadsBloc>()),
        BlocProvider(create: (_) => di.sl<StatisticsBloc>()),
      ],
      child: MaterialApp(
        title: 'Grupo Solar - Gestor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const DashboardPage();
            } else if (state is AuthUnauthenticated || state is AuthError) {
              return const LoginPage();
            }
            // Loading (AuthInitial ou AuthLoading)
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
