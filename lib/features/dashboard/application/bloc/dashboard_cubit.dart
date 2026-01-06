import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../user_profile/domain/entities/user_profile.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../../allergies/domain/entities/allergy.dart';
import '../../../allergies/domain/repositories/allergy_repository.dart';
import '../../../vitals/domain/entities/vital_sign.dart';
import '../../../vitals/domain/repositories/vital_sign_repository.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../../medications/domain/repositories/medication_repository.dart';

part 'dashboard_state.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  final UserProfileRepository _userProfileRepository;
  final AllergyRepository _allergyRepository;
  final VitalSignRepository _vitalSignRepository;
  final AppointmentRepository _appointmentRepository;
  final MedicationRepository _medicationRepository;

  DashboardCubit(
    this._userProfileRepository,
    this._allergyRepository,
    this._vitalSignRepository,
    this._appointmentRepository,
    this._medicationRepository,
  ) : super(DashboardInitial());

  /// Load all dashboard data
  Future<void> loadDashboard() async {
    emit(DashboardLoading());
    try {
      // Load all data in parallel for efficiency
      final results = await Future.wait([
        _userProfileRepository.getUserProfile(),
        _allergyRepository.getCriticalAllergies(),
        _vitalSignRepository.getLatestVitals(),
        _appointmentRepository.getLastCompletedAppointment(),
        _appointmentRepository.getNextAppointment(),
        _medicationRepository.getCurrentMedication(),
      ]);

      final userProfile = results[0] as UserProfile?;
      final criticalAllergies = results[1] as List<Allergy>;
      final latestVitals = results[2] as Map<VitalSignType, VitalSign?>;
      final lastConsultation = results[3] as Appointment?;
      final nextAppointment = results[4] as Appointment?;
      final currentMedication = results[5] as Medication?;

      // Build health metrics from user profile and vital signs
      final healthMetrics = HealthMetricsSnapshot(
        bloodType: userProfile?.bloodType,
        weight: userProfile?.weight,
        height: userProfile?.height,
        heartRate: latestVitals[VitalSignType.heartRate]?.value,
        temperature: latestVitals[VitalSignType.temperature]?.value,
        systolicPressure:
            latestVitals[VitalSignType.bloodPressureSystolic]?.value,
        diastolicPressure:
            latestVitals[VitalSignType.bloodPressureDiastolic]?.value,
      );

      // Build recent activity
      final recentActivity = RecentActivity(
        lastConsultation: lastConsultation,
        nextAppointment: nextAppointment,
        currentMedication: currentMedication,
      );

      emit(
        DashboardLoaded(
          userProfile: userProfile,
          criticalAllergies: criticalAllergies,
          healthMetrics: healthMetrics,
          recentActivity: recentActivity,
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  /// Refresh only the health metrics (useful after syncing with health devices)
  Future<void> refreshHealthMetrics() async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    try {
      final results = await Future.wait([
        _userProfileRepository.getUserProfile(),
        _vitalSignRepository.getLatestVitals(),
      ]);

      final userProfile = results[0] as UserProfile?;
      final latestVitals = results[1] as Map<VitalSignType, VitalSign?>;

      final healthMetrics = HealthMetricsSnapshot(
        bloodType: userProfile?.bloodType,
        weight: userProfile?.weight,
        height: userProfile?.height,
        heartRate: latestVitals[VitalSignType.heartRate]?.value,
        temperature: latestVitals[VitalSignType.temperature]?.value,
        systolicPressure:
            latestVitals[VitalSignType.bloodPressureSystolic]?.value,
        diastolicPressure:
            latestVitals[VitalSignType.bloodPressureDiastolic]?.value,
      );

      emit(
        currentState.copyWith(
          userProfile: userProfile,
          healthMetrics: healthMetrics,
        ),
      );
    } catch (e) {
      // Don't emit error state, just keep current state on refresh failure
    }
  }

  /// Refresh only the recent activity section
  Future<void> refreshRecentActivity() async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    try {
      final results = await Future.wait([
        _appointmentRepository.getLastCompletedAppointment(),
        _appointmentRepository.getNextAppointment(),
        _medicationRepository.getCurrentMedication(),
      ]);

      final recentActivity = RecentActivity(
        lastConsultation: results[0] as Appointment?,
        nextAppointment: results[1] as Appointment?,
        currentMedication: results[2] as Medication?,
      );

      emit(currentState.copyWith(recentActivity: recentActivity));
    } catch (e) {
      // Don't emit error state, just keep current state on refresh failure
    }
  }
}
