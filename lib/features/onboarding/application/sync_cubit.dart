import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:equatable/equatable.dart';
import '../../local_agent/domain/services/vector_store_service.dart';

abstract class SyncState extends Equatable {
  const SyncState();
  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {}
class SyncInProgress extends SyncState {
  final String currentDataset;
  final double progress;
  const SyncInProgress(this.currentDataset, this.progress);
  @override
  List<Object?> get props => [currentDataset, progress];
}
class SyncSuccess extends SyncState {
  final String status;
  const SyncSuccess(this.status);
  @override
  List<Object?> get props => [status];
}
class SyncFailure extends SyncState {
  final String error;
  const SyncFailure(this.error);
  @override
  List<Object?> get props => [error];
}

@injectable
class SyncCubit extends Cubit<SyncState> {
  final SyncService _syncService;
  final VectorStoreService _vectorStore;

  SyncCubit(this._syncService, this._vectorStore) : super(SyncInitial());

  Future<void> syncMedicalStandards() async {
    try {
      final datasets = SyncService.datasets;
      final totalSteps = datasets.length + 1; // +1 for indexing
      
      final results = <SyncResult>[];
      
      for (int i = 0; i < datasets.length; i++) {
        final config = datasets[i];
        final progress = (i / totalSteps);
        emit(SyncInProgress('Descargando ${config.datasetName}...', progress));
        
        final result = await _syncService.syncDataset(config);
        results.add(result);
      }

      final success = results.every((r) => r.success);
      
      if (success) {
        emit(const SyncInProgress('Indexando conocimientos...', 0.9));
        // Indexing is the heavy part, we force it to ensure local DB is fresh
        await _vectorStore.indexMedicalStandards(force: true);
        
        final status = await _syncService.getSyncStatus();
        emit(SyncSuccess(status));
      } else {
        final errors = results.where((r) => !r.success).map((r) => '${r.datasetName}: ${r.error}').join(', ');
        emit(SyncFailure('Error en la sincronización: $errors'));
      }
    } catch (e) {
      emit(SyncFailure('Error inesperado: $e'));
    }
  }
}
