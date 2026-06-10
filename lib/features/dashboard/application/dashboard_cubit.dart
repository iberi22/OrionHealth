import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/repositories/dashboard_repository.dart';
import 'dashboard_state.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;

  DashboardCubit(this._repository) : super(DashboardInitial());

  Future<void> loadDashboardData() async {
    emit(DashboardLoading());
    try {
      final stats = await _repository.getDashboardStats();
      final activities = await _repository.getRecentActivity();
      emit(DashboardLoaded(stats: stats, activities: activities));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
