import '../entities/vital_sign.dart';

abstract class VitalSignRepository {
  Future<List<VitalSign>> getAllVitalSigns();
  Future<List<VitalSign>> getVitalSignsByType(VitalSignType type);
  Future<VitalSign?> getLatestByType(VitalSignType type);
  Future<Map<VitalSignType, VitalSign?>> getLatestVitals();
  Future<VitalSign?> getVitalSignById(int id);
  Future<void> saveVitalSign(VitalSign vitalSign);
  Future<void> saveVitalSigns(List<VitalSign> vitalSigns);
  Future<void> deleteVitalSign(int id);
}
