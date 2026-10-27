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

  VitalSign _copyVitalSign(VitalSign v) {
    final copy = VitalSign(
      type: v.type,
      dateTime: v.dateTime,
      unit: v.unit,
      source: v.source,
    )..id = v.id;
    copy.encryptedValue = v.encryptedValue;
    copy.encryptedNotes = v.encryptedNotes;
    return copy;
  }

  Future<VitalSign> _encryptVitalSign(VitalSign vitalSign) async {
    final copy = _copyVitalSign(vitalSign);
    if (copy.encryptedValue != null) {
      copy.encryptedValue = await _encryptionService.encryptHealthData(
        copy.encryptedValue!,
      );
    }
    if (copy.encryptedNotes != null) {
      copy.encryptedNotes = await _encryptionService.encryptHealthData(
        copy.encryptedNotes!,
      );
    }
    return copy;
  }

  Future<String> _safeDecrypt(String data) async {
    try {
      return await _encryptionService.decryptHealthData(data);
    } catch (_) {
      return data;
    }
  }

  Future<VitalSign> _decryptVitalSign(VitalSign vitalSign) async {
    final copy = _copyVitalSign(vitalSign);
    if (copy.encryptedValue != null) {
      copy.encryptedValue = await _safeDecrypt(copy.encryptedValue!);
    }
    if (copy.encryptedNotes != null) {
      copy.encryptedNotes = await _safeDecrypt(copy.encryptedNotes!);
    }
    return copy;
  }

  @override
  Future<void> saveVitalSign(VitalSign vitalSign) async {
    final encrypted = await _encryptVitalSign(vitalSign);
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.put(encrypted);
    });
  }

  @override
  Future<void> saveVitalSigns(List<VitalSign> vitalSigns) async {
    if (vitalSigns.isEmpty) return;
    final encryptedList = await Future.wait(
      vitalSigns.map((v) => _encryptVitalSign(v)),
    );
    await _isar.writeTxn(() async {
      await _isar.vitalSigns.putAll(encryptedList);
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
