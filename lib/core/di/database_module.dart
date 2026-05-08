import 'dart:typed_data';
import 'package:hex/hex.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/auth/infrastructure/services/encryption_service.dart';
import '../domain/entities/api_audit_log.dart';
import '../../features/user_profile/domain/entities/user_profile.dart';
import '../../features/local_agent/domain/chat_message.dart';
import '../../features/health_record/domain/entities/medical_record.dart';
import '../../features/reports/domain/entities/report.dart';
import '../../features/medications/domain/entities/medication.dart';
import '../../features/vitals/domain/entities/vital_sign.dart';
import '../../features/appointments/domain/entities/appointment.dart';
import '../../features/allergies/domain/entities/allergy.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'package:health_wallet/health_wallet.dart' hide HealthRecord, LabResult, VitalSign, VitalSignSchema, MedicationEntry, MedicalDocument, MedicalEvent;

@module
abstract class DatabaseModule {
  String uint8ListToHex(Uint8List bytes) => HEX.encode(bytes);

  @preResolve
  Future<Isar> get isar async {
    final dir = await getApplicationDocumentsDirectory();
    final encryptionService = EncryptionServiceImpl();
    final keyBytes = await encryptionService.getDatabaseKey();
    final keyHex = uint8ListToHex(Uint8List.fromList(keyBytes));

    final schemas = [
      UserProfileSchema,
      ApiAuditLogSchema,
      ChatMessageSchema,
      MedicalRecordSchema,
      MemoryNodeSchema,
      MemoryEdgeSchema,
      ReportSchema,
      MedicationSchema,
      AppointmentSchema,
      AllergySchema,
      HealthRecordSchema,
      LabResultSchema,
      VitalSignSchema,
      MedicationEntrySchema,
      MedicalDocumentSchema,
      MedicalEventSchema,
    ];

    try {
      return await Isar.open(
        schemas,
        directory: dir.path,
        encryptionKey: keyHex,
      );
    } catch (e) {
      // Fallback for existing unencrypted databases or migration path
      return await Isar.open(
        schemas,
        directory: dir.path,
      );
    }
  }
}
