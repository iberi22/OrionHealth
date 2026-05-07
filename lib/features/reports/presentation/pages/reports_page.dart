import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../application/bloc/report_bloc.dart';
import '../../domain/entities/report.dart';
import '../widgets/report_card.dart';
import 'report_detail_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  ReportStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReportBloc>()..add(LoadReports()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Informes de Salud'),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<ReportBloc>().add(LoadReports());
              },
              color: AppColors.primary,
              child: BlocBuilder<ReportBloc, ReportState>(
                builder: (context, state) {
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _PrimaryActionCard(),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _buildFilterBar(),
                      ),
                      if (state is ReportLoading)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (state is ReportLoaded)
                        ..._buildFilteredReportList(context, state.reports),
                      if (state is ReportError)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: Text('Error: ${state.message}')),
                        ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'Todos',
            isSelected: _selectedStatus == null,
            onSelected: (_) => setState(() => _selectedStatus = null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Urgentes',
            isSelected: _selectedStatus == ReportStatus.urgent,
            onSelected: (_) => setState(() => _selectedStatus = ReportStatus.urgent),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Finalizados',
            isSelected: _selectedStatus == ReportStatus.finalized,
            onSelected: (_) => setState(() => _selectedStatus = ReportStatus.finalized),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Pendientes',
            isSelected: _selectedStatus == ReportStatus.pending,
            onSelected: (_) => setState(() => _selectedStatus = ReportStatus.pending),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredReportList(BuildContext context, List<Report> allReports) {
    final filteredReports = _selectedStatus == null
        ? allReports
        : allReports.where((r) => r.status == _selectedStatus).toList();

    if (allReports.isEmpty) {
      return [_buildEmptyState()];
    }

    if (filteredReports.isEmpty) {
      return [_buildFilteredEmptyState()];
    }

    final groupedReports = _groupReportsByDate(filteredReports);
    final List<Widget> slivers = [];

    for (final entry in groupedReports.entries) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              entry.key,
              style: TextStyle(
                color: AppColors.secondary.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      );

      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final report = entry.value[index];
              return RepaintBoundary(
                child: ReportCard(
                  report: report,
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
            childCount: entry.value.length,
          ),
        ),
      );
    }

    return slivers;
  }

  Map<String, List<Report>> _groupReportsByDate(List<Report> reports) {
    final Map<String, List<Report>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final report in reports) {
      if (report.generatedAt == null) {
        groups.putIfAbsent('Sin Fecha', () => []).add(report);
        continue;
      }

      final date = DateTime(
        report.generatedAt!.year,
        report.generatedAt!.month,
        report.generatedAt!.day,
      );

      String title;
      if (date == today) {
        title = 'HOY';
      } else if (date == yesterday) {
        title = 'AYER';
      } else if (now.difference(date).inDays < 7) {
        title = 'ESTA SEMANA';
      } else if (now.difference(date).inDays < 30) {
        title = 'ESTE MES';
      } else {
        title = DateFormat('MMMM yyyy', 'es').format(date).toUpperCase();
      }

      groups.putIfAbsent(title, () => []).add(report);
    }

    return groups;
  }

  Widget _buildEmptyState() {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text(
              'No hay informes disponibles',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Tus informes generados aparecerán aquí.',
              style: TextStyle(color: Colors.white30, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.filter_list_off, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'No hay resultados',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'No se encontraron informes con este filtro.',
              style: TextStyle(color: Colors.white30, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _selectedStatus = null),
              child: const Text('Limpiar Filtros', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
        ),
      ),
    );
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
            const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            const Text('Generar Nuevo Informe',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Utiliza la IA para analizar tus datos de salud recientes y generar un resumen detallado.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              ),
              onPressed: () {
                context.read<ReportBloc>().add(GenerateReportEvent(
                      prompt: 'Generar nuevo informe de salud',
                      contextData: ['Signos vitales recientes', 'Alergias conocidas'],
                    ));
              },
              child: const Text('Generar Ahora'),
            ),
          ],
        ),
      ),
    );
  }
}
