// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'eps_connection_event.dart';
import 'eps_connection_state.dart';
import '../../domain/usecases/connect_provider_usecase.dart';
import '../../domain/usecases/disconnect_provider_usecase.dart';
import '../../domain/usecases/get_connections_usecase.dart';

@injectable
class EpsConnectionBloc extends Bloc<EpsConnectionEvent, EpsConnectionState> {
  final GetConnectionsUseCase _getConnectionsUseCase;
  final ConnectProviderUseCase _connectProviderUseCase;
  final DisconnectProviderUseCase _disconnectProviderUseCase;

  EpsConnectionBloc(
    this._getConnectionsUseCase,
    this._connectProviderUseCase,
    this._disconnectProviderUseCase,
  ) : super(const EpsConnectionInitial()) {
    on<LoadConnections>(_onLoadConnections);
    on<ConnectProvider>(_onConnectProvider);
    on<DisconnectProvider>(_onDisconnectProvider);
  }

  Future<void> _onLoadConnections(
    LoadConnections event,
    Emitter<EpsConnectionState> emit,
  ) async {
    emit(const EpsConnectionLoading());
    try {
      final connections = await _getConnectionsUseCase();
      emit(EpsConnectionLoaded(connections));
    } catch (e) {
      emit(EpsConnectionError('Error loading connections: ${e.toString()}'));
    }
  }

  Future<void> _onConnectProvider(
    ConnectProvider event,
    Emitter<EpsConnectionState> emit,
  ) async {
    emit(const EpsConnectionLoading());
    try {
      await _connectProviderUseCase(event.provider);
      add(const LoadConnections());
    } catch (e) {
      emit(EpsConnectionError('Connection error: ${e.toString()}'));
    }
  }

  Future<void> _onDisconnectProvider(
    DisconnectProvider event,
    Emitter<EpsConnectionState> emit,
  ) async {
    emit(const EpsConnectionLoading());
    try {
      await _disconnectProviderUseCase(event.providerId);
      add(const LoadConnections());
    } catch (e) {
      emit(EpsConnectionError('Disconnection error: ${e.toString()}'));
    }
  }
}
