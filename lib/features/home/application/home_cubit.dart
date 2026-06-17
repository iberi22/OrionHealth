import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../vitals/domain/repositories/vital_sign_repository.dart';
import '../../local_agent/infrastructure/services/medical_indexing_service.dart';
import '../../user_profile/domain/repositories/user_profile_repository.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final VitalSignRepository _vitalSignRepository;
  final MedicalIndexingService _medicalIndexingService;
  final UserProfileRepository _userProfileRepository;
  StreamSubscription<bool>? _indexingSubscription;

  HomeCubit(
    this._vitalSignRepository,
    this._medicalIndexingService,
    this._userProfileRepository,
  ) : super(const HomeState()) {
    _init();
  }

  void _init() {
    _loadVitals();
    _subscribeToIndexing();
  }

  Future<void> _loadVitals() async {
    emit(state.copyWith(isLoadingVitals: true));
    try {
      final vitals = await _vitalSignRepository.getLatestVitals();
      emit(state.copyWith(
        latestVitals: vitals,
        isLoadingVitals: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingVitals: false));
    }
  }

  void _subscribeToIndexing() {
    _indexingSubscription?.cancel();

    // In HomeCubit, isIndexing should be true if hasIndexed is false
    if (!_medicalIndexingService.hasIndexed) {
      emit(state.copyWith(isIndexing: true));
    }

    _indexingSubscription = _medicalIndexingService.statusStream.listen((isIndexed) {
      emit(state.copyWith(isIndexing: !isIndexed, indexingError: false));
    });
  }

  Future<void> retryIndexing() async {
    emit(state.copyWith(isIndexing: true, indexingError: false));
    try {
      final result = await _medicalIndexingService.indexAll(force: true);
      if (result.errors > 0 && result.indexed == 0) {
        emit(state.copyWith(isIndexing: false, indexingError: true));
      } else {
        emit(state.copyWith(isIndexing: false, indexingError: false));
      }
    } catch (e) {
      emit(state.copyWith(isIndexing: false, indexingError: true));
    }
  }

  @override
  Future<void> close() {
    _indexingSubscription?.cancel();
    return super.close();
  }
}
