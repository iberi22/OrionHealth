import '../../domain/entities/shared_health_package.dart';
import '../datasources/health_sharing_local_datasource.dart';

class HealthSharingRepository {
  final HealthSharingLocalDataSource _localDataSource;
  HealthSharingRepository(this._localDataSource);

  Future<List<SharedHealthPackage>> getSentPackages() => _localDataSource.getSentPackages();
  Future<List<SharedHealthPackage>> getReceivedPackages() => _localDataSource.getReceivedPackages();
  Future<void> sendPackage(SharedHealthPackage pkg) async => _localDataSource.savePackage(pkg);
}
