import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../../auth/infrastructure/services/encryption_service.dart';
import '../../domain/entities/vital_sign.dart';
import '../../domain/repositories/vital_sign_repository.dart';

@LazySingleton(as: VitalSignRepository)
class VitalSignRepositoryImpl implements VitalSignRepository {
  final Isar _isar;
  final EncryptionService _encryptionService;

  VitalSignRepositoryImpl(this._isar, this._encryptionService);

  Future<VitalSign> _encryptVitalSign(VitalSign vitalSign) async {
    if (vitalSign.encryptedValue != null) {
      vitalSign.encryptedValue = await _encryptionService.encryptHealthData(
        vitalSign.encryptedValue!,
      );
    }
    if (vitalSign.encryptedNotes != null) {
      vitalSign.encryptedNotes = await _encryptionService.encryptHealthData(
        vitalSign.encryptedNotes!,
      );
    }
    return vitalSign;
  }

  Future<VitalSign> _decryptVitalSign(VitalSign vitalSign) async {
    if (vitalSign.encryptedValue != null) {
      vitalSign.encryptedValue = await _encryptionService.decryptHealthData(
        vitalSign.encryptedValue!,
      );
    }
    if (vitalSign.encryptedNotes != null) {
      vitalSign.encryptedNotes = await _encryptionService.decryptHealthData(
        vitalSign.encryptedNotes!,
      );
    }
    return vitalSign;
  }

  @override
  Future<void> saveVitalSign(VitalSign vitalSign) async {
    await _encryptVitalSign(vitalSign);
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.put(vitalSign);
    });
  }

  @override
  Future<void> saveVitalSigns(List<VitalSign> vitalSigns) async {
    if (vitalSigns.isEmpty) return;
    await Future.wait(vitalSigns.map((v) => _encryptVitalSign(v)));
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.putAll(vitalSigns);
    });
  }

  @override
  Future<List<VitalSign>> getAllVitalSigns() async {
    final vitals = await _isar.vitalSigns
        .where()
        .sortByDateTimeDesc()
        .findAll();
    return await Future.wait(vitals.map((v) => _decryptVitalSign(v)));
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
      if (latest != null) {
        latestVitals[type] = await _decryptVitalSign(latest);
      } else {
        latestVitals[type] = null;
      }
    }

    return latestVitals;
  }
}
