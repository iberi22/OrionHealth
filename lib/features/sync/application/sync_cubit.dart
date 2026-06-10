import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/services/sync_service.dart';
import 'sync_state.dart';

@injectable
class FhirSyncCubit extends Cubit<SyncState> {
  final SyncService _syncService;

  FhirSyncCubit(this._syncService) : super(const SyncState()) {
    _loadLastSyncTime();
  }

  Future<void> _loadLastSyncTime() async {
    final lastSync = await _syncService.getLastSyncTime();
    emit(state.copyWith(lastSyncTime: lastSync));
  }

  Future<void> performSync() async {
    emit(state.copyWith(status: SyncStatus.loading));
    try {
      await _syncService.performFullSync();
      final lastSync = await _syncService.getLastSyncTime();
      emit(state.copyWith(
        status: SyncStatus.success,
        lastSyncTime: lastSync,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SyncStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
