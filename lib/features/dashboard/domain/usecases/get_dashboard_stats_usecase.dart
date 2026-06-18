import 'package:injectable/injectable.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

@injectable
class GetDashboardStatsUseCase {
  final DashboardRepository _repository;

  GetDashboardStatsUseCase(this._repository);

  Future<DashboardStats> call() async {
    return _repository.getDashboardStats();
  }
}
