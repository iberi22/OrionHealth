import '../../domain/entities/vital_sign.dart';
import '../../domain/repositories/vital_sign_repository.dart';
import '../datasources/vital_sign_local_datasource.dart';

class VitalSignRepositoryImpl implements VitalSignRepository {
  final VitalSignLocalDataSource _localDataSource;
  VitalSignRepositoryImpl(this._localDataSource);

  @override
  Future<void> saveVitalSign(VitalSign vitalSign) => _localDataSource.saveVitalSign(vitalSign);
  @override
  Future<void> saveVitalSigns(List<VitalSign> vitalSigns) => _localDataSource.saveVitalSigns(vitalSigns);
  @override
  Future<List<VitalSign>> getAllVitalSigns() => _localDataSource.getAllVitalSigns();
  @override
  Future<Map<VitalSignType, VitalSign?>> getLatestVitals() async {
    final result = <VitalSignType, VitalSign?>{};
    for (final type in VitalSignType.values) {
      result[type] = await _localDataSource.getLatestByType(type);
    }
    return result;
  }
}
