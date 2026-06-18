// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'eps_connection_state.dart';
import '../../domain/entities/eps_provider.dart';
import '../../domain/usecases/connect_provider_usecase.dart';
import '../../domain/usecases/disconnect_provider_usecase.dart';
import '../../domain/usecases/get_connections_usecase.dart';

@injectable
class EpsConnectionCubit extends Cubit<EpsConnectionState> {
  final GetConnectionsUseCase _getConnectionsUseCase;
  final ConnectProviderUseCase _connectProviderUseCase;
  final DisconnectProviderUseCase _disconnectProviderUseCase;

  EpsConnectionCubit(
    this._getConnectionsUseCase,
    this._connectProviderUseCase,
    this._disconnectProviderUseCase,
  ) : super(const EpsConnectionInitial()) {
    loadConnections();
  }

  Future<void> loadConnections() async {
    emit(const EpsConnectionLoading());
    try {
      final connections = await _getConnectionsUseCase();
      emit(EpsConnectionLoaded(connections));
    } catch (e) {
      emit(EpsConnectionError('Error loading connections: ${e.toString()}'));
    }
  }

  Future<void> connect(EPSProvider provider) async {
    emit(const EpsConnectionLoading());
    try {
      await _connectProviderUseCase(provider);
      await loadConnections();
    } catch (e) {
      emit(EpsConnectionError('Connection error: ${e.toString()}'));
    }
  }

  Future<void> disconnect(String providerId) async {
    emit(const EpsConnectionLoading());
    try {
      await _disconnectProviderUseCase(providerId);
      await loadConnections();
    } catch (e) {
      emit(EpsConnectionError('Disconnection error: ${e.toString()}'));
    }
  }
}
