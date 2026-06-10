import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalMedications;
  final int reportsCount;
  final DateTime? lastVitalCheck;

  const DashboardStats({
    required this.totalMedications,
    required this.reportsCount,
    this.lastVitalCheck,
  });

  @override
  List<Object?> get props => [totalMedications, reportsCount, lastVitalCheck];
}
