import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../application/bloc/health_report_bloc.dart';
import 'report_detail_page.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HealthReportBloc>()..add(LoadReports()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Informes de Salud'),
        ),
        body: BlocBuilder<HealthReportBloc, HealthReportState>(
          builder: (context, state) {
            if (state is HealthReportLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HealthReportLoaded) {
              if (state.reports.isEmpty) {
                return const Center(child: Text('No hay informes generados.'));
              }
              return ListView.builder(
                itemCount: state.reports.length,
                itemBuilder: (context, index) {
                  final report = state.reports[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(report.title ?? 'Sin título'),
                      subtitle: Text(report.generatedAt?.toString() ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          context.read<HealthReportBloc>().add(DeleteReport(report.id));
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportDetailPage(report: report),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            } else if (state is HealthReportError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
                // Trigger generation with mock data
                context.read<HealthReportBloc>().add(GenerateReportEvent(
                  prompt: 'Generar informe general',
                  contextData: ['Paciente masculino, 30 años', 'Presión arterial normal'],
                ));
              },
              child: const Icon(Icons.add),
            );
          }
        ),
      ),
    );
  }
}
