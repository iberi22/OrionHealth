import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../domain/entities/health_report.dart';

class ReportDetailPage extends StatelessWidget {
  final HealthReport report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(report.title ?? 'Detalle del Informe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Markdown(data: report.content ?? ''),
      ),
    );
  }
}
