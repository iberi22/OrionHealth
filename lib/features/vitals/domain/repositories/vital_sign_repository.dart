import '../entities/vital_sign.dart';

abstract class VitalSignRepository {
  Future<List<VitalSign>> getAllVitals();
  Future<List<VitalSign>> getVitalsByType(VitalType type);
  Future<void> saveVital(VitalSign vital);
  Future<void> deleteVital(int id);
  Stream<List<VitalSign>> watchVitals();
}
