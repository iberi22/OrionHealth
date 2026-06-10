import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../domain/services/sync_service.dart';

enum SyncStatus { initial, loading, success, failure }

class SyncState extends Equatable {
  final SyncStatus status;
  final DateTime? lastSyncTime;
  final String? errorMessage;

  const SyncState({
    this.status = SyncStatus.initial,
    this.lastSyncTime,
    this.errorMessage,
  });

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncTime,
    String? errorMessage,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, lastSyncTime, errorMessage];
}

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
