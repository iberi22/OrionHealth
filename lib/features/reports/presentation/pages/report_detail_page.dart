import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../domain/entities/report.dart';

class ReportDetailPage extends StatelessWidget {
  final Report report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(report.title ?? 'Detalle del Informe'),
      ),
      body: RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Markdown(data: report.content ?? ''),
        ),
      ),
    );
  }
}
