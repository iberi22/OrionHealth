import '../entities/shared_health_package.dart';

abstract class SharingRepository {
  Future<List<SharedHealthPackage>> getSentPackages();
  Future<List<SharedHealthPackage>> getReceivedPackages();
  Future<void> sendPackage(SharedHealthPackage pkg);
}
