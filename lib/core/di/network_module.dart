// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:medical_standards/medical_standards.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio get dio => Dio();

  @lazySingleton
  MedicalContextProvider get medicalContextProvider => MedicalContextProvider();

  @lazySingleton
  SyncService get syncService => SyncService();
}
