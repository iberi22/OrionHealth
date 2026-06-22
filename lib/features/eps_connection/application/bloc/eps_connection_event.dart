// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:equatable/equatable.dart';
import '../../domain/entities/eps_provider.dart';

abstract class EpsConnectionEvent extends Equatable {
  const EpsConnectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadConnections extends EpsConnectionEvent {
  const LoadConnections();
}

class ConnectProvider extends EpsConnectionEvent {
  final EPSProvider provider;
  const ConnectProvider(this.provider);

  @override
  List<Object?> get props => [provider];
}

class DisconnectProvider extends EpsConnectionEvent {
  final String providerId;
  const DisconnectProvider(this.providerId);

  @override
  List<Object?> get props => [providerId];
}
