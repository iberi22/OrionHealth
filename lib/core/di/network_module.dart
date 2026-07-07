// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:medical_standards/medical_standards.dart';
import '../network/http_client.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio get dio => HttpClientFactory.createDio();

  @lazySingleton
  MedicalContextProvider get medicalContextProvider => MedicalContextProvider();

  @lazySingleton
  SyncService get syncService => SyncService();
}
