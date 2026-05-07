import 'package:isar/isar.dart';

part 'report.g.dart';

enum ReportStatus {
  pending,
  finalized,
  urgent,
}

@collection
class Report {
  Id id = Isar.autoIncrement;

  DateTime? generatedAt;

  String? title;

  String? content; // Markdown content

  @enumerated
  ReportStatus status = ReportStatus.finalized;

  Report({
    this.generatedAt,
    this.title,
    this.content,
    this.status = ReportStatus.finalized,
  });

  String get statusLabel {
    switch (status) {
      case ReportStatus.pending:
        return 'Pendiente';
      case ReportStatus.finalized:
        return 'Finalizado';
      case ReportStatus.urgent:
        return 'Urgente';
    }
  }
}
