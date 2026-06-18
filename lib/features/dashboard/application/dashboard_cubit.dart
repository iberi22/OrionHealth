import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/usecases/get_dashboard_stats_usecase.dart';
import '../domain/usecases/get_recent_activity_usecase.dart';
import 'dashboard_state.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardStatsUseCase _getDashboardStats;
  final GetRecentActivityUseCase _getRecentActivity;

  DashboardCubit(
    this._getDashboardStats,
    this._getRecentActivity,
  ) : super(DashboardInitial());

  Future<void> loadDashboardData() async {
    emit(DashboardLoading());
    try {
      final stats = await _getDashboardStats();
      final activities = await _getRecentActivity();
      emit(DashboardLoaded(stats: stats, activities: activities));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
