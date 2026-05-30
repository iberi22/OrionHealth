import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../vitals/domain/repositories/vital_sign_repository.dart';
import '../../local_agent/infrastructure/services/medical_indexing_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final VitalSignRepository _vitalSignRepository;
  final MedicalIndexingService _indexingService;
  StreamSubscription<bool>? _indexingSubscription;

  HomeCubit(this._vitalSignRepository, this._indexingService) : super(const HomeState()) {
    _init();
  }

  void _init() {
    emit(state.copyWith(isIndexing: !_indexingService.hasIndexed));

    _indexingSubscription = _indexingService.statusStream.listen((isDone) {
      emit(state.copyWith(
        isIndexing: !isDone,
        indexingError: false,
      ));
    });

    loadVitals();
  }

  Future<void> retryIndexing() async {
    emit(state.copyWith(isIndexing: true, indexingError: false));
    try {
      final result = await _indexingService.indexAll(force: true);
      if (!result.success) {
        emit(state.copyWith(isIndexing: false, indexingError: true));
      }
    } catch (e) {
      emit(state.copyWith(isIndexing: false, indexingError: true));
    }
  }

  Future<void> loadVitals() async {
    emit(state.copyWith(isLoadingVitals: true));
    try {
      final vitals = await _vitalSignRepository.getLatestVitals();
      emit(state.copyWith(latestVitals: vitals, isLoadingVitals: false));
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
