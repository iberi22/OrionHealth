import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
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
          automaticallyImplyLeading: false,
          title: const Text('Programar Citas'),
        ),
        body: BlocBuilder<HealthReportBloc, HealthReportState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _PrimaryActionCard(),
                  ),
                ),
                if (state is HealthReportLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (state is HealthReportLoaded)
                  ..._buildReportList(context, state),
                if (state is HealthReportError)
                  SliverFillRemaining(
                    child: Center(child: Text('Error: ${state.message}')),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildReportList(BuildContext context, HealthReportLoaded state) {
    if (state.reports.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.white54),
                  SizedBox(height: 16),
                  Text('No tienes citas programadas.'),
                ],
              ),
            ),
          ),
        )
      ];
    }
    return [
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Próximas Citas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final report = state.reports[index];
            return _AppointmentItem(
              doctorName: report.title ?? 'Dr. Desconocido',
              specialty: 'Cardiología', // Mock data
              dateTime: '15 DIC, 10:30 AM', // Mock data
              status: 'Confirmada',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportDetailPage(report: report),
                  ),
                );
              },
            );
          },
          childCount: state.reports.length,
        ),
      ),
    ];
  }
}

class _PrimaryActionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.add_circle, color: CyberTheme.primary, size: 48),
            const SizedBox(height: 16),
            const Text('Agendar Nueva Cita',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Inicia el proceso para reservar una nueva consulta con un proveedor de salud.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberTheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              ),
              onPressed: () {
                context.read<HealthReportBloc>().add(GenerateReportEvent(
                      prompt: 'Generar nueva cita',
                      contextData: ['Cardiología'],
                    ));
              },
              child: const Text('Agendar Ahora'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentItem extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String dateTime;
  final String status;
  final VoidCallback onTap;

  const _AppointmentItem({
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassmorphicCard(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_border, color: CyberTheme.secondary, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(specialty, style: TextStyle(color: Colors.white.withOpacity(0.7))),
                        ],
                      ),
                    ),
                    Text(dateTime, style: const TextStyle(color: CyberTheme.secondary)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Status: $status', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    const Text('Ver Detalles', style: TextStyle(color: CyberTheme.secondary)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
