import 'dart:convert';
import 'package:isar/isar.dart';
import '../../domain/services/ecosystem_import_service.dart';

part 'meal_log.g.dart';

/// Cached GOS item references and declared nutrition, never a food catalog.
@collection
class MealLog {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String recordId;
  late String subject;
  late DateTime consumedAt;
  late String mealType;
  late String itemsJson;
  late String nutritionJson;
  late String nutritionSource;
  late String envelopeJson;

  MealLog();

  factory MealLog.fromRecord(Map<String, dynamic> record) {
    final data = record['data'] as Map<String, dynamic>;
    return MealLog()
      ..recordId = record['id'] as String
      ..subject = record['subject'] as String
      ..consumedAt = parseEcosystemTimestamp(data['consumedAt'] as String)
      ..mealType = data['mealType'] as String
      ..itemsJson = jsonEncode(data['items'])
      ..nutritionJson = jsonEncode(data['nutrition'])
      ..nutritionSource = data['nutritionSource'] as String
      ..envelopeJson = jsonEncode(record);
  }
}

/// Retains received profiles locally without altering allergies automatically.
@collection
class EcosystemDietaryProfile {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String recordId;
  late String subject;
  late DateTime expiresAt;
  late String envelopeJson;

  EcosystemDietaryProfile();

  factory EcosystemDietaryProfile.fromRecord(Map<String, dynamic> record) {
    final data = record['data'] as Map<String, dynamic>;
    return EcosystemDietaryProfile()
      ..recordId = record['id'] as String
      ..subject = record['subject'] as String
      ..expiresAt = parseEcosystemTimestamp(data['expiresAt'] as String)
      ..envelopeJson = jsonEncode(record);
  }
}
