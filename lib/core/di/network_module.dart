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
