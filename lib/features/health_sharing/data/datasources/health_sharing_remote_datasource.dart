import 'package:injectable/injectable.dart';

@lazySingleton
class HealthSharingRemoteDataSource {
  Future<bool> sendPackageViaNfc(String payload) async => false;
  Future<bool> sendPackageViaBle(String payload) async => false;
  Future<bool> sendPackageViaWifi(String payload) async => false;
}
