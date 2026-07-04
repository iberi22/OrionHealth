import 'package:injectable/injectable.dart';
import '../entities/report.dart';
import '../repositories/report_repository.dart';

@injectable
class GetReportsUseCase {
  final ReportRepository repository;

  GetReportsUseCase(this.repository);

  Future<List<Report>> call() async {
    return repository.getReports();
  }
}
