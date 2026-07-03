import 'package:injectable/injectable.dart';
import '../../domain/entities/shared_health_package.dart';
import '../../domain/repositories/sharing_repository.dart';
import '../datasources/health_sharing_local_datasource.dart';

@LazySingleton(as: SharingRepository)
class HealthSharingRepositoryImpl implements SharingRepository {
  final HealthSharingLocalDataSource _localDataSource;
  HealthSharingRepositoryImpl(this._localDataSource);

  @override
  Future<List<SharedHealthPackage>> getSentPackages() => _localDataSource.getSentPackages();

  @override
  Future<List<SharedHealthPackage>> getReceivedPackages() => _localDataSource.getReceivedPackages();

  @override
  Future<void> sendPackage(SharedHealthPackage pkg) async => _localDataSource.savePackage(pkg);
}
