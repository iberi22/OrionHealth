import 'package:equatable/equatable.dart';
import '../domain/entities/activity_item.dart';
import '../domain/entities/dashboard_stats.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<ActivityItem> activities;

  const DashboardLoaded({
    required this.stats,
    required this.activities,
  });

  @override
  List<Object?> get props => [stats, activities];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
