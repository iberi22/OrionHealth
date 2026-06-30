import 'package:injectable/injectable.dart';
import '../../domain/entities/shared_health_package.dart';

@lazySingleton
class HealthSharingLocalDataSource {
  HealthSharingLocalDataSource();

  Future<List<SharedHealthPackage>> getSentPackages() async => [];

  Future<List<SharedHealthPackage>> getReceivedPackages() async => [];

  Future<void> savePackage(SharedHealthPackage pkg) async {}
}
