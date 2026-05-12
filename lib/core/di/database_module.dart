import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/entities/api_audit_log.dart';
import '../../features/user_profile/infrastructure/persistence/isar_user_profile.dart';
import '../../features/local_agent/infrastructure/persistence/isar_chat_message.dart';
import '../../features/health_record/infrastructure/persistence/isar_medical_record.dart';
import '../../features/reports/infrastructure/persistence/isar_report.dart';
import '../../features/ssi/infrastructure/persistence/isar_did.dart';
import '../../features/ssi/infrastructure/persistence/isar_credential.dart';
import '../../features/ssi/infrastructure/persistence/isar_revocation_entry.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';
import 'package:health_wallet/health_wallet.dart' hide HealthRecord, LabResult, VitalSign, VitalSignSchema, MedicationEntry, MedicalDocument, MedicalEvent;

@module
abstract class DatabaseModule {
  @preResolve
  Future<Isar> get isar async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [
        IsarUserProfileSchema,
        ApiAuditLogSchema,
        IsarChatMessageSchema,
        IsarMedicalRecordSchema,
        MemoryNodeSchema,
        MemoryEdgeSchema,
        IsarReportSchema,
        IsarDidSchema,
        IsarCredentialSchema,
        IsarRevocationEntrySchema,
        HealthRecordSchema,
        LabResultSchema,
        VitalSignSchema,
        MedicationEntrySchema,
        MedicalDocumentSchema,
        MedicalEventSchema,
      ],
      directory: dir.path,
    );
  }
}
