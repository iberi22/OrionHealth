import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/vital_sign.dart';
import '../../domain/repositories/vital_sign_repository.dart';

@LazySingleton(as: VitalSignRepository)
class VitalSignRepositoryImpl implements VitalSignRepository {
  final Isar _isar;

  VitalSignRepositoryImpl(this._isar);

  @override
  Future<void> saveVitalSign(VitalSign vitalSign) async {
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.put(vitalSign);
    });
  }

  @override
  Future<void> saveVitalSigns(List<VitalSign> vitalSigns) async {
    if (vitalSigns.isEmpty) return;
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.putAll(vitalSigns);
    });
  }

  @override
  Future<List<VitalSign>> getAllVitalSigns() async {
    return await _isar.vitalSigns.where().sortByDateTimeDesc().findAll();
  }

  @override
  Future<Map<VitalSignType, VitalSign?>> getLatestVitals() async {
    final Map<VitalSignType, VitalSign?> latestVitals = {};

    for (var type in VitalSignType.values) {
      final latest = await _isar.vitalSigns
          .filter()
          .typeEqualTo(type)
          .sortByDateTimeDesc()
          .findFirst();
      latestVitals[type] = latest;
    }

    return latestVitals;
  }
}
