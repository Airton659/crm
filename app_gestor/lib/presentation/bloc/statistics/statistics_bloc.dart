import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_statistics.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetStatistics getStatistics;

  StreamSubscription? _statisticsSubscription;

  StatisticsBloc({
    required this.getStatistics,
  }) : super(StatisticsInitial()) {
    on<LoadStatisticsEvent>(_onLoadStatistics);

    // Carregar estatísticas automaticamente após pequeno delay para garantir que o Firebase Auth está pronto
    Future.delayed(const Duration(milliseconds: 500), () {
      add(LoadStatisticsEvent());
    });
  }

  Future<void> _onLoadStatistics(LoadStatisticsEvent event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());

    _statisticsSubscription?.cancel();
    await emit.forEach(
      getStatistics(),
      onData: (result) {
        return result.fold(
          (error) => StatisticsError(message: error),
          (statistics) => StatisticsLoaded(statistics: statistics),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _statisticsSubscription?.cancel();
    return super.close();
  }
}
