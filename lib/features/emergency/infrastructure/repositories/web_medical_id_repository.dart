/// FEAT-022: Web implementation of MedicalIdRepository
///
/// Uses SharedPreferences + JSON. For Flutter Web.
///
/// Privacy: JSON stored as-is in SharedPreferences (browser localStorage).
/// For higher security, encrypt with Web Crypto API + PIN-derived key.
/// MVP: relies on device-level security (browser profile, OS user account).
library;

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/medical_id.dart';
import '../../domain/repositories/medical_id_repository.dart';

// NOTE: not registered via injectable — main_web.dart constructs it directly.
// A LazySingleton(as: MedicalIdRepository, env: ['web']) here collides with
// IsarMedicalIdRepository's env-less registration (injectable generator:
// "registered more than once under the same environment").
class WebMedicalIdRepository implements MedicalIdRepository {
  static const _prefix = 'emergency.medical_id.';

  @override
  Future<MedicalIdEntity?> getByUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$userId');
    if (raw == null) return null;
    return MedicalIdEntity.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(MedicalIdEntity medicalId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefix${medicalId.userId}',
      json.encode(medicalId.toJson()),
    );
  }

  @override
  Future<void> delete(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$userId');
  }

  @override
  Future<List<String>> getCriticalFields(String userId) async {
    final id = await getByUser(userId);
    return id?.toCriticalCard() ?? const [];
  }
}
