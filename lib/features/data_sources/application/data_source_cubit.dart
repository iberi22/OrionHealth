import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/data_source_entity.dart';
import '../domain/repositories/data_source_repository.dart';
import 'data_source_state.dart';

@injectable
class DataSourceCubit extends Cubit<DataSourceState> {
  final DataSourceRepository _repository;

  DataSourceCubit(this._repository) : super(DataSourceInitial());

  Future<void> loadDataSources() async {
    emit(DataSourceLoading());
    try {
      final sources = await _repository.getDataSources();
      emit(DataSourceLoaded(sources));
    } catch (e) {
      emit(DataSourceError(e.toString()));
    }
  }

  Future<void> toggleConnection(String id) async {
    final currentState = state;
    if (currentState is! DataSourceLoaded) return;

    final source = currentState.dataSources.firstWhere((s) => s.id == id);
    if (source.status == DataSourceStatus.connected) {
      // Disconnect immediately for UI responsiveness if it's already connected
      _updateSourceStatus(id, DataSourceStatus.disconnected);
      try {
        await _repository.disconnectDataSource(id);
      } catch (e) {
        _updateSourceStatus(id, DataSourceStatus.error, errorMessage: e.toString());
      }
      return;
    }

    _updateSourceStatus(id, DataSourceStatus.connecting);

    try {
      if (source.status != DataSourceStatus.connected) {
        await _repository.connectDataSource(id);
        _updateSourceStatus(id, DataSourceStatus.connected);
      }
    } catch (e) {
      _updateSourceStatus(id, DataSourceStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> syncSource(String id) async {
    final currentState = state;
    if (currentState is! DataSourceLoaded) return;

    try {
      await _repository.syncDataSource(id);
      final updatedSources = currentState.dataSources.map((source) {
        if (source.id == id) {
          return source.copyWith(lastSync: DateTime.now());
        }
        return source;
      }).toList();
      emit(DataSourceLoaded(updatedSources));
    } catch (e) {
      emit(DataSourceError('Sync failed: $e'));
    }
  }

  void _updateSourceStatus(String id, DataSourceStatus status, {String? errorMessage}) {
    final currentState = state;
    if (currentState is! DataSourceLoaded) return;

    final updatedSources = currentState.dataSources.map((source) {
      if (source.id == id) {
        return source.copyWith(status: status, errorMessage: errorMessage);
      }
      return source;
    }).toList();

    emit(DataSourceLoaded(updatedSources));
  }
}
