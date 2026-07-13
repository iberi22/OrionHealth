// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'eps_connection_state.dart';
import '../../domain/entities/eps_provider.dart';
import '../../domain/entities/eps_providers_catalog.dart';
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
  ) : super(const EpsConnectionCatalog(availableProviders: [])) {
    loadCatalog();
  }

  /// Carga el catálogo completo de EPS + conexiones existentes.
  Future<void> loadCatalog() async {
    final providers = EpsProvidersCatalog.activeProviders;

    try {
      final connections = await _getConnectionsUseCase();
      final connectedIds =
          connections.map((c) => c.provider.id).toSet().toList();

      emit(EpsConnectionCatalog(
        availableProviders: providers,
        connections: connections,
        connectedProviderIds: connectedIds,
      ));
    } catch (_) {
      // Si falla obtener conexiones, mostrar solo catálogo
      emit(EpsConnectionCatalog(
        availableProviders: providers,
        connections: const [],
        connectedProviderIds: const [],
      ));
    }
  }

  /// Refresca las conexiones sin recargar el catálogo.
  Future<void> loadConnections() async {
    emit(const EpsConnectionLoading());
    try {
      final connections = await _getConnectionsUseCase();
      emit(EpsConnectionLoaded(connections));
    } catch (e) {
      emit(EpsConnectionError('Error loading connections: ${e.toString()}'));
    }
  }

  /// Conecta con una EPS del catálogo.
  Future<void> connect(EPSProvider provider) async {
    emit(EpsConnectionConnecting(provider));
    try {
      await _connectProviderUseCase(provider);
      await loadCatalog(); // Recarga catálogo con nuevas conexiones
    } catch (e) {
      emit(EpsConnectionError('Error de conexión: ${e.toString()}'));
      // Recuperar: volver al catálogo
      await loadCatalog();
    }
  }

  Future<void> disconnect(String providerId) async {
    emit(const EpsConnectionLoading());
    try {
      await _disconnectProviderUseCase(providerId);
      await loadCatalog();
    } catch (e) {
      emit(EpsConnectionError('Disconnection error: ${e.toString()}'));
    }
  }

  /// Marks a provider as connected via the Patient Portal Extractor flow.
  /// This is used when the patient authenticates through the EPS web portal
  /// (on-device RPA) rather than through SMART on FHIR OAuth2.
  void markPortalConnected({
    required EPSProvider provider,
    String? patientId,
  }) {
    // Emit a success-like state so the UI updates
    emit(EpsConnectionPortalConnected(
      provider: provider,
      patientId: patientId,
    ));
    // Reload full state to reflect the new connection
    loadCatalog();
  }
}
