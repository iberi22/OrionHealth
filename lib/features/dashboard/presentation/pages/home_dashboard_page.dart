import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/features/local_agent/presentation/chat_page.dart';
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_page.dart';
import 'package:orionhealth_health/features/medications/presentation/pages/medications_page.dart';
import 'package:orionhealth_health/features/reports/presentation/pages/reports_page.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/timeline_page.dart';
import 'package:orionhealth_health/features/medical_research/presentation/pages/medical_research_page.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_cubit.dart';
import 'package:orionhealth_health/features/dashboard/application/dashboard_state.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';
import 'package:orionhealth_health/features/dashboard/presentation/widgets/quick_action_card.dart';
import 'package:orionhealth_health/features/dashboard/presentation/widgets/activity_tile.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardCubit>().loadDashboardData(),
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'ORION HEALTH',
                      style: TextStyle(
                        color: CyberTheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),
                if (state is DashboardLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is DashboardError)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  )
                else if (state is DashboardLoaded)
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildQuickActionsHeader(context),
                        const SizedBox(height: 16),
                        _buildQuickActionsGrid(context),
                        const SizedBox(height: 32),
                        _buildRecentActivityHeader(context),
                        const SizedBox(height: 16),
                        if (state.activities.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No hay actividad reciente',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          )
                        else
                          ...state.activities.map((activity) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: ActivityTile(
                                  title: activity.title,
                                  time: _formatTimestamp(activity.timestamp),
                                  icon: _getIconForActivity(activity.type),
                                ),
                              )),
                      ]),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} minutos';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} horas';
    } else {
      return 'Hace ${diff.inDays} días';
    }
  }

  IconData _getIconForActivity(ActivityType type) {
    switch (type) {
      case ActivityType.vitalCheck:
        return Icons.monitor_heart;
      case ActivityType.medicationTaken:
        return Icons.done;
      case ActivityType.reportGenerated:
        return Icons.description;
      case ActivityType.appointment:
        return Icons.calendar_today;
      case ActivityType.other:
        return Icons.info_outline;
    }
  }

  Widget _buildQuickActionsHeader(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.flash_on, color: CyberTheme.secondary, size: 20),
        SizedBox(width: 8),
        Text(
          'ACCIONES RÁPIDAS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        QuickActionCard(
          title: 'AI Assistant',
          icon: Icons.psychology,
          color: CyberTheme.primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(llmService: di.getIt<LlmService>()),
            ),
          ),
        ),
        QuickActionCard(
          title: 'Salud',
          icon: Icons.favorite,
          color: Colors.redAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const VitalsPage(),
            ),
          ),
        ),
        QuickActionCard(
          title: 'Estadísticas',
          icon: Icons.bar_chart,
          color: CyberTheme.secondary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ReportsPage(),
            ),
          ),
        ),
        QuickActionCard(
          title: 'Medicamentos',
          icon: Icons.medication,
          color: Colors.orangeAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MedicationsPage(),
            ),
          ),
        ),
        QuickActionCard(
          title: 'Timeline',
          icon: Icons.timeline,
          color: Colors.tealAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TimelinePage(),
            ),
          ),
        ),
        QuickActionCard(
          title: 'Investigación',
          icon: Icons.science,
          color: Colors.purpleAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MedicalResearchPage(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityHeader(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.history, color: CyberTheme.secondary, size: 20),
        SizedBox(width: 8),
        Text(
          'ACTIVIDAD RECIENTE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

