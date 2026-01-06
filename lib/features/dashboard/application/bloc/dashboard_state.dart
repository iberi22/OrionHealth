part of 'dashboard_cubit.dart';

/// Represents a snapshot of health metrics for the dashboard
class HealthMetricsSnapshot {
  final String? bloodType;
  final double? weight;
  final double? height;
  final double? heartRate;
  final double? temperature;
  final double? systolicPressure;
  final double? diastolicPressure;

  const HealthMetricsSnapshot({
    this.bloodType,
    this.weight,
    this.height,
    this.heartRate,
    this.temperature,
    this.systolicPressure,
    this.diastolicPressure,
  });

  String get formattedWeight => weight != null ? '${weight!.toStringAsFixed(0)} kg' : '--';
  String get formattedHeight => height != null ? '${height!.toStringAsFixed(0)} cm' : '--';
  String get formattedHeartRate => heartRate != null ? '${heartRate!.toStringAsFixed(0)}' : '--';
  String get formattedTemperature => temperature != null ? '${temperature!.toStringAsFixed(1)}°C' : '--';
  String get formattedBloodPressure {
    if (systolicPressure != null && diastolicPressure != null) {
      return '${systolicPressure!.toStringAsFixed(0)}/${diastolicPressure!.toStringAsFixed(0)}';
    }
    return '--';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthMetricsSnapshot &&
          runtimeType == other.runtimeType &&
          bloodType == other.bloodType &&
          weight == other.weight &&
          height == other.height &&
          heartRate == other.heartRate &&
          temperature == other.temperature &&
          systolicPressure == other.systolicPressure &&
          diastolicPressure == other.diastolicPressure;

  @override
  int get hashCode =>
      bloodType.hashCode ^
      weight.hashCode ^
      height.hashCode ^
      heartRate.hashCode ^
      temperature.hashCode ^
      systolicPressure.hashCode ^
      diastolicPressure.hashCode;
}

/// Represents the recent activity data for the dashboard
class RecentActivity {
  final Appointment? lastConsultation;
  final Appointment? nextAppointment;
  final Medication? currentMedication;

  const RecentActivity({
    this.lastConsultation,
    this.nextAppointment,
    this.currentMedication,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentActivity &&
          runtimeType == other.runtimeType &&
          lastConsultation?.id == other.lastConsultation?.id &&
          nextAppointment?.id == other.nextAppointment?.id &&
          currentMedication?.id == other.currentMedication?.id;

  @override
  int get hashCode =>
      lastConsultation.hashCode ^
      nextAppointment.hashCode ^
      currentMedication.hashCode;
}

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final UserProfile? userProfile;
  final List<Allergy> criticalAllergies;
  final HealthMetricsSnapshot healthMetrics;
  final RecentActivity recentActivity;

  const DashboardLoaded({
    this.userProfile,
    this.criticalAllergies = const [],
    this.healthMetrics = const HealthMetricsSnapshot(),
    this.recentActivity = const RecentActivity(),
  });

  @override
  List<Object?> get props => [
        userProfile?.id,
        userProfile?.name,
        criticalAllergies.length,
        healthMetrics,
        recentActivity,
      ];

  DashboardLoaded copyWith({
    UserProfile? userProfile,
    List<Allergy>? criticalAllergies,
    HealthMetricsSnapshot? healthMetrics,
    RecentActivity? recentActivity,
  }) {
    return DashboardLoaded(
      userProfile: userProfile ?? this.userProfile,
      criticalAllergies: criticalAllergies ?? this.criticalAllergies,
      healthMetrics: healthMetrics ?? this.healthMetrics,
      recentActivity: recentActivity ?? this.recentActivity,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
