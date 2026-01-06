import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/user_profile/domain/entities/user_profile.dart';
import '../../features/local_agent/domain/chat_message.dart';
import '../../features/health_record/domain/entities/medical_record.dart';
import '../../features/health_report/domain/entities/health_report.dart';
import '../../features/allergies/domain/entities/allergy.dart';
import '../../features/vitals/domain/entities/vital_sign.dart';
import '../../features/appointments/domain/entities/appointment.dart';
import '../../features/medications/domain/entities/medication.dart';
import '../../features/auth/domain/entities/auth_credentials.dart';
import 'package:isar_agent_memory/isar_agent_memory.dart';

@module
abstract class DatabaseModule {
  @preResolve
  Future<Isar> get isar async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open([
      UserProfileSchema,
      ChatMessageSchema,
      MedicalRecordSchema,
      MemoryNodeSchema,
      MemoryEdgeSchema,
      HealthReportSchema,
      AllergySchema,
      VitalSignSchema,
      AppointmentSchema,
      MedicationSchema,
      AuthCredentialsSchema,
    ], directory: dir.path);
  }
}
