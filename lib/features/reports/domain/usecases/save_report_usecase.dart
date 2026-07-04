import 'package:injectable/injectable.dart';
import '../entities/report.dart';
import '../repositories/report_repository.dart';

@injectable
class SaveReportUseCase {
  final ReportRepository repository;

  SaveReportUseCase(this.repository);

  Future<void> call(Report report) async {
    return repository.saveReport(report);
  }
}
