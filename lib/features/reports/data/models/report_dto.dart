import '../../domain/entities/report.dart';

class ReportDto {
  final int? id;
  final String? title;
  final String? content;
  final DateTime? generatedAt;
  final ReportStatus? status;

  const ReportDto({
    this.id,
    this.title,
    this.content,
    this.generatedAt,
    this.status,
  });

  factory ReportDto.fromEntity(Report e) => ReportDto(
        id: e.id,
        title: e.title,
        content: e.content,
        generatedAt: e.generatedAt,
        status: e.status,
      );

  Report toEntity() => Report(
        id: id,
        title: title,
        content: content,
        generatedAt: generatedAt,
        status: status ?? ReportStatus.finalized,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (generatedAt != null) 'generatedAt': generatedAt!.toIso8601String(),
        if (status != null) 'status': status!.name,
      };

  factory ReportDto.fromJson(Map<String, dynamic> j) => ReportDto(
        id: j['id'] as int?,
        title: j['title'] as String?,
        content: j['content'] as String?,
        generatedAt: j['generatedAt'] != null
            ? DateTime.parse(j['generatedAt'] as String)
            : null,
        status: j['status'] != null
            ? ReportStatus.values.firstWhere(
                (s) => s.name == j['status'],
                orElse: () => ReportStatus.finalized,
              )
            : null,
      );
}
