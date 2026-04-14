import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/user_profile/domain/entities/user_profile.dart';
import '../../features/local_agent/domain/chat_message.dart';
import '../../features/health_record/domain/entities/medical_record.dart';
import '../../features/health_report/domain/entities/health_report.dart';
import '../../features/vitals/domain/entities/vital_sign.dart';
import '../../features/allergies/domain/entities/allergy.dart';
import '../../features/medications/domain/entities/medication.dart';
import '../../features/appointments/domain/entities/appointment.dart';
import '../services/encryption_service.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';

@module
abstract class DatabaseModule {
  @preResolve
  Future<Isar> isar(EncryptionService encryptionService) async {
    final dir = await getApplicationDocumentsDirectory();
    final encryptionKey = await encryptionService.getStoredKey();

    return Isar.open(
      [
        UserProfileSchema,
        ChatMessageSchema,
        MedicalRecordSchema,
        MemoryNodeSchema,
        MemoryEdgeSchema,
        HealthReportSchema,
        VitalSignSchema,
        AllergySchema,
        MedicationSchema,
        AppointmentSchema,
      ],
      directory: dir.path,
      encryptionKey: encryptionKey?.join(','), // Isar expects a hex string or key
    );
  }
}
