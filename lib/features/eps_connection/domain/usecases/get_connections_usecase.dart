// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import '../entities/eps_connection.dart';
import '../repositories/oauth_repository.dart';

@injectable
class GetConnectionsUseCase {
  final OAuthRepository _repository;

  GetConnectionsUseCase(this._repository);

  Future<List<EPSConnection>> call() async {
    final connectedIds = await _repository.getConnectedProviders();
    final List<EPSConnection> connections = [];

    for (final id in connectedIds) {
      final token = await _repository.getToken(id);
      final provider = await _repository.getProviderDetails(id);
      final patientId = await _repository.getPatientId(id);

      if (token != null && provider != null) {
        connections.add(EPSConnection(
          provider: provider,
          token: token,
          patientId: patientId ?? 'Unknown',
          connectedAt: DateTime.now(),
        ));
      }
    }
    return connections;
  }
}
