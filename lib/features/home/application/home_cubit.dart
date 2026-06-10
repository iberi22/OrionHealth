import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/repositories/home_repository.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  StreamSubscription<bool>? _indexingSubscription;

  HomeCubit(this._homeRepository) : super(const HomeState()) {
    _init();
  }

  void _init() {
    emit(state.copyWith(isIndexing: !_homeRepository.hasIndexed));

    _indexingSubscription = _homeRepository.indexingStatusStream.listen((isDone) {
      emit(state.copyWith(
        isIndexing: !isDone,
        indexingError: false,
      ));
    });

    loadVitals();
  }

  Future<void> retryIndexing() async {
    emit(state.copyWith(isIndexing: true, indexingError: false));
    final success = await _homeRepository.retryIndexing();
    if (!success) {
      emit(state.copyWith(isIndexing: false, indexingError: true));
    }
  }

  Future<void> loadVitals() async {
    emit(state.copyWith(isLoadingVitals: true));
    try {
      final vitals = await _homeRepository.getLatestVitals();
      final allInsights = await _homeRepository.getRecentInsights();

      emit(state.copyWith(
        latestVitals: vitals,
        recentInsights: allInsights,
        isLoadingVitals: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoadingVitals: false));
    }
  }

  @override
  Future<void> close() {
    _indexingSubscription?.cancel();
    return super.close();
  }
}
