import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/lead_repository_impl.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../../data/repositories/interacao_repository_impl.dart';
import '../../data/repositories/agendamento_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../domain/repositories/interacao_repository.dart';
import '../../domain/repositories/agendamento_repository.dart';
import '../../domain/usecases/get_leads.dart';
import '../../domain/usecases/update_lead_status.dart';
import '../../domain/usecases/update_lead_qualificacao.dart';
import '../../domain/usecases/get_statistics.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/leads/leads_bloc.dart';
import '../../presentation/bloc/statistics/statistics_bloc.dart';
import '../../presentation/bloc/interacao/interacao_bloc.dart';
import '../../presentation/bloc/agendamento/agendamento_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoCs
  sl.registerFactory(() => AuthBloc(
        signIn: sl(),
        signOut: sl(),
        checkAuthStatus: sl(),
      ));

  sl.registerFactory(() => LeadsBloc(
        getLeads: sl(),
        updateLeadStatus: sl(),
        updateLeadQualificacao: sl(),
      ));

  sl.registerFactory(() => StatisticsBloc(
        getStatistics: sl(),
      ));

  sl.registerFactory(() => InteracaoBloc(
        repository: sl(),
      ));

  sl.registerFactory(() => AgendamentoBloc(
        repository: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => GetLeads(sl()));
  sl.registerLazySingleton(() => UpdateLeadStatus(sl()));
  sl.registerLazySingleton(() => UpdateLeadQualificacao(sl()));
  sl.registerLazySingleton(() => GetStatistics(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(auth: sl(), firestore: sl()),
  );

  sl.registerLazySingleton<LeadRepository>(
    () => LeadRepositoryImpl(firestore: sl()),
  );

  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(firestore: sl()),
  );

  sl.registerLazySingleton<InteracaoRepository>(
    () => InteracaoRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<AgendamentoRepository>(
    () => AgendamentoRepositoryImpl(sl()),
  );

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}
