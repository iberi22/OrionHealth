// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:equatable/equatable.dart';
import '../../application/health_import_state.dart';

abstract class HealthImportEvent extends Equatable {
  const HealthImportEvent();

  @override
  List<Object?> get props => [];
}

class CheckAvailableSources extends HealthImportEvent {
  const CheckAvailableSources();
}

class ImportFromSource extends HealthImportEvent {
  final HealthDataSource source;
  const ImportFromSource(this.source);

  @override
  List<Object?> get props => [source];
}

class ResetImport extends HealthImportEvent {
  const ResetImport();
}
