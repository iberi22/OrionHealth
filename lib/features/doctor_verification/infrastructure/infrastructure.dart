/// Infrastructure layer for doctor_verification feature.
///
/// Re-exports from the data layer for clean architecture consistency.
/// Actual implementations live under data/ for legacy reasons.
export '../data/repositories/isar_doctor_profile_repository.dart';
export '../data/repositories/isar_rating_repository.dart';
export '../data/datasources/license_registry_local.dart';
export '../data/models/doctor_profile_model.dart';
