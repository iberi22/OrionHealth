import 'package:injectable/injectable.dart';
import '../entities/activity_item.dart';
import '../repositories/dashboard_repository.dart';

@injectable
class GetRecentActivityUseCase {
  final DashboardRepository _repository;

  GetRecentActivityUseCase(this._repository);

  Future<List<ActivityItem>> call() async {
    return _repository.getRecentActivity();
  }
}
