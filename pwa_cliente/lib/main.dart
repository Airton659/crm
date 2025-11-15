import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'core/utils/analytics_tracker.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/bloc/lead_form/lead_form_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force rebuild - v3.0
  print('🚀 App iniciando - versão 3.0');

  // Remove o # da URL (pathUrlStrategy)
  usePathUrlStrategy();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDVcNZ93t7iWqE_0dUQMxT8WtgcjzO3ngs",
      authDomain: "grupo-solar-producao.firebaseapp.com",
      projectId: "grupo-solar-producao",
      storageBucket: "grupo-solar-producao.firebasestorage.app",
      messagingSenderId: "442177655317",
      appId: "1:442177655317:web:8ec90afb8a05ac59b7741c",
      measurementId: "G-K85T1M2JPK",
    ),
  );

  // Configurar Dependency Injection
  await di.init();

  print('🔥 PRESTES A INICIALIZAR ANALYTICS TRACKER');

  // INICIALIZAR ANALYTICS TRACKER AQUI NO MAIN
  // Isso garante que seja chamado TODA VEZ que a aplicação carregar
  AnalyticsTracker.init();

  print('🔥 ANALYTICS TRACKER INICIALIZADO');

  runApp(const GrupoSolarApp());
}

class GrupoSolarApp extends StatelessWidget {
  const GrupoSolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<LeadFormBloc>(),
      child: MaterialApp(
        title: 'Grupo Solar Brasil - Energia Solar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
    );
  }
}
