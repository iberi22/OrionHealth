// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:equatable/equatable.dart';

abstract class EmailCitasEvent extends Equatable {
  const EmailCitasEvent();

  @override
  List<Object?> get props => [];
}

class ConnectGmail extends EmailCitasEvent {
  const ConnectGmail();
}

class ConnectOutlook extends EmailCitasEvent {
  const ConnectOutlook();
}

class HandleOAuthRedirect extends EmailCitasEvent {
  final Uri uri;
  const HandleOAuthRedirect(this.uri);

  @override
  List<Object?> get props => [uri];
}

class ManualSync extends EmailCitasEvent {
  const ManualSync();
}

class SyncAppointments extends EmailCitasEvent {
  final String code;
  const SyncAppointments(this.code);

  @override
  List<Object?> get props => [code];
}
