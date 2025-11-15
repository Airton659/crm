import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/repositories/lead_repository_impl.dart';
import '../../domain/repositories/lead_repository.dart';
import '../../domain/usecases/submit_lead.dart';
import '../../presentation/bloc/lead_form/lead_form_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoCs
  sl.registerFactory(
    () => LeadFormBloc(submitLead: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => SubmitLead(sl()));

  // Repositories
  sl.registerLazySingleton<LeadRepository>(
    () => LeadRepositoryImpl(firestore: sl()),
  );

  // External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}
